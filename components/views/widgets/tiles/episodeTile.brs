sub init()
    m.poster = m.top.findNode("poster")
    m.title = m.top.findNode("title")
    m.subtitle = m.top.findNode("subtitle")
    
    m.metadata = m.top.findNode("metadata")
    
    m.titleGroup = m.top.findNode("titleGroup")
    m.episodeNumber = m.top.findNode("episodeNumber")
    m.titleGroup.removeChild(m.episodeNumber)

    m.subtitleGroup = m.top.findNode("subtitleGroup")
    m.subtitle = m.top.findNode("subtitle")
    m.subtitle2 = m.top.findNode("subtitle2")
end sub

sub onContentChanged()
    if m.episode = invalid or not m.episode.isSameNode(m.top.itemContent) then
        if m.episode <> invalid then
            m.episode.unobserveField("resumePoint")
        end if
        if m.updateTimer <> invalid then
            m.updateTimer.control = "stop"
            m.updateTimer.unobserveField("fire")
            m.updateTimer = invalid
        end if
        m.episode = m.top.itemContent
        if m.episode <> invalid then
            m.episode.observeField("resumePoint", "updateResumePoint")
            updateMetadata()
            updatePoster()
            updateResumePoint()
        end if
    end if
end sub

sub updateResumePoint()
    if m.episode <> invalid then
        if m.episode.resumePoint <> invalid and m.episode.resumePoint > 0 then
            if m.progressBar = invalid then
                m.progressBar = createObject("roSGNode", "CBSProgressBar")
                m.progressBar.id = "progressBar"
                m.progressBar.height = 6

                m.progressBar.width = m.top.width - 24 - 24
                m.progressbar.translation = [24, m.top.height - m.progressBar.height - 24]
                m.top.appendChild(m.progressBar)
            end if
            m.progressBar.maxValue = m.episode.length
            m.progressBar.value = m.episode.resumePoint

            ' if watch history exists leave progress bar at 100%
            if m.progressBar.value / m.progressBar.maxValue > .97 then
                m.progressBar.value = m.progressBar.maxValue
            end if
            if m.progressBar.value / m.progressBar.maxValue > .05 then
                m.progressBar.visible = true
            else
                m.progressBar.visible = false
            end if
        else
            if m.progressBar <> invalid then
                m.progressBar.visible = false
            end if
        end if
    end if
end sub

sub updateMetadata()
    if m.episode <> invalid then
        m.title.text = m.episode.title
        if m.episode.subtype() = "LiveFeed" then
            m.subtitle.text = m.episode.description
        else
            if m.episode.isFullEpisode then
                m.episodeNumber.text = (m.episode.seasonString + " " + m.episode.episodeString).trim()
                m.subtitle.text = m.episode.releaseDate
            else
                m.subtitle.text = m.episode.durationString
                m.subtitle2.text = m.episode.showName
            end if
        end if
    end if
end sub

sub updateLayout()
    if m.top.width > 0 and m.top.height > 0 then
        if m.poster.width <> m.top.width or m.poster.height <> m.top.height then
            m.poster.width = m.top.width
            m.poster.height = m.top.height
            
            updatePoster()
            
            m.metadata.translation = [0, m.top.height + 17]
            
            if not isNullOrEmpty(m.episodeNumber.text) then
                m.titleGroup.insertChild(m.episodeNumber, 0)
                m.title.width = m.top.width - (m.episodeNumber.boundingRect().width + m.titleGroup.itemSpacings[0])
            else
                m.titleGroup.removeChild(m.episodeNumber)
                m.title.width = m.top.width
            end if

            if m.episode.isFullEpisode and m.episode.subtype() <> "Movie" then
                m.subtitle.width = m.top.width
            else
                m.subtitle2.width = m.top.width - (m.subtitle.boundingRect().width + m.subtitleGroup.itemSpacings[0])
            end if
            
            if m.progressBar <> invalid then
                m.progressBar.width = m.top.width - 24 - 24
                m.progressbar.translation = [24, m.top.height - m.progressBar.height - 24]
            end if
        end if
    end if
end sub

sub updatePoster()
    if m.episode <> invalid and m.poster.width > 0 and m.poster.height > 0 then
        uri = m.episode.thumbnailUrl
        if m.episode.subtype() = "LiveFeed" then
            uri = m.episode.thumbnailUrl
            if uri.inStr("?") > -1 then
                uri = uri + "&"
            else
                uri = uri + "?"
            end if
            uri = uri + "cachebuster=" + createObject("roDateTime").asSeconds().toStr()
            if m.updateTimer = invalid then
                m.updateTimer = createObject("roSGNode", "Timer")
                m.updateTimer.observeField("fire", "updatePoster")
                m.updateTimer.duration = 60
                m.updateTimer.repeat = true
                m.updateTimer.control = "start"
            end if
        else
            uri = getImageUrl(m.episode.thumbnailUrl, m.poster.width)
        end if
        m.poster.uri = uri
    end if
end sub
