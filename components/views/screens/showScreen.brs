sub init()
    m.top.omniturePageType = "show"

    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.observeField("visible", "onVisibleChanged")
    
    m.heroImageUrl = ""
    m.heroDarkenImageUrl = ""
    m.hero = m.top.findNode("hero")
    m.hero.observeField("opacity", "onHeroOpacityChanged")

    m.heroDarken = m.top.findNode("heroDarken")
    m.heroFadeRect = m.top.findNode("heroFadeRect")
    m.menu = m.top.findNode("menu")
    
    m.dynamicPlay = m.top.findNode("dynamicPlay")
    m.dynamicPlay.observeField("contentLoaded", "onDynamicPlayLoaded")
    m.dynamicPlay.observeField("buttonSelected", "onButtonSelected")
    
    m.list = m.top.findNode("list")
    m.list.observeField("itemFocused", "onRowFocused")
    m.list.observeField("rowItemFocused", "onRowItemFocused")
    m.list.observeField("rowItemSelected", "onRowItemSelected")

    m.fadeOutAnimation = m.top.findNode("fadeOutAnimation")
    m.fadeInAnimation = m.top.findNode("fadeInAnimation")
    m.scrollAnimation = m.top.findNode("scrollAnimation")
    m.scrollInterp = m.top.findNode("scrollInterp")
    
    m.focusSeason = ""
    m.lastFocus = m.dynamicPlay
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.lastFocus.setFocus(true)
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        if key = "down" then
            if m.dynamicPlay.isInFocusChain() then
                m.list.setFocus(true)
                m.lastFocus = m.list
                scrollList()
            end if
            return true
        else if key = "up" then
            if m.list.isInFocusChain() then
                m.dynamicPlay.setFocus(true)
                m.lastFocus = m.dynamicPlay
                scrollList()
            end if
        end if
    end if
    return false
end function

sub onVisibleChanged()
    if m.top.visible then
        if m.show <> invalid then
            m.dynamicPlay.update = true
        end if
    end if
end sub

sub onShowChanged()
    if m.show = invalid or not m.show.isSameNode(m.top.show) then
        m.show = m.top.show
        if m.show <> invalid then
            pageName = "/shows/" + lCase(m.show.title)
            m.top.omnitureName = pageName
            trackScreenView()
    
            m.hero.uri = getImageUrl(m.show.heroImageUrl, m.hero.width)
            m.dynamicPlay.show = m.show

            rows = m.show.sections
            content = createObject("roSGNode", "ContentNode")
            
            focusRow = -1
            rowHeights = []
            rowItemSizes = []
            for i = 0 to rows.count() - 1
                row = rows[i]
                if row.subtype() = "Section" then
                    row.loadIndex = 0
                    rowItemSizes.push([420, 230])
                    rowHeights.push(298)
                end if
                content.appendChild(row)
                
                ' HACK: Find the row for the deep-linked episode
                if row.title = "Season " + m.focusSeason then
                    focusRow = i
                end if
            next
            ' Append the related shows row info to the end
            rowItemSizes.push([266, 400])
            rowHeights.push(452)
            
            m.list.rowItemSize = rowItemSizes
            m.list.rowHeights = rowHeights
            m.list.content = content
            
            if focusRow > -1 then
                m.list.jumpToItem = focusRow
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
        m.global.showSpinner = true
        m.loadTask = createObject("roSGNode", "ShowScreenTask")
        m.loadTask.observeField("content", "onContentLoaded")
        m.loadTask.showID = showID
        m.loadTask.control = "run"
    end if
end sub

sub onEpisodeIDChanged(nodeEvent as object)
    episodeID = nodeEvent.getData()
    if not isNullOrEmpty(episodeID) then
        m.global.showSpinner = true
        m.loadTask = createObject("roSGNode", "LoadEpisodeTask")
        m.loadTask.observeField("episode", "onEpisodeLoaded")
        m.loadTask.episodeID = episodeID
        m.loadTask.control = "run"
    end if
end sub

sub onEpisodeLoaded(nodeEvent as object)
    episode = nodeEvent.getData()
    if episode <> invalid then
        m.focusSeason = episode.seasonNumber
        m.top.showID = episode.showID
    else
        m.top.close = true
    end if
end sub

sub onContentChanged()
    m.global.showSpinner = true
    loadContent(m.top.content)
end sub

sub onContentLoaded(nodeEvent as object)
    content = nodeEvent.getData()
    m.top.content = nodeEvent.getData()
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
    m.global.showSpinner = false
end sub

sub scrollList(forceScroll = false as boolean)
    if forceScroll or m.list.isInFocusChain() then
        m.scrollInterp.keyValue = [m.list.translation, [0, 46]]
        if m.hero.visible then
            m.fadeOutAnimation.appendChild(m.scrollAnimation)
            m.fadeOutAnimation.control = "start"
        else
            m.scrollAnimation.control = "start"
        end if
    else if m.dynamicPlay.isInFocusChain() then
        m.scrollInterp.keyValue = [m.list.translation, [0, 867]]
        m.fadeInAnimation.appendChild(m.scrollAnimation)
        m.fadeInAnimation.control = "start"
    end if
end sub

sub onHeroOpacityChanged()
    m.hero.visible = (m.hero.opacity > 0)
end sub

sub onRowItemFocused(nodeEvent as object)
    indices = nodeEvent.getData()
    row = m.list.content.getChild(indices[0])
    if row <> invalid then
        row.loadIndex = indices[1]
    end if
end sub

sub onRowItemSelected(nodeEvent as object)
    indices = nodeEvent.getData()
    row = m.list.content.getChild(indices[0])
    if row <> invalid then
        index = indices[1]
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
            m.top.itemSelected = item
        end if
    end if
end sub

sub onButtonSelected(nodeEvent as object)
    row = nodeEvent.getRoSGNode()
    button = nodeEvent.getData()
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
            favorites = m.global.user.favorites
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

