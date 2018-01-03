sub init()
    m.top.observeField("loadStatus", "onLoadStatusChanged")
    m.retries = 0
end sub

sub onLoadStatusChanged()
    ?m.top.loadStatus,m.top.uri
    if m.top.loadStatus = "ready" then
        resetTimers()
    else if m.top.loadStatus = "failed" then
        if m.top.uri <> "" then
            retry(false)
        end if
    else if m.top.loadStatus = "loading" then
        resetTimers()
        if m.top.uri <> "" then
            m.uri = m.top.uri
            if m.top.timeout > 0 then
                m.timeoutTimer = createObject("roSGNode", "Timer")
                m.timeoutTimer.observeField("fire", "onTimeout")
                m.timeoutTimer.repeat = false
                m.timeoutTimer.duration = m.top.timeout
                m.timeoutTimer.control = "start"
            end if
        end if
    end if
end sub

sub retry(isTimeout = true as boolean)
    resetTimers()
    if m.retries < m.top.maxRetries then
        if isTimeout then
            ?"**WARNING** Poster load timed out (";m.uri;"). Retrying...";m.retries + 1;" of";m.top.maxRetries
        else
            ?"**WARNING** Poster load failed (";m.uri;"). Retrying...";m.retries + 1;" of";m.top.maxRetries
        end if
        m.top.uri = ""
        if m.uri <> "" then
            ' HACK: we can't immediately reset the URL to get a retry, so we delay 500 ms
            m.retryTimer = createObject("roSGNode", "Timer")
            m.retryTimer.observeField("fire", "onRetryTimerFired")
            m.retryTimer.repeat = false
            m.retryTimer.duration = .5
            m.retryTimer.control = "start"
        else
            ?"**ERROR** Uri is empty"
        end if
    else
        ?"**Error** Poster failed to load: ";m.top.uri
        if m.top.failoverUri <> invalid then
            m.top.uri = m.top.failoverUri
        end if
    end if
end sub

sub resetTimers()
    if m.timeoutTimer <> invalid then
        m.timeoutTimer.unobserveField("fire")
        m.timeoutTimer.control = "stop"
        m.timeoutTimer = invalid
    end if
    if m.retryTimer <> invalid then
        m.retryTimer.unobserveField("fire")
        m.retryTimer.control = "stop"
        m.retryTimer = invalid
    end if
end sub

sub onRetryTimerFired()
    ?"Retrying: ";m.uri
    m.top.uri = m.uri
    m.retries = m.retries + 1
end sub

sub onTimeout()
    if m.top.loadStatus = "loading" then
        retry(true)
    end if
end sub

sub onItemContentChanged()
    if m.content = invalid or not m.content.isSameNode(m.top.itemContent) then
        m.content = m.top.itemContent
        m.retries = 0
        if m.content <> invalid then
            m.top.uri = m.content.hdPosterUrl
        else
            m.top.uri = ""
        end if
    end if
end sub
