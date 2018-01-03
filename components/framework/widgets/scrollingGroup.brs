sub init()
    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.components = []
    
    ' array index for calculating position based on
    ' layoutDirection
    m.extentIndex = 1
    
    m.focusIndex = 0
    m.startIndex = -1
    m.currentOffset = 0
    m.currentStartIndex = 0
    m.currentEndIndex = -1
    
    m.group = m.top.findNode("group")
    m.group.observeField("translation", "onGroupTranslationChanged")
    
    m.focus = m.top.findNode("focus")
    m.placeholder = m.top.findNode("placeholder")
    m.scrollAnimation = m.top.findNode("scrollAnimation")
    m.scrollInterpolator = m.top.findNode("scrollInterpolator")
    
    m.scrollAnimation.observeField("state", "onAnimationStateChanged")
end sub

sub onFocusChanged()
    if m.top.hasFocus() and m.group.getChildCount() > 0 then
        updateFocus()
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        if key = "up" then
            if m.top.layoutDirection = "vert" then
                return jumpToItem(m.focusIndex - 1, true)
            end if
        else if key = "down" then
            if m.top.layoutDirection = "vert" then
                return jumpToItem(m.focusIndex + 1, true)
            end if
        else if key = "left" then
            if m.top.layoutDirection = "horiz" then
                return jumpToItem(m.focusIndex - 1, true)
            end if
        else if key = "right" then
            if m.top.layoutDirection = "horiz" then
                return jumpToItem(m.focusIndex + 1, true)
            end if
        else if key = "OK" then
            m.top.itemSelected = m.focusIndex
        end if
    end if
    return false
end function

sub onContentChanged()
    m.startIndex = -1
    m.currentStartIndex = 0
    m.currentEndIndex = -1
    m.focusIndex = 0

    translation = m.group.translation
    translation[m.extentIndex] = 0
    m.group.translation = translation

    m.group.removeChildrenIndex(m.group.getChildCount(), 0)
    m.components.clear()
    updateStartIndex(0)
?"contentChanged: ", m.top.content.title, m.top.content.getChildCount()

    onFocusChanged()
end sub

sub onLayoutDirectionChanged()
    if m.top.layoutDirection = "vert" then
        m.extentIndex = 1
    else
        m.extentIndex = 0
    end if
end sub

function jumpToItem(index as integer, animate = false as boolean) as boolean
    if m.top.content <> invalid then
        if index >= m.top.content.getChildCount() then
            index = m.top.content.getChildCount() - 1
        else if index < 0 then
            index = 0
        end if
        if index <> m.focusIndex then
            if animate then
                if m.top.focusAnimationStyle.inStr("fixed") = 0 then
                    firstItem = getFirstVisibleItemInfo()
                    delta = getItemPosition(index) - firstItem.layoutPosition
    
                    startPosition = m.group.translation
                    if index < m.startIndex then
                        updateStartIndex(index)
                        startPosition[m.extentIndex] = startPosition[m.extentIndex] + delta
                    else
                        indexDelta = index - m.startIndex
                        updateStartIndex(m.startIndex, m.top.visibleItemCount + indexDelta)
                    end if
    
                    keyValues = []
                    targetPosition = [startPosition[0], startPosition[1]]
                    targetPosition[m.extentIndex] = startPosition[m.extentIndex] - delta
                    
                    keyValues[0] = startPosition
                    keyValues[1] = targetPosition
                    m.scrollInterpolator.keyValue = keyValues
                    
                    m.currentOffset = targetPosition[m.extentIndex]
    
                    m.scrollAnimation.control = "start"
                else
                    firstItem = getFirstVisibleItemInfo()
                    itemPos = getItemPosition(index, true)
                    itemExtent = getItemExtent(index)
                    delta = itemPos + itemExtent + m.group.translation[m.extentIndex] - m.top.scrollMargin

                    startPosition = m.group.translation
                    if index < m.focusIndex then
                        updateStartIndex(index)
                        startPosition[m.extentIndex] = startPosition[m.extentIndex] + delta
                    else
                        indexDelta = index - m.startIndex
                        updateStartIndex(m.startIndex, m.top.visibleItemCount + indexDelta)
                    end if
    
                    keyValues = []
                    targetPosition = [startPosition[0], startPosition[1]]
                    targetPosition[m.extentIndex] = startPosition[m.extentIndex] - delta
                    
                    keyValues[0] = startPosition
                    keyValues[1] = targetPosition
                    m.scrollInterpolator.keyValue = keyValues
                    
                    m.currentOffset = targetPosition[m.extentIndex]
    
                    m.scrollAnimation.control = "start"
                end if
                m.focusIndex = index
            else
                updateStartIndex(index)
                m.focusIndex = index
                updateFocus()
            end if
        end if
    end if
    return false
