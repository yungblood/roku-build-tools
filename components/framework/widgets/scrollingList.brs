sub init()
    m.components = []
    m.pendingFocusChange = []
    m.selectedIndex = 0
    m.scrollIndex = 0
    m.lastItemCount = 0
    m.itemExtent = 0
    m.listExtent = 0
    m.scrollExtent = 0
    m.top.itemFocused = 0
    
    m.list = m.top.findNode("list")
    m.focus = m.top.findNode("focus")
    m.placeholder = m.top.findNode("placeholder")
    m.scrollAnimation = m.top.findNode("scrollAnimation")
    m.scrollInterpolator = m.top.findNode("scrollInterpolator")
    
    m.scrollAnimation.observeField("state", "onAnimationStateChanged")
end sub

sub onContentChanged()
    itemCount = getItemCount()
    if m.top.content = invalid or not m.top.content.isSameNode(m.content) or m.lastItemCount <> itemCount then
        m.lastItemCount = itemCount
        m.content = m.top.content
        if getItemCount() < m.top.numItems then
            if m.top.focusAnimationStyle = "fixedFocusWrap" then
                m.top.focusAnimationStyle = "fixedFocus"
            else if m.top.focusAnimationStyle = "floatingFocusWrap" then
                m.top.focusAnimationStyle = "floatingFocus"
            end if
        end if
        initializeComponents()
        resetScrollPosition(true)
        m.top.itemFocused = m.top.itemFocused
    end if
end sub

sub onItemComponentNameChanged()
    'initializeComponents()
end sub

sub onItemSizeChanged()
    getItemExtent(true)
    onNumItemsChanged()
    m.focus.width = m.top.itemSize[0]
    m.focus.height = m.top.itemSize[1]
end sub

sub onNumItemsChanged()
    updateLayout()
end sub

sub onLeadingPlaceholdersChanged()
    m.selectedIndex = m.top.itemFocused + m.top.leadingPlaceholders
    ' TODO: This should really be calculated based on the change for floating focus
    m.scrollIndex = m.top.itemFocused + m.top.leadingPlaceholders
end sub

sub updateLayout()
    if m.top.layoutDirection = "vert" then
        if m.top.width = 0 and m.top.height = 0 then
            m.top.clippingRect = [0, 0, m.top.itemSize[0], getScrollExtent(true)]
        else if m.top.width = 0 then
            m.top.clippingRect = [0, 0, m.top.itemSize[0], m.top.height]
        else if m.top.height = 0 then
            m.top.clippingRect = [0, 0, m.top.width, getScrollExtent(true)]
        else
            m.top.clippingRect = [0, 0, m.top.width, m.top.height]
        end if
    else
        if m.top.width = 0 and m.top.height = 0 then
            m.top.clippingRect = [0, 0, getScrollExtent(true), m.top.itemSize[1]]
        else if m.top.width = 0 then
            m.top.clippingRect = [0, 0, getScrollExtent(true), m.top.height]
        else if m.top.height = 0 then
            m.top.clippingRect = [0, 0, m.top.width, m.top.itemSize[1]]
        else
            m.top.clippingRect = [0, 0, m.top.width, m.top.height]
        end if
    end if
    resetScrollPosition()
end sub

sub onJumpToItem()
    advanceToItem(m.top.jumpToItem, false)
end sub

sub onAnimateToItem()
    advanceToItem(m.top.animateToItem, true)
end sub

sub advanceToItem(index as integer, animate = true as boolean)
    if animate then
        offset = m.selectedIndex - index
        count = abs(offset)
        duration = m.top.scrollSpeed
        if offset > 0 then
            duration = duration / count
        end if
        for i = 1 to count
            pending = {
                change: 1
                duration: duration
                ease: "inOutQuad"
            }
            if count >= 3 then
                if i = 1 then
                    pending.duration = m.top.scrollSpeed / 2
                    pending.ease = "inQuad"
                else if i = count then
                    pending.duration = m.top.scrollSpeed / 2
                    pending.ease = "outQuad"
                else
                    pending.ease = "linear"
                end if
            end if
            if offset > 0 then
                pending.change = -1
            end if
            m.pendingFocusChange.push(pending)
        next
        if m.top.updateFocusBeforeScroll then
            index = getItemIndex(index)
            m.top.itemFocused = index - m.top.leadingPlaceholders
        end if
        processPendingFocusChanges()
    else
        change = index - m.selectedIndex
        index = getItemIndex(index)
        m.selectedIndex = index
        
        if m.top.focusAnimationStyle = "fixedFocus" or m.top.focusAnimationStyle = "fixedFocusWrap" then
            m.scrollIndex = index
        else
            wrappedIndex = m.selectedIndex + getItemCount()
            if (m.selectedIndex >= m.scrollIndex and m.selectedIndex < m.scrollIndex + m.top.numItems) or (wrappedIndex >= m.scrollIndex and wrappedIndex < m.scrollIndex + m.top.numItems) then
                ' We're within the current scrollable area, so do nothing
            else
                m.scrollIndex = m.scrollIndex + change
                if m.scrollIndex < 0
                    m.scrollIndex = getItemCount() + (m.scrollIndex mod getItemCount())
                end if
                if m.scrollIndex >= getItemCount()
                    m.scrollIndex = m.scrollIndex mod getItemCount()
                end if
                if m.top.layoutDirection = "vert" then
                    m.list.translation = [m.list.translation[0], -change * getItemExtent() - getScrollExtent()]
                else 
                    m.list.translation = [-change * getItemExtent() - getScrollExtent(), m.list.translation[1]]
                end if
            end if
        end if
        resetScrollPosition(true)
        m.top.itemFocused = m.selectedIndex - m.top.leadingPlaceholders
    end if
