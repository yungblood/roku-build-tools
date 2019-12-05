sub init()
    m.top.omniturePageType = "show"

    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.observeField("visible", "onVisibleChanged")

    m.menu = m.top.findNode("menu")

    m.heroFadeRect = m.top.findNode("heroFadeRect")
    m.heroFadeRect.observeField("opacity", "onHeroOpacityChanged")
    m.heroFadeRect.color = getThemeColor("galaxy")
    
    m.dynamicPlay = m.top.findNode("dynamicPlay")
    m.dynamicPlay.observeField("contentLoaded", "onDynamicPlayLoaded")
    m.dynamicPlay.observeField("buttonSelected", "onButtonSelected")
    
    m.list = m.top.findNode("list")
    m.list.observeField("itemFocused", "onRowFocused")
    m.list.observeField("rowItemFocused", "onRowItemFocused")
    m.list.observeField("rowItemSelected", "onRowItemSelected")
    
    ' Used to hide the partial content load, in the event of a deep link into dynamic play
    m.loadMask = m.top.findNode("loadMask")
    m.loadMask.color = getThemeColor("galaxy")

    m.fadeOutAnimation = m.top.findNode("fadeOutAnimation")
    m.fadeInAnimation = m.top.findNode("fadeInAnimation")
    m.scrollAnimation = m.top.findNode("scrollAnimation")
    m.scrollInterp = m.top.findNode("scrollInterp")
    
    m.firstShow = true
    m.focusSeason = ""
    m.lastFocus = m.dynamicPlay
end sub

sub onFocusChanged(nodeEvent as object)
    if m.top.hasFocus() then
        m.lastFocus.setFocus(true)
        setGlobalField("ignoreBack", false)
    end if
    if m.list.hasFocus() and m.list.drawFocusFeeback <> true then
        m.list.drawFocusFeedback = true
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        if key = "down" and not isScrolling() then
            if m.dynamicPlay.isInFocusChain() then
                m.list.setFocus(true)
                m.list.jumpToRowItem = [0, 0]
                m.lastFocus = m.list
                scrollList()
            end if
            return true
        else if key = "up" and not isScrolling() then
            if m.list.isInFocusChain() then
                m.dynamicPlay.setFocus(true)
                m.lastFocus = m.dynamicPlay
                scrollList()
            end if
        else if key = "OK" then
            m.dynamicPlay.vilynxControl = "stop" 
        end if
    end if
    return false
end function

sub onVisibleChanged()
    if m.top.visible then
        if m.show <> invalid then
            m.dynamicPlay.autoplay = not m.top.autoplay
            m.dynamicPlay.update = true
        end if
        if m.firstShow then
            m.dynamicPlay.setFocus(true)
            scrollList()
            m.firstShow = false
        else
            m.loadMask.visible = false
        end if
    else
        m.dynamicPlay.vilynxControl = "stop"
    end if
end sub

sub onShowChanged()
    if m.show = invalid or not m.show.isSameNode(m.top.show) then
        m.show = m.top.show
        if m.show <> invalid then
            pageName = "/shows/" + lCase(m.show.title)
            m.top.omnitureName = pageName
            m.top.omnitureSiteHier = "shows|"+ lCase(m.show.categories.join(",")) + "|" + lCase(m.show.title) + "|"
            trackScreenView()
    
            m.dynamicPlay.autoplay = not m.top.autoplay
            m.dynamicPlay.show = m.show

            rows = m.show.sections
            content = createObject("roSGNode", "ContentNode")
            
            m.focusRow = -1
            rowTypes = []
            for i = 0 to rows.count() - 1
                row = rows[i]
                
                ' HACK: Find the row for the deep-linked episode
                if not isNullOrEmpty(m.focusSeason) and row.title = ("Season " + m.focusSeason) then
                    m.focusRow = i
                    ' assume the episode number matches the necessary load index
                    ' to ensure the correct page loads
                    row.loadIndex = m.focusEpisodeNumber
                    row.observeField("change", "onEpisodesLoaded")
                end if

                if row.subtype() = "Section" then
                    if i <= 2 then
                        row.loadIndex = 0
                    end if
                    rowTypes.push("landscape")
                end if
                content.appendChild(row)
            next
            ' Append the related shows row info to the end
            rowTypes.push("portrait")
            
            m.list.rowTypes = rowTypes
            m.list.content = content
            
            if m.focusRow > -1 then
                m.list.jumpToItem = m.focusRow
                m.lastFocus = m.list
                m.list.setFocus(true)
                scrollList(true)
            end if
        else
           ' We don't have a valid show or a show with content, so close the screen
            m.top.close = true
        end if
    end if
