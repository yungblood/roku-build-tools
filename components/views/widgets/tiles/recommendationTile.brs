sub init()
    m.top.observeField("focusedChild", "onFocusChanged")

    m.poster = m.top.findNode("poster")
    m.title = m.top.findNode("title")
    m.subtitle = m.top.findNode("subtitle")
    m.metadata = m.top.findNode("metadata")
    m.ctaButton = m.top.findNode("ctaButton")
    
    m.countdown = m.top.findNode("countdown")
    m.countdownLabel = m.top.findNode("countdownLabel")
    m.countdown.visible = isSubscriber(m.top)
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.ctaButton.setFocus(true)
    end if
end sub

sub onContentChanged()
    if m.content = invalid or not m.content.isSameNode(m.top.itemContent) then
        m.content = m.top.itemContent
        if m.content <> invalid then
            if m.content.subtype() = "Episode" then
                m.title.text = m.content.title
                m.subtitle.text = (m.content.seasonString + " " + m.content.episodeString).trim()

                show = getShowFromCache(m.content.showID)
                if show <> invalid then
                    m.poster.uri = getImageUrl(show.myCbsImageUrl, m.poster.width)
                else
                    m.poster.uri = getImageUrl(m.content.thumbnailUrl, m.poster.width)
                end if

                if canWatch(m.content, m.top) then
                    m.ctaButton.text = "WATCH NOW"
                else
                    m.ctaButton.text = "SUBSCRIBE TO WATCH"
                end if
            else
                m.title.text = m.content.title
                m.subtitle.text = m.content.subtitle
                m.poster.uri = getImageUrl(m.content.thumbnailUrl, m.poster.width)
                m.ctaButton.text = m.content.callToAction
            end if
        end if
    end if
end sub

sub onCountdownChanged()
    'if m.content.subtype() <> "Episode" or canWatch(m.content, m.top) then
        if isSubscriber(m.top) then
            m.countdownLabel.text = m.top.countdown.toStr()
            m.countdown.visible = m.top.isInFocusChain()
        end if
    'else
    '    m.countdown.visible = false
    'end if
end sub

