sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    m.global.addField("cookies", "string", false)
    m.global.addField("shows", "nodearray", false)
    m.global.addField("showCache", "assocarray", false)
    m.global.addField("liveTVChannels", "node", false)
    m.global.addField("liveTVChannel", "string", false)
    m.global.addField("stations", "nodearray", false)
    m.global.addField("station", "string", false)

    config = m.global.config
    api = cbs()
    api.initialize(config)
    config.append(api.getConfiguration())
    config.ipAddress = api.getIPAddress()

    m.global.config = config

    m.global.shows = []
    m.global.showCache = {}
    m.global.stations = []

    m.global.addField("user", "node", false)
    m.global.user = createObject("roSGNode", "User")
    
    m.global.addField("analytics", "node", false)
    analyticsTask = createObject("roSGNode", "AnalyticsTask")
    analyticsTask.control = "run"
    m.global.analytics = analyticsTask
    
    m.global.addField("adobe", "node", false)
    adobeTask = createObject("roSGNode", "adbmobileTask")
    ' The ADBMobileTask automatically starts itself in init()
    'adobeTask.control = "run"
    m.global.adobe = adobeTask
    
    m.global.addField("comscore", "node", false)
    comscoreTask = createObject("roSGNode", "ComscoreTask")
    comscoreTask.control = "run"
    m.global.comscore = comscoreTask
    
    ' Add BrightlineTask here 
    m.global.addField("brightline", "node", false)
    brightlineTask = createObject("roSGNode", "BrightlineTask")
    brightlineTask.control = "run"
    m.global.brightline = brightlineTask    
    
    m.global.addField("dai", "node", false)
    daiTask = createObject("roSGNode", "DaiTask")
    daiTask.control = "run"
    m.global.dai = daiTask
    
    m.top.initialized = true
end sub
