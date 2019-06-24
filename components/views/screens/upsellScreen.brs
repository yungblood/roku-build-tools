sub init()
    m.top.omnitureName = "/all access/upsell"
    m.top.omniturePageType = "svod_upsell"
    m.top.omnitureSiteHier = "other|other|settings|home"

    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.logo = m.top.findNode("logo")
    m.background = m.top.findNode("background")
    m.message1 = m.top.findNode("message1")
    m.message2 = m.top.findNode("message2")
    m.message3 = m.top.findNode("message3")

    m.buttons = m.top.findNode("buttons")
    m.buttons.observeField("buttonSelected", "onButtonSelected")
    
    m.buttonFont = m.top.findNode("buttonFont")
    
    m.tts = createObject("roTextToSpeech")

    trackRMFEvent("RBK")
end sub

sub onFocusChanged()
    if m.top.hasFocus() and m.top.upsellInfo <> invalid then
        m.buttons.setFocus(true)
    end if
end sub

sub onUpsellTypeChanged()
    showSpinner()

    m.loadTask = createObject("roSGNode", "LoadUpsellInfoTask")
    m.loadTask.observeField("upsellInfo", "onUpsellInfoLoaded")
    m.loadTask.upsellType = m.top.upsellType
    m.loadTask.control = "run"
end sub

sub onButtonSelected(nodeEvent as object)
    button = m.buttons.getChild(nodeEvent.getData())
    
    buttonText = button.text
    params = {}
    params["siteHier"] = "all access|upsell"
    if buttonText = constants().signUpText then
        params["podType"] = "upsell"
        params["podText"] = "sign up"
        params["podSection"] = "limited commercials"
        params["podTitle"] = "sign up"
    else if buttonText = constants().signInText then
        params["podType"] = "upsell"
        params["podText"] = "sign in"
        params["podTitle"] = "already a subscriber?"
    else if buttonText = constants().browseText then
        params["podType"] = "upsell"
        params["podText"] = "browse and watch clips"
    end if
    trackScreenAction("trackPodSelect", params)

    m.top.buttonSelected = buttonText
end sub

sub onButtonsChanged(nodeEvent as object)
    buttons = nodeEvent.getData()
    m.buttons.removeChildrenIndex(m.buttons.getChildCount(), 0)
    
    newButtons = []
    for each buttonText in buttons
        button = createObject("roSGNode", "LabelButton")
        button.width = 701
        button.height = 88
        button.textColor = "0xffffffff"
        button.focusedTextColor = "0xffffffff"
        button.backgroundUri = "pkg:/images/upsell_button.9.png"
        button.focusedBackgroundUri = "pkg:/images/upsell_button_focused.9.png"
        button.processKeyEvents = false
        button.font = m.buttonFont
        button.text = buttonText
        newButtons.push(button)
    next
    ' Append after all have been created, so TTS works correctly
    m.buttons.appendChildren(newButtons)
end sub

sub onUpsellInfoLoaded(nodeEvent as object)
    task = nodeEvent.getRoSGNode()
    upsellInfo = nodeEvent.getData()
    
    if upsellInfo <> invalid and task.errorCode = 0 then
        m.top.upsellInfo = upsellInfo
    else
        if task.errorCode > 0 then
            showApiError(true)
        end if
    end if

    hideSpinner()
    m.loadTask = invalid
end sub

sub onUpsellInfoChanged(nodeEvent as object)
    upsellInfo = nodeEvent.getData()
    if upsellInfo <> invalid then
        m.logo.uri = upsellInfo.logoUrl
        m.background.uri = upsellInfo.hdPosterUrl
        m.message1.text = upsellInfo.message1
        m.message2.text = upsellInfo.message2
        m.message3.text = upsellInfo.message3
        
        if createObject("roDeviceInfo").isAudioGuideEnabled() then
            m.tts.say(upsellInfo.message1 + " " + upsellInfo.message2 + " " + upsellInfo.message3)
        end if
        m.buttons.setFocus(true)
    end if
end sub