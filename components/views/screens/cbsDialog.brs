sub init()
    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.controls = m.top.findNode("controls")
    m.title = m.top.findNode("title")
    m.message = m.top.findNode("message")
    m.buttons = m.top.findNode("buttons")
    m.buttons.observeField("buttonSelected", "onButtonSelected")
    m.additionalContent = m.top.findNode("additionalContent")
    m.top.contentGroup = m.additionalContent
    
    m.tts = createObject("roTextToSpeech")
    
    m.buttonFont = m.top.findNode("buttonFont")
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        if createObject("roDeviceInfo").isAudioGuideEnabled() then
            m.tts.say(m.top.title + " " + m.top.message)
        end if
        m.buttons.setFocus(true)
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        if key = "back" then
            if m.top.allowBack then
                m.top.buttonSelected = "cancel"
            end if
        end if
    end if
    return true
end function

sub onButtonsChanged()
    m.buttons.removeChildrenIndex(m.buttons.getChildCount(), 0)
    buttons = m.top.buttons
    for each buttonText in buttons
        button = m.buttons.createChild("LabelButton")
        button.text = uCase(buttonText)
        button.textColor = "0xffffff99"
        button.focusedTextColor = "0xffffffff"
        button.width = 305
        button.height = 62
        button.font = m.buttonFont
        button.backgroundUri = "pkg:/images/frame_generic.9.png"
        button.focusedBackgroundUri = "pkg:/images/button_focus.9.png"
        button.processKeyEvents = false
    next
end sub

sub onButtonSelected(nodeEvent as object)
    m.top.buttonSelected = m.top.buttons[nodeEvent.getData()]
end sub