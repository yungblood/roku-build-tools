sub init()
    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.observeField("change", "onFocusChanged")
    
    m.itemFocused = -1
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        if m.top.itemFocused = -1 then
            updateFocus(getAdjustedIndex(0))
        else
            updateFocus(m.top.itemFocused)
        end if
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        key = lCase(key)
        if key = m.top.reverseKey then
            if m.top.itemFocused = -1 then
                return updateFocus(getAdjustedIndex(0))
            else
                return incrementFocus(-1)
            end if
        else if key = m.top.advanceKey then
            if m.top.itemFocused = -1 then
                return updateFocus(getAdjustedIndex(0))
            else
                return incrementFocus(1)
            end if
        end if
    end if
    return false
end function

function incrementFocus(increment as integer) as boolean
    count = 0
    if increment > 0 then
        for i = m.top.itemFocused + 1 to m.top.getChildCount() - 1
            item = m.top.getChild(i)
            if item.visible then
                count++
                if count = increment then
                    return updateFocus(i)
                end if
            end if
        next
    else if increment < 0 then
        for i = m.top.itemFocused - 1 to 0 step - 1
            item = m.top.getChild(i)
            if item.visible then
                count++
                if count = abs(increment) then
                    return updateFocus(i)
                end if
            end if
        next
    end if
end function

function updateFocus(index as integer) as boolean
    if m.top.wrap then
        if index < 0 then
            index = m.top.getChildCount() - 1
        else if index >= m.top.getChildCount() then
            index = 0
        end if
    end if
    item = m.top.getChild(index)
    if item <> invalid then
        if m.top.isInFocusChain() then
            item.setFocus(true)
        end if
        m.top.itemFocused = index
        if m.itemFocused <> -1 then
            m.top.itemUnfocused = m.itemFocused
        end if
        m.itemFocused = m.top.itemFocused
        return true
    end if
    return false
end function

function getAdjustedIndex(index as integer) as integer
    adjustedIndex = -1
    steps = -1
    for i = 0 to m.top.getChildCount() - 1
        item = m.top.getChild(i)
        if item.visible then
            steps++
            if steps = index then
                adjustedIndex = i
                exit for
            end if
        end if
    next
    return adjustedIndex
end function

sub jumpToIndex()
    updateFocus(m.top.jumpToIndex)
end sub
