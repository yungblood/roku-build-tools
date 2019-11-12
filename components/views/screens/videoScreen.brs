sub init()
    config = getGlobalField("config")
    
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
    m.trickPlayVisible = false

    m.replayGroup = m.top.findNode("replayGroup")
    'child 0 is poster, child 1 is text
    'we are going to utilize this as a group item, so these operations will be done once in case the text is changed later in the xml
    exrect = m.replayGroup.GetChild(1).boundingRect()
    centerx = (1920 - exrect.width) / 2
    m.replayGroup.GetChild(1).translation = [centerx, 860]

   ' if getGlobalField("extremeMemoryManagement") = true then
    if getModel().mid(0, 2).toInt() <= 35 then
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
    m.debugInfo.visible = config.showDebug
    
    m.endCard = m.top.findNode("endCard")
    m.endCard.observeField("buttonSelected", "onEndCardButtonSelected")
    m.endCard.visible = false

    m.continuousPlayTimer = m.top.findNode("continuousPlayTimer")
    m.continuousPlayTimer.observeField("fire", "onContinuousPlayTimerFired")
    
    m.overlayTimer = m.top.findNode("overlayTimer")
    m.overlayTimer.observeField("fire", "onOverlayTimerFired")

    m.timeoutTimer = m.top.findNode("timeoutTimer")
    m.timeoutTimer.observeField("fire", "onTimeoutTimerFired")
    
    m.smoothingTimer = m.top.findNode("smoothingTimer")
    m.smoothingTimer.observeField("fire", "onSmoothingTimerFired")

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
    m.firstPlay = true

    m.timedOut = false
    
    m.idleTimeout = asInteger(config.playback_timeout_bblf, config.liveTimeout)

    'destroy the clock
    m.video.getChild(1).removeChildIndex(9)
    'grab reference to the firmware rectangle
    m.firmRect = m.video.getChild(1).getChild(1)
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    ?"videoScreen.onKeyEvent", key, press, m.inAd
    if press then
        if not m.inAd then
            if key = "back" then
                if m.overlay.visible then
                    m.overlay.visible = false
                    m.overlayTimer.control = "stop"
                else
                    m.top.close = true
                end if 
                return true
            end if
        else
            'm.inAd - send key to brightline
            brightline = getGlobalField("brightline")
            if brightline <> invalid then
                brightline.BLKeyPress = key
            end if
            if key = "play" then
                if m.video.enableUI then
                    if m.video.state = "playing" then
                        m.video.control = "pause"
                    else if m.video.state = "paused" then
                        m.video.control = "resume"
                    end if
                end if
            end if
        end if
    else
        if not m.inAd then
            if key = "replay" then
                if m.trickPlayVisible and m.video.state <> "paused" then m.replayGroup.visible = true
            end if
            if key = "OK" then
                'manual control of overlay display so make sure we disable timer for this
                if m.video.state = "playing" then
                    if m.overlay.visible then
                        m.overlay.visible = false
                        m.overlayTimer.control = "stop"
                    else
                        m.overlay.visible = true
                        m.overlayTimer.control = "stop"
                        m.overlayTimer.control = "start"
                    end if
                end if
            end if
        end if
    end if
    return false
end function

sub fixFirmRectOpacity(desiredOpacity As integer)
    if m.firmRect <> invalid then
        'this is intended to eliminate flicker, if we don't need to change the value then don't change the value
        if m.firmRect.opacity <> desiredOpacity then
            m.firmRect.opacity = desiredOpacity
        end if
    end if
end sub

sub onClosed()
    m.video.control = "stop"
    if m.loadTask <> invalid then
        m.loadTask.unobserveField("episode")
        m.loadTask = invalid
    end if
    m.video.unobserveFieldScoped("close")
    if m.top.useDai then
        dai = getGlobalField("dai")
        if dai <> invalid then
            dai.unobserveField("error")
            dai.unobserveField("videoComplete")
            dai.unobserveField("adPosition")
            dai.unobserveField("adStart")
            dai.unobserveField("adFirstQuartile")
            dai.unobserveField("adMidpoint")
            dai.unobserveField("adThirdQuartile")
            dai.unobserveField("adComplete")
            dai.video = invalid
            dai.callFunc("reset")
        end if
    end if
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        if m.video <> invalid then
            m.video.setFocus(true)
        end if
        setGlobalField("ignoreBack",false)
    end if
