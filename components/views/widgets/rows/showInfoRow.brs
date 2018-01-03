function init()
    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.dynamicPlay = m.top.findNode("dynamicPlay")
    m.dynamicPlay.observeField("visible", "onDynamicPlayVisibleChanged")
    m.dynamicPlay.observeField("itemSelected", "onDynamicPlaySelected")
    m.showInfo = m.top.findNode("showInfo")
    m.showInfo.observeField("buttonSelected", "onButtonSelected")
end function

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        if key = "right" then
            if m.dynamicPlay.isInFocusChain() then
                m.showInfo.setFocus(true)
                return true
            end if
        else if key = "left" then
            if m.showInfo.isInFocusChain() and m.dynamicPlay.visible then
                m.dynamicPlay.setFocus(true)
                return true
            end if
        end if
    end if
    return false
end function

sub onFocusChanged()
    if m.top.hasFocus() then
        if m.dynamicPlay.visible then
            m.dynamicPlay.setFocus(true)
        else
            m.showInfo.setFocus(true)
        end if
    end if
end sub

sub onContentChanged()
    if m.show = invalid or not m.show.isSameNode(m.top.content) then
        m.show = m.top.content
        m.dynamicPlay.show = m.show
        m.showInfo.show = m.show
    end if
end sub

sub onDynamicPlayVisibleChanged(nodeEvent as object)
    if m.top.isInFocusChain() then
        if m.dynamicPlay.visible then
            m.dynamicPlay.setFocus(true)
        else
            m.showInfo.setFocus(true)
        end if
    end if
end sub

sub onDynamicPlaySelected(nodeEvent as object)
    m.top.itemSelected = 0
end sub

sub onButtonSelected(nodeEvent as object)
    m.top.buttonSelected = nodeEvent.getData()
end sub
