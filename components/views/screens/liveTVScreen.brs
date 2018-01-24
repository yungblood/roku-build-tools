sub init()
    m.top.observeField("focusedChild", "onFocusChanged")
    m.firstFocus = true
    
    ' HACK: Observing these as aliased fields to work around an issue with
    '       Conviva unobserving the fields out from under us
    m.top.observeField("position", "onPositionChanged")
    m.top.observeField("state", "onVideoStateChanged")

    m.video = m.top.findNode("video")

    m.overlay = m.top.findNode("overlay")
    m.darkenTop = m.top.findNode("darkenTop")
    m.channelOverlay = m.top.findNode("channelOverlay")
    m.channelGrid = m.top.findNode("channelGrid")
    m.channelGrid.observeField("itemFocused", "resetOverlayTimer")
    m.channelGrid.observeField("itemSelected", "onChannelSelected")

    stations = m.global.stations
    channels = m.global.liveTVChannels
    for i = 0 to channels.getChildCount() - 1
        channelItem = channels.getChild(i)
        if channelItem.id = "local" then
            if stations.count() > 1 then
                if m.global.station <> invalid and m.global.station <> "" then
                    for each station in stations
                        if station.id = m.global.station then
                            channelItem.title = station.station
                            channelItem.affiliate = station.affiliate
                            channelItem.scheduleUrl = station.scheduleUrl
                            exit for
                        end if
                    next
                end if
            else
                station = stations[0]
                if station <> invalid then
                    channelItem.affiliate = station.affiliate
                    channelItem.title = station.title
                    channelItem.affiliate = station.affiliate
                    channelItem.scheduleUrl = station.scheduleUrl
                end if
            end if
            exit for
        end if
    next
    m.channelGrid.content = channels
            
    m.scheduleOverlay = m.top.findNode("scheduleOverlay")
    m.scheduleGrid = m.top.findNode("scheduleGrid")
    m.scheduleGrid.observeField("itemFocused", "onScheduleItemFocused")
    m.scheduleGrid.observeField("itemSelected", "onScheduleItemSelected")
    
    m.scheduleDismiss = m.top.findNode("scheduleDismiss")

    m.scheduleDetails = m.top.findNode("scheduleDetails")
    m.scheduleShowTitle = m.top.findNode("scheduleShowTitle")
    m.scheduleEpisodeTitle = m.top.findNode("scheduleEpisodeTitle")
    m.scheduleDescription = m.top.findNode("scheduleDescription")
    
    m.nowPlayingOverlay = m.top.findNode("nowPlayingOverlay")
    m.showTitle = m.top.findNode("showTitle")
    m.episodeTitle = m.top.findNode("episodeTitle")
    m.stationLogo = m.top.findNode("stationLogo")
    
    m.menu = m.top.findNode("menu")
    m.menu.observeField("buttonSelected", "onMenuItemSelected")
    
    m.scheduleChannelName = m.top.findNode("scheduleChannelName")
    m.scheduleChannelLogo = m.top.findNode("scheduleChannelLogo")
    m.scheduleChannelLogo.observeField("bitmapWidth", "onLogoLoaded")
    m.scheduleChannelLogo.observeField("bitmapHeight", "onLogoLoaded")
    m.channelName = m.top.findNode("channelName")
    m.channelLogo = m.top.findNode("channelLogo")
    m.channelLogo.observeField("bitmapWidth", "onLogoLoaded")
    m.channelLogo.observeField("bitmapHeight", "onLogoLoaded")

    m.updateTimer = m.top.findNode("updateTimer")
    m.updateTimer.observeField("fire", "updateSchedule")
    m.overlayTimer = m.top.findNode("overlayTimer")
    m.overlayTimer.observeField("fire", "onOverlayTimerFired")
    m.timeoutTimer = m.top.findNode("timeoutTimer")
    m.timeoutTimer.observeField("fire", "onTimeoutTimerFired")
    
    m.liveTV = m.top.findNode("liveTV")
    m.liveTVSelection = m.top.findNode("liveTVSelection")
    m.stations = m.top.findNode("stations")
    m.stations.observeField("buttonSelected", "onStationSelected")
    m.unavailable = m.top.findNode("unavailable")

    m.position = 0
    m.initialPosition = -1
    m.timeOffset = 0
    m.timedOut = false
    m.scheduleReload = 12 ' 1 minute (timer fires every 5 seconds)
    m.firstLoad = true
    
    m.idleTimeout = asInteger(m.global.config.playback_timeout_live_tv, m.global.config.liveTimeout)

    m.top.observeField("visible", "onVisibleChanged")