end sub

sub onContentReady()
    if m.top.useDai and m.video.content <> invalid then
        if m.video.content.streamDetails <> invalid then
            m.debugInfo.text = "DAI Stream ID: " + m.video.content.streamDetails.streamID
        end if
        if not m.top.close then
            m.video.control = "play"
        end if
        m.firstPlay = true
    end if
end sub

sub onVideoComplete()
    if m.top.useDai then
        dai = getGlobalField("dai")
        if dai.videoComplete then
            if m.errorDialog = invalid then
                if not playNext() then
                    m.top.close = true
                end if
            else
                m.errorDialog.setFocus(true)
            end if
        end if
    end if
end sub

sub onOverlayVisibilityHint()
    if m.inAd then
        m.trickPlayVisible = false
    else
        m.trickPlayVisible = m.video.trickPlayBarVisibilityHint
    end if
end sub

sub clearMetadata()
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
end sub

sub onOverlayTimerFired()
    m.overlay.visible = false
    m.overlayTimer.control = "stop"
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
            m.overlay.visible = false
            m.overlayTimer.control = "stop"
            m.replayGroup.visible = false
        else if state = "error" then
            m.replayGroup.visible = false
            showErrorDialog(m.video.errorMsg)
        else if state = "buffering" then
            m.overlay.visible = false
            m.overlayTimer.control = "stop"
            m.smoothingTimer.control = "stop"
            hideSpinner()
            ' HACK: The Roku firmware automatically moves the video state to buffering
            '       when the user switches audio tracks, even if the player is paused,
            '       so we check for an audio track change to determine whether this is
            '       a valid buffer after a pause (e.g., ffw or rew), or if we need to
            '       allow the player to resume playback manually
            if not m.paused or m.video.audioTrack = m.currentAudioTrack then
                m.video.enableTrickPlay = false
            end if
            m.currentAudioTrack = m.video.audioTrack
        else if state = "paused" then
            ' Track the current audio track, to detect track changes in buffering
            m.currentAudioTrack = m.video.audioTrack
            'this will remove flickers of less than 100ms but also introduce a short delay before display of 100ms
            m.smoothingTimer.control = "stop"
            m.smoothingTimer.control = "start"

            m.paused = true
            m.pausedPosition = m.video.position
            sendDWAnalytics({method: "playerPause", params: [m.episode, getPlayerPosition(true), getPlayerPosition()]})
            sendDWAnalytics({method: "playerPlayPosition", params: [m.episode, getPlayerPosition()]})
            trackVideoPause()
            m.pauseTimer.mark()

            comscore = getGlobalField("comscore")
            if comscore <> invalid then
                comscore.videoEnd = true
            end if
            m.replayGroup.visible = false
            fixFirmRectOpacity(1)
        else if state = "playing" then
            ' Fire launch complete beacon (Roku cert requirement)
            ' Only fired by the scene if this is a deeplink
            setGlobalField("launchComplete", true)

            if m.firstPlay then
                clearMetadata()
                m.firstPlay = false
            end if
            fixFirmRectOpacity(0)
            hideSpinner()
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
            comscore = getGlobalField("comscore")
            if comscore <> invalid then
                comscore.videoStart = true
            end if
            m.paused = false
            m.replayGroup.visible = false
            m.overlay.visible = false
            m.overlayTimer.control = "stop"
            m.smoothingTimer.control = "stop"
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
            comscore = getGlobalField("comscore")
            if comscore <> invalid then
                comscore.videoEnd = true
            end if
            trackVideoComplete()
            trackVideoUnload()
            m.replayGroup.visible = false
            m.overlay.visible = false
            m.overlayTimer.control = "stop"
            m.smoothingTimer.control = "stop"
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
    dai = getGlobalField("dai")
    if not m.top.useDai or dai = invalid or not dai.adPlaying then
        m.video.enableTrickPlay = not m.episode.isLive
    end if 

