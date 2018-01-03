sub init()
    m.top.buttonGroup.observeField("change", "onButtonGroupChanged")
    m.top.buttonGroup.observeField("focusedChild", "onFocusChanged")
    
    m.top.buttonGroup.horizAlignment = "center"
    
    m.pinPad = CreateObject("roSGNode", "PinPad")
    m.pinPad.showPinDisplay = false    
end sub

sub onButtonGroupChanged()
    ?"buttonGroupChanged",m.top.buttonGroup.change
    m.top.buttonGroup.insertChild(m.pinPad, 0)
end sub

sub onFocusChanged()
    ?"Focused: ",m.top.buttonGroup.focusedChild.subType()
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    ?"DateDialog.onKeyEvent.";key,press
    if press then
        if key = "up" then
            m.pinPad.setFocus(true)
        end if
    end if
    return true
end function
