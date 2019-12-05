sub init()
    m.top.omnitureName = "/settings/"
    m.top.omniturePageType = "settings"
    m.top.omnitureSiteHier = "other|other|settings|home"    

    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.menu = m.top.findNode("menu")
    m.menu.observeField("buttonSelected", "onMenuItemSelected")
    
    m.settingsButtons = m.top.findNode("settingsButtons")
    'm.settingsButtons.observeField("buttonFocused", "onButtonFocused")
    m.settingsButtons.observeField("buttonSelected", "onButtonSelected")

    m.panels = m.top.findNode("panels")
    m.accountPanel = m.top.findNode("accountPanel")
    m.accountPanel.observeField("buttonSelected", "onPanelButtonSelected")
    
    m.legalPanel = m.top.findNode("legalPanel")
    
    m.supportPanel = m.top.findNode("supportPanel")
    
    m.liveTVPanel = m.top.findNode("liveTVPanel")
    m.liveTVPanel.observeField("buttonSelected", "onPanelButtonSelected")

    m.lastPanel = m.accountPanel
end sub

sub onFocusChanged(nodeEvent as object)
    if m.top.hasFocus() then
        focusPanel(m.lastPanel.id, false)
    end if
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
                focusPanel(m.lastPanel.id)
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

sub onButtonFocused()
    if m.lastSetting <> invalid then
        m.lastSetting.highlighted = false
    end if

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

sub onButtonSelected(nodeEvent as object)
    button = m.settingsButtons.getChild(nodeEvent.getData())
    focusPanel(button.id + "Panel")
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

function focusPanel(panelID = "" as string, setFocus = true as boolean) as boolean
    buttonID = panelID.replace("Panel", "")
    panel = m.top.findNode(panelID)
    if panel <> invalid then
        if m.lastPanel <> invalid and not panel.isSameNode(m.lastPanel) then
            m.lastPanel.visible = false
        end if
        panel.visible = true
        panel.callFunc("read", {})
        m.lastPanel = panel

        podIndex = 0
        for i = 0 to m.settingsButtons.getChildCount() - 1
            button = m.settingsButtons.getChild(i)
            if button.id = buttonID then
                button.highlighted = true
                podIndex = i
            else
                button.highlighted = false
            end if
        next

        if panel.focusable and setFocus then
            panel.setFocus(true)

            params = {}
            params["podType"] = "settings"
            params["podText"] = lCase(buttonID)
            params["podPosition"] = podIndex
            trackScreenAction("trackPodSelect", params)
        else
            m.settingsButtons.setFocus(true)
        end if
    end if
end function
