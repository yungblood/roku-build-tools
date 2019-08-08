sub init()
    m.background = m.top.findNode("background")
    m.focusedBackground = m.top.findNode("focusedBackground")

    m.iconGroup = m.top.findNode("iconGroup")
    m.icon = m.top.findNode("icon")

    m.callSignFont = m.top.findNode("callSignFont")
    m.locationFont = m.top.findNode("locationFont")
    m.callSign = m.top.findNode("callSign")
    m.location = m.top.findNode("location")
end sub

sub onContentChanged(nodeEvent as object)
    content = nodeEvent.getData()
    if content <> invalid then
        m.callsign.text = content.title
        m.location.text = content.description
        
        if content.affiliate <> invalid then
            m.icon.uri = getImageUrl(content.affiliate.logoUrl, m.icon.width, m.icon.height) 
        end if
    end if
end sub

sub updateLayout()
    if m.top.width > 0 and m.top.height > 0 then
        m.background.width = m.top.width
        m.background.height = m.top.height
        m.focusedBackground.width = m.top.width
        m.focusedBackground.height = m.top.height
        
        m.iconGroup.translation = [110, m.top.height / 2]

        m.callSign.translation = [220, 0]
        m.callSign.width = m.top.width - m.callSign.translation[0] - 25
        m.callSign.height = m.top.height / 2 + 10
        m.location.translation = [220, m.top.height / 2 + 10]
        m.location.width = m.callSign.width
    end if
end sub

sub updateFocus()
    if m.top.gridHasFocus then
        m.focusedBackground.opacity = m.top.focusPercent
    else
        m.focusedBackground.opacity = 0
    end if
end sub