'    ?"CONTENT POSITION:";m.position,"STREAM POSITION:";m.video.position
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
                    sendSparrowAnalytics({method: "playerLivePlayPosition", params: [m.episode, getPlayerPosition()]})
                else
                    sendDWAnalytics({method: "playerPlayPosition", params: [m.episode, getPlayerPosition()]})
                    sendSparrowAnalytics({method: "playerPlayPosition", params: [m.episode, getPlayerPosition()]})
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
            setGlobalField("cbsDialog", m.stillWatchingDialog)
            
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

sub onSmoothingTimerFired()
    m.smoothingTimer.control = "stop"
    if not m.inAd then
        m.overlay.visible = true
    end if
end sub

sub onEpisodeIDChanged()
    showSpinner(m.top, true)

    m.nextEpisode = invalid
    m.cpInfo = invalid
    m.overlay.visible = false
    m.overlayTimer.control = "stop"
    m.endCard.visible = false
    m.video.bifDisplay.visible = false
    m.video.trickPlayBar.visible = false
    m.video.content = invalid

    m.loadTask = createObject("roSGNode", "LoadEpisodeTask")
    m.loadTask.observeField("episode", "onEpisodeLoaded")
    m.loadTask.episodeID = m.top.episodeID
    m.loadTask.refreshParentalControls = true
    m.loadTask.populateStream = true
    m.loadTask.control = "run"
end sub

sub onEpisodeLoaded(nodeEvent as object)
    showSpinner()
    if m.top.useDai then
        dai = getGlobalField("dai")
        if dai <> invalid then
            dai.unobserveField("error")
            dai.unobserveField("videoComplete")
            dai.unobserveField("adPosition")
            dai.unobserveField("adStart")
            dai.unobserveField("adFirstQuartile")
            dai.unobserveField("adMidpoint")
            dai.unobserveField("adThirdQuartile")
            dai.unobserveField("adComplete")
        end if
    end if

    m.loadTask = invalid
    task = nodeEvent.getRoSGNode()
    m.episode = nodeEvent.getData()
    m.top.episode = m.episode

'   ---- According to the new DRM Logic on ticket 1031 -------
    user = getGlobalField("user")
    rafMediaTypes = [
        "Full Episode"
        "AA Original"
        ""
    ]
    if m.episode <> invalid then
        if m.episode.isLive or (user.isAdFree and arrayContains(rafMediaTypes, m.episode.mediaType)) then
            m.top.useDai = false
        end if
    end if
