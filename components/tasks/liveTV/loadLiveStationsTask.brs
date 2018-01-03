sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    config = m.global.config
    api = cbs() 'm.global.api
    api.initialize(config)
    
    
    syncbak().initialize(config.syncbakKey, config.syncbakSecret, config.syncbakBaseUrl)
    m.top.stations = syncbak().getChannels()
end sub
