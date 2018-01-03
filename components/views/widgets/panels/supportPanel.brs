sub init()
    m.top.focusable = false
    m.content = m.top.findNode("content")
    
    updateContent()
end sub

sub updateContent()
    config = m.global.config
    if config <> invalid then
        m.content.removeChildrenIndex(m.content.getChildCount(), 0)
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
        
        deviceGroup = m.content.createChild("Group")
        label = deviceGroup.createChild("SettingsLabel")
        label.title = "DEVICE ID"
        label.value = createObject("roDeviceInfo").getDeviceUniqueID()
        
        label = deviceGroup.createChild("SettingsLabel")
        label.translation = [500, 0]
        label.title = "IP ADDRESS"
        label.value = config.ipAddress
    end if
end sub