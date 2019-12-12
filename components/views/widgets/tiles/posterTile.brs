sub init()
    m.poster = m.top.findNode("poster")
    m.title = m.top.findNode("title")

    m.border = m.top.findNode("border")
    
    m.badge = m.top.findNode("badge")
    m.badgeText = m.top.findNode("badgeText")
end sub

sub onContentChanged()
    m.content = m.top.itemContent
    if m.content <> invalid then
        m.title.text = m.content.title
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
            
            ' this 1px adjustment is for 720p scaling
            ' logic would suggest -2, but Roku scaling has no logic
            ' trust me, it's correct ;)
            m.border.translation = [1, 1]
            m.border.width = m.top.width - 1
            m.border.height = m.top.height - 1
        end if
        updatePoster()
    end if
end sub

sub updatePoster()
    if m.poster.width > 0 and m.content <> invalid then
        m.poster.uri = getImageUrl(m.content.browseImageUrl, m.poster.width)
    end if
end sub