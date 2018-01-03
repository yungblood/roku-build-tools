sub init()
    m.global.observeField("requestVideoAccess", "onVideoAccessRequested")
    m.global.observeField("videoState", "onGlobalVideoStateChanged")
    
    m.top.observeField("visible", "onVisibleChanged")
    
    m.fadeOut = m.top.findNode("fadeOutInterpolator")
    m.fadeOutAnimation = m.top.findNode("fadeOutAnimation")
    m.fadeOutAnimation.observeField("state", "onAnimationStateChanged")

    m.switchTimer = m.top.findNode("switchTimer")
    m.switchTimer.observeField("fire", "onSwitchTimerFired")
    
end sub

sub onVisibleChanged()
    if m.top.visible then
'        m.initialLoad = true
        updateCurrent()
    else
        m.switchTimer.control = "stop"
        m.fadeOutAnimation.control = "pause"
        if m.video <> invalid then
            m.top.index = m.top.index - 1
        end if
        destroyVideo()
    end if
end sub

sub updateCurrent()
    if m.top.visible then
        content = m.top.content.getChild(m.top.index)
        if content = invalid then
            content = m.top.content
        end if
        
        if m.current <> invalid then
            if m.previous <> invalid then
                destroyPrevious()
            end if
            m.previous = m.current
        end if
        
        if content.hasField("streamFormat") and content.streamFormat <> invalid and content.streamFormat <> "" and content.streamFormat <> "(null)" then
            if m.video = invalid then
                ?"creating video"
                m.video = CreateObject("roSGNode", "Video")
                m.video.observeField("state", "onVideoStateChanged")
                m.video.mute = true
                m.video.width = m.top.width
                m.video.height = m.top.height
                m.video.visible = false
                m.top.insertChild(m.video, 0)
            end if
            if m.video.content = invalid or not m.video.content.isSameNode(content) then
                m.video.content = content

                m.current = m.video
                m.video.control = "PLAY"
            else
                ?"NOT NEW CONTENT"
                if m.video.state <> "playing" then
                    m.video.content = content
                    m.video.control = "PLAY"
                end if
            end if
        else
            poster = CreateObject("roSGNode", "PosterWithRetry")
            m.current = poster
            poster.observeField("loadStatus", "onPosterLoadStatusChanged")
            poster.id = CreateObject("roDeviceInfo").GetRandomUUID()
            poster.loadDisplayMode = m.top.loadDisplayMode
            poster.loadWidth = m.top.loadWidth
            poster.loadHeight = m.top.loadHeight
            poster.width = m.top.width
            poster.height = m.top.height
            poster.uri = content.url
            
            m.top.insertChild(poster, 0)
        end if
        
        if content <> invalid then
            if content.hasField("advanceTime") then
                m.switchTimer.duration = content.advanceTime
            else
                m.switchTimer.duration = m.top.advanceTime
            end if
        end if
    end if
end sub

sub destroyPrevious()
    if m.previous <> invalid then
        if m.previous.subtype() = "Video" then
            m.previous.control = "STOP"
            m.previous.mute = false
        end if
        m.top.removeChild(m.previous)
        m.previous = invalid
    end if
end sub

sub destroyVideo()
    if m.video <> invalid then
        video = m.video
        m.video = invalid
        
        video.control = "STOP"
        video.unobserveField("state")
        m.top.removeChild(video)
        m.top.videoState = "none"
        if m.current <> invalid and m.current.isSameNode(video) then
            m.current = invalid
        end if
        if m.previous <> invalid and m.previous.isSameNode(video) then
            m.previous = invalid
        end if
        video.mute = false
        video = invalid
    end if
end sub

sub onContentChanged()
    if m.top.resetIndexOnContentChange then
        m.top.index = 0
        updateCurrent()
    end if
    m.top.resetIndexOnContentChange = true
end sub

sub onPosterLoadStatusChanged()
    if m.current <> invalid and m.current.loadStatus = "ready" then
        if m.previous <> invalid then
            m.fadeOut.fieldToInterp = m.previous.id + ".opacity"
            m.fadeOutAnimation.control = "start"
        else
            if m.switchTimer.duration > -1 then
                m.switchTimer.control = "start"
            end if
        end if
    end if
end sub

sub onAnimationStateChanged()
    if m.fadeOutAnimation.state = "stopped" then
        if m.video <> invalid then
            m.video.visible = true
        end if
        if m.switchTimer.duration > -1 then
            m.switchTimer.control = "start"
        end if
        destroyPrevious()
    end if
end sub

sub onVideoStateChanged()
    if m.video <> invalid then
        ?"SLIDESHOW VIDEO STATE: ";m.video.state
        m.top.videoState = m.video.state
        if m.video.state = "playing" then
            if m.previous <> invalid then
                m.fadeOut.fieldToInterp = m.previous.id + ".opacity"
                m.fadeOutAnimation.control = "start"
            end if
        else if m.video.state = "stopped" or m.video.state = "error" or m.video.state = "none" then
            destroyVideo()
            onSwitchTimerFired()
        end if
    end if
end sub

sub onSwitchTimerFired()
?"SwitchTimerFired"
    if m.top.visible then
        m.switchTimer.control = "stop"

        ' Advance to the next item
        if m.top.content.getChildCount() > 1 then
            m.top.index = m.top.index + 1
            if m.top.index >= m.top.content.getChildCount() and m.top.loop then
                m.top.index = 0
            end if
            if m.top.index < m.top.content.getChildCount() then
                updateCurrent()
            end if
        end if
    end if
end sub

sub onAdvanceTimeChanged()
    m.switchTimer.duration = m.top.advanceTime
end sub