'   -------------------- end ------------------   
 
    if m.top.useDai then
        dai = getGlobalField("dai")
        if dai = invalid then
            dai = createObject("roSGNode", "DaiTask")
            dai.control = "run"
            setGlobalField("dai", dai)
        end if
        dai.observeField("error", "onDaiError")
        dai.observeField("videoComplete", "onVideoComplete")
        dai.observeField("adPosition", "onAdPosition")
        dai.observeField("adStart", "onAdStart")
        dai.observeField("adFirstQuartile", "onAdFirstQuartile")
        dai.observeField("adMidpoint", "onAdMidpoint")
        dai.observeField("adThirdQuartile", "onAdThirdQuartile")
        dai.observeField("adComplete", "onAdComplete")
    end if
    brightline = getGlobalField("brightline")
    if brightline = invalid then
        brightline = createObject("roSGNode", "BrightlineTask")
        brightline.control = "run"
        setGlobalField("brightline", brightline)    
    end if

    m.heartbeatContext = {}
    m.omnitureParams = {}
    m.endCardOmnitureParams = {}

    m.heartbeatContext["screenName"] = m.top.omnitureName
    m.heartbeatContext["showId"] = m.episode.showID
    m.heartbeatcontext["showTitle"] = m.episode.showName

    m.omnitureParams["showEpisodeTitle"] = m.episode.title
    m.heartbeatContext["showEpisodeTitle"] = m.episode.title
    m.omnitureParams["showSeriesId"] = m.episode.showID
    m.endCardOmnitureParams["showSeriesId"] = m.episode.showID
    m.omnitureParams["showEpisodeLabel"] = m.episode.title
    m.endCardOmnitureParams["showEpisodeLabel"] = m.episode.title
    if m.episode.showName <> "" then
        m.omnitureParams["showEpisodeTitle"] = m.episode.showName + " - " + m.omnitureParams["showEpisodeTitle"]
        m.heartbeatContext["showEpisodeTitle"] = m.episode.showName + " - " + m.omnitureParams["showEpisodeTitle"]
        m.omnitureParams["showSeriesTitle"] = m.episode.showName
        m.endCardOmnitureParams["showSeriesTitle"] = m.episode.showName
    end if
    m.omnitureParams["showEpisodeId"] = m.episode.id
    m.heartbeatContext["showEpisodeId"] = m.episode.id
    m.endCardOmnitureParams["showEpisodeId"] = m.episode.id
    if m.episode.subtype() = "Movie" or m.episode.subtype() = "Trailer" then
        m.omnitureParams.v38 = "vod:movies"
        m.heartbeatContext["mediaContentType"] = "vod:movies"

        m.heartbeatContext["movieId"] = m.episode.id
        m.omnitureParams["movieId"] = m.episode.id
        m.endCardOmnitureParams["movieId"] = m.episode.id
        m.heartbeatcontext["movieTitle"] = m.episode.title
        m.omnitureParams["movieTitle"] = m.episode.title
        m.endCardOmnitureParams["movieTitle"] = m.episode.title
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
    if not isNullOrEmpty(m.episode.seasonNumber) then
        m.heartbeatContext["showSeasoNumber"] = m.episode.seasonNumber
        m.omnitureParams["showSeasonNumber"] = m.episode.seasonNumber
        m.endCardOmnitureParams["showSeasonNumber"] = m.episode.seasonNumber
    end if
    if not isNullOrEmpty(m.episode.episodeNumber) then
        m.heartbeatContext["showEpisodeNumber"] = m.episode.episodeNumber
        m.omnitureParams["showEpisodeNumber"] = m.episode.episodeNumber
        m.endCardOmnitureParams["showEpisodeNumber"] = m.episode.episodeNumber
    end if
    if not isNullOrEmpty(m.episode.primaryCategoryName) then
        m.heartbeatContext["showDaypart"] = lCase(m.episode.primaryCategoryName.split("/")[0])
        m.omnitureParams["showDaypart"] = lCase(m.episode.primaryCategoryName.split("/")[0])
        m.endCardOmnitureParams["showDaypart"] = lCase(m.episode.primaryCategoryName.split("/")[0])
    end if

    m.omnitureParams.v36 = "false"
    m.omnitureParams.v46 = ""
    m.omnitureParams.v59 = iif(m.episode.subscriptionLevel = "FREE", "non-svod", "svod")
    m.heartbeatContext["mediaSvodContentType"] = iif(m.episode.subscriptionLevel = "FREE", "free", "paid")
    m.omnitureParams["mediaSvodContentType"] = iif(m.episode.subscriptionLevel = "FREE", "free", "paid")
    m.endCardOmnitureParams["mediaSvodContentType"] = iif(m.episode.subscriptionLevel = "FREE", "free", "paid")
    m.omnitureParams.pev2 = "video"
    m.omnitureParams.pev3 = "video"

    m.omnitureParams.v24 = m.vguid
    m.omnitureParams.p24 = m.vguid

    m.omnitureParams["showGenre"] = m.episode.genre
    m.endCardOmnitureParams["showGenre"] = m.episode.genre
    ' Unsure how to retrieve this, so commenting out for now
    ' m.endCardOmnitureParams["showDaypart"] = ""
    m.endCardOmnitureParams["showAirDate"] = m.episode.airDateIso
    
    if m.top.additionalContext <> invalid then
        m.omnitureParams.append(m.top.additionalContext)
        m.heartbeatContext.append(m.top.additionalContext)
        m.top.additionalContext = {}
    end if

    m.top.content = m.episode
    if m.episode = invalid then
        hideSpinner()
        if task.error = "CONCURRENT_STREAM_LIMIT" then
            dialog = createCbsDialog("Concurrent Streams Limit", "You've reached the maximum number of simultaneous video streams for your account. To view this video, close the other videos you're watching and try again.", ["OK"])
            dialog.observeField("buttonSelected", "onErrorDialogClose")
            setGlobalField("cbsDialog", dialog)
        else
            dialog = createCbsDialog("Content Unavailable", "The content you are trying to play is currently unavailable. Please try again later.", ["OK"])
            dialog.observeField("buttonSelected", "onErrorDialogClose")
            setGlobalField("cbsDialog", dialog)
        end if
    else
        if m.episode.videoStream <> invalid then
            if m.episode.videoStream.url = constants().errorProxy then
                hideSpinner()
                dialog = createCbsDialog("Oh no!", "It looks like you're using a VPN or proxy, which prevents playing your video. Please disable this service and try again." + chr(10) + chr(10) + "Questions? Visit our FAQ page at http://cbs.com/vpnhelp.", ["OK"])
                dialog.observeField("buttonSelected", "onErrorDialogClose")
                setGlobalField("cbsDialog", dialog)
                return
            end if
        end if

        if isRestricted(m.episode, user) then
            hideSpinner()
            params = {}
            params.append(m.omnitureParams)
            scene = m.top.getScene()
            if scene <> invalid then
                prevScreen = scene.callFunc("getPreviousScreen")
                if prevScreen <> invalid then
                    ' Data is expecting the previous screen name, instead of the video screen,
                    ' so we grab it and set it here
                    params["screenName"] = prevScreen.omnitureName
                end if
            end if
            showPinDialog("Enter your PIN to watch", ["SUBMIT", "CANCEL"], "onPinDialogButtonSelected", params)
        else
            resumePlayback()
        end if
    end if