end function

function getItemExtent(itemIndex as integer) as object
    itemSize = getItemSize(itemIndex)
    itemSpacing = getItemSpacing(itemIndex)
    return itemSize[m.extentIndex] + itemSpacing
end function

function getItemSize(itemIndex as integer, actualIfAvailable = false as boolean) as object
    if actualIfAvailable then
        component = getComponent(itemIndex)
        if component <> invalid then
            rect = component.boundingRect()
            if rect.height > 0 then
                return [rect.width, rect.height]
            end if
        end if
    end if
    itemSizes = m.top.itemSizes
    itemSize = itemSizes[itemIndex]
    if itemSize = invalid then
        itemSize = itemSizes.peek()
    end if     
    if itemSize = invalid then
        itemSize = [100, 100]
    end if
    return itemSize
end function

function getItemSpacing(itemIndex as integer) as float
    itemSpacings = m.top.itemSpacings
    itemSpacing = itemSpacings[itemIndex]
    if itemSpacing = invalid then
        itemSpacing = itemSpacings.peek()
    end if     
    if itemSpacing = invalid then
        itemSpacing = 0
    end if
    return itemSpacing
end function

function getItemPosition(index as integer, adjusted = false as boolean) as float
    position = 0
    for i = 0 to index - 1
        if not adjusted or i >= m.startIndex then
            position = position + getItemExtent(i)
        end if
    next
    return position
end function

function getCurrentGroupExtent(visibleExtent = false as boolean, startIndex = m.startIndex as integer) as float
    extent = 0
    endIndex = startIndex + m.group.getChildCount() - 1
    for i = m.startIndex to endIndex
        itemSize = getItemSize(i)
        itemSpacing = getItemSpacing(i)
        extent = extent + itemSize[m.extentIndex] + itemSpacing
    next
    if visibleExtent then
        extent = extent + m.group.translation[m.extentIndex]
    end if
    return extent
end function

function getComponent(contentIndex as integer) as object
    component = m.components[contentIndex]
    content = m.top.content.getChild(contentIndex)
    if content <> invalid then
        if component = invalid then
            component = createObject("roSGNode", m.top.itemComponentName)
            itemSize = getItemSize(contentIndex)
            if component.hasField("width") then
                component.width = itemSize[0]
            end if
            if component.hasField("height") then
                component.height = itemSize[1]
            end if
            if component.hasField("itemFocused") then
                component.observeField("itemFocused", "onChildItemFocused")
            end if
            if component.hasField("itemSelected") then
                component.observeField("itemSelected", "onChildItemSelected")
            end if
        end if
        if component <> invalid then
            component.itemContent = content
        end if
        m.components[contentIndex] = component
    end if
    return component
end function

function getFirstVisibleItemInfo(fullyVisible = false as boolean) as object
    visibleStart = -m.group.translation[m.extentIndex]
    endIndex = m.startIndex + m.group.getChildCount() - 1
    
    info = {
        index: m.startIndex
        position: 0
        layoutPosition: 0
    }
    extent = 0
    for i = m.startIndex to endIndex
        itemExtent = getItemExtent(i)
        if extent + itemExtent > visibleStart then
            if not fullyVisible or extent >= visibleStart then
                info.index = i
                info.position = extent
                info.layoutPosition = getItemPosition(i)
                return info
            end if
        end if
        extent += itemExtent
    next
    return info
