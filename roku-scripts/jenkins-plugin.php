<?php

function read_jenkinsfile() {
    if(!is_file("Jenkinsfile")) finish("Unable to find: Jenkinsfile", -1);
    $jenkins = file_get_contents("Jenkinsfile");
    $envMapStart = strpos($jenkins, "[");
    $envMapLen = strpos($jenkins, "//end environmentMap") - $envMapStart;
    //Convert to clean json.
    $json = str_replace(["[","]","\n","\t"],["{","}","",""], substr($jenkins, $envMapStart, $envMapLen));
    while (strpos($json, " ") !== false) $json = str_replace(" ", "", $json);
    $json = str_replace(",}", "}", $json);
    $envMap = json_decode($json, true);
    return $envMap;
}

function jenkins() {
    global $E;
    if(empty($E['COUNTRY'])) finish("Required var not set: COUNTRY", -1);
    if(empty($E['BUILD_TYPE'])) finish("Required var not set: BUILD_TYPE", -1);
    $envMap = read_jenkinsfile();
    if(!empty($envMap[$E['COUNTRY']])) $country = $E['COUNTRY'];
    if(!isset($country)) finish("Unknown region: $E[COUNTRY]", -1);
    foreach ($envMap[$country]["default"] as $key=>$val) {
        if(empty($E[$key])) $E[$key] = $val;
    }
    $defaultEnv = $E;
    foreach ($envMap[$country] as $key=>$val) {
        $E = $defaultEnv;
        if(!empty($val['BUILD_TYPE']) and $val['BUILD_TYPE'] === $E['BUILD_TYPE']) {
            $build = $key;
            foreach ($envMap[$country][$build] as $key=>$val) {
                $E[$key] = $val;
            }
            updateEnv();
            all();
            if(function_exists("curl_upload_artifactory")) {
                curl_upload_artifactory();
            }
        }
    }
}

?>