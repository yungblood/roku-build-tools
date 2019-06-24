sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.top)

    config = getGlobalField("config")
    if m.top.groupID = config.allShowsGroupID then
        shows = getGlobalField("shows")
        if shows = invalid or shows.count() = 0 then
            shows = api.getGroupShows(m.top.groupID)
        end if
        m.top.shows = shows
    else
        m.top.shows = api.getGroupShows(m.top.groupID)
    end if
end sub
