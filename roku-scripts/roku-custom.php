<?php 
#########################################################################
# Custom routines to make development easier
#
# @2019 Kevin Hoos
##########################################################################  

function genkey() {
    global $E;
    if(!is_dir($E['KEYDIR'])) {
        mkdir($E['KEYDIR'], 0755, true);
    }
    if(!is_writable($E['KEYDIR'])) {
        pl("  >> setting directory permissions for $E[KEYDIR]");
        chmod($E['KEYDIR'], 0755);
    }
    $key_file = "$E[KEYDIR]/$E[APPNAME].key";
    pl("*** Generate Key on host $E[ROKU_DEV] ***");
    telnet($E['ROKU_DEV'], 8080, "genkey", $key_file);
    finish("*** Key stored in $key_file  ***");
}

function rekey() {
    global $E;
    if(!empty($E['ROKU_GEO']) &&  !empty($E['BUILD_ENV'])) {
		pl("Copying $E[ROKU_GEO]-$E[BUILD_ENV]-* files to primary key files...");
		copy("$E[KEYDIR]/$E[ROKU_GEO]-$E[BUILD_ENV]-$E[APPNAME].key", "$E[KEYDIR]/$E[APPNAME].key");
		copy("$E[KEYDIR]/$E[ROKU_GEO]-$E[BUILD_ENV]-$E[APPNAME].pkg", "$E[KEYDIR]/$E[APPNAME].pkg");
		updateEnv();
		pl("Setting Key for $E[ROKU_GEO]-$E[BUILD_ENV]-$E[APPNAME] on host $E[ROKU_DEV]");
    } else {
		pl("Setting Key for $E[APPNAME] on host $E[ROKU_DEV]");
    }
    $data = [
        'mysubmit'=>'Rekey',
        'archive'=>curl_file_create("$E[KEYDIR]/$E[APPNAME].pkg"),
        'passwd'=>"$E[PKG_KEY]"
    ];
    $response = curl_post("http://$E[ROKU_DEV]/plugin_inspect", $data, $E['USERPASS']);
    $output = filterString($response, "Roku.Message", "trigger('Set message content', '", "').trigger('Render', node);");
    finish("Rekey: $output", checkSuccess($output));
}

function setbuild() {
    global $E;
    pl("*** Setting Build Number ***");
    setIniVal("manifest", "build_version", $E['DATE']);
    updateEnv();
	finish("*** Version $E[VERSION] ***");
}

function incbuild() {
    global $E;
    pl("*** Incrementing Build Number ***");
    $E['V3'] = getIniVal("manifest", "build_version") + 1;
    setIniVal("manifest", "build_version", $E['V3']);
    updateEnv();
    finish("*** Version $E[VERSION] ***");
}

function incminor() {
    global $E;
    pl("*** Incrementing Minor Version ***");
    $E['V2'] = getIniVal("manifest", "minor_version") + 1;
    setIniVal("manifest", "minor_version", $E['V2']);
    updateEnv();
    finish("*** Version $E[VERSION] ***");
}

function incmajor() {
    global $E;
    pl("*** Incrementing Major Version ***");
    $E['V1'] = getIniVal("manifest", "major_version") + 1;
    $E['V2'] = 0;
    setIniVal("manifest", "major_version", $E['V1']);
    setIniVal("manifest", "minor_version", $E['V2']);
    updateEnv();
    finish("*** Version $E[VERSION] ***");
}

function debug() {
    global $E, $testOk, $timeout;
    $testOk = 1;
    $timeout = 0;
    pl("*** Brightscript Debug on host $E[ROKU_DEV] ***");
    if(function_exists("consoleCreate")) {
        $console = consoleCreate();
        $script = [
            [ 'expect' => 'NeverGonnaHappen', 'action' => 'none', 'parms' => [] ], // Just open debug port, and copy to terminal & file. Needed a rule that doesn't get matched...
        ];
        consoleScript($console, $script);
    } else {
        shell_exec("telnet $E[ROKU_DEV] 8085 | tee ~/console.log");
    }
}

function launch() {
    global $E;
    pl("*** Launching DEV app on $E[ROKU_DEV] ***");
    curl_post("http://$E[ROKU_DEV]:8060/launch/dev");
}