end sub

sub incrementFocus(change = 1 as integer, duration = .25 as float, easeFunction = "inOutQuad" as string)
    if change > 1 then
        change = 1
    else if change < 0 then
        change = -1
    end if
    newIndex = getItemIndex(m.selectedIndex + change)
    if newIndex <> m.selectedIndex then
        m.selectedIndex = newIndex
        
        animateList = true
        animateFocus = false
        if m.top.focusAnimationStyle = "fixedFocus" or m.top.focusAnimationStyle = "fixedFocusWrap" then
            m.scrollIndex = index
        else
            wrappedIndex = m.selectedIndex + getItemCount()
            if (m.selectedIndex >= m.scrollIndex and m.selectedIndex < m.scrollIndex + m.top.numItems) or (wrappedIndex >= m.scrollIndex and wrappedIndex < m.scrollIndex + m.top.numItems) then
                ' We are within the scrollable view, so we need to animate the focus frame instead of the list
                animateList = false
                animateFocus = true
            else
                m.scrollIndex = m.scrollIndex + change
                if m.scrollIndex < 0
                    m.scrollIndex = getItemCount() + (m.scrollIndex mod getItemCount())
                end if
                if m.scrollIndex >= getItemCount()
                    m.scrollIndex = m.scrollIndex mod getItemCount()
                end if
            end if
        end if
        
        m.scrollAnimation.duration = duration
        m.scrollAnimation.easeFunction = easeFunction
        if animateList then
            m.scrollInterpolator.fieldToInterp = "list.translation"
            if m.top.layoutDirection = "vert" then
                m.scrollInterpolator.keyValue = [
                    m.list.translation,
                    [m.list.translation[0], -change * getItemExtent() - getScrollExtent()]
                ]
            else 
                m.scrollInterpolator.keyValue = [
                    m.list.translation,
                    [-change * getItemExtent() - getScrollExtent(), m.list.translation[1]]
                ]
            end if
            m.scrollAnimation.control = "start"
        else if animateFocus then
            focusIndex = getFocusIndex()
            m.scrollInterpolator.fieldToInterp = "focus.translation"
            if m.top.layoutDirection = "vert" then
                m.scrollInterpolator.keyValue = [
                    m.focus.translation,
                    [m.focus.translation[0], focusIndex * getItemExtent() + m.top.focusOffset, 0]
                ]
            else 
                m.scrollInterpolator.keyValue = [
                    m.focus.translation,
                    [focusIndex * getItemExtent() + m.top.focusOffset, m.focus.translation[1]]
                ]
            end if
            m.scrollAnimation.control = "start"
        end if
    end if
end sub

function processPendingFocusChanges() as boolean
    focusChange = m.pendingFocusChange.shift()
    if focusChange <> invalid then
        resetScrollPosition(true)
        incrementFocus(focusChange.change, focusChange.duration, focusChange.ease)
        return true
    end if
    return false
end function

sub onAnimationStateChanged()
    if m.scrollAnimation.state = "stopped" then
        if not processPendingFocusChanges() then
            advanceToItem(m.selectedIndex, false)
        end if
    end if
end sub

function getItemIndex(index as integer) as integer
    if index < 0 then
        if m.top.focusAnimationStyle = "fixedFocusWrap" or m.top.focusAnimationStyle = "floatingFocusWrap" then
            index = getItemCount() + (index mod getItemCount())
        else
            index = 0
        end if
    end if
    if index >= getItemCount() then
        if m.top.focusAnimationStyle = "fixedFocusWrap" or m.top.focusAnimationStyle = "floatingFocusWrap" then
            index = index mod getItemCount()
        else
            index = getItemCount() - 1
        end if
    end if
    return index
end function

function getItemCount() as integer
    return m.top.leadingPlaceholders + m.top.content.getChildCount() + m.top.trailingPlaceholders
end function

function getItemContent(index as integer) as object
    contentIndex = index mod getItemCount()
    if contentIndex < 0 then
        contentIndex = getItemCount() + contentIndex
    end if
    contentIndex = contentIndex - m.top.leadingPlaceholders
    if contentIndex < 0 or contentIndex >= m.top.content.getChildCount() then
        return m.placeholder
    else
        return m.top.content.getChild(contentIndex)
    end if
