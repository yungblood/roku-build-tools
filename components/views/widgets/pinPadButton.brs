sub init()
    m.top.observeField("focusedChild", "onFocusChanged")

    m.pinPadGroup = m.top.findNode("pinPadGroup")
    m.textbox = m.top.findNode("textbox")
    m.pinPad = m.top.findNode("pinPad")
    m.pinPad.observeField("pin", "onPinChanged")
    
    for i = m.top.getChildCount() - 1 to 0 step -1
        child = m.top.getChild(i)
        if child.id <> "pinPadGroup" then
            m.top.removeChild(child)
        end if
    next
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.pinPad.setFocus(true)
    end if
end sub

sub onPinChanged()
    m.textbox.text = m.pinPad.pin
end sub