end sub

sub onShowIDChanged(nodeEvent as object)
    showID = nodeEvent.getData()
    if not isNullOrEmpty(showID) then
        showSpinner()
        m.loadTask = createObject("roSGNode", "ShowScreenTask")
        m.loadTask.observeField("content", "onContentLoaded")
        m.loadTask.showID = showID
        m.loadTask.control = "run"
    end if
end sub

sub onEpisodeIDChanged(nodeEvent as object)
    episodeID = nodeEvent.getData()
    if not isNullOrEmpty(episodeID) then
        showSpinner()
        m.loadTask = createObject("roSGNode", "LoadEpisodeTask")
        m.loadTask.observeField("episode", "onEpisodeLoaded")
        m.loadTask.episodeID = episodeID
        m.loadTask.control = "run"
    end if
end sub

sub onEpisodeLoaded(nodeEvent as object)
    episode = nodeEvent.getData()
    if episode <> invalid then
        ' If we're triggering dynamic play, then we don't want to set
        ' focus to the deep-linked episode ID
        if not m.top.triggerDynamicPlay then
            m.focusSeason = episode.seasonNumber
            m.focusEpisode = episode.id
            m.focusEpisodeNumber = asInteger(episode.episodeNumber)
        end if
        m.top.showID = episode.showID
    else
        m.top.close = true
    end if
end sub

sub onEpisodesLoaded(nodeEvent as object)
    if m.focusRow <> invalid and m.focusRow > -1 and not isNullOrEmpty(m.focusEpisode) then
        row = nodeEvent.getRoSGNode()
        for i = 0 to row.getChildCount() - 1
            episode = row.getChild(i)
            if episode <> invalid and episode.id = m.focusEpisode then
                row.unobserveField("change")
                m.focusEpisode = ""
                m.focusItem = i
                
                ' Delay the focus, so the row list has time to update
                m.focusTimer = createObject("roSGNode", "Timer")
                m.focusTimer.observeField("fire", "onFocusTimerFired")
                m.focusTimer.duration = .5
                m.focusTimer.control = "start"
                exit for
            end if
        next
    end if
end sub

sub onFocusTimerFired()
    m.focusTimer = invalid
    if m.focusRow <> invalid and m.focusItem <> invalid then
        ?"JUMPING TO: ", [m.focusRow, m.focusItem]
        m.list.jumpToRowItem = [m.focusRow, m.focusItem]
        if m.top.autoplay then
            m.top.autoplay = false
            row = m.list.content.getChild(m.focusRow)
            if row <> invalid then
                selectItem(row, m.focusItem)
            end if
        end if
    end if
end sub

sub onContentChanged()
    showSpinner()
    loadContent(m.top.content)
end sub

sub onContentLoaded(nodeEvent as object)
    content = nodeEvent.getData()
    task = nodeEvent.getRoSGNode()
    if not content.isEmpty() then
        m.top.content = nodeEvent.getData()
    else if task.errorCode > 0 then
        showApiError(true)
    else
        m.top.close = true
    end if
end sub

sub loadContent(content as object)
    m.show = invalid
    m.top.show = content.show
    shows = content.relatedShows
    if shows.count() > 0 then
        related = createObject("roSGNode", "ContentNode")
        related.title = "Related Shows"
        related.appendChildren(shows)
        m.list.content.appendChild(related)
    end if
    m.loadTask = invalid
end sub

sub onDynamicPlayLoaded()
    hideSpinner()
    m.loadMask.visible = false
    m.top.setFocus(true)
    if m.top.triggerDynamicPlay then
        m.top.triggerDynamicPlay = false
        processButtonSelection("dynamicPlay")
    end if