function run_ecp_test() {
    global $E, $testOk, $timeout;
    $testOk = 1;
    $timeout = 0;
    $req = ['ROKU_DEV','ROKU_CHAN','ROKU_TEST'];
    foreach ($req as $var) if(empty($E[$var])) finish("Run_Ecp_Test: $var not set.", -1);
    $scriptfile = __DIR__.'/'.$E['ROKU_TEST'].'.php';
    #$E['CONSOLE_LOG'] = __DIR__.'/'.$E['ROKU_TEST'].date(".Ymd.His").".log";
    if(!file_exists($scriptfile)) finish("Run_Ecp_Test: file '$scriptfile' not found.", -2);
    pl("*** Running ECP Test $E[ROKU_TEST] on $E[ROKU_DEV] ***");
    include $scriptfile;
    $console = consoleCreate();
    rokuLaunch($E['ROKU_CHAN'], $E['ROKU_PARMS']);
    consoleScript($console, $script);
}

function run_unit_tests() {
    global $E, $testOk, $timeout;
    $testOk = 1;
    $timeout = 0;
    pl("*** Running Unit Tests on $E[ROKU_DEV] ***");
    $console = consoleCreate();
    curl_post("http://$E[ROKU_DEV]:8060/launch/dev?RunTests=true");
    $script = [
        [ 'expect' => '***   Total', 'action' => 'testString', 'parms' => ['Failed   =  0'] ]
    ];
    consoleScript($console, $script);
}

function home() {
    global $E;
    pl("*** Pressing Home on $E[ROKU_DEV] ***");
    curl_post("http://$E[ROKU_DEV]:8060/keypress/home");
    curl_post("http://$E[ROKU_DEV]:8060/keypress/home");
}

function setconfig() {
    pl("*** Setting config options ***");
    $manifest_options = [
        "CONFIG_FILE"=>"config_file",
        "CHANNEL_TOKEN"=>"channel_token"
    ];
    $ADBMobile_options = [
        "ANALYTICS_SSL"=>"analytics/ssl",
        "ANALYTICS_RSIDS"=>"analytics/rsids",
        "ANALYTICS_SERVER"=>"analytics/server",
        "MEDIAHEARTBEAT_SSL"=>"mediaHeartbeat/ssl",
    ];
    foreach($manifest_options as $opt=>$key) {
        $val = getenv($opt);
        if(!empty($val)) {
            setIniVal("manifest", $key, $val);
            pl("> manifest > $key, $val");
        }
    }
    foreach($ADBMobile_options as $opt=>$key) {
        $val = getenv($opt);
        if(!empty($val)) {
            setJsonVal("ADBMobileConfig.json", $key, $val);
            pl("> ADBMobileConfig.json > $key, $val");
        }
    }
}

function build() {
    setbuild();
    install();
}

function pkg_us_default() {
    global $E;
    $E["APPNAME"]="cbs-roku";
    $E["REPO"]="allaccess-domestic";
    $E["ROLE"]="roku";
    $E["ROKU_GEO"]="domestic";
    $E["STAGE_PROD"]="us";
    $E["CHANNEL_TOKEN"]="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2t1LXBlcm0iOlsiZ2V0X2RldmljZV9pZCJdLCJzdWIiOiJ1cm46cm9rdS5jb206c3RiLzMxNDQwIiwiaXNzIjoidXJuOnJva3UuY29tOnRva2VubWludDpjaGFubmVsdG9rZW4iLCJqdGkiOiJ1cm46ZDJhMzA0ZjctOGViMS00ZmY0LWFmNzUtNjg2NDExNGFhNzQ0IiwiZXhwIjoxNTU5MzUwODAwLCJpYXQiOjE1NTQ3Njk1MDIsInJva3UtY2hhbm5lbC1pZCI6WyIzMTQ0MCJdLCJuYmYiOjE0NzI5MDQwMDAsInJva3UtdGZ2IjoiMSIsImF1ZCI6InVybjpyb2t1LmNvbTpzdGIvY2hhbm5lbCJ9.DGt01TOljBt1HYaUt8_BxoUn10okS-OBliQ3YAX26W32fWFzsCnN1t6aODD62AHX_srtBDziqLSRbAEXnnEM9a0m_AgVxZ9SBAZSOnV02V-td4i8c3Ep-pre8LP40uAlOeXgawDdBj05lIukdandxfsaT6OXZElKWDaQ6a54oS5FPaUjjs0bmud8UwVtHFaDk9vP94RX53wetwJHysCrgHIlNaHf1uGnDDc8I-rQvaJIjahjt08gT7h20yImnQ7RmON6t2sOSCbnzzNYU7fXB_iQuKi4AJ4YybzvnyN52htacLbuv8dRJ2e4-cplVFSoyVgDSZppfShckZH4AgOjxw";
}