end sub

sub onPinDialogButtonSelected(nodeEvent as object)
    params = {}
    params.append(m.omnitureParams)
    scene = m.top.getScene()
    if scene <> invalid then
        prevScreen = scene.callFunc("getPreviousScreen")
        if prevScreen <> invalid then
            ' Data is expecting the previous screen name, instead of the video screen,
            ' so we grab it and set it here
            params["screenName"] = prevScreen.omnitureName
        end if
    end if

    dialog = nodeEvent.getRoSGNode()
    button = nodeEvent.getData()
    if lCase(button) = "cancel" then
        params["parentalControlsCancel"] = "1"
        trackScreenAction("trackparentalControlsCancel", params)

        m.top.close = true
    else if button = "SUBMIT" then
        pinPad = dialog.findNode("pinPad")
        success = true
        if pinPad <> invalid then
            user = getGlobalField("user")
            if user.parentalControlPin <> pinPad.pin then
                success = false
                showPinErrorDialog("Login Error", "Invalid PIN entered", ["CLOSE"], "onPinErrorDialogButtonSelected", params)
            end if
        end if
        if success then
            params["parentalControlsEnterPinOk"] = "1"
            trackScreenAction("trackparentalControlsEnterPinOk", params)
            resumePlayback()
        end if
    end if
    dialog.close = true
end sub

