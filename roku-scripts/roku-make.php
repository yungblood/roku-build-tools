#!/usr/bin/php
<?php 
#########################################################################
# build script for ALL Roku applications
#
# Important Notes: 
# To use the "install" and "remove" targets to install your
# application directly from the shell, you must do the following:
#
# 1) Make sure that you have the curl command line executable in your path
# 2) Set the variable ROKU_DEV in your environment to the IP 
#    address of your Roku box. (e.g. export ROKU_DEV=192.168.1.1.
#    Set in your this variable in your shell startup (e.g. .bashrc)
##########################################################################
$baseScript = basename(__FILE__);
$includeScripts = scandir(__DIR__);
$includePlugins = scandir(__DIR__."/plugins");

$E = array();
$env_vars = ["APPNAME","ROKU_DEV","ROKU_PASS","HOME","COMMENT"];
$longOptions  = [];
$shortOptions = [];
$completeMsgs = [];

foreach ($includeScripts as $includeScript) {
    if(strtolower(substr($includeScript, -4)) == ".php") {
        if($includeScript <> $baseScript) {
            include __DIR__ ."/". $includeScript;
        }
    }
}
foreach ($includePlugins as $includePlugin) {
    if(strtolower(substr($includePlugin, -4)) == ".php") {
        include __DIR__ ."/plugins/". $includePlugin;
    }
}

foreach ($env_vars as $var) $E[$var] = getenv($var);

$commands = [];
$longOptions = ["help","showvars"];
$shortOptions = ["?" => "help", "V" => "showvars"];

for ($v = 1; $v < $argc; $v++) {
    if(strpos($argv[$v], '=') !== false) {
        $override = explode('=',$argv[$v]);
        $E[$override[0]] = $override[1];
    } else if(substr($argv[$v], 0, 2) == '--') {
        $option = substr($argv[$v], 2);
        if(in_array($option, $longOptions)) {
            $commands[] = $option;
        } else {
            pl("Unknown option: --".$option);
            help();
        }
    } else if(substr($argv[$v], 0, 1) == '-') {
        $option = substr($argv[$v], 1);
        $shorts = array_keys($shortOptions);
        if(in_array($option, $shorts)) {
            $commands[] = $shortOptions[$option];
        } else {
            pl("Unknown option: -".$option);
            help();
        }
    } else {
        if(!function_exists($argv[$v])) {
            pl("Unknown command: ".$argv[$v]);
            help();
        }
        $commands[] = $argv[$v];
    }
}

$E['TOOLDIR'] = dirname(__DIR__);
$E['MINI_PKG_ZIP'] = "$E[TOOLDIR]/keys/mini-pkg.zip";

$E['OS'] = strtolower(php_uname('s')); 
if(strpos($E['OS'],"windows") !== false) {
    $E['ZIPCMD'] = "$E[TOOLDIR]/win/zip.exe";
    $E['CURLCMD'] = "$E[TOOLDIR]/win/curl.exe";
} else {
    $E['ZIPCMD'] = "zip";
    $E['CURLCMD'] = "curl";
}

$E['ORGDIR'] = dirname(getcwd());
$E['DISTDIR'] = "$E[ORGDIR]/dist";
$E['COMMONDIR'] = "$E[ORGDIR]/common";

$E['ZIPDIR'] = "$E[DISTDIR]/apps";
$E['PKGDIR'] = "$E[DISTDIR]/packages";
$E['KEYDIR'] = "$E[DISTDIR]/keys";

$E['SOURCEDIR'] = getcwd();
if(empty($E['APPNAME'])) $E['APPNAME'] = str_replace(" ", "", getValueFromFile("manifest", 'title', '='));
if(empty($E['APPNAME'])) $E['APPNAME'] = basename($E['SOURCEDIR']);
$E['APPSOURCEDIR'] = "$E[SOURCEDIR]/source";
$E['APPCOMPDIR'] = "$E[SOURCEDIR]/components";

$E['CONSOLE_LOG'] = "$E[HOME]/console.log";

if(!empty($E['ROKU_PASS'])) $E['USERPASS'] = "rokudev:$E[ROKU_PASS]";
else $E['USERPASS'] = "rokudev";

if(empty($E['ZIP_EXCLUDE'])) $E['ZIP_EXCLUDE'] = "-x \*.pkg -x exclude\* -x \.* -x \*/.\* -x /.git\* -x /.history\* -x \*~ -x Makefile -x Jenkinsfile";

if(empty($E['ROKU_CHAN'])) $E['ROKU_CHAN'] = "dev";
if(empty($E['ROKU_DEV'])) $E['ROKU_DEV'] = "10.16.181.8";

