sub init()
    m.top.omniturePageType = "movies"

    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.observeField("visible", "onVisibleChanged")
    
    m.heroImageUrl = ""

    m.background = m.top.findNode("background")
    m.poster = m.top.findNode("poster")
    m.movieTitle = m.top.findNode("movieTitle")
    m.movieSubtitle = m.top.findNode("movieSubtitle")
    m.movieDescription = m.top.findNode("movieDescription")
    m.progressBar = m.top.findNode("progressBar")
    
    m.resume = m.top.findNode("resume")
    m.watch = m.top.findNode("watch")
    m.trailer = m.top.findNode("trailer")

    m.buttons = m.top.findNode("buttons")
    m.buttons.observeField("buttonSelected", "onButtonSelected")

    m.tts = createObject("roTextToSpeech")

    m.firstLoad = true
    m.top.setFocus(true)
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.buttons.setFocus(true)
        setGlobalField("ignoreBack",false)
    end if
end sub

sub onVisibleChanged()
    if m.top.visible then
        m.background.uri = m.heroImageUrl
        ' refresh the movie for updated resume point
        if not m.firstLoad then
            loadMovie(m.top.movieID)
        end if
    else
        ' unload the background image to free up some memory
        ' before playback
        m.heroImageUrl = m.background.uri
        m.background.uri = ""
    end if
end sub

sub onMovieIDChanged(nodeEvent as object)
    movieID = nodeEvent.getData()
    if not isNullOrEmpty(movieID) then
        loadMovie(movieID)
    end if
end sub

sub onMovieLoaded(nodeEvent as object)
    movie = nodeEvent.getData()
    task = nodeEvent.getRoSGNode()
    if movie <> invalid then
        m.top.movie = movie
    else if task.errorCode > 0 then
        showApiError(true)
    else
        m.top.close = true
    end if
    m.loadTask = invalid
end sub

sub onMovieChanged()
    hideSpinner()
    movie = m.top.movie
    if movie <> invalid then
        m.firstLoad = false

        pageName = "/movies/" + lCase(movie.title)
        m.top.omnitureName = pageName
        m.top.omnitureSiteHier = "movies|" + lCase(movie.title)
        trackScreenView()

        m.movieTitle.text = movie.title
        m.movieSubtitle.text = movie.subtitle
        m.movieDescription.text = movie.description

        m.poster.uri = getImageUrl(movie.thumbnailUrl, m.poster.width)

        ' if watch history exists leave progress bar at 100%
        if movie.resumePoint > 0 then
            m.progressBar.maxValue = movie.length
            m.progressBar.value = movie.resumePoint
            if m.progressBar.value / m.progressBar.maxValue > .97 then
                m.progressBar.value = m.progressBar.maxValue
            end if
            if m.progressBar.value / m.progressBar.maxValue > .05 then
                m.progressBar.visible = true
            else
                m.progressBar.visible = false
            end if
        else
            m.progressBar.visible = false
        end if

        m.background.uri = getImageUrl(movie.thumbnailUrl, m.background.width)
        
        if movie.trailer = invalid then
            m.buttons.removeChild(m.trailer)
        end if
        
        if canWatch(movie, m.top) then
            if movie.resumePoint > 0 and (movie.resumePoint < movie.length * .97) then
                m.watch.text = "RESTART"
                m.buttons.insertChild(m.resume, 0)
            else
                m.watch.text = "WATCH"
                m.buttons.removeChild(m.resume)
            end if
        else
            m.watch.text = "SUBSCRIBE"
            m.buttons.removeChild(m.resume)
        end if

        m.buttons.visible = true
        m.buttons.setFocus(false)
        m.buttons.setFocus(true)
        
        if m.top.autoPlay then
            m.top.buttonSelected = "autoplay"
            m.top.autoPlay = false
        else
            if createObject("roDeviceInfo").isAudioGuideEnabled() then
                m.tts.say(m.movieTitle.text)
                m.tts.say(m.movieSubtitle.text)
                m.tts.say(m.movieDescription.text)
            end if
        end if
    else        
        dialog = createCbsDialog("Content Unavailable", "The content you are trying to play is currently unavailable. Please try again later.", ["OK"])
        dialog.observeField("buttonSelected", "onUnavailableDialogClosed")
        setGlobalField("cbsDialog", dialog)
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

sub loadMovie(movieID as string)
    if not isNullOrEmpty(movieID) then
        showSpinner()
        m.loadTask = createObject("roSGNode", "LoadMovieTask")
        m.loadTask.observeField("movie", "onMovieLoaded")
        m.loadTask.movieID = movieID
        m.loadTask.control = "run"
    end if
end sub
