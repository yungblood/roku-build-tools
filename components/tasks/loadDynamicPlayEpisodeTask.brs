sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.top)

    user = getGlobalField("user")
    episode = api.getDynamicPlayEpisode(m.top.show, user.videoHistory)
    m.top.episode = episode
end sub
