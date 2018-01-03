sub init()
    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.omnitureName = "/video"
    m.top.omniturePageType = "video"
    
    m.overlay = m.top.findNode("overlay")
    m.overlay.visible = false
    
    ' HACK: Observing these as aliased fields to work around an issue with
    '       Conviva unobserving the fields out from under us
    m.top.observeField("position", "onPositionChanged")
    m.top.observeField("state", "onVideoStateChanged")

    m.video = m.top.findNode("video")
    m.video.observeField("trickPlayBarVisibilityHint", "onOverlayVisibilityHint")
    
    if createObject("roDeviceInfo").getModel().mid(0, 1) = "3" then
        ' limit the video resolution on "giga" devices
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

    m.showTitle = m.top.findNode("showTitle")
    m.episodeTitle = m.top.findNode("episodeTitle")
    m.episodeNumber = m.top.findNode("episodeNumber")
    m.description = m.top.findNode("description")
    
    m.endCard = m.top.findNode("endCard")
    m.endCardBackground = m.top.findNode("endCardBackground")
    m.endCardButtons = m.top.findNode("endCardButtons")
    m.endCardButtons.observeField("buttonSelected", "onEndCardButtonSelected")
    m.endCard.visible = false

    m.zoom = m.top.findNode("zoom")
    m.upNext = m.top.findNode("upNext")
    m.countdown = m.top.findNode("countdown")
    m.upNextShowName = m.top.findNode("upNextShowName")
    m.upNextEpisodeNumber = m.top.findNode("upNextEpisodeNumber")
    m.upNextEpisodeName = m.top.findNode("upNextEpisodeName")
    
    m.continuousPlayTimer = m.top.findNode("continuousPlayTimer")
    m.continuousPlayTimer.observeField("fire", "onContinuousPlayTimerFired")
    
    m.overlayTimer = m.top.findNode("overlayTimer")
    m.overlayTimer.observeField("fire", "onOverlayTimerFired")

    m.timeoutTimer = m.top.findNode("timeoutTimer")
    m.timeoutTimer.observeField("fire", "onTimeoutTimerFired")
    
    m.pauseTimer = createObject("roTimespan")
    m.paused = false
    m.pausedPosition = 0

    m.adCount = 0
    m.adPodIndex = 1
    m.adPositionOffset = 0

    m.position = 0
    m.overrideEndCard = false
    
    m.timedOut = false
    
    m.idleTimeout = asInteger(m.global.config.playback_timeout_bblf, m.global.config.liveTimeout)
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        if not m.video.enableTrickPlay then
            if key = "OK" or key = "play" then
                m.overlay.visible = true
                m.overlayTimer.control = "start"
                return true
            else if key = "back" then
                if m.overlay.visible then
                    m.overlay.visible = false
                    m.overlayTimer.control = "stop"
                    return true
                end if
            end if
        end if
    end if
    return false
end function

