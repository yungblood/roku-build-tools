sub init()
    m.top.omnitureName = "/all access/upsell"
    m.top.omniturePageType = "upsell"

    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.logo = m.top.findNode("logo")
    m.background = m.top.findNode("background")
    m.message1 = m.top.findNode("message1")
    m.message2 = m.top.findNode("message2")
    m.message3 = m.top.findNode("message3")

    m.buttons = m.top.findNode("buttons")
    m.buttons.observeField("buttonSelected", "onButtonSelected")
    
    m.buttonFont = m.top.findNode("buttonFont")
    
    m.top.setFocus(true)
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.buttons.setFocus(true)
    end if
end sub

sub onUpsellTypeChanged()
    m.global.showSpinner = true

    m.loadTask = createObject("roSGNode", "LoadUpsellInfoTask")
    m.loadTask.observeField("upsellInfo", "onUpsellInfoLoaded")
    m.loadTask.upsellType = m.top.upsellType
    m.loadTask.control = "run"
end sub

sub onButtonSelected(nodeEvent as object)
    button = m.buttons.getChild(nodeEvent.getData())
    
    buttonText = button.text
    params = {}
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

sub onButtonsChanged()
    buttons = m.top.buttons
    m.buttons.removeChildrenIndex(m.buttons.getChildCount(), 0)
    for each buttonText in buttons
        button = m.buttons.createChild("LabelButton")
        button.width = 701
        button.height = 88
        button.textColor = "0xffffffff"
        button.focusedTextColor = "0xffffffff"
        button.backgroundUri = "pkg:/images/upsell_button.9.png"
        button.focusedBackgroundUri = "pkg:/images/upsell_button_focused.9.png"
        button.processKeyEvents = false
        button.font = m.buttonFont
        button.text = buttonText
    next
end sub

sub onUpsellInfoLoaded()
    m.top.upsellInfo = m.loadTask.upsellInfo
    
    m.global.showSpinner = false
end sub

sub onUpsellInfoChanged()
    upsellInfo = m.top.upsellInfo
    if upsellInfo <> invalid then
        m.logo.uri = upsellInfo.logoUrl
        m.background.uri = upsellInfo.hdPosterUrl
        m.message1.text = upsellInfo.message1
        m.message2.text = upsellInfo.message2
        m.message3.text = upsellInfo.message3
    end if
end sub