$E['PKG_TIME'] = time();
$E['DATE'] = date("Ymd");
$E['TIME'] = date("mdHi");

if(count($commands) == 0) help();
updateEnv();
$console = consoleCreate();

foreach ($commands as $command) {	
	call_user_func($command);
}
finish("*** roku-make $command $E[APPFULLNAME] complete ***\n".implode("\n", $completeMsgs)."\n");

function help() {
    global $argv;
    pl("Usage: roku-make [COMMAND] [VAR=VALUE]...");
    pl("Build Simple PHP script for packaging Roku SDK Applications.");
    pl("Common usage:");
    pl("> roku-make build");
    pl("> roku-make install");
    pl("> roku-make package");
    pl("> roku-make remove");
    pl("> roku-make run_ecp_test ROKU_TEST=sample-test");
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

function showvars() {
    global $E;
    $keys = array_keys($E);
    sort($keys);
    foreach($keys as $idx=>$key) {
        pl("$key => $E[$key]");
    }
}

function updateEnv($runCustomConfig = false) {
    global $E;
    $E['V1'] = getValueFromFile("manifest", "major_version", "=");
    $E['V2'] = getValueFromFile("manifest", "minor_version", "=");
    $E['V3'] = getValueFromFile("manifest", "build_version", "=");
    $comment = getValueFromFile("manifest", "build_comment", "=");
    if(!empty($comment)) $E['COMMENT'] = $comment;
    $E['VERSION'] = "$E[V1].$E[V2].$E[V3]";
    $E['APPFULLNAME'] = "$E[APPNAME].$E[VERSION].$E[TIME]";
    if(!empty($E['BUILD_TYPE'])) $E['APPFULLNAME'] .= ".$E[BUILD_TYPE]";
    if(!empty($E['COMMENT'])) $E['APPFULLNAME'] .= ".$E[COMMENT]";
    if(!empty($E['ROKU_GEO'])) $E['APPFULLNAME'] .= ".$E[ROKU_GEO]";
    if(!empty($E['BUILD_ENV'])) $E['APPFULLNAME'] .= ".$E[BUILD_ENV]";
    $E['PKG_KEY_FILE'] = "$E[KEYDIR]/$E[APPNAME].pkg";
    if(!empty($E['ROKU_GEO']) &&  !empty($E['BUILD_ENV'])) {
        $E['PKG_KEY_FILE'] = "$E[KEYDIR]/$E[ROKU_GEO]-$E[BUILD_ENV]-$E[APPNAME].pkg";
    }
    $E['PKG_KEY'] = getValueFromFile(substr($E['PKG_KEY_FILE'], 0, -3)."key", "Password", ":");
    if($runCustomConfig) {
        if(function_exists("customConfig")) {
            customConfig();
        }
    }
}

function swapFiles($base, $from, $active, $to) {
    global $E;
    if(file_exists($E["SOURCEDIR"].$base.$from)) {
        pl("> Swapping Files: $base$from to $base$active");
        if(is_file($E["SOURCEDIR"].$base.$active)) {
            if(!is_file($E["SOURCEDIR"].$base.$to)) {
                rename($E["SOURCEDIR"].$base.$active, $E["SOURCEDIR"].$base.$to);
            }
        }
        if(is_file($E["SOURCEDIR"].$base.$active)) {
            rename($E["SOURCEDIR"].$base.$active);
        }
        rename($E["SOURCEDIR"].$base.$from, $E["SOURCEDIR"].$base.$active);
    }
}

function setbuild() {
    global $E;
    pl("*** Setting Build Number ***");
    setIniVal("manifest", "build_version", $E['DATE']);
    updateEnv();
	finish("*** Version $E[VERSION] ***");
}

function incbuild() {
    global $E;
    pl("*** Incrementing Build Number ***");
    $E['V3'] = getIniVal("manifest", "build_version") + 1;
    setIniVal("manifest", "build_version", $E['V3']);
    updateEnv();
    finish("*** Version $E[VERSION] ***");
}

function incminor() {
    global $E;
    pl("*** Incrementing Minor Version ***");
    $E['V2'] = getIniVal("manifest", "minor_version") + 1;
    setIniVal("manifest", "minor_version", $E['V2']);
    updateEnv();
    finish("*** Version $E[VERSION] ***");
}

function incmajor() {
    global $E;
    pl("*** Incrementing Major Version ***");
    $E['V1'] = getIniVal("manifest", "major_version") + 1;
    $E['V2'] = 0;
    setIniVal("manifest", "major_version", $E['V1']);
    setIniVal("manifest", "minor_version", $E['V2']);
    updateEnv();
    finish("*** Version $E[VERSION] ***");
}

function info() {
    phpinfo();
}
?>