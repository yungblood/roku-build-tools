sub init()
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        m.top.id = json.id
        m.top.showID = json.cbsShowId
        m.top.displayOrder = json.displayOrder
        m.top.dateAdded = json.dateAdded
    end if
end sub