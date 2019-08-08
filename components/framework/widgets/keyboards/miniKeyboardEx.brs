sub init()
    m.keyboard = findNodeOfType("VKBGrid", m.top)
    m.label = findNodeOfType("Label", m.top.textEditBox)
    
    m.keyFontSet = false
    m.textboxFontSet = false
end sub

sub onKeyFontChanged(nodeEvent as object)
    if not m.keyFontSet then
        m.keyFontSet = true
    end if
end sub

sub onTextboxFontChanged(nodeEvent as object)
    if not m.textboxFontSet then
        m.textboxFontSet = true
        m.label.observeField("font", "resetLabelFont")
    end if
    resetLabelFont()
end sub

sub resetLabelFont()
    m.label.font = m.top.textboxFont
end sub

sub onFocusBitmapBlendColorChanged(nodeEvent as object)
    m.keyboard.focusBitmapBlendColor = nodeEvent.getData()
end sub
