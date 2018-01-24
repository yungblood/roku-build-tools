sub runUserInterface(ecp as object)
    m.port = CreateObject("roMessagePort")
    m.screen = CreateObject("roSGScreen")
    m.screen.setMessagePort(m.port)
    scene = m.screen.CreateScene("AppScene")
    
    appInfo = createObject("roAppInfo")
    useStaging = (appInfo.GetValue("use_staging") = "true")

    m.config = invalid
    if useStaging then
        m.config = parseJson(readAsciiFile("pkg:/config-staging.json"))
    else
        m.config = parseJson(readAsciiFile("pkg:/config.json"))
    end if
    if m.config = invalid then
        m.config = {}
    end if
    m.config.appVersion = appInfo.getVersion()
    
    displaySize = createObject("roDeviceInfo").getDisplaySize()
    m.config.screenDims = displaySize.w.toStr() + "x" + displaySize.h.toStr()

    globalNode = m.screen.getGlobalNode()
    globalNode.addField("config", "assocarray", false)
    globalNode.setField("config", m.config)
    
    models = ["2000X", "2050X", "2100X", "2400X", "2450X", "2500X", "3000X", "3050X", "3100X", "3400X", "3420X"]
    globalNode.addField("extremeMemoryManagement", "boolean", false)
    globalNode.setField("extremeMemoryManagement", arrayContains(models, getModel()))
    
    m.screen.show()
    scene.ecp = ecp
    scene.observeField("close", m.port)

    m.exitApp = false
    while true
        msg = wait(1000, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent" then
            if msg.isScreenClosed() then return
        else if msgType = "roSGNodeEvent" then
            if msg.getField() = "close" then
                exit while
            end if
        end if
    end while
end sub
