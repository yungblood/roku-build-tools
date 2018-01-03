sub init()
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        m.top.id = json.stationId
        m.top.parentStationID = json.parentStationID
        m.top.mediaID = json.mediaID
        m.top.title = json.name
        m.top.description = json.description
        m.top.closedCaptions = json.supportsClosedCaptions
        m.top.scheduleUrl = json.scheduleUrl
        
        if json.scheduleUrls <> invalid then
            if json.scheduleUrls["v3"] <> invalid then
                m.top.scheduleUrl = json.scheduleUrls["v3"]
            end if
        end if
        
        m.top.token = json.token
        
        m.top.trackingID = json.stationId
        m.top.trackingTitle = json.name + "-liveTV"
        m.top.convivaTrackingTitle = json.name + "-LiveTV"
        m.top.omnitureTrackingTitle = json.name + "-LiveTV"
        m.top.comscoreTrackingTitle = m.top.trackingTitle
        m.top.trackingContentID = ""
    end if
end sub