end sub

sub onVisibleChanged()
    if m.top.visible then
        ' force a refresh
        m.station = invalid
        m.firstLoad = true
        m.menu.focusedID = "liveTV"
        if m.global.liveTVChannel = "local" then
            selectStation()
        else
            channels = m.global.liveTVChannels
            for i = 0 to channels.getChildCount() - 1
                channelItem = channels.getChild(i)
                if channelItem.id = m.global.liveTVChannel then
                    selectChannel(channelItem)
                    return
                end if
            next
            ' if we get this far, we couldn't find a matching channel,
            ' so play the local live stream
            selectStation()
        end if
    else
        m.video.control = "stop"
    end if
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        if m.firstFocus then
            showMenu(true)
            m.firstFocus = false
        else
            if m.liveTV.visible then
            else if m.liveTVSelection.visible then
                m.stations.setFocus(true)
            else
                showMenu(true)
                m.menu.setFocus(true)
            end if
        end if
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        resetOverlayTimer()
        if not m.liveTV.visible or m.overlay.visible then
            if key = "down" then
                if m.menu.isInFocusChain() then
                    if m.liveTV.visible then
                        if m.channelOverlay.visible then
                            hideMenu()
                            m.channelGrid.setFocus(true)
                        else if m.scheduleOverlay.visible then
                            m.scheduleGrid.setFocus(true)
                        end if
                    else if m.liveTVSelection.visible then
                        m.stations.setFocus(true)
                    end if
                    return true
                else if m.overlay.visible then
                    if m.scheduleOverlay.visible then
                        showNowPlaying()
                        return true
                    end if
                end if
            else if key = "back" then
                if m.overlay.visible then
                    if not m.channelOverlay.visible then
                        showOverlay(not m.scheduleDetails.visible)
                        return true
                    end if
                else
                    showOverlay(false)
                end if
            else if key = "up" then
                if m.nowPlayingOverlay.visible then
                    showOverlay(false)
                else
                    showMenu(true)
                end if
                return true
            end if
        else
            showNowPlaying()
            return true
        end if
    end if
    return false
end function

sub onScheduleItemFocused(nodeEvent as object)
    resetOverlayTimer()
    if m.scheduleGrid.content <> invalid then
        scheduleItem = m.scheduleGrid.content.getChild(nodeEvent.getData())
        if scheduleItem <> invalid then
            m.scheduleShowTitle.text = scheduleItem.title
            if not isNullOrEmpty(scheduleItem.title) and not isNullOrEmpty(scheduleItem.episodeTitle) then
                m.scheduleShowTitle.text = m.scheduleShowTitle.text + " | "
            end if
            m.scheduleEpisodeTitle.text = scheduleItem.episodeTitle
            m.scheduleDescription.text = scheduleItem.description
        end if
    end if
end sub

sub onScheduleItemSelected(nodeEvent as object)
    if m.scheduleDetails.visible then
        showOverlay(false, false)
    else
        showScheduleDetails()
    end if
end sub

sub onOverlayTimerFired()
    if m.video.state = "playing" then
        hideOverlay()
    end if
end sub

sub onMenuItemSelected(nodeEvent as object)
    menuItem = nodeEvent.getData()
    if menuItem <> "liveTV" then
        m.video.control = "stop"
    end if
    m.top.menuItemSelected = menuItem
end sub

sub selectChannel(channel as object)
    if m.channel = invalid or m.channel.id <> channel.id then
        if m.video.state <> "stopped" then
            m.video.control = "stop"
        end if

        if m.channel <> invalid then
            m.channel.isTuned = false
        end if
        m.channel = channel
        if m.channel.id = "local" then
            selectStation()
        else
            m.channel.isTuned = true
            playChannel(m.channel)
        end if

        m.global.liveTVChannel = m.channel.id
        m.regTask = createObject("roSGNode", "RegistryTask")
        m.regTask.key = "liveTVChannel"
        m.regTask.value = m.channel.id
        m.regTask.section = m.global.config.registrySection
        m.regTask.mode = "save"

    else if m.video.state <> "stopped" then
        showNowPlaying()
    end if
end sub

sub onStationChanged()
    if m.station = invalid or not m.station.isSameNode(m.top.station) then
        m.station = m.top.station
        playChannel(m.station)
    end if
