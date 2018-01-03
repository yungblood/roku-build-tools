sub init()
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        m.top.title = "Season " + json.seasonNum
        m.top.number = json.seasonNum
        m.top.totalCount = json.totalCount
    end if
end sub

sub onLoadPage(nodeEvent as object)
end sub