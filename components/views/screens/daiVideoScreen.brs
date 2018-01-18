sub init()
    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.omnitureName = "/video"
    m.top.omniturePageType = "video"
    
    m.top.observeField("close", "onClosed")

    m.overlay = m.top.findNode("overlay")
    m.overlay.visible = false
    
    m.video = m.top.findNode("video")
    m.video.enableCookies()
    m.video.timedMetaDataSelectionKeys = ["*"]

    m.video.observeFieldScoped("content", "onContentReady")
    m.video.observeFieldScoped("position", "onPositionChanged")
    m.video.observeFieldScoped("state", "onVideoStateChanged")
    m.video.observeFieldScoped("trickPlayBarVisibilityHint", "onOverlayVisibilityHint")
    
    if m.global.extremeMemoryManagement then
        ' limit the video resolution on low-end devices
        m.video.maxVideoDecodeResolution = [1280, 720]
    end if

    'm.video.trickPlayBar.thumbBlendColor = "0xffffffff"
    m.video.trickPlayBar.filledBarBlendColor = "0x0092f3ff"
    m.video.trickPlayBar.trackBlendColor = "0xffffff80"
    m.video.bufferingBar.filledBarBlendColor = "0x0092f3ff"
    m.video.retrievingBar.filledBarBlendColor = "0x0092f3ff"
    
    m.video.bifDisplay.reparent(m.overlay, true)
    m.video.bifDisplay.observeField("visible", "onBifVisibleChanged")
    m.video.bifDisplay.observeField("translation", "onBifTranslationChanged")
    m.video.bifDisplay.scale = [.7, .7]
    m.video.bifDisplay.visible = false

    m.video.trickPlayBar.reparent(m.overlay, true)
    m.video.trickPlayBar.visible = false
    
    m.adCounter = m.top.findNode("adCounter")
    m.adCounterShadow = m.top.findNode("adCounterShadow")

    m.showTitle = m.top.findNode("showTitle")
    m.episodeTitle = m.top.findNode("episodeTitle")
    m.episodeNumber = m.top.findNode("episodeNumber")
    m.description = m.top.findNode("description")
    
    m.debugInfo = m.top.findNode("debugInfo")
    
    m.endCard = m.top.findNode("endCard")
    m.endCard.observeField("buttonSelected", "onEndCardButtonSelected")
    m.endCard.visible = false

    m.continuousPlayTimer = m.top.findNode("continuousPlayTimer")
    m.continuousPlayTimer.observeField("fire", "onContinuousPlayTimerFired")
    
    m.overlayTimer = m.top.findNode("overlayTimer")
    m.overlayTimer.observeField("fire", "onOverlayTimerFired")

    m.timeoutTimer = m.top.findNode("timeoutTimer")
    m.timeoutTimer.observeField("fire", "onTimeoutTimerFired")
    
    m.pauseTimer = createObject("roTimespan")
    m.paused = false
    m.pausedPosition = 0

    m.inAd = false
    m.adCount = 0
    m.adPositionOffset = 0

    m.position = 0
    m.overrideEndCard = false
    m.isContinuousPlay = false
    m.isForced = false
    
    m.timedOut = false
    
    m.idleTimeout = asInteger(m.global.config.playback_timeout_bblf, m.global.config.liveTimeout)
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        if not m.inAd then
            if key = "OK" or key = "play" then
                if not m.endCard.visible then
                    m.overlay.visible = true
                    m.overlayTimer.control = "start"
                    return true
                end if
            else if key = "back" then
                if m.overlay.visible then
                    m.overlay.visible = false
                    m.overlayTimer.control = "stop"
                    return true
                else
                    m.top.close = true
                    return true
                end if
            end if
        end if
    end if
    return false
end function

sub onClosed()
    if m.loadTask <> invalid then
        m.loadTask.unobserveField("episode")
        m.loadTask = invalid
    end if
    m.video.unobserveFieldScoped("close")
    if m.top.useDai then
        m.global.dai.unobserveField("error")
        m.global.dai.unobserveField("videoComplete")
        m.global.dai.unobserveField("adPosition")
        m.global.dai.unobserveField("adStart")
        m.global.dai.unobserveField("adFirstQuartile")
        m.global.dai.unobserveField("adMidpoint")
        m.global.dai.unobserveField("adThirdQuartile")
        m.global.dai.unobserveField("adComplete")
        m.global.dai.video = invalid
        m.global.dai.reset = true
    end if
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        if m.video <> invalid then
            m.video.setFocus(true)
        end if
    end if
