sub init()
    m.top.observeField("focusedChild", "onFocusChanged")
    m.poster = m.top.findNode("poster")
    m.overlayText = m.top.findNode("overlayText")
    
    m.playTile = m.top.findNode("playTile")
    m.focusFrame = m.top.findNode("focusFrame")
    m.descriptionFocusRect = m.top.findNode("descriptionFocusRect")
    m.title = m.top.findNode("title")
    m.episodeNumber = m.top.findNode("episodeNumber")
    m.description = m.top.findNode("description")
    
    m.metadata = m.top.findNode("metadata")
    m.progressBar = m.top.findNode("progressBar")
    
    m.currentFocus = m.playTile
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        updateFocus()
    else if not m.top.isInFocusChain() then
        updateFocus(false)
    end if
end sub

sub updateFocus(setFocus = true as boolean)
    if setFocus then
        m.currentFocus.setFocus(true)
    end if
    m.focusFrame.visible = m.playTile.hasFocus()
    m.descriptionFocusRect.visible = m.description.hasFocus()
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        if key = "right" then
            if m.playTile.hasFocus() then
                m.currentFocus = m.description
                updateFocus()
                return true
            end if
        else if key = "left" then
            if m.description.hasFocus() then
                m.currentFocus = m.playTile
                updateFocus()
                return true
            end if
        else if key = "OK" then
            if m.playTile.hasFocus() then
                m.top.itemSelected = 0
                return true
            end if
        end if
    end if
    return false
end function

sub onShowChanged()
    if m.show = invalid or not m.show.isSameNode(m.top.show) then
        m.show = m.top.show
        m.loadTask = createObject("roSGNode", "loadDynamicPlayEpisodeTask")
        m.loadTask.observeField("episode", "onEpisodeLoaded")
        m.loadTask.showID = m.show.id
        m.loadTask.control = "run"
    end if
end sub

sub onEpisodeLoaded(nodeEvent as object)
    dynamicPlay = nodeEvent.getData()
    if dynamicPlay <> invalid then
        episode = dynamicPlay.episode
        m.top.episode = episode
        m.top.show.dynamicPlayEpisode = episode

        m.overlayText.text = uCase(dynamicPlay.title)
        m.poster.uri = getImageUrl(episode.thumbnailUrl, m.poster.width)
        m.title.text = episode.title
        m.episodeNumber.text = episode.seasonString + " " + episode.episodeString
        m.description.text = episode.description
     
        if episode.resumePoint <> invalid and episode.resumePoint > 0 then
            m.metadata.appendChild(m.progressBar)
            m.progressBar.maxValue = episode.length
            m.progressBar.value = episode.resumePoint
            m.progressBar.visible = true
        else
            m.metadata.removeChild(m.progressBar)
        end if
        m.top.visible = true
    else
        ' We don't have content, so hide ourselves
        m.top.visible = false
    end if

    m.loadTask = invalid
end sub

