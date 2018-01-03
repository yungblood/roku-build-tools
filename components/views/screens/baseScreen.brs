sub init()
    m.top.visible = false
    m.visible = false
    m.top.observeField("visible", "onScreenVisibleChanged")
end sub

sub onScreenVisibleChanged()
    ?"onScreenVisibleChanged()",m.top.subtype(),m.top.visible
    if m.top.visible and not m.visible then
        trackScreenView()
    end if
    m.visible = m.top.visible
end sub

