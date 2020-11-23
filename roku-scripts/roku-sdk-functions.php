<?php
function all() {
    global $E;
    home();
    remove();
    //setbuild(); //Removed auto build number, now it requires you to manually set the build number in the manifest file.
    install();
    squashfs();
    rekey();
    package();
}

function zip() {
    global $E;
    updateEnv(true);
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
    echo shell_exec("$E[ZIPCMD] -0 -r \"$E[ZIPFILE]\" . -i \*.png $E[ZIP_EXCLUDE]");
    echo shell_exec("$E[ZIPCMD] -9 -r \"$E[ZIPFILE]\" . -x \*.png $E[ZIP_EXCLUDE]");

    if(!empty($E["IMPORTFILES"])) {
        pl("  >> deleting imports");
        echo shell_exec("rm -rf $E[APPSOURCEDIR]/common");
        echo shell_exec("rm -rf $E[APPCOMPDIR]/common");
    }

	finish("Zipping $E[APPFULLNAME]");
}

function install($fullpath = '') {
    global $E, $timeout, $testOk, $console;
    if ($fullpath === '') {
        zip();
        $fullpath = realpath("$E[ZIPDIR]/$E[APPFULLNAME].zip");
    }
    $response = rokuSubmit("plugin_install", 'Install', _curl_file($fullpath));
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
    global $E;
    $response = rokuSubmit("plugin_install", 'Convert to cramfs', _curl_file("$E[ZIPDIR]/$E[APPFULLNAME].zip"));
    $output = filterString($response, "Roku.Message", "n.innerHTML='", "<p>");
    finish("CramFS: $output", checkSuccess($output, "succeeded"));
}

function squashfs() {
    global $E;
    $response = rokuSubmit("plugin_install", 'Convert to squashfs',_curl_file("$E[ZIPDIR]/$E[APPFULLNAME].zip"));
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
    
    $response = rokuSubmit("plugin_package", 'Package', "" , "$E[PKG_KEY]", "$E[APPNAME]/$E[VERSION]","$E[PKG_TIME]");
    $output = filterString($response, "Roku.Message", "trigger('Set message content', '", "').trigger('Render', node);");
    finish("Package: $output", checkSuccess($output));
    pl("Downloading Package...");
    $pkg = filterString($response, "a href", "pkgs//", '">', true);
    if(!empty($pkg)) {
        _curl("http://$E[ROKU_DEV]/pkgs/$pkg", 'GET', $E['USERPASS'], '', "$E[PKGDIR]/$E[APPFULLNAME].pkg");
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
    $response = rokuSubmit("plugin_install", 'Delete');
    $output = filterString($response, "Roku.Message", "trigger('Set message content', '", "').trigger('Render', node);");
    finish("Remove: $output");
}

function rokuSubmit($url, $submit, $archive = "", $passwd = "", $app_name = "", $pkg_time = "") {
    global $E;
    $data = [];
    $data['mysubmit'] = $submit;
    $data['archive']  = $archive;
    $data['passwd']   = $passwd;
    $data['app_name'] = $app_name;
    $data['pkg_time'] = $pkg_time;
    pl("$submit $E[APPFULLNAME] on host $E[ROKU_DEV]");
    return _curl("http://$E[ROKU_DEV]/$url", 'POST', $E['USERPASS'], $data);
}
?>