sub init()
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        m.top.id = json.id
        m.top.title = json.affiliateName
        m.top.url = json.affiliateUrl
        m.top.station = json.affiliateStation
        m.top.latitude = asFloat(json.stationLatitude)
        m.top.longitude = asFloat(json.stationLongitude)

        m.top.logoUrl = json.logoSelected
        m.top.hdPosterUrl = getImageUrl(json.logoSelected, 0, 72)
        m.top.sdPosterUrl = getImageUrl(json.smallLogoSelected, 0, 30)
    end if
end sub
