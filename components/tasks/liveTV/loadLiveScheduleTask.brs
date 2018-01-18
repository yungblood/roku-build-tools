sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    schedule = []
    if not isNullOrEmpty(m.top.scheduleUrl) then
        config = m.global.config
        syncbak().initialize(config.syncbakKey, config.syncbakSecret, config.syncbakBaseUrl)
        schedule = syncbak().getSchedule(m.top.scheduleUrl)
    end if
    m.top.schedule = schedule
end sub
