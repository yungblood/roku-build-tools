sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    config = getGlobalField("config")
    api = cbs()
    api.initialize(m.top)
    
    if m.top.refreshParentalControls then
        ' We're refreshing the user to capture any parental control changes
        user = getGlobalField("user")
        refreshedUser = api.getUser()
        if refreshedUser <> invalid then
            ' We reset the json directly to avoid user observer callbacks
            user.json = refreshedUser.json
        end if
    end if

'   TODO: 
'    if api.isOverStreamLimit() then
'        m.top.error = "CONCURRENT_STREAM_LIMIT"
'        m.top.stream = invalid
'        return
'    end if
    
    stream = invalid
    station = m.top.station
    if station.subtype() = "LiveTVChannel" then
        streamUrl = station.streamUrl
        if isNullOrEmpty(streamUrl) then
            if not isNullOrEmpty(station.contentID) then
                ' We have a content ID, so we need to retrieve the stream url from the API
                feed = api.getEpisode(station.contentID, false)
                if feed <> invalid and not isNullOrEmpty(feed.liveStreamingUrl) then
                    streamUrl = feed.liveStreamingUrl
                end if
            end if
        end if
        if not isNullOrEmpty(streamUrl) then
            stream = createObject("roSGNode", "LiveTVStream")
            stream.streamFormat = "hls"
            stream.switchingStrategy = "full-adaptation"
            stream.url = streamUrl
            stream.live = true
            stream.playStart = createObject("roDateTime").asSeconds() + 999999
            stream.subtitleConfig = { trackName: "eia608/1" }
            stream.title = station.title
        end if
    else if station.subtype() = "LiveFeed" then
        api.populateStream(station)
        stream = station.videoStream
    else
        syncbak().initialize(config.syncbakKey, config.syncbakSecret, config.syncbakBaseUrl)
        syncbak().setLocation(getGlobalField("localStationLatitude"), getGlobalField("localStationLongitude"))
        stream = syncbak().getStream(station.id, station.mediaID)
    end if
    m.top.stream = stream
end sub
