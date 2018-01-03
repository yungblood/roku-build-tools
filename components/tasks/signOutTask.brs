sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    config = m.global.config
    
    api = cbs()
    api.initialize(config)
    
    deleteRegistryValue("AuthToken", api.registrySection)
    deleteRegistryValue("Username", api.registrySection)
    deleteRegistryValue("Password", api.registrySection)
    deleteRegistryValue("liveTV", api.registrySection)
    m.global.cookies = ""
    m.global.stations = []
    m.global.station = ""
    api.signOut()

    shows = api.getGroupShows(config.allShowsGroupID)
    showCache = {}
    for each show in shows
        showCache[show.id] = show
    next
    m.global.shows = shows
    m.global.showCache = showCache
    m.global.user = createObject("roSGNode", "User")

    m.top.signedOut = true
end sub
