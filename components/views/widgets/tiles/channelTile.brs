sub init()
    m.logo = m.top.findNode("logo")
    m.showTitle = m.top.findNode("showTitle")
    m.focusFrame = m.top.findNode("focusFrame")
    m.liveNow = m.top.findNode("liveNow")
    m.updateTimer = m.top.findNode("updateTimer")
    m.updateTimer.observeField("fire", "updateSchedule")
    
    m.error = m.top.findNode("error")

    m.scheduleReload = 12
end sub

sub onContentChanged()
    if m.content = invalid or not m.content.isSameNode(m.top.itemContent) then
        if m.content <> invalid then
            m.content.unobserveField("affiliate")
            m.content.unobserveField("isTuned")
        end if
        m.content = m.top.itemContent
        m.content.observeField("affiliate", "onAffiliateChanged")
        m.content.observeField("isTuned", "onTunedChanged")

        onAffiliateChanged()
        onTunedChanged()
        
        loadSchedule()
    end if
end sub

sub onFocusChanged()
    m.focusFrame.visible = (m.top.focusPercent > 0 and m.top.gridHasFocus)
    m.focusFrame.opacity = m.top.focusPercent
end sub

sub onAffiliateChanged()
    if m.content.affiliate = invalid then
        if m.content.id = "local" then
            m.error.text = "Station Unavailable"
            m.showTitle.text = "CBS Local Station"
        else
            m.logo.uri = m.content.hdPosterUrl
        end if
    else
        m.logo.uri = m.content.affiliate.hdPosterUrl
    end if
end sub

sub onTunedChanged()
    m.liveNow.visible = m.content.isTuned
end sub

sub loadSchedule()
    m.scheduleTask = createObject("roSGNode", "LoadLiveScheduleTask")
    m.scheduleTask.observeField("schedule", "onScheduleLoaded")
    m.scheduleTask.scheduleUrl = m.content.scheduleUrl
    m.scheduleTask.control = "run"
    m.scheduleReload = 12
end sub

sub onScheduleLoaded(nodeEvent as object)
    m.scheduleTask = invalid

    schedule = nodeEvent.getData()
    m.schedule = createObject("roSGNode", "ContentNode")
    m.schedule.appendChildren(schedule)
    updateSchedule()

    m.updateTimer.control = "start"
end sub

sub updateSchedule()
    nowTime = createObject("roDateTime").asSeconds()
 
    scheduleUpdated = false
    if m.nowPlaying = invalid or m.nowPlaying.endTime <= nowTime then
        program = m.schedule.getChild(0)
        while m.schedule.getChildCount() > 0 and program.endTime <= nowTime and program.endTime > 0
            m.schedule.removeChild(program)
            program = m.schedule.getChild(0)
            scheduleUpdated = true
        end while

        m.nowPlaying = m.schedule.getChild(0)
        updateNowPlaying()
        
        if m.nowPlaying.endTime = 0 then
            m.scheduleReload--
        end if
        if m.scheduleReload = 0 then
            loadSchedule()
        end if
    end if
end sub

sub updateNowPlaying()
    nowPlaying = m.nowPlaying
    if nowPlaying <> invalid then
        m.showTitle.text = nowPlaying.title
    end if
end sub