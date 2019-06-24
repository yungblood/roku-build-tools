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

    observeGlobalField("user", "onUserChanged")
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

sub onUserChanged(nodeEvent as object)
    user = nodeEvent.getData()
    if m.user = invalid or not m.user.isSameNode(user) then
        m.user = user
        m.top.content = m.user.favorites
    end if
end sub

sub onContentUpdated(change as object)
    hadFocus = m.top.isInFocusChain()
    if change.operation = "add" then
        index = change.index1
        item = m.content.getChild(index)
        if item <> invalid then
            tile = m.list.createChild("FavoriteTile")
            tile.width = 409
            tile.height = 230
            tile.itemContent = item
        end if
    else if change.operation = "remove" then
        m.list.removeChildIndex(change.index1)
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
    if hadFocus then
        m.top.setFocus(true)
    end if
end sub

sub onItemFocused(nodeEvent as object)
    item = m.list.getChild(m.list.itemFocused)
    if item <> invalid then
        rect = item.boundingRect()
        m.focusFrame.translation = [rect.x + m.list.translation[0], rect.y + m.list.translation[1]]
        m.focusFrame.width = rect.width
        m.focusFrame.height = rect.height
        if m.scrollRect.translation[0] + rect.x < 100 then
            m.scrollInterp.keyValue = [m.scrollRect.translation, [100 - rect.x, m.scrollRect.translation[1]]]
            m.scrollAnimation.control = "start"
        else if m.scrollRect.translation[0] + rect.x + rect.width > 1820 then
            m.scrollInterp.keyValue = [m.scrollRect.translation, [1820 - (rect.x + rect.width), m.scrollRect.translation[1]]]
            m.scrollAnimation.control = "start"
        end if
    end if
    m.previousItemFocused = m.list.itemFocused
end sub

sub onItemSelected(nodeEvent as object)
    m.top.itemSelected = m.list.itemSelected
end sub
