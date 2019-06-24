sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.top)
    m.top.success = api.forgotPassword(m.top.email)
end sub
