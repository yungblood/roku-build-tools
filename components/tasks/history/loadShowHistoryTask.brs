sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.top)
    
    config = getGlobalField("config")
    if config <> invalid and config.enableTaplytics = true then
        taplyticsApi = getGlobalComponent("taplytics")
        if taplyticsApi <> invalid then
            response = taplyticsApi.callFunc("getRunningExperimentsAndVariations")
            if response.experiments <> invalid and response.experiments["Shows You Watch - Sort Order"] <> invalid then
                ' The SYW experiment is running, get the sort order
                m.top.sortOrder = taplyticsApi.callFunc("getValueForVariable", { name: "SYWSortOrder", default: m.top.sortOrder })
            end if
        end if
    end if

    m.top.history = api.getShowHistory(m.top.sortOrder)
end sub