sub init()
    m.top.focusable = true
    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.observeField("visible", "onVisibleChanged")
    
    m.content = m.top.findNode("content")
    m.signedOut = m.top.findNode("signedOut")
    m.signedIn = m.top.findNode("signedIn")
    m.override = m.top.findNode("override")

    m.localStationLabel = m.top.findNode("localStationLabel")
    
    m.checkLocationGroup = m.top.findNode("checkLocationGroup")
    m.checkLocationLabel = m.top.findNode("checkLocationLabel")
    
    m.eloUnavailableText = "Still not right? Please contact customer support at cbs.com/contactus and we'll be happy to help."

    m.defaultStationsHeader = "Your local station is:"
    m.defaultStationsMultipleHeader = "Your local stations are:"
    m.defaultStationsText = "If this is correct, select the station and then hit 'OK' on your remote to return to live TV." + chr(10) + chr(10) + "Not the right station? Let's fix that."
    m.defaultStationsMultipleText = "If this is correct, select your preferred station, then hit 'OK' on your remote to return to live TV." + chr(10) + chr(10) + "Not the right stations? Let's fix that."
    m.defaultStationsUnavailableHeaderText = "Station not available"
    m.defaultStationsUnavailableText = "We're sorry, but live TV is currently not supported in your area.  To make sure we have your correct location, select the button below."
    
    m.accountStationsHeader = "Based on your account information, your local station is:"
    m.accountStationsMultipleHeader = "Based on your account information, your local stations are:"
    m.accountStationsText = "If this is correct, select the station and then hit 'OK' on your remote to return to live TV." + chr(10) + chr(10) + "Still not the right station? Let's try one more time."
    m.accountStationsMultipleText = "If this is correct, select your preferred station, then hit 'OK' on your remote to return to live TV." + chr(10) + chr(10) + "Still not the right station? Let's try one more time."
    m.accountStationsUnavailableText = "We're sorry, but live TV is currently not supported in your area.  To make sure we have your correct location, select the button below."
    
    m.zipStationsHeader = "Thank you for entering your ZIP Code."
    m.zipStationsMultipleHeader = "Thank you for entering your ZIP Code."
    m.zipStationsText = "If this is correct, select the station and then hit 'OK' on your remote to return to live TV." + chr(10) + chr(10) + m.eloUnavailableText
    m.zipStationsMultipleText = "If this is correct, select your preferred station, then hit 'OK' on your remote to return to live TV." + chr(10) + chr(10) + m.eloUnavailableText
    m.zipStationsUnavailableText = "We're sorry, but live TV is currently not supported in your area." + chr(10) + chr(10) + m.eloUnavailableText

    m.zipEntryStationsText = "If that's correct, just select LIVE TV from the main menu and start streaming!" + chr(10) + chr(10) + "If that isn't correct, enter your current ZIP code and we'll try to reset your location."
    m.zipEntryStationsUnavailableText = "We're sorry, but live TV is currently not supported in your area." + chr(10) + chr(10) + "To make sure we have your correct location, enter your current ZIP code and we'll try to reset your location."

    m.zipOverrideInfo = m.top.findNode("zipOverrideInfo")
    m.liveTVTile = m.top.findNode("liveTVTile")
    m.zipCode = m.top.findNode("zipCode")
    m.enter = m.top.findNode("enter")
    m.enter.observeField("buttonSelected", "onZipCodeEntered")
    
    m.currentLocation = m.top.findNode("currentLocation")
    m.currentLocationCorrect = m.top.findNode("currentLocationCorrect")

    m.overridesUnavailable = m.top.findNode("overridesUnavailable")
    m.overrideChannels = m.top.findNode("overrideChannels")
    
    m.channels = m.top.findNode("channels")
    m.channels.observeField("itemSelected", "onStationSelected")
    
    m.checkLocation = m.top.findNode("checkLocation")
    m.checkLocation.observeField("buttonSelected", "onCheckLocationSelected")
    m.overridesLocked = m.top.findNode("overridesLocked")
    
    m.overrideStage = 0
    m.overrideCount = 0
    m.currentStation = invalid

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
            end if
        else if key = "up" then
            if m.checkLocation.isInFocusChain() then
                if m.channels.visible then
                    m.channels.setFocus(true)
                    return true
                end if
            else if m.enter.isInFocusChain() then
                m.zipCode.setFocus(true)
                return true
            end if
        end if
    end if
    return false
end function

