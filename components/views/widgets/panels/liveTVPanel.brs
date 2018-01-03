sub init()
    m.top.focusable = false
    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.content = m.top.findNode("content")
    m.signedOut = m.top.findNode("signedOut")
    m.signedIn = m.top.findNode("signedIn")
    m.unavailable = m.top.findNode("unavailable")
    m.stations = m.top.findNode("channels")
    m.stations.observeField("buttonSelected", "onStationSelected")
    
    m.global.observeField("user", "updateContent")
    updateContent()
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.stations.setFocus(true)
    end if
end sub

sub updateContent()
    m.content.removeChild(m.signedOut)
    m.content.removeChild(m.unavailable)
    m.content.removeChild(m.signedIn)
    
    if isAuthenticated(m.global) then
        stations = m.global.stations
        m.top.focusable = (stations.count() > 1)
        if stations.count() = 0 then
            m.content.appendChild(m.unavailable)
        else
            stationIndex = 0
            m.content.appendChild(m.signedIn)
            m.stations.removeChildrenIndex(m.stations.getChildCount(), 0)
            for i = 0 to stations.count() - 1
                station = stations[i]
                if station.id = m.global.station then
                    stationIndex = i
                end if
                button = m.stations.createChild("LiveTVButton")
                button.station = station
                button.processKeyEvents = false
            next
            m.stations.jumpToIndex = stationIndex
        end if
    else
        m.content.appendChild(m.signedOut)
    end if
end sub

sub onStationSelected(nodeEvent as object)
    button = m.stations.getChild(nodeEvent.getData())
    if button <> invalid then
        m.global.station = button.station.id
        m.regTask = createObject("roSGNode", "RegistryTask")
        m.regTask.key = "liveTV"
        m.regTask.value = button.station.id
        m.regTask.section = m.global.config.registrySection
        m.regTask.mode = "save"
    end if
end sub
