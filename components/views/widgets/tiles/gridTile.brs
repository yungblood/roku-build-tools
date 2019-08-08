sub init()
    m.tile = invalid
end sub

sub onContentChanged()
    if m.content = invalid or not m.content.isSameNode(m.top.itemContent) then
        m.top.removeChildrenIndex(m.top.getChildCount(), 0)

        m.content = m.top.itemContent
        parent = m.content.getParent()
        if parent <> invalid then
            contentType = parent.subtype()
            if contentType = "Section" and parent.title.inStr("Movies") >= 0 then
                m.tile = m.top.createChild("PosterTile")
            else if contentType = "Favorites" then
                m.tile = m.top.createChild("FavoriteTile")
            else if contentType = "LiveTVChannels" then
                m.tile = m.top.createChild("ChannelTile")
            else if contentType = "RecentlyWatched" or contentType = "ContinueWatching" then
                m.tile = m.top.createChild("FeaturedEpisodeTile")
            else if m.content.subtype() = "Show" or m.content.subtype() = "RelatedShow" or m.content.subtype() = "ShowGroupItem" then
                m.tile = m.top.createChild("PosterTile")
            else
                if parent.displaySeasons = true then
                    m.tile = m.top.createChild("EpisodeTile")
                else
                    m.tile = m.top.createChild("FeaturedEpisodeTile")
                end if
            end if
        else
            m.tile = m.top.createChild("EpisodeTile")
        end if
        if m.tile <> invalid then
            m.tile.itemContent = m.content
        end if
    end if
    updateLayout()
end sub

sub updateLayout()
    if m.tile <> invalid and m.top.width <> 0 and m.top.height <> 0 then
        m.tile.width = m.top.width
        m.tile.height = m.top.height
    end if
end sub