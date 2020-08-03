<?php
function all() {
    global $E;
    $processUser = posix_getpwuid(posix_geteuid());
    if($processUser['name'] == 'jenkins') {
        if(!is_file("Jenkinsfile")) finish("Unable to find: Jenkinsfile", -1);
    }
    remove();
    //setbuild(); //Removed auto build number, now it requires you to manually set the build number in the manifest file.
    install();
    squashfs();
    rekey();
    package();
}

function zip() {
    global $E;
    updateEnv();
    setConfig();
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
    global $E, $timeout, $testOk, $console;
    zip();
    home();
    pl("Installing $E[APPFULLNAME] on host $E[ROKU_DEV]");

    $data = [];
    $data['mysubmit'] = 'Install';
//    $data['archive']  = curl_file_create("$E[ZIPDIR]/$E[APPFULLNAME].zip");
    $data['archive']  = new CURLFile(realpath("$E[ZIPDIR]/$E[APPFULLNAME].zip"));
    $data['passwd']   = "";

    $response = curl_post("http://$E[ROKU_DEV]/plugin_install", $data, $E['USERPASS']);
    if(explode(' ', $response)[1] == "Error") {
        finish("Install: $response", false, -1);
    } else if(isset($console)) {
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

function cramfs() {
    global $E, $timeout, $testOk;
    pl("Convert to CramFS on host $E[ROKU_DEV]");
    $data = [
        'mysubmit'=>'Convert to cramfs',
        'archive'=>curl_file_create("$E[ZIPDIR]/$E[APPFULLNAME].zip"),
        'passwd'=>""
    ];
    $response = curl_post("http://$E[ROKU_DEV]/plugin_install", $data, $E['USERPASS']);
    $output = filterString($response, "Roku.Message", "n.innerHTML='", "<p>");
    finish("CramFS: $output", checkSuccess($output, "succeeded"));
}

function squashfs() {
    global $E, $timeout, $testOk;
    pl("Convert to SquashFS on host $E[ROKU_DEV]");
    $data = [
        'mysubmit'=>'Convert to squashfs',
        'archive'=>curl_file_create("$E[ZIPDIR]/$E[APPFULLNAME].zip"),
        'passwd'=>""
    ];
    $response = curl_post("http://$E[ROKU_DEV]/plugin_install", $data, $E['USERPASS']);
    $output = filterString($response, "Roku.Message", "n.innerHTML='", "<p>");
    finish("SquashFS: $output", checkSuccess($output, "succeeded"));
}

function pkg() {
    package();
}

function package() {
    global $E;
    
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
        curl_binary("http://$E[ROKU_DEV]/pkgs/$pkg", "$E[PKGDIR]/$E[APPFULLNAME].pkg", $E['USERPASS']);
        if(!is_file($E['PKG_KEY_FILE'])) {
            copy("$E[PKGDIR]/$E[APPFULLNAME].pkg", "$E[PKG_KEY_FILE]");
        }
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