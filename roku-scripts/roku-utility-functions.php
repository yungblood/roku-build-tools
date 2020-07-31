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

function debug() {
    global $E, $testOk, $timeout, $console;
    $testOk = 1;
    $timeout = 0;
    pl("*** Brightscript Debug on host $E[ROKU_DEV] ***");
    if(isset($console)) {
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

function home() {
    global $E;
    pl("*** Pressing Home on $E[ROKU_DEV] ***");
    curl_post("http://$E[ROKU_DEV]:8060/keypress/home");
    curl_post("http://$E[ROKU_DEV]:8060/keypress/home");
}

function build() {
    setbuild();
    install();
}
?>