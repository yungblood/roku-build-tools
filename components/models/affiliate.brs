sub init()
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        m.top.id = json.id
        m.top.title = json.affiliateName
        m.top.url = json.affiliateUrl
        m.top.station = json.affiliateStation
        
        m.top.hdPosterUrl = getImageUrl(json.logoSelected, 0, 72)
        m.top.sdPosterUrl = getImageUrl(json.smallLogoSelected, 0, 30)
        ?m.top.hdPosterUrl
    end if
end sub
