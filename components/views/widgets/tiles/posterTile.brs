sub init()
    m.poster = m.top.findNode("poster")
    m.title = m.top.findNode("title")

    m.whiteRect = m.top.findNode("whiteRect")
    m.blackRect = m.top.findNode("blackRect")
end sub

sub onContentChanged()
    content = m.top.itemContent
    if content <> invalid then
        m.title.text = uCase(content.title)
        m.poster.uri = getImageUrl(content.browseImageUrl, m.poster.width)
    end if
end sub

sub updateLayout()
    if m.top.width > 0 and m.top.height > 0 then
        if m.poster.width <> m.top.width or m.poster.height <> m.top.height then
            m.poster.width = m.top.width
            m.poster.height = m.top.height
            m.title.width = m.top.width - 40
            m.title.height = m.top.height - 40
            
            m.whiteRect.width = m.top.width - 2
            m.whiteRect.height = m.top.height - 2
            m.blackRect.width = m.top.width - 6
            m.blackRect.height = m.top.height - 6
        end if
    end if
end sub
