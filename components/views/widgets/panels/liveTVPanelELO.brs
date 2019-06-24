sub init()
    m.top.focusable = true
    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.content = m.top.findNode("content")
    m.signedOut = m.top.findNode("signedOut")
    m.signedIn = m.top.findNode("signedIn")
    m.unavailable = m.top.findNode("unavailable")
    m.override = m.top.findNode("override")
    
    m.checkLocationLabel = m.top.findNode("checkLocationLabel")
    m.checkLocationAvailableText = "If that isn't correct, you can check your location by selecting the button below."
    m.checkLocationUnavailableText = "If that isn't correct, please contact customer support at (888) 274-5343 and we'll be happy to help you!"
    
    m.zipCode = m.top.findNode("zipCode")
    m.enter = m.top.findNode("enter")
    m.enter.observeField("buttonSelected", "onZipCodeEntered")
    
    m.currentLocation = m.top.findNode("currentLocation")
    m.currentLocationCorrect = m.top.findNode("currentLocationCorrect")

    m.currentLocationText = "It looks like you're located in {LOCATION}. Your local station is {CALLSIGN}."
    m.noLocationText = "It looks like Live TV may not be available in your area."
    
    m.zipOverrides = m.top.findNode("zipOverrides")
    m.overridesUnavailable = m.top.findNode("overridesUnavailable")
    m.overrideChannels = m.top.findNode("overrideChannels")

    'm.stations = m.top.findNode("channels")
    'm.stations.observeField("buttonSelected", "onStationSelected")
    m.channels = m.top.findNode("channels")
    
    m.checkLocation = m.top.findNode("checkLocation")
    m.checkLocation.observeField("buttonSelected", "onCheckLocationSelected")
    m.tryAgain = m.top.findNode("tryAgain")
    m.tryAgain.observeField("buttonSelected", "onCheckLocationSelected")
    m.overridesLocked = m.top.findNode("overridesLocked")
    
    m.overrideCount = 0
    
    observeGlobalField("user", "updateContent")
    updateContent()

    m.tts = createObject("roTextToSpeech")
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        if key = "down" then
            if m.channels.hasFocus() then
                if m.checkLocation.visible then
                    m.checkLocation.setFocus(true)
                    return true
                end if
            else if m.zipCode.isInFocusChain() then
                m.enter.setFocus(true)
                return true
            else if m.overrideChannels.isInFocusChain() then
                if m.tryAgain.visible then
                    m.tryAgain.setFocus(true)
                end if
                return true
            end if
        else if key = "up" then
            if m.checkLocation.isInFocusChain() then
                m.channels.setFocus(true)
                return true
            else if m.tryAgain.isInFocusChain() then
                if m.overrideChannels.visible then
                    m.overrideChannels.setFocus(true)
                end if
                return true
            else if m.enter.isInFocusChain() then
                m.zipCode.setFocus(true)
                return true
            end if
        end if
    end if
    return false
end function

sub onFocusChanged()
    if m.top.hasFocus() then
        if m.override.visible then
            m.zipCode.setFocus(true)
        else if m.signedIn.visible then
            m.channels.setFocus(true)
        end if
    end if
end sub

sub updateContent()
    m.content.removeChild(m.signedOut)
    m.content.removeChild(m.unavailable)
    m.content.removeChild(m.signedIn)
    m.content.removeChild(m.override)
    m.content.removeChild(m.zipOverrides)
    
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
    
    task = nodeEvent.getRoSGNode()
    stations = nodeEvent.getData()
    m.top.focusable = (stations.count() > 0)
    if stations.count() = 0 then
        m.content.appendChild(m.unavailable)
        m.unavailable.visible = true
    else
        stationIndex = 0
        stationID = getGlobalField("localStation")
        m.content.appendChild(m.signedIn)
        m.signedIn.visible = true

        m.stations = createObject("roSGNode", "ContentNode")
        m.stations.appendChildren(stations)
        
        m.channels.itemSize = [578,219]
        m.channels.numColumns = 1
        if stations.count() <= 1 then
            m.channels.itemSize = [900,317]
        else if stations.count() > 2 then
            m.channels.numColumns = 2
        end if
        m.channels.content = m.stations

        station = invalid
        for i = 0 to stations.count() - 1
            station = stations[i]
            if station.id = stationID then
                stationIndex = i
                exit for
            end if
        next
        if station = invalid then
            m.currentLocation.text = m.noLocationText
            m.currentLocationCorrect.visible = false
        else
            m.currentLocation.text = m.currentLocationText.replace("{LOCATION}", station.location).replace("{CALLSIGN}", station.title)
            m.currentLocationCorrect.visible = true
        end if
    end if

    if task.canOverride then
        m.checkLocationLabel.text = m.checkLocationAvailableText
        m.checkLocation.visible = true
    else
        m.checkLocationLabel.text = m.checkLocationUnavailableText
        m.checkLocation.visible = false
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

sub onCheckLocationSelected(nodeEvent as object)
    m.content.removeChild(m.signedIn)
    m.signedIn.visible = false
    m.content.removeChild(m.zipOverrides)
    m.zipOverrides.visible = false
    m.content.appendChild(m.override)
    m.override.visible = true
    m.zipCode.setFocus(true)
end sub

sub onZipCodeEntered(nodeEvent as object)
    m.overridesTask = createObject("roSGNode", "LoadLiveTVOverridesTask")
    m.overridesTask.zipCode = m.zipCode.pin
    m.overridesTask.observeField("stations", "onOverrideStationsLoaded")
    m.overridesTask.control = "run"
end sub

sub onOverrideStationsLoaded(nodeEvent as object)
    m.overrideCount++
    m.overridesTask = invalid
    stations = nodeEvent.getData()
    if stations <> invalid then
        m.content.removeChild(m.override)
        m.override.visible = false
        m.content.appendChild(m.zipOverrides)
        m.zipOverrides.visible = true
        
        if stations.count() > 0 then
            m.overridesUnavailable.visible = false
            m.overrideChannels.visible = true
            m.overrideChannels.setFocus(true)
    
            m.overrideChannels.itemSize = [578,219]
            m.overrideChannels.numColumns = 1
            if stations.count() <= 1 then
                m.overrideChannels.itemSize = [900,317]
            else if stations.count() > 2 then
                m.overrideChannels.numColumns = 2
            end if
    
            m.stations = createObject("roSGNode", "ContentNode")
            m.stations.appendChildren(stations)
            m.overrideChannels.content = m.stations
            
            if m.overrideCount >= 2 then
                m.tryAgain.visible = false
                m.overridesLocked.visible = true
            else
                m.tryAgain.visible = true
                m.overridesLocked.visible = false
            end if
        else
            m.overridesUnavailable.visible = true
            m.overrideChannels.visible = false
            m.overridesLocked.visible = false
            m.tryAgain.setFocus(true)
        end if
    end if
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