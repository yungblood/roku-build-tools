sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    config = getGlobalField("config")
    
    api = cbs()
    api.initialize(m.top)
    
    deleteRegistryValue("AuthToken", api.registrySection)
    deleteRegistryValue("Username", api.registrySection)
    deleteRegistryValue("Password", api.registrySection)
    deleteRegistryValue("liveTV", api.registrySection)
    deleteRegistryValue("liveTVChannel", api.registrySection)
    deleteRegistryValue("persistedDeviceID", api.registrySection)
    setGlobalField("cookies", "")
    setGlobalField("stations", [])
    setGlobalField("localStation", "")
    setGlobalField("lastLiveChannel", "")
    api.signOut(getPersistedDeviceID())

    shows = api.getGroupShows(config.allShowsGroupID)
    showCache = {}
    for each show in shows
        showCache[show.id] = show
    next
    setGlobalField("shows", shows)
    setGlobalField("showCache", showCache)
    setGlobalField("user", createObject("roSGNode", "User"))

    m.top.signedOut = true
end sub