sub onFocusChanged()
    if m.top.hasFocus() then
        if m.video <> invalid then
            m.video.setFocus(true)
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
        if state = "finished" then ' and not m.playingAd then
            if m.errorDialog = invalid then
                ' HACK: this is needed so the main.brs thread can respond to the content update
                m.continuousPlayTimer.control = "start"
            else
                m.errorDialog.setFocus(true)
            end if
        else if state = "error" then
            if m.episode.isLive then
                m.global.analytics.dwParams = { method: "playerLiveError", params: [m.video.errorMsg, m.episode, getPlayerPosition(true), getPlayerPosition()]}
            else
                m.global.analytics.dwParams = { method: "playerError", params: [m.video.errorMsg, m.episode, getPlayerPosition(true), getPlayerPosition()]}
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
        else if state = "buffering" then
            m.overlay.visible = false
        else if state = "paused" then
            m.paused = true
            m.pausedPosition = m.video.position
            m.global.analytics.dwParams = { method: "playerPause", params: [m.episode, getPlayerPosition(true), getPlayerPosition()]}
            m.global.analytics.dwParams = { method: "playerPlayPosition", params: [m.episode, getPlayerPosition()]}
            m.pauseTimer.mark()
        else if state = "playing" then
            if m.paused then
                if m.video.position < m.pausedPosition or m.video.position > m.pausedPosition + 1 then
                    if m.video.position > m.pausedPosition then
                        m.global.analytics.dwParams = { method: "playerForward", params: [m.video.position - m.pausedPosition, m.episode, getPlayerPosition(true), getPlayerPosition()]}
                    else
                        m.global.analytics.dwParams = { method: "playerRewind", params: [m.pausedPosition - m.video.position, m.episode, getPlayerPosition(true), getPlayerPosition()]}
                    end if
                else
                    m.global.analytics.dwParams = { method: "playerUnpause", params: [m.pauseTimer.totalSeconds(), m.episode, getPlayerPosition(true), getPlayerPosition()]}
                end if
            end if
            m.paused = false
        else if state = "stopped" then
            if m.episode <> invalid then
                if m.episode.isLive then
                    m.global.analytics.dwParams = { method: "playerLivePlayPosition", params: [m.episode, getPlayerPosition()]}
                else
                    m.global.analytics.dwParams = { method: "playerPlayPosition", params: [m.episode, getPlayerPosition()]}
                end if
                if not m.top.playingAd then
                    if m.episode.isLive then
                        if m.timedOut then
                            m.global.analytics.dwParams = { method: "playerLiveForcedEnd", params: ["forcedend", m.episode, getPlayerPosition(), getPlayerPosition()] }
                        else
                            m.global.analytics.dwParams = { method: "playerLiveStop", params: [m.episode, getPlayerPosition(), getPlayerPosition()] }
                        end if
                    else
                        m.global.analytics.dwParams = { method: "playerStop", params: [m.episode, getPlayerPosition(true), getPlayerPosition()]}
                    end if
                end if
            end if
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
    m.position = m.video.position
    if m.episode.isLive then
        m.global.analytics.dwParams = { method: "playerLivePlay", params: [m.episode, getPlayerPosition(true), getPlayerPosition()]}
    else
        m.global.analytics.dwParams = { method: "playerPlay", params: [m.episode, getPlayerPosition(true), getPlayerPosition()]}
    end if
    if m.position > 0 then
        if m.position mod 10 = 0 then
            if m.episode.isLive then
                m.global.analytics.dwParams = { method: "playerLivePlayPosition", params: [m.episode, getPlayerPosition()]}
            else
                m.global.analytics.dwParams = { method: "playerPlayPosition", params: [m.episode, getPlayerPosition()]}
            end if
        end if
        if m.position mod 60 = 0 then
            trackScreenAction("trackVideo", m.omnitureParams, m.top.omnitureName, m.top.omniturePageType, ["event57=60"])
        end if
    end if
    if m.episode.endCreditsChapterTime > 0 and m.nextEpisode <> invalid then
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
end sub

sub onTimeoutDialogClosed(nodeEvent as object)
    m.timeoutTimer.control = "stop"
    dialog = nodeEvent.getRoSGNode()
    dialog.close = true
    m.stillWatchingDialog = invalid

    m.global.analytics.dwParams = { method: "playerLiveForcedEnd", params: ["resume", m.episode, getPlayerPosition(), getPlayerPosition()] }
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
    m.overlay.visible = false
    m.endCard.visible = false
    m.video.bifDisplay.visible = false
    m.video.trickPlayBar.visible = false

    m.loadTask = createObject("roSGNode", "LoadEpisodeTask")
    m.loadTask.observeField("episode", "onEpisodeLoaded")
    m.loadTask.episodeID = m.top.episodeID
    m.loadTask.populateStream = true
    m.loadTask.control = "run"
end sub

sub onEpisodeLoaded(nodeEvent as object)
    m.global.showSpinner = false
    
    m.loadTask = invalid
    task = nodeEvent.getRoSGNode()
    m.episode = nodeEvent.getData()
    
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
            startPlayback(false)
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

        startPlayback(false, m.episode.resumePoint)
    else
        omnitureData = m.top.omnitureData
        if omnitureData = invalid then
            omnitureData = {}
        end if
        omnitureData["podType"] = "grid_resume"
        omnitureData["podText"] = "restart from beginning"
        trackScreenAction("trackPodSelect", omnitureData)

        startPlayback(false)
    end if
    dialog.close = true
end sub

sub onNextEpisodeLoaded(nodeEvent as object)
    m.nextTask = invalid
    nextEpisode = nodeEvent.getData()
    m.nextEpisode = nextEpisode
    if m.nextEpisode <> invalid then
        m.episode.skipPostroll = true
        show = m.global.showCache[m.nextEpisode.showID]
        if show <> invalid then
            m.endCardBackground.uri = getImageUrl(show.heroImageUrl, m.endCardBackground.width)
        else
            m.endCardBackground.uri = ""
        end if
        m.upNext.backgroundUri = getImageUrl(m.nextEpisode.thumbnailUrl, m.upNext.width)
        m.upNext.focusedBackgroundUri = getImageUrl(m.nextEpisode.thumbnailUrl, m.upNext.width)
        m.upNextShowName.text = m.nextEpisode.showName
        
        upNextEpisodeNumber = (m.nextEpisode.seasonString + " " + m.nextEpisode.episodeString).trim()
        if not isNullOrEmpty(upNextEpisodeNumber) then
            upNextEpisodeNumber = upNextEpisodeNumber + " | "
        end if
        m.upNextEpisodeNumber.text = upNextEpisodeNumber + m.nextEpisode.durationString
        m.upNextEpisodeName.text = m.nextEpisode.title
    end if
