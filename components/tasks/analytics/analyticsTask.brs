sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    'setLogLevel(6)
    config = m.global.config

    m.port = createObject("roMessagePort")
    if config.enableDW then
        m.top.observeField("dwParams", m.port)
    end if
    if config.enableSparrow then
        m.top.observeField("sparrowParams", m.port)
    end if
    m.top.observeField("omnitureParams", m.port)
    m.top.observeField("debugParams", m.port)
    m.top.observeField("control", m.port)
    m.global.observeField("user", m.port)

    user = m.global.user
    dw().setUserInfo(user.id, user.trackingStatus)
    sparrow().setUserID(user.id)
    omniture().initialize(config.omnitureSuiteID, user.id, user.trackingStatus, user.trackingProduct, config.omnitureEvar5)
    while true
        msg = wait(0, m.port)
        if msg <> invalid then
            if type(msg) = "roSGNodeEvent" then
                if msg.getField() = "dwParams" then
                    data = msg.getData()
                    trackDW(data.method, data.params)
                else if msg.getField() = "sparrowParams" then
                    data = msg.getData()
                    trackSparrow(data.method, data.params)
                else if msg.getField() = "omnitureParams" then
                    data = msg.getData()
                    trackOmniture(data.method, data.params)
                else if msg.getField() = "debugParams" then
                    data = msg.getData()
                    debugPrint(msg.getData(), "Debug", 0)
                else if msg.getField() = "control" then
                    if m.top.control = "stop" then
                        exit while
                    end if
                else if msg.getField() = "user" then
                    user = msg.getData()
                    dw().setUserInfo(user.id, user.trackingStatus)
                    sparrow().setUserID(user.id)
                    omniture().initialize(config.omnitureSuiteID, user.id, user.trackingStatus, user.trackingProduct, config.omnitureEvar5)
                end if
            end if
        end if
    end while
end sub

sub trackDW(method as string, params as object)
    class = dw()
    if params = invalid or params.count() = 0 then
        class[method]()
    else if params.count() = 1 then
        class[method](params[0])
    else if params.count() = 2 then
        class[method](params[0], params[1])
    else if params.count() = 3 then
        class[method](params[0], params[1], params[2])
    else if params.count() = 4 then
        class[method](params[0], params[1], params[2], params[3])
    else if params.count() = 5 then
        class[method](params[0], params[1], params[2], params[3], params[4])
    else if params.count() = 6 then
        class[method](params[0], params[1], params[2], params[3], params[4], params[5])
    else if params.count() = 7 then
        class[method](params[0], params[1], params[2], params[3], params[4], params[5], params[6])
    else if params.count() = 8 then
        class[method](params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7])
    else if params.count() = 9 then
        class[method](params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8])
    else if params.count() = 10 then
        class[method](params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8], params[9])
    end if
end sub

sub trackSparrow(method as string, params as object)
    class = sparrow()
    if params = invalid or params.count() = 0 then
        class[method]()
    else if params.count() = 1 then
        class[method](params[0])
    else if params.count() = 2 then
        class[method](params[0], params[1])
    else if params.count() = 3 then
        class[method](params[0], params[1], params[2])
    else if params.count() = 4 then
        class[method](params[0], params[1], params[2], params[3])
    else if params.count() = 5 then
        class[method](params[0], params[1], params[2], params[3], params[4])
    else if params.count() = 6 then
        class[method](params[0], params[1], params[2], params[3], params[4], params[5])
    else if params.count() = 7 then
        class[method](params[0], params[1], params[2], params[3], params[4], params[5], params[6])
    else if params.count() = 8 then
        class[method](params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7])
    else if params.count() = 9 then
        class[method](params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8])
    else if params.count() = 10 then
        class[method](params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8], params[9])
    end if
end sub

sub trackOmniture(method as string, params as object)
    class = omniture()
    if params = invalid or params.count() = 0 then
        class[method]()
    else if params.count() = 1 then
        class[method](params[0])
    else if params.count() = 2 then
        class[method](params[0], params[1])
    else if params.count() = 3 then
        class[method](params[0], params[1], params[2])
    else if params.count() = 4 then
        class[method](params[0], params[1], params[2], params[3])
    else if params.count() = 5 then
        class[method](params[0], params[1], params[2], params[3], params[4])
    else if params.count() = 6 then
        class[method](params[0], params[1], params[2], params[3], params[4], params[5])
    else if params.count() = 7 then
        class[method](params[0], params[1], params[2], params[3], params[4], params[5], params[6])
    else if params.count() = 8 then
        class[method](params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7])
    else if params.count() = 9 then
        class[method](params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8])
    else if params.count() = 10 then
        class[method](params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8], params[9])
    end if
end sub