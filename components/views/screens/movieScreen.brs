sub init()
    m.top.omniturePageType = "movies"

    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.background = m.top.findNode("background")
    m.poster = m.top.findNode("poster")
    m.movieTitle = m.top.findNode("movieTitle")
    m.movieSubtitle = m.top.findNode("movieSubtitle")
    m.movieDescription = m.top.findNode("movieDescription")
    
    m.buttons = m.top.findNode("buttons")
    m.buttons.observeField("buttonSelected", "onButtonSelected")
    
    m.watch = m.top.findNode("watch")
    m.trailer = m.top.findNode("trailer")

    m.top.setFocus(true)
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.buttons.setFocus(true)
    end if
end sub

sub onMovieIDChanged()
    m.global.showSpinner = true

    m.loadTask = createObject("roSGNode", "LoadMovieTask")
    m.loadTask.observeField("movie", "onMovieLoaded")
    m.loadTask.movieID = m.top.movieID
    m.loadTask.control = "run"
end sub

sub onMovieLoaded(nodeEvent as object)
    m.top.movie = nodeEvent.getData()
    m.loadTask = invalid
end sub

sub onMovieChanged()
    m.global.showSpinner = false
    movie = m.top.movie
    if movie <> invalid then
        pageName = "/movies/" + lCase(movie.title)
        m.top.omnitureName = pageName
        trackScreenView()

        m.movieTitle.text = movie.title
        m.movieSubtitle.text = movie.subtitle
        m.movieDescription.text = movie.description

        m.poster.uri = getImageUrl(movie.thumbnailUrl, m.poster.width)
        m.background.uri = getImageUrl(movie.thumbnailUrl, m.background.width)
        
        if movie.trailer = invalid then
            m.buttons.removeChild(m.trailer)
        end if
        
        if m.top.autoPlay then
            m.top.buttonSelected = m.watch.id
        end if
        
        if canWatch(movie, m.global) then
            m.watch.text = "WATCH"
        else
            m.watch.text = "SUBSCRIBE TO WATCH"
        end if

        m.buttons.visible = true
    else        
        dialog = createCbsDialog("Content Unavailable", "The content you are trying to play is currently unavailable. Please try again later.", ["OK"])
        dialog.observeField("buttonSelected", "onUnavailableDialogClosed")
        m.global.dialog = dialog
    end if
end sub

sub onUnavailableDialogClosed(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    if dialog <> invalid then
        dialog.close = true
    end if
    m.top.close = true
end sub

sub onButtonSelected(nodeEvent as object)
    button = m.buttons.getChild(m.buttons.buttonSelected)
    if button <> invalid then
        omnitureData = m.top.omnitureData
        if omnitureData = invalid then
            omnitureData = {}
        end if
        omnitureData["podText"] = lCase(button.text)
        omnitureData["podType"] = "overlay"
        m.top.omnitureData = omnitureData

        trackScreenAction("trackPodSelect", omnitureData)
        m.top.buttonSelected = button.id
    end if
end sub
