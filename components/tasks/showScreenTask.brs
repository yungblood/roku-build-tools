sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.top)

    content = {}
    show = api.getShow(m.top.showID, true)
    if show <> invalid and show.errorCode = invalid then
        relatedShows = api.getRelatedShows(m.top.showID)
        content.show = show
        content.relatedShows = relatedShows
        m.top.content = content
    else
        if show <> invalid then
            m.top.errorCode = asInteger(show.errorCode)
        end if
        m.top.content = {}
    end if
end sub
