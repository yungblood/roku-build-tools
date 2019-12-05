sub init()
    m.top.omnitureName = "/movies/list/"
    m.top.omniturePageType = "category_door"
    m.top.omnitureSiteHier = "movies|other|movies listings|"
    
    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.menu = m.top.findNode("menu")
    m.menu.observeField("buttonSelected", "onMenuItemSelected")
    
    m.buttonFont = m.top.findNode("buttonFont")
'    m.groups = m.top.findNode("groups")
    m.grid = m.top.findNode("grid")
    m.grid.observeField("itemFocused", "onItemFocused")
    m.grid.observeField("itemSelected", "onItemSelected")

    m.movies = createObject("roSGNode", "MovieGroup")
    m.movies.observeField("change", "onMoviesLoaded")
    m.movies.loadIndex = 0
    m.grid.content = m.movies

    showSpinner(m.top, true)
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.grid.setFocus(true)
        setGlobalField("ignoreBack",false)
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

sub onMoviesLoaded(nodeEvent as object)
    ' Fire launch complete beacon (Roku cert requirement)
    ' Only fired by the scene if this is a deeplink
    setGlobalField("launchComplete", true)

    hideSpinner()
    m.movies.unobserveField("change")
end sub

sub onMenuItemSelected(nodeEvent as object)
    selection=nodeEvent.getData()
    if selection = "movies" then
        m.grid.setFocus(true)
        m.lastFocus = m.grid
    else
        m.top.menuItemSelected = selection
    end if
end sub

sub onItemFocused(nodeEvent as object)
    index = nodeEvent.getData()
    m.movies.loadIndex = index
end sub

sub onItemSelected(nodeEvent as object)
    index = nodeEvent.getData()
    movie = m.grid.content.getChild(index)
    if movie <> invalid then
        omnitureData = getOmnitureData(m.grid, index)
        m.top.omnitureData = omnitureData
        trackScreenAction("trackPodSelect", omnitureData, "/movies/list/" + lCase(movie.title))
        m.top.itemSelected = movie
    end if
end sub
