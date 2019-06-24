sub init()
    m.background = m.top.findNode("background")
    
    m.metadata = m.top.findNode("metadata")
    m.time = m.top.findNode("time")
    m.showTitle = m.top.findNode("showTitle")
    'm.episodeTitle = m.top.findNode("episodeTitle")
    m.focusFrame = m.top.findNode("focusFrame")

    m.liveNow = m.top.findNode("liveNow")
    m.comingUp = m.top.findNode("comingUp")
end sub

sub onContentChanged()
    if m.content = invalid or not m.content.isSameNode(m.top.itemContent) then
        if m.content <> invalid then
            m.content.unobserveField("isLive")
        end if
        m.content = m.top.itemContent
        m.content.observeField("isLive", "onLiveChanged")
        
        if m.content.subtype() = "Program" and m.content.startTime > 0 and m.content.endTime > 0 then
            m.metadata.insertChild(m.time, 0)

            time = createObject("roDateTime")
            time.fromSeconds(m.content.startTime)
            time.toLocalTime()
            m.time.text = uCase(getTimeString(time))

            m.showTitle.translation = [m.showTitle.translation[0], 96]
            m.showTitle.text = m.content.title

            now = createObject("roDateTime").asSeconds()
            m.liveNow.visible = asBoolean(m.content.isLive) or (m.content.startTime <= now and m.content.endTime > now) 
            'm.comingUp.visible = asBoolean(m.content.isNext)
        else
            m.metadata.removeChild(m.time)

            m.showTitle.translation = [m.showTitle.translation[0], 76]
            m.showTitle.text = m.content.episodeTitle
            
            if asInteger(m.content.startTime) > 0 then
                m.liveNow.visible = asBoolean(m.content.isLive) or (m.content.startTime <= now and (m.content.endTime > now or m.content.endTime = 0 ))
            else
                m.liveNow.visible = false 
            end if
        end if
        'm.episodeTitle.text = m.content.episodeTitle
    end if
end sub

sub onFocusChanged()
    m.focusFrame.visible = (m.top.focusPercent > 0 and m.top.gridHasFocus)
    m.focusFrame.opacity = m.top.focusPercent
end sub

sub onLiveChanged()
    m.liveNow.visible = asBoolean(m.content.isLive)
end sub

sub updateLayout()
    if m.top.width > 0 and m.top.height > 0 then
        m.background.width = m.top.width
        m.background.height = m.top.height
        
        m.focusFrame.width = m.top.width
        m.focusFrame.height = m.top.height
        
        m.time.width = m.top.width * .8
        m.showTitle.width = m.top.width * .8
        'm.episodeTitle.width = m.top.width * .8
        m.metadata.translation = [m.top.width / 2, m.top.height / 2]
        
        m.liveNow.translation = [m.top.width - m.liveNow.width, m.liveNow.translation[1]]
    end if
end sub
