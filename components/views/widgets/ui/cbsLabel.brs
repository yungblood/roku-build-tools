sub init()
    m.top.observeField("color", "onColorChanged")
    m.top.observeField("text", "onTextChanged")

    m.top.themeColor = "milkyWay"
end sub

sub updateFont()
    font = getThemeFont(m.top.style, m.top.weight)
    m.top.font = font
    m.top.lineSpacing = font.lineSpacing
end sub

sub onTextChanged(nodeEvent as object)
    ' Giga is always uppercase, so transform it here, regardless
    ' of what case is passed in
    if lCase(m.top.style) = "giga" then
        m.top.text = uCase(m.top.text)
    end if
end sub

sub onThemeColorChanged(nodeEvent as object)
    color = nodeEvent.getData()
    m.top.color = getThemeColor(color)
end sub