sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.global.config, m.global.user, m.global.cookies)

    episode = api.getDynamicPlayEpisode(m.top.show, m.global.user.videoHistory)
    m.top.episode = episode
end sub
