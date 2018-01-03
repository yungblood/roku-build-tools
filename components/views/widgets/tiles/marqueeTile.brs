sub init()
    m.poster = m.top.findNode("poster")
    m.title = m.top.findNode("title")
end sub

sub onContentChanged()
    m.poster.uri = m.top.itemContent.hdPosterUrl
    m.title.text = m.top.itemContent.title
end sub

sub updateLayout()
    if m.top.width > 0 and m.top.height > 0 then
        m.poster.width = m.top.width
        m.poster.height = m.top.height
    end if
end sub

sub onCurrRectChanged()
    m.top.width = m.top.currRect.width
    m.top.height = m.top.currRect.height
    updateLayout()
end sub