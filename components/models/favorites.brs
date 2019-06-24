sub init()
    m.top.title = "My CBS"
end sub

sub onAddFavorite(nodeEvent as object)
    if m.updateTask = invalid then
        m.updateTask = createObject("roSGNode", "AddToFavoritesTask")
        m.updateTask.observeField("favorites", "onFavoritesLoaded")
        m.updateTask.showID = nodeEvent.getData()
        m.updateTask.control = "run"
    end if
end sub

sub onRemoveFavorite()
    if m.updateTask = invalid then
        m.updateTask = createObject("roSGNode", "RemoveFromFavoritesTask")
        m.updateTask.observeField("favorites", "onFavoritesLoaded")
        m.updateTask.showID = nodeEvent.getData()
        m.updateTask.control = "run"
    end if
end sub

sub update()
    if m.updateTask = invalid then
        m.updateTask = createObject("roSGNode", "LoadFavoritesTask")
        m.updateTask.observeField("favorites", "onFavoritesLoaded")
        m.updateTask.control = "run"
    end if
end sub

sub onFavoritesLoaded(nodeEvent as object)
    m.updateTask = invalid
    m.top.content = nodeEvent.getData()
end sub

sub onContentChanged(nodeEvent as object)
    favorites = []
    favorites.append(nodeEvent.getData())
    if favorites.count() > 0 then
        shows = getGlobalField("showCache")
        for i = favorites.count() - 1 to 0 step -1
            favorite = favorites[i]
            if favorite <> invalid then
                show = shows[favorite.showID]
                if show = invalid then
                    favorites.delete(i)
                end if
            end if
        next
    end if
    m.top.removeChildrenIndex(m.top.getChildCount(), 0)
    m.top.appendChildren(favorites)
end sub