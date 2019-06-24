sub init()
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        m.top.id = json.stationId
        m.top.parentStationID = json.parentStationID
        m.top.mediaID = json.mediaID
        m.top.title = json.name
        if isNullOrEmpty(m.top.title) then
            m.top.title = json.callSign
        end if
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
        m.top.trackingTitle = m.top.title + "-LiveTV"
        m.top.convivaTrackingTitle = m.top.title + "-LiveTV"
        m.top.omnitureTrackingTitle = m.top.title + "-LiveTV"
        m.top.comscoreTrackingTitle = m.top.trackingTitle
        m.top.trackingContentID = "_55cL7EscO2mdFcpsZVcQ3VtXNA5bcA_"
        
        location = json.city
        if not isNullOrEmpty(json.state) then
            if not isNullOrEmpty(location) then
                location = location + ", "
            end if
            location = location + json.state
        end if
        if isNullOrEmpty(location) then
            location = json.market
        end if
        m.top.location = location
        
        if isNullOrEmpty(m.top.description) then
            m.top.description = m.top.location
        end if
    end if
end sub
