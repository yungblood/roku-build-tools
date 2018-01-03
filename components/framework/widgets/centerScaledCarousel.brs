sub init()
    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.focus = m.top.findNode("focus")
    
    m.list = m.top.findNode("list")
    m.list.advanceKey = "right"
    m.list.reverseKey = "left"
    m.layoutInitialized = false
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.list.setFocus(true)
    end if
    m.focus.visible = m.top.isInFocusChain()
end sub

sub onContentChanged()
    if m.content = invalid or not m.content.isSameNode(m.top.content) then
        m.content = m.top.content
        initLayout()
        m.list.content = m.top.content
    end if
end sub

sub initLayout()
    if not m.layoutInitialized then
        m.layoutInitialized = true
        
        centerRect = {}
        centerRect.x = int((1920 - m.top.focusedItemWidth) / 2)
        centerRect.y = 0
        centerRect.width = m.top.focusedItemWidth
        centerRect.height = m.top.focusedItemHeight
        
        targetRects = [centerRect]
        
        x = centerRect.x
        
        focusedIndex = 0
        y = int((m.top.focusedItemHeight - m.top.unfocusedItemHeight) / 2)
        while x + m.top.unfocusedItemWidth > 0
            x = x - m.top.itemSpacing - m.top.unfocusedItemWidth
            targetRect = {}
            targetRect.x = x
            targetRect.y = y
            targetRect.width = m.top.unfocusedItemWidth
            targetRect.height = m.top.unfocusedItemHeight
            targetRects.unshift(targetRect)
            focusedIndex++
        end while
        
        x = centerRect.x + centerRect.width - m.top.unfocusedItemWidth
        while x < 1920
            x = x + m.top.itemSpacing + m.top.unfocusedItemWidth
            targetRect = {}
            targetRect.x = x
            targetRect.y = y
            targetRect.width = m.top.unfocusedItemWidth
            targetRect.height = m.top.unfocusedItemHeight
            targetRects.push(targetRect)
        end while

        focusedTargetSet = createObject("roSGNode", "TargetSet")
        focusedTargetSet.targetRects = targetRects
        focusedTargetSet.focusIndex = focusedIndex
        m.list.focusedTargetSet = [focusedTargetSet]
        m.list.unfocusedTargetSet = focusedTargetSet
        m.list.targetSet = focusedTargetSet
        
        m.focus.translation = [centerRect.x - m.top.focusBitmapPadding, centerRect.y - m.top.focusBitmapPadding]
        m.focus.width = centerRect.width + (m.top.focusBitmapPadding * 2)
        m.focus.height = centerRect.height + (m.top.focusBitmapPadding * 2)
    end if
end sub

