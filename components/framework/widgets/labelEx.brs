sub init()
    m.background = m.top.findNode("background")
    m.label = m.top.findNode("label")
    m.label.observeField("text", "updateLayout")
    m.label.observeField("font", "updateLayout")
end sub

sub onWidthChanged()
    m.label.width = m.top.width - (m.top.padding * 2)
    updateLayout()
end sub

sub onHeightChanged()
    m.label.height = m.top.height - (m.top.padding * 2)
    updateLayout()
end sub

sub onPaddingChanged()
    m.label.translation = m.top.padding
    updateLayout()
end sub

sub updateLayout()
    rect = m.label.localBoundingRect()
    m.background.width = rect.width + (m.top.padding[0] * 2)
    m.background.height = rect.height  + (m.top.padding[1])
end sub