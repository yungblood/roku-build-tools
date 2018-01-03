Library "Roku_Ads.brs"

sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    m.lastLoopTime = 0
    m.seekThreshold = 2
    m.cuepoints = []
    m.skippingPod = false

    loadSdk()
    if m.sdk <> invalid then
        m.port = createObject("roMessagePort")
        m.top.observeField("video", m.port)
        while true
            msg = wait(1000, m.port)
            if type(msg) = "roSGNodeEvent" and msg.getField() = "video" then
                onVideoChanged()
            else
                if not m.top.streamManagerReady then
                    loadStreamManager()
                end if
                if m.streamManager <> invalid then
                    m.streamManager.onMessage(msg)
                    if m.top.video <> invalid and m.top.streamManagerReady then
                        currentTime = m.top.video.position
                        contentTime = m.streamManager.getContentTime(currentTime * 1000) / 1000
                        m.top.contentTime = contentTime
                        if m.lastLoopTime > 0 and abs(currentTime - m.lastLoopTime) > m.seekThreshold then
                            print "Seek detected from "; m.lastLoopTime;" to ";currentTime
                            if m.top.inSnapback or m.skippingPod then
                                ' That seek was us snapping back to content
                                print "Threshold break was snapback or pod skip"
                                m.top.inSnapback = false
                                m.skippingPod = false
                            else
                                ' User seeked
                                print "Threshold break was user seek - sending to onUserSeek"
                                onUserSeek(m.lastLoopTime, currentTime)
                            end if
                        else if type(msg) = "roSGNodeEvent" and msg.getField() = "position" then
                            if not m.skippingPod and not m.top.inSnapback then
                                for i = 0 to m.cuepoints.count() - 1
                                    cuepoint = m.cuepoints[i]
                                    ' add a 2 second buffer to the end to avoid ms rounding issues
                                    if cuepoint.start <= currentTime and cuepoint.end > currentTime + 2 then
                                        m.currentCuePoint = cuepoint
                                        if cuepoint.hasPlayed and not m.top.adPlaying then
                                            ' this cuepoint has already played, so
                                            ' we should skip it
                                            print currentTime
                                            print "Seeking past credited cuepoint -";cuepoint.start;"->";cuepoint.end
                                            m.skippingPod = true
                                            m.top.video.seek = cuepoint.end + 1
                                        end if
                                        exit for
                                    end if
                                    if m.currentCuePoint <> invalid then
                                        ' We're no longer in the cuepoint, so mark
                                        ' it as played
                                        m.currentCuePoint.hasPlayed = true
                                    end if
                                    m.currentCuePoint = invalid
                                next
                            end if
                        end if
                        m.lastLoopTime = currentTime
                    end if
                end if
            end if
        end while
    else
        ' TODO: Handle an SDK load failure
    end if
end sub

sub loadSdk()
    sdk = m.sdk
    ' Only do this once per channel execution
    if sdk = invalid then
'        m.sdk = getImaSdk()
        sdkUrl = "https://imasdk.googleapis.com/roku/sdkloader/ima3.brs"
        sdkResponse = getUrlToStringEx(sdkUrl)
        if sdkResponse.responseCode = 200 then
            sdkCode = sdkResponse.response
            error = eval(sdkCode)
            if type(error) = "roList" then
                for each e in error
                    print e
                    m.top.errors.push(e)
                end for
            else if error <> &hE2 and error <> &hFC and error <> &hFF then
                ' hFC = error on normal end, hE2 = error on return value
                ' hFF = unknown error
                print("Error Evaluating SDK: " + stri(error))
                m.top.errors.push("Error Evaluating SDK: " + stri(error))
            end if
            ' This is the AA created in the remote IMA file. Here we store it while it
            ' is still in scope for this function context.
            m.sdk = imasdk
            m.top.sdkLoaded = true
        else
            print("Error downloading SDK: " + stri(code))
            m.top.errors.push("Error downloading SDK: " + stri(code))
        end if
    end if
end sub

sub loadStreamManager()
    if m.sdk <> invalid and m.top.video <> invalid and m.top.streamData <> invalid then
        ?"--- Loading Stream Manager ---"
        m.sdk.initSdk()
        setupVideoPlayer()
        request = m.sdk.createStreamRequest()
        
        streamData = m.top.streamData
        if streamData.type = "live" then
            request.assetKey = streamData.assetKey
        else
            request.contentSourceId = streamData.contentSourceId
            request.videoId = streamData.videoId
        end if
        request.apiKey = streamData.apiKey
        if streamData.attemptPreroll <> invalid then
            request.attemptPreroll = streamData.attemptPreroll
        end if
        request.player = m.player
        request.adTagParameters = streamData.adTagParameters
        request.ppid = streamData.ppid
        
        ?"Stream Data: ";streamData
        ?"DAI Request: ";request

        m.cuepoints = []
        requestResult = m.sdk.requestStream(request)
        if requestResult <> invalid then
            print "Error requesting stream ";requestResult
        else
            m.streamManager = invalid
            while m.streamManager = invalid
                sleep(50)
                m.streamManager = m.sdk.getStreamManager()
            end while
            if m.streamManager.type = "error" then
                print "DAI Error: ";m.streamManager.info
                m.top.error = m.streamManager.info
                m.streamManager = invalid
                m.top.reset = true
            else
                m.top.streamManagerReady = true
                addCallbacks()
                m.player.streamManager = m.streamManager
                m.streamManager.start()

                m.cuepoints = m.streamManager.getCuePoints()
                
                if streamData.bookmarkPosition <> invalid and streamData.bookmarkPosition > 0 then
                    ' Adjust bookmark position for stitched ads
                    streamData.bookmarkPosition = m.streamManager.getStreamTime(streamData.bookmarkPosition * 1000) / 1000
                end if
                m.lastLoopTime = 0
            end if
        end if
    end if