end function

function getItemExtent(refresh = false as boolean) as integer
    if refresh or m.itemExtent = 0 then
        if m.top.layoutDirection = "vert" then
            m.itemExtent = m.top.itemSize[1] + m.top.itemSpacing
        else
            m.itemExtent = m.top.itemSize[0] + m.top.itemSpacing
        end if
    end if
    return m.itemExtent
end function

function getListExtent(refresh = false as boolean) as integer
    if refresh or m.listExtent = 0 then
        m.listExtent = getItemCount() * getItemExtent(refresh)
    end if
    return m.listExtent
end function

function getScrollExtent(refresh = false as boolean) as integer
    if refresh or m.scrollExtent = 0 then
        m.scrollExtent = m.top.numItems * getItemExtent(refresh) 
    end if
    return m.scrollExtent - m.top.focusOffset
end function

function getVisibleItemCount() as integer
    count = 0
    if m.top.layoutDirection = "vert" then
        if m.top.height = 0 then
            count = m.top.numItems
        else
            count = m.top.height / getItemExtent()
        end if
    else
        if m.top.width = 0 then
            count = m.top.numItems
        else
            count = m.top.width / getItemExtent()
        end if
    end if
    ' Add two to account for the incoming and outgoing items during scroll
    count = count + 2
    if count > int(count) then
        count = count + 1
    end if
    return int(count)
end function

function getFocusIndex() as integer
    if m.top.content <> invalid then
        wrappedIndex = m.selectedIndex + getItemCount()
        focusIndex = m.selectedIndex - m.scrollIndex
        if focusIndex < 0 then
            focusIndex = wrappedIndex - m.scrollIndex
        end if
        return focusIndex
    end if
    return 0
 end function

sub initializeComponents()
    if m.components.isEmpty() and m.top.content <> invalid and not isNullOrEmpty(m.top.itemComponentName) then
        visibleItems = getVisibleItemCount()
        'for i = 0 to (visibleItems * 3) - 1
        for i = 0 to (visibleItems + 2) - 1
            component = CreateObject("roSGNode", m.top.itemComponentName)
            if component.hasField("width") then
                component.width = m.top.itemSize[0]
            end if
            if component.hasField("height") then
                component.height = m.top.itemSize[1]
            end if
            m.components.push(component)
        next
        m.list.appendChildren(m.components)
    end if
end sub

function itemIsVisible(index as integer) as boolean
    startIndex = m.top.numItems
    endIndex = startIndex + m.top.numItems - 1
    for i = startIndex to endIndex
        contentIndex = (i + m.selectedIndex - m.top.numItems) mod getItemCount()
        if contentIndex < 0 then
            contentIndex = getItemCount() + contentIndex
        end if
        if contentIndex = index then
            return true
        end if
    next
    return false
end function

sub updateComponentContent()
    for i = 0 to m.components.count() - 1
        component = m.components[i]
        if component <> invalid then
            if m.top.layoutDirection = "vert" then
                component.translation = [0, i * getItemExtent()]
            else
                component.translation = [i * getItemExtent(), 0]
            end if
            index = (i + m.scrollIndex - m.top.numItems)
            if m.top.focusAnimationStyle = "fixedFocus" or m.top.focusAnimationStyle = "floatingFocus" then
                component.visible = index >= 0 and index < getItemCount()
            end if
            if component.visible then
                component.itemContent = getItemContent(index)
            end if
        else
            exit for
        end if
    next
end sub

sub resetScrollPosition(repositionComponents = false as boolean)
    focusIndex = getFocusIndex()
    scrollExtent = getScrollExtent()
    if m.top.layoutDirection = "vert" then
        if repositionComponents then
            if m.list.translation[1] > -scrollExtent then
                ' We've scrolled up, so move the last component to the first position
                m.components.unshift(m.components.pop())
            else if m.list.translation[1] < -scrollExtent then
                ' We've scrolled down, so move the first component to the last position
                m.components.push(m.components.shift())
            end if
            updateComponentContent()
        end if
        m.list.translation = [0, -scrollExtent]
        m.focus.translation = [m.focus.translation[0], focusIndex * getItemExtent() + m.top.focusOffset]
    else
        if repositionComponents then
            if m.list.translation[0] > -scrollExtent then
                ' We've scrolled left, so move the last component to the first position
                m.components.unshift(m.components.pop())
            else if m.list.translation[0] < -scrollExtent then
                ' We've scrolled right, so move the first component to the last position
                m.components.push(m.components.shift())
            end if
            updateComponentContent()
        end if
        m.list.translation = [-scrollExtent, 0]
        m.focus.translation = [focusIndex * getItemExtent() + m.top.focusOffset, m.focus.translation[1]]
    end if
end sub
