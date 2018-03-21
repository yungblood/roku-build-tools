function init()
    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.observeField("visible", "onVisibleChanged")
    
    m.list = m.top.findNode("list")
    m.list.observeField("itemFocused", "onItemFocused")
    m.list.content = createObject("roSGNode", "ContentNode")
    m.list.observeField("currTargetSet", "onCurrTargetSetChanged")

    m.actionButton = m.top.findNode("actionButton")
    m.dots = m.top.findNode("dots")

    m.top.itemComponentName = "MarqueeTile"
    m.top.advanceKey = "right"
    m.top.reverseKey = "left"
    m.top.wrap = false

    initTargetSets()
    updateRowHeight()
    
    m.targetSetIndex = 0
    m.itemIndex = 0
    m.keyPressed = "none"
    m.hadFocus = false
end function

function onKeyEvent(key as string, press as boolean) as boolean
    handled = false
    if key = m.top.reverseKey then
        if press
            m.keyPressed = m.top.reverseKey
            reverse()
        else
            m.keypressed = "none"
            m.list.reversing = false     
        end if
        handled = true
    else if key = m.top.advanceKey then
        if press
            m.keyPressed = m.top.advanceKey
            advance()
        else
            m.keyPressed = "none"
            m.list.advancing = false
        end if
        handled = true
    end if
    return handled
end function

sub onVisibleChanged()
    if m.top.visible then
        if m.list.content = invalid and m.top.content <> invalid then
            onContentChanged()
            ?"resetting content"
        end if
    else
        m.list.content = invalid
    end if
end sub

function advance()
    if m.top.content <> invalid then
        m.list.advancing = true
        m.itemIndex = m.list.itemFocused + 1
        if m.itemIndex >= m.top.content.getChildCount()
            m.itemIndex = m.itemIndex - m.top.content.getChildCount()
        end if      
        print "right key itemIndex is "; m.itemIndex
        if m.targetSetIndex < m.top.focusedTargetSet.count() - 1
            print "animating target set from ";m.targetSetIndex;" to ";m.targetSetIndex + 1
            m.targetSetIndex = m.targetSetIndex + 1
            m.top.animateToTargetSet = m.top.focusedTargetSet[m.targetSetIndex]
        else
            print "animating just the items"
        end if
        m.top.animateToItem = m.itemIndex
    end if
end function

function reverse()
    if m.top.content <> invalid then
        m.list.reversing = true
        m.itemIndex = m.list.itemFocused - 1
        if m.itemIndex < 0 then
            m.itemIndex = m.itemIndex + m.top.content.getChildCount()
        end if      
        print "left key itemIndex is "; m.itemIndex
        if m.targetSetIndex > 0 then
            print "animating target set from ";m.targetSetIndex;" to ";m.targetSetIndex - 1
            m.targetSetIndex = m.targetSetIndex - 1
            m.top.animateToTargetSet = m.top.focusedTargetSet[m.targetSetIndex]
        else
            print "animating just the items"
        end if
        m.top.animateToItem = m.itemIndex
    end if
end function

sub initTargetSets()
    targetSets = []
    
    primarySize = [1920, 1080]
    spacing = 0
    
    xShift = 0
    x = 0
    targetSet = createObject("roSGNode", "TargetSet")
    targetRects = []
    targetRects.push({ x: -primarySize[0], y: 0, width: primarySize[0], height: primarySize[1] })
    targetRects.push({ x: 0, y: 0, width: primarySize[0], height: primarySize[1] })
    targetRects.push({ x: primarySize[0], y: 0, width: primarySize[0], height: primarySize[1] })
    targetSet.targetRects = targetRects
    targetSet.focusIndex = 1
    targetSets.push(targetSet)

    unfocusedTargetSet = createObject("roSGNode", "TargetSet")
    unfocusedTargetSet.targetRects = targetSets[0].targetRects
    unfocusedTargetSet.focusIndex = 1
    
    m.top.focusedTargetSet = targetSets
    m.top.unfocusedTargetSet = unfocusedTargetSet
    m.top.targetSet = targetSets[0]
end sub

sub updateRowHeight()
    rowHeight = 0
    for each targetSet in m.top.focusedTargetSet
        for each rect in targetSet.targetRects
            if rect.y + rect.height > rowHeight then
                rowHeight = rect.y + rect.height
            end if
        next
    next
    m.top.rowHeight = rowHeight
end sub

sub onFocusChanged()
    hasFocus = m.top.hasFocus()
    if hasFocus then
        m.list.setFocus(true)
        if not m.hadFocus then
            m.hadFocus = true
            m.top.animateToTargetSet = m.top.focusedTargetSet[m.targetSetIndex]
        end if
    else
        if m.hadFocus then
            if not m.top.targetSet.isSameNode(m.top.unfocusedTargetSet) then
                m.top.animateToTargetSet = m.top.unfocusedTargetSet
            end if
            m.hadFocus = false
        end if
    end if
    if m.top.isInFocusChain() then
        m.actionButton.opacity = 1
    else
        m.actionButton.opacity = .4
    end if
end sub

sub onContentChanged()
    if m.top.content = invalid or m.top.content.getChildCount() = 0 then
        m.list.visible = false
        m.list.content = invalid
    else
        content = m.top.content
        m.dots.removeChildrenIndex(m.dots.getChildCount(), 0)
        for i = 1 to content.getChildCount()
            dot = m.dots.createChild("Poster")
            dot.width = 12
            dot.height = 12
            dot.uri = "pkg:/images/marquee_dot.png"
        next
'        ' HACK: In 7.5 the last item isn't selectable, so we add a fake final item and skip it
'        '       when scrolling through the content
'        if content.getChild(content.getChildCount() - 1).subtype() <> "ContentNode" then
'            content.createChild("ContentNode")
'        end if
        m.list.content = content
        
        onItemFocused()
    end if
end sub

sub onItemFocused()
    if m.list.content <> invalid then
        m.top.unfocusedTargetSet.focusIndex = m.top.targetSet.focusIndex
        for i = 0 to m.dots.getChildCount() - 1
            dot = m.dots.getChild(i)
            if i = m.list.itemFocused then
                dot.opacity = 1
            else
                dot.opacity = .55
            end if
        next
        item = m.list.content.getChild(m.list.itemFocused)
        if item <> invalid then
            m.actionButton.text = item.actionTitle
        end if
    end if
end sub

sub onCurrTargetSetChanged()
    '?m.list.currTargetSet.targetRects[0]
    '?m.list.currFocusItemIndex
end sub