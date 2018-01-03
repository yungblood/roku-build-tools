sub init()
    m.top.observeField("json", "onRelatedShowJsonChanged")
end sub

sub onRelatedShowJsonChanged()
    json = m.top.json
    if json <> invalid then
        m.top.id = json.relatedShowId
        m.top.title = json.relatedShowTitle
    end if
end sub