end sub

sub scrollList(forceScroll = false as boolean)
    if forceScroll or m.list.isInFocusChain() then
        m.list.peekVisible = true
        m.scrollInterp.keyValue = [m.list.translation, [0, 46]]
        if m.heroFadeRect.opacity = 0 then
            m.fadeOutAnimation.appendChild(m.scrollAnimation)
            m.fadeOutAnimation.control = "start"
        else
            m.scrollAnimation.control = "start"
        end if
    else if m.dynamicPlay.isInFocusChain() then
        m.list.peekVisible = false
        m.scrollInterp.keyValue = [m.list.translation, [0, 835]]
        m.fadeInAnimation.appendChild(m.scrollAnimation)
        m.fadeInAnimation.control = "start"
    end if
end sub

function isScrolling() as boolean
    return m.fadeOutAnimation.state = "running" or m.fadeInAnimation.state = "running"
end function

sub onHeroOpacityChanged(nodeEvent as object)
    opacity = nodeEvent.getData()
    if opacity = 1 then
        m.dynamicPlay.vilynxControl = "pause"
    else if opacity = 0 then
        m.dynamicPlay.vilynxControl = "resume"
    end if
end sub

sub onRowItemFocused(nodeEvent as object)
    indices = nodeEvent.getData()
    rowIndex = indices[0]
    itemIndex = indices[1]
    for i = 0 to 4
        row = m.list.content.getChild(rowIndex + i)
        if row <> invalid and row.hasField("loadIndex") then
            if i = 0 then
                row.loadIndex = itemIndex
            else
                row.loadIndex = row.itemFocused
            end if
        end if
    next
end sub

sub selectItem(row as object, index = 0 as integer)
    if row <> invalid then
        item = row.getChild(index)
        if item <> invalid then
            if item.subtype() = "RelatedShow" then
                omnitureData = getOmnitureData(row, index, lCase(item.title), "watch related shows")
                m.top.omnitureData = omnitureData
                trackScreenAction("trackPodSelect", omnitureData)
            else
                omnitureData = getOmnitureData(row, index, "more info", "overlay")
                m.top.omnitureData = omnitureData
                trackScreenAction("trackPodSelect", omnitureData)
            end if
            m.dynamicPlay.vilynxControl = "stop"
            m.top.itemSelected = item
        end if
    end if
end sub

sub onRowItemSelected(nodeEvent as object)
    indices = nodeEvent.getData()
    row = m.list.content.getChild(indices[0])
    if row <> invalid then
        index = indices[1]
        selectItem(row, index)
    end if
end sub

sub onButtonSelected(nodeEvent as object)
    row = nodeEvent.getRoSGNode()
    button = nodeEvent.getData()
    processButtonSelection(button, row)
end sub

sub processButtonSelection(button as string, row = invalid as object)
    if button = "dynamicPlay" then
        if m.dynamicPlay.episode <> invalid then
            omnitureData = getOmnitureData(m.show, 0, lCase(m.dynamicPlay.episode.title), "marquee|top")
            m.top.omnitureData = omnitureData

            additionalContext = m.top.additionalContext
            if additionalContext = invalid then
                additionalContext = {}
            end if
            additionalContext["mediaDynamicPlay"] = "true"
            additionalContext["mediaResume"] = "true"
            m.top.additionalContext = additionalContext
            
            trackScreenAction("trackDynamicPlay", omnitureData)
            m.top.itemSelected = m.dynamicPlay.episode
        end if
    else
        if button = "favorite" then
            user = getGlobalField("user")
            favorites = user.favorites
            if isFavorite(m.top.showID, favorites) then
                trackScreenAction("trackMyCBSRemove", getOmnitureData(row, -1, "remove from mycbs"))
            else
                trackScreenAction("trackMyCBSAdd", getOmnitureData(row, -1, "add to mycbs"))
            end if
        else if button = "showInfo" then
            trackScreenAction("trackPodSelect", getOmnitureData(m.show, -1, "more info", "overlay"))
        end if
        m.top.buttonSelected = button
    end if
end sub

