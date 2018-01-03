sub init()
    m.top.observeField("focusedChild", "onFocusChanged")
    m.title = m.top.findNode("title")
    m.airtime = m.top.findNode("airtime")
    
    m.metadata = m.top.findNode("metadata")
    m.buttons = m.top.findNode("buttons")
    m.showInfo = m.top.findNode("showInfo")
    m.showInfo.observeField("buttonSelected", "onButtonSelected")
    m.favorite = m.top.findNode("favorite")
    m.favorite.observeField("buttonSelected", "onButtonSelected")
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.buttons.setFocus(true)
    end if
end sub

sub onShowChanged()
    if m.show = invalid or not m.show.isSameNode(m.top.show) then
        m.show = m.top.show
        m.title.text = uCase(m.show.title)
        m.airtime.text = uCase(m.show.tuneInTime)
        
        m.showInfo.addField("showID", "string", false)
        m.showInfo.setField("showID", m.show.id)

        updateButtons()
    end if
end sub

sub updateButtons()
    user = m.global.user
    if user <> invalid and user.status <> "ANONYMOUS" then
        if isFavorite(m.show.id, user.favorites) then
            m.favorite.foregroundUri = "pkg:/images/icon-fav-selected-unfocused.png"
            m.favorite.focusedForegroundUri = "pkg:/images/icon-fav-selected-focused.png"
        else
            m.favorite.foregroundUri = "pkg:/images/icon-fav-unselected-unfocused.png"
            m.favorite.focusedForegroundUri = "pkg:/images/icon-fav-unselected-focused.png"
        end if
    else
        m.buttons.removeChild(m.favorite)
    end if
end sub

sub onButtonSelected(nodeEvent as object)
    button = nodeEvent.getRoSGNode()
    if button <> invalid then
        m.top.buttonSelected = button.id
        updateButtons()
    end if
end sub
