sub init()
    m.top.omnitureName = "/all access/upsell"
    m.top.omniturePageType = "signin"

    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.background = m.top.findNode("background")
    m.header = m.top.findNode("header")
    
    m.options = m.top.findNode("options")
    m.options.observeField("buttonSelected", "onOptionSelected")
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
    end if
    return false
end function

sub onFocusChanged()
    if m.top.hasFocus() then
        m.options.setFocus(true)
        setGlobalField("ignoreBack",false)
    end if
end sub

sub onOptionSelected(nodeEvent as object)
    option = m.options.getChild(nodeEvent.getData())
    m.top.buttonSelected = option.id
end sub



