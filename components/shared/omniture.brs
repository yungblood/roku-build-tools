sub initializeAdobe()
    if m.adobe = invalid then
        adobe = getGlobalField("adobe")
        m.adobe = ADBMobile().getADBMobileConnectorInstance(adobe)
        m.adobeConstants = m.adobe.sceneGraphConstants()
        adobe.observeField(m.adobeConstants.API_RESPONSE, "onAdobeApiResponse")

        config = getGlobalField("config")
        user = getGlobalField("user")
        m.persistentParams = {}
        m.persistentParams["siteCode"] = "CBS"
        m.persistentParams["siteEdition"] = "us"
        m.persistentParams["siteType"] = "roku tv ott|" + lCase(getModel())
        m.persistentParams["brandPlatformId"] = "cbscom_ott_roku"
        m.persistentParams["sitePrimaryRsid"] = config.omnitureEvar5
        m.persistentParams["userStatus"] = user.trackingStatus
        m.persistentParams["mediaPartnerId"] = "cbs_roku_app"
        m.persistentParams["mediaDistNetwork"] = "can"
        m.persistentParams["mediaDeviceId"] = getPersistedDeviceID()
        m.persistentParams["adDeviceId"] = getAdvertisingID()
        m.persistentParams["userRegId"] = user.id
        m.persistentParams["&&products"] = user.trackingProduct
        if user.status="ANONYMOUS" then
            m.persistentParams["userType"]="ANON"
        else
            m.persistentParams["userType"]=user.status
        end if
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

sub trackScreenView(screenName = m.top.omnitureName as string, additionalParams = {} as object)
    initializeAdobe()
    if screenName <> "" then
        params = {}
        params["screenName"] = screenName
        params["pageType"] = m.top.omniturePageType
        params["siteHier"] = m.top.omnitureSiteHier
        deeplink = getGlobalField("deeplinkForTracking")
        if not isNullOrEmpty("deeplinkForTracking") then
            params["refSource"] = deeplink
            ' We only track the deeplink on the first screen,
            ' reset it here
            setGlobalField("deeplinkForTracking", "")
        end if

        params.append(additionalParams)
        params.append(m.persistentParams)

        trackState(screenName, params)
    end if
end sub

sub trackScreenAction(actionName as string, params = {} as object, screenName = m.top.omnitureName as string, pageType = m.top.omniturePageType as string, events = [] as object, siteHier = m.top.omnitureSiteHier as string)
    initializeAdobe()

    allParams = {}
    allParams["screenName"] = screenName
    allParams["pageType"] = pageType
    if not isNullOrEmpty(siteHier) then
        allParams["siteHier"] = siteHier
    end if
    allParams.append(m.persistentParams)
    allParams.append(params)

    trackAction(actionName, allParams, events)
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
    if row <> invalid then
        if row.subtype() = "Show" or row.subtype() = "RelatedShow" or row.subtype() = "ShowGroupItem" or row.subtype() = "SearchResults" then
            if index = -1 then
                item = row
            else
                item = row.dynamicPlayEpisode
            end if
        else if row.content <> invalid and isSGNode(row.content) then
            data["podSection"] = row.content.title
            item = row.content.getChild(index)
        else
            data["podSection"] = row.title
            item = row.getChild(index)
        end if
    end if
    if index = invalid then index = -1
    
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
        else if item.subtype() = "LiveTVChannel" then
            data["podTitle"] = asString(item.trackingTitle)
            data["podSection"] = "live channels"
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
    m.mediaInfo.id = video.trackingContentID
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
    m.videoStarted = true
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
    if m.videoStarted = true then
        initializeAdobe()
        m.adobe.mediaTrackComplete()
        m.videoStarted = false
    end if
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

sub trackVideoError(errorMessage as string, errorCode as object)
    initializeAdobe()
    m.adobe.mediaTrackError(errorMessage, asString(errorCode))
end sub

sub trackState(screenName as string, params as object)
    initializeAdobe()
    m.adobe.trackState(screenName, params)
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
end sub