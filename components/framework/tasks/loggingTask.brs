sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    setLogLevel(99, m.top.remoteLoggingUrl)
    m.port = createObject("roMessagePort")
    m.top.observeField("logLevel", m.port)
    m.top.observeField("remoteLoggingUrl", m.port)
    m.top.observeField("details", m.port)
    while true
        msg = wait(0, m.port)
        if msg <> invalid then
            if type(msg) = "roSGNodeEvent" then
                if msg.getField() = "details" then
                    debugPrint(msg.getData(), "Logging", 0)
                else if msg.getField() = "control" then
                    if m.top.control = "stop" then
                        exit while
                    end if
                end if
            end if
        end if
    end while
end sub
