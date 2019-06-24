sub init()
    m.top.focusable = false
    m.content = m.top.findNode("content")
    
    updateContent()

    m.tts = createObject("roTextToSpeech")
end sub

sub updateContent()
    config = getGlobalField("config")
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

function read(params = {} as object) as boolean
    if createObject("roDeviceInfo").isAudioGuideEnabled() then
        for i = 0 to m.content.getChildCount() - 1
            child = m.content.getChild(i)
            if child.subtype() = "SettingsLabel" then
                m.tts.say(child.title)
                m.tts.say(child.value)
            end if
        next
    end if
end function