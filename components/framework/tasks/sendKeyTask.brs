sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    sendKey(m.top.key)
    m.top.sent = true
end sub
