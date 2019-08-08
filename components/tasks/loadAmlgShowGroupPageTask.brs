sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.top)

    shows = api.getAmlgVariantShows(m.top.variant, m.top.page, m.top.pageSize, m.top.hideIfTrending)
    m.top.shows = shows
end sub
