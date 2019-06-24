sub init()
    m.top.focusedBackgroundUri = "pkg:/images/frame_grid.9.png"
    m.top.backgroundColor = "0x1d1d1dff"
    m.top.focusedBackgroundColor = "0x1d1d1dff"
    m.top.width = 600
    m.top.height = 280
    
    m.group = m.top.findNode("group")
    m.group.translation = [m.top.width / 2, m.top.height / 2]

    m.logo = m.top.findNode("logo")
    m.frame = m.top.findNode("frame")
    m.frame.width = m.top.width
    m.frame.height = m.top.height
    m.frame.visible = false
end sub

sub onStationChanged()
    if m.top.station.affiliate <> invalid then
        m.logo.uri = m.top.station.affiliate.hdPosterUrl
    end if
end sub

sub onSelectedChanged()
    m.frame.visible = m.top.selected
end sub