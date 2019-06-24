sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.top)

    shows = api.getHomeShowGroupShows(m.top.sectionID, m.top.page, m.top.pageSize)
    m.top.shows = shows
end sub
