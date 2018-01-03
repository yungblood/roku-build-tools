sub init()
    m.poster = m.top.findNode("poster")
    m.title = m.top.findNode("title")
    m.subtitle = m.top.findNode("subtitle")
    m.progressBar = m.top.findNode("progressBar")
    
    m.largeDarken = m.top.findNode("largeDarken")
    m.smallDarken = m.top.findNode("smallDarken")
    
    m.metadata = m.top.findNode("metadata")
end sub

sub onContentChanged()
    if m.episode = invalid or not m.episode.isSameNode(m.top.itemContent) then
        if m.updateTimer <> invalid then
            m.updateTimer.control = "stop"
            m.updateTimer.unobserveField("fire")
            m.updateTimer = invalid
        end if
        m.episode = m.top.itemContent
        if m.episode <> invalid then
            updateMetadata()
            updatePoster()
            if m.episode.resumePoint <> invalid and m.episode.resumePoint > 0 then
                m.metadata.appendChild(m.progressBar)
                m.progressBar.maxValue = m.episode.length
                m.progressBar.value = m.episode.resumePoint
            else
                m.metadata.removeChild(m.progressBar)
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
                subtitle = m.episode.episodeString
                if not isNullOrEmpty(subtitle) then
                    subtitle = subtitle + " | "
                end if
                subtitle = subtitle + m.episode.airDateString
                m.subtitle.text = subtitle
            else
                m.subtitle.text = "(" + m.episode.durationString + ")"
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
            
            m.metadata.translation = [18, m.top.height - 20]
            
            m.title.width = m.top.width - 36
            m.subtitle.width = m.top.width - 36
            m.progressBar.width = m.top.width - 36
            
            m.largeDarken.width = m.top.width
            m.largeDarken.height = m.top.height
            m.smallDarken.width = m.top.width
            m.smallDarken.height = m.top.height
            
            m.largeDarken.visible = m.top.width > 500
            m.smallDarken.visible = not m.largeDarken.visible
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
