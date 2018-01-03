sub init()
    m.top.title = "My CBS"
end sub

sub onAddFavorite(nodeEvent as object)
    m.addTask = createObject("roSGNode", "AddToFavoritesTask")
    m.addTask.observeField("favorites", "onFavoritesLoaded")
    m.addTask.showID = nodeEvent.getData()
    m.addTask.control = "run"
end sub

sub onRemoveFavorite()
    m.removeTask = createObject("roSGNode", "RemoveFromFavoritesTask")
    m.removeTask.observeField("favorites", "onFavoritesLoaded")
    m.removeTask.showID = nodeEvent.getData()
    m.removeTask.control = "run"
end sub

sub update()
    m.updateTask = createObject("roSGNode", "LoadFavoritesTask")
    m.updateTask.observeField("favorites", "onFavoritesLoaded")
    m.updateTask.control = "run"
end sub

sub onFavoritesLoaded(nodeEvent as object)
    m.updateTask = invalid
    m.removeTask = invalid
    m.addTask = invalid

    favorites = []
    favorites.append(nodeEvent.getData())
    if favorites.count() > 0 then
        shows = m.global.showCache
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