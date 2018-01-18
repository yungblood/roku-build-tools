sub init()
    m.time = m.top.findNode("time")
    m.showTitle = m.top.findNode("showTitle")
    m.episodeTitle = m.top.findNode("episodeTitle")
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
            time = createObject("roDateTime")
            time.fromSeconds(m.content.startTime)
            time.toLocalTime()
            m.time.text = getTimeString(time)
            
            m.showTitle.text = m.content.title

            now = createObject("roDateTime").asSeconds()
            m.liveNow.visible = asBoolean(m.content.isLive) or (m.content.startTime <= now and m.content.endTime > now) 
            'm.comingUp.visible = asBoolean(m.content.isNext)
        else
            m.time.text = m.content.title
            
            m.showTitle.text = ""
        end if
        m.episodeTitle.text = m.content.episodeTitle
    end if
end sub

sub onFocusChanged()
    m.focusFrame.visible = (m.top.focusPercent > 0 and m.top.gridHasFocus)
    m.focusFrame.opacity = m.top.focusPercent
end sub

sub onLiveChanged()
    m.liveNow.visible = asBoolean(m.content.isLive)
end sub
