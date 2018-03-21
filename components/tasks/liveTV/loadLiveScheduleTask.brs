sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    schedule = []
    if not isNullOrEmpty(m.top.scheduleUrl) then
        config = m.global.config
        scheduleUrl = m.top.scheduleUrl
        if scheduleUrl.mid(0, 4) <> "http" then
            ' This is a proxied url, get the schedule json from the cbs api
            api = cbs()
            api.initialize(config, m.global.user, m.global.cookies)
            scheduleJson = api.makeRequest(api.apiBaseUrl + scheduleUrl, "GET")
            schedule = parseScheduleJson(scheduleJson)
        else
            syncbak().initialize(config.syncbakKey, config.syncbakSecret, config.syncbakBaseUrl)
            schedule = syncbak().getSchedule(scheduleUrl)
        end if
    end if
    m.top.schedule = schedule
end sub
