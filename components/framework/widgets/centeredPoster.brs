sub init()
    m.group = m.top.findNode("group")
end sub

sub updatePosition()
    if m.top.width <> invalid and m.top.width > 0 then
        m.group.translation = [m.top.width / 2, m.top.height / 2]
    end if
end sub
