<?php 
function help() {
    global $argv;
    pl("Usage: $argv[0] [COMMAND] [VAR=VALUE]...");
    pl("Build Simple PHP script for packaging Roku SDK Applications.");
    pl("Common usage:");
    pl("> $argv[0] build");
    pl("> $argv[0] install");
    pl("> $argv[0] package");
    pl("> $argv[0] remove");
    pl("> $argv[0] run_ecp_test ROKU_TEST=sample-test");
    finish("", 0, true);
}

function pl($line = "") {
    printf("%s\n", $line);
}

function finish($line, $code = 0, $force = false) {
    global $E;
    if($code <> 0) {
        $trace = debug_backtrace();
        $failmsg = sprintf("*** %s ***\n*** %s(%d) - %s ***",
            "roku-make $E[APPFULLNAME] failed",
            basename($trace[0]["file"]),
            $trace[0]["line"],
            $trace[1]["function"]
        );
        $line = sprintf("%s\n%s", $failmsg, $line);
    }
    file_put_contents(".roku-make.out", $line);
    pl($line);
    if(($code <> 0) or $force) {
        die($code);
    }
}

function httpStatusString($code) {
    switch ($code) {
        case 100: return 'Continue';
        case 101: return 'Switching Protocols';
        case 200: return 'OK';
        case 201: return 'Created';
        case 202: return 'Accepted';
        case 203: return 'Non-Authoritative Information';
        case 204: return 'No Content';
        case 205: return 'Reset Content';
        case 206: return 'Partial Content';
        case 300: return 'Multiple Choices';
        case 301: return 'Moved Permanently';
        case 302: return 'Moved Temporarily';
        case 303: return 'See Other';
        case 304: return 'Not Modified';
        case 305: return 'Use Proxy';
        case 400: return 'Bad Request';
        case 401: return 'Unauthorized';
        case 402: return 'Payment Required';
        case 403: return 'Forbidden';
        case 404: return 'Not Found';
        case 405: return 'Method Not Allowed';
        case 406: return 'Not Acceptable';
        case 407: return 'Proxy Authentication Required';
        case 408: return 'Request Time-out';
        case 409: return 'Conflict';
        case 410: return 'Gone';
        case 411: return 'Length Required';
        case 412: return 'Precondition Failed';
        case 413: return 'Request Entity Too Large';
        case 414: return 'Request-URI Too Large';
        case 415: return 'Unsupported Media Type';
        case 500: return 'Internal Server Error';
        case 501: return 'Not Implemented';
        case 502: return 'Bad Gateway';
        case 503: return 'Service Unavailable';
        case 504: return 'Gateway Time-out';
        case 505: return 'HTTP Version not supported';
        default:  return 'Unknown http status code';
    }
}

function curl_post($url, $data = '', $digest = '') {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");
    curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    if(!empty($digest)) {
        curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_ANY);
        curl_setopt($ch, CURLOPT_USERPWD, $digest);
    }
    $result = curl_exec($ch);
    $info = curl_getinfo($ch);
    $errno = curl_errno($ch);
    if($errno) {
        $result = sprintf("cURL Error(%d): %s\n", $errno, curl_strerror($errno));
    } else if($info['http_code'] >= 300) {
        $result = sprintf("HTTP Error(%d): %s\n", $info['http_code'], httpStatusString($info['http_code']));
    }
    curl_close($ch);
    return $result;
}

function curl_binary($url, $filename, $digest) {
    $fp = fopen($filename, 'w');
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_FILE, $fp);
    if(!empty($digest)) {
        curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_ANY);
        curl_setopt($ch, CURLOPT_USERPWD, $digest);
    }
    $result = curl_exec($ch);
    $info = curl_getinfo($ch);
    $errno = curl_errno($ch);
    if($errno) {
        $result = sprintf("cURL Error(%d): %s\n", $errno, curl_strerror($errno));
    } else if($info['http_code'] >= 300) {
        $result = sprintf("HTTP Error(%d): %s\n", $info['http_code'], httpStatusString($info['http_code']));
    }
    curl_close($ch);
    fclose($fp);
    return $result;
}

