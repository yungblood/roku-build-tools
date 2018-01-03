function init()
    ?"ContentAwareRow.init"
    m.top.observeField("focusedChild", "onFocusChanged")
end function

sub onFocusChanged()
    if m.top.hasFocus() then
        if m.row <> invalid then
            m.row.setFocus(true)
        end if
    end if
end sub

sub onContentChanged()
    if m.content = invalid or not m.content.isSameNode(m.top.itemContent) then
        if m.row <> invalid then
            m.row.unobserveField("itemSelected")
        end if
        m.top.removeChildrenIndex(m.top.getChildCount(), 0)
        m.content = m.top.itemContent
        contentType = m.content.subtype()
        if contentType = "Marquee" then
            m.row = m.top.createChild("MarqueeRow")
        else if contentType = "Section" then
            if m.content.excludeShow then
                m.row = m.top.createChild("FeaturedRow")
            else
                m.row = m.top.createChild("EpisodesRow")
            end if
        else if contentType = "Favorites" then
            m.row = m.top.createChild("FavoritesRow")
        else if contentType = "RecentlyWatched" then
            m.row = m.top.createChild("FeaturedRow")
        else if contentType = "Show" then
            m.row = m.top.createChild("ShowInfoRow")
        else
            ?"Unrecognized content type: ";contentType
        end if
        if m.row <> invalid then
            m.row.content = m.top.itemContent
            m.row.observeField("itemSelected", "onItemSelected")
            m.row.observeField("buttonSelected", "onButtonSelected")
        end if
    end if
end sub

sub onItemSelected()
    m.top.itemSelected = m.row.itemSelected
end sub

sub onButtonSelected(nodeEvent as object)
    m.top.buttonSelected = nodeEvent.getData()
end sub
