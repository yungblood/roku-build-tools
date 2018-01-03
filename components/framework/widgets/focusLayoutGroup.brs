sub init()
    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.observeField("change", "onFocusChanged")
    m.top.observeField("itemFocused", "onItemFocused")

    m.keyRepeatTimer = createObject("roSGNode", "Timer")
    m.keyRepeatTimer.observeField("fire", "onKeyRepeatTimerFired")
    
    m.itemFocused = -1
    m.keyPressed = ""
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        if m.top.itemFocused = -1 then
            updateFocus(0, true)
        else
            updateFocus(m.top.itemFocused, true)
        end if
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    handled = false
    if m.top.processKeyEvents then
        if press then
            key = lCase(key)
            if m.keyPressed = "" then
                ' delay longer on the initial key press
                m.keyRepeatTimer.duration = .5
            else
                m.keyRepeatTimer.duration = .05
            end if
            m.keyPressed = key
            startTimer = false
            if key = "left" and m.top.layoutDirection = "horiz" then
                startTimer = true
                if m.top.itemFocused = -1 then
                    handled = updateFocus(0)
                else
                    handled = updateFocus(m.top.itemFocused - 1)
                end if
            else if key = "right" and m.top.layoutDirection = "horiz" then
                startTimer = true
                if m.top.itemFocused = -1 then
                    handled = updateFocus(0)
                else
                    handled = updateFocus(m.top.itemFocused + 1)
                end if
            else if key = "up" and m.top.layoutDirection = "vert" then
                startTimer = true
                if m.top.itemFocused = -1 then
                    handled = updateFocus(0)
                else
                    handled = updateFocus(m.top.itemFocused - 1)
                end if
            else if key = "down" and m.top.layoutDirection = "vert" then
                startTimer = true
                if m.top.itemFocused = -1 then
                    handled = updateFocus(0)
                else
                    handled = updateFocus(m.top.itemFocused + 1)
                end if
            else if key = "rewind" and m.top.allowPaging then
                startTimer = true
                if m.top.itemFocused = -1 then
                    handled = updateFocus(0)
                else
                    handled = updateFocus(m.top.itemFocused - m.top.pageSize)
                end if
            else if key = "fastforward" and m.top.allowPaging then
                startTimer = true
                if m.top.itemFocused = -1 then
                    handled = updateFocus(0)
                else
                    handled = updateFocus(m.top.itemFocused + m.top.pageSize)
                end if
            else if key = "ok" then
                m.top.itemSelected = m.top.itemFocused
                handled = true
            end if
        else
            m.keyPressed = ""
            m.keyRepeatTimer.control = "stop"
        end if
        if handled and startTimer then
            m.keyRepeatTimer.control = "start"
        end if
    end if
    return handled
end function

sub onKeyRepeatTimerFired()
    if m.keyPressed <> "" then
        onKeyEvent(m.keyPressed, true)
    end if
end sub

function updateFocus(index as integer, force = false as boolean) as boolean
    if m.top.wrap then
        if index < 0 then
            index = m.top.getChildCount() - 1
        else if index >= m.top.getChildCount() then
            index = 0
        end if
    else if index >= m.top.getChildCount() then
        index = m.top.getChildCount() - 1
    else if index < 0 then
        index = 0
    end if
    if not force and index = m.top.itemFocused then
        return false
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

sub jumpToIndex()
    updateFocus(m.top.jumpToIndex)
end sub
