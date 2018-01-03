sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.global.config, m.global.user, m.global.cookies)

    if m.top.groupID = m.global.config.allShowsGroupID then
        m.top.shows = m.global.shows
    else
        m.top.shows = api.getGroupShows(m.top.groupID)
    end if
end sub
