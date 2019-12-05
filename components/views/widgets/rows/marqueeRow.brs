function init()
    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.observeField("itemFocused", "onItemFocused")
    m.top.observeField("animateToItem", "onAnimateToItem")
    m.top.observeField("jumpToItem", "onJumpToItem")
    
    m.marquee = m.top.findNode("marquee")
    m.marquee.observeField("itemFocused", "onItemFocused")
    m.marquee.observeField("itemSelected", "onItemSelected")

    m.dots = m.top.findNode("dots")

    m.itemIndex = 0
    m.keyPressed = "none"
end function

sub onFocusChanged()
    if m.top.isInFocusChain() then
        m.marquee.visible = true
        m.marquee.setFocus(true)
    end if
end sub

sub onContentChanged(nodeEvent as object)
    content = nodeEvent.getData()
    updateContent(content)
end sub

sub updateContent(content as object)
    if content = invalid or content.getChildCount() = 0 then
        m.marquee.visible = false
        m.dots.visible = false
        m.marquee.content = invalid
    else
        m.dots.removeChildrenIndex(m.dots.getChildCount(), 0)
        for i = 1 to content.getChildCount()
            dot = m.dots.createChild("Poster")
            dot.width = 14
            dot.height = 14
            dot.uri = "pkg:/images/ui/dot_marquee.png"
        next
        m.dots.visible = true
        m.marquee.visible = true
        m.marquee.numColumns = content.getChildCount()
        m.marquee.content = content
        m.top.jumpToItem = 0
    end if
end sub

sub onItemFocused(nodeEvent as object)
    itemFocused = nodeEvent.getData()
    if m.marquee.content <> invalid then
        for i = 0 to m.dots.getChildCount() - 1
            dot = m.dots.getChild(i)
            if i = itemFocused then
                dot.opacity = 1
            else
                dot.opacity = .4
            end if
        next
        item = m.marquee.content.getChild(itemFocused)
        m.top.itemFocused = itemFocused
    end if
end sub

sub onItemSelected(nodeEvent as object)
    m.top.itemSelected = nodeEvent.getData()
end sub

sub onAnimateToItem(nodeEvent as object)
    itemIndex = nodeEvent.getData()
    m.itemIndex = itemIndex
    m.marquee.animateToItem = m.itemIndex
    m.top.itemFocused = m.itemIndex
end sub

sub onJumpToItem(nodeEvent as object)
    m.itemIndex = nodeEvent.getData()
    m.marquee.jumpToItem = m.itemIndex
    m.top.itemFocused = m.itemIndex
end sub