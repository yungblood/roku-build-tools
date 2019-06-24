sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.top)

    videos = api.getSectionVideos(m.top.sectionID, m.top.excludeShow, m.top.params, m.top.page, m.top.pageSize)
    m.top.videos = videos
end sub
