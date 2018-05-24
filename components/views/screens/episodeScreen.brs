sub init()
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
    
    m.watch = m.top.findNode("watch")
    
    m.buttons = m.top.findNode("buttons")
    m.buttons.observeField("buttonSelected", "onButtonSelected")
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.buttons.setFocus(true)
    end if
end sub

sub onVisibleChanged()
    if m.top.visible then
        m.background.uri = m.heroImageUrl
        refreshEpisodeState()
    else
        m.heroImageUrl = m.background.uri
        m.background.uri = ""
    end if
end sub

sub onEpisodeIDChanged()
    m.global.showSpinner = true
    m.loadTask = createObject("roSGNode", "LoadEpisodeTask")
    m.loadTask.observeField("episode", "onEpisodeLoaded")
    m.loadTask.episodeID = m.top.episodeID
    m.loadTask.control = "run"
end sub

sub onEpisodeLoaded(nodeEvent as object)
    episode = nodeEvent.getData()
    m.top.episode = episode
    m.loadTask = invalid
end sub

sub refreshEpisodeState()
    if m.top.episode <> invalid then
        m.global.showSpinner = true
        m.refreshTask = createObject("roSGNode", "LoadEpisodeTask")
        m.refreshTask.observeField("episode", "onEpisodeRefreshed")
        m.refreshTask.episodeID = m.top.episode.id
        m.refreshTask.control = "run"
    end if
end sub

sub onEpisodeRefreshed(nodeEvent as object)
    ' We can't update the episode itself here, because it
    ' will trigger the itemSelected event in the appScene,
    ' as it registers as a change
    m.episode = nodeEvent.getData()
    m.top.episode = m.episode
    onEpisodeChanged()
    m.refreshTask = invalid
end sub

sub onEpisodeChanged()
    m.global.showSpinner = false
    episode = m.top.episode
    if episode <> invalid then
        if m.episode = invalid then
            ' We need to refresh the episode information
            refreshEpisodeState()
        else
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
            
            if episode.resumePoint > 0 then
                m.progressBar.visible = true
                m.progressBar.maxValue = episode.length
                m.progressBar.value = episode.resumePoint
            else
                m.progressBar.visible = false
            end if
            
            show = m.global.showCache[episode.showID]
            if show <> invalid then
                m.background.uri = getImageUrl(show.heroImageUrl, m.background.width)
            end if
            
            ' NOTE: We're checking the refreshed version of the episode here
            if canWatch(m.episode, m.global) then
                m.watch.text = "WATCH"
            else
                m.watch.text = "SUBSCRIBE TO WATCH"
            end if
            
            m.buttons.visible = true
            
            if m.top.autoPlay then
                m.top.buttonSelected = m.watch.id
                m.top.autoPlay = false
            end if
        end if
    else
        dialog = createCbsDialog("Content Unavailable", "The content you are trying to play is currently unavailable. Please try again later.", ["OK"])
        dialog.observeField("buttonSelected", "onUnavailableDialogClosed")
        m.global.dialog = dialog
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