end sub

sub playChannel(channel as object)
    m.video.control = "stop"
    if channel = invalid then
        channels = m.channelGrid.content
        for i = 0 to channels.getChildCount() - 1
            channelItem = channels.getChild(i)
            if channelItem.id = "local" then
                m.channel = channelItem
                channelItem.affiliate = invalid
                channelItem.isTuned = false
            end if
        next
        m.liveTV.visible = true
        showOverlay(true)
    else
        m.global.showSpinner = true
    
        m.idleTimeout = asInteger(m.global.config.playback_timeout_live_tv, m.global.config.liveTimeout)
    
        m.liveTV.visible = true
        m.liveTVSelection.visible = false
        m.unavailable.visible = false
        m.nowPlaying = invalid
        m.schedule = invalid
    
        m.scheduleChannelName.text = channel.title
        m.channelName.text = channel.title
        if channel.affiliate <> invalid then
            m.scheduleChannelLogo.uri = channel.affiliate.hdPosterUrl
            m.channelLogo.uri = channel.affiliate.hdPosterUrl
        else if channel.hdPosterUrl <> invalid then
            m.scheduleChannelLogo.uri = channel.hdPosterUrl
            m.channelLogo.uri = channel.hdPosterUrl
        end if
        
        if channel.subtype() <> "Station" and channel.id = "local" then
            channel = m.top.station
        end if
        m.channel = channel
        if channel.subtype() = "Station" or channel.subtype() = "LiveFeed" then
            channels = m.channelGrid.content
            for i = 0 to channels.getChildCount() - 1
                channelItem = channels.getChild(i)
                if channelItem.id = "local" then
                    m.channel = channelItem
                    if channel.subtype() = "LiveFeed" then
                        channelItem.title = ""
                        channelItem.affiliate = channel
                    else
                        affiliate = channel.affiliate
                        channelItem.title = channel.station
                        channelItem.affiliate = affiliate
                        channelItem.scheduleUrl = channel.scheduleUrl
                    end if
                    channelItem.isTuned = true
                else
                    channelItem.isTuned = false
                end if
            next
        end if
    
        m.streamTask = createObject("roSGNode", "LoadLiveStreamTask")
        m.streamTask.observeField("schedule", "onScheduleLoaded")
        m.streamTask.observeField("stream", "onStreamLoaded")
        m.streamTask.station = channel
        m.streamTask.control = "run"
    
        m.top.omnitureName = "/livetv"
        m.top.omniturePageType = "livetv_stream"
        trackScreenView()
    '
        m.heartbeatContext = {}
        m.omnitureParams = {}
        m.heartbeatContext["screenName"] = m.top.omnitureName
        if channel.subtype() = "LiveFeed" then
            m.heartbeatContext["showId"] = channel.showID
            m.omnitureParams["showEpisodeTitle"] = channel.title
            m.heartbeatContext["showEpisodeTitle"] = channel.title
            if channel.showName <> "" then
                m.omnitureParams["showEpisodeTitle"] = channel.showName + " - " + m.omnitureParams["showEpisodeTitle"]
                m.heartbeatContext["showEpisodeTitle"] = channel.showName + " - " + m.omnitureParams["showEpisodeTitle"]
            end if
            m.omnitureParams["showEpisodeId"] = channel.trackingContentId
            m.heartbeatContext["showEpisodeId"] = channel.trackingContentId
            m.omnitureParams.v38 = "live"
            m.heartbeatContext["mediaContentType"] = "live"
            m.omnitureParams.v36 = "false"
            m.omnitureParams.v46 = ""
            m.omnitureParams.v59 = iif(channel.subscriptionLevel = "FREE", "non-svod", "svod")
            m.heartbeatContext["mediaSvodContentType"] = iif(channel.subscriptionLevel = "FREE", "free", "pay")
            m.omnitureParams.pev2 = "video"
            m.omnitureParams.pev3 = "video"
        else
            m.heartbeatContext["showEpisodeTitle"] = channel.trackingTitle
            m.omnitureParams["showEpisodeTitle"] = channel.trackingTitle
            m.heartbeatContext["showEpisodeId"] = channel.trackingContentID
            m.omnitureParams.v24 = channel.trackingContentID
            m.heartbeatContext["showTitle"] = channel.omnitureTrackingTitle
            m.omnitureParams.v25 = channel.omnitureTrackingTitle
            m.heartbeatContext["mediaContentType"] = "live"
            m.omnitureParams.v38 = "live"
            m.omnitureParams.v46 = ""
            m.omnitureParams.pev2 = "video"
            m.omnitureParams.pev3 = "video"
        end if

        'trackScreenAction("trackVideoLoad", m.omnitureParams, m.top.omnitureName, m.top.omniturePageType, ["event52"])

        hideOverlay()
        loadSchedule()
    end if
