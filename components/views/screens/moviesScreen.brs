sub init()
    m.top.omnitureName = "/movies/list/"
    m.top.omniturePageType = "category_door"
    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.menu = m.top.findNode("menu")
    m.menu.observeField("buttonSelected", "onMenuItemSelected")
    
    m.buttonFont = m.top.findNode("buttonFont")
'    m.groups = m.top.findNode("groups")
    m.grid = m.top.findNode("grid")
    m.grid.observeField("itemSelected", "onItemSelected")

    m.global.showSpinner = true
    
    m.contentTask = createObject("roSGNode", "MoviesScreenTask")
    m.contentTask.observeField("movies", "onMoviesLoaded")
    m.contentTask.control = "run"
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.grid.setFocus(true)
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        if key = "down" then
            if m.menu.isInFocusChain() then
                m.grid.setFocus(true)
                return true
            end if
        else if key = "up" then
            if m.grid.isInFocusChain() then
                m.menu.setFocus(true)
                return true
            end if
        end if
    end if
    return false
end function

sub onMoviesLoaded()
    movies = m.contentTask.movies
    content = createObject("roSGNode", "ContentNode")
    content.title = "movies"
    content.appendChildren(movies)
    m.grid.content = content
    
    m.global.showSpinner = false
end sub

sub onMenuItemSelected(nodeEvent as object)
    m.top.menuItemSelected = nodeEvent.getData()
end sub

sub onItemSelected()
    index = m.grid.itemSelected
    movie = m.grid.content.getChild(index)
    if movie <> invalid then
        omnitureData = getOmnitureData(m.grid, index)
        m.top.omnitureData = omnitureData
        trackScreenAction("trackPodSelect", omnitureData, "/movies/list/" + lCase(movie.title))
        m.top.itemSelected = movie
    end if
end sub
