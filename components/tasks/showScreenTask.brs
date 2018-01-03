sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.global.config, m.global.user, m.global.cookies)

    content = {}
    content.show = api.getShow(m.top.showID, true)
    content.relatedShows = api.getRelatedShows(m.top.showID)
    m.top.content = content
end sub
