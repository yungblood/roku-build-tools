sub init()
    m.top.omnitureName = "/all access/pick_a_plan"
    m.top.omniturePageType = "svod_pick_a_plan"
    m.top.omnitureSiteHier = "all access|pick_a_plan"

    m.top.observeField("focusedChild", "onFocusChanged")
    
'    m.background = m.top.findNode("background")
    m.title = m.top.findNode("title")
    m.header = m.top.findNode("header")
    m.disclaimer = m.top.findNode("disclaimer")
    
    m.options = m.top.findNode("options")
    m.options.observeField("buttonSelected", "onOptionSelected")
    m.buttons = m.top.findNode("buttons")
    m.buttons.observeField("buttonSelected", "onButtonSelected")
    m.noButtons = m.top.findNode("noButtons")
    
    m.buttonFont = m.top.findNode("buttonFont")
    
    m.store = m.top.findNode("store")
    m.store.observeField("purchases", "onPurchasesLoaded")
    
    m.tts = createObject("roTextToSpeech")
    m.purchaseCount = 0

    trackRMFEvent("PAP")
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        if key = "down" then
            if m.options.isInFocusChain() then
                if m.buttons.visible and m.buttons.getChildCount() > 0 then
                    m.buttons.setFocus(true)
                    return true
                end if
            end if
        else if key = "up" then
            if m.buttons.isInFocusChain() then
                resetFocus()
                return true
            end if
        end if
    end if
    return false
end function

sub onFocusChanged()
    if m.top.hasFocus() then
        resetFocus()
        setGlobalField("ignoreBack",false)
    end if
end sub

sub resetFocus()
    for i = 0 to m.options.getChildCount() - 1
        option = m.options.getchild(i)
        if option.disabled <> true then
            m.options.setFocus(true)
            return
        end if
    next
    m.buttons.setFocus(true)
end sub

sub onButtonSelected(nodeEvent as object)
    button = m.buttons.getChild(nodeEvent.getData())
    
    buttonText = button.text
    params = {}
    params["siteHier"] = "all access|pick_a_plan"
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
    else if buttonText = constants().switchText then
        params["podType"] = "upsell"
        params["podText"] = "downgrade"
        params["podSection"] = "limited commercials"
    else if buttonText = constants().tourText then
        params["podType"] = "upsell"
        params["podText"] = "take the tour"
        params["podTitle"] = "take the tour"
    end if
    trackScreenAction("trackPodSelect", params)
    
    m.top.buttonSelected = buttonText
end sub

sub onOptionSelected(nodeEvent as object)
    if m.purchaseCount = 0 then
        option = m.options.getChild(nodeEvent.getData())
        if not option.disabled then
            upsellInfo = option.upsellInfo
            params = upsellInfo.omnitureData
            if params = invalid then
                params = {}
            end if
            params["podType"] = "pick_a_plan"
            params["siteHier"] = "all access|pick_a_plan"
            trackScreenAction("trackPodSelect", params)
            
            m.top.optionSelected = option.upsellInfo
        end if
    else
        config = getGlobalField("config")
        dialog = createCbsDialog("Account Exists", "It looks like you've already subscribed to CBS All Access on this Roku device. Please sign in.", ["OK"])
        dialog.observeField("buttonSelected", "onUpsellErrorDialogClosed")
        setGlobalField("cbsDialog", dialog)
    end if
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

sub onOptionsChanged(nodeEvent as object)
    options = nodeEvent.getData()
    m.options.removeChildrenIndex(m.options.getChildCount(), 0)
    if options <> invalid then
        for each option in options
            if option <> invalid then
                button = m.options.createChild("SubscriptionOptionButton")
                if options.count() = 1 then
                    button.width = 838
                else
                    button.width = 734
                end if
                button.height = 444
                button.upsellInfo = option
                button.processKeyEvents = false
            end if
        next
    end if
end sub

sub onModeChanged(nodeEvent as object)
    showSpinner()
    mode = nodeEvent.getData()
    if mode = "newSub" or mode = "reg" or mode = "liveTV" then
        m.store.command = "getPurchases"
    else
        loadUpsellInfo(mode)
    end if
end sub

sub onPurchasesLoaded(nodeEvent as object)
    purchases = nodeEvent.getData()
    m.purchaseCount = purchases.getChildCount()
    if m.purchaseCount = 0 or m.top.mode = "reg" then
        loadUpsellInfo(m.top.mode)
    else
        config = getGlobalField("config")
        dialog = createCbsDialog("Account Exists", "It looks like you've already subscribed to CBS All Access on this Roku device. Please sign in.", ["OK"])
        dialog.observeField("buttonSelected", "onUpsellErrorDialogClosed")
        setGlobalField("cbsDialog", dialog)
    end if
end sub

sub loadUpsellInfo(mode as string)
    m.loadTask = createObject("roSGNode", "LoadUpsellInfoTask")
    m.loadTask.observeField("upsellScreenInfo", "onUpsellInfoLoaded")
    m.loadTask.upsellType = mode
    m.loadTask.control = "run"
end sub

sub onUpsellInfoLoaded(nodeEvent as object)
    task = nodeEvent.getRoSGNode()
    screenInfo = task.upsellScreenInfo
    config = getGlobalField("config")
    if screenInfo <> invalid and screenInfo.backgroundInfo <> invalid then
        m.top.tourVideoID = screenInfo.backgroundInfo.videoID
        m.header.uri = screenInfo.backgroundInfo.hdPosterUrl
        'm.disclaimer.text = screenInfo.backgroundInfo.message1
        m.title.text = screenInfo.backgroundInfo.message2
        
        options = screenInfo.options
        if screenInfo.buttons.count() > 0 then
            m.top.buttons = screenInfo.buttons
        else if options <> invalid and options.count() > 0 then
            m.noButtons.text = options[0].message3
            options[0].message3 = ""
            m.noButtons.visible = true
        end if
        m.top.options = options
    end if
        
    if createObject("roDeviceInfo").isAudioGuideEnabled() then
        m.tts.say(m.title.text)
    end if
    resetFocus()
    
    hideSpinner()
    
    options = m.top.options
    if options = invalid or options.count() = 0 then
        ' Something went wrong, display an error and back out
        dialog = createCbsDialog("Error", "An unexpected error has occurred. Please contact customer support for assistance at " + config.supportPhone + ".", ["OK"])
        dialog.observeField("buttonSelected", "onUpsellErrorDialogClosed")
        setGlobalField("cbsDialog", dialog)
        return
    end if
end sub

sub onUpsellErrorDialogClosed(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    dialog.close = true
    m.top.close = true
end sub



