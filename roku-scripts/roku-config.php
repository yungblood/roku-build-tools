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
    "ROKU_TEST","ROKU_CHAN","ROKU_PARMS","HOME","COMMENT","JENKINS_DISABLE"];
foreach ($env_vars as $var) $E[$var] = getenv($var);

$E['SOURCEDIR'] = getcwd();
if(empty($E['APPNAME'])) $E['APPNAME'] = getValueFromFile("$E[SOURCEDIR]/Makefile", 'APPNAME');
if(empty($E['APPNAME'])) $E['APPNAME'] = basename($E['SOURCEDIR']);
$E['KEYDIR'] = "$E[SOURCEDIR]/exclude/keys";
$E['DISTDIR'] = "$E[SOURCEDIR]/exclude/dist";
$E['COMMONDIR'] = "$E[SOURCEDIR]/exclude/common";
$E['APPSOURCEDIR'] = "$E[SOURCEDIR]/source";
$E['APPCOMPDIR'] = "$E[SOURCEDIR]/components";
$E['CONSOLE_LOG'] = "$E[HOME]/console.log";
$E['MINI_PKG_ZIP'] = "$E[SOURCEDIR]/exclude/keys/mini-pkg.zip";

$E['ZIPDIR'] = "$E[DISTDIR]/apps";
$E['PKGDIR'] = "$E[DISTDIR]/packages";

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
?>