sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    config = m.global.config
    syncbak().initialize(config.syncbakKey, config.syncbakSecret, config.syncbakBaseUrl)
    schedule = syncbak().getSchedule(m.top.scheduleUrl)
    
    m.top.schedule = schedule
end sub
