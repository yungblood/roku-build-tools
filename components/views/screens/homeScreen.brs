sub init()
    m.top.omnitureName = "/"
    m.top.omniturePageType = "front_door"

    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.observeField("visible", "onVisibleChanged")
    
    m.marquee = m.top.findNode("marquee")
    m.marquee.observeField("itemSelected", "onItemSelected")
    m.marquee.observeField("opacity", "onMarqueeOpacityChanged")

    m.marqueeTimer = m.top.findNode("marqueeTimer")
    m.marqueeTimer.observeField("fire", "onMarqueeTimerFired")
    
    m.menu = m.top.findNode("menu")
    m.menu.observeField("buttonSelected", "onMenuItemSelected")
    
    m.list = m.top.findNode("list")
    m.list.observeField("itemFocused", "onRowFocused")
    m.list.observeField("rowItemFocused", "onRowItemFocused")
    m.list.observeField("rowItemSelected", "onRowItemSelected")

    m.global.showSpinner = true

    m.fadeOutAnimation = m.top.findNode("fadeOutAnimation")
    m.fadeInAnimation = m.top.findNode("fadeInAnimation")
    m.scrollAnimation = m.top.findNode("scrollAnimation")
    m.scrollInterp = m.top.findNode("scrollInterp")
    
    m.lastFocus = m.marquee
    
    m.concurrentRowLoads = 3
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.lastFocus.setFocus(true)
    end if
end sub

sub onVisibleChanged()
    if m.top.visible then
        m.marqueeTimer.control = "start"
        m.marquee.visible = true
        if m.top.content = invalid then
            m.global.showSpinner = true
            m.contentTask = createObject("roSGNode", "HomeScreenTask")
            m.contentTask.observeField("content", "onContentLoaded")
            m.contentTask.control = "run"
        end if
    else
        m.marqueeTimer.control = "stop"
        m.marquee.visible = false
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    ?"HomeScreen.onKeyEvent: ";key,press
    if press then
        if key = "down" then
            if m.menu.isInFocusChain() then
                m.marquee.setFocus(true)
                m.lastFocus = m.marquee
                return true
            else if m.marquee.isInFocusChain() then
                m.list.setFocus(true)
                m.lastFocus = m.list
                scrollList()
                'scrollToRow(true)
                return true
            end if
        else if key = "up" then
            if m.marquee.isInFocusChain() then
                m.menu.setFocus(true)
                m.lastFocus = m.menu
                return true
            else if m.list.isInFocusChain() then
                m.marquee.setFocus(true)
                m.lastFocus = m.marquee
                scrollList()
                'scrollToRow()
                return true
            end if
        end if
    end if
    return false
end function

sub loadContent(content as object)
    m.marquee.content = content.marquee
    m.marquee.visible = true
    m.marqueeTimer.control = "start"

    rows = content.rows
    content = createObject("roSGNode", "ContentNode")
    
    rowHeights = []
    rowItemSizes = []
    for i = 0 to rows.count() - 1
        row = rows[i]
        if row.subtype() = "Section" then
            row.loadIndex = 0
            if row.title.inStr("Movies") >= 0 then
                rowItemSizes.push([409, 614])
                rowHeights.push(682)
            else
                rowItemSizes.push([409, 230])
                rowHeights.push(298)
            end if
        else
            rowItemSizes.push([409, 230])
            rowHeights.push(298)
        end if
        content.appendChild(row)
    next
    m.list.rowItemSize = rowItemSizes
    m.list.rowHeights = rowHeights
    m.list.content = content

