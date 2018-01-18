sub initializeAdobe()
    if m.adobe = invalid then
        m.adobe = ADBMobile().getADBMobileConnectorInstance(m.global.adobe)
        m.adobe.setDebugLogging(false)
        m.adobeConstants = m.adobe.sceneGraphConstants()
        m.global.adobe.observeField(m.adobeConstants.API_RESPONSE, "onAdobeApiResponse")

        config = m.global.config
        user = m.global.user
        m.persistentParams = {}
        m.persistentParams["siteCode"] = "CBS"
        m.persistentParams["siteEdition"] = "us"
        m.persistentParams["siteType"] = "roku tv ott|" + lCase(getModel())
        m.persistentParams["sitePrimaryRsid"] = config.omnitureEvar5
        m.persistentParams["userStatus"] = user.trackingStatus
        m.persistentParams["mediaPartnerId"] = "cbs_roku_app|can"
        m.persistentParams["mediaDeviceId"] = getDeviceID()
        m.persistentParams["userRegId"] = user.id
        m.persistentParams["&&products"] = user.trackingProduct
    end if
end sub

sub onAdobeApiResponse(nodeEvent as object)
    response = nodeEvent.getData()
    if response <> invalid then
        method = response.apiName
        value = response.returnValue
        ?"ADBMobile Response (";method;"): ";value
    end if
end sub

sub trackScreenView(screenName = m.top.omnitureName as string)
    initializeAdobe()
    if screenName <> "" then
        params = {}
        params["screenName"] = screenName
        params["pageType"] = m.top.omniturePageType
        params.append(m.persistentParams)

        trackState(screenName, params)
    end if
end sub

sub trackScreenAction(actionName as string, params = {} as object, screenName = m.top.omnitureName as string, pageType = m.top.omniturePageType as string, events = [] as object)
    initializeAdobe()
    params["screenName"] = screenName
    params["pageType"] = pageType
    params.append(m.persistentParams)

    trackAction(actionName, params, events)
end sub

function getOmnitureData(row as object, index as integer, podText = "" as string, podType = "" as string) as object
    'podType|podText|podSection|podPosition|podTitle
    data = {}
    if not isNullOrEmpty(podType) then
        data["podType"] = podType
    else
        if row.subtype() = "MarqueeRow" then
            data["podType"] = "marquee"
        else
            data["podType"] = "grid"
        end if
    end if

    data["podText"] = podText
    item = invalid
    if row.subtype() = "Show" or row.subtype() = "RelatedShow" or row.subtype() = "ShowGroupItem" or row.subtype() = "SearchResults" then
        if index = -1 then
            item = row
        else
            item = row.dynamicPlayEpisode
        end if
    else if row.content <> invalid then
        data["podSection"] = row.content.title
        item = row.content.getChild(index)
    else
        data["podSection"] = row.title
        item = row.getChild(index)
    end if

    data["podPosition"] = index
    if item <> invalid then
        data["podTitle"] = asString(item.title)
        if item.subtype() = "Episode" or item.subtype() = "LiveFeed" then
            data["showId"] = item.showID
            data["showName"] = item.showName
            data["showEpisodeId"] = item.id
            data["showEpisodeTitle"] = item.showName + " - " + item.title
        else if item.subtype() = "Show" or item.subtype() = "RelatedShow" or item.subtype() = "ShowGroupItem" then
            data["showId"] = item.id
            data["showTitle"] = item.title
        else if item.subtype() = "SearchResult" then
            data["showId"] = item.id
            data["showTitle"] = item.title
        else if item.subtype() = "Movie" then
        end if
    end if
    return data
end function

sub trackVideoLoad(video as object, context as object)
    initializeAdobe()

    videoType = "vod:fullepisodes"
    if video.subtype() = "Movie" then
        videoType = "vod:movies"
    else if video.subtype() = "Station" or video.isLive then
        videoType = "live"
    else if not video.isFullEpisode then
        videoType = "vod:clips"
    end if
    m.mediaInfo = adb_media_init_mediainfo(video.trackingTitle, video.trackingContentID, video.length, videoType)
    m.mediaInfo.id = video.id
    m.mediaInfo.length = video.length
    
    m.mediaContext = {}
    m.mediaContext.append(m.persistentParams)
    m.mediaContext.append(context)
    
    m.adobe.mediaTrackLoad(m.mediaInfo, m.mediaContext)