end sub

sub onContentReady()
    if m.top.useDai and m.video.content <> invalid then
        if m.video.content.streamDetails <> invalid then
            m.debugInfo.text = "DAI Stream ID: " + m.video.content.streamDetails.streamID
        end if
        m.video.control = "play"
    end if
end sub

sub onVideoComplete()
    if m.top.useDai and m.global.dai.videoComplete then
        if m.errorDialog = invalid then
            if not playNext() then
                m.top.close = true
            end if
        else
            m.errorDialog.setFocus(true)
        end if
    end if
end sub

sub onOverlayVisibilityHint()
    if m.video <> invalid then
        m.overlay.visible = (m.video.trickPlayBarVisibilityHint or m.video.state = "paused")
        if m.overlay.visible then
            ' HACK: Find the labels with the current content metadata and hide them
            for i = 0 to m.video.getChildCount() - 1
                child = m.video.getChild(i)
                for j = 0 to child.getChildCount() - 1
                    control = child.getChild(j)
                    if control.subtype() = "Label" then
                        if control.text = m.episode.title then
                            control.text = ""
                        else if control.text = m.episode.titleSeason then
                            control.text = ""
                        end if
                    end if
                next
            next
        end if
    end if
end sub

sub onOverlayTimerFired()
    m.overlay.visible = false
end sub

sub onBifVisibleChanged()
end sub

sub onBifTranslationChanged()
    m.video.bifDisplay.translation = [310, 640]
end sub

sub onVideoStateChanged()
    if m.video <> invalid then
        state = LCase(m.video.state)
        ?"VIDEO STATE: ";state
        if state = "finished" and not m.inAd then
            if m.errorDialog = invalid then
                onContinuousPlayTimerFired()
            else
                m.errorDialog.setFocus(true)
            end if
        else if state = "error" then
            showErrorDialog(m.video.errorMsg)
        else if state = "buffering" then
            m.overlay.visible = false
        else if state = "paused" then
            m.paused = true
            m.pausedPosition = m.video.position
            sendDWAnalytics({method: "playerPause", params: [m.episode, getPlayerPosition(true), getPlayerPosition()]})
            sendDWAnalytics({method: "playerPlayPosition", params: [m.episode, getPlayerPosition()]})
            trackVideoPause()
            m.pauseTimer.mark()

            if m.global.comscore <> invalid then
                m.global.comscore.videoEnd = true
            end if
        else if state = "playing" then
            if m.paused then
                if m.video.position < m.pausedPosition or m.video.position > m.pausedPosition + 1 then
                    if m.video.position > m.pausedPosition then
                        sendDWAnalytics({method: "playerForward", params: [m.video.position - m.pausedPosition, m.episode, getPlayerPosition(true), getPlayerPosition()]})
                    else
                        sendDWAnalytics({method: "playerRewind", params: [m.pausedPosition - m.video.position, m.episode, getPlayerPosition(true), getPlayerPosition()]})
                        
                        ' The user activated trick play, so reset the end card override, so the end card
                        ' shows again.
                        m.overrideEndCard = false
                    end if
                else
                    sendDWAnalytics({method: "playerUnpause", params: [m.pauseTimer.totalSeconds(), m.episode, getPlayerPosition(true), getPlayerPosition()]})
                end if
            end if
            trackVideoPlay()
            if m.global.comscore <> invalid then
                m.global.comscore.videoStart = true
            end if
            m.paused = false
        else if state = "stopped" then
            if m.episode <> invalid then
                if m.episode.isLive then
                    sendDWAnalytics({method: "playerLivePlayPosition", params: [m.episode, getPlayerPosition()]})
                else
                    sendDWAnalytics({method: "playerPlayPosition", params: [m.episode, getPlayerPosition()]})
                end if
                if not m.inAd then
                    if m.episode.isLive then
                        if m.timedOut then
                            sendDWAnalytics({method: "playerLiveForcedEnd", params: ["forcedend", m.episode, getPlayerPosition(), getPlayerPosition()] })
                        else
                            sendDWAnalytics({method: "playerLiveStop", params: [m.episode, getPlayerPosition(), getPlayerPosition()] })
                        end if
                    else
                        sendDWAnalytics({method: "playerStop", params: [m.episode, getPlayerPosition(true), getPlayerPosition()]})
                    end if
                end if
            end if
            if m.global.comscore <> invalid then
                m.global.comscore.videoEnd = true
            end if
            trackVideoComplete()
            trackVideoUnload()
        end if
    end if
