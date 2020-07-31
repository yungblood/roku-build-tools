#!/usr/bin/php
<?php 
$baseScript = basename(__FILE__);
$includeScripts = scandir(__DIR__);

$longOptions  = [];
$shortOptions = [];
$completeMsgs = [];

foreach ($includeScripts as $includeScript) {
	if(strtolower(substr($includeScript, -4)) == ".php") {
		if($includeScript <> $baseScript) {
			include __DIR__ ."/". $includeScript ;
		}
	}
}

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

if(count($commands) == 0) help();
updateEnv();

foreach ($commands as $command) {	
	call_user_func($command);
	$msg = "*** roku-make $command $E[APPFULLNAME] complete ***";
	foreach ($completeMsgs as $completeMsg) $msg .= call_user_func($completeMsg);
	finish($msg);
}
?>