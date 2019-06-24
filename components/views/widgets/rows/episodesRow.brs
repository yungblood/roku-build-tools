function init()
    m.top.rowHeight = 288

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
    if change.operation = "add" then
        index = change.index1
        item = m.content.getChild(index)
        if item <> invalid then
            user = getGlobalField("user")
            history = user.videoHistory
            historyItem = getChildByID(item.id, history)
            if historyItem <> invalid then
                item.resumePoint = historyItem.resumePoint
            end if
            tile = m.list.createChild("EpisodeTile")
            tile.width = 409
            tile.height = 230
            tile.itemContent = item
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
    else
        ?change
    end if
end sub

sub onItemFocused(nodeEvent as object)
    item = m.list.getChild(m.list.itemFocused)
    if item <> invalid then
        rect = item.boundingRect()
        if m.list.itemFocused = 0 or rect.x > 0 then
            m.focusFrame.translation = [rect.x + m.list.translation[0], 0]
            'm.focusFrame.width = rect.width
            'm.focusFrame.height = rect.height
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
        m.content.loadIndex = m.list.itemFocused
    end if
end sub

sub onItemSelected(nodeEvent as object)
    m.top.itemSelected = m.list.itemSelected
end sub
