sub init()
    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.itemIndex = 0
    
    m.list = m.top.findNode("list")
    m.list.observeField("currFocusItemIndex", "onCurrFocusItemIndex")
    
    m.components = m.top.findNode("components")
    m.components.observeField("change", "onChildrenChanged")
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        updateFocus(m.list.currFocusItemIndex)
    end if
end sub

sub onChildrenChanged()
    if m.top.isInFocusChain() then
        updateFocus(m.list.currFocusItemIndex)
    end if
end sub

sub updateFocus(index as integer)
    itemComponent = m.components.getChild(index)
    if itemComponent <> invalid then
        itemComponent.setFocus(true)
    end if
'    if m.list.content <> invalid then
'        item = m.list.content.getChild(index)
'        if item <> invalid and item.itemComponent <> invalid then
'            item.itemComponent.setFocus(true)
'        end if
'    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    '?"ScrollableList.onKeyEvent: ";key,press
    if press then
        if key = "down" then
            itemIndex = m.itemIndex + 1
            if itemIndex >= m.list.content.getChildCount() then
                itemIndex = m.list.content.getChildCount() - 1
            end if
            if itemIndex <> m.itemIndex then
                m.itemIndex = itemIndex
                if m.itemIndex = 1 then
                    ?"animating to intermediate"
                    'm.list.jumpToItem = m.itemIndex
                    m.list.duration = m.top.duration * 2
                    m.list.animateToTargetSet = m.forwardIntermediateTargetSet
                    m.list.jumpToItem = m.itemIndex
                else if m.itemIndex = m.list.content.getChildCount() - 1 then
                    ?"animating to final"
                    'm.finalTargetSet.focusIndex = 0
                    'm.list.animateToTargetSet = m.finalTargetSet
                    m.list.animateToTargetSet = m.finalTargetSet
                    m.list.jumpToItem = m.itemIndex
                else
                    m.list.duration = m.top.duration
                    m.list.animateToItem = m.itemIndex
                end if
                return true
            end if
        else if key = "up" then
            itemIndex = m.itemIndex - 1
            if itemIndex < 0 then
                itemIndex = 0
            end if
            if itemIndex <> m.itemIndex then
                m.itemIndex = itemIndex
                if m.itemIndex = m.list.content.getChildCount() - 2 then
                ?"animating to intermediate"
                    m.list.duration = m.top.duration * 2
                    m.list.animateToTargetSet = m.forwardIntermediateTargetSet
                    m.list.jumpToItem = m.itemIndex
                else if m.itemIndex = 0 then
                ?"animating to initial"
                    m.list.duration = m.top.duration * 2
                    m.list.animateToTargetSet = m.initialTargetSet
                    m.list.jumpToItem = m.itemIndex
                else
                    m.list.duration = m.top.duration
                    m.list.animateToItem = m.itemIndex
                end if
                return true
            end if
        end if
    end if
    return false
end function

sub onCurrFocusItemIndex()
    if m.list.currFocusItemIndex = int(m.list.currFocusItemIndex) then
        updateFocus(m.list.currFocusItemIndex)
    end if
end sub

sub onContentChanged()
    m.itemIndex = 0' m.top.content.getChildCount() - 2

    ' m.top.removeChildrenIndex(m.top.getChildCount(), 0)
    controllerContent = createObject("roSGNode", "ContentNode")
    if m.top.contentField = "" then
        for i = 0 to m.top.content.getChildCount() - 1
            listItem = controllerContent.createChild("ScrollableListItem")
            listItem.observeField("itemSelected", "onItemSelected")
            listItem.observeField("buttonSelected", "onButtonSelected")
            listItem.index = i
            listItem.itemContent = m.top.content.getChild(i)
            listItem.parentGroup = m.components
            listItem.itemComponentName = m.top.itemComponentName
        next
    else
        field = m.top.content.getField(m.top.contentField)
        if field <> invalid then
            m.top.content.unobserveField(m.top.contentField)
            m.top.content.observeField(m.top.contentField, "onFieldContentChanged")
            for i = 0 to field.count() - 1
                listItem = controllerContent.createChild("ScrollableListItem")
                listItem.observeField("itemSelected", "onItemSelected")
                listItem.observeField("buttonSelected", "onButtonSelected")
                listItem.index = i
                listItem.itemContent = field[i]
                listItem.parentGroup = m.components
                listItem.itemComponentName = m.top.itemComponentName
            next
        end if
    end if
    m.list.content = controllerContent
    m.list.targetSet = m.initialTargetSet
    m.list.jumpToItem = m.itemIndex
end sub

sub onFieldContentChanged() 
    onContentChanged()
end sub

sub onItemSelected(nodeEvent as object)
    item = nodeEvent.getRoSGNode()
    if item <> invalid then
        m.top.listItemSelected = [item.index, nodeEvent.getData()]
        return
    end if
end sub

sub onButtonSelected(nodeEvent as object)
    m.top.buttonSelected = nodeEvent.getData()
end sub

sub onInitialPositionsChanged()
    m.initialTargetSet = getTargetSet(m.top.initialPositions)
    m.initialTargetSet.focusIndex = 1
end sub

sub onForwardIntermediatePositionsChanged()
    m.forwardIntermediateTargetSet = getTargetSet(m.top.forwardIntermediatePositions)
    m.forwardIntermediateTargetSet.focusIndex = 2
end sub

sub onReverseIntermediatePositionsChanged()
    m.reverseIntermediateTargetSet = getTargetSet(m.top.reverseIntermediatePositions)
    m.reverseIntermediateTargetSet.focusIndex = 2 'm.top.finalPositions.count() - 2
end sub

sub onFinalPositionsChanged()
    m.finalTargetSet = getTargetSet(m.top.finalPositions)
    m.finalTargetSet.focusIndex = 3 'm.top.finalPositions.count() - 1
end sub

function getTargetSet(positions as object) as object
    targetSet = createObject("roSGNode", "TargetSet")
    targetRects = []
    for each position in positions
        targetRects.push({
            x: 0
            y: position
            width: 1
            height: 1
        })
    next
    targetSet.targetRects = targetRects
    return targetSet
end function
