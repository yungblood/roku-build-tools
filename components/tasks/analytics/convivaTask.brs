sub init()
    m.top.functionName = "doWork"
    m.debug = false
    m.id = rnd(1000000).toStr()
end sub

sub doWork()
    port = createObject("roMessagePort")
    m.top.observeField("control", port)
    m.top.observeField("cancel", port)
    m.top.observeField("adStart", port)
    m.top.observeField("adEnd", port)
    
    m.inAd = false

    config = getGlobalField("config")
    user = getGlobalField("user")
    video = m.top.video
    content = m.top.content

    lastCdnReportTime = 0
    cdnReportInterval = 60

    convivaTags = {}
    contentInfo = {}
    convivaTags["accessType"]       = user.trackingStatus
    convivaTags["connectionType"]   = iif(getEthernetInterface() = "eth0", "ethernet", "wifi")
    convivaTags["Partner_ID"]       = "cbs_roku_app"
    convivaTags["Player_Version"]   = getAppVersion()
    if content.subtype() = "Station" or content.isLive then
        convivaTags["contentId"]    = content.mediaID
        convivaTags["contentType"]  = "Live"
        convivaTags["isAd"]         = "false"
        convivaTags["episodeTitle"] = content.convivaTrackingTitle
        convivaTags["drm"]          = "false"
        convivaTags["drmType"]      = "none"
        convivaTags["app"]          = "Roku"
        convivaTags["appVersion"]   = config.appName + " " + config.appVersion
        convivaTags["appRegion"]    = config.appRegion
        convivaTags["winDimension"] = config.screenDims

        contentInfo = convivaContentInfo(content.convivaTrackingTitle, convivaTags)
        contentInfo["isLive"]       = true
        contentInfo["contentLength"] = 0
        contentInfo["streamUrl"]    = video.content.url
        contentInfo["streamFormat"] = video.content.streamFormat
    else
        convivaTags["contentId"]    = content.id
        convivaTags["contentType"]  = "VOD"
        convivaTags["isAd"]         = "false"
        convivaTags["isEpisode"]    = iif(content.isFullEpisode , "true", "false")
        convivaTags["seriesTitle"]  = content.showName
        convivaTags["showId"]       = content.showID
        convivaTags["episodeTitle"] = content.title
        convivaTags["drm"]          = iif(content.isProtected , "true", "false")
        convivaTags["drmType"]      = iif(content.isProtected , "PlayReady", "none")
        convivaTags["app"]          = config.appName
        convivaTags["appVersion"]   = config.appName + " " + config.appVersion
        convivaTags["appRegion"]    = config.appRegion
        convivaTags["winDimension"] = config.screenDims
    
        contentInfo = convivaContentInfo(content.convivaTrackingTitle, convivaTags)
        contentInfo["isLive"]       = false
        contentInfo["contentLength"] = content.length
        contentInfo["streamUrl"]    = content.videoStream.url
        contentInfo["streamFormat"] = content.videoStream.streamFormat
    end if
    contentInfo["playerName"]       = "ROKU"
    contentInfo["viewerId"]         = user.id

    settings = {}
    if not isNullOrEmpty(config.convivaGateway) then
        settings.gatewayUrl = config.convivaGateway
    end if
    
    livePass = convivaLivePassInitWithSettings(config.convivaKey, settings)
    livePass.toggleTraces(m.debug)
    
    video.observeField("streamInfo", port)
    video.observeField("position", port)
    video.observeField("state", port)
    video.observeField("duration", port)
    video.observeField("streamingSegment", port)
    video.observeField("errorCode", port)
    video.observeField("errorMsg", port)
    video.observeField("downloadedSegment", port)
    video.observeField("content", port)
    
    convivaSession = livePass.createSession(true, contentInfo, video.notificationInterval, video, port)
    livePass.attachStreamer()
    while true
        msg = convivaWait(0, port, invalid)
        msgType = type(msg)
        if msgType = "roSGNodeEvent"
            if msg.getField() = "control" then
                if m.debug
                    print "msgType=";msgType,"getField=";msg.getField(),"data=";msg.getData()
                end if
                if msg.getData() = "stop" then
                    exit while
                end if
            else if msg.getField() = "cancel" then
                if m.debug
                    print "convivaTask cancelled", m.id
                end if
                exit while
            else if msg.getField() = "adStart" then
                if not m.inAd then
                    m.inAd = true
                    livePass.detachStreamer()
                    livePass.adStart()
                end if
            else if msg.getField() = "adEnd" then
                if m.inAd then
                    livePass.adEnd()
                    livePass.attachStreamer()
                    m.inAd = false
                end if
            else if msg.getField() = "position" then
            else if msg.getField() = "downloadedSegment" then
                now = createObject("roDateTime").asSeconds()
                if now - lastCdnReportTime >= cdnReportInterval then
                    segmentInfo = msg.getData()
                    headers = getUrlHeaders(segmentInfo.segUrl)
                    if headers <> invalid then
                        cdn = headers["x-cdn"]
                        if not isNullOrEmpty(cdn) then
                            ?"UPDATING CDN: ";cdn
                            newContentInfo = {}
                            newContentInfo.append(contentInfo)
                            newContentInfo["defaultReportingCdnName"] = cdn
                            newContentInfo["defaultReportingResource"] = cdn
                            livePass.updateContentMetadata(convivaSession, newContentInfo)
                            lastCdnReportTime = now
                            contentInfo = newContentInfo
                        end if
                    end if
                end if
            else if msg.getField() = "content" then
                videoContent = msg.getData()
                if videoContent <> invalid and videoContent.streamDetails <> invalid then
                    newContentInfo = {}
                    newContentInfo.append(contentInfo)
                    newContentInfo.tags["stream_id"] = videoContent.streamDetails.streamID
                    livePass.updateContentMetadata(convivaSession, newContentInfo)
                    contentInfo = newContentInfo
                end if  
            else if msg.getField() = "state" then
                if m.debug then
                    print "msgType=";msgType,"getField=";msg.getField(),"data=";msg.getData()
                end if
                curState = msg.getData()
                if curState = "stopped" and not m.inAd then
                    if convivaSession <> invalid then
                        if m.debug
                            print "play back stopped in between"
                        end if
                        livePass.cleanupSession(convivaSession)
                        convivaSession = invalid
                    end if
                    exit while
                else if curState = "error" then
                    livePass.detachStreamer()
                    livePass.reportError(convivaSession, video.errorMsg)
                    exit while
                else if curState = "finished" then
                    if m.debug
                        print "raftask-video finished, try postroll"
                    end if
                    ' Session will be cleaned only on stopped during exit of playback
                end if
            end if
        end if
    end while
    if convivaSession <> invalid then
        livePass.cleanupSession(convivaSession)
        convivaSession = invalid
    end if
    livePass.cleanup()
    video = invalid
    m.top.video = invalid
    if m.debug then
        print "raftask - exiting client-stitched loop",m.id
    end if
end sub
