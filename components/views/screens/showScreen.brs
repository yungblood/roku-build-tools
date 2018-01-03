sub init()
    m.top.omniturePageType = "show"

    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.observeField("visible", "onVisibleChanged")
    
    m.heroImageUrl = ""
    m.heroDarkenImageUrl = ""
    m.hero = m.top.findNode("hero")
    m.heroDarken = m.top.findNode("heroDarken")
    m.heroFadeRect = m.top.findNode("heroFadeRect")
    m.menu = m.top.findNode("menu")
    
    m.list = m.top.findNode("list")
    m.list.observeField("itemFocused", "onRowFocused")

    m.fadeOutAnimation = m.top.findNode("fadeOutAnimation")
    m.fadeInAnimation = m.top.findNode("fadeInAnimation")
    m.scrollAnimation = m.top.findNode("scrollAnimation")
    m.scrollInterp = m.top.findNode("scrollInterp")
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.list.setFocus(true)
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
    end if
    return false
end function

sub onVisibleChanged()
    if m.top.visible then
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

            row = m.list.createChild("ShowInfoRow")
            row.content = m.show
            row.observeField("itemSelected", "onItemSelected")
            row.observeField("buttonSelected", "onButtonSelected")
            row.observeField("visible", "updateRowLayout")

            rows = m.show.sections
            for i = 0 to rows.count() - 1
                row = invalid
                content = rows[i]
                if i < 5 then
                    content.loadIndex = 0
                end if
                row = m.list.createChild("EpisodesRow")
                if row <> invalid then
                    row.content = content
                    row.observeField("itemSelected", "onItemSelected")
                    row.observeField("buttonSelected", "onButtonSelected")
                    row.observeField("visible", "updateRowLayout")
                end if
            next
            updateRowLayout()
        else
           ' We don't have a valid show or a show with content, so close the screen
            m.top.close = true
        end if
    end if
    m.global.showSpinner = false
end sub

sub onShowIDChanged()
    m.global.showSpinner = true
    m.loadTask = createObject("roSGNode", "ShowScreenTask")
    m.loadTask.observeField("content", "onContentLoaded")
    m.loadTask.showID = m.top.showID
    m.loadTask.control = "run"
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
        
        ' Add the related shows row
        row = m.list.createChild("PostersRow")
        row.content = related
        row.observeField("itemSelected", "onItemSelected")
        row.observeField("buttonSelected", "onButtonSelected")
        row.observeField("visible", "updateRowLayout")
    
        updateRowLayout()
    end if
    m.loadTask = invalid
    m.global.showSpinner = false
end sub

sub updateRowLayout()
    offset = 0
    for i = 0 to m.list.getChildCount() - 1
        row = m.list.getChild(i)
        if row.visible then
            row.translation = [0, offset]
            offset = offset + row.rowHeight + 50
        end if
    next
end sub

sub onRowFocused()
    scrollToRow()
end sub

sub scrollToRow()
    for i = 0 to 4
        row = m.list.getChild(m.list.itemFocused + i)
        if row <> invalid and row.content <> invalid and row.content.subtype() = "Section" then
            row.content.loadIndex = 0
        end if
    next

    if m.list.itemFocused > 0 then
        row = m.list.getChild(m.list.itemFocused)
        if row <> invalid then
            rect = row.boundingRect()
            m.scrollInterp.keyValue = [m.list.translation, [0, 188 - rect.y]]
            if m.heroFadeRect.opacity = 0 then
                m.fadeOutAnimation.appendChild(m.scrollAnimation)
                m.fadeOutAnimation.control = "start"
            else
                m.scrollAnimation.control = "start"
            end if
        end if
    else
        m.scrollInterp.keyValue = [m.list.translation, [0, 482]]
        m.fadeInAnimation.appendChild(m.scrollAnimation)
        m.fadeInAnimation.control = "start"
    end if
end sub

sub onItemSelected(nodeEvent as object)
    row = nodeEvent.getRoSGNode()
    if row <> invalid then
        index = nodeEvent.getData()
        content = row.content
        if content.subtype() = "Show" then
            if content.dynamicPlayEpisode <> invalid then
                omnitureData = getOmnitureData(row, 0, lCase(content.dynamicPlayEpisode.title))
                m.top.omnitureData = omnitureData
                trackScreenAction("trackPodSelect", omnitureData)
                m.top.itemSelected = content.dynamicPlayEpisode.episode
            end if
        else
            item = content.getChild(index)
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
    end if
end sub

sub onButtonSelected(nodeEvent as object)
    row = nodeEvent.getRoSGNode()
    button = nodeEvent.getData()
    if button = "favorite" then
        favorites = m.global.user.favorites
        if isFavorite(m.top.showID, favorites) then
            trackScreenAction("trackMyCBSRemove", getOmnitureData(row, -1, "remove from mycbs"))
        else
            trackScreenAction("trackMyCBSAdd", getOmnitureData(row, -1, "add to mycbs"))
        end if
    else if button = "showInfo"
        trackScreenAction("trackPodSelect", getOmnitureData(row, -1, "more info", "overlay"))
    end if
    m.top.buttonSelected = button
end sub