'
'timer = createObject("roTimespan")    
'    for i = 0 to rows.count() - 1
'        row = invalid
'        content = rows[i]
'        contentType = content.subtype()
'        if contentType = "Section" then
'            if content.title.inStr("Movies") >= 0 then
'                row = m.list.createChild("PostersRow")
'            else
'                if content.excludeShow then
'                    row = m.list.createChild("FeaturedRow")
'                else
'                    row = m.list.createChild("EpisodesRow")
'                end if
'            end if
'        else if contentType = "Favorites" then
'            row = m.list.createChild("FavoritesRow")
'        else if contentType = "RecentlyWatched" then
'            row = m.list.createChild("RecentlyWatchedRow")
'        else if contentType = "Show" then
'            row = m.list.createChild("ShowInfoRow")
'        else
'            ?"Unrecognized content type: ";contentType
'        end if
'        if row <> invalid then
'            if content.subtype() = "Section" and i <= m.concurrentRowLoads then
'                content.loadIndex = 0
'            end if
'            row.content = content
'            row.observeField("itemSelected", "onItemSelected")
'            row.observeField("visible", "updateRowLayout")
'        end if
'    next
'?"Rows created:";timer.totalMilliseconds():timer.mark()
'    updateRowLayout()
'?"Rows updated:";timer.totalMilliseconds():timer.mark()    
    m.global.showSpinner = false
end sub

sub onContentChanged()
    m.global.showSpinner = true
    loadContent(m.top.content)
end sub

sub onContentLoaded()
    m.top.content = m.contentTask.content
    m.contentTask = invalid
end sub

sub scrollList()
    if m.list.isInFocusChain() then
        m.scrollInterp.keyValue = [m.list.translation, [0, 46]]
        if m.marquee.visible then
            m.fadeOutAnimation.appendChild(m.scrollAnimation)
            m.fadeOutAnimation.control = "start"
        else
            m.scrollAnimation.control = "start"
        end if
    else if m.marquee.isInFocusChain() then
        m.scrollInterp.keyValue = [m.list.translation, [0, 762]]
        m.fadeInAnimation.appendChild(m.scrollAnimation)
        m.fadeInAnimation.control = "start"
    end if
end sub

sub onRowItemSelected(nodeEvent as object)
    indices = nodeEvent.getData()
    row = m.list.content.getChild(indices[0])
    if row <> invalid then
        index = indices[1]
        item = row.getChild(index)
        if item <> invalid then
            trackScreenAction("trackPodSelect", getOmnitureData(row, index, iif(isSubscriber(m.global), "pay", "free")))
            if item.subtype() = "Episode" or item.subtype() = "Movie" then
                omnitureData = getOmnitureData(row, index, "more info", "overlay")
                m.top.omnitureData = omnitureData
                trackScreenAction("trackPodSelect", omnitureData)
            end if
            m.top.itemSelected = item
        end if
    end if
end sub

sub onItemSelected(nodeEvent as object)
    row = nodeEvent.getRoSGNode()
    if row <> invalid then
        index = nodeEvent.getData()
        item = row.content.getChild(index)
        if item <> invalid then
            trackScreenAction("trackPodSelect", getOmnitureData(row, index, iif(isSubscriber(m.global), "pay", "free")))
            if item.subtype() = "Episode" or item.subtype() = "Movie" then
                omnitureData = getOmnitureData(row, index, "more info", "overlay")
                m.top.omnitureData = omnitureData
                trackScreenAction("trackPodSelect", omnitureData)
            end if
            m.top.itemSelected = item
        end if
    end if
end sub

sub onMenuItemSelected(nodeEvent as object)
    m.top.menuItemSelected = nodeEvent.getData()
end sub

sub onMarqueeOpacityChanged()
    m.marquee.visible = (m.marquee.opacity > 0)
end sub

sub onMarqueeTimerFired()
    if m.marquee.isInFocusChain() and m.marquee.content <> invalid then
        if createObject("roDeviceInfo").timeSinceLastKeyPress() > 5 then
            index = m.marquee.itemFocused + 1
            if index >= m.marquee.content.getChildCount() - 1 then
                index = 0
            end if
            m.marquee.animateToItem = index
        end if
    end if
end sub