sub init()
    m.top.focusable = false
    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.content = m.top.findNode("content")
    m.signedOut = m.top.findNode("signedOut")
    m.signedIn = m.top.findNode("signedIn")
    m.unavailable = m.top.findNode("unavailable")
    m.stations = m.top.findNode("channels")
    m.stations.observeField("buttonSelected", "onStationSelected")
    
    observeGlobalField("user", "updateContent")
    updateContent()

    m.tts = createObject("roTextToSpeech")
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
    
    if isAuthenticated(m.top) then
        m.loadTask = createObject("roSGNode", "LoadLiveStationsTask")
        m.loadTask.observeField("stations", "onStationsLoaded")
        m.loadTask.loadChannels = false
        m.loadTask.control = "run"
    else
        m.content.appendChild(m.signedOut)
        m.signedOut.visible = true
    end if
end sub

sub onStationsLoaded(nodeEvent as object)
    m.loadTask = invalid
    stations = nodeEvent.getData()
    m.top.focusable = (stations.count() > 1)
    if stations.count() = 0 then
        m.content.appendChild(m.unavailable)
        m.unavailable.visible = true
    else
        stationIndex = 0
        stationID = getGlobalField("localStation")
        m.content.appendChild(m.signedIn)
        m.stations.removeChildrenIndex(m.stations.getChildCount(), 0)
        for i = 0 to stations.count() - 1
            station = stations[i]
            if station.id = stationID then
                stationIndex = i
            end if
            button = m.stations.createChild("LiveTVButton")
            button.station = station
            button.processKeyEvents = false
            button.selected = (station.id = stationID)
        next
        m.stations.jumpToIndex = stationIndex
    end if
end sub

sub onStationSelected(nodeEvent as object)
    button = m.stations.getChild(nodeEvent.getData())
    if button <> invalid then
        config = getGlobalField("config")
        setGlobalField("localStation", button.station.id)
        m.regTask = createObject("roSGNode", "RegistryTask")
        m.regTask.key = "liveTV"
        m.regTask.value = button.station.id
        m.regTask.section = config.registrySection
        m.regTask.mode = "save"
    end if
    for i = 0 to m.stations.getChildCount() - 1
        station = m.stations.getChild(i)
        station.selected = station.isSameNode(button)
    next
end sub

function read(params = {} as object) as boolean
    if createObject("roDeviceInfo").isAudioGuideEnabled() then
        if m.signedOut.visible then
            m.tts.say(m.signedOut.text)
        else if m.unavailable.visible then
            m.tts.say(m.unavailable.text)
        else
            m.tts.say("Available local stations")
            for i = 0 to m.stations.getChildCount() - 1
                button = m.stations.getChild(i)
                station = button.station
                if station <> invalid then
                    m.tts.say(station.title)
                    if button.selected then
                        m.tts.say("Currently Selected")
                    end if
                end if
            next
        end if
    end if
end function