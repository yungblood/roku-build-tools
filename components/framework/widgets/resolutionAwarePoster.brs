sub init()
    m.top.observeField("bitmapWidth", "updateLayout")
    m.top.observeField("bitmapHeight", "updateLayout")
end sub

sub updateLayout()
    if m.top.width = 0 and m.top.height = 0 and m.top.bitmapWidth > 0 and m.top.bitmapHeight > 0 then
        scale = createObject("roDeviceInfo").getUIResolution().width / 1920
        m.top.width = m.top.bitmapWidth * scale
        m.top.height = m.top.bitmapHeight * scale
    end if
end sub

