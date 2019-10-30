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
    
    m.user = getGlobalField("user")
    observeGlobalField("user", "onUserChanged")

    showSpinner()

    m.fadeOutAnimation = m.top.findNode("fadeOutAnimation")
    m.fadeInAnimation = m.top.findNode("fadeInAnimation")
    m.scrollAnimation = m.top.findNode("scrollAnimation")
    m.scrollInterp = m.top.findNode("scrollInterp")
    
    m.lastFocus = m.menu
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.lastFocus.setFocus(true)
        setGlobalField("ignoreBack",false)
    end if
    if m.list.hasFocus() and m.list.drawFocusFeeback <> true then
        m.list.drawFocusFeedback = true
    end if
end sub

sub onVisibleChanged()
    if m.top.visible then
        m.marqueeTimer.control = "start"
        m.marquee.visible = true
        updateContent()

        trackRMFEvent("CHS")
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
                m.list.jumpToRowItem = [0, 0]
                m.lastFocus = m.list
                scrollList()
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
        else if key = "back" then
            if m.list.hasFocus() then
                m.marquee.setFocus(true)
                m.lastFocus = m.marquee
                scrollList()
                m.menu.setFocus(true)
                m.lastFocus = m.menu
                return true
            end if
        end if
    end if
    return false
end function

sub onUserChanged(nodeEvent as object)
    ' Roku is a little overzealous with node field observations
    ' when individual fields of the node are changed, so we check
    ' to ensure we actually have a new user object
    user = nodeEvent.getData()
    if m.user = invalid or not m.user.isSameNode(user) then
        m.user = user
        refreshContent()
    end if
end sub

sub refreshContent()
    showSpinner()
    m.contentTask = createObject("roSGNode", "HomeScreenTask")
    m.contentTask.observeField("content", "onContentLoaded")
    m.contentTask.control = "run"
end sub

sub loadContent(content as object)
    config = getGlobalField("config")
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
            if i <= 2 then
                row.loadIndex = 0
            end if
            if row.title.inStr("Movies") >= 0 then
                rowItemSizes.push([266, 399])
                rowHeights.push(480)
            else
                if row.getChild(0).subtype() = "Show" or row.getChild(0).subtype() = "RelatedShow" then
                    rowItemSizes.push([266, 399])
                    rowHeights.push(480)
                else
                    rowItemSizes.push([420, 230])
                    rowHeights.push(298)
                end if 
            end if
        else if row.subtype() = "HomeShowGroup" or row.subtype() = "AmlgShowGroup" then
            if row.subtype() = "AmlgShowGroup" then
                row.loadIndex = 0
            end if
            rowItemSizes.push([266, 399])
            rowHeights.push(480)
        else if row.subtype() = "ShowHistory" then
            if m.showHistoryObserved <> true then
                row.observeField("content", "updateContent")
                m.showHistoryObserved = true
            end if
            row.update = true
            rowItemSizes.push([266, 399])
            rowHeights.push(480)   
        else
            if row.subtype() = "ContinueWatching" then
                if m.continueWatchingObserved <> true then
                    row.observeField("content", "updateContent")
                    m.continueWatchingObserved = true
                end if
                row.update = true
            end if
            rowItemSizes.push([420, 230])
            rowHeights.push(298)
        end if
        content.appendChild(row)
    next
    m.list.rowItemSize = rowItemSizes
    m.list.rowHeights = rowHeights
    m.list.content = content

    ' Fire launch complete beacon (Roku cert requirement)
    setGlobalField("launchComplete", true)

    if config.enableGeoBlock and not arrayContains(config.appCountryCode.split(","), config.currentCountryCode) and not config.geoBlocked then
        dialog = createCbsDialog("", "Due to licensing restrictions, video is not available outside your country.", ["CLOSE"])
        dialog.observeField("buttonSelected", "onLicensingDialogClosed")
        setGlobalField("cbsDialog", dialog)
        
        config.geoBlocked = true
    end if

    hideSpinner()
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
        refreshContent()
    else
        content = {}
        content.append(m.top.content)
        rows = []
        rows.append(content.rows)
        content.rows = rows
        user = getGlobalField("user")
        update = false
        if user.showHistory.getChildCount() = 0 and not user.showHistory.firstLoad then
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
    
        ' If showHistory is in recentlyWatched mode, we don't show the
        ' continue watching carousel
        if user.showHistory.mode <> "recentlyWatched" then
            if user.continueWatching.getChildCount() = 0 and not user.continueWatching.firstLoad then
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
        end if
        if update then
            m.top.content = content
        end if
    end if
end sub

sub onContentChanged(nodeEvent as object)
    showSpinner()
    loadContent(nodeEvent.getData())
end sub

sub onContentLoaded(nodeEvent as object)
    m.contentTask = invalid
    task = nodeEvent.getRoSGNode()
    if task.errorCode = 0 then
        content = nodeEvent.getData()
        if content <> invalid then
            m.list.showRowLabel=[true]
            m.top.content = content
        end if
    else
        showApiError(true)
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
    rowIndex = indices[0]
    itemIndex = indices[1]
    for i = 0 to 4
        row = m.list.content.getChild(rowIndex + i)
        if row <> invalid then
            if i = 0 then
                row.loadIndex = itemIndex
            else
                row.loadIndex = row.itemFocused
            end if
        end if
    next
end sub

sub onRowItemSelected(nodeEvent as object)
    indices = nodeEvent.getData()
    row = m.list.content.getChild(indices[0])
    if row <> invalid then
        index = indices[1]
        item = row.getChild(index)
        if item <> invalid then
            trackScreenAction("trackPodSelect", getOmnitureData(row, index, iif(isSubscriber(m.top), "pay", "free")))
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
                omnitureData = getOmnitureData(row, index, sectionName, "resume")
                if item.hasNewEpisodes = true then
                    omnitureData["episodeBadge"] = "true"
                    omnitureData["episodeBadgeLabel"] = "new"
                else
                    omnitureData["episodeBadge"] = "false"
                end if

                additionalContext["mediaResume"] = "true"
                additionalContext["mediaResumeSource"] = "continue watching"
                if row.subtype() = "ShowHistory" then
                    event = "trackShowsYouWatch"
                    sectionName = "shows you watch"
                    additionalContext["mediaResumeSource"] = "shows you watch"
                    additionalContext["mediaResumeSourceShow"] = item.title
                    
                    config = getGlobalField("config")
                    if config <> invalid and config.enableTaplytics = true then
                        taplyticsApi = getGlobalComponent("taplytics")
                        if taplyticsApi <> invalid then
                            taplyticsApi.callFunc("logEvent", { eventName: event, eventValue: 1 })
                        end if
                    end if
                else
                    additionalContext["mediaResumeSourceShow"] = item.showName + " - " + item.title
                end if
                
                showList = ""
                user = getGlobalField("user")
                continueWatching = user.videoHistory
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
            trackScreenAction("trackPodSelect", getOmnitureData(row, index, iif(isSubscriber(m.top), "pay", "free")))
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
    selection = nodeEvent.getData()
    if selection = "home" then
        'only change selection focus area after content is loaded
        'for users with itchy hyper trigger fingers this will keep focus where it should be
        if m.top.content <> invalid then
            m.marquee.setFocus(true)
            m.lastFocus = m.marquee
        end if
    else
        m.top.menuItemSelected = selection
    end if
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