end sub

sub setupVideoPlayer()
    sdk = m.sdk
    m.player = m.sdk.createPlayer()
    m.player.top = m.top

    m.player.loadUrl = function(streamInfo as object)
        print "---- Load URL ---- "
        print streamInfo
        streamData = m.top.streamData
        streamData.url = streamInfo.manifest
        streamData.streamDetails = streamInfo

        if streamInfo.subtitles <> invalid then
            ?formatjson(streamInfo.subtitles)
            for each subtitle in streamInfo.subtitles
                if lCase(subtitle.language) = "en" and subtitle.ttml <> invalid then
                    streamData.subtitleConfig = { trackName: subtitle.ttml.toStr() }
                    exit for    
                else if lCase(subtitle.language) = "en" and subtitle.webvtt <> invalid then
                    streamData.subtitleConfig = { trackName: subtitle.webvtt.toStr() }
                    exit for
                end if
            end for
        end if

        if m.top.video <> invalid then
            m.top.video.content = streamData
        end if
        m.top.videoComplete = false
    end function

    m.player.adBreakStarted = function(adBreakInfo as object)
        print "---- Ad Break Started ---- ";adBreakInfo
        m.top.adPlaying = true
        m.top.video.enableTrickPlay = false
    end function

    m.player.adBreakEnded = function(adBreakInfo as object)
        print "---- Ad Break Ended ---- ";adBreakInfo
        m.top.adPlaying = false
        if m.top.snapbackTime > -1 and m.top.snapbackTime > m.top.video.position then
            m.top.video.seek = m.top.snapbackTime
            m.top.snapbackTime = -1
        end if
        m.top.video.enableTrickPlay = true
    end function

    m.player.allVideoComplete = function()
        print "---- All Video Complete ---- "
        onReset()
        m.top.videoComplete = true
    end function
end sub

sub addCallbacks()
    m.streamManager.addEventListener(m.sdk.AdEvent.ERROR, onError)
    m.streamManager.addEventListener(m.sdk.AdEvent.START, onAdStart)
    m.streamManager.addEventListener(m.sdk.AdEvent.FIRST_QUARTILE, onAdFirstQuartile)
    m.streamManager.addEventListener(m.sdk.AdEvent.MIDPOINT, onAdMidpoint)
    m.streamManager.addEventListener(m.sdk.AdEvent.THIRD_QUARTILE, onAdThirdQuartile)
    m.streamManager.addEventListener(m.sdk.AdEvent.COMPLETE, onAdComplete)
end sub

sub onReset()
    m.top.snapbackTime = -1
    m.top.streamData = invalid
    m.top.adPlaying = false
    if m.top.video <> invalid then
        m.top.video.enableTrickPlay = true
    end if
    m.top.streamManagerReady = false
end sub

sub onVideoChanged()
    if m.video = invalid or not m.video.isSameNode(m.top.video) then
        if m.video <> invalid then
            m.video.unobserveFieldScoped("position")
            m.video.unobserveFieldScoped("timedMetadata")
            m.video.unobserveFieldScoped("state")
        end if
        m.video = m.top.video
        if m.video <> invalid then
            m.video.observeFieldScoped("position", m.port)
            m.video.observeFieldScoped("timedMetadata", m.port)
            m.video.observeFieldScoped("state", m.port)
        end if
        m.top.snapbackTime = -1
        m.top.streamManagerReady = false
    end if
end sub

sub onUserSeek(seekStartTime as integer, seekEndTime as integer)
    previousCuePoint = m.streamManager.getPreviousCuePoint(seekEndTime)
    if previousCuePoint = invalid or previousCuePoint.hasPlayed then
        print "Previous cuepoint was invalid or played"
        return
    else
        print "Previous cuepoint was ";previousCuepoint.start
        ' Add a second to make sure we hit the keyframe at the start of the ad
        print "Seeking to ";previousCuepoint.start + 1
        m.top.video.seek = previousCuePoint.start + 1
        m.top.snapbackTime = seekEndTime
        m.top.inSnapback = true
    end if
end sub

sub onAdStart(ad as object)
    print "Callback from SDK -- Start called - "; ad
    print "breakInfo: "; ad.adBreakInfo
    m.top.adStart = getAdEventData(ad)
end sub

sub onAdFirstQuartile(ad as object)
    print "Callback from SDK -- First quartile called - "
    m.top.adFirstQuartile = getAdEventData(ad)
end sub

sub onAdMidpoint(ad as object)
    print "Callback from SDK -- Midpoint called - "
    m.top.adMidpoint = getAdEventData(ad)
end sub

sub onAdThirdQuartile(ad as object)
    print "Callback from SDK -- Third quartile called - "
    m.top.adThirdQuartile = getAdEventData(ad)
end sub

sub onAdComplete(ad as object)
    print "Callback from SDK -- Complete called - "
    m.top.adComplete = getAdEventData(ad)
end sub

sub onError(error as object)
    print "Callback from SDK -- Error called - "; error
    ' errors are critical and should terminate the stream.
    m.errorState = true
end sub

function getAdEventData(ad as object) as object
    eventData = {}
    eventData.ad = {
        creativeID: ad.adID
        duration: ad.duration
        length: ad.duration
        title: ad.adTitle
    }
    breakInfo = ad.adBreakInfo
    eventData.podIndex = breakInfo.podIndex - 1
    eventData.adIndex = breakInfo.adPosition
    eventData.adCount = breakInfo.totalAds
    eventData.position = breakInfo.timeOffset
    return eventData
end function
