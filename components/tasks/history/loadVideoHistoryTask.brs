sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.top)
    
    m.top.history = api.getVideoHistory(1, 50)
end sub
