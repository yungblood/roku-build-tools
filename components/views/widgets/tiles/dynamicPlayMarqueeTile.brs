sub init()
    m.top.observeField("focusedChild", "onFocusChanged")

    m.showTitle = m.top.findNode("showTitle")
    m.episodeTitle = m.top.findNode("episodeTitle")
    m.episodeNumber = m.top.findNode("episodeNumber")
    m.description = m.top.findNode("description")
    
    m.ctaButton = m.top.findNode("ctaButton")
    m.showInfo = m.top.findNode("showInfo")
    
    m.metadata = m.top.findNode("metadata")
    m.progressSpacer = m.top.findNode("progressSpacer")
    m.progress = m.top.findNode("progress")
    m.progressBar = m.top.findNode("progressBar")
    m.timeIndicator = m.top.findNode("timeIndicator")
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.ctaButton.setFocus(true)
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        if key = "OK" then
            if m.ctaButton.hasFocus() then
                m.top.buttonSelected = "dynamicPlay"
            end if
            return true
        else if key = "options" then
            m.top.buttonSelected = "showInfo"
            return true
        end if
    end if
    return false
end function

sub updateContent()
    if m.show <> invalid then
        m.loadTask = createObject("roSGNode", "loadDynamicPlayEpisodeTask")
        m.loadTask.observeField("episode", "onEpisodeLoaded")
        m.loadTask.show = m.show
        m.loadTask.control = "run"
    end if
end sub

sub onShowChanged()
    if m.show = invalid or not m.show.isSameNode(m.top.show) then
        m.show = m.top.show
        m.showTitle.text = uCase(m.show.title)
        updateContent()
    end if
end sub

sub onEpisodeLoaded(nodeEvent as object)
    dynamicPlay = nodeEvent.getData()
    if dynamicPlay <> invalid then
        episode = dynamicPlay.episode
        m.top.episode = episode
        m.top.show.dynamicPlayEpisode = episode

        m.ctaButton.text = uCase(dynamicPlay.title)
        m.ctaButton.visible = true

        m.episodeTitle.text = episode.title
        m.episodeNumber.text = episode.seasonString + " " + episode.episodeString
        m.description.text = episode.description
     
        if episode.resumePoint <> invalid and episode.resumePoint > 0 then
            m.metadata.insertChild(m.progress, 5)
            m.progressBar.maxValue = episode.length
            m.progressBar.value = episode.resumePoint
            m.progressBar.visible = true
            resumeTime = int((episode.resumePoint / 60) + .5)
            actualTime = (episode.length \ 60)
            timeIndicator = resumeTime.toStr() + " of " + actualTime.toStr() + " min"
            m.timeIndicator.text = timeIndicator

            m.progressSpacer.height = 10
        else
            m.metadata.removeChild(m.progress)
            m.progressSpacer.height = 11
        end if
        m.top.visible = true
    else
        ' We don't have content, so hide ourselves
        m.top.visible = false
    end if
    m.loadTask = invalid
    m.top.contentLoaded = true
end sub

