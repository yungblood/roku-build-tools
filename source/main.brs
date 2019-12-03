sub runUserInterface(ecp as object)
    if ecp.RunTests = "true" and type(TestRunner) = "Function" then
        Runner = TestRunner()

        Runner.SetFunctions([
            TestSuite__Main
        ])

        Runner.Logger.SetVerbosity(3)
        Runner.Logger.SetEcho(false)
        Runner.Logger.SetJUnit(false)
        Runner.SetFailFast(true)
        
        Runner.Run()
        return
    end if
    m.port = createObject("roMessagePort")
    m.inputListener = createObject("roInput")
    m.inputListener.setMessagePort(m.port)

    m.screen = createObject("roSGScreen")
    m.screen.setMessagePort(m.port)
    scene = m.screen.createScene("AppScene")

    appInfo = createObject("roAppInfo")
    m.config = parseJson(readAsciiFile(appInfo.getValue("config_file")))
    if m.config = invalid then
        m.config = {}
    end if
    m.config.appVersion = appInfo.getVersion()
    
    displaySize = createObject("roDeviceInfo").getDisplaySize()
    m.config.screenDims = displaySize.w.toStr() + "x" + displaySize.h.toStr()

    m.screen.show()
    scene.observeField("close", m.port)

    models = ["2000X", "2050X", "2100X", "2400X", "2450X", "2500X", "3000X", "3050X", "3100X", "3400X", "3420X"]
    scene.setField("extremeMemoryManagement", false) 'arrayContains(models, getModel()))
    scene.setField("config", m.config)
    scene.setField("ecp", ecp)
    
    scene.callFunc("reinit", {})

    m.exitApp = false
    while true
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent" then
            if msg.isScreenClosed() then return
        else if msgType = "roSGNodeEvent" then
            if msg.getField() = "close" then
                exit while
            end if
        else if msgType = "roInputEvent" then
            scene.setField("deeplink", msg.getInfo())
        end if
    end while
end sub
