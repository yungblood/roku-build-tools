<?php
    function rokuCurl($method, $url) {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL,  $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        if($method == 'POST') {
            curl_setopt($ch, CURLOPT_POST, 1);
        }
        $output = curl_exec($ch);
        curl_close($ch);

        return $output;
    }
    
//Roku ECP commands.
    function rokuApps() {
        global $E;
        return rokuCurl('GET', "http://$E[ROKU_DEV]:8060/query/apps");
    }
    function rokuActiveApp() {
        global $E;
        return rokuCurl('GET', "http://$E[ROKU_DEV]:8060/query/active-app");
    }
    function rokuKeydown($key) {
        global $E;
        return rokuCurl('POST', "http://$E[ROKU_DEV]:8060/keydown/$key");
    }
    function rokuKeyup($key) {
        global $E;
        return rokuCurl('POST', "http://$E[ROKU_DEV]:8060/keyup/$key");
    }
    function rokuKeypress($key, $count = 1) {
        global $E;
        for ($c = 0; $c < $count; $c++) {
            rokuCurl('POST', "http://$E[ROKU_DEV]:8060/keypress/$key");
        }
    }
    function rokuKeyChar($char = '') {
        if(ctype_alnum($char)) {
            return rokuKeypress("Lit_".$char);
        } else {
            return rokuKeypress("Lit_%".dechex(ord($char)));
        }
    }
    function rokuKeyString($string) {
        $len = strlen($string);
        for ($i = 0; $i < $len; $i++){
            rokuKeyChar($string[$i]);
        }
    }
    function rokuLaunch($channel = '', $launchparms = '') {
        global $E;
        if(empty($channel)) $channel = $E['ROKU_CHAN'];
        if(empty($launchparms)) $launchparms = $E['ROKU_PARMS'];
        return rokuCurl('POST', "http://$E[ROKU_DEV]:8060/launch/$channel$launchparms");
    }
    function rokuInstall($channel = '', $launchparms = '') {
        global $E;
        if(empty($channel)) $channel = $E['ROKU_CHAN'];
        if(empty($launchparms)) $launchparms = $E['ROKU_PARMS'];
        return rokuCurl('POST', "http://$E[ROKU_DEV]:8060/install/$channel$launchparms");
    }
    function rokuDeviceInfo() {
        global $E;
        return rokuCurl('GET', "http://$E[ROKU_DEV]:8060/query/device-info");
    }
    function rokuAppIcon($channel) {
        global $E;
        return rokuCurl('GET', "http://$E[ROKU_DEV]:8060/query/icon/$channel");
    }
    function rokuMediaPlayer() {
        global $E;
        return rokuCurl('GET', "http://$E[ROKU_DEV]:8060/query/media-player");
    }
    function rokuInput($inputparms) {
        global $E;
        return rokuCurl('POST', "http://$E[ROKU_DEV]:8060/input/$inputparms");
    }
    function rokuSearch($searchparms) {
        global $E;
        return rokuCurl('POST', "http://$E[ROKU_DEV]:8060/search/browse$searchparms");
    }
    function rokuTvChannels() {
        global $E;
        return rokuCurl('GET', "http://$E[ROKU_DEV]:8060/query/tv-channels");
    }
    function rokuTvActiveChannel() {
        global $E;
        return rokuCurl('GET', "http://$E[ROKU_DEV]:8060/query/tv-active-channel");
    }
    function rokuTvLaunch($launchparms = '') {
        global $E;
        if(empty($launchparms)) $launchparms = $E['ROKU_PARMS'];
        return rokuCurl('POST', "http://$E[ROKU_DEV]:8060/launch/tvinput.dtv$launchparms");
    }

?>