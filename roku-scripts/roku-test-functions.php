<?php
    $console = consoleCreate();

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
        global $E, $testOk, $timeout, $console;
        $testOk = 1;
        $timeout = 0;
        pl("*** Running Unit Tests on $E[ROKU_DEV] ***");
        curl_post("http://$E[ROKU_DEV]:8060/launch/dev?RunTests=true");
        if(isset($console)) {
            $script = [
                [ 'expect' => '***   Total', 'action' => 'testString', 'parms' => ['Failed   =  0'] ]
            ];
            consoleScript($console, $script);
        }
    }
    
?>