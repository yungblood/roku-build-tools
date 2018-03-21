Library "Roku_Ads.brs"

sub init()
    m.top.functionName = "doWork"
    m.debug = true
end sub

sub doWork()
    port = createObject("roMessagePort")
    m.top.observeField("control", port)

    config = m.global.config
    video = m.top.video
    view = video.getParent()
    content = m.top.content
    
    video.observeFieldScoped("position", port)
    video.observeFieldScoped("state", port)

    raf = Roku_Ads() 'RAF initialize
    print "Roku_Ads library version: " + raf.getLibVersion()

    raf.setDebugOutput(m.debug)

    'RAF content params
    raf.setContentID(content.id)
    raf.SetContentGenre("General Variety")
    
    'Nielsen content params
    raf.enableNielsenDAR(true)
    raf.setContentLength(content.length)
    raf.setNielsenGenre(content.nielsenGenre)
    raf.setNielsenAppID(config.nielsenAppID)

    'Indicates whether the default Roku backfill ad service URL 
    'should be used in case the client-configured URL fails
    'to return any renderable ads.
    raf.setAdPrefs(false)
    raf.setAdUrl(content.vmapUrl) 

    raf.setTrackingCallback(rafAdCallback, m.top)

    playContent = true
    postroll = false
    adPods = invalid

    'Returns available ad pod(s) scheduled for rendering or invalid, if none are available.
    adPods = raf.getAds()
    if not m.top.skipPreroll and adPods <> invalid and adPods.count() > 0 then
        m.top.adPodReady = true
        playContent = raf.showAds(adPods, invalid, view)
    end if
    if playContent then
        m.top.adPodComplete = true
        while true
            msg = wait(0, port)
            msgType = type(msg)
            if msgType = "roSGNodeEvent" then
                if msg.getField() = "control" then
                    if msg.getData() = "stop" then
                        exit while
                    end if
                else if msg.getField() = "position" then
                    position = msg.getData()
                    adPods = raf.getAds(msg)
                    if adPods <> invalid and adPods.count() > 0 then
                        m.top.adPodReady = true
                    end if
                else if msg.getField() = "state" then
                    state = msg.getData()
                    if state = "stopped" then
                        if adPods = invalid or adPods.count() = 0 then
                            exit while
                        end if
                        if not raf.showAds(adPods, invalid, view) then
                            m.top.adPodComplete = true
                            exit while
                        else
                            m.top.adPodComplete = true
                            if postroll then
                                exit while
                            end if
                        end if
                    else if state = "finished" then
                        adPods = raf.getAds(msg)
                        if m.top.skipPostroll or adPods = invalid or adPods.count() = 0 then
                            exit while
                        end if
                        postroll = true
                        m.top.adPodReady = true
                    end if
                end if
            end if
        end while
    else
        m.top.adClose = {}
    end if
end sub

sub rafAdCallback(top = invalid as dynamic, eventType = invalid as dynamic, context = invalid as dynamic)
    ?"rafAdCallback: ";eventType,context
    eventData = getAdEventData(context, eventType)
    if eventData <> invalid then
        if eventData.eventType = "start" then
            top.adStart = eventData
        else if eventData.eventType = "firstquartile" then
            top.adFirstQuartile = eventData
        else if eventData.eventType = "midpoint" then
            top.adMidpoint = eventData
        else if eventData.eventType = "thirdquartile" then
            top.adThirdQuartile = eventData
        else if eventData.eventType = "complete" then
            top.adPlaybackTime = top.adPlaybackTime + eventData.ad.duration
            top.adComplete = eventData
        else if eventData.eventType = "close" then
            top.adClose = eventData
        else if eventData.eventType = "" then
            if eventData.position > 0 then
                top.adPosition = eventData
            end if
        end if
    end if
end sub

function getAdEventData(context as object, eventType = invalid as dynamic) as object
    if not isAssociativeArray(context) or not isAssociativeArray(context.ad) then
        return invalid
    end if
    eventData = {
        eventType:  lCase(asString(eventType))
        podIndex:   asInteger(0) 'TODO: replace once podIndex is available
        adIndex:    asInteger(context.adIndex)
        position:   asInteger(context.time)
    }
    ad = context.ad
    ' make it compatible with DW analytics naming
    ad.length = asInteger(ad.duration)
    ad.title = asString(ad.adTitle)
    eventData.ad = ad
    return eventData
end function
