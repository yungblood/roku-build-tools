<?php

$completeMsgs[] = "artifactoryMsg";

function curl_upload_artifactory() {
    global $E;
    $E['ARTIFACTORY'] = "http://maven.cbs.com:7305/artifactory/cbs-roku-deploys";
    $curl = "curl -v -u admin:password --upload-file ";
    if(is_file("$E[PKGDIR]/$E[APPFULLNAME].pkg")) {
        exec("$curl $E[PKGDIR]/$E[APPFULLNAME].pkg $E[ARTIFACTORY]/$E[APPFULLNAME].pkg", $result, $errno);
    }
    if(is_file("$E[ZIPDIR]/$E[APPFULLNAME].zip")) {
        exec("$curl $E[ZIPDIR]/$E[APPFULLNAME].zip $E[ARTIFACTORY]/$E[APPFULLNAME].zip", $result, $errno);
    }
    if(empty($E['ARTIFACTORY_LIST'])) $E['ARTIFACTORY_LIST'] = "";
    if(file_exists("$E[ZIPDIR]/$E[APPFULLNAME].zip")) $E['ARTIFACTORY_LIST'] .= sprintf("\n $E[ARTIFACTORY]/$E[APPFULLNAME].zip ");
    if(file_exists("$E[PKGDIR]/$E[APPFULLNAME].pkg")) $E['ARTIFACTORY_LIST'] .= sprintf("\n $E[ARTIFACTORY]/$E[APPFULLNAME].pkg ");
}

function artifactoryMsg() {
    global $E;
    $msg = "";
    if(!empty($E['ARTIFACTORY']) and empty($E['ARTIFACTORY_LIST'])) {
		$E['ARTIFACTORY_LIST'] = "";
		if(file_exists("$E[ZIPDIR]/$E[APPFULLNAME].zip")) $E['ARTIFACTORY_LIST'] .= sprintf("\n $E[ARTIFACTORY]/$E[APPFULLNAME].zip ");
		if(file_exists("$E[PKGDIR]/$E[APPFULLNAME].pkg")) $E['ARTIFACTORY_LIST'] .= sprintf("\n $E[ARTIFACTORY]/$E[APPFULLNAME].pkg ");
	}
	if(!empty($E['ARTIFACTORY_LIST'])) {
		$msg .= $E['ARTIFACTORY_LIST'];
		exec("git log -1 --pretty=%B | sed '/^$/d'", $output);
		$msg .= "\nThis Build Includes:\n```".implode("\n",$output)."```";
	}
    return $msg;
}
?>