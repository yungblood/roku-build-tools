sub init()
    m.frame1 = m.top.findNode("frame1")
    m.frame1.observeField("loadStatus", "onFrame1LoadStatusChanged")
    m.frame2 = m.top.findNode("frame2")
    m.frame2.observeField("loadStatus", "onFrame2LoadStatusChanged")
    
    m.currentPoster = m.frame2
    
    m.frameTimer = m.top.findNode("frameTimer")
    m.frameTimer.observeField("fire", "onFrameTimerFired")
    
    m.visibilityOverride = false
    m.visibilityTimer = m.top.findNode("visibilityTimer")
    m.visibilityTimer.observeField("fire", "onVisibilityTimerFired")
    
    m.top.observeField("visible", "onVisibilityChanged")

    m.frameIndex = -1
end sub

sub updateLayout()
    if m.top.width > 0 and m.top.height > 0 then
        m.frame1.width = m.top.width
        m.frame1.height = m.top.height
        m.frame2.width = m.top.width
        m.frame2.height = m.top.height
    end if
end sub

sub onFrame1LoadStatusChanged()
    if m.frame1.loadStatus = "ready" or m.frame1.loadStatus = "failed" then
        m.frame1.visible = true
        m.frame2.visible = false
        if m.top.control = "start" and not m.visibilityOverride then
            m.frameTimer.control = "start"
        end if
    end if
end sub

sub onFrame2LoadStatusChanged()
    if m.frame2.loadStatus = "ready" or m.frame2.loadStatus = "failed" then
        m.frame1.visible = false
        m.frame2.visible = true
        if m.top.control = "start" and not m.visibilityOverride then
            m.frameTimer.control = "start"
        end if
    end if
end sub

sub onFrameUriChanged()
    updateFrame(0)
end sub

sub onVisibilityChanged()
    m.visibilityOverride = not m.top.visible
end sub

sub onFrameTimerFired()
    m.frameIndex = m.frameIndex + 1
    if m.frameIndex >= m.top.frames then
        m.frameIndex = 0
    end if
    updateFrame(m.frameIndex)
end sub

sub onVisibilityTimerFired()
    if isNodeVisible(m.top) then
        if m.visibilityOverride then
            m.visibilityOverride = false
            m.frameTimer.control = "start"
        end if
    else
        m.visibilityOverride = true
    end if
end sub

sub onControlChanged()
    if m.top.control = "stop" then
        m.top.state = "stopped"
        if m.top.resetOnStop then
            m.frameIndex = 0
            updateFrame(m.frameIndex)
            m.frameTimer.control = "stop"
        end if
        m.visibilityTimer.control = "stop"
    else if m.top.control = "start" then
        m.top.state = "running"
        m.frameTimer.control = "start"
        m.visibilityTimer.control = "start"
    end if
end sub

sub updateFrame(index as integer)
    if m.currentPoster.isSameNode(m.frame1) then
        m.frame2.uri = m.top.frameUri.replace("{0}", paddedToStr(index + 1, m.top.frames.toStr().len()))
        m.currentPoster = m.frame2
    else
        m.frame1.uri = m.top.frameUri.replace("{0}", paddedToStr(index + 1, m.top.frames.toStr().len()))
        m.currentPoster = m.frame1
    end if
end sub

function paddedToStr(index as integer, length as integer) as string
    str = index.toStr()
    while str.len() < length
        str = "0" + str
    end while
    return str
end function