end sub

sub onLogoLoaded(nodeEvent as object)
    logo = nodeEvent.getRoSGNode()
    if logo.bitmapWidth > 0 and logo.bitmapHeight > 0 then
        if logo <> invalid then
            logo.width = logo.bitmapWidth * (logo.height / logo.bitmapHeight)
        end if
    end if
end sub

sub onStreamLoaded(nodeEvent as object)
?"====== ON STREAM LOADED ======"
    if m.streamTask <> invalid then
        m.streamTask.unobserveField("schedule")
        m.streamTask.unobserveField("stream")
        m.streamTask = invalid
    end if

    stream = nodeEvent.getData()
    stream.station = m.station
    m.video.content = stream
    resetOverlayTimer(true)

    if m.channel.id <> "local" then
        m.station = m.channel
    end if
    sendDWAnalytics({method: "playerInit", params: [true, m.station.trackingContentID] })
    sendDWAnalytics({method: "playerLiveStart", params: [m.station, getPlayerPosition()] })

    trackVideoLoad(m.station, m.heartbeatContext)
    
    if m.global.comscore <> invalid then
        m.global.comscore.reset = true
        if not isNullOrEmpty(m.station.comscoreC2) then
            m.global.comscore.c2 = m.station.comscoreC2
        end if
        if not isNullOrEmpty(m.station.comscoreC3) then
            m.global.comscore.c3 = m.station.comscoreC3
        end if
        if not isNullOrEmpty(m.station.comscoreC4) then
            m.global.comscore.c4 = m.station.comscoreC4
        end if
        m.global.comscore.content = m.station
    end if

    startConviva()
    m.video.control = "play"

    trackVideoStart()
        
    m.global.showSpinner = false
    if not m.firstLoad then
        showNowPlaying()
    end if
    m.firstLoad = false
end sub

sub loadSchedule()
    m.scheduleTask = createObject("roSGNode", "LoadLiveScheduleTask")
    m.scheduleTask.observeField("schedule", "onScheduleLoaded")
    m.scheduleTask.scheduleUrl = m.channel.scheduleUrl
    m.scheduleTask.control = "run"
    m.scheduleReload = 12
end sub

sub onScheduleLoaded(nodeEvent as object)
    m.scheduleTask = invalid

    schedule = nodeEvent.getData()
    if schedule = invalid or schedule.count() = 0 then
        unavailable = createObject("roSGNode", "ContentNode")
        unavailable.title = "Schedule"
        unavailable.addField("episodeTitle", "string", false)
        unavailable.episodeTitle = "Unavailable At This Time"
        schedule = []
        schedule.push(unavailable)
    end if
    
    m.schedule = createObject("roSGNode", "ContentNode")
    m.schedule.appendChildren(schedule)
    updateSchedule()
    
    m.scheduleGrid.content = m.schedule
    
    m.updateTimer.control = "start"
end sub

sub onVideoStateChanged(nodeEvent as object)
    state = nodeEvent.getData()
    m.global.showSpinner = (state = "buffering")
    if state = "playing" then
        if m.global.comscore <> invalid then
            m.global.comscore.videoStart = true
        end if
        trackVideoPlay()
    else if state = "finished" then
        sendDWAnalytics({method: "playerLiveEnd", params: [m.station, getPlayerPosition(), getPlayerPosition()] })
        if m.global.comscore <> invalid then
            m.global.comscore.videoEnd = true
        end if
        stopConviva()
        trackVideoComplete()
        trackVideoUnload()
    else if state = "stopped" then
        if m.station <> invalid then
            if m.timedOut then
                sendDWAnalytics({method: "playerLiveForcedEnd", params: ["forcedend", m.station, getPlayerPosition(), getPlayerPosition()] })
            else
                sendDWAnalytics({method: "playerLiveStop", params: [m.station, getPlayerPosition(), getPlayerPosition()] })
            end if
            if m.global.comscore <> invalid then
                m.global.comscore.videoEnd = true
            end if
            stopConviva()
            trackVideoComplete()
            trackVideoUnload()
        end if
    else if state = "error" then
        sendDWAnalytics({method: "playerLiveError", params: [m.video.errorMsg, m.station, getPlayerPosition(), getPlayerPosition()] })
        if m.global.comscore <> invalid then
            m.global.comscore.videoEnd = true
        end if
        stopConviva()
        trackVideoComplete()
        trackVideoUnload()

        error = "Unfortunately, an error occurred during playback."
        ' Check for a network connection error
        if not createObject("roDeviceInfo").getLinkStatus() then
            error = error + " Please check your network connection and try again."
        else
            error = error + " Please try again."
        end if
        dialog = createCbsDialog("Error", error, ["OK"])
        dialog.observeField("buttonSelected", "onErrorDialogClose")
        m.global.dialog = dialog
    end if
