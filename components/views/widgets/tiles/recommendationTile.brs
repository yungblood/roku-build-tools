sub init()
    m.top.observeField("focusedChild", "onFocusChanged")

    m.poster = m.top.findNode("poster")
    m.title = m.top.findNode("title")
    m.subtitle = m.top.findNode("subtitle")
    m.metadata = m.top.findNode("metadata")
    m.ctaButton = m.top.findNode("ctaButton")
    
    m.countdown = m.top.findNode("countdown")
    m.countdownLabel = m.top.findNode("countdownLabel")
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.ctaButton.setFocus(true)
    end if
    m.countdown.visible = m.top.isInFocusChain()
end sub

sub onContentChanged()
    if m.content = invalid or not m.content.isSameNode(m.top.itemContent) then
        m.content = m.top.itemContent
        if m.content <> invalid then
            m.title.text = m.content.title
            m.subtitle.text = m.content.subtitle
            m.poster.uri = getImageUrl(m.content.thumbnailUrl, m.poster.width)
            m.ctaButton.text = m.content.callToAction
        end if
    end if
end sub

sub onCountdownChanged()
    m.countdownLabel.text = m.top.countdown.toStr()
end sub

