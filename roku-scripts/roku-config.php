<?php 
#########################################################################
# config include file for ALL applications
#
# By default, ZIP_EXCLUDE will exclude -x \*.pkg -x storeassets\* -x keys\* -x .\*
# If you define ZIP_EXCLUDE in your Makefile, it will override the default setting.
#
# To exclude different files from being added to the zipfile during packaging
# include a line like this:ZIP_EXCLUDE= -x keys\*
# that will exclude any file who's name begins with 'keys'
# to exclude using more than one pattern use additional '-x <pattern>' arguments
# ZIP_EXCLUDE= -x \*.pkg -x storeassets\*
#
# Important Notes: 
# To use the "install" and "remove" targets to install your
# application directly from the shell, you must do the following:
#
# 1) Make sure that you have the curl command line executable in your path
# 2) Set the variable ROKU_DEV in your environment to the IP 
#    address of your Roku box. (e.g. export ROKU_DEV=192.168.1.1.
#    Set in your this variable in your shell startup (e.g. .bashrc)
##########################################################################

//import needed env vars into php script.
$E = array();
$env_vars = ["ARTIFACTORY","APPNAME","REPO","ROLE","ROKU_DEV","ROKU_PASS","ROKU_GEO","STAGE_PROD","BUILD_TYPE","BUILD_ENV",
    "ROKU_TEST","ROKU_CHAN","ROKU_PARMS","HOME","COMMENT","COUNTRY"];
foreach ($env_vars as $var) $E[$var] = getenv($var);

$E['TOOLDIR'] = dirname(__DIR__);
$E['KEYDIR'] = "$E[TOOLDIR]/keys";
$E['DISTDIR'] = "$E[TOOLDIR]/dist";
$E['COMMONDIR'] = "$E[TOOLDIR]/common";
$E['MINI_PKG_ZIP'] = "$E[TOOLDIR]/keys/mini-pkg.zip";

$E['ZIPDIR'] = "$E[DISTDIR]/apps";
$E['PKGDIR'] = "$E[DISTDIR]/packages";

$E['SOURCEDIR'] = getcwd();
if(empty($E['APPNAME'])) $E['APPNAME'] = getValueFromFile("$E[SOURCEDIR]/Makefile", 'APPNAME');
if(empty($E['APPNAME'])) $E['APPNAME'] = basename($E['SOURCEDIR']);
$E['APPSOURCEDIR'] = "$E[SOURCEDIR]/source";
$E['APPCOMPDIR'] = "$E[SOURCEDIR]/components";

$E['CONSOLE_LOG'] = "$E[HOME]/console.log";

if(!empty($E['ROKU_PASS'])) $E['USERPASS'] = "rokudev:$E[ROKU_PASS]";
else $E['USERPASS'] = "rokudev";

if(empty($E['ZIP_EXCLUDE'])) $E['ZIP_EXCLUDE'] = "-x \*.pkg -x exclude\* -x \.* -x \*/.\* -x /.git\* -x /.history\* -x \*~ -x Makefile -x Jenkinsfile";

if(empty($E['ROKU_CHAN'])) $E['ROKU_CHAN'] = "dev";
if(empty($E['ROKU_DEV'])) $E['ROKU_DEV'] = "10.16.181.8";

$E['PKG_TIME'] = time();
$E['DATE'] = date("Ymd");
$E['TIME'] = date("mdHi");

function updateEnv() {
    global $E;
    $E['V1'] = getValueFromFile("manifest", "major_version", "=");
    $E['V2'] = getValueFromFile("manifest", "minor_version", "=");
    $E['V3'] = getValueFromFile("manifest", "build_version", "=");
    $comment = getValueFromFile("manifest", "build_comment", "=");
    if(!empty($comment)) $E['COMMENT'] = $comment;
    $E['VERSION'] = "$E[V1].$E[V2].$E[V3]";
    $E['APPFULLNAME'] = "$E[APPNAME].$E[VERSION].$E[TIME]";
    if(!empty($E['BUILD_TYPE'])) $E['APPFULLNAME'] .= ".$E[BUILD_TYPE]";
    if(!empty($E['COMMENT'])) $E['APPFULLNAME'] .= ".$E[COMMENT]";
    if(!empty($E['ROKU_GEO'])) $E['APPFULLNAME'] .= ".$E[ROKU_GEO]";
    if(!empty($E['BUILD_ENV'])) $E['APPFULLNAME'] .= ".$E[BUILD_ENV]";
    $E['PKG_KEY_FILE'] = "$E[KEYDIR]/$E[APPNAME].pkg";
    if(!empty($E['ROKU_GEO']) &&  !empty($E['BUILD_ENV'])) {
        $E['PKG_KEY_FILE'] = "$E[KEYDIR]/$E[ROKU_GEO]-$E[BUILD_ENV]-$E[APPNAME].pkg";
    }
    $E['PKG_KEY'] = getValueFromFile(substr($E['PKG_KEY_FILE'], 0, -3)."key", "Password", ":");
}

function setConfig() {
    global $E;
    pl("*** Setting config options ***");
    $proxyFiles = [
        "/components/shared/proxy",
        "/components/services/dw",
        "/components/services/innovid",
        "/components/services/adobe/adbmobile",
        "/components/services/comscore/ComScore",
        "/components/services/conviva/Conviva_Roku"
    ];
    $manifest_options = [
        "CONFIG_FILE"=>"config_file",
        "CHANNEL_TOKEN"=>"channel_token",
        "SPLASH_SCREEN_FHD"=>"splash_screen_fhd",
        "SPLASH_SCREEN_HD"=>"splash_screen_hd",
        "SPLASH_SCREEN_SD"=>"splash_screen_sd",
        "SPLASH_COLOR"=>"splash_color",
    ];
    $ADBMobile_options = [
        "ANALYTICS_SSL"=>"analytics/ssl",
        "ANALYTICS_RSIDS"=>"analytics/rsids",
        "ANALYTICS_SERVER"=>"analytics/server",
        "MEDIAHEARTBEAT_SSL"=>"mediaHeartbeat/ssl",
    ];
    if(!empty($E["ENABLE_PROXY"])) {
        if($E["ENABLE_PROXY"] == "true") {
            $E["BS_CONST"] = "enableProxy=true";
            foreach ($proxyFiles as $proxyFile) {
                swapFiles($proxyFile, ".brs.ref", ".brs", ".brs.orig");
            }
        } else {
            $E["BS_CONST"] = "enableProxy=false";
            foreach ($proxyFiles as $proxyFile) {
                swapFiles($proxyFile, ".brs.orig", ".brs", ".brs.ref");
            }
        }
        $manifest_options["BS_CONST"]="bs_const";
    }
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

function swapFiles($base, $from, $active, $to) {
    global $E;
    if(file_exists($E["SOURCEDIR"].$base.$from)) {
        if(is_file($E["SOURCEDIR"].$base.$active)) {
            if(!is_file($E["SOURCEDIR"].$base.$to)) {
                pl("> Swapping Files: $base$from to $base$active");
                rename($E["SOURCEDIR"].$base.$active, $E["SOURCEDIR"].$base.$to);
                rename($E["SOURCEDIR"].$base.$from, $E["SOURCEDIR"].$base.$active);
            }
        }
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

?>