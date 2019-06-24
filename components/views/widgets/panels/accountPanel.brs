sub init()
    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.focusable = true
    
    m.content = m.top.findNode("content")
    m.name = m.top.findNode("name")
    m.email = m.top.findNode("email")
    m.level = m.top.findNode("level")
    
    m.buttons = m.top.findNode("buttons")
    m.buttons.observeField("buttonSelected", "onButtonSelected")
    
    m.signIn = m.top.findNode("signIn")
    m.freeTrial = m.top.findNode("freeTrial")
    m.upgrade = m.top.findNode("upgrade")
    m.manageAccount = m.top.findNode("manageAccount")
    m.signOut = m.top.findNode("signOut")
    
    observeGlobalField("user", "updateContent")
    updateContent()

    m.tts = createObject("roTextToSpeech")
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.buttons.setFocus(true)
    end if
end sub

sub updateContent()
    m.content.insertChild(m.level, 0)
    m.content.insertChild(m.email, 0)
    m.content.insertChild(m.name, 0)
    m.buttons.appendChild(m.manageAccount)
    m.buttons.appendChild(m.upgrade)
    m.buttons.appendChild(m.signOut)
    m.buttons.appendChild(m.freeTrial)
    m.buttons.appendChild(m.signIn)
    user = getGlobalField("user")
    if user <> invalid and user.status <> "ANONYMOUS" then
        m.name.value = user.maskedFullName
        if not isNullOrEmpty(user.email) then
            m.email.value = user.email
        else
            m.email.value = user.maskedEmail
        end if
        m.level.value = user.packageName
        if not user.canUpgrade then
            m.buttons.removeChild(m.upgrade)
        end if
        if not user.canDowngrade then
            m.buttons.removeChild(m.manageAccount)
        end if
        m.buttons.removeChild(m.freeTrial)
        m.buttons.removeChild(m.signIn)
    else
        m.content.removeChild(m.name)
        m.content.removeChild(m.email)
        m.content.removeChild(m.level)
        m.buttons.removeChild(m.manageAccount)
        m.buttons.removeChild(m.upgrade)
        m.buttons.removeChild(m.signOut)
    end if
end sub

sub onButtonSelected(nodeEvent as object)
    button = m.buttons.getChild(m.buttons.buttonSelected)
    if button <> invalid then
        m.top.buttonSelected = button.id
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