sub onPinErrorDialogButtonSelected(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    dialog.close = true
    m.top.close = true
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
        
        ' We have continuous play info, so make sure we skip the postroll
        if m.rafTask <> invalid then
            m.rafTask.skipPostroll = true
        end if
    end if
end sub

sub onEndCardButtonSelected(nodeEvent as object)
'    omnitureParams = {}
'    omnitureParams.append(m.omnitureParams)
'    omnitureParams["podType"] = "end card ui"
'    omnitureParams["podSection"] = "video"

    omnitureParams = {}
    omnitureParams.append(m.endCard.omnitureParams)
    omnitureParams["endCardCountdownTime"] = asString(m.endCard.countdown)

    button = nodeEvent.getData()
    if button <> invalid then
        if button.id.inStr("Zoom") > 0 then
            setVideoToFullScreen(true)
            omnitureParams["eventEndCardCreditsSelect"] = "1"
            trackScreenAction("trackEndCardSelectCredits", omnitureParams)
'            omnitureParams["podText"] = "credits"
'            trackScreenAction("trackPodSelect", omnitureParams, m.top.omnitureName, m.top.omniturePageType)
        else
            if m.cpInfo <> invalid then
                if m.cpInfo.episode <> invalid then
                    m.nextEpisode = m.cpInfo.episode
                    m.watchNextType = "single_next-ep"
                else
                    m.nextEpisode = button.itemContent.video
                    m.watchNextType = button.itemContent.watchNextType
                    omnitureParams["endCardContentPosition"] = asString(button.index + 1)
                end if
                omnitureParams["endCardContentSelection"] = m.nextEpisode.title
                trackScreenAction("trackEndCardSelect", omnitureParams)
'                omnitureParams["mediaWatchNextType"] = m.watchNextType
'                omnitureParams["podText"] = "upnext|play"
'                omnitureParams["podTitle"] = m.nextEpisode.title
'                omnitureParams["showId"] = m.nextEpisode.showID
'                omnitureParams["showName"] = m.nextEpisode.showName
'                omnitureParams["showEpisodeId"] = m.nextEpisode.id
'                omnitureParams["showEpisodeTitle"] = m.nextEpisode.showName + " - " + m.nextEpisode.title
'                trackScreenAction("trackPodSelect", omnitureParams, m.top.omnitureName, m.top.omniturePageType)
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
    m.overlay.visible = false
    m.overlayTimer.control = "stop"
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
        if not m.top.close then
            m.video.control = "play"
            m.video.setFocus(true)
        end if
        if m.resumePoint > 0 then
            m.video.seek = m.resumePoint
        end if
    end if
end sub

sub onAdStart(nodeEvent as object)
    ' Ensure the spinner is hidden in the case of a RAF ad
    hideSpinner()

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
    comscore = getGlobalField("comscore")
    if comscore <> invalid then
        comscore.adStart = true
    end if

    position = eventData.position
    if position <> m.lastAdPosition then
        m.lastAdPosition = position
        breakName = "mid"
        if position = 0 then
            breakName = "pre"
        else if position = m.episode.length then
            breakName = "post"
        end if
        trackAdBreakStart(breakName, position, eventData.podIndex + 1)
    end if
'    trackScreenAction("trackVideoLoad", m.omnitureParams, m.top.omnitureName, m.top.omniturePageType, ["event60"])
    trackAdStart(eventData.ad, eventData.adIndex)
    
    if m.top.useDai then
        user = getGlobalField("user")
        m.adCounter.visible = (not user.isAdFree)
        m.adCounterShadow.visible = m.adCounter.visible
        m.adCounter.text = "Ad " + eventData.adIndex.toStr() + " of " + eventData.adCount.toStr()
        m.adCounterShadow.text = m.adCounter.text
        
        setVideoToFullScreen()
    end if
    
    m.inAd = true
    m.overlay.visible = false
    m.overlayTimer.control = "stop"
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
    comscore = getGlobalField("comscore")
    if comscore <> invalid then
        comscore.adEnd = true
    end if

'    trackScreenAction("trackVideoComplete", m.omnitureParams, m.top.omnitureName, m.top.omniturePageType, ["event61"])
    trackAdComplete()
    if eventData.adIndex = eventData.adCount then
        trackAdBreakComplete()
    end if
    
    if m.top.useDai then
        user = getGlobalField("user")
        m.adCounter.visible = ((not user.isAdFree) and (eventData.adIndex < eventData.adCount))
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
    dai = getGlobalField("dai")
    showErrorDialog(dai.error)
end sub

sub showErrorDialog(errorMessage as string)
    if m.errorDialog <> invalid and not m.errorDialog.close then
        ' We're already showing an error, skip this one
        return
    end if

    hideSpinner()

    if m.episode.isLive then
        sendDWAnalytics({method: "playerLiveError", params: [errorMessage, m.episode, getPlayerPosition(true), getPlayerPosition()]})
    else
        sendDWAnalytics({method: "playerError", params: [errorMessage, m.episode, getPlayerPosition(true), getPlayerPosition()]})
    end if
    comscore = getGlobalField("comscore")
    if comscore <> invalid then
        comscore.videoEnd = true
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
    setGlobalField("cbsDialog", m.errorDialog)
end sub

function getPlayerPosition(includeAds = false as boolean) as integer
    if m.top.useDai then
        if includeAds then
            return m.video.position
        end if
        dai = getGlobalField("dai")
        return dai.contentTime
    end if
    if includeAds then
        if m.rafTask <> invalid then
            return m.video.position + m.rafTask.adPlaybackTime
        end if
    end if
    return m.video.position
end function

sub resumePlayback()
    m.video.enableTrickPlay = not m.episode.isLive
    if m.top.resumePoint > -1 then
        startPlayback(m.isContinuousPlay, m.top.resumePoint, m.isContinuousPlay, m.isForced)
        ' reset the resume point, so we don't accidentally resume
        ' on continuous play
        m.top.resumePoint = -1
    else if m.episode.resumePoint > 0 and (m.episode.resumePoint < m.episode.length * .97) then
        startPlayback(m.isContinuousPlay, m.episode.resumePoint, m.isContinuousPlay, m.isForced)
'        hideSpinner()
'        
'        dialog = createCbsDialog("Resume Watching", "Would you like to continue watching from where you left off or start from the beginning?", ["Resume", "Start Over"])
'        dialog.messageAlignment = "left"
'        dialog.allowBack = true
'        dialog.observeField("buttonSelected", "onResumeDialogButtonSelected")
'        setGlobalField("cbsDialog", dialog)
'        
'        omnitureData = m.top.omnitureData
'        if omnitureData = invalid then
'            omnitureData = {}
'        end if
'        omnitureData["podType"] = "overlay"
'        omnitureData["podText"] = "resume watching"
'        trackScreenAction("trackPodSelect", omnitureData)
    else
        startPlayback(m.isContinuousPlay, 0, m.isContinuousPlay, m.isForced)
    end if
end sub

sub startPlayback(skipPreroll = false as boolean, resumePosition = 0 as integer, isContinuousPlay = false as boolean, forced = false as boolean)
?"---- START PLAYBACK ----"
    showSpinner()

    runGarbageCollector()
    if m.episode <> invalid then
        if canWatch(m.episode, m.top) then
            user = getGlobalField("user")
            config = getGlobalField("config")
            if m.episode.videoStream <> invalid and m.episode.videoStream.url <> "" then
                streamData = m.episode.videoStream
                m.vguid = createObject("roDeviceInfo").getRandomUuid()
                
                streamData.apiKey = config.daiKey
                streamData.videoID = m.episode.id
                
                
                ' Exclude the 5.1 options from "legacy" and select models
                ' due to macroblocking issues
'                model = getModel().mid (0, 2).toInt()
'                if not config.enable51Audio or model <= 39 or model = 80 then
'                    streamData.contentSourceID = config.daiSourceID
'                else
'                    if m.episode.premiumAudioAvailable = true then
'                        streamData.contentSourceID = config.dai51SourceID
'                    else
'                        streamData.contentSourceID = config.daiSourceID
'                    end if
'                end if

'               -------------According to ticket 1031-------------
                if m.episode.isFullEpisode then
                    streamData.contentSourceID = config.daiSourceID
                else
                    if streamData.streamFormat = "hls" then
                        streamData.contentSourceID = config.daiSourceIDClip
                    else
                        streamData.contentSourceID = config.daiSourceID
                    end if
                end if 
'               ----------------------- end ----------------------

    
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
                adParams = config.fixedAdParams
                if lCase(m.episode.genre) = "kids" then
                    adParams = adParams + "&tfcd=1"
                else
                    adParams = adParams + "&tfcd=0"
                end if
                adParams = adParams + "&vguid=" + m.vguid
                adParams = adParams + "&ppid=" + m.episode.adParams["ppid_encoded"]
                adParams = adParams + "&vid=" + m.episode.id
                adParams = adParams + "&cust_params=" + custParams
    
                streamData.adTagParameters = adParams
                if user <> invalid then
                    streamData.ppid = user.ppid
                end if
          
                m.episode.resume = resumePosition > 0
                m.episode.resumePoint = resumePosition
                m.position = resumePosition
                m.resumePoint = resumePosition
                m.adCount = 0
                m.isContinuousPlay = false
                m.isForced = false
        
                sendDWAnalytics({method: "playerInit", params: [not isContinuousPlay, m.vguid] })
                sendSparrowAnalytics({method: "playerInit", params: [not isContinuousPlay] })
                if m.episode.isLive then
                    sendDWAnalytics({method: "playerLiveStart", params: [m.episode, getPlayerPosition()] })
                else
                    sendDWAnalytics({method: "playerStart", params: [m.episode, getPlayerPosition(), 1, iif(isContinuousPlay, iif(forced, "autoplay:endcard_click", "autoplay:endcard"), "")] })
                end if
                comscore = getGlobalField("comscore")
                if comscore = invalid then
                    comscore = createObject("roSGNode", "ComscoreTask")
                    comscore.control = "run"
                    setGlobalField("comscore", comscore)
                end if
                if comscore <> invalid then
                    comscore.callFunc("reset", {})
                    comscore.content = m.episode
                end if
                
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
                        show = getShowFromCache(showID)
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
                    dai = getGlobalField("dai")
                    if dai <> invalid then
                        dai.callFunc("reset")
                        dai.video = m.video
                        dai.content = m.episode
                        dai.streamData = streamData
                    end if
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
                    m.rafTask.skipPreroll = skipPreroll
                    m.rafTask.content = m.episode
                    m.rafTask.video = m.video
                    m.rafTask.control = "run"
                end if
            else
                if user.state = "SUSPENDED" then
                    dialog = createCbsDialog("Error", "An error occurred when attempting to play this video. Please contact customer support for assistance at " + config.supportPhone + ".", ["OK"])
                    dialog.observeField("buttonSelected", "onErrorDialogClose")
                    setGlobalField("cbsDialog", dialog)
                else
                    dialog = createCbsDialog("Content Unavailable", "The content you are trying to play is currently unavailable. Please try again later.", ["OK"])
                    dialog.observeField("buttonSelected", "onErrorDialogClose")
                    setGlobalField("cbsDialog", dialog)
                end if
            end if
        else
            ' We don't have access to this video, so tell the scene
            ' to we want to watch, which should direct to upsell
            m.top.close = true
            m.top.buttonSelected = "watch"
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
    comscore = getGlobalField("comscore")
    if comscore <> invalid then
        comscore.videoEnd = true
    end if
    trackVideoComplete()
    trackVideoUnload()

'    trackScreenAction("trackVideoComplete", m.omnitureParams, m.top.omnitureName, m.top.omniturePageType, ["event58"])

    m.isContinuousPlay = true
    m.isForced = forced
    if m.nextEpisode = invalid and m.cpInfo <> invalid then
        if m.cpInfo.episode <> invalid then
            m.nextEpisode = m.cpInfo.episode
            'ucase probably isn't required, but if 'free' or any combination of case ever shows up in the value then it'll be valid for the check here
            if not isSubscriber(m.top) and UCASE(m.nextEpisode.subscriptionLevel) <> "FREE" then
                return false
            else
                m.watchNextType = "single_next-ep"
            end if
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
                
                omnitureParams = {}
                omnitureParams.append(m.endCardOmnitureParams)
                omnitureParams.append(m.endCard.omnitureParams)
                omnitureParams["endCardCountdownTime"] = asString(remaining)
                trackScreenAction("trackEndCardView", omnitureParams)
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

