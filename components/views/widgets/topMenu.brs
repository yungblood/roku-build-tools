sub init()
    m.top.observeField("focusedChild", "onFocusedIDChanged")

    m.navButtons = m.top.findNode("navButtons")
    m.home = m.top.findNode("home")
    m.shows = m.top.findNode("shows")
    m.liveTV = m.top.findNode("liveTV")
    m.movies = m.top.findNode("movies")
    m.search = m.top.findNode("search")
    m.settings = m.top.findNode("settings")
    
    m.tabOrder = [
        m.home
        m.shows
        m.liveTV
        m.movies
        m.search
        m.settings
    ]
    m.tabIndex = 0
    
    m.color = &hffffff66
    m.focusedColor = &hffffffff

    m.global.observeField("config", "onConfigChanged")
    onConfigChanged()
    onFocusedIDChanged()
end sub

sub onConfigChanged()
    config = m.global.config
    if asString(config.movies_enabled) = "false" then
        m.navButtons.removeChild(m.movies)
        for i = 0 to m.tabOrder.count() - 1
            if m.tabOrder[i].isSameNode(m.movies) then
                m.tabOrder.delete(i)
                exit for
            end if
        next
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
?"TopMenu.onKeyEvent", key, press
    if press then
        if key = "right" then
            if m.tabIndex < m.tabOrder.count() - 1 then
                m.tabIndex++
                m.top.focusedID = m.tabOrder[m.tabIndex].id
                return true
            end if
        else if key = "left" then
            if m.tabIndex > 0 then
                m.tabIndex--
                m.top.focusedID = m.tabOrder[m.tabIndex].id
                return true
            end if
        else if key = "OK" then
            m.top.buttonSelected = m.top.focusedID
            return true
        end if
    end if
    return false
end function

sub onFocusedIDChanged()
    for i = 0 to m.tabOrder.count() - 1
        button = m.tabOrder[i]
        if button.id = m.top.focusedID then
            if m.top.isInFocusChain() then
                button.setFocus(true)
                m.tabIndex = i
            else
                button.textColor = m.focusedColor
            end if
        else
            button.textColor = m.color
        end if
    next
end sub

