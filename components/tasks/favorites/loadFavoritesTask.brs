sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.top)
    favorites = api.getFavoriteShows()
    m.top.favorites = favorites
end sub
