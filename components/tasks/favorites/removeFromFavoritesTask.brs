sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.global.config, m.global.user, m.global.cookies)

    user = m.global.user
    if not isNullOrEmpty(m.top.showID) then
        api.removeShowFromFavorites(m.top.showID)
        user.favorites.update = true
    end if
end sub
