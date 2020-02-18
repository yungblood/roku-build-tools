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
    function testString($haystack, $needle) {
        global $testOk;
        if(strpos($haystack, $needle) === false) $testOk = 0;
        return $testOk;
    }
    function testNotString($haystack, $needle) {
        global $testOk;
        if(strpos($haystack, $needle) !== false) $testOk = 0;
        return $testOk;
    }
    function setTimeout($sec = 0) {
        global $timeout;
        $timeout = $sec;
    }
    
    function consoleCreate() {
        global $E;
        $console = fsockopen($E['ROKU_DEV'], 8085);
        if(!$console) finish("Failed to open console connection to $E[ROKU_DEV]", -1, true);
        file_put_contents($E['CONSOLE_LOG'], "Connection Started: ".date("Y-m-d h:i:sa")."\n\n");
        do {
            $read   = array($console);
            $write  = NULL;
            $except = NULL;
            
            if(!is_resource($console)) return;
            $num_changed_streams = @stream_select($read, $write, $except, 1);
            if(feof($console)) return ;
            
            if($num_changed_streams === false) finish("Crashed while ignoring previous console data\n", -1, true);
            if($num_changed_streams > 0) {
                $data = fgets($console, 4096);
            }
        } while($num_changed_streams > 0);
        return $console;
    }
    
    function consoleScript(&$console, $script) {
        global $E, $testOk, $timeout;
        $testOk = 1;
        $expected = 0;
        $scriptPos = 0;
        $scriptMax = count($script);
        $lasttime = time();
        $scriptName = debug_backtrace()[1]["function"];
        $ecpline = "";
        if ($scriptName === "run_ecp_test") $scriptName = $E['ROKU_TEST'];
        do {
            $read   = array( $console);
            $write  = NULL;
            $except = NULL;
            
            if(!is_resource($console)) return;
            $num_changed_streams = @stream_select($read, $write, $except, 1);
            if(feof($console)) return ;
            
            if($num_changed_streams === false) {
                finish("Script crashed: $E[ROKU_TEST] ($scriptPos)\n", -1, true);
            } elseif($num_changed_streams === 0) {
                $data = "";
            } elseif ($num_changed_streams > 0) {
                $data = fgets($console, 4096);
                file_put_contents($E['CONSOLE_LOG'], $data, FILE_APPEND);
                echo "$data";
            }
            if($script[$scriptPos]['expect'] === '') {
                $expected = 1;
            } elseif(strpos($data, $script[$scriptPos]['expect']) !== false) {
                $expected = 1;
            }
            if($expected) {
                $lasttime = time();
                $ecpline = sprintf(">>>> ECP <<<< | expect = '%s' | action = %s(%s)\n", $script[$scriptPos]['expect'], $script[$scriptPos]['action'], implode(',', $script[$scriptPos]['parms']));
                #file_put_contents($E['CONSOLE_LOG'], $ecpline, FILE_APPEND);
                echo $ecpline;
#print_r($script[$scriptPos]);
                switch($script[$scriptPos]['action']) {
                    case 'none':
                        break;
                    case 'testString':
                    case 'testNotString':
                        array_unshift($script[$scriptPos]['parms'], $data);
                    default:
                        call_user_func_array($script[$scriptPos]['action'], $script[$scriptPos]['parms']);
                }
                $expected = 0;
                if($testOk === 0) {
                    finish("$scriptName ($scriptPos) Failed.\n".$ecpline.$data, -2, true);
                }
                $scriptPos++;
#echo "[expect] => ".$script[$scriptPos]['expect']."\n";
            }
            if(isset($timeout) && ($timeout > 0)) {
                if(time() - $lasttime > $timeout) {
                    $testOk = 0;
                    finish("$scriptName ($scriptPos) Failed. Timeout $timeout.\n".$ecpline.$data, -3, true);
                }
            }
        } while(($scriptPos < $scriptMax) && ($testOk === 1));
        if($testOk === 1) {
            finish("$scriptName Passed.\n".$ecpline.$data);
        }
    }

?>