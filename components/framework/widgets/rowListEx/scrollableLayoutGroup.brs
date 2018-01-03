sub init()
    m.initialized = false
    
    ' 0 = horizontal (x-coord)
    ' 1 = vertical   (y-coord)
    m.layoutIndex = 1
    m.layoutCoord = "y"
    m.layoutDim = "height"
    
    m.group = m.top.findNode("group")
    m.group.observeField("translation", "onTranslationChanged")
    m.group.observeField("change", "onChange")
    m.top.group = m.group
    

    m.top.observeField("layoutDirection", "onLayoutDirectionChanged")
    onLayoutDirectionChanged()
    
    m.parentAnimation = m.top.findNode("parentAnimation")
    
    m.percentAnimation = m.top.findNode("percentAnimation")
    m.percentAnimation.observeField("state", "onPercentAnimationStateChanged")
    m.percentInterpolator = m.top.findNode("percentInterpolator")

    m.scrollAnimation = m.top.findNode("scrollAnimation")
    m.scrollInterpolator = m.top.findNode("scrollInterpolator")
end sub

sub initLayout()
    if not m.initialized then
'        m.parentGroup = createObject("roSGNode", "Group")
'        parent = m.top.getParent()
'        for i = 0 to parent.getChildCount() - 1
'            child = parent.getChild(i)
'            if child.isSameNode(m.top) then
'                parent.replaceChild(m.parentGroup, i)
'                m.parentGroup.translation = m.top.translation
'                exit for
'            end if
'        next
'        m.top.reparent(m.parentGroup, true)
'        m.top.translation = [0, 0]
'        ' HACK: the scroll animation can't target this component from within it
'        '       so we re-parent it as soon as our children change
'        if m.top.id = "" then
'            m.top.id = m.top.subtype() + "_" + Rnd(&hfffffff).toStr()
'        end if
'        m.scrollInterpolator.fieldToInterp = m.top.id + ".translation"
'        m.percentInterpolator.fieldToInterp = m.top.id + ".scrollPercentage"
'        m.parentAnimation.reparent(m.parentGroup, false)
    end if
    m.initialized = true
end sub

sub updateLayout()
    spacings = m.top.itemSpacings
    if spacings.count() = 0 then
        spacings.push(0)
    end if
    x = 0
    y = 0
    if not m.top.ignoreScrollMarginForFirstChild then
        if m.top.layoutDirection = "vert" then
            y = m.top.scrollMargin
        else
            x = m.top.scrollMargin
        end if
    end if
    for i = 0 to m.group.getChildCount() - 1
        child = m.group.getChild(i)
        if child <> invalid and child.visible = true then
            spacing = spacings[i]
            if spacing = invalid then
                spacing = spacings.peek()
            end if
        end if
        child.translation = [x, y]
        rect = child.boundingRect()
        if m.top.layoutDirection = "vert" then
            y = y + rect.height + spacing
        else
            x = x + rect.width + spacing
        end if
    next
end sub

sub onChange()
    if not m.initialized then
        initLayout()
    end if
    updateLayout()
end sub

sub onLayoutDirectionChanged()
    if m.top.layoutDirection = "vert" then
        m.layoutIndex = 1
        m.layoutCoord = "y"
        m.layoutDim = "height"
    else
        m.layoutIndex = 0
        m.layoutCoord = "x"
        m.layoutDim = "width"
    end if
end sub

sub onTranslationChanged()
    if m.originalTranslation = invalid then
        m.originalTranslation = m.group.translation
    end if
    m.top.clippingRect = [0, 0, 1920 - m.top.translation[0], 1080 - m.top.translation[1]]
end sub

sub onScrollToChild()
    scrollToChild(m.top.scrollToChild, true)
end sub

sub onJumpToChild()
    scrollToChild(m.top.jumpToChild, false)
end sub

sub scrollToChild(index as integer, animate = true as boolean)
    if index < 0 then
        index = 0
    end if
    if index >= m.group.getChildCount() then
        index = m.group.getChildCount() - 1
    end if
    scrollMargin = m.top.scrollMargin
    scrollExtent = m.top.scrollExtent
    
    if index = 0 and m.top.ignoreScrollMarginForFirstChild then
        scrollMargin = 0
    end if


    ?"scrollToChild:";index,animate
    child = m.group.getChild(index)
    if child <> invalid then
        rect = child.boundingRect()
        childStart = m.group.translation[m.layoutIndex] + rect[m.layoutCoord]
        childExtent = childStart + rect[m.layoutDim]
        delta = 0
        if childExtent > scrollExtent then
            delta = scrollExtent - childExtent
        else if childStart < scrollMargin then
            delta = scrollMargin - childStart
        end if
        m.top.pendingChildScrolled = index
        if delta <> 0 then
            newTranslation = getNewTranslation(delta)
            if animate then
                m.scrollInterpolator.keyValue = [m.group.translation, newTranslation]
                m.parentAnimation.control = "start"
            else
                m.group.translation = newTranslation
                m.top.childScrolled = index
            end if
        else
            m.percentAnimation.control = "start"
        end if
    end if
end sub

function getNewTranslation(delta as float) as object
    translation = m.group.translation
    if m.top.layoutDirection = "vert" then
        translation[1] = translation[1] + delta
    else
        translation[0] = translation[0] + delta
    end if

    return translation
end function

sub onPercentAnimationStateChanged()
    if m.percentAnimation.state = "stopped" then
        m.top.childScrolled = m.top.pendingChildScrolled
    end if
end sub

sub onScrollDurationChanged()
    m.scrollAnimation.duration = m.top.scrollDuration
    m.percentAnimation.duration = m.top.scrollDuration
end sub

sub onScrollEaseFunctionChanged()
    m.scrollAnimation.easeFunction = m.top.scrollEaseFunction
    m.percentAnimation.easeFunction = m.top.scrollEaseFunction
end sub