end sub

sub onEndCardButtonSelected(nodeEvent as object)
    button = m.endCardButtons.getChild(nodeEvent.getData())
    if button <> invalid then
        if button.id = "zoom" then
            setVideoToFullScreen(true)
        else
            playNext(true)
        end if
    end if
end sub

sub onVideoStart(nodeEvent as object)
    trackScreenAction("trackVideoLoad", m.omnitureParams, m.top.omnitureName, m.top.omniturePageType, ["event52"])
end sub

sub onAdStart(nodeEvent as object)
    eventData = nodeEvent.getData()
    m.adCount = m.adCount + 1
    m.global.analytics.dwParams = { method: "playerAdStart", params: [eventData.ad, eventData.podIndex + 1, eventData.adIndex, m.adCount, m.episode, getPlayerPosition(true), getPlayerPosition()]}

    trackScreenAction("trackVideoLoad", m.omnitureParams, m.top.omnitureName, m.top.omniturePageType, ["event60"])
    
'    adPods = m.AdPods
'    if isArray(adPods) then
'        adPods = adPods[0]
'    end if
'    ad = eventData.ad
'    ' TODO: Currently Akamai only supports pre-rolls
'    if m.position = 0 and ad <> invalid then
'        m.Akamai.handleAdLoaded(GetAkamaiAdParams(ad, getPlayerPosition() - m.AdPositionOffset))
'        m.Akamai.handleAdStarted(GetAkamaiAdParams(ad, getPlayerPosition() - m.AdPositionOffset))
'    end if
end sub

sub onAdFirstQuartile(nodeEvent as object)
    eventData = nodeEvent.getData()
'    ad = eventData.ad
'    ' TODO: Currently Akamai only supports pre-rolls
'    if m.position = 0 and ad <> invalid then
'        m.Akamai.handleAdFirstQuartile(GetAkamaiAdParams(ad, getPlayerPosition() - m.AdPositionOffset))
'    end if
end sub

sub onAdMidpoint(nodeEvent as object)
    eventData = nodeEvent.getData()
'    ad = eventData.ad
'    ' TODO: Currently Akamai only supports pre-rolls
'    if m.position = 0 and ad <> invalid then
'        m.Akamai.handleAdMidpoint(GetAkamaiAdParams(ad, getPlayerPosition() - m.AdPositionOffset))
'    end if
end sub

sub onAdThirdQuartile(nodeEvent as object)
    eventData = nodeEvent.getData()
'    ad = eventData.ad
'    ' TODO: Currently Akamai only supports pre-rolls
'    if m.position = 0 and ad <> invalid then
'        m.Akamai.handleAdThirdQuartile(GetAkamaiAdParams(ad, getPlayerPosition() - m.AdPositionOffset))
'    end if
end sub

sub onAdPosition(nodeEvent as object)
    eventData = nodeEvent.getData()
    m.global.analytics.dwParams = { method: "playerAdPlay", params: [eventData.ad, eventData.position, eventData.podIndex + 1, eventData.adIndex, m.adCount, m.episode, getPlayerPosition(true), getPlayerPosition()] }
end sub

sub onAdComplete(nodeEvent as object)
    eventData = nodeEvent.getData()
    m.global.analytics.dwParams = { method: "playerAdEnd", params: [eventData.ad, asInteger(eventData.ad.duration) - 1, eventData.podIndex + 1, eventData.adIndex, m.adCount, m.episode, getPlayerPosition(true), getPlayerPosition()] }

    trackScreenAction("trackVideoComplete", m.omnitureParams, m.top.omnitureName, m.top.omniturePageType, ["event61"])

'    adPods = m.AdPods
'    if isArray(adPods) then
'        adPods = adPods[0]
'    end if
'    
'    ' TODO: Currently Akamai only supports pre-rolls
'    if m.position = 0 and ad <> invalid then
'        m.Akamai.handleAdComplete(GetAkamaiAdParams(ad, getPlayerPosition() - m.AdPositionOffset))
'        m.Akamai.handleAdEnd(GetAkamaiAdParams(ad, getPlayerPosition() - m.AdPositionOffset), getPlayerPosition())
'    end if
end sub

sub onAdClose(nodeEvent as object)
    eventData = nodeEvent.getData()
