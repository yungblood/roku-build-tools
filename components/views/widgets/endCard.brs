sub init()
    m.top.observeField("focusedChild", "onFocusChanged")

    m.background = m.top.findNode("background")
    m.autoplayZoom = m.top.findNode("autoplayZoom")
    m.upNext = m.top.findNode("upNext")
    m.countdown = m.top.findNode("countdown")
    m.upNextShowName = m.top.findNode("upNextShowName")
    m.upNextEpisodeNumber = m.top.findNode("upNextEpisodeNumber")
    m.upNextEpisodeName = m.top.findNode("upNextEpisodeName")
    
    m.autoplay = m.top.findNode("autoplay")
    m.autoplayButtons = m.top.findNode("autoplayButtons")
    m.autoplayButtons.observeField("buttonSelected", "onButtonSelected")

    m.selector = m.top.findNode("selector")
    m.selectorZoom = m.top.findNode("selectorZoom")
    m.selectorZoom.observeField("buttonSelected", "onSelectorZoomButtonSelected")
    m.selectorButtons = m.top.findNode("selectorButtons")
    m.selectorButtons.observeField("buttonFocused", "onSelectorButtonFocused")
    m.selectorButtons.observeField("buttonSelected", "onSelectorButtonSelected")
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        if m.autoplay.visible then
            m.autoplayButtons.jumpToIndex = 1
            m.autoplayButtons.setFocus(true)
        else if m.selector.visible then
            m.selectorButtons.jumpToIndex = 0
            m.selectorButtons.setFocus(true)
        end if
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        if key = "left" then
            if m.selector.visible then
                if m.selectorButtons.isInFocusChain() then
                    m.selectorZoom.setFocus(true)
                    return true
                end if
            end if
        else if key = "right" then
            if m.selector.visible then
                if m.selectorZoom.isInFocusChain() then
                    m.selectorButtons.setFocus(true)
                    return true
                end if
            end if
        else if key = "back" then
            if m.selector.visible then
                m.top.buttonSelected = m.selectorZoom
                return true
            end if
        end if
    end if
    return false
end function

sub onContinuousPlayInfoChanged(nodeEvent as object)
    omnitureParams = {}
    m.top.buttonFocused = invalid
    cpInfo = nodeEvent.getData()
    if cpInfo.episode <> invalid then
        episode = cpInfo.episode
        if episode <> invalid then
            omnitureParams["eventEndCardView"] = "1"
            omnitureParams["endCardType"] = "single"
            omnitureParams["endCardContentList"] = episode.title
            if canWatch(episode, m.top) then
                m.selector.visible = false
                m.autoplay.visible = true
                viewport = {}
                viewport.x = m.autoplayButtons.translation[0] + 4
                viewport.y = m.autoplayButtons.translation[1] + 4
                viewport.width = m.autoplayZoom.width - 8
                viewport.height = m.autoplayZoom.height - 8
                m.top.viewport = viewport
    
                show = getShowFromCache(episode.showID)
                if show <> invalid then
                    m.background.uri = getImageUrl(show.heroImageUrl, m.background.width)
                else
                    m.background.uri = ""
                end if
                m.upNext.backgroundUri = getImageUrl(episode.thumbnailUrl, m.upNext.width)
                m.upNext.focusedBackgroundUri = getImageUrl(episode.thumbnailUrl, m.upNext.width)
                m.upNextShowName.text = episode.showName
                
                upNextEpisodeNumber = (episode.seasonString + " " + episode.episodeString).trim()
                if not isNullOrEmpty(upNextEpisodeNumber) then
                    upNextEpisodeNumber = upNextEpisodeNumber + " | "
                end if
                m.upNextEpisodeNumber.text = upNextEpisodeNumber + episode.durationString
                m.upNextEpisodeName.text = episode.title
            else
                m.selector.visible = true
                m.autoplay.visible = false
        
                viewport = {}
                viewport.x = m.selectorZoom.translation[0] + 4
                viewport.y = m.selectorZoom.translation[1] + 4
                viewport.width = m.selectorZoom.width - 8
                viewport.height = m.selectorZoom.height - 8
                m.top.viewport = viewport

                m.selectorButtons.removeChildrenIndex(m.selectorButtons.getChildCount(), 0)
                button = m.selectorButtons.createChild("RecommendationTile")
                button.itemContent = episode
            end if
        end if
    else if cpInfo.videos.count() > 0 then
        m.selector.visible = true
        m.autoplay.visible = false

        viewport = {}
        viewport.x = m.selectorZoom.translation[0] + 4
        viewport.y = m.selectorZoom.translation[1] + 4
        viewport.width = m.selectorZoom.width - 8
        viewport.height = m.selectorZoom.height - 8
        m.top.viewport = viewport

        contentList = ""
        m.selectorButtons.removeChildrenIndex(m.selectorButtons.getChildCount(), 0)
        for i = 0 to cpInfo.videos.count()
            video = cpInfo.videos[i]
            if video <> invalid then
                button = m.selectorButtons.createChild("RecommendationTile")
                button.itemContent = video
                button.index = i
            end if
            if not isNullOrEmpty(contentList) then
                contentList = contentList + "|"
            end if
            'ticket hotfix for if endcard videos is empty
            'cropped up when recommended/episodes for late late show with james corden were removed
            if video <> invalid then
                contentList = contentList + video.title
            end if
            
            ' We shouldn't display more than 3 recommendations
            if m.selectorButtons.getChildCount() >= 3 then
                exit for
            end if
        next

        omnitureParams["eventEndCardView"] = "1"
        omnitureParams["endCardType"] = "multi"
        omnitureParams["endCardContentList"] = contentList
    end if
    m.top.omnitureParams = omnitureParams
end sub

sub onCountdownChanged()
    countdown = m.top.countdown.toStr() + " SECOND"
    if m.top.countdown <> 1 then
        countdown = countdown + "S"
    end if
    m.countdown.text = countdown
    
    for i = 0 to m.selectorButtons.getChildCount() - 1
        button = m.selectorButtons.getChild(i)
        if button <> invalid then
            button.countdown = m.top.countdown
        end if
    next
end sub

sub onButtonSelected(nodeEvent as object)
    button = m.autoplayButtons.getChild(nodeEvent.getData())
    if button <> invalid then
        m.top.buttonSelected = button
    end if
end sub

sub onSelectorButtonFocused(nodeEvent as object)
    button = m.selectorButtons.getChild(nodeEvent.getData())
    if button <> invalid then
        m.top.buttonFocused = button
        content = button.itemContent
        if content.subtype() = "Episode" then
            show = getShowFromCache(content.showID)
            if show <> invalid then
                m.background.uri = getImageUrl(show.heroImageUrl, m.background.width)
            else
                m.background.uri = ""
            end if
        else
            m.background.uri = getImageUrl(content.backgroundUrl, m.background.width)
        end if
    end if
end sub

sub onSelectorButtonSelected(nodeEvent as object)
    button = m.selectorButtons.getChild(nodeEvent.getData())
    if button <> invalid then
        m.top.buttonSelected = button
    end if
end sub

sub onSelectorZoomButtonSelected(nodeEvent as object)
    button = nodeEvent.getRoSGNode()
    if button <> invalid then
        m.top.buttonSelected = button
    end if
end sub

