<?php 
#########################################################################
# Custom routines to make development easier
#
# @2019 Kevin Hoos
##########################################################################  

function clean() {
    global $E;
    $files = array_merge(glob($E['ZIPDIR'] . '/*'), glob($E['PKGDIR'] . '/*'));
    
    foreach($files as $file){
        if(is_file($file)){
            pl("Deleting: $file");
            unlink($file);
        }
    }
}

function genkey() {
    global $E;
    if(!is_dir($E['KEYDIR'])) {
        mkdir($E['KEYDIR'], 0755, true);
    }
    if(!is_writable($E['KEYDIR'])) {
        pl("  >> setting directory permissions for $E[KEYDIR]");
        chmod($E['KEYDIR'], 0755);
    }
    $key_file = substr($E['PKG_KEY_FILE'], 0, -3)."key";
    pl("*** Generate Key: $E[PKG_KEY_FILE] on host $E[ROKU_DEV] ***");
    telnet($E['ROKU_DEV'], 8080, "genkey", $key_file);
    finish("*** Key stored in $key_file  ***");
    updateEnv();
    pl("Installing mini-pkg on host $E[ROKU_DEV]");
    home();
    $data = [
        'mysubmit'=>'Install',
        'archive'=>curl_file_create($E['MINI_PKG_ZIP']),
        'passwd'=>""
    ];
    $response = curl_post("http://$E[ROKU_DEV]/plugin_install", $data, $E['USERPASS']);
    $output = filterString($response, "Roku.Message", "trigger('Set message content', '", "').trigger('Render', node);");
    finish("Install mini-pkg: $output", checkSuccess($output, "Received"));
    package();
}

function rekey() {
    global $E;
    pl("*** Setting Key: $E[PKG_KEY_FILE] on host $E[ROKU_DEV] ***");
    if(is_file($E['PKG_KEY_FILE'])) {
        $data = [
            'mysubmit'=>'Rekey',
            'archive'=>curl_file_create($E['PKG_KEY_FILE']),
            'passwd'=>"$E[PKG_KEY]"
        ];
        $response = curl_post("http://$E[ROKU_DEV]/plugin_inspect", $data, $E['USERPASS']);
        $output = filterString($response, "Roku.Message", "trigger('Set message content', '", "').trigger('Render', node);");
        finish("Rekey: $output", checkSuccess($output));
    } else {
        finish("Rekey: $E[PKG_KEY_FILE] does not exist", -1);
    }
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
            [ 'expect' => 'AppExitComplete', 'action' => 'none', 'parms' => [] ], // Stop debugging when app exits.
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
    global $E;
    pl("*** Setting config options ***");
    $manifest_options = [
        "CONFIG_FILE"=>"config_file",
        "CHANNEL_TOKEN"=>"channel_token",
        "SPLASH_SCREEN_FHD"=>"splash_screen_fhd",
        "SPLASH_SCREEN_HD"=>"splash_screen_hd",
        "SPLASH_SCREEN_SD"=>"splash_screen_sd",
        "SPLASH_COLOR"=>"splash_color"
    ];
    $ADBMobile_options = [
        "ANALYTICS_SSL"=>"analytics/ssl",
        "ANALYTICS_RSIDS"=>"analytics/rsids",
        "ANALYTICS_SERVER"=>"analytics/server",
        "MEDIAHEARTBEAT_SSL"=>"mediaHeartbeat/ssl",
    ];
    foreach($manifest_options as $opt=>$key) {
        $val = getenv($opt);
        if(!empty($val)) $E[$opt] = $val;
        if(!empty($E[$opt])) {
            setIniVal("manifest", $key, $E[$opt]);
            pl("> manifest > $key, $E[$opt]");
        }
    }
    foreach($ADBMobile_options as $opt=>$key) {
        $val = getenv($opt);
        if(!empty($val)) $E[$opt] = $val;
        if(!empty($E[$opt])) {
            setJsonVal("ADBMobileConfig.json", $key, $E[$opt]);
            pl("> ADBMobileConfig.json > $key, $E[$opt]");
        }
    }
}

function build() {
    setbuild();
    install();
}

function jenkins_pkg() {
    global $E;
    if(!is_file("Jenkinsfile")) finish("Unable to find: Jenkinsfile", -1);
    if(!isset($E['JENKINS']))  finish("Required var not set: JENKINS", -1);
    $jenkins = file_get_contents("Jenkinsfile");
    $envMapStart = strpos($jenkins, "[");
    $envMapLen = strpos($jenkins, "//end environmentMap") - $envMapStart;
    //Convert to clean json.
    $json = str_replace(["[","]","\n","\t"],["{","}","",""], substr($jenkins, $envMapStart, $envMapLen));
    while (strpos($json, " ") !== false) $json = str_replace(" ", "", $json);
    $json = str_replace(",}", "}", $json);
    $envMap = json_decode($json, true);

    list($region, $typeEnv) = explode("/", $E['JENKINS']);
    if(!isset($envMap[$region])) finish("Region ($region) not found in Jenkinsfile", -1);
    foreach ($envMap[$region]["default"] as $key=>$val) {
        if(empty($E[$key])) $E[$key] = $val;
    }
    if(!isset($envMap[$region][$typeEnv])) finish("$region Type/Env ($typeEnv) not found in Jenkinsfile", -1);
    foreach ($envMap[$region][$typeEnv] as $key=>$val) {
        if(empty($E[$key])) $E[$key] = $val;
    }
    updateEnv();
    all();
}
?>