'    ad = eventData.ad
'    ' TODO: Currently Akamai only supports pre-rolls
'    if m.position = 0 and ad <> invalid then
'        m.Akamai.handleAdStopped(GetAkamaiAdParams(ad, getPlayerPosition() - m.AdPositionOffset), getPlayerPosition())
'    end if
end sub

function getPlayerPosition(includeAds = false as boolean) as integer
    if includeAds then
        return m.position + m.top.adPlaybackTime
    end if
    return m.position
end function

sub startPlayback(skipPreroll = false as boolean, resumePosition = 0 as integer, isAutoPlay = false as boolean, forced = false as boolean)
    if m.episode <> invalid then
        if m.episode.videoStream <> invalid and m.episode.videoStream.url <> "" then
            m.episode.resume = resumePosition > 0
            m.episode.resumePoint = resumePosition
            m.position = resumePosition
            m.adCount = 0
            m.adPodIndex = 1
            m.top.adPlaybackTime = 0
    
            m.global.analytics.dwParams = { method: "playerInit", params: [not isAutoPlay] }
            if m.episode.isLive then
                m.global.analytics.dwParams = { method: "playerLiveStart", params: [m.episode, getPlayerPosition()] }
            else
                m.global.analytics.dwParams = { method: "playerStart", params: [m.episode, getPlayerPosition(), 1, iif(isAutoPlay, iif(forced, "autoplay:endcard_click", "autoplay:endcard"), "")] }
            end if

            m.omnitureParams = {}
            m.omnitureParams["showEpisodeTitle"] = m.episode.title
            if m.episode.showName <> "" then
                m.omnitureParams["showEpisodeTitle"] = m.episode.showName + " - " + m.omnitureParams["showEpisodeTitle"]
            end if
            m.omnitureParams["showEpisodeId"] = m.episode.id
            if m.episode.subtype() = "Movie" then
                m.omnitureParams.v38 = "vod:movies"
            else if m.episode.isLive then
                m.omnitureParams.v38 = "live"
            else if m.episode.isFullEpisode then
                m.omnitureParams.v38 = "vod:fullepisodes"
            else
                m.omnitureParams.v38 = "vod:clips"
            end if
            m.omnitureParams.v36 = "false"
            m.omnitureParams.v46 = ""
            m.omnitureParams.pev2 = "video"
            m.omnitureParams.pev3 = "video"
    
            m.episode.skipPreroll = skipPreroll
    
            setVideoToFullScreen()

            ' the main.brs event loop is observing this change and will
            ' start the playback
            m.video.content = m.episode.videoStream
            
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
    
            'if m.episode.isFullEpisode then
                m.nextTask = createObject("roSGNode", "LoadNextEpisodeTask")
                m.nextTask.observeField("nextEpisode", "onNextEpisodeLoaded")
                m.nextTask.episode = m.episode
                m.nextTask.section = m.top.section
                m.nextTask.control = "run"
            'end if
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
        m.global.analytics.dwParams = { method: "playerLiveEnd", params: [m.episode, getPlayerPosition(true), getPlayerPosition()] }
        m.global.analytics.dwParams = { method: "playerLivePlayPosition", params: [m.episode, getPlayerPosition()] }
    else
        m.global.analytics.dwParams = { method: "playerEnd", params: [m.episode, getPlayerPosition(true), getPlayerPosition()] }
        m.global.analytics.dwParams = { method: "playerPlayPosition", params: [m.episode, getPlayerPosition()] }
    end if

    trackScreenAction("trackVideoComplete", m.omnitureParams, m.top.omnitureName, m.top.omniturePageType, ["event58"])

    if m.nextEpisode <> invalid then
        m.video.control = "stop"

        m.episode = m.nextEpisode
        m.top.content = m.episode
        m.nextEpisode = invalid
        startPlayback(true, 0, true, forced)

        return true
    end if
    return false
end function

sub updateEndCard()
    if not m.overrideEndCard then
        remaining = int(m.episode.endCreditsChapterEnd - m.video.position)
        if m.position >= m.episode.endCreditsChapterTime then
            if not m.endCard.visible then
                m.endCard.visible = true
                m.video.translation = [m.endCardButtons.translation[0] + 4, m.endCardButtons.translation[1] + 4]
                m.video.width = m.zoom.width - 8
                m.video.height = m.zoom.height - 8
                m.endCardButtons.setFocus(true)
                m.endCardButtons.jumpToIndex = 1
            end if
            if remaining > 0 then
                countdown = remaining.toStr() + " SECOND"
                if remaining <> 1 then
                    countdown = countdown + "S"
                end if
                m.countdown.text = countdown
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
    
    m.overrideEndCard = overrideEndCard
    m.endCard.visible = false
end sub

