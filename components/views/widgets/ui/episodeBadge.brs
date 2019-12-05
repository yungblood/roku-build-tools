sub init()
    m.padding = 24

    m.background = m.top.findNode("background")
    m.textGroup = m.top.findNode("textGroup")
    m.badgeText = m.top.findNode("badgeText")

    uiRes = createObject("roDeviceInfo").getUIResolution()
    m.topPadding = 1
    if uiRes.name = "HD" then
        m.topPadding = -1
    end if
end sub

sub updateLayout()
    m.background.height = m.top.height
    m.textGroup.translation = [m.background.width / 2, m.top.height / 2 + m.topPadding]
end sub

sub onTextChanged(nodeEvent as object)
    text = nodeEvent.getData()
    m.badgeText.text = text
    m.background.width = m.badgeText.boundingRect().width + (m.padding * 2)
    
    updateLayout()
end sub
