<?php
$env_vars[] = "ARTIFACTORY";

function curl_upload_artifactory() {
    global $E, $completeMsgs;
    $E['ARTIFACTORY'] = "http://maven.cbs.com:7305/artifactory/cbs-roku-deploys";
    $curl = "curl -v -u admin:password --upload-file ";
    if(is_file("$E[PKGDIR]/$E[APPFULLNAME].pkg")) {
        exec("$curl $E[PKGDIR]/$E[APPFULLNAME].pkg $E[ARTIFACTORY]/$E[APPFULLNAME].pkg", $result, $errno);
    }
    if(is_file("$E[ZIPDIR]/$E[APPFULLNAME].zip")) {
        exec("$curl $E[ZIPDIR]/$E[APPFULLNAME].zip $E[ARTIFACTORY]/$E[APPFULLNAME].zip", $result, $errno);
    }
    if(empty($E['ARTIFACTORY_LIST'])) $E['ARTIFACTORY_LIST'] = "";
    if(file_exists("$E[ZIPDIR]/$E[APPFULLNAME].zip")) $completeMsgs[] = "$E[ARTIFACTORY]/$E[APPFULLNAME].zip ";
    if(file_exists("$E[PKGDIR]/$E[APPFULLNAME].pkg")) $completeMsgs[] = "$E[ARTIFACTORY]/$E[APPFULLNAME].pkg ";
}
?>