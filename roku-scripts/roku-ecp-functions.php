<?php
//Roku ECP commands.
    function rokuApps() {
        global $E;
        return _curl("http://$E[ROKU_DEV]:8060/query/apps");
    }
    function rokuActiveApp() {
        global $E;
        return _curl("http://$E[ROKU_DEV]:8060/query/active-app");
    }
    function rokuKeydown($key) {
        global $E;
        if(empty($key)) $key = $E['ROKU_PARMS'];
        return _curl("http://$E[ROKU_DEV]:8060/keydown/$key", 'POST');
    }
    function rokuKeyup($key) {
        global $E;
        if(empty($key)) $key = $E['ROKU_PARMS'];
        return _curl("http://$E[ROKU_DEV]:8060/keyup/$key", 'POST');
    }
    function rokuKeypress($key, $count = 1) {
        global $E;
        if(empty($key)) $key = $E['ROKU_PARMS'];
        for ($c = 0; $c < $count; $c++) {
            _curl("http://$E[ROKU_DEV]:8060/keypress/$key", 'POST');
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
        if(empty($string)) $string = $E['ROKU_PARMS'];
        $len = strlen($string);
        for ($i = 0; $i < $len; $i++){
            rokuKeyChar($string[$i]);
        }
    }
    function rokuLaunch($channel = '', $launchparms = '') {
        global $E;
        if(empty($channel)) $channel = $E['ROKU_CHAN'];
        if(empty($launchparms)) $launchparms = $E['ROKU_PARMS'];
        if(empty($channel)) $channel = 'dev';
        $url = "http://$E[ROKU_DEV]:8060/launch/$channel";
        if(!empty($launchparms)) $url .= "?$launchparms";
        return _curl($url, 'POST');
    }
    function rokuInstall($channel = '', $launchparms = '') {
        global $E;
        if(empty($channel)) $channel = $E['ROKU_CHAN'];
        if(empty($launchparms)) $launchparms = $E['ROKU_PARMS'];
        $url = "http://$E[ROKU_DEV]:8060/install/$channel";
        if(!empty($launchparms)) $url .= "?$launchparms";
        return _curl($url, 'POST');
    }
    function rokuDeviceInfo() {
        global $E;
        return _curl("http://$E[ROKU_DEV]:8060/query/device-info");
    }
    function rokuAppIcon($channel) {
        global $E;
        if(empty($channel)) $channel = $E['ROKU_CHAN'];
        return _curl("http://$E[ROKU_DEV]:8060/query/icon/$channel");
    }
    function rokuMediaPlayer() {
        global $E;
        return _curl("http://$E[ROKU_DEV]:8060/query/media-player");
    }
    function rokuInput($inputparms) {
        global $E;
        if(empty($inputparms)) $inputparms = $E['ROKU_PARMS'];
        return _curl("http://$E[ROKU_DEV]:8060/input/$inputparms", 'POST');
    }
    function rokuSearch($searchparms) {
        global $E;
        if(empty($searchparms)) $searchparms = $E['ROKU_PARMS'];
        return _curl("http://$E[ROKU_DEV]:8060/search/browse?$searchparms", 'POST');
    }
    function rokuTvChannels() {
        global $E;
        return _curl("http://$E[ROKU_DEV]:8060/query/tv-channels");
    }
    function rokuTvActiveChannel() {
        global $E;
        return _curl("http://$E[ROKU_DEV]:8060/query/tv-active-channel");
    }
    function rokuTvLaunch($launchparms = '') {
        return rokuLaunch('tvinput.dtv', $launchparms);
    }
?>