end sub

sub onErrorDialogClose(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    if dialog <> invalid then
        dialog.close = true
    end if
    m.video.control = "stop"
    showOverlay()
end sub

sub onPositionChanged()
    if m.initialPosition = -1 then
        m.initialPosition = m.video.position
    end if
    m.position = m.video.position - m.initialPosition
    sendDWAnalytics({method: "playerLivePlay", params: [m.station, getPlayerPosition(), getPlayerPosition()] })
    
    if m.position > 0 then
        if m.position mod 10 = 0 then
            sendDWAnalytics({method: "playerLivePlayPosition", params: [m.station, getPlayerPosition()] })
        end if
        if m.position mod 60 = 0 then
'            trackScreenAction("trackVideo", m.omnitureParams, m.top.omnitureName, m.top.omniturePageType, ["event57=60"])
        end if
        trackVideoPlayhead(m.position)
    end if
    
    idleTime = createObject("roDeviceInfo").timeSinceLastKeyPress()
    if idleTime >= m.idleTimeout and m.stillWatchingDialog = invalid then
        m.stillWatchingDialog = createCbsDialog("", "Are you still watching?", ["Continue watching"])
        m.stillWatchingDialog.observeField("buttonSelected", "onTimeoutDialogClosed")
        m.global.dialog = m.stillWatchingDialog
        
        m.timeoutTimer.control = "start"
    end if
end sub

sub onTimeoutDialogClosed(nodeEvent as object)
    m.timeoutTimer.control = "stop"
    dialog = nodeEvent.getRoSGNode()
    dialog.close = true
    m.stillWatchingDialog = invalid

    sendDWAnalytics({method: "playerLiveForcedEnd", params: ["resume", m.station, getPlayerPosition(), getPlayerPosition()] })
    m.video.control = "resume"
end sub

sub onTimeoutTimerFired()
    m.timedOut = true
    m.video.control = "stop"
    m.stillWatchingDialog.close = true
    m.stillWatchingDialog = invalid
    showOverlay()
end sub

function getPlayerPosition() as integer
    return m.position
end function

sub selectStation()
    stations = m.global.stations
    if stations.count() = 0 then
        m.unavailable.visible = true
       
        m.top.omnitureName = "/livetv/check availability"
        m.top.omniturePageType = "livetv_unavailable"
        trackScreenView()
        
        m.top.station = invalid
    else if stations.count() = 1 then
        m.top.station = stations[0]
        m.liveTV.visible = true
    else
        if m.global.station <> invalid and m.global.station <> "" then
            for each station in stations
                if station.id = m.global.station then
                    m.top.station = station
                    m.liveTV.visible = true
                    return
                end if
            next
        end if
        m.stations.removeChildrenIndex(m.stations.getChildCount(), 0)
        for i = 0 to stations.count() - 1
            button = m.stations.createChild("LiveTVButton")
            button.station = stations[i]
            button.processKeyEvents = false
        next
        m.liveTVSelection.visible = true
       
        m.top.omnitureName = "livetv/provider/select"
        m.top.omniturePageType = "provider_select"
        trackScreenView()
    end if
end sub

sub onChannelSelected(nodeEvent as object)
    resetOverlayTimer()
    channels = m.channelGrid.content
    channel = channels.getChild(nodeEvent.getData())
    if channel <> invalid then
        selectChannel(channel)
    end if
end sub

sub onStationSelected(nodeEvent as object)
    button = m.stations.getChild(nodeEvent.getData())
    if button <> invalid then
        m.top.station = button.station

        m.global.station = button.station.id
        m.regTask = createObject("roSGNode", "RegistryTask")
        m.regTask.key = "liveTV"
        m.regTask.value = button.station.id
        m.regTask.section = m.global.config.registrySection
        m.regTask.mode = "save"
    end if
    m.channelGrid.setFocus(true)
end sub

sub hideOverlay()
    if m.overlay.isInFocusChain() or m.nowPlayingOverlay.visible then
        m.overlay.visible = false
        hideMenu()
        m.video.setFocus(true)
    end if
end sub

sub showOverlay(showChannels = false as boolean, resetIndex = true as boolean)
    m.scheduleOverlay.visible = not showChannels
    m.scheduleOverlay.translation = [0, 645]
    m.scheduleDetails.visible = false
    m.scheduleDismiss.visible = true
    m.channelOverlay.visible = showChannels
    m.nowPlayingOverlay.visible = false
    m.overlay.visible = true

    if showChannels then
        m.channelGrid.setFocus(true)
    else
        if resetIndex then
            m.scheduleGrid.jumpToItem = 0
        end if
        m.scheduleGrid.setFocus(true)
    end if
end sub

sub showMenu(focus = false as boolean)
    m.darkenTop.visible = true
    m.menu.visible = true
    if focus then
        m.menu.setFocus(true)
    end if
end sub

sub hideMenu()
    m.darkenTop.visible = false
    m.menu.visible = false
end sub

sub showChannelSelection()
    showOverlay(true)
end sub

sub showNowPlaying()
    updateNowPlaying()

    m.scheduleOverlay.visible = false
    m.channelOverlay.visible = false
    m.nowPlayingOverlay.visible = true
    m.overlay.visible = true
end sub

sub showScheduleDetails()
    resetOverlayTimer()
    m.scheduleOverlay.visible = true
    m.scheduleOverlay.translation = [0, 485]
    m.scheduleDetails.visible = true
    m.scheduleDismiss.visible = false
end sub

sub resetOverlayTimer(force = false as boolean)
    m.overlayTimer.control = "stop"
    if force or m.video.state = "playing" or m.video.state = "buffering" then
        m.overlayTimer.control = "start"
    end if
end sub

sub updateSchedule()
    nowTime = createObject("roDateTime").asSeconds() + m.timeOffset
 
    scheduleUpdated = false
    if m.schedule <> invalid and (m.nowPlaying = invalid or (m.nowPlaying.subtype() = "Program" and m.nowPlaying.endTime <= nowTime)) then
        program = m.schedule.getChild(0)
        if program.subtype() = "Program" then
            while m.schedule.getChildCount() > 0 and program.endTime <= nowTime and program.endTime > 0
                m.schedule.removeChild(program)
                program = m.schedule.getChild(0)
                scheduleUpdated = true
            end while
        end if

        m.nowPlaying = m.schedule.getChild(0)
        if m.nowPlaying <> invalid then
            m.nowPlaying.isLive = true
        end if
        m.upNext = m.schedule.getChild(1)
        if m.upNext <> invalid then
            m.upNext.isNext = true
        end if
        
        updateNowPlaying()
        
        if m.nowPlaying.endTime = 0 then
            m.scheduleReload--
        end if
        if m.scheduleReload = 0 then
            loadSchedule()
        end if
    end if
end sub

sub updateNowPlaying()
    nowPlaying = m.nowPlaying
    if nowPlaying <> invalid then
        m.showTitle.text = nowPlaying.title
        if not isNullOrEmpty(nowPlaying.title) and not isNullOrEmpty(nowPlaying.episodeTitle) then
            m.showTitle.text = m.showTitle.text + " | "
        end if
        m.episodeTitle.text = nowPlaying.episodeTitle
    else
        if m.schedule = invalid then
            m.showTitle.text = ""
            m.episodeTitle.text = ""
        else
            m.showTitle.text = "Schedule is unavailable at this time."
            m.episodeTitle.text = ""
        end if
    end if
end sub

sub startConviva()
    stopConviva()
    m.convivaTask = createObject("roSGNode", "ConvivaTask")
    m.convivaTask.video = m.video
    m.convivaTask.content = m.station
    m.convivaTask.control = "run"
end sub

sub stopConviva()
    if m.convivaTask <> invalid then
        m.convivaTask.cancel = true
        m.convivaTask = invalid
    end if
end sub
