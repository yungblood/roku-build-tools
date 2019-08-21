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
        
        user = getGlobalField("user")
'        if user <> invalid then
'            label = m.content.createChild("SettingsLabel")
'            label.title = "EMAIL"
'            if not isNullOrEmpty(user.email) then
'                label.value = user.email
'            else
'                label.value = user.maskedEmail
'            end if
'        end if
        if not isNullOrEmpty(config.faqUrl) then
            label = m.content.createChild("SettingsLabel")
            label.title = "FREQUENTLY ASKED QUESTIONS"
            label.value = config.faqUrl
        end if
        if not isNullOrEmpty(config.feedbackEmail) then
            label = m.content.createChild("SettingsLabel")
            label.title = "SEND FEEDBACK"
            label.value = config.feedbackEmail
        end if
        supportGroup = m.content.createChild("Group")
        label = supportGroup.createChild("SettingsLabel")
        label.title = "CUSTOMER SUPPORT"
        label.value = config.supportPhone
        
        label = supportGroup.createChild("SettingsLabel")
        label.translation = [500, 0]
        label.title = "APP VERSION"
        label.value = config.appVersion
        
        liveTVGroup = m.content.createChild("Group")
        label = liveTVGroup.createChild("SettingsLabel")
        label.title = "LIVE TV LOCATION"
        label.value = "To change location, visit Settings > Live TV"
        
        deviceGroup = m.content.createChild("Group")
        label = deviceGroup.createChild("SettingsLabel")
        label.title = "DEVICE ID"
        label.value = getPersistedDeviceID()
        
        ipGroup = m.content.createChild("Group")
        label = ipGroup.createChild("SettingsLabel")
        label.title = "IP ADDRESS"
        label.value = config.ipAddress
    end if
end sub

function read(params = {} as object) as boolean
    if createObject("roDeviceInfo").isAudioGuideEnabled() then
        for i = 0 to m.content.getChildCount() - 1
            child = m.content.getChild(i)
            if child.subtype() = "SettingsLabel" then
                m.tts.say(child.title)
                m.tts.say(child.value)
            else if child.subtype() = "Group" then
                for j = 0 to child.getChildCount() - 1
                    subchild = child.getChild(j)
                    if subchild.subtype() = "SettingsLabel" then
                        m.tts.say(subchild.title)
                        m.tts.say(subchild.value)
                    end if
                next
            end if
        next
    end if
end function