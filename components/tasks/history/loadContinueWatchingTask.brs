sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.top)
    
    m.top.episodes = api.getContinueWatching(1, 50)
end sub
