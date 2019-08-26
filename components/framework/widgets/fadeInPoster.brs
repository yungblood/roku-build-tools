sub init()
    m.loading = m.top.findNode("loading")
    m.poster = m.top.findNode("poster")
    m.poster.observeField("loadStatus", "onLoadStatusChanged")
    
    m.fadeIn = m.top.findNode("fadeIn")
    m.fadeInInterp = m.top.findNode("fadeInInterp")
end sub

sub onItemContentChanged(nodeEvent as object)
    content = nodeEvent.getData()
    if content <> invalid then
        if m.top.uri <> content.hdPosterUrl then
            m.top.uri = content.hdPosterUrl
            if content.hdPosterUrl <> "" then
                m.top.uri = content.hdPosterUrl
            else
                m.top.uri = m.top.failedBitmapUri
            end if
        end if
    else
        m.top.uri = m.top.failedBitmapUri
    end if
end sub

sub onUriChanged(nodeEvent as object)
    uri = nodeEvent.getData()
    m.poster.opacity = m.top.startingOpacity
    m.poster.uri = uri
    m.retries = 0
    m.loading.visible = true
end sub

sub onLoadDisplayModeChanged(nodeEvent as object)
    mode = nodeEvent.getData()
    m.poster.loadDisplayMode = mode
    m.loading.loadDisplayMode = mode
end sub

sub onLoadStatusChanged(nodeEvent as object)
    status = nodeEvent.getData()
    if status = "ready" then
        m.loading.visible = false
        m.fadeInInterp.keyValue = [m.top.startingOpacity, 1]
        m.fadeIn.control = "start"
        if m.retryTimer <> invalid then
            m.retryTimer.unobserveField("fire")
            m.retryTimer = invalid
        end if
    else if status = "failed" then
        if m.retries < m.top.retries then
            m.retries++
            ?"Retrying (";m.retries.toStr();")... ";m.top.uri
            m.poster.uri = ""
            m.retryTimer = createObject("roSGNode", "Timer")
            m.retryTimer.observeField("fire", "onRetryTimerFired")
            m.retryTimer.duration = 0.1
            m.retryTimer.control = "start"
        else
            m.loading.visible = false
            ' No more retries, so fade in the failed bitmap
            m.poster.uri = m.top.failedBitmapUri
            m.fadeInInterp.keyValue = [m.top.startingOpacity, 1]
            m.fadeIn.control = "start"
        end if
    end if
end sub

sub onRetryTimerFired()
    ?"Retry timer..."
    m.poster.uri = m.top.uri
    m.retryTimer.unobserveField("fire")
    m.retryTimer = invalid
end sub

sub updateLayout()
    if m.top.width > 0 and m.top.height > 0 then
        m.poster.width = m.top.width
        m.poster.height = m.top.height
        m.loading.width = m.top.width
        m.loading.height = m.top.height
    end if
end sub

sub onCurrRectChanged(nodeEvent as object)
    rect = nodeEvent.getData()
    m.top.width = rect.width
    m.top.height = rect.height
end sub