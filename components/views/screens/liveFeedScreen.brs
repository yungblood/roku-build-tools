sub init()
    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.background = m.top.findNode("background")
    m.poster = m.top.findNode("poster")
    m.showTitle = m.top.findNode("showTitle")
    m.episodeTitle = m.top.findNode("episodeTitle")
    m.episodeSubtitle = m.top.findNode("episodeSubtitle")
    m.episodeDescription = m.top.findNode("episodeDescription")
    
    m.watch = m.top.findNode("watch")
    m.showButton = m.top.findNode("show")
    
    m.buttons = m.top.findNode("buttons")
    m.buttons.observeField("buttonSelected", "onButtonSelected")
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.buttons.setFocus(true)
    end if
end sub

sub onLiveFeedChanged()
    liveFeed = m.top.liveFeed
    if liveFeed <> invalid then
        if m.updateTimer <> invalid then
            m.updateTimer.control = "stop"
            m.updateTimer.unobserveField("fire")
            m.updateTimer = invalid
        end if
        'm.poster.uri = liveFeed.thumbnailUrl

        m.showTitle.text = liveFeed.showName
        m.episodeTitle.text = liveFeed.title
        m.episodeDescription.text = liveFeed.description

        showID = liveFeed.showID
        if showID = "-1" then
            section = liveFeed.getParent()
            if section <> invalid then
                showID = section.showID
            end if
        end if
        show = m.global.showCache[showID]
        if show = invalid then
            m.buttons.removeChild(m.showButton)
        else
            m.background.uri = getImageUrl(show.heroImageUrl, m.background.width)
            m.showTitle.text = show.title
        end if
        
        if m.top.autoPlay then
            m.top.buttonSelected = m.watch.id
        end if
        
        if canWatch(liveFeed, m.global) then
            m.watch.text = "WATCH"
        else
            m.watch.text = "SUBSCRIBE TO WATCH"
        end if
        
        m.buttons.visible = true
        
        updatePoster()
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

sub updatePoster()
    liveFeed = m.top.liveFeed
    if liveFeed <> invalid and m.poster.width > 0 and m.poster.height > 0 then
        if m.updateTimer = invalid then
            m.updateTimer = createObject("roSGNode", "Timer")
            m.updateTimer.observeField("fire", "updatePoster")
            m.updateTimer.duration = 60
            m.updateTimer.repeat = true
            m.updateTimer.control = "start"
        end if
        uri = liveFeed.thumbnailUrl
        if uri.inStr("?") > -1 then
            uri = uri + "&"
        else
            uri = uri + "?"
        end if
        uri = uri + "cachebuster=" + createObject("roDateTime").asSeconds().toStr()
        ?"updatePoster: ";uri
        m.poster.uri = uri
    end if
end sub
