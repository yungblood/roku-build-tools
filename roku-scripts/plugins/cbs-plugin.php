<?php
function customConfig() {
    global $E;
    pl("*** Setting config options ***");
    $proxyFiles = [
        "/components/shared/proxy",
        "/components/services/dw",
        "/components/services/innovid",
        "/components/services/adobe/adbmobile",
        "/components/services/comscore/ComScore",
        "/components/services/conviva/Conviva_Roku",
        "/components/services/conviva/ConvivaCoreLib"
    ];
    $manifest_options = [
        "CONFIG_FILE"=>"config_file",
        "CHANNEL_TOKEN"=>"channel_token",
        "SPLASH_SCREEN_FHD"=>"splash_screen_fhd",
        "SPLASH_SCREEN_HD"=>"splash_screen_hd",
        "SPLASH_COLOR"=>"splash_color",
        "ICON_FHD"=>"mm_icon_focus_fhd",
        "ICON_HD"=>"mm_icon_focus_hd",
        "TITLE"=>"title",
        "DIAL_TITLE"=>"dial_title",
    ];
    $ADBMobile_options = [
        "ANALYTICS_SSL"=>"analytics/ssl",
        "ANALYTICS_RSIDS"=>"analytics/rsids",
        "ANALYTICS_SERVER"=>"analytics/server",
        "MEDIAHEARTBEAT_SSL"=>"mediaHeartbeat/ssl",
    ];
    if(!empty($E["ENABLE_PROXY"])) {
        if($E["ENABLE_PROXY"] == "true") {
            $E["BS_CONST"] = "enableProxy=true";
            foreach ($proxyFiles as $proxyFile) {
                swapFiles($proxyFile, ".brs.proxy", ".brs", ".brs.orig");
            }
        } else {
            $E["BS_CONST"] = "enableProxy=false";
            foreach ($proxyFiles as $proxyFile) {
                swapFiles($proxyFile, ".brs.orig", ".brs", ".brs.proxy");
            }
        }
        $manifest_options["BS_CONST"]="bs_const";
    }
    foreach($manifest_options as $opt=>$key) {
        $val = getenv($opt);
        if(!empty($val)) $E[$opt] = $val;
        if(!empty($E[$opt])) {
            setIniVal("manifest", $key, $E[$opt]);
            pl("> manifest > $key, $E[$opt]");
        }
    }
    foreach($ADBMobile_options as $opt=>$key) {
        $val = getenv($opt);
        if(!empty($val)) $E[$opt] = $val;
        if(!empty($E[$opt])) {
            setJsonVal("ADBMobileConfig.json", $key, $E[$opt]);
            pl("> ADBMobileConfig.json > $key, $E[$opt]");
        }
    }
}
?>