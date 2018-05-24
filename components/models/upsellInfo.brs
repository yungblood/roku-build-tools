sub init()
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        m.top.productCode = json.aaProductID
        m.top.videoID = json.contentID
        m.top.showID = json.showId
        m.top.campaign = json.campaign

        m.top.liveDate = dateFromISO8601String(json["_liveDate"]).asSeconds()
        m.top.expireDate = dateFromISO8601String(json["_expireDate"]).asSeconds()
        
        m.top.title = json.title
        m.top.hdPosterUrl = getImageUrl(json.upsellHDImagePath, 1920)
        if m.top.hdPosterUrl = invalid or m.top.hdPosterUrl = "" then
            m.top.hdPosterUrl = getImageUrl(json.upsellImagePath, 1920)
        end if
        m.top.logoUrl = getImageUrl(json.upsellImage2Path, -1)

        m.top.message1 = json.upsellMessage
        m.top.message2 = json.upsellMessage2
        m.top.message3 = json.upsellMessage3
        
        m.top.frequency = json.displayFrequency

        m.top.actionType = json.actionType
        m.top.actionTarget = json.actionTarget
        m.top.callToAction = json.callToAction
        m.top.callToActionUrl = json.callToActionUrl
        
        m.top.userStates = json.userStateList
        
        if not isNullOrEmpty(m.top.productID) then
            m.top.product = channelStore().getProduct(m.top.productID)
        end if
    end if
end sub