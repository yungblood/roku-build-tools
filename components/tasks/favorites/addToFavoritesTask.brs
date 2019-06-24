sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.top)
    
    user = getGlobalField("user")
    if user <> invalid then
        if not isNullOrEmpty(m.top.showID) then
            api.addShowToFavorites(m.top.showID)
            user.favorites.update = true
        end if
    end if
end sub
