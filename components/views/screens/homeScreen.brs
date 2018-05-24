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
    
    m.lastFocus = m.menu
    
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
        updateContent()
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
    config = m.global.config
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
                rowItemSizes.push([266, 400])
                rowHeights.push(480)
            else
                if row.getChild(0).subtype() = "Show" or row.getChild(0).subtype() = "RelatedShow" then
                    rowItemSizes.push([266, 400])
                    rowHeights.push(480)
                else
                    rowItemSizes.push([420, 230])
                    rowHeights.push(298)
                end if 
            end if
        else if row.subtype() = "ShowHistory" then 
            rowItemSizes.push([266, 400])
            rowHeights.push(480)   
        else
            rowItemSizes.push([420, 230])
            rowHeights.push(298)
        end if
        content.appendChild(row)
    next
    m.list.rowItemSize = rowItemSizes
    m.list.rowHeights = rowHeights
    m.list.content = content

'    if config.currentCountryCode <> config.appCountryCode then
'        if m.global.showContentBlock = invalid then
'            m.global.addField("showContentBlock", "boolean", true)
'            dialog = createCbsDialog("", "Due to licensing restrictions, video is not available outside your country.", ["CLOSE"])
'            dialog.observeField("buttonSelected", "onLicensingDialogClosed")
'            m.global.dialog = dialog
'       end if
'    end if

    m.global.showSpinner = false
end sub

sub onLicensingDialogClosed(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    button = nodeEvent.getData()
    if button = "CLOSE" then
        dialog.close = true
    end if
end sub

sub updateContent()
    if m.top.content = invalid then
        m.global.showSpinner = true
        m.contentTask = createObject("roSGNode", "HomeScreenTask")
        m.contentTask.observeField("content", "onContentLoaded")
        m.contentTask.control = "run"
    else
        content = {}
        content.append(m.top.content)
        rows = []
        rows.append(content.rows)
        content.rows = rows
        user = m.global.user
        update = false
        if user.showHistory.getChildCount() = 0 then
            if user.showHistory.isSameNode(rows[0]) then
                rows.delete(0)
                update = true
            else if user.showHistory.isSameNode(rows[1]) then
                rows.delete(1)
                update = true
            end if
        else
            if not user.showHistory.isSameNode(rows[1]) then
                if not user.showHistory.isSameNode(rows[0]) then
                    if user.continueWatching.isSameNode(rows[0]) then
                        rows.shift()
                    end if
                    rows.unshift(user.showHistory)
                    update = true
                end if
            end if
        end if
    
        if user.continueWatching.getChildCount() = 0 then
            if user.continueWatching.isSameNode(rows[0]) then
                rows.delete(0)
                update = true
            end if
        else
            if not user.continueWatching.isSameNode(rows[0]) then
                rows.unshift(user.continueWatching)
                update = true
            end if
        end if
        if update then
            m.top.content = content
        end if
    end if
end sub

sub onContentChanged(nodeEvent as object)
    m.global.showSpinner = true
    loadContent(nodeEvent.getData())
end sub

sub onContentLoaded(nodeEvent as object)
    m.contentTask = invalid
    content = nodeEvent.getData()
    if content <> invalid then
        m.top.content = content
    end if
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
        m.scrollInterp.keyValue = [m.list.translation, [0, 862]]
        m.fadeInAnimation.appendChild(m.scrollAnimation)
        m.fadeInAnimation.control = "start"
    end if
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
            trackScreenAction("trackPodSelect", getOmnitureData(row, index, iif(isSubscriber(m.global), "pay", "free")))
            if item.subtype() = "Episode" or item.subtype() = "Movie" then
                omnitureData = getOmnitureData(row, index, "more info", "overlay")
                m.top.additionalContext = {}
                m.top.omnitureData = omnitureData
                trackScreenAction("trackPodSelect", omnitureData)
            end if
            if row.subtype() = "ContinueWatching" or row.subtype() = "ShowHistory" then
                additionalContext = {}
                event = "trackContinueWatching"
                sectionName = "continue watching"
                additionalContext["mediaResume"] = "true"
                additionalContext["mediaResumeSource"] = "continue watching"
                if row.subtype() = "ShowHistory" then
                    event = "trackShowsYouWatch"
                    sectionName = "shows you watch"
                    additionalContext["mediaResumeSource"] = "shows you watch"
                    additionalContext["mediaResumeSourceShow"] = item.title
                else
                    additionalContext["mediaResumeSourceShow"] = item.showName + " - " + item.title
                end if
                omnitureData = getOmnitureData(row, index, sectionName, "resume")
                
                showList = ""
                continueWatching = m.global.user.videoHistory
                if continueWatching <> invalid then
                    for i = 0 to continueWatching.getChildCount() - 1
                        episode = continueWatching.getChild(i)
                        if episode <> invalid then
                            if showList.len() > 0 then
                                showList = showList + "|"
                            end if
                            showList = showList + episode.showName + " - " + episode.title
                        end if
                    next
                end if
                additionalContext["continueWatchingShowsList"] = showList
                omnitureData["continueWatchingShowsList"] = showList
                m.top.additionalContext = additionalContext
                m.top.omnitureData = omnitureData
                trackScreenAction(event, omnitureData)
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
    if (m.menu.isInFocusChain() or m.marquee.isInFocusChain()) and m.marquee.content <> invalid then
        if createObject("roDeviceInfo").timeSinceLastKeyPress() > 5 then
            index = m.marquee.itemFocused + 1
            if index > m.marquee.content.getChildCount() - 1 then
                index = 0
            end if
            m.marquee.animateToItem = index
        end if
    end if
end sub