sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.top)

    episode = api.getDynamicPlayEpisode(m.top.showID)
    m.top.episode = episode
end sub
