sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    addGlobalField("deviceID", "string", false)
    addGlobalField("cookies", "string", false)
    addGlobalField("shows", "nodearray", false)
    addGlobalField("showCache", "assocarray", false)
    addGlobalField("liveTVChannels", "node", false)
    addGlobalField("lastLiveChannel", "string", false)
    addGlobalField("stations", "nodearray", false)
    addGlobalField("localStation", "string", false)
    addGlobalField("localStationLatitude", "float", false)
    addGlobalField("localStationLongitude", "float", false)
    addGlobalField("deeplinkForTracking", "string", false)
    addGlobalField("correlator", "string", false)
    addGlobalField("spotXCampaign", "stringarray", false)

    config = getGlobalField("config")
    api = cbs()
    api.initialize(m.top)
    config.append(api.getConfiguration())
    config.ipAddress = api.getIPAddress()
    config.geoBlocked = false

    setGlobalField("config", config)

    setGlobalField("shows", [])
    setGlobalField("showCache", {})
    setGlobalField("stations", [])

    addGlobalField("user", "node", false)
    setglobalField("user", createObject("roSGNode", "User"))
    
    addGlobalField("analytics", "node", false)
    analyticsTask = createObject("roSGNode", "AnalyticsTask")
    analyticsTask.control = "run"
    setGlobalField("analytics", analyticsTask)
    
    addGlobalField("adobe", "node", false)
    adobeTask = createObject("roSGNode", "adbmobileTask")
    ' The ADBMobileTask automatically starts itself in init()
    'adobeTask.control = "run"
    setGlobalField("adobe", adobeTask)
    
    ' Started in video thread
    addGlobalField("comscore", "node", false)
    addGlobalField("brightline", "node", false)
    addGlobalField("dai", "node", false)
    
    m.top.initialized = true
end sub
