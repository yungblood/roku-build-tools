sub init()
    m.top.focusable = false
    m.content = m.top.findNode("content")
    
    updateContent()
end sub

sub updateContent()
    config = m.global.config
    if config <> invalid then
        m.content.removeChildrenIndex(m.content.getChildCount(), 0)
        if not isNullOrEmpty(config.touUrl) then
            label = m.content.createChild("SettingsLabel")
            label.title = "TERMS OF USE"
            label.value = config.touUrl
        end if
        if not isNullOrEmpty(config.privacyUrl) then
            label = m.content.createChild("SettingsLabel")
            label.title = "PRIVACY STATEMENT"
            label.value = config.privacyUrl
        end if
        if not isNullOrEmpty(config.videoPolicyUrl) then
            label = m.content.createChild("SettingsLabel")
            label.title = "VIDEO SERVICES POLICY"
            label.value = config.videoPolicyUrl
        end if
    end if
end sub