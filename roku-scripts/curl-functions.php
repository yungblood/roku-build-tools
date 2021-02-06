<?php
function _curl($url, $method = 'GET', $digestAuth = '', $data = '', $filename = '') {
    $usePhpCurl = false;
    if(function_exists("curl_version")) {
        if(floatval(curl_version()['version']) < 7.60) {
            //HACK: php-curl 7.68 doesn't work with roku, revert to command line
            //Windows also has issues with curl, revert to command line until resolved.
            //$usePhpCurl = true;
        }
    }
    if($usePhpCurl) {
        return lib_curl($url, $method, $digestAuth, $data, $filename);
    } else {
        return cmd_curl($url, $method, $digestAuth, $data, $filename);
    }
}

function lib_curl($url, $method = 'GET', $digestAuth = '', $data = '', $filename = '') {
    $ch = curl_init();
    if($method <> 'GET') {
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
        if($method == 'POST') curl_setopt($ch, CURLOPT_POST, true);
    }
    if(!empty($digest)) {
        curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_ANY);
        curl_setopt($ch, CURLOPT_USERPWD, $digest);
    }
    if(is_array($data)) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
    }
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    if(!empty($filename)) {
        $fp = fopen($filename, 'w');
        curl_setopt($ch, CURLOPT_FILE, $fp);

    }
    curl_setopt($ch, CURLOPT_URL, $url);

    $result = curl_exec($ch);
    $info = curl_getinfo($ch);
    $errno = curl_errno($ch);
    if(!empty($filename)) {
        fclose($fp);
    }
    curl_close($ch);

    return check_curl($url, $result, $info, $errno);
}

function cmd_curl($url, $method = 'GET', $digestAuth = '', $data = '', $filename = '') {
    global $E;
    $info = ['http_code'=>0];
    $curl = $E['CURLCMD'] . " -s";
    if($method <> 'GET') $curl .= " -X $method";
    if(!empty($digestAuth)) $curl .= " --digest --user $digestAuth";
    if(is_array($data)) {
        foreach($data as $key=>$val) {
            if(is_string($val)) $curl .= " -F \"$key=$val\"";
            else if(is_string($val->name)) $curl .= " -F '$key=@$val->name'";
        }
    } else if(!empty($data)) {
        $curl .= " -d '$data'";
    }
    if(!empty($filename)) {
        $curl .= " --output $filename";
    }
    $curl .= " \"$url\"";

    exec($curl, $result, $errno);
    if(array_key_exists(0, $result)) {
        $status = explode(' ', $result[0]);
        if($status[0] == "Error") {
            $info['http_code'] = intval($status[1]);
        } else {
            $result = implode("\n", $result);
        }
    }

    if ($method == 'GET') pl($result);
    return check_curl($url, $result, $info, $errno);
}

function check_curl($url, $result, $info, $errno) {
    if($errno) {
        return sprintf("cURL Error %d: %s\n%s\n", $errno, curlStatusString($errno), $url);
    } else if($info['http_code'] >= 300) {
        return sprintf("HTTP Error %d: %s\n%s\n", $info['http_code'], httpStatusString($info['http_code']), $url);
    }
    return $result;
}

function _curl_file($file) {
    if(class_exists('CURLFile')) {
        return new CURLFile($file);
    } else if(function_exists('curl_file_create')) {
        return curl_file_create($file);
    }
    return "@$file";
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
        default:  return 'Unknown HTTP status code';
    }
}

function curlStatusString($code) {
    switch ($code) {
        case  0: return 'OK';
        case  1: return 'Unsupported Protocol';
        case  2: return 'Failed Initialization';
        case  3: return 'URL Malformat';
        case  4: return 'Option Not Built In';
        case  5: return 'Could Not Resolve Proxy';
        case  6: return 'Could Not Resolve Host';
        case  7: return 'Could Not Connect';
        case  8: return 'Weird Server Reply';
        case  9: return 'Remote Access Denied';
        case 10: return 'FTP Failed Accept';
        case 11: return 'FTP Weird Pass Reply';
        case 12: return 'FTP Accept Timeout';
        case 13: return 'FTP Weird PASV Reply';
        case 14: return 'FTP Weird 227 Format';
        case 15: return 'FTP Can Not Get Host';
        case 16: return 'HTTP2 General Error';
        case 17: return 'FTP Could Not Set Type';
        case 18: return 'Partial File';
        case 19: return 'FTP Could Not RETR File';
        case 21: return 'Quote Error';
        case 22: return 'HTTP Returned Error';
        case 23: return 'Write Error';
        case 25: return 'Upload Failed';
        case 26: return 'Read Error';
        case 27: return 'Out Of Memory';
        case 28: return 'Operation Timeout';
        case 30: return 'FTP Port Failed';
        case 31: return 'FTP Could Not Use REST';
        case 33: return 'Range Error';
        case 34: return 'HTTP POST Error';
        case 35: return 'SSL Connect Error';
        case 36: return 'Bad Download Resume';
        case 37: return 'Could Not Read FILE://';
        case 38: return 'LDAP Can Not Bind';
        case 39: return 'LDAP Search Failed';
        case 41: return 'Function Not Found';
        case 42: return 'Aborted By Callback';
        case 43: return 'Bad Function Argument';
        case 45: return 'Interface Failed';
        case 47: return 'Too Many Redirects';
        case 48: return 'Unknown Option';
        case 49: return 'Telnet Option Syntax';
        case 52: return 'Got Nothing';
        case 53: return 'SSL Engine Not Found';
        case 54: return 'SSL Engine Set Failed';
        case 55: return 'Send Error';
        case 56: return 'RECV Error';
        case 58: return 'SSL Cert Problem';
        case 59: return 'SSL Cipher';
        case 60: return 'Peer Failed Verification';
        case 61: return 'Bad Content Encoding';
        case 62: return 'LDAP Invalid Url';
        case 63: return 'Filesize Exceeded';
        case 64: return 'Use SSL Failed';
        case 65: return 'Send Fail Rewind';
        case 66: return 'SSL Engine Init Failed';
        case 67: return 'Login Denied';
        case 68: return 'TFTP Not Found';
        case 69: return 'TFTP Permission Problem';
        case 70: return 'Remote Disk Full';
        case 71: return 'TFTP Illegal Operation';
        case 72: return 'TFTP Unknown Id';
        case 73: return 'Remote File Exists';
        case 74: return 'TFTP No Such User';
        case 75: return 'CONV Failed';
        case 76: return 'CONV Required';
        case 77: return 'SSL Bad CACERT File';
        case 78: return 'Remote File Not Found';
        case 79: return 'SSH Error';
        case 80: return 'SSL Shutdown Failed';
        case 81: return 'Again Socket Not Ready';
        case 82: return 'SSL Bad CRL File';
        case 83: return 'SSL Issuer Error';
        case 84: return 'FTP PRET Failed';
        case 85: return 'RTSP CSEQ Error';
        case 86: return 'RTSP Session Error';
        case 87: return 'FTP Bad File List';
        case 88: return 'Chunk Failed';
        case 89: return 'No Connection Available';
        case 90: return 'SSL Pinned Pub Key No Match';
        case 91: return 'SSL Invalid Cert Status';
        case 92: return 'HTTP2 Stream Error';
        case 93: return 'Recursive API Call';
        case 94: return 'Auth Error';
        case 95: return 'HTTP3 Error';
        case 96: return 'QUIC Connect Error';
        default:  return 'Unknown CURL status code';
    }
}
?>