sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    config = getGlobalField("config")
    api = cbs()
    api.initialize(m.top)
    
    m.top.canOverride = (api.getLiveTVOverrideCount().overLimit = false)

    stations = []
    if asBoolean(config.syncbak_enabled, true) then
        syncbak().initialize(config.syncbakKey, config.syncbakSecret, config.syncbakBaseUrl)
        stations = syncbak().getChannels()
    else
        nationalFeedID = config.live_tv_national_feed_content_id
        if not isNullOrEmpty(nationalFeedID) then
            nationalFeed = api.getEpisode(nationalFeedID)
            if nationalFeed <> invalid then
                stations.push(nationalFeed)
            end if
        end if
    end if

    if m.top.loadChannels then
        liveTVChannels = api.getLiveChannels()
        if config.liveTVChannels <> invalid then
            for each channel in liveTVChannels
                for each override in config.liveTVChannels
                    if override.id = channel.scheduleType or (override.id = "local" and channel.type = "syncbak") then
                        for each field in override.keys()
                            if field <> "id" then
                                channel.setField(field, override[field])
                            end if
                        next
                        exit for
                    end if
                next
            next
        end if
        channels = createObject("roSGNode", "ContentNode")
        channels.appendChildren(liveTVChannels)
        m.top.liveTVChannels = channels
    end if
    
    m.top.stations = stations
end sub
