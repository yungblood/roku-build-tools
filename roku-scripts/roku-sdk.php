<?php
function all() {
    remove();
    rekey();
    //setbuild(); //Removed auto build number, now it requires you to manually set the build number in the manifest file.
    package();
}

function zip() {
    global $E;
    updateEnv();
    setconfig();
    if(!is_dir($E['ZIPDIR'])) {
	    pl("  >> creating destination directory $E[ZIPDIR]");
	    mkdir($E['ZIPDIR'], 0755, true);
	}
	if(!is_writable($E['ZIPDIR'])) {
        pl("  >> setting directory permissions for $E[ZIPDIR]");
        chmod($E['ZIPDIR'], 0755);
	}
	if(is_dir($E['COMMONDIR'])) {
        pl("  >> copying imports");
        $E["IMPORTFILES"] = shell_exec("cp -rf --preserve=ownership,timestamps --no-preserve=mode -v $E[COMMONDIR]/* .");
        echo $E["IMPORTFILES"];
	}

# zip .png files without compression
    $E['ZIPFILE'] = "$E[ZIPDIR]/$E[APPFULLNAME].zip";
	pl("  >> creating application zip $E[APPFULLNAME]");	
    echo shell_exec("zip -0 -r \"$E[ZIPFILE]\" . -i \*.png $E[ZIP_EXCLUDE]");
    echo shell_exec("zip -9 -r \"$E[ZIPFILE]\" . -x \*.png $E[ZIP_EXCLUDE]");

    if(!empty($E["IMPORTFILES"])) {
        pl("  >> deleting imports");
        echo shell_exec("rm -rf $E[APPSOURCEDIR]/common");
        echo shell_exec("rm -rf $E[APPCOMPDIR]/common");
    }

	finish("Zipping $E[APPFULLNAME]");
}

function install() {
    global $E, $timeout, $testOk;
    zip();
    pl("Installing $E[APPFULLNAME] on host $E[ROKU_DEV]");
    home();
    if(function_exists("consoleCreate")) $console = consoleCreate();
    $data = [
        'mysubmit'=>'Install',
        'archive'=>curl_file_create("$E[ZIPDIR]/$E[APPFULLNAME].zip"),
        'passwd'=>""
    ];
    $response = curl_post("http://$E[ROKU_DEV]/plugin_install", $data, $E['USERPASS']);
    if(isset($console)) {
        $timeout = 10;
    
        $script = [
            [ 'expect' => '------ Compiling dev', 'action' => 'none',       'parms' => [] ],
            [ 'expect' => '---',                  'action' => 'testString', 'parms' => ['AppCompileComplete'] ]
        ];
    
        consoleScript($console, $script);
        $output = file_get_contents(".roku-make.out");
        finish("Install: $output", checkSuccess($output, "Passed"));
    } else {
        $output = filterString($response, "Roku.Message", "trigger('Set message content', '", "').trigger('Render', node);");
        finish("Install: $output", checkSuccess($output, "Received"));
    }
}

function pkg() {
    package();
}

function package() {
    global $E;
    install();
    if(!is_dir($E['PKGDIR'])) {
        pl("  >> creating destination directory $E[PKGDIR]");
        mkdir($E['PKGDIR'], 0755, true);
    }
    if(!is_writable($E['PKGDIR'])) {
        pl("  >> setting directory permissions for $E[PKGDIR]");
        chmod($E['PKGDIR'], 0755);
    }
    
	pl("Packaging $E[APPFULLNAME] on host $E[ROKU_DEV]");
	$data = [
	    'mysubmit'=>'Package',
	    'app_name'=>"$E[APPNAME]/$E[VERSION]",
	    'passwd'=>"$E[PKG_KEY]",
	    'pkg_time'=>"$E[PKG_TIME]"
	];
	$response = curl_post("http://$E[ROKU_DEV]/plugin_package", $data, $E['USERPASS']);
	$output = filterString($response, "Roku.Message", "trigger('Set message content', '", "').trigger('Render', node);");
	finish("Package: $output", checkSuccess($output));
	pl("Downloading Package...");
	$pkg = filterString($response, "a href", "pkgs//", '">', true);
	if(!empty($pkg)) {
	    curl_binary("http://$E[ROKU_DEV]/pkgs/$pkg", "$E[KEYDIR]/$E[APPNAME].pkg", $E['USERPASS']);
	    if(!empty($E['ROKU_GEO']) &&  !empty($E['BUILD_ENV'])) {
	        copy("$E[KEYDIR]/$E[APPNAME].pkg", "$E[KEYDIR]/$E[ROKU_GEO]-$E[BUILD_ENV]-$E[APPNAME].pkg");
	    }
	    copy("$E[KEYDIR]/$E[APPNAME].pkg", "$E[PKGDIR]/$E[APPFULLNAME].pkg");
	    finish("*** Package $E[APPFULLNAME] complete ***");
	} else {
	    finish("*** Package $E[APPFULLNAME] failed ***", -1);
	}
}

function remove() {
    global $E;
    pl("Removing dev app from host $E[ROKU_DEV]");
    home();
    $data = [
        'mysubmit'=>'Delete',
        'archive'=>"",
        'passwd'=>""
    ];
    $response = curl_post("http://$E[ROKU_DEV]/plugin_install", $data, $E['USERPASS']);
    $output = filterString($response, "Roku.Message", "trigger('Set message content', '", "').trigger('Render', node);");
    finish("Remove: $output");
}

?>