sub onVisibleChanged(nodeEvent as object)
    visible = nodeEvent.getData()
    if visible then
        updateContent()
    end if
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        if m.override.visible then
            m.zipCode.setFocus(true)
        else if m.signedIn.visible then
            if m.channels.visible then
                m.channels.setFocus(true)
            else
                m.checkLocation.setFocus(true)
            end if
        end if
    end if
end sub

sub updateContent()
    trackScreenView()
    
    m.overrideStage = 0

    m.override.visible = false
    m.content.removeChild(m.signedOut)
    m.content.removeChild(m.signedIn)
    m.content.removeChild(m.override)
    m.content.removeChild(m.zipOverrides)
    
    if isSubscriber(m.top) then
        showSpinner()

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
    hideSpinner()

    m.loadTask = invalid
    
    task = nodeEvent.getRoSGNode()
    stations = nodeEvent.getData()

    m.top.focusable = true
    m.localStationLabel.text = m.defaultStationsHeader
    m.checkLocationLabel.text = m.defaultStationsText
    if stations.count() > 1 then
        m.localStationLabel.text = m.defaultStationsMultipleHeader
        m.checkLocationLabel.text = m.defaultStationsMultipleText
    else if stations.count() = 0 then
        m.localStationLabel.text = m.defaultStationsUnavailableHeader
        m.checkLocationLabel.text = m.defaultStationsUnavailableText
    end if

    if stations.count() > 0 then
        m.signedIn.insertChild(m.channels, 1)
        m.channels.visible = true
        if m.top.isInFocusChain() then
            m.channels.setFocus(true)
        end if
    else
        m.channels.visible = false
    end if

    stationIndex = 0
    stationID = getGlobalField("localStation")
    m.content.appendChild(m.signedIn)
    m.signedIn.visible = true

    m.stations = createObject("roSGNode", "ContentNode")
    m.stations.appendChildren(stations)
    
    m.channels.itemSize = [900,172]
    m.channels.numColumns = 1
    if stations.count() > 2 then
        m.channels.itemSize = [578,172]
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
        m.currentLocation.text = m.zipEntryStationsUnavailableText
        m.zipOverrideInfo.removeChild(m.liveTVTile)
    else
        m.currentStation = station
        m.currentLocation.text = m.zipEntryStationsText
        m.liveTVTile.itemContent = station
        m.zipOverrideInfo.insertChild(m.liveTVTile, 1)
    end if

    if task.canOverride then
        m.checkLocationGroup.appendChild(m.checkLocation)
        m.checkLocation.visible = true
    else
        m.checkLocationLabel.text = m.eloUnavailableText
        m.checkLocationGroup.removeChild(m.checkLocation)
        m.checkLocation.visible = false
        m.top.focusable = (stations.count() > 0)
    end if
end sub

sub onStationSelected(nodeEvent as object)
    stations = nodeEvent.getRoSGNode().content
    button = stations.getChild(nodeEvent.getData())
    if button <> invalid then
        config = getGlobalField("config")
        m.regTask = createObject("roSGNode", "RegistryTask")
        m.regTask.section = config.registrySection
        if m.overrideStage > 0 then
            override = {}
            override["liveTV"] = button.id
            override["liveTVLatitude"] = button.affiliate.latitude
            override["liveTVLongitude"] = button.affiliate.longitude

            setGlobalField("localStation", button.id)
            setGlobalField("localStationLatitude", button.affiliate.latitude)
            setGlobalField("localStationLongitude", button.affiliate.longitude)
            m.regTask.values = override
        else
            setGlobalField("localStation", button.id)
            m.regTask.key = "liveTV"
            m.regTask.value = button.id
        end if
        m.regTask.mode = "save"
    end if
    for i = 0 to stations.getChildCount() - 1
        station = stations.getChild(i)
        station.selected = station.isSameNode(button)
        if station.selected then
            m.currentStation = station
        end if
    next
    setGlobalField("lastLiveChannel", "local")
    m.top.buttonSelected = "liveTV"
end sub

sub onCheckLocationSelected(nodeEvent as object)
    m.overrideStage = m.overrideStage + 1
    if m.overrideStage = 1 then
        m.overridesTask = createObject("roSGNode", "LoadLiveTVOverridesTask")
        m.overridesTask.observeField("stations", "onOverrideStationsLoaded")
        m.overridesTask.control = "run"
        
        params = {}
        if m.currentStation <> invalid then
            params["stationCode"] = m.currentStation.title
        end if
        trackScreenAction("trackLocationOverrideCheckLocation_1stCheck", params)
    else
        params = {}
        if m.currentStation <> invalid then
            params["stationCode"] = m.currentStation.title
        end if
        trackScreenAction("trackLocationOverrideCheckLocation_2ndCheck", params)
        showZipCodePanel()
    end if
