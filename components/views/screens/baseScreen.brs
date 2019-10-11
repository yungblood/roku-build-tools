sub init()
    m.top.visible = false
    m.visible = false
    m.top.observeField("visible", "onScreenVisibleChanged")
    m.top.omniturePageViewGuid = createObject("roDeviceInfo").getRandomUuid()
end sub

sub onScreenVisibleChanged()
    if m.top.visible and not m.visible then
        trackScreenView()
    end if
    m.visible = m.top.visible
end sub

