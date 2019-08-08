sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.top)
    
    m.top.canOverride = (api.getLiveTVOverrideCount().overLimit = false)

    if m.top.loadChannels then
        m.top.liveTVChannels = loadLiveChannels(api)
    end if
    m.top.stations = loadLocalLiveStations(api)
end sub
