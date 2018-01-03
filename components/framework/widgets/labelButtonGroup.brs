sub init()
    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.observeField("change", "onFocusChanged")
    
    m.buttonFocused = -1
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        if m.top.buttonFocused = -1 then
            updateFocus(0)
        else
            updateFocus(m.top.buttonFocused)
        end if
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        key = lCase(key)
        if key = "left" and m.top.layoutDirection = "horiz" then
            if m.top.buttonFocused = -1 then
                return updateFocus(0)
            else
                return updateFocus(m.top.buttonFocused - 1)
            end if
        else if key = "right" and m.top.layoutDirection = "horiz" then
            if m.top.buttonFocused = -1 then
                return updateFocus(0)
            else
                return updateFocus(m.top.buttonFocused + 1)
            end if
        else if key = "up" and m.top.layoutDirection = "vert" then
            if m.top.buttonFocused = -1 then
                return updateFocus(0)
            else
                return updateFocus(m.top.buttonFocused - 1)
            end if
        else if key = "down" and m.top.layoutDirection = "vert" then
            if m.top.buttonFocused = -1 then
                return updateFocus(0)
            else
                return updateFocus(m.top.buttonFocused + 1)
            end if
        else if key = "ok" then
            if m.top.buttonFocused = -1 then
                return false
            else
                m.top.buttonSelected = m.top.buttonFocused
                return true
            end if
        end if
    end if
    return false
end function

function updateFocus(index as integer) as boolean
    if m.top.wrap then
        if index < 0 then
            index = m.top.getChildCount() - 1
        else if index >= m.top.getChildCount() then
            index = 0
        end if
    end if
    button = m.top.getChild(index)
    if button <> invalid then
        if m.top.isInFocusChain() then
            button.setFocus(true)
        end if
        m.top.buttonFocused = index
        if m.buttonFocused <> -1 then
            m.top.buttonUnfocused = m.buttonFocused
        end if
        m.buttonFocused = m.top.buttonFocused
        return true
    end if
    return false
end function

sub jumpToIndex()
    updateFocus(m.top.jumpToIndex)
end sub

sub jumpToButton()
    buttonIndex = 0
    for i = 0 to m.top.getChildCount() - 1
        button = m.top.getChild(i)
        if button <> invalid and button.id = m.top.jumpToButton then
            buttonIndex = i
        else
            button.setFocus(false)
        end if
    next
    m.top.jumpToIndex = buttonIndex
end sub
