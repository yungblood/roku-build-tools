sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.global.config, m.global.user, m.global.cookies)
    
    m.top.episodes = api.getContinueWatching(1, 50)
end sub
