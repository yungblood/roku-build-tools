sub init()
    m.top.observeField("focusedChild", "onFocusChanged")

    m.navButtons = m.top.findNode("navButtons")
    m.navButtons.observeField("buttonSelected", "onButtonSelected")

    m.home = m.top.findNode("home")
    m.shows = m.top.findNode("shows")
    m.liveTV = m.top.findNode("liveTV")
    m.movies = m.top.findNode("movies")
    m.search = m.top.findNode("search")
    m.settings = m.top.findNode("settings")
    
    m.color = &hffffff66
    m.focusedColor = &hffffffff

    observeGlobalField("config", "onConfigChanged")
    onConfigChanged()
    onFocusedIDChanged()
end sub

sub onConfigChanged()
    config = getGlobalField("config")
    if asString(config.movies_enabled) = "false" then
        m.navButtons.removeChild(m.movies)
    end if
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        if not isNullOrEmpty(m.top.focusedID) then
            m.navButtons.jumpToButton = m.top.focusedID
        end if
        m.navButtons.setFocus(true)
    end if
end sub

sub onFocusedIDChanged()
    for i = 0 to m.navButtons.getChildCount() - 1
        button = m.navButtons.getChild(i)
        if button.id = m.top.focusedID then
            if m.top.isInFocusChain() then
                m.navButtons.jumpToIndex = i
            else
                button.textColor = m.focusedColor
            end if
        else
            button.textColor = m.color
        end if
    next
end sub

sub onButtonSelected(nodeEvent as object)
    index = nodeEvent.getData()
    button = m.navButtons.getChild(index)
    if button <> invalid then
        m.top.buttonSelected = button.id
    end if
end sub


