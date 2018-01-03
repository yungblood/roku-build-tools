sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    config = m.global.config
    
    stream = invalid

    schedule = syncbak().getSchedule(m.top.station.scheduleUrl)
    m.top.schedule = schedule

    if m.top.station.subtype() = "LiveTVChannel" then
        stream = createObject("roSGNode", "LiveTVStream")
        stream.streamFormat = "hls"
        stream.switchingStrategy = "full-adaptation"
        stream.live = true
        stream.playStart = createObject("roDateTime").asSeconds() + 999999
        stream.subtitleConfig = { trackName: "eia608/1" }
        stream.title = m.top.station.title
        stream.url = m.top.station.streamUrl
    else
        syncbak().initialize(config.syncbakKey, config.syncbakSecret, config.syncbakBaseUrl)
        stream = syncbak().getStream(m.top.station.id, m.top.station.mediaID)
    end if
    m.top.stream = stream
end sub
