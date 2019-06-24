sub init()
    m.poster = m.top.findNode("poster")
    m.title = m.top.findNode("title")

    m.whiteRect = m.top.findNode("whiteRect")
    m.blackRect = m.top.findNode("blackRect")
end sub

sub onContentChanged()
    if m.content = invalid or not m.content.isSameNode(m.top.itemContent) then
        m.content = m.top.itemContent
        if m.content <> invalid then
            updateMetadata()
        end if
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
            m.blackRect.width = m.top.width - 8
            m.blackRect.height = m.top.height - 8
            
            updateMetadata()
        end if
    end if
end sub

sub updateMetadata()
    content = m.top.itemContent
    if content <> invalid and m.poster.width > 0 and m.poster.height > 0 then
        showCache = getGlobalField("showCache")
        show = showCache[content.showID]
        if show <> invalid then
            m.title.text = uCase(show.title)
            m.poster.uri = getImageUrl(show.myCbsImageUrl, m.poster.width)
        end if
    end if
end sub