function pkg_us_qa_testwww() {
    global $E;
    pkg_us_default();
    $E["BUILD_TYPE"]="qa";
    $E["BUILD_ENV"]="testwww";
    $E["CONFIG_FILE"]="pkg:/config-staging.json";
    $E["ANALYTICS_SSL"]="false";
    $E["ANALYTICS_SERVER"]="aa.cbsi.com";
    $E["MEDIAHEARTBEAT_SSL"]="false";
    all();
}

function pkg_us_qa_prod() {
    global $E;
    pkg_us_default();
    $E["BUILD_TYPE"]="qa";
    $E["BUILD_ENV"]="prod";
    $E["CONFIG_FILE"]="pkg:/config.json";
    $E["ANALYTICS_SSL"]="true";
    $E["ANALYTICS_SERVER"]="saa.cbsi.com";
    $E["MEDIAHEARTBEAT_SSL"]="true";
    all();
}

function pkg_us_cert_prod() {
    global $E;
    pkg_us_default();
    $E["BUILD_TYPE"]="cert";
    $E["BUILD_ENV"]="prod";
    $E["CONFIG_FILE"]="pkg:/config.json";
    $E["ANALYTICS_SSL"]="true";
    $E["ANALYTICS_SERVER"]="saa.cbsi.com";
    $E["MEDIAHEARTBEAT_SSL"]="true";
    all();
}

function pkg_ca_default() {
    global $E;
    $E["APPNAME"]="cbs-roku";
    $E["REPO"]="allaccess-ca";
    $E["ROLE"]="roku";
    $E["ROKU_GEO"]="canada";
    $E["STAGE_PROD"]="ca";
    $E["CHANNEL_TOKEN"]="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2t1LXBlcm0iOlsiZ2V0X2RldmljZV9pZCJdLCJzdWIiOiJ1cm46cm9rdS5jb206c3RiLzMxNDQwIiwiaXNzIjoidXJuOnJva3UuY29tOnRva2VubWludDpjaGFubmVsdG9rZW4iLCJqdGkiOiJ1cm46ZDJhMzA0ZjctOGViMS00ZmY0LWFmNzUtNjg2NDExNGFhNzQ0IiwiZXhwIjoxNTU5MzUwODAwLCJpYXQiOjE1NTQ3Njk1MDIsInJva3UtY2hhbm5lbC1pZCI6WyIzMTQ0MCJdLCJuYmYiOjE0NzI5MDQwMDAsInJva3UtdGZ2IjoiMSIsImF1ZCI6InVybjpyb2t1LmNvbTpzdGIvY2hhbm5lbCJ9.DGt01TOljBt1HYaUt8_BxoUn10okS-OBliQ3YAX26W32fWFzsCnN1t6aODD62AHX_srtBDziqLSRbAEXnnEM9a0m_AgVxZ9SBAZSOnV02V-td4i8c3Ep-pre8LP40uAlOeXgawDdBj05lIukdandxfsaT6OXZElKWDaQ6a54oS5FPaUjjs0bmud8UwVtHFaDk9vP94RX53wetwJHysCrgHIlNaHf1uGnDDc8I-rQvaJIjahjt08gT7h20yImnQ7RmON6t2sOSCbnzzNYU7fXB_iQuKi4AJ4YybzvnyN52htacLbuv8dRJ2e4-cplVFSoyVgDSZppfShckZH4AgOjxw";
}

function pkg_ca_qa_testwww() {
    global $E;
    pkg_ca_default();
    $E["BUILD_TYPE"]="qa";
    $E["BUILD_ENV"]="testwww";
    $E["CONFIG_FILE"]="pkg:/config-canada-staging.json";
    $E["ANALYTICS_SSL"]="false";
    $E["ANALYTICS_SERVER"]="om.cbsi.com";
    $E["MEDIAHEARTBEAT_SSL"]="false";
    all();
}

function pkg_ca_qa_prod() {
    global $E;
    pkg_ca_default();
    $E["BUILD_TYPE"]="qa";
    $E["BUILD_ENV"]="prod";
    $E["CONFIG_FILE"]="pkg:/config-canada.json";
    $E["ANALYTICS_SSL"]="false";
    $E["ANALYTICS_SERVER"]="om.cbsi.com";
    $E["MEDIAHEARTBEAT_SSL"]="false";
    all();
}

function pkg_ca_cert_prod() {
    global $E;
    pkg_ca_default();
    $E["BUILD_TYPE"]="cert";
    $E["BUILD_ENV"]="prod";
    $E["CONFIG_FILE"]="pkg:/config-canada.json";
    $E["ANALYTICS_SSL"]="false";
    $E["ANALYTICS_SERVER"]="om.cbsi.com";
    $E["MEDIAHEARTBEAT_SSL"]="false";
    all();
}
