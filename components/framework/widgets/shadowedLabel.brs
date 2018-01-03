sub init()
    m.label = m.top.findNode("label")
    m.shadow = m.top.findNode("shadow")
end sub

sub onTextChanged()
    m.label.text = m.top.text
    m.shadow.text = m.top.text
end sub

sub onColorChanged()
    m.label.color = m.top.color
end sub

sub onShadowColorChanged()
    m.shadow.color = m.top.color
end sub

sub onFontChanged()
    m.label.font = m.top.font
    m.shadow.font = m.top.font
end sub

sub onHorizAlignChanged()
    m.label.horizAlign = m.top.horizAlign
    m.shadow.horizAlign = m.top.horizAlign
end sub

sub onVertAlignChanged()
    m.label.vertAlign = m.top.vertAlign
    m.shadow.vertAlign = m.top.vertAlign
end sub

sub onWidthChanged()
    m.label.width = m.top.width
    m.shadow.width = m.top.width
end sub

sub onHeightChanged()
    m.label.height = m.top.height
    m.shadow.height = m.top.height
end sub

sub onNumLinesChanged()
    m.label.numLines = m.top.numLines
    m.shadow.numLines = m.top.numLines
end sub

sub onMaxLinesChanged()
    m.label.maxLines = m.top.maxLines
    m.shadow.maxLines = m.top.maxLines
end sub

sub onWrapChanged()
    m.label.wrap = m.top.wrap
    m.shadow.wrap = m.top.wrap
end sub

sub onLineSpacingChanged()
    m.label.lineSpacing = m.top.lineSpacing
    m.shadow.lineSpacing = m.top.lineSpacing
end sub

sub onDisplayPartialLinesChanged()
    m.label.displayPartialLines = m.top.displayPartialLines
    m.shadow.displayPartialLines = m.top.displayPartialLines
end sub

sub onEllipsizeOnBoundaryChanged()
    m.label.ellipsizeOnBoundary = m.top.ellipsizeOnBoundary
    m.shadow.ellipsizeOnBoundary = m.top.ellipsizeOnBoundary
end sub

sub onTruncateOnDelimiterChanged()
    m.label.truncateOnDelimiter = m.top.truncateOnDelimiter
    m.shadow.truncateOnDelimiter = m.top.truncateOnDelimiter
end sub

sub onWordBreakCharsChanged()
    m.label.wordBreakChars = m.top.wordBreakChars
    m.shadow.wordBreakChars = m.top.wordBreakChars
end sub

sub onEllipsisTextChanged()
    m.label.ellipsisText = m.top.ellipsisText
    m.shadow.ellipsisText = m.top.ellipsisText
end sub
