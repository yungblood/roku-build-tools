sub init()
    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.observeField("change", "onFocusChanged")
    
    m.buttonFocused = -1

    m.keyRepeatTimer = createObject("roSGNode", "Timer")
    m.keyRepeatTimer.observeField("fire", "onKeyRepeatTimerFired")
    
    m.itemFocused = -1
    m.keyPressed = ""
    
    m.firstFocus = true
    m.top.muteAudioGuide = true
    m.tts = createObject("roTextToSpeech")
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
    ?m.top.subtype();".onKeyEvent",key,press
    handled = false
    startTimer = false
    if press then
        key = lCase(key)
        if m.keyPressed = "" then
            ' delay longer on the initial key press
            m.keyRepeatTimer.duration = .5
        else
            m.keyRepeatTimer.duration = .05
        end if
        m.keyPressed = key

        if key = "left" and m.top.layoutDirection = "horiz" then
            startTimer = true
            if m.top.buttonFocused = -1 then
                handled = updateFocus(0)
            else
                handled = updateFocus(m.top.buttonFocused - 1)
            end if
        else if key = "right" and m.top.layoutDirection = "horiz" then
            startTimer = true
            if m.top.buttonFocused = -1 then
                handled = updateFocus(0)
            else
                handled = updateFocus(m.top.buttonFocused + 1)
            end if
        else if key = "up" and m.top.layoutDirection = "vert" then
            startTimer = true
            if m.top.buttonFocused = -1 then
                handled = updateFocus(0)
            else
                handled = updateFocus(m.top.buttonFocused - 1)
            end if
        else if key = "down" and m.top.layoutDirection = "vert" then
            startTimer = true
            if m.top.buttonFocused = -1 then
                handled = updateFocus(0)
            else
                handled = updateFocus(m.top.buttonFocused + 1)
            end if
        else if key = "ok" then
            if m.top.buttonFocused = -1 then
                handled = false
            else
                m.tts.flush()
                m.top.buttonSelected = m.top.buttonFocused
                handled = true
            end if
        end if
    else
        m.keyPressed = ""
        m.keyRepeatTimer.control = "stop"
    end if
    if handled and startTimer then
        m.keyRepeatTimer.control = "start"
    end if
    return handled
end function

sub onKeyRepeatTimerFired()
    if m.keyPressed <> "" then
        onKeyEvent(m.keyPressed, true)
    end if
end sub

sub readButton(index as integer)
    if not createObject("roDeviceInfo").isAudioGuideEnabled() then
        return
    end if
    button = m.top.getChild(index)
    if button <> invalid then
        text = button.tts
        if text = invalid or text = "" then
            text = button.text
        end if
        if text <> invalid and text <> "" then
            if not m.firstFocus then
                m.tts.flush()
            end if
            m.firstFocus = false

            componentType = "button"
            if button.ttsComponentType <> invalid and button.ttsComponentType <> "" then
                componentType = button.ttsComponentType
            end if
            m.tts.say(text + " " + componentType + " " + (index + 1).toStr() + " of " + m.top.getChildCount().toStr())
        end if
    end if
end sub

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
        if button.disabled = true and index < m.top.getChildCount() -1 then
            return updateFocus(index + 1)
        else
            if m.top.isInFocusChain() then
                button.setFocus(true)
                readButton(index)
            end if
            m.top.buttonFocused = index
            if m.buttonFocused <> -1 then
                m.top.buttonUnfocused = m.buttonFocused
            end if
            m.buttonFocused = m.top.buttonFocused
            return true
        end if
    end if
    return false
end function

sub jumpToIndex(nodeEvent as object)
    index = nodeEvent.getData()
    updateFocus(index)
    for i = 0 to m.top.getChildCount() - 1
        button = m.top.getChild(i)
        if button <> invalid and i <> index then
            button.setFocus(false)
        end if
    next
end sub

sub jumpToButton()
    buttonIndex = 0
    for i = 0 to m.top.getChildCount() - 1
        button = m.top.getChild(i)
        if button <> invalid and button.id = m.top.jumpToButton then
            buttonIndex = i
            exit for
        end if
    next
    m.top.jumpToIndex = buttonIndex
end sub