function telnet($host, $port, $command, $logname = null) {
    $console = fsockopen($host, $port);
    if(!$console) die("Failed to open console connection to $host\n");
    if($logname <> null) file_put_contents($logname, "");
    fwrite($console, trim($command)."\n");
    
    do {
        $read   = array($console);
        $write  = NULL;
        $except = NULL;
        
        if(!is_resource($console)) return;
        $num_changed_streams = @stream_select($read, $write, $except, 1);
        if(feof($console)) return;
        
        if ($num_changed_streams > 0) {
            $data = fgets($console, 4096);
            if($logname <> null) file_put_contents($logname, $data, FILE_APPEND);
            echo "$data";
        } else {
            return;
        }
    } while(true);
}

function setIniVal($filename, $parm, $newval) {
    $lines = file($filename, FILE_IGNORE_NEW_LINES);
    $changed = 0;
    $i = 0;
    $len = count($lines);
    do {
        $line = $lines[$i];
        if(strpos($line, '=') <> false) {
            list($key, $val) = explode('=', $line);
            if(strcasecmp($key, $parm) === 0) {
                $lines[$i] = sprintf("%s=%s", $parm, $newval);
                $changed = 1;
            }
        }
        $i++;
    } while(($changed == 0) && ($i <= $len));
    if($changed == 0) {
        $lines[] = sprintf("%s=%s", $parm, $newval);
    }
    $lines[] = "";
    file_put_contents($filename, implode("\n", $lines));
}

function getIniVal($filename, $parm) {
    $lines = file($filename, FILE_IGNORE_NEW_LINES);
    $i = 0;
    $len = count($lines);
    
    do {
        $line = $lines[$i];
        if(strpos($line, '=') <> false) {
            list($key, $val) = explode('=', $line);
            if(strcmp($key, $parm) === 0) {
                return $val;
            }
        }
        $i++;
    } while($i < $len);
    return "";
}

function getJsonVal($filename, $parm) {
    $file = file($filename, FILE_IGNORE_NEW_LINES);
    $json = json_decode(implode('', $file),true);
    $keys = explode('/', $parm);
    $ptr = $json;
    foreach($keys as $key) {
        echo ">> $key\n";
        if(!array_key_exists($key, $ptr)) {
            return "";
        }
        $ptr = $ptr[$key];
    }
    return $ptr;
}

function setJsonVal($filename, $parm, $val) {
    $file = file($filename, FILE_IGNORE_NEW_LINES);
    $json = json_decode(implode('', $file),true);
    $keys = explode('/', $parm);
    $new = _setJsonVal($json, $keys, $val);
    file_put_contents($filename, json_encode($new, JSON_PRETTY_PRINT));
}

function _setJsonVal($arr, $keys, $val) {
    if(count($keys) > 1) {
        $key = array_shift($keys);
        $arr[$key] = _setJsonVal($arr[$key], $keys, $val);
    } else {
        $bool = filter_var($val, FILTER_VALIDATE_BOOLEAN, FILTER_NULL_ON_FAILURE);
        if($bool !== null) $val = $bool;
        $arr[$keys[0]] = $val;
    }
    return $arr;
}

function getValueFromFile($file, $key, $sep = "=") {
    $ret = "";
    if(!empty($file) and file_exists($file) and !empty($key)) {
        if ($fh = fopen($file, 'r')) {
            while (!feof($fh) and empty($ret)) {
                $line = fgets($fh);
                if(strpos($line, $key) !== false) {
                    $ret = trim(explode($sep, $line)[1]);
                }
            }
            fclose($fh);
        }
    }
    return $ret;
}

function filterString($str, $inline, $beg = '', $end = '', $strict = false) {
    $lines = explode("\n", $str);
    $i = 0;
    $len = count($lines);
    do {
        $line = $lines[$i];
        if(strpos($line, $inline) <> false) {
            if(empty($beg) && !$strict) return $line;
            $msgStart = strpos($line, $beg) + strlen($beg);
            $msgEnd = strpos($line, $end, $msgStart);
            $msgLen = $msgEnd - $msgStart;
            return substr($line, $msgStart, $msgLen);
        }
        $i++;
    } while($i < $len);
    if($strict) return "";
    return $str;
}

function checkSuccess($output, $success = "Succe") {
    return (stripos($output, $success) === false) ? -1 : 0;
}

?>