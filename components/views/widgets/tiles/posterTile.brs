sub init()
    m.poster = m.top.findNode("poster")
    m.title = m.top.findNode("title")

    m.whiteRect = m.top.findNode("whiteRect")
    m.blackRect = m.top.findNode("blackRect")
    
    m.badge = m.top.findNode("badge")
    m.badgeText = m.top.findNode("badgeText")
end sub

sub onContentChanged()
    m.content = m.top.itemContent
    if m.content <> invalid then
        m.title.text = uCase(m.content.title)
        m.badge.visible = (m.content.hasNewEpisodes = true)
        updatePoster()
    end if
end sub

sub updateLayout()
    if m.top.width > 0 and m.top.height > 0 then
        if m.poster.width <> m.top.width or m.poster.height <> m.top.height then
            m.poster.width = m.top.width
            m.poster.height = m.top.height
            m.title.width = m.top.width - 40
            m.title.height = m.top.height - 40
            
            m.badge.width = m.top.width
            m.badgeText.width = m.top.width
            
            m.whiteRect.width = m.top.width - 2
            m.whiteRect.height = m.top.height - 2
            m.blackRect.width = m.top.width - 6
            m.blackRect.height = m.top.height - 6
        end if
        updatePoster()
    end if
end sub

sub updatePoster()
    if m.poster.width > 0 and m.content <> invalid then
        m.poster.uri = getImageUrl(m.content.browseImageUrl, m.poster.width)
    end if
end sub