sub init()
    m.titleFont = m.top.findNode("titleFont")
    m.titleFontBold = m.top.findNode("titleFontBold")
    m.title = m.top.findNode("title")
end sub

sub onItemContentChanged()
    item = m.top.itemContent
    if item <> invalid then
        m.title.text = item.title
    else
        m.title.text = ""
    end if
end sub

sub onFocusPercentChanged()
    if (m.top.focusPercent = 1 and m.top.listHasFocus) or (m.top.itemContent <> invalid and m.top.itemContent.selected = true) then
        m.title.font = m.titleFontBold
    else
        m.title.font = m.titleFont
    end if
end sub
