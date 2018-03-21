sub init()
    m.tile = invalid
end sub

sub onContentChanged()
    if m.content = invalid or not m.content.isSameNode(m.top.itemContent) then
        m.top.removeChildrenIndex(m.top.getChildCount(), 0)

        m.content = m.top.itemContent
        parent = m.content.getParent()
        if parent <> invalid then
'        if contentType = "Section" then
'            if content.title.inStr("Movies") >= 0 then
'                row = m.list.createChild("PostersRow")
'            else
'                if content.excludeShow then
'                    row = m.list.createChild("FeaturedRow")
'                else
'                    row = m.list.createChild("EpisodesRow")
'                end if
'            end if
'        else if contentType = "Favorites" then
'            row = m.list.createChild("FavoritesRow")
'        else if contentType = "RecentlyWatched" then
'            row = m.list.createChild("RecentlyWatchedRow")
'        else if contentType = "Show" then
'            row = m.list.createChild("ShowInfoRow")
'        else
'            ?"Unrecognized content type: ";contentType
'        end if
'        if row <> invalid then
'            if content.subtype() = "Section" and i <= m.concurrentRowLoads then
'                content.loadIndex = 0
'            end if
'            row.content = content
'            row.observeField("itemSelected", "onItemSelected")
'            row.observeField("visible", "updateRowLayout")
'        end if
            contentType = parent.subtype()
            if contentType = "Section" and parent.title.inStr("Movies") >= 0 then
'                m.tile = m.top.createChild("FeaturedEpisodeTile")
                m.tile = m.top.createChild("PosterTile")
            else if contentType = "Favorites" then
                m.tile = m.top.createChild("FavoriteTile")
            else if contentType = "RecentlyWatched" then
                m.tile = m.top.createChild("FeaturedEpisodeTile")
            else if m.content.subtype() = "RelatedShow" then
                m.tile = m.top.createChild("PosterTile")
            else
                m.tile = m.top.createChild("FeaturedEpisodeTile")
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