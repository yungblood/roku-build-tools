sub init()
    m.top.omnitureName = "/settings/"
    m.top.omniturePageType = "settings"
    m.top.omnitureSiteHier = "other|other|settings|home"    

    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.menu = m.top.findNode("menu")
    m.menu.observeField("buttonSelected", "onMenuItemSelected")
    
    m.settingsButtons = m.top.findNode("settingsButtons")
    m.settingsButtons.observeField("buttonFocused", "onButtonFocused")
    m.settingsButtons.observeField("buttonSelected", "onButtonSelected")

    m.panels = m.top.findNode("panels")
    m.accountPanel = m.top.findNode("accountPanel")
    m.accountPanel.observeField("buttonSelected", "onPanelButtonSelected")
    
    m.legalPanel = m.top.findNode("legalPanel")
    
    m.supportPanel = m.top.findNode("supportPanel")
    
    m.liveTVPanel = m.top.findNode("liveTVPanel")
    m.liveTVPanel.observeField("buttonSelected", "onPanelButtonSelected")
    
    m.buttonTextColor = "0xffffff66"
    m.focusedButtonTextColor = "0x0092f3ff"
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        if key = "left" then
            if m.panels.isInFocusChain() then
                if m.lastFocus <> invalid then
                    m.lastFocus.setFocus(true)
                else
                    m.settingsButtons.setFocus(true)
                end if
                return true
            end if
        else if key = "right" then
            if m.settingsButtons.isInFocusChain() then
                focusPanel()
                return true
            end if
        else if key = "up" then
            if m.settingsButtons.isInFocusChain() or m.panels.isInFocusChain() then
                m.menu.setFocus(true)
                return true
            end if
        else if key = "down" then
            if m.menu.isInFocusChain() then
                m.settingsButtons.setFocus(true)
                return true
            end if
        end if
    end if
    return false
end function

sub onFocusChanged()
    if m.top.hasFocus() then
        if m.lastFocus <> invalid then
            m.lastFocus.setFocus(true)
        else
            hideSpinner()
            m.settingsButtons.setFocus(true)
        end if
        setGlobalField("ignoreBack",false)
    end if
end sub

sub onButtonFocused()
    if m.lastSetting <> invalid then
        m.lastSetting.selected = false
    end if
    
    for i = 0 to m.settingsButtons.getChildCount() - 1
        button = m.settingsButtons.getChild(i)
        button.textColor = m.buttonTextColor
    next

    buttons = m.settingsButtons
    setting = buttons.getChild(buttons.buttonFocused)
    if setting <> invalid then
        for i = 0 to m.panels.getChildCount() - 1
            panel = m.panels.getChild(i)
            panel.visible = (panel.id.inStr(setting.id) = 0)
            if panel.visible then
                m.currentPanel = panel
                if m.readTimer = invalid then
                    m.readTimer = createObject("roSGNode", "Timer")
                    m.readtimer.duration = 1
                    m.readtimer.observeField("fire", "onReadTimerFired")
                end if
                m.readTimer.control = "start"
            end if
        next
    end if
end sub

sub onReadTimerFired(nodeEvent as object)
    if m.currentPanel <> invalid then
        m.currentPanel.callFunc("read", {})
    end if
end sub

sub onButtonSelected()
    focusPanel()
end sub

sub onPanelButtonSelected(nodeEvent as object)
    button = nodeEvent.getData()
    
    params = {}
    params["podType"] = "settings"
    params["podText"] = lCase(button)
    trackScreenAction("trackPodSelect", params) 

    m.top.buttonSelected = button
end sub

sub onMenuItemSelected(nodeEvent as object)
    selection=nodeEvent.getData()
    if selection = "settings" then
        m.settingsButtons.setFocus(true)
        m.lastFocus = m.settingsButtons
    else
        m.top.menuItemSelected = selection
    end if
end sub

function focusPanel() as boolean
    m.lastFocus = m.top.focusedChild
    for i = 0 to m.panels.getChildCount() - 1
        panel = m.panels.getChild(i)
        if panel.visible then
            if panel.focusable then
                currentButton = m.settingsButtons.getChild(m.settingsButtons.buttonFocused)
                if currentButton <> invalid then
                    currentButton.textColor = m.focusedButtonTextColor
                end if
                panel.setFocus(true)

                params = {}
                params["podType"] = "settings"
                params["podText"] = lCase(currentbutton.text)
                params["podPosition"] = i
                trackScreenAction("trackPodSelect", params)

                return true
            end if
            exit for
        end if
    next
    return false
end function