end sub

sub showZipCodePanel()
    params = {}
    if m.currentStation <> invalid then
        params["stationCode"] = m.currentStation.title
    end if
    trackScreenView("/settings/livetv/location_check_results/enter_zip/", params)

    m.content.removeChild(m.signedIn)
    m.signedIn.visible = false
    m.content.appendChild(m.override)
    m.override.visible = true
    m.zipCode.setFocus(true)
end sub

sub onZipCodeEntered(nodeEvent as object)
    zipCode = m.zipCode.pin
    params = {}
    params["zipCode"] = zipCode
    if m.currentStation <> invalid then
        params["stationCode"] = m.currentStation.title
    end if
    trackScreenAction("trackLocationOverrideEnterZip", params)

    if not isNullOrEmpty(zipCode) and zipCode.len() = 5 then
        m.overrideStage = m.overrideStage + 1
        m.overridesTask = createObject("roSGNode", "LoadLiveTVOverridesTask")
        m.overridesTask.zipCode = m.zipCode.pin
        m.overridesTask.observeField("stations", "onOverrideStationsLoaded")
        m.overridesTask.control = "run"
    else
        dialog = createCbsDialog("Error", "Please enter a valid 5-digit zip code.", ["OK"])
        dialog.observeField("buttonSelected", "closeDialog")
        dialog.returnFocus = m.zipCode
        setGlobalField("cbsDialog", dialog)
    end if
end sub

sub onOverrideStationsLoaded(nodeEvent as object)
    task = nodeEvent.getRoSGNode()
    
    m.overrideCount++
    m.overridesTask = invalid
    stations = nodeEvent.getData()
    if stations <> invalid then
        m.content.removeChild(m.override)
        m.override.visible = false
        m.content.appendChild(m.signedIn)
        m.signedIn.visible = true

        if stations.count() > 0 then
            if m.overrideStage = 1 then
                params = {}
                params["zipCode"] = task.zipCode
                if m.currentStation <> invalid then
                    params["stationCode"] = m.currentStation.title
                end if
                trackScreenView("/settings/livetv/location_check_results/", params)

                m.localStationLabel.text = m.accountStationsHeader
                m.checkLocationLabel.text = m.accountStationsText
                if stations.count() > 1 then
                    m.localStationLabel.text = m.accountStationsMultipleHeader
                    m.checkLocationLabel.text = m.accountStationsMultipleText
                end if
                m.checkLocationGroup.appendChild(m.checkLocation)
            else
                params = {}
                params["zipCode"] = task.zipCode
                if m.currentStation <> invalid then
                    params["stationCode"] = m.currentStation.title
                end if
                trackScreenView("/settings/livetv/location_check_results/enter_zip/confirmation/", params)

                m.localStationLabel.text = m.zipStationsHeader
                m.checkLocationLabel.text = m.zipStationsText
                if stations.count() > 1 then
                    m.localStationLabel.text = m.zipStationsMultipleHeader
                    m.checkLocationLabel.text = m.zipStationsMultipleText
                end if
                m.checkLocationGroup.removeChild(m.checkLocation)
            end if

            m.signedIn.insertChild(m.channels, 1)
            m.channels.visible = true
            m.channels.setFocus(true)
    
            m.channels.itemSize = [900,172]
            m.channels.numColumns = 1
            if stations.count() > 2 then
                m.channels.itemSize = [578,172]
                m.channels.numColumns = 2
            end if
    
            m.stations = createObject("roSGNode", "ContentNode")
            m.stations.appendChildren(stations)
            m.channels.content = m.stations
        else
            if m.overrideStage = 1 then
                showZipCodePanel()
            else
                m.signedIn.removeChild(m.channels)
                m.channels.visible = false
                m.checkLocationLabel.text = m.zipStationsUnavailableText
                m.checkLocationGroup.removeChild(m.checkLocation)
                
                getParentScreen().setFocus(true)
                m.top.focusable = false
            end if
        end if
    end if
end sub

sub closeDialog(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    dialog.close = true
end sub

function read(params = {} as object) as boolean
    if createObject("roDeviceInfo").isAudioGuideEnabled() then
        if m.signedOut.visible then
            m.tts.say(m.signedOut.text)
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