end sub

sub onErrorDialogClose(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    if dialog <> invalid then
        dialog.close = true
    end if
    m.errorDialog = invalid
    ' invalidate the episode to prevent dw tracking wiping the resume point
    m.episode = invalid
    m.top.close = true
end sub

sub onContinuousPlayTimerFired()
    if not playNext() then
        m.top.close = true
    end if
end sub

sub onPositionChanged()
    m.position = getPlayerPosition(false)
    ?"CONTENT POSITION:";m.position,"STREAM POSITION:";m.video.position
    if m.lastPosition = invalid or m.position <> m.lastPosition then
        if m.episode.isLive then
            sendDWAnalytics({method: "playerLivePlay", params: [m.episode, getPlayerPosition(true), getPlayerPosition()]})
        else
            sendDWAnalytics({method: "playerPlay", params: [m.episode, getPlayerPosition(true), getPlayerPosition()]})
        end if
        if m.position > 0 then
            if m.position mod 10 = 0 then
                if m.episode.isLive then
                    sendDWAnalytics({method: "playerLivePlayPosition", params: [m.episode, getPlayerPosition()]})
                else
                    sendDWAnalytics({method: "playerPlayPosition", params: [m.episode, getPlayerPosition()]})
                end if
            end if
            if m.position mod 60 = 0 then
                'trackScreenAction("trackVideo", m.omnitureParams, m.top.omnitureName, m.top.omniturePageType, ["event57=60"])
            end if
            trackVideoPlayhead(m.position)
        end if
    end if
    if m.episode.endCreditsChapterTime > 0 and (m.nextEpisode <> invalid or m.cpInfo <> invalid) then
        updateEndCard()
    end if
    
    if m.episode.isLive then
        idleTime = createObject("roDeviceInfo").timeSinceLastKeyPress()
        if idleTime >= m.idleTimeout and m.stillWatchingDialog = invalid then
            m.stillWatchingDialog = createCbsDialog("", "Are you still watching?", ["Continue watching"])
            m.stillWatchingDialog.observeField("buttonSelected", "onTimeoutDialogClosed")
            m.global.dialog = m.stillWatchingDialog
            
            m.timeoutTimer.control = "start"
        end if
    end if
    m.lastPosition = m.position
end sub

sub onTimeoutDialogClosed(nodeEvent as object)
    m.timeoutTimer.control = "stop"
    dialog = nodeEvent.getRoSGNode()
    dialog.close = true
    m.stillWatchingDialog = invalid

    sendDWAnalytics({method: "playerLiveForcedEnd", params: ["resume", m.episode, getPlayerPosition(), getPlayerPosition()] })
    m.video.control = "resume"
end sub

sub onTimeoutTimerFired()
    m.timedOut = true
    m.video.control = "stop"
    m.stillWatchingDialog.close = true
    m.stillWatchingDialog = invalid
    m.top.close = true
end sub

sub onEpisodeIDChanged()
    m.global.showSpinner = true

    m.nextEpisode = invalid
    m.cpInfo = invalid
    m.overlay.visible = false
    m.endCard.visible = false
    m.video.bifDisplay.visible = false
    m.video.trickPlayBar.visible = false
    m.video.content = invalid

    m.loadTask = createObject("roSGNode", "LoadEpisodeTask")
    m.loadTask.observeField("episode", "onEpisodeLoaded")
    m.loadTask.episodeID = m.top.episodeID
    m.loadTask.populateStream = true
    m.loadTask.control = "run"
end sub

sub onEpisodeLoaded(nodeEvent as object)
    m.global.showSpinner = false
    
    if m.top.useDai then
        m.global.dai.unobserveField("error")
        m.global.dai.unobserveField("videoComplete")
        m.global.dai.unobserveField("adPosition")
        m.global.dai.unobserveField("adStart")
        m.global.dai.unobserveField("adFirstQuartile")
        m.global.dai.unobserveField("adMidpoint")
        m.global.dai.unobserveField("adThirdQuartile")
        m.global.dai.unobserveField("adComplete")
    end if

    m.loadTask = invalid
    task = nodeEvent.getRoSGNode()
    m.episode = nodeEvent.getData()
    
    if m.episode.isLive then
        m.top.useDai = false
    end if
    
    if m.top.useDai then
        m.global.dai.observeField("error", "onDaiError")
        m.global.dai.observeField("videoComplete", "onVideoComplete")
        m.global.dai.observeField("adPosition", "onAdPosition")
        m.global.dai.observeField("adStart", "onAdStart")
        m.global.dai.observeField("adFirstQuartile", "onAdFirstQuartile")
        m.global.dai.observeField("adMidpoint", "onAdMidpoint")
        m.global.dai.observeField("adThirdQuartile", "onAdThirdQuartile")
        m.global.dai.observeField("adComplete", "onAdComplete")
    end if

    m.top.content = m.episode
    if m.episode = invalid then
        if task.error = "CONCURRENT_STREAM_LIMIT" then
            dialog = createCbsDialog("Concurrent Streams Limit", "You've reached the maximum number of simultaneous video streams for your account. To view this video, close the other videos you're watching and try again.", ["OK"])
            dialog.observeField("buttonSelected", "onErrorDialogClose")
            m.global.dialog = dialog
        else
            dialog = createCbsDialog("Content Unavailable", "The content you are trying to play is currently unavailable. Please try again later.", ["OK"])
            dialog.observeField("buttonSelected", "onErrorDialogClose")
            m.global.dialog = dialog
        end if
    else
        m.video.enableTrickPlay = not m.episode.isLive
        if m.episode.resumePoint > 0 and (m.episode.resumePoint < m.episode.length * .97) then
            dialog = createCbsDialog("Resume Watching", "Would you like to continue watching from where you left off or start from the beginning?", ["Resume", "Start Over"])
            dialog.messageAlignment = "left"
            dialog.allowBack = true
            dialog.observeField("buttonSelected", "onResumeDialogButtonSelected")
            m.global.dialog = dialog
            
            omnitureData = m.top.omnitureData
            if omnitureData = invalid then
                omnitureData = {}
            end if
            omnitureData["podType"] = "overlay"
            omnitureData["podText"] = "resume watching"
            trackScreenAction("trackPodSelect", omnitureData)
        else
            startPlayback(m.isContinuousPlay, 0, m.isContinuousPlay, m.isForced)
        end if
    end if
end sub

sub onResumeDialogButtonSelected(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    button = nodeEvent.getData()
    if button = "cancel" then
        m.top.close = true
    else if button = "Resume" then
        omnitureData = m.top.omnitureData
        if omnitureData = invalid then
            omnitureData = {}
        end if
        omnitureData["podType"] = "grid_resume"
        omnitureData["podText"] = "play from where i left off"
        trackScreenAction("trackPodSelect", omnitureData)

        startPlayback(m.isContinuousPlay, m.episode.resumePoint, m.isContinuousPlay, m.isForced)
    else
        omnitureData = m.top.omnitureData
        if omnitureData = invalid then
            omnitureData = {}
        end if
        omnitureData["podType"] = "grid_resume"
        omnitureData["podText"] = "restart from beginning"
        trackScreenAction("trackPodSelect", omnitureData)

        startPlayback(m.isContinuousPlay, 0, m.isContinuousPlay, m.isForced)
    end if
    dialog.close = true
end sub

sub onContinuousPlayInfoLoaded(nodeEvent as object)
    m.nextTask = invalid
    m.cpInfo = nodeEvent.getData()
    if m.cpInfo <> invalid then
        m.endCard.continuousPlayInfo = m.cpInfo
    end if
end sub

sub onNextEpisodeLoaded(nodeEvent as object)
    m.nextTask = invalid
    nextEpisode = nodeEvent.getData()
    m.nextEpisode = nextEpisode
    if m.nextEpisode <> invalid then
        m.episode.skipPostroll = true
        m.endCard.episode = m.nextEpisode
    end if
end sub

sub onEndCardButtonSelected(nodeEvent as object)
    omnitureParams = {}
    omnitureParams.append(m.omnitureParams)
    omnitureParams["podType"] = "end card ui"
    omnitureParams["podSection"] = "video"

    button = nodeEvent.getData()
    if button <> invalid then
        if button.id.inStr("Zoom") > 0 then
            setVideoToFullScreen(true)
            
            omnitureParams["podText"] = "credits"
            trackScreenAction("trackPodSelect", omnitureParams, m.top.omnitureName, m.top.omniturePageType)
        else
            if m.cpInfo <> invalid then
                if m.cpInfo.episode <> invalid then
                    m.nextEpisode = m.cpInfo.episode
                    omnitureParams["mediaWatchNextType"] = "single_next-ep"
                else
                    m.nextEpisode = button.itemContent.video
                    omnitureParams["mediaWatchNextType"] = button.itemContent.watchNextType
                end if
                omnitureParams["podText"] = "upnext|play"
                omnitureParams["podTitle"] = m.nextEpisode.title
                omnitureParams["showId"] = m.nextEpisode.showID
                omnitureParams["showName"] = m.nextEpisode.showName
                omnitureParams["showEpisodeId"] = m.nextEpisode.id
                omnitureParams["showEpisodeTitle"] = m.nextEpisode.showName + " - " + m.nextEpisode.title
                trackScreenAction("trackPodSelect", omnitureParams, m.top.omnitureName, m.top.omniturePageType)
                
                m.watchNextType = omnitureParams["mediaWatchNextType"]
            end if
            playNext(true)
        end if
        m.endCard.buttonSelected = invalid
    end if
end sub

sub onVideoStart()
    if not isNullOrEmpty(m.watchNextType) then
        m.omnitureParams["v90"] = m.watchNextType
    else
        m.omnitureParams.delete("v90")
    end if
    'trackScreenAction("trackVideoLoad", m.omnitureParams, m.top.omnitureName, m.top.omniturePageType, ["event52"])
    trackVideoLoad(m.episode, m.heartbeatContext)
    trackVideoStart()
    m.watchNextType = ""
end sub

sub onAdPodReady()
?"==== onAdPodReady ===="
    m.inAd = true
    if m.video.state = "playing" or m.video.state = "finished" then
        m.resumePoint = m.video.position
        if m.video.state = "finished" then
            m.videoComplete = true
        end if
        m.video.control = "stop"
    end if
end sub

sub onAdPodComplete()
?"==== onAdPodComplete ===="
    m.inAd = false
    if m.videoComplete then
        m.top.close = true
    else
        m.video.seek = m.resumePoint
        m.video.control = "play"
        m.video.setFocus(true)
    end if
end sub

sub onAdStart(nodeEvent as object)
?"==== onAdStart ===="
    ' check to make sure we're not in a post-roll during continuous play
    if m.episode.endCreditsChapterTime > 0 and (m.nextEpisode <> invalid or m.cpInfo <> invalid) then
        remaining = int(m.episode.endCreditsChapterEnd - m.position)
        if remaining <= 5 and playNext() then
            return
        end if
    end if

    eventData = nodeEvent.getData()
    m.adCount = m.adCount + 1
    sendDWAnalytics({method: "playerAdStart", params: [eventData.ad, eventData.podIndex + 1, eventData.adIndex, m.adCount, m.episode, getPlayerPosition(true), getPlayerPosition()]})
    if m.global.comscore <> invalid then
        m.global.comscore.adStart = true
    end if

    position = eventData.position
    if position <> m.lastAdPosition then
        m.lastAdPosition = position
        breakName = "mid-roll"
        if position = 0 then
            breakName = "pre-roll"
        else if position = m.episode.length then
            breakName = "post-roll"
        end if
        trackAdBreakStart(breakName, position, eventData.podIndex + 1)
    end if
'    trackScreenAction("trackVideoLoad", m.omnitureParams, m.top.omnitureName, m.top.omniturePageType, ["event60"])
    trackAdStart(eventData.ad, eventData.adIndex)
    
    if m.top.useDai then
        m.adCounter.visible = true
        m.adCounterShadow.visible = true
        m.adCounter.text = "Ad " + eventData.adIndex.toStr() + " of " + eventData.adCount.toStr()
        m.adCounterShadow.text = m.adCounter.text
        
        setVideoToFullScreen()
    end if
    
    m.inAd = true
    if m.convivaTask <> invalid then
        m.convivaTask.adStart = true
    end if
end sub

sub onAdFirstQuartile(nodeEvent as object)
?"==== onAdFirstQuartile ===="
    eventData = nodeEvent.getData()
end sub

sub onAdMidpoint(nodeEvent as object)
?"==== onAdMidpoint ===="
    eventData = nodeEvent.getData()
end sub

sub onAdThirdQuartile(nodeEvent as object)
?"==== onAdThirdQuartile ===="
    eventData = nodeEvent.getData()
end sub

sub onAdPosition(nodeEvent as object)
?"==== onAdPosition ===="
    eventData = nodeEvent.getData()
    sendDWAnalytics({method: "playerAdPlay", params: [eventData.ad, eventData.position, eventData.podIndex + 1, eventData.adIndex, m.adCount, m.episode, getPlayerPosition(true), getPlayerPosition()] })
end sub

sub onAdComplete(nodeEvent as object)
?"==== onAdComplete ===="
    eventData = nodeEvent.getData()
    sendDWAnalytics({method: "playerAdEnd", params: [eventData.ad, asInteger(eventData.ad.duration) - 1, eventData.podIndex + 1, eventData.adIndex, m.adCount, m.episode, getPlayerPosition(true), getPlayerPosition()] })
    if m.global.comscore <> invalid then
        m.global.comscore.adEnd = true
    end if

'    trackScreenAction("trackVideoComplete", m.omnitureParams, m.top.omnitureName, m.top.omniturePageType, ["event61"])
    trackAdComplete()
    if eventData.adIndex = eventData.adCount then
        trackAdBreakComplete()
    end if
    
    if m.top.useDai then
        m.adCounter.visible = eventData.adIndex < eventData.adCount
        m.adCounterShadow.visible = m.adCounter.visible
    end if
    
    m.inAd = false
    if m.convivaTask <> invalid then
        m.convivaTask.adEnd = true
    end if
end sub

sub onAdClose(nodeEvent as object)
?"==== onAdClose ===="
    eventData = nodeEvent.getData()
    
    m.inAd = false
    if m.convivaTask <> invalid then
        m.convivaTask.adEnd = true
    end if

    m.top.close = true
end sub

sub onDaiError()
    showErrorDialog(m.global.dai.error)
end sub

sub showErrorDialog(errorMessage as string)
    if m.episode.isLive then
        sendDWAnalytics({method: "playerLiveError", params: [errorMessage, m.episode, getPlayerPosition(true), getPlayerPosition()]})
    else
        sendDWAnalytics({method: "playerError", params: [errorMessage, m.episode, getPlayerPosition(true), getPlayerPosition()]})
    end if
    if m.global.comscore <> invalid then
        m.global.comscore.videoEnd = true
    end if
    
    error = "Unfortunately, an error occurred during playback."
    ' Check for a network connection error
    if not createObject("roDeviceInfo").getLinkStatus() then
        error = error + " Please check your network connection and try again."
    else
        error = error + " Please try again."
    end if
    m.errorDialog = createCbsDialog("Error", error, ["OK"])
    m.errorDialog.observeField("buttonSelected", "onErrorDialogClose")
    m.global.dialog = m.errorDialog
end sub

function getPlayerPosition(includeAds = false as boolean) as integer
    if m.top.useDai then
        if includeAds then
            return m.video.position
        end if
        return m.global.dai.contentTime
    end if
    if includeAds then
        if m.rafTask <> invalid then
            return m.video.position + m.rafTask.adPlaybackTime
        end if
    end if
    return m.video.position
end function

sub startPlayback(skipPreroll = false as boolean, resumePosition = 0 as integer, isContinuousPlay = false as boolean, forced = false as boolean)
?"---- START PLAYBACK ----"
    ?runGarbageCollector()
    if m.episode <> invalid then
        if m.episode.videoStream <> invalid and m.episode.videoStream.url <> "" then
            streamData = m.episode.videoStream
            m.vguid = createObject("roDeviceInfo").getRandomUuid()
            
            config = m.global.config
            streamData.apiKey = config.daiKey
            streamData.contentSourceID = m.global.config.daiSourceID
            streamData.videoID = m.episode.id

            ' Add encoded video specific custom parameters
            custParams = m.episode.adParams["cust_params_encoded"]
            if skipPreroll then
                custParams = custParams + "%26cpPre%3D1"
            else
                custParams = custParams + "%26cpPre%3D0"
            end if
            if isContinuousPlay then
                custParams = custParams + "%26cpSession%3D1"
            else
                custParams = custParams + "%26cpSession%3D0"
            end if

            adParams = m.global.config.fixedAdParams
            adParams = adParams + "&vguid=" + m.vguid
            adParams = adParams + "&ppid=" + m.episode.adParams["ppid_encoded"]
            adParams = adParams + "&vid=" + m.episode.id
            adParams = adParams + "&cust_params=" + custParams

            streamData.adTagParameters = adParams
            if m.global.user <> invalid then
                streamData.ppid = m.global.user.ppid
            end if

            m.episode.resume = resumePosition > 0
            m.episode.resumePoint = resumePosition
            m.position = resumePosition
            m.resumePoint = resumePosition
            m.adCount = 0
            m.isContinuousPlay = false
            m.isForced = false
    
            sendDWAnalytics({method: "playerInit", params: [not isContinuousPlay, m.vguid] })
            if m.episode.isLive then
                sendDWAnalytics({method: "playerLiveStart", params: [m.episode, getPlayerPosition()] })
            else
                sendDWAnalytics({method: "playerStart", params: [m.episode, getPlayerPosition(), 1, iif(isContinuousPlay, iif(forced, "autoplay:endcard_click", "autoplay:endcard"), "")] })
            end if
            if m.global.comscore <> invalid then
                m.global.comscore.content = m.episode
            end if

            m.heartbeatContext = {}
            m.heartbeatContext["screenName"] = m.top.omnitureName
            m.heartbeatContext["showId"] = m.episode.showID
    
            m.omnitureParams = {}
            m.omnitureParams["showEpisodeTitle"] = m.episode.title
            m.heartbeatContext["showEpisodeTitle"] = m.episode.title
            if m.episode.showName <> "" then
                m.omnitureParams["showEpisodeTitle"] = m.episode.showName + " - " + m.omnitureParams["showEpisodeTitle"]
                m.heartbeatContext["showEpisodeTitle"] = m.episode.showName + " - " + m.omnitureParams["showEpisodeTitle"]
            end if
            m.omnitureParams["showEpisodeId"] = m.episode.id
            m.heartbeatContext["showEpisodeId"] = m.episode.id
            if m.episode.subtype() = "Movie" then
                m.omnitureParams.v38 = "vod:movies"
                m.heartbeatContext["mediaContentType"] = "vod:movies"
            else if m.episode.isLive then
                m.omnitureParams.v38 = "live"
                m.heartbeatContext["mediaContentType"] = "live"
            else if m.episode.isFullEpisode then
                m.omnitureParams.v38 = "vod:fullepisodes"
                m.heartbeatContext["mediaContentType"] = "vod:fullepisodes"
            else
                m.omnitureParams.v38 = "vod:clips"
                m.heartbeatContext["mediaContentType"] = "vod:clips"
            end if
            m.omnitureParams.v36 = "false"
            m.omnitureParams.v46 = ""
            m.omnitureParams.v59 = iif(m.episode.subscriptionLevel = "FREE", "non-svod", "svod")
            m.omnitureParams.pev2 = "video"
            m.omnitureParams.pev3 = "video"

            m.omnitureParams.v24 = m.vguid
            m.omnitureParams.p24 = m.vguid
            
            m.episode.skipPreroll = skipPreroll
    
            onVideoStart()
            setVideoToFullScreen()
            
            if m.episode.resume then
                streamData.bookmarkPosition = m.episode.resumePoint
            end if

            m.episodeTitle.text = m.episode.title
            if m.episode.isLive then
                m.episodeNumber.text = ""
                showID = m.episode.showID
                if showID = "-1" then
                    section = m.episode.getParent()
                    if section <> invalid then
                        showID = section.showID
                    end if
                end if
                if showID <> invalid then
                    show = m.global.showCache[showID]
                    if show <> invalid then
                        m.showTitle.text = uCase(show.title)
                    end if
                end if
            else
                m.showTitle.text = uCase(m.episode.showName)
                m.episodeNumber.text = uCase(m.episode.seasonString + " " + m.episode.episodeString)
            end if
            m.description.text = m.episode.description
    
'            m.nextTask = createObject("roSGNode", "LoadNextEpisodeTask")
'            m.nextTask.observeField("nextEpisode", "onNextEpisodeLoaded")
'            m.nextTask.episode = m.episode
'            m.nextTask.section = m.top.section
'            m.nextTask.control = "run"
            m.nextTask = createObject("roSGNode", "LoadContinuousPlayInfoTask")
            m.nextTask.observeField("continuousPlayInfo", "onContinuousPlayInfoLoaded")
            m.nextTask.episode = m.episode
            m.nextTask.section = m.top.section
            m.nextTask.control = "run"

            m.convivaTask = createObject("roSGNode", "ConvivaTask")
            m.convivaTask.video = m.video
            m.convivaTask.content = m.episode
            m.convivaTask.control = "run"

            if m.top.useDai then
                m.video.content = invalid
                m.global.dai.reset = true
                m.global.dai.video = m.video
                m.global.dai.streamData = streamData
            else
                m.video.content = m.episode.videoStream
                m.rafTask = createObject("roSGNode", "RafTask")
                m.rafTask.observeField("adPodReady", "onAdPodReady")
                m.rafTask.observeField("adPodComplete", "onAdPodComplete")
                m.rafTask.observeField("adStart", "onAdStart")
                m.rafTask.observeField("adFirstQuartile", "onAdFirstQuartile")
                m.rafTask.observeField("adMidpoint", "onAdMidpoint")
                m.rafTask.observeField("adThirdQuartile", "onAdThirdQuartile")
                m.rafTask.observeField("adComplete", "onAdComplete")
                m.rafTask.observeField("adClose", "onAdClose")
                m.rafTask.content = m.episode
                m.rafTask.video = m.video
                m.rafTask.control = "run"
            end if
        else
            if m.global.user.state = "SUSPENDED" then
                dialog = createCbsDialog("Error", "An error occurred when attempting to play this video. Please contact customer support for assistance at " + m.global.config.supportPhone + ".", ["OK"])
                dialog.observeField("buttonSelected", "onErrorDialogClose")
                m.global.dialog = dialog
            else
                dialog = createCbsDialog("Content Unavailable", "The content you are trying to play is currently unavailable. Please try again later.", ["OK"])
                dialog.observeField("buttonSelected", "onErrorDialogClose")
                m.global.dialog = dialog
            end if
        end if
    else
        m.top.close = true
    end if
end sub

function playNext(forced = false as boolean) as boolean
    ' This is always called at the end of playback of the current episode, so track the end here
    ' Update the position to reflect the full video played
    m.position = m.episode.length
    if m.episode.isLive then
        sendDWAnalytics({method: "playerLiveEnd", params: [m.episode, getPlayerPosition(true), getPlayerPosition()] })
        sendDWAnalytics({method: "playerLivePlayPosition", params: [m.episode, getPlayerPosition()] })
    else
        sendDWAnalytics({method: "playerEnd", params: [m.episode, getPlayerPosition(true), getPlayerPosition()] })
        sendDWAnalytics({method: "playerPlayPosition", params: [m.episode, getPlayerPosition()] })
    end if

'    trackScreenAction("trackVideoComplete", m.omnitureParams, m.top.omnitureName, m.top.omniturePageType, ["event58"])

    m.isContinuousPlay = true
    m.isForced = forced
    if m.nextEpisode = invalid and m.cpInfo <> invalid then
        if m.cpInfo.episode <> invalid then
            m.nextEpisode = m.cpInfo.episode
            m.watchNextType = "single_next-ep"
        else
            button = m.endCard.buttonFocused
            if button <> invalid then
                m.nextEpisode = button.itemContent.video
                m.watchNextType = button.itemContent.watchNextType
            end if
        end if
    end if

    if m.nextEpisode <> invalid then
        m.video.control = "stop"
        if m.nextEpisode.videoStream <> invalid then
            m.episode = m.nextEpisode
            m.top.content = m.episode
            m.nextEpisode = invalid
            startPlayback(true, 0, true, forced)
        else
            ' We don't have the stream info, yet, so populate it now
            m.top.episodeID = m.nextEpisode.id
            setVideoToFullscreen(m.overrideEndCard)
        end if

        return true
    end if
    return false
end function

sub updateEndCard()
    if not m.overrideEndCard then
        remaining = int(m.episode.endCreditsChapterEnd - m.position)
        if m.video.state = "playing" and m.position >= m.episode.endCreditsChapterTime then
            if not m.endCard.visible then
                m.endCard.visible = true
                m.video.translation = [m.endCard.viewport.x, m.endCard.viewport.y]
                m.video.width = m.endCard.viewport.width
                m.video.height = m.endCard.viewport.height
                m.endCard.setFocus(true)
            end if
            if remaining > 0 then
                m.endCard.countdown = remaining
            else
                if not playNext() then
                    m.top.close = true
                end if
            end if
        end if
    else
        ?"overridden"
    end if
end sub

sub setVideoToFullScreen(overrideEndCard = false as boolean)
    m.video.translation = [0, 0]
    m.video.width = 1920
    m.video.height = 1080
    m.video.setFocus(true)
    
    m.videoComplete = false
    m.overrideEndCard = overrideEndCard
    m.endCard.visible = false
end sub

