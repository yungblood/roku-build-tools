sub init()
    m.fontPath = "pkg:/fonts/Proxima Nova A {WEIGHT}.ttf"
end sub

sub onFontInfoChanged(nodeEvent as object)
    fontInfo = nodeEvent.getData()

    m.top.weight = fontInfo.weight
    m.top.size = fontInfo.size
    m.top.lineSpacing = fontInfo.lineSpacing
end sub

sub onWeightChanged(nodeEvent as object)
    weight = nodeEvent.getData()
    m.top.uri = m.fontPath.replace("{WEIGHT}", weight)
end sub