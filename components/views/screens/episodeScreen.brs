sub init()
    m.top.omniturePageType = "video_details"
    
    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.observeField("visible", "onVisibleChanged")
    
    m.heroImageUrl = ""

    m.background = m.top.findNode("background")
    m.poster = m.top.findNode("poster")
    m.showTitle = m.top.findNode("showTitle")
    m.episodeTitle = m.top.findNode("episodeTitle")
    m.episodeSubtitle = m.top.findNode("episodeSubtitle")
    m.episodeDescription = m.top.findNode("episodeDescription")
    m.progressBar = m.top.findNode("progressBar")
    
    m.resume = m.top.findNode("resume")
    m.watch = m.top.findNode("watch")
    
    m.buttons = m.top.findNode("buttons")
    m.buttons.observeField("buttonSelected", "onButtonSelected")

    m.tts = createObject("roTextToSpeech")
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.buttons.setFocus(true)
        setGlobalField("ignoreBack",false)
    end if
end sub

sub onVisibleChanged()
    if m.top.visible then
        m.background.uri = m.heroImageUrl
    else
        ' unload the background image to free up some memory
        ' before playback
        m.heroImageUrl = m.background.uri
        m.background.uri = ""
    end if
end sub

sub onShowIDChanged(nodeEvent as object)
    showID = nodeEvent.getData()
    if not isNullOrEmpty(showID) then
        showSpinner()
        m.loadTask = createObject("roSGNode", "LoadDynamicPlayEpisodeTask")
        m.loadTask.observeField("episode", "onEpisodeLoaded")
        ' Enable fallback, in case there is no dynamic play episode for this show
        m.loadTask.enableFallback = true
        m.loadTask.showID = showID
        m.loadTask.control = "run"
    end if
end sub

sub onEpisodeIDChanged(nodeEvent as object)
    episodeID = nodeEvent.getData()
    if not isNullOrEmpty(episodeID) then
        loadEpisode(episodeID)
    end if
end sub

sub onEpisodeLoaded(nodeEvent as object)
    task = nodeEvent.getRoSGNode()
    episode = nodeEvent.getData()
    if episode <> invalid then
        if episode.subtype() = "DynamicPlayEpisode" then
            episode = episode.episode
        end if
        m.top.episode = episode
    else if task.hasField("errorCode") and task.errorCode > 0 then
        showApiError(true)
    else
        m.top.close = true
    end if
    m.loadTask = invalid
end sub

sub onEpisodeChanged(nodeEvent as object)
    hideSpinner()
    episode = nodeEvent.getData()
    if episode <> invalid then
        pageName = "/shows/" + lCase(episode.showName) + "/video-details/" + lCase(episode.title)
        m.top.omnitureName = pageName
        trackScreenView()

        m.showTitle.text = episode.showName
        m.episodeTitle.text = episode.title
        m.episodeDescription.text = episode.description

        subtitle = (episode.seasonString + " " + episode.episodeString).trim()
        if not isNullOrEmpty(subtitle) then
            subtitle = subtitle + " | "
        end if
        subtitle = subtitle + episode.durationString + " | " + episode.rating
        subtitle = subtitle + " | " + episode.airDateString
        m.episodeSubtitle.text = subtitle
        m.poster.uri = getImageUrl(episode.thumbnailUrl, m.poster.width)

        ' if watch history exists leave progress bar at 100%
        if episode.resumePoint > 0 then
            m.progressBar.maxValue = episode.length
            m.progressBar.value = episode.resumePoint
            if m.progressBar.value / m.progressBar.maxValue > .97 then
                m.progressBar.value = m.progressBar.maxValue
            end if
            if m.progressBar.value / m.progressBar.maxValue > .05 then
                m.progressBar.visible = true
            else
                m.progressBar.visible = false
            end if
        else
            m.progressBar.visible = false
        end if

        show = getShowFromCache(episode.showID)
        if show <> invalid then
            m.background.uri = getImageUrl(show.heroImageUrl, m.background.width)
        end if
        
        if canWatch(episode, m.top) then
            if episode.resumePoint > 0 and (episode.resumePoint < episode.length * .97) then
                m.watch.text = "RESTART"
                m.buttons.insertChild(m.resume, 0)
            else
                m.watch.text = "WATCH"
                m.buttons.removeChild(m.resume)
            end if
        else
            m.watch.text = "SUBSCRIBE"
            m.buttons.removeChild(m.resume)
        end if

        m.buttons.visible = true
        m.buttons.setFocus(false)
        m.buttons.setFocus(true)
        
        if m.top.autoPlay then
            m.top.buttonSelected = "autoplay"
            m.top.autoPlay = false
        else
            if createObject("roDeviceInfo").isAudioGuideEnabled() then
                m.tts.say(m.showTitle.text)
                m.tts.say(m.episodeTitle.text)
                m.tts.say(m.episodeSubtitle.text)
                m.tts.say(m.episodeDescription.text)
            end if
        end if
    else
        dialog = createCbsDialog("Content Unavailable", "The content you are trying to play is currently unavailable. Please try again later.", ["OK"])
        dialog.observeField("buttonSelected", "onUnavailableDialogClosed")
        setGlobalField("cbsDialog", dialog)
    end if
end sub

sub onUnavailableDialogClosed(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    if dialog <> invalid then
        dialog.close = true
    end if
    m.top.close = true
end sub

sub onButtonSelected(nodeEvent as object)
    button = m.buttons.getChild(m.buttons.buttonSelected)
    if button <> invalid then
        omnitureData = m.top.omnitureData
        if omnitureData = invalid then
            omnitureData = {}
        end if
        omnitureData["podText"] = lCase(button.text)
        omnitureData["podType"] = "grid_moreinfo"
        trackScreenAction("trackPodSelect", omnitureData)
        m.top.buttonSelected = button.id
    end if
end sub

sub loadEpisode(episodeID as string)
    showSpinner()
    m.loadTask = createObject("roSGNode", "LoadEpisodeTask")
    m.loadTask.observeField("episode", "onEpisodeLoaded")
    m.loadTask.episodeID = episodeID
    m.loadTask.control = "run"
end sub
