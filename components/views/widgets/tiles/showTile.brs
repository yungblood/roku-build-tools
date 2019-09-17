sub init()
    m.poster = m.top.findNode("poster")
    m.title = m.top.findNode("title")
    m.count = m.top.findNode("count")
    
    m.whiteRect = m.top.findNode("whiteRect")
    m.blackRect = m.top.findNode("blackRect")
    
    m.metadata = m.top.findNode("metadata")
end sub

sub onContentChanged()
    show = m.top.itemContent
    if show <> invalid then
        if show.subtype() = "Favorite" then
            show = getShowFromCache(show.showID)
        end if
        m.title.text = uCase(show.title)
        m.poster.uri = getImageUrl(show.browseImageUrl, m.poster.width)
        m.count.text = ""
'        if show.episodeCount <> invalid and show.episodeCount > 0 then
'            m.count.text = show.episodeCount.toStr() + " Episode"
'            if show.episodeCount > 1 then
'                m.count.text = m.count.text + "s"
'            end if
'        else if show.clipCount <> invalid and show.clipCount > 0 then
'            m.count.text = show.clipCount.toStr() + " Clip"
'            if show.clipCount > 1 then
'                m.count.text = m.count.text + "s"
'            end if
'        end if
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

            m.metadata.translation = [0, m.top.height - 36]
            
            m.count.width = m.top.width
        end if
    end if
end sub