end function

function getLastVisibleItemInfo() as object
    visibleEnd = -m.group.translation[m.extentIndex] + m.top.width
    if m.top.layoutDirection = "vert" then
        visibleEnd = -m.group.translation[m.extentIndex] + m.top.height
    end if
    endIndex = m.startIndex + m.group.getChildCount() - 1
    
    info = {
        index: endIndex
        position: 0
    }
    extent = 0
    for i = m.startIndex to endIndex
        itemExtent = getItemExtent(i)
        if extent < visibleEnd and extent + itemExtent >= visibleEnd then
            info.index = 1
            info.position = extent
            return info
        end if
        extent += itemExtent
    next
    return endIndex
end function

sub adjustGroup()
    startItemInfo = getFirstVisibleItemInfo()
    m.startIndex = startItemInfo.index
    
    translation = m.group.translation
    translation[m.extentIndex] = translation[m.extentIndex] + startItemInfo.position
    m.group.translation = translation

    updateComponents(m.startIndex)
    
    m.currentOffset = m.group.translation[m.extentIndex]
end sub

sub onAnimationStateChanged()
    if m.scrollAnimation.state = "stopped" then
        adjustGroup()
        updateFocus()
    end if
end sub

sub onGroupTranslationChanged()
    'updateVisibleComponents()
end sub

sub updateFocus()
    focused = m.group.getChild(m.focusIndex - m.startIndex)
    if focused <> invalid then
        focused.setFocus(true)
    end if
end sub

sub updateStartIndex(index as integer, itemCount = m.top.visibleItemCount as integer)
    if m.startIndex <> index then
        m.startIndex = index
        updateComponents(m.startIndex, itemCount)
    end if
end sub

sub updateItemSpacing(startIndex = m.startIndex as integer)
    itemSpacings = []
    itemSpacings.Append(m.top.itemSpacings)
    for i = 0 to startIndex - 1
        if itemSpacings.count() <= 1 then
            exit for
        end if
        itemSpacings.shift()
    next
    m.group.itemSpacings = itemSpacings
end sub

sub updateComponents(startIndex as integer, count = m.top.visibleItemCount as integer)
    if startIndex > m.currentStartIndex then
        m.group.removeChildrenIndex(startIndex - m.currentStartIndex, 0)
        ?"removed";startIndex - m.currentStartIndex;" components from start"
        m.currentStartIndex = startIndex
    end if
    if startIndex + count < m.currentEndIndex then
        m.group.removeChildrenIndex(m.currentEndIndex - (startIndex + count), startIndex + count)
        ?"removed";m.currentEndIndex - (startIndex + count);" components from end"
        m.currentEndIndex = startIndex + count
    end if
    updateItemSpacing(startIndex)
    
    for i = startIndex to m.currentStartIndex - 1
       component = getComponent(i)
        if component <> invalid then
            ?"inserted 1 component at the start"
            m.group.insertChild(component, i - startIndex)
        else
            exit for
        end if
    next
    for i = (m.currentEndIndex + 1) to (startIndex + count)
        component = getComponent(i)
        if component <> invalid then
            m.group.appendChild(component)
        else
            exit for
        end if
    next
    m.currentStartIndex = startIndex
    m.currentEndIndex = startIndex + count
    ?"Component count: ";m.group.getChildCount()
end sub

sub onChildItemFocused(nodeEvent as object)
    m.top.itemFocused = m.focusIndex
    component = m.components[m.focusIndex]
    if component <> invalid then
        m.top.subItemFocused = [m.focusIndex, component.itemFocused]
    end if
end sub

sub onChildItemSelected(nodeEvent as object)
    m.top.itemSelected = m.focusIndex
    component = m.components[m.focusIndex]
    if component <> invalid then
        m.top.subItemSelected = [m.focusIndex, component.itemSelected]
    end if
end sub