end sub

sub trackVideoUnload()
    initializeAdobe()
    m.adobe.mediaTrackUnload()
end sub

sub trackVideoStart()
    initializeAdobe()
    m.adobe.mediaTrackStart()
end sub

sub trackVideoPlay()
    initializeAdobe()
    m.adobe.mediaTrackPlay()
end sub

sub trackVideoPause()
    initializeAdobe()
    m.adobe.mediaTrackPause()
end sub

sub trackVideoComplete()
    initializeAdobe()
    m.adobe.mediaTrackComplete()
end sub

sub trackAdBreakStart(name as string, startTime as integer, position as integer)
    initializeAdobe()
    breakInfo = adb_media_init_adbreakinfo(name, startTime, position)
    m.adobe.mediaTrackEvent(m.adobe["MEDIA_AD_BREAK_START"], breakInfo, invalid)
end sub

sub trackAdBreakComplete()
    initializeAdobe()
    m.adobe.mediaTrackEvent(m.adobe["MEDIA_AD_BREAK_COMPLETE"], invalid, invalid)
end sub

sub trackAdStart(ad as object, position as integer)
    initializeAdobe()
    m.adInfo = adb_media_init_adinfo(ad.title, ad.creativeid, position, ad.length)
    m.adobe.mediaTrackEvent(m.adobe["MEDIA_AD_START"], m.adInfo, m.mediaContext)
end sub

sub trackAdComplete()
    initializeAdobe()
    m.adobe.mediaTrackEvent(m.adobe["MEDIA_AD_COMPLETE"], m.adInfo, invalid)
end sub

sub trackVideoBufferStart()
    initializeAdobe()
end sub

sub trackVideoBufferComplete()
    initializeAdobe()
end sub

sub trackVideoPlayhead(position as integer)
    initializeAdobe()
    m.adobe.mediaUpdatePlayhead(position)
end sub

sub trackVideoError(errorMessage as string, errorCode as integer)
    initializeAdobe()
    m.adobe.mediaTrackError(errorMessage, errorCode.toStr())
end sub

sub trackState(screenName as string, params as object)
    initializeAdobe()
    m.adobe.trackState(screenName, params)
'    if m.global.analytics <> invalid then
'        m.global.analytics.omnitureParams = { method: "trackPage", params: [screenName]}   
'    end if     
end sub

sub trackAction(actionName as string, params as object, events = [] as object)
    initializeAdobe()
    
    ' Remove any legacy omniture params
    for each param in params.keys()
        if param.mid(0, 1) = "v" or param.mid(0, 2) = "pe" then
            params.delete(param)
        end if
    next
    m.adobe.trackAction(actionName, params)
'    if m.global.analytics <> invalid then
'        additionalParams = {}
'        if actionName = "trackPodSelect" or actionName = "trackShowFilterSelect" then
'            events = ["event19"]
'            additionalParams["pev2"] = "trackClick"
'        end if
'        additionalParams["pe"] = "lnk_o"
'    
'        additionalParams["pageName"] = asString(params["screenName"])
'        additionalParams["v6"] = asString(params["siteHier"])
'        additionalParams["v10"] = asString(params["pageType"])
'        if isNullOrEmpty(params["showEpisodeTitle"]) then
'            additionalParams["v25"] = asString(params["showTitle"])
'        else
'            additionalParams["v25"] = asString(params["showEpisodeTitle"])
'        end if
'        additionalParams["v31"] = asString(params["showEpisodeId"])
'        if params["&&products"] <> invalid then
'            additionalParams["products"] = params["&&products"]
'        end if
'        for each param in params
'            if param.mid(0, 1) = "v" or param.mid(0, 2) = "pe" then
'                additionalParams[param] = params[param]
'            end if
'        next
'        linkName = asString(params["podType"]) + "|" + asString(params["podText"]) + "|" + asString(params["podSection"]) + "|" + asString(params["podPosition"]) + "|" + asString(params["podTitle"]) 
'        m.global.analytics.omnitureParams = { method: "trackEvent", params: [linkName, events, additionalParams]}
'    
'        ?"Omniture: ";formatJson({ method: "trackEvent", params: [linkName, events, additionalParams]})
'    end if
end sub