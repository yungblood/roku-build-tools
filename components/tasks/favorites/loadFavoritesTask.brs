sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.global.config, m.global.user, m.global.cookies)
    favorites = api.getFavoriteShows()
    m.top.favorites = favorites
end sub
