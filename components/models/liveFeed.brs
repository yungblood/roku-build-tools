sub init()
    m.top.observeField("json", "onLiveFeedJsonChanged")
end sub

sub onLiveFeedJsonChanged()
    json = m.top.json
    if json <> invalid then
        m.top.comscoreTrackingTitle = m.top.showName + " - " + m.top.title
        m.top.convivaTrackingTitle = m.top.title
    end if
end sub