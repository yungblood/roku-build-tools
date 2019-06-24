sub init()
    m.top.iconUri = ""
    m.top.dividerUri = ""
        
    m.top.buttonGroup.horizAlignment = "center"
    'm.top.buttonGroup.textFont = messageFont
    'm.top.buttonGroup.focusedTextFont = messageFont
    m.top.observeField("buttons", "onButtonsChanged")
end sub

sub onButtonsChanged()
    if m.pinPad = invalid then
        m.pinPad = createObject("roSGNode", "PinPadButton")
        m.pinPad.pinLength = m.top.textLength
        m.pinPad.observeField("pin", "onPinChanged")
    end if
    buttons = []
    buttons.append(m.top.buttons)
    foundPad = false
    for i = 0 to buttons.count() - 1
        buttonText = buttons[i]
        if buttonText = "[PinPad]" then
            foundPad = true
            exit for
        end if
    next
    if not foundPad then
        buttons.unshift("[PinPad]")
    end if
    m.top.buttons = buttons
    
    for i = 0 to buttons.count() - 1
        buttonText = buttons[i]
        if buttonText = "[PinPad]" then
            m.top.buttonGroup.replaceChild(m.pinPad, i)
            exit for
        end if
    next
end sub

sub onTextLengthChanged(nodeEvent as object)
    if m.pinPad <> invalid then
        m.pinPad.pinLength = nodeEvent.getData()
    end if
end sub

sub onPinChanged(nodeEvent as object)
    m.top.text = nodeEvent.getData()
end sub

