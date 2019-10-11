sub init()
    m.top.focusedBackgroundUri = "pkg:/images/frame_grid.9.png"
    m.top.backgroundColor = "0x2b2b2bff"
    m.top.focusedBackgroundColor = "0x2b2b2bff"
    m.top.width = 384
    m.top.height = 216
    
    m.group = m.top.findNode("group")
    m.group.translation = [m.top.width / 2, m.top.height / 2 + 5]

    m.logo = m.top.findNode("logo")
    m.logo.width = m.top.width
    
    m.title = m.top.findNode("title")
    m.title.width = m.top.width

    m.frame = m.top.findNode("frame")
    m.frame.width = m.top.width
    m.frame.height = m.top.height
    m.frame.visible = false
end sub

sub onStationChanged()
    if m.top.station.affiliate <> invalid then
        m.logo.uri = m.top.station.affiliate.hdPosterUrl
        m.title.text = m.top.station.title
    end if
end sub

sub onSelectedChanged()
    m.frame.visible = m.top.selected
end sub