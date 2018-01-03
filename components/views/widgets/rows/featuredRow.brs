function init()
    m.top.rowHeight = 528

    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.scrollRect = m.top.findNode("scrollRect")
    m.list = m.top.findNode("list")
    m.list.observeField("itemFocused", "onItemFocused")
    m.list.observeField("itemSelected", "onItemSelected")

    m.rowTitle = m.top.findNode("rowTitle")
    m.focusFrame = m.top.findNode("focusFrame")
    
    m.scrollAnimation = m.top.findNode("scrollAnimation")
    m.scrollInterp = m.top.findNode("scrollInterp")
    
    m.previousItemFocused = 0
    m.initialLoad = true
    
    m.top.visible = true
    m.top.hideIfEmpty = false
end function

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
    end if
    return false
end function

sub onFocusChanged()
    if m.top.hasFocus() then
        m.list.setFocus(true)
    end if
    m.focusFrame.visible = m.top.isInFocusChain()
end sub

sub onContentUpdated(change as object)
    hadFocus = m.top.isInFocusChain()
    if change.operation = "add" then
        index = change.index1
        item = m.content.getChild(index)
        if item <> invalid then
            history = m.global.user.recentlyWatched
            historyItem = getChildByID(item.id, history)
            if historyItem <> invalid then
                item.resumePoint = historyItem.resumePoint
            end if

            if index = 0 or m.content.getChildCount() < 5 then
                tile = m.list.createChild("FeaturedEpisodeTile")
                tile.width = 836
                tile.height = 470
                tile.itemContent = item
            else
                if index mod 2 = 0 then
                    tileGroup = m.list.getChild(m.list.getChildCount() - 1)
                else
                    tileGroup = m.list.createChild("FocusLayoutGroup")
                    tileGroup.observeField("itemFocused", "onSubItemFocused")
                    tileGroup.observeField("itemSelected", "onSubItemSelected")
                    tileGroup.layoutDirection = "vert"
                    tileGroup.itemSpacings = [10]
                    tileGroup.allowPaging = false
                end if
                tile = tileGroup.createChild("FeaturedEpisodeTile")
                tile.width = 409
                tile.height = 230
                tile.itemContent = item
            end if
        end if
    else if change.operation = "setall" then
        m.list.removeChildrenIndex(m.list.getChildCount(), 0)
        for i = 0 to m.content.getChildCount() - 1
            change = {
                operation: "add"
                index1: i
                index2: 0
            }
            onContentUpdated(change)
        next
    else if change.operation = "remove" then
        m.list.removeChildIndex(change.index1)
    else
        ?change
    end if
    if hadFocus then
        m.top.setFocus(true)
    end if
end sub

'sub onItemFocused(nodeEvent as object)
'    item = m.list.getChild(m.list.itemFocused)
'    if item <> invalid then
'        rect = item.boundingRect()
'        if (m.list.itemFocused = 0 and item.width > 0) or rect.x > 0 then
'            if m.list.itemFocused = 0 then
'                m.focusFrame.translation = [rect.x + m.list.translation[0], rect.y + m.list.translation[1]]
'                m.focusFrame.width = item.width
'                m.focusFrame.height = item.height
'            else
'                if m.previousItemFocused > 0 then
'                    previousItem = m.list.getChild(m.previousItemFocused)
'                    if previousItem <> invalid then
'                        item.jumpToIndex = previousItem.itemFocused
'                    else
'                        item.jumpToIndex = 0
'                    end if
'                else
'                    item.jumpToIndex = 0
'                end if
'                child = item.getChild(item.itemFocused)
'                childRect = child.boundingRect()
'                m.focusFrame.translation = [childRect.x + rect.x + m.list.translation[0], childRect.y + rect.y + m.list.translation[1]]
'                m.focusFrame.width = child.width
'                m.focusFrame.height = child.height
'            end if
'            if m.scrollRect.translation[0] + rect.x < 100 then
'                m.scrollInterp.keyValue = [m.scrollRect.translation, [100 - rect.x, m.scrollRect.translation[1]]]
'                m.scrollAnimation.control = "start"
'            else if m.scrollRect.translation[0] + rect.x + rect.width > 1820 then
'                m.scrollInterp.keyValue = [m.scrollRect.translation, [1820 - (rect.x + rect.width), m.scrollRect.translation[1]]]
'                m.scrollAnimation.control = "start"
'            end if
'        end if
'    end if
'    m.previousItemFocused = m.list.itemFocused
'    if m.content.subtype() = "Section" then
'        m.content.loadIndex = (m.list.itemFocused * 2)
'    end if
'end sub

sub onItemFocused(nodeEvent as object)
    item = m.list.getChild(m.list.itemFocused)
    if item <> invalid then
        rect = item.boundingRect()
        if (m.list.itemFocused = 0 and item.width > 0) or rect.x > 0 then
            if m.list.itemFocused = 0 then
                m.focusFrame.translation = [rect.x + m.list.translation[0], rect.y + m.list.translation[1]]
                m.focusFrame.width = item.width
                m.focusFrame.height = item.height
            else
                child = item
                childRect = { x: 0, y: 0, width: 0, height: 0 }
                if item.subtype() = "FocusLayoutGroup" then
                    if m.previousItemFocused > 0 then
                        previousItem = m.list.getChild(m.previousItemFocused)
                        if previousItem <> invalid and previousItem.subtype() = "FocusLayoutGroup" then
                            item.jumpToIndex = previousItem.itemFocused
                        else
                            item.jumpToIndex = 0
                        end if
                    else
                        item.jumpToIndex = 0
                    end if
                    child = item.getChild(item.itemFocused)
                    childRect = child.boundingRect()
                end if
                
                m.focusFrame.translation = [childRect.x + rect.x + m.list.translation[0], childRect.y + rect.y + m.list.translation[1]]
                m.focusFrame.width = child.width
                m.focusFrame.height = child.height
            end if
            if m.scrollRect.translation[0] + rect.x < 100 then
                m.scrollInterp.keyValue = [m.scrollRect.translation, [100 - rect.x, m.scrollRect.translation[1]]]
                m.scrollAnimation.control = "start"
            else if m.scrollRect.translation[0] + rect.x + rect.width > 1820 then
                m.scrollInterp.keyValue = [m.scrollRect.translation, [1820 - (rect.x + rect.width), m.scrollRect.translation[1]]]
                m.scrollAnimation.control = "start"
            end if
        end if
    end if
    m.previousItemFocused = m.list.itemFocused
    if m.content.subtype() = "Section" then
        m.content.loadIndex = (m.list.itemFocused * 2)
    end if
end sub

sub onItemSelected(nodeEvent as object)
    m.top.itemSelected = nodeEvent.getData()
end sub

sub onSubItemFocused(nodeEvent as object)
    if m.list.itemFocused > 0 then
        item = m.list.getChild(m.list.itemFocused)
        if item <> invalid then
            rect = item.boundingRect()
            if rect.x > 0 then
                child = item.getChild(item.itemFocused)
                if child <> invalid then
                    childRect = child.boundingRect()
                    m.focusFrame.translation = [childRect.x + rect.x + m.list.translation[0], childRect.y + rect.y + m.list.translation[1]]
                    m.focusFrame.width = childRect.width
                    m.focusFrame.height = childRect.height
                end if
            end if
        end if
    end if
end sub

sub onSubItemSelected(nodeEvent as object)
    index = (m.list.itemFocused * 2) - 1
    index = index + nodeEvent.getData()
    m.top.itemSelected = index
end sub
