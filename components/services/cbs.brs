function cbs() as object
    if m.cbs = invalid then
        m.cbs = newCbs()
    end if
    return m.cbs
end function

function newCbs() as object
    this                            = {}
    this.className                  = "CBS"
    
    this.user                       = createObject("roSGNode", "User")

    this.registrySection            = constants().registrySection
    this.cookies                    = ""
    this.resumeOffset               = 3

    this.rokuProductCode            = "com.cbsallaccess.subscription.trial" ' "PROD1"
    this.productCode                = "CBS_ALL_ACCESS_PACKAGE" '
    this.signUpUrl                  = "cbs.com/all-access"
    this.tosUrl                     = "http://www.cbs.com/sites/roku/cbs_roku.cfg"
    this.legalUrl                   = "http://www.cbs.com/sites/roku/cbs_roku_legal_notices.cfg"
    
    this.appID                      = "TF7564CEF-EE7C-5EFD-E040-070AAC3132A7"
    this.accountPid                 = "dJ5BDC"
    
    ' Overidden by config.json
    this.dashSelectorUrl            = "http://link.theplatform.com/s/dJ5BDC/[PID]?sig=[SIGNATURE]&switch=roku" '&format=SMIL&tracking=true&mbr=true"
    this.selectorUrl                = "http://link.theplatform.com/s/dJ5BDC/[PID]?sig=[SIGNATURE]&mbr=true&manifest=m3u&format=redirect&assetTypes=StreamPack%7COTT"

    this.initialize                 = cbs_initialize
    this.setUser                    = cbs_setUser
    this.setCookies                 = cbs_setCookies
    
    this.clearCache                 = cbs_clearCache
    
    this.getConfiguration           = cbs_getConfiguration
    
    this.getIPAddress               = cbs_getIPAddress
    
    this.getMarquee                 = cbs_getMarquee
    this.getEpisode                 = cbs_getEpisode
    this.getMovie                   = cbs_getMovie
    this.getNextEpisode             = cbs_getNextEpisode
    this.getContinuousPlayInfo      = cbs_getContinuousPlayInfo
    this.populateStream             = cbs_populateStream
    
    this.getCampaignAvailability    = cbs_getCampaignAvailability
    this.getUpsellInfo              = cbs_getUpsellInfo
    this.getEligibility             = cbs_getEligibility
    
    this.subscribe                  = cbs_subscribe
    this.restoreAccount             = cbs_restoreAccount
    this.createAccount              = cbs_createAccount
    this.getEntitlement             = cbs_getEntitlement
    this.upgrade                    = cbs_upgrade
    this.downgrade                  = cbs_downgrade
    
    this.checkEmailExists           = cbs_checkEmailExists
    this.validateZipCode            = cbs_validateZipCode
    
    this.isAuthenticated            = cbs_isAuthenticated
    this.getUser                    = cbs_getUser
    this.signIn                     = cbs_signIn
    this.setPin                     = cbs_setPin
    this.forgotPassword             = cbs_forgotPassword
    this.signOut                    = cbs_signOut
    this.getActivationCode          = cbs_getActivationCode
    this.checkActivationCode        = cbs_checkActivationCode
    
    this.getVideoSections           = cbs_getVideoSections
    this.getHomeRows                = cbs_getHomeRows
    this.getHomeShowGroupShows      = cbs_getHomeShowGroupShows

    this.getAmlgVariantShows        = cbs_getAmlgVariantShows
    
    this.getMovies                  = cbs_getMovies

    this.getAllShows                = cbs_getAllShows
    this.getShowGroups              = cbs_getShowGroups
    this.getGroupShows              = cbs_getGroupShows
    this.getShows                   = cbs_getShows
    this.getRelatedShows            = cbs_getRelatedShows
    this.getShow                    = cbs_getShow
    this.getShowSections            = cbs_getShowSections
    this.getShowAvailableSeasons    = cbs_getShowAvailableSeasons
    this.getDynamicPlayEpisode      = cbs_getDynamicPlayEpisode
    
    this.getSectionVideos           = cbs_getSectionVideos
    
    this.getLiveTVOverrideCount     = cbs_getLiveTVOverrideCount
    this.getDmaFromZip              = cbs_getDmaFromZip
    this.registerDmaOverride        = cbs_registerDmaOverride
    this.getAffiliate               = cbs_getAffiliate
    this.getLiveChannels            = cbs_getLiveChannels
    
    this.getExperiments             = cbs_getExperiments
    
    this.search                     = cbs_search
    
    this.getFavoriteShows           = cbs_getFavoriteShows
    this.addShowToFavorites         = cbs_addShowToFavorites
    this.removeShowFromFavorites    = cbs_removeShowFromFavorites
    this.getShowHistory             = cbs_getShowHistory

    this.getVideoHistory            = cbs_getVideoHistory
    this.getContinueWatching        = cbs_getContinueWatching
    
    this.getResumePoint             = cbs_getResumePoint
    
    this.isOverStreamLimit          = cbs_isOverStreamLimit
    this.getVideoStreamUrl          = cbs_getVideoStreamUrl
    this.getPlayReadyInfo           = cbs_getPlayReadyInfo
    this.getVideoStreamToken        = cbs_getVideoStreamToken

    this.getVilynxHash              = cbs_getVilynxHash
    
    this.generateAccessToken        = cbs_generateAccessToken
    this.makeRequest                = cbs_makeRequest
    
    setLogLevel(0)

    return this
end function

sub cbs_initialize(context as object)
    config = getGlobalField("config", context)
    user = getGlobalField("user", context)
    cookies = getGlobalField("cookies", context)

    m.append(config)
    if user <> invalid then
        m.setUser(user)
    end if
    m.setCookies(cookies)
end sub

sub cbs_setUser(user as object)
    m.user = user
end sub

sub cbs_setCookies(cookies as string)
    m.cookies = cookies
end sub

sub cbs_clearCache()
    files = listDir("tmp:/")
    for each file in files
        deleteFile("tmp:/" + file)
    next
end sub

function cbs_getConfiguration() as object
    url = m.apiBaseUrl + "v2.0/roku/configuration.json"
    headers = {}
    response = m.makeRequest(url, "GET", invalid, "json", false, headers)
    if isAssociativeArray(response) and response.configs <> invalid then
        config = response.configs
        
        ' Capture the current country code from the response headers
        config.currentCountryCode = lCase(asString(headers["X-Request-IP-Origin-Country"]))
        return response.configs
    end if
    return {}
end function

function cbs_getIPAddress(useCbsApi = true as boolean) as string
    if useCbsApi then
        url = "https://www.cbs.com/apps/user/ip.json"
        result = getUrlToJson(url)
        if result <> invalid and result.success = true then
            return result.ip
        end if
    else
        return getExternalIPAddress()
    end if
    return "Unknown"
end function

function cbs_getMarquee() as object
    url = m.apiBaseUrl + "v3.0/roku/home/marquee.json"
    response = m.makeRequest(url, "GET", invalid, "json", true)
    if isAssociativeArray(response) and response.success = true then
        marquee = createObject("roSGNode", "Marquee")
        marquee.json = response
        return marquee
    end if
    return invalid
end function

function cbs_getMovie(movieID as string, populateStream = false as boolean) as object
    url = m.apiBaseUrl + "v3.0/roku/movies/" + urlEncode(movieID) + ".json"
    url = addQueryString(url, "includeContentInfo", true)
    url = addQueryString(url, "includeTrailerInfo", true)
    response = m.makeRequest(url, "GET", invalid, "json", true)
    if isAssociativeArray(response) then
        if response.success = true then
            item = response.movie
            if item <> invalid then
                if item.movieContent <> invalid then
                    movie = createObject("roSGNode", "Movie")
                    movie.json = item.movieContent
                    if item.trailerContent <> invalid then
                        trailer = createObject("roSGNode", "Trailer")
                        trailer.json = item.trailerContent
                        movie.trailer = trailer
                    end if
                    movie.resumePoint = m.getResumePoint(movieID)
                    if populateStream then
                        m.populateStream(movie)
                    end if
                    return movie
                end if
            end if
        else if response.errorCode <> invalid then
            return response
        end if
    end if
    return invalid
end function

function cbs_getEpisode(episodeID as string, populateStream = false as boolean) as object
    url = m.apiBaseUrl + "v2.0/roku/videos/item.json"
    url = addQueryString(url, "contentId", episodeID)
    response = m.makeRequest(url, "GET", invalid, "json", true)
    if isAssociativeArray(response) then
        if response.success = true and isAssociativeArray(response.results) then
            item = asArray(response.results.itemList)[0]
            if item <> invalid then
                episode = invalid
                if item.mediaType = "Movie" then
                    episode = createObject("roSGNode", "Movie")
                else if item.isLive = true then
                    episode = createObject("roSGNode", "LiveFeed")
                else
                    episode = createObject("roSGNode", "Episode")
                end if
                episode.json = item
                episode.resumePoint = m.getResumePoint(episodeID)
                if populateStream then
                    m.populateStream(episode)
                end if
                return episode
            end if
        else if response.errorCode <> invalid then
            return response
        end if
    end if
    return invalid
end function

function cbs_getNextEpisode(episodeID as string, showID as string, populateStream = false as boolean) as object
    if showID <> "-1" then
        url = m.apiBaseUrl + "v3.0/roku/shows/" + showID + "/video/autoplay/nextEpisode.json"
        url = addQueryString(url, "contentId", episodeID)
        response = m.makeRequest(url, "GET")
        if isAssociativeArray(response) and response.success = true then
            if response.nextVideo <> invalid then
                episode = invalid
                if response.nextVideo.mediaType = "Movie" then
                    episode = createObject("roSGNode", "Movie")
                else
                    episode = createObject("roSGNode", "Episode")
                end if
                episode.json = response.nextVideo
                if populateStream then
                    m.populateStream(episode)
                end if
                return episode
            end if
        end if
    end if
    return invalid
end function

function cbs_getContinuousPlayInfo(episodeID as string, showID as string, testSegmentID = "default_free_all_platforms" as string, populateStream = false as boolean) as object
    if showID <> "-1" then
        url = m.apiBaseUrl + "v3.0/roku/continuousplay/shows/" + showID + "/content/" + episodeID + "/nextEpisode.json"
        url = addQueryString(url, "testSegmentId", testSegmentID)
        response = m.makeRequest(url, "GET")
        if isAssociativeArray(response) and response.success = true then
            if response.nextVideo <> invalid then
                episode = invalid
                if response.nextVideo.mediaType = "Movie" then
                    episode = createObject("roSGNode", "Movie")
                else
                    episode = createObject("roSGNode", "Episode")
                end if
                episode.json = response.nextVideo
                if populateStream then
                    m.populateStream(episode)
                end if
                
                cpInfo = createObject("roSGNode", "ContinuousPlayInfo")
                cpInfo.episode = episode
                return cpInfo
            else
                if response.endcardTest <> invalid then
                    videos = []
                    for each config in response.endcardTest.endpointConfiguration
                        response = invalid
                        watchNextType = ""
                        if config.endpoint = "related_show" then
                            watchNextType = "multi-next-show_related"
                            url = m.apiBaseUrl + "v3.0/roku/continuousplay/content/" + episodeID + "/related.json"
                            response = m.makeRequest(url, "GET")
                        else if config.endpoint = "related_show_history" then
                            watchNextType = "multi-next-show_related_history"
                            url = m.apiBaseUrl + "v3.0/roku/continuousplay/shows/" + showID + "/content/" + episodeID + "/hint/relatedHistory.json"
                            response = m.makeRequest(url, "GET")
                        else if config.endpoint = "mycbs" then
                            watchNextType = "multi-next-show_mycbs"
                            url = m.apiBaseUrl + "v3.0/roku/continuousplay/content/" + episodeID + "/hint/mycbs.json"
                            response = m.makeRequest(url, "GET")
                        else if config.endpoint = "recently_watched" then
                            watchNextType = "multi-next-show_recent"
                            url = m.apiBaseUrl + "v3.0/roku/continuousplay/shows/" + showID + "/content/" + episodeID + "/hint/history.json"
                            response = m.makeRequest(url, "GET")
                        else if config.endpoint = "promoted" then
                            watchNextType = "multi-next-show_promo"
                            url = m.apiBaseUrl + "v3.0/roku/continuousplay/hint/promoted.json"
                            response = m.makeRequest(url, "GET")
                        end if
                        if response <> invalid then
                            count = 0
                            if response.videos <> invalid then
                                for each video in response.videos
                                    recommendation = createObject("roSGNode", "Recommendation")
                                    recommendation.type = config.endpoint
                                    recommendation.json = video
                                    recommendation.watchNextType = watchNextType
                                    videos.push(recommendation)
                                    count++
                                    if count >= config.contentCount then
                                        exit for
                                    end if
                                next
                            else if response.promoted <> invalid then
                                for each video in response.promoted
                                    recommendation = createObject("roSGNode", "Recommendation")
                                    recommendation.type = config.endpoint
                                    recommendation.json = video
                                    if recommendation.video.isLive then
                                        watchNextType = watchNextType + "-live-event"
                                    else
                                        watchNextType = watchNextType + "-show"
                                    end if
                                    recommendation.watchNextType = watchNextType
                                    videos.push(recommendation)
                                    count++
                                    if count >= config.contentCount then
                                        exit for
                                    end if
                                next
                            end if
                        end if
                    next
                    if videos.count() > 0 then
                        cpInfo = createObject("roSGNode", "ContinuousPlayInfo")
                        cpInfo.videos = videos
                        return cpInfo
                    end if
                end if
            end if
        end if
    end if
    return invalid
end function

sub cbs_populateStream(episode as object)
    if episode <> invalid and not isNullOrEmpty(episode.pid) then
        stream = createObject("roSGNode", "VideoStream")
        stream.title = episode.title
        stream.titleSeason = episode.titleSeason
        if episode.isProtected or episode.assetType = "DASH_CENC_PRECON" then
            playReady = m.getPlayReadyInfo(episode.id)
            stream.streamFormat = "dash"
            stream.encodingType = "PlayReadyLicenseAcquisitionUrl"
            stream.encodingKey = playReady.url
            stream.url = m.getVideoStreamUrl(episode.pid, m.dashSelectorUrl)
        else
            stream.url = m.getVideoStreamUrl(episode.pid)
            stream.streamFormat = "hls"
        end if
        stream.switchingStrategy = "full-adaptation"
        stream.subtitleConfig    = episode.subtitleConfig
        stream.sdBifUrl          = episode.sdBifUrl
        stream.hdBifUrl          = episode.hdBifUrl
        
        if episode.isLive then
            stream.live = true
            stream.playStart = createObject("roDateTime").asSeconds() + 9999999
        end if
        
        episode.videoStream = stream

        vmapUrl = m.vmapUrl
        vmapUrl = addQueryString(vmapUrl, "ppid", m.user.ppid)
        customParams = asString(m.user.adStatus) ' "sb=14" ' 
        cbsU = parseCookies(m.cookies)["CBS_U"]
        if not isNullOrEmpty(cbsU) then
            ' Convert "ge:1|gr:2" to ge=1&gr=2
            customParams = customParams + "&" + cbsU.replace(":", "=").replace("|", "&").replace(Chr(34), "")
        end if
        customParams = customParams + "&ppid=" + asString(m.user.ppid)
        customParams = customParams + "&appid=" + m.appID
        vmapUrl = addQueryString(vmapUrl, "cust_params", customParams)
        episode.vmapUrl = vmapUrl
        
        ' TODO: Add vid, vguid, appid, campaign, and show

        adParams = {}
        adParams["ppid"] = m.user.ppid
        adParams["ppid_encoded"] = urlEncode(m.user.ppid)
        
        spotXCampaign = asArray(getGlobalField("spotXCampaign"))
        campaign = spotXCampaign.join(",")
        if not isNullOrEmpty(campaign) then
            customParams = customParams + "&campaign=" + urlEncode(campaign)
        end if
        
        adParams["cust_params"] = customParams
        adParams["cust_params_encoded"] = urlEncode(customParams)
        episode.adParams = adParams
    end if
end sub

function cbs_getCampaignAvailability(pageUrl = "CBS_ALL_ACCESS_PACKAGE" as string) as string
    url = m.apiBaseUrl + "v3.0/roku/upsell/campaign/availability.json?pageURL=" + urlEncode(pageUrl)
    result = m.makeRequest(url, "GET")
    if isAssociativeArray(result) and result.upsellCampaignAvailability <> invalid then
        creationTime = getDeviceCreationTime()
        if creationTime <> invalid then
            for each campaign in asArray(result.upsellCampaignAvailability)
                if campaign.liveDate / 1000 <= creationTime.AsSeconds() and campaign.expiresOn / 1000 > creationTime.AsSeconds() then
                    return campaign.campaign
                end if
            next
        end if
    end if
    return ""
end function

function cbs_getUpsellInfo(pageUrl as string, campaign = "" as string, userState = "" as string) as object
    url = m.apiBaseUrl + "roku/upsell.json?pageURL=" + urlEncode(pageUrl)
    if not isNullOrEmpty(campaign) then
        url = url + "&upsellCampaign=" + urlEncode(campaign)
    end if
    result = m.makeRequest(url, "GET")
    if isAssociativeArray(result) and result.upsellInfo <> invalid then
        state = userState
        if isNullOrEmpty(state) and m.user <> invalid then
            state = m.user.status
        end if
        if isNullOrEmpty(state) then
            state = "ANONYMOUS"
        end if
        upsellInfos = asArray(result.upsellInfo)
        for each upsellInfo in upsellInfos
            if arrayContains(upsellInfo.userStateList, state) then
                info = createObject("roSGNode", "UpsellInfo")
                info.json = upsellInfo
                return info
            end if
        next
    end if
    if result <> invalid and result.errorCode <> invalid then
        return result
    end if
    return invalid
end function

function cbs_getEligibility() as object
    url = m.apiBaseUrl + "v2.0/roku/subscription/upgrade/eligibility.json"
    products = {
        upgrades: []
        downgrades: []
    }
    response = m.makeRequest(url, "GET")
    if isAssociativeArray(response) and response.success = true then
        for each item in asArray(response["productUpgradeList: "])
            product = createObject("roSGNode", "Product")
            product.json = item
            products.upgrades.push(product)
        next
        for each item in asArray(response["productDowngradeList: "])
            product = createObject("roSGNode", "Product")
            product.json = item
            products.downgrades.push(product)
        next
        for each item in asArray(response.productUpgradeList)
            product = createObject("roSGNode", "Product")
            product.json = item
            products.upgrades.push(product)
        next
        for each item in asArray(response.productDowngradeList)
            product = createObject("roSGNode", "Product")
            product.json = item
            products.downgrades.push(product)
        next
    end if
    return products
end function

function cbs_subscribe(productCode as string) as string
    if not isNullOrEmpty(productCode) then
        ' Do the channel store purchase first
        channelStore().clearOrder()
        channelStore().addToOrder(productCode)
        result = channelStore().doOrder()
        if isArray(result) and result.count() > 0 then
            m.upgradeTime = nowDate().asSeconds()
            transaction = result[0]
            return asString(transaction.PurchaseId)
        end if
    end if
    return ""
end function

function cbs_restoreAccount(transactionID as string, deviceID as string) as string
    if not isNullOrEmpty(transactionID) then
        url = m.apiBaseUrl + "v2.0/roku/device/restoration.json"
        
        postData = {}
        postData["transactionId"]   = transactionID
        postData["deviceId"]        = deviceID

        response = m.makeRequest(url, "POST", postData)
        if isAssociativeArray(response) and response.success = true then
            return response.activationCode
        end if
    end if
    return ""
end function

function cbs_createAccount(userData as object, transactionID as string, productCode as string, deviceID as string) as string
'    userData = {
'        FirstName:  ""
'        LastName:   ""
'        Email:      ""
'        Zip:        ""
'        Password:   ""
'        DOB:        ""
'        Gender:     ""
'    }

    if not isNullOrEmpty(transactionID) then
        url = m.apiBaseUrl + "v3.0/roku/useraccount/activate-registration.json"
        
        postData = {}
        postData["email"]           = userData.Email
        postData["password"]        = userData.Password
        postData["confirmPassword"] = userData.Password
        postData["firstName"]       = userData.FirstName
        postData["lastName"]        = userData.LastName
        postData["birthday"]        = userData.DOB
        postData["country"]         = "US"
        postData["gender"]          = uCase(asString(userData.Gender)).replace(" ", "_")
        postData["mpid"]            = 4812
        postData["zip"]             = userData.Zip
        postData["optIn"]           = 1
        postData["deviceId"]        = deviceID

        response = m.makeRequest(url, "POST", postData)
        if isAssociativeArray(response) and response.success = true then
            ' Get the entitlement           
            return m.getEntitlement(transactionID, productCode, deviceID)
        end if
    end if
    return ""
end function

function cbs_getEntitlement(transactionID as string, productCode as string, deviceID as string) as string
    url = m.apiBaseUrl + "v2.0/roku/entitlement/purchase.json"
    url = addQueryString(url, "transactionId", transactionID)
    url = addQueryString(url, "deviceId", deviceID)
    url = addQueryString(url, "newPackageCode", productCode)

    ' Attempt to get the entitlement up to three times
    for i = 1 to 3
        response = m.makeRequest(url, "GET")
        if isAssociativeArray(response) and response.success = true then
            return response.activationCode
        end if
        sleep(1000)
    next
    return ""
end function

function cbs_upgrade(transactionID as string) as boolean
    url = m.apiBaseUrl + "v2.0/roku/subscription/product/upgrade.json"
    url = addQueryString(url, "newTransactionId", transactionID)

    ' Attempt to complete the upgrade up to three times
    for i = 1 to 3
        response = m.makeRequest(url)
        if isAssociativeArray(response) and response.success = true then
            return (response.isRefundSuccess <> false)
        end if
        sleep(1000)
    next
    return false
end function

function cbs_downgrade(transactionID as string) as boolean
    return m.upgrade(transactionID)
end function

function cbs_checkEmailExists(email as string) as boolean
    if not isNullOrEmpty(email) then
        url = m.apiBaseUrl + "v3.0/useraccount/email/exists.json"
        url = addQueryString(url, "email", email)
        
        response = m.makeRequest(url, "GET")
        if isAssociativeArray(response) then
            return (response.success = true)
        end if
    end if
    return false
end function

function cbs_validateZipCode(zip as string) as boolean
    if not isNullOrEmpty(zip) then
        url = m.apiBaseUrl + "v2.0/zipcode/check.json"
        url = addQueryString(url, "zip", zip)
        url = addQueryString(url, "country", "US")
        
        response = m.makeRequest(url, "GET")
        if isAssociativeArray(response) then
            return (response.success = true)
        end if
    end if
    return false
end function

function cbs_isAuthenticated() as boolean
    cookies = m.cookies
    if not isNullOrEmpty(cookies) then
        return cookies.inStr("CBS_COM=") > -1
    end if
    return false
end function

function cbs_getUser() as object
    url = m.apiBaseUrl + "v3.0/roku/login/status.json"

    user = createObject("roSGNode", "User")
    result = m.makeRequest(url, "GET")
    if isAssociativeArray(result) and result.isLoggedIn = true then
        user.json = result
        user.eligibleProducts = m.getEligibility()
    end if
    m.setUser(user)
    return user
end function

function cbs_signIn(username as string, password as string, deviceID as string) as string
    url = m.apiBaseUrl + "v2.0/roku/auth/login.json"
    postData = {}
    postData["j_username"] = username
    postData["j_password"] = password
    postData["deviceId"] = deviceID

    result = m.makeRequest(url, "POST", postData)
    if isAssociativeArray(result) and result.success = true then
        return getCookiesForUrl(m.apiBaseUrl)
    end if
    return ""
end function

function cbs_setPin(pin as string, ratings = [] as object) as boolean
    url = m.apiBaseUrl + "v2.0/roku/usersettings/parental/control/pin.json"
    postData = {}
    postData["pin"] = pin
    postData["parentalControlLevel"] = ratings.join(",")

    result = m.makeRequest(url, "POST", postData)
    if isAssociativeArray(result) and result.success = true then
        return true
    end if
    return false
end function

function cbs_forgotPassword(email as string) as boolean
    url = m.apiBaseUrl + "v2.0/roku/auth/useraccount/password/reset/request.json"
    postData = {}
    postData["email"] = email

    result = m.makeRequest(url, "POST", postData)
    if isAssociativeArray(result) and result.success = true then
        return true
    end if
    return false
end function

function cbs_signOut(deviceID as string) as boolean
    url = m.apiBaseUrl + "v2.0/ott/devices/roku/auth/deactivate.json"
    postData = {}
    postData["deviceId"] = deviceID

    result = m.makeRequest(url, "POST", postData)
    m.cookies = ""
    return true
end function

function cbs_getActivationCode(deviceID as string) as object
    url = m.apiBaseUrl + "v2.0/ott/devices/roku/auth/code.xml"
    url = addQueryString(url, "deviceId", deviceID)
    url = addQueryString(url, "ipAddress", m.getIPAddress())
    url = addQueryString(url, "newCode", "true")
    
    result = m.makeRequest(url, "GET", invalid, "xml")
    if isAssociativeArray(result) then
        authCode = createObject("roSGNode", "AuthCode")
        authCode.json = result.result
        return authCode
    end if
    return invalid
end function

function cbs_checkActivationCode(code as string, deviceID as string) as string
    url = m.apiBaseUrl + "v2.0/ott/devices/roku/auth/status.xml"
    url = addQueryString(url, "deviceId", deviceID)
    url = addQueryString(url, "activationCode", code)
    
    result = m.makeRequest(url, "GET", invalid, "xml")
    if isAssociativeArray(result) and isAssociativeArray(result.result) then
        if result.result.status = "success" then
            return getCookiesForUrl(m.apiBaseUrl)
        end if
    end if
    return ""
end function

function cbs_getVideoSections(config as string, itemsPerRow = 50 as integer, platform = "roku" as string) as object
    sections = []
    
    url = m.apiBaseUrl + "v2.0/roku/shows/199951/videos/config/" + config + ".json"
    if not isNullOrEmpty(platform) then
        url = addQueryString(url, "platformType", platform)
    end if
    url = addQueryString(url, "rows", itemsPerRow)
    url = addQueryString(url, "excludeShow", true)
    
    response = m.makeRequest(url, "GET", invalid, "json", true)
    if isAssociativeArray(response) then
        if response.success = true and response.results <> invalid then
            for each item in response.results
                section = createObject("roSGNode", "Section")
                section.json = item
                sections.push(section)
            next
        else if response.errorCode <> invalid then
            return response
        end if
    end if
    return sections
end function

function cbs_getHomeRowsOld(itemsPerRow = 50 as integer) as object
    return m.getVideoSections("SHOW_HOME_ROKU_SVOD", itemsPerRow)
end function

function cbs_getHomeRows(itemsPerRow = 50 as integer) as object
    sections = []

    sections.append(m.getVideoSections("CBS_HOME_VIDEO", itemsPerRow, ""))
    
    url = m.apiBaseUrl + "v3.0/roku/homeshowgroup.json"
    url = addQueryString(url, "rows", itemsPerRow)
    
    response = m.makeRequest(url, "GET", invalid, "json", true)
    if isAssociativeArray(response) then
        if response.success = true and response.homeShowGroupSections <> invalid then
            for each item in response.homeShowGroupSections
                section = createObject("roSGNode", "HomeShowGroup")
                section.json = item
                sections.push(section)
            next
        else if response.errorCode <> invalid then
            return response
        end if
    end if

    sections.append(m.getVideoSections("CBS_HOME_VIDEO2", itemsPerRow, ""))

    return sections
end function

function cbs_getHomeShowGroupShows(sectionID as string, page = 0 as integer, pageSize = 100 as integer) as object
    shows = []
    url = m.apiBaseUrl + "v3.0/roku/homeshowgroup/" + sectionID + ".json"
    url = addQueryString(url, "start", page * pageSize)
    url = addQueryString(url, "rows", pageSize)

    response = m.makeRequest(url, "GET", invalid, "json", true)
    if isAssociativeArray(response) then
        if response.success = true and response.homeShowGroupSection <> invalid then
            for each item in response.homeShowGroupSection.shows
                show = createObject("roSGNode", "ShowGroupItem")
                show.json = item
                shows.push(show)
            next
        else if response.errorCode <> invalid then
            return response
        end if
    end if
    return shows
end function

function cbs_getAmlgVariantShows(variant = "showRecommendationTrending" as string, page = 0 as integer, pageSize = 100 as integer, skipIfSourceIsTrending = false as boolean) as object
    shows = []
    url = m.apiBaseUrl + "v2.0/roku/recommendation/amlg/shows/variant.json"
    url = addQueryString(url, "variant", variant)
    url = addQueryString(url, "start", page * pageSize)
    url = addQueryString(url, "rows", pageSize)

    response = m.makeRequest(url, "GET", invalid, "json", true)
    if isAssociativeArray(response) then
        if response.success = true and response.results <> invalid then
            for each item in response.results
                if not skipIfSourceIsTrending or item.amlgSource <> "trending" then
                    show = createObject("roSGNode", "Show")
                    show.json = item
                    shows.push(show)
                end if
            next
        else if response.errorCode <> invalid then
            return response
        end if
    end if
    return shows
end function

function cbs_getMovies(page = 0 as integer, pageSize = 100 as integer) as object
    movies = []
    url = m.apiBaseUrl + "v3.0/roku/movies.json"
    url = addQueryString(url, "includeContentInfo", true)
    url = addQueryString(url, "includeTrailerInfo", true)
    url = addQueryString(url, "start", page * pageSize)
    url = addQueryString(url, "rows", pageSize)
    response = m.makeRequest(url, "GET", invalid, "json", true)
    if isAssociativeArray(response) and response.success = true then
        for each item in asArray(response.movies)
            if item.movieContent <> invalid then
                movie = createObject("roSGNode", "Movie")
                movie.json = item.movieContent
                if item.trailerContent <> invalid then
                    trailer = createObject("roSGNode", "Trailer")
                    trailer.json = item.trailerContent
                    movie.trailer = trailer
                end if
                movies.push(movie)
            end if
        next
    end if
    return movies
end function

function cbs_getAllShows() as object
    shows = {}
    url = m.apiBaseUrl + "v2.0/roku/shows/groups.json"
    url = addQueryString(url, "includeAllShowGroups", true)
    response = m.makeRequest(url, "GET", invalid, "json", true)
    if isAssociativeArray(response) and response.success = true then
        for each item in asArray(response.all)
            show = createObject("roSGNode", "Show")
            show.json = item
            shows[show.id] = show
        next
    end if
    return shows
end function

function cbs_getShowGroups() as object
    groups = []
    url = m.apiBaseUrl + "v2.0/roku/shows/groups.json"
    response = m.makeRequest(url, "GET", invalid, "json", true)
    if isAssociativeArray(response) then
        if response.success = true then
            for each item in response.showGroups
                group = createObject("roSGNode", "ShowGroup")
                group.json = item
                groups.push(group)
            next
        else if response.errorCode <> invalid then
            return response
        end if
    end if
    return groups
end function

function cbs_getGroupShows(groupID as string) as object
    shows = []
    url = m.apiBaseUrl + "v2.0/roku/shows/group/" + groupID + ".json"
    response = m.makeRequest(url, "GET", invalid, "json", true)
    if isAssociativeArray(response) and response.success = true and isAssociativeArray(response.group) then
        for each item in response.group.showGroupItems
            show = createObject("roSGNode", "ShowGroupItem")
            show.json = item
            shows.push(show)
        next
    end if
    return shows
end function

function cbs_getShows(showIDs as object) as object
    shows = []
    url = m.apiBaseUrl + "v3.0/roku/shows/multiShow.json"
    url = addQueryString(url, "showIds", join(showIDs, ","))
    response = m.makeRequest(url, "GET", invalid, "json", true)
    if response <> invalid then
        for each id in showIDs
            if response[id] <> invalid then
                show = createObject("roSGNode", "Show")
                show.json = response[id]
                shows.push(show)
            end if
        next
    end if
    return shows
end function

function cbs_getRelatedShows(showID as string) as object
    shows = []
    url = m.apiBaseUrl + "v2.0/roku/shows/" + showID + "/related/shows.json"
    response = m.makeRequest(url, "GET", invalid, "json", true)
    if response <> invalid and response.relatedShows <> invalid then
        for each related in response.relatedShows
            show = createObject("roSGNode", "RelatedShow")
            show.json = related
            shows.push(show)
        next
    end if
    return shows
end function

function cbs_getShow(showID as string, loadRows = false as boolean) as object
    url = m.apiBaseUrl + "v2.0/roku/shows/" + showID + ".json"
    response = m.makeRequest(url, "GET", invalid, "json", true)
    if response <> invalid then
        if response.show <> invalid and response.errorCode = invalid then
            if response.show.results = invalid or response.show.results.count() > 0 then
                show = createObject("roSGNode", "Show")
                show.json = response
                if loadRows then
                    showSections = m.getShowSections(showID)
                    seasons = m.getShowAvailableSeasons(showID)
                    if seasons <> invalid then
                        ' Add the show for the show info row
                        sections = []
                        for each parentSection in showSections
                            if parentSection.displaySeasons = true then
                                sortedSeasons = []
                                sortedSeasons.append(seasons)
                                if parentSection.seasonSortOrder = "DESC" then
                                    sortArray(sortedSeasons, function(item1, item2) as boolean : return item1.number < item2.number : end function)
                                else if parentSection.seasonSortOrder = "ASC" then
                                    sortArray(sortedSeasons, function(item1, item2) as boolean : return item1.number > item2.number : end function)
                                end if
                                for each availableSeason in sortedSeasons
                                    if availableSeason.number <> 0 then
                                        section = createObject("roSGNode", "Section")
                                        section.json = parentSection.json
                                        section.showID = showID
                                        section.title = availableSeason.title
                                        section.excludeShow = false
                                        section.totalCount = availableSeason.totalCount
                                        params = {}
                                        params["params"] = "seasonNum=" + availableSeason.number.toStr()
                                        params["seasonNum"] = availableSeason.number
                                        section.params = params
                                        sections.push(section)
                                    end if
                                next
                            else
                                section = createObject("roSGNode", "Section")
                                section.json = parentSection.json
                                section.showID = showID
                                section.excludeShow = false
                                sections.push(section)
                            end if
                        next
                        show.sections = sections
                    else
                        return invalid
                    end if
                end if
                return show
            end if
        else if response.errorCode <> invalid then
            return response
        end if
    end if
    return invalid
end function

function cbs_getShowSections(showID as string) as object
    sections = []
    url = m.apiBaseUrl + "v2.0/roku/shows/" + showID + "/videos/config/DEFAULT_ROKU_SVOD.json"
    url = addQueryString(url, "platformType", "roku")
    url = addQueryString(url, "begin", 0)
    url = addQueryString(url, "rows", 1)
    
    response = m.makeRequest(url, "GET", invalid, "json", true)
    if isAssociativeArray(response) and response.success = true and response.results <> invalid then
        for each item in response.results
            if item.sectionItems <> invalid and item.sectionItems.itemCount > 0 then
                ' Remove the sectionItems, so we can populate the rows properly on the show screen
                item.sectionItems = invalid

                section = createObject("roSGNode", "Section")
                section.json = item
                sections.push(section)
            end if
        next
    end if
    return sections
end function

function cbs_getShowAvailableSeasons(showID as string) as object
    seasons = []
    url = m.apiBaseUrl + "v2.0/roku/shows/" + showID + "/video/season/availability.json"
    response = m.makeRequest(url, "GET", invalid, "json", true)
    if isAssociativeArray(response) and response.success = true then
        for each item in response.video_available_season.itemList
            season = createObject("roSGNode", "Season")
            season.json = item
            seasons.push(season)
        next
    else
        return invalid
    end if
    return seasons
end function

function cbs_getDynamicPlayEpisode(showID as string) as object
    episode = invalid
    dynamicPlay = createObject("roSGNode", "DynamicPlayEpisode")
    if m.user.status = "SUBSCRIBER" then
        url = m.apiBaseUrl + "v3.0/roku/dynamicplay/show/"+ showID +".json"
    else
        url = m.apiBaseUrl + "v3.0/roku/dynamicplay/show/"+ showID +"/nonsub.json"
    end if
    response = m.makeRequest(url, "GET")
    if response <> invalid and response.success = true then
         if response.dynamicVideoModel <> invalid then
            if response.dynamicVideoModel.model <> invalid then
                episode = createObject("roSGNode", "Episode")
                episode.json = response.dynamicVideoModel.model
                if response.dynamicVideoModel.medTime <> invalid then
                    episode.resumePoint = response.dynamicVideoModel.medTime
                end if
            end if 
         end if
         if episode <> invalid then
            dynamicPlay.title =  response.dynamicVideoModel.playbackModeCTA
            dynamicPlay.episode = episode
            return dynamicPlay
         end if 
    end if

    if episode <> invalid then
        dynamicPlay.episode = episode
        return dynamicPlay
    end if
    return invalid
end function

function cbs_getSectionVideos(sectionID as string, excludeShow as boolean, params as object, page as integer, pageSize as integer) as object
    videos = []
    url = m.apiBaseUrl + "v2.0/roku/videos/section/" + sectionID + ".json"
    url = addQueryString(url, "begin", page * pageSize)
    url = addQueryString(url, "rows", pageSize)
    if excludeShow then
        url = addQueryString(url, "excludeShow", true)
    end if
    if params <> invalid then
        for each param in params
            url = addQueryString(url, param, params[param])
        next
    end if
    response = m.makeRequest(url, "GET", invalid, "json", true)
    if isAssociativeArray(response) and response.success = true then
        for each item in response.sectionItems.itemList
            video = invalid
            if item.mediaType = "Movie" then
                video = createObject("roSGNode", "Movie")
            else
                if item.isLive = true then
                    video = createObject("roSGNode", "LiveFeed")
                else
                    video = createObject("roSGNode", "Episode")
                end if
            end if
            video.json = item
            videos.push(video)
        next
    end if
    return videos
end function

function cbs_getDmaFromZip(zipCode as string) as object
    url = m.apiBaseUrl + "v3.0/roku/dma/zipcode/" + zipCode + ".json"
    
    stations = []
    response = m.makeRequest(url, "GET")
    if isAssociativeArray(response) and response.success = true then
        markets = response.markets
        if markets = invalid then
            markets = response.market
        end if
        for each item in asArray(markets)
            station = createObject("roSGNode", "Station")
            station.json = item
            ' HACK: Trim the callsign to just the station letters (e.g. KBTX-DT-AA to KBTX)
            if station.title.inStr("-") > 0 then
                station.title = station.title.mid(0, station.title.inStr("-"))
            end if
            station.affiliate = m.getAffiliate(station.title)
            stations.push(station)
        next
    end if
    return stations
end function

function cbs_registerDmaOverride(zipCode = "" as string) as object
    url = m.apiBaseUrl + "v3.0/roku/dma/override/register.json"
    if not isNullOrEmpty(zipCode)
        url = addQueryString(url, "zipcode", zipCode)
    end if

    stations = []
    response = m.makeRequest(url, "POST") 'parseJson(readAsciiFile("pkg:/test/dmaOverrideNoZipError.json")) '
    if isAssociativeArray(response) and response.success = true then
        markets = response.markets
        if markets = invalid then
            markets = response.market
        end if
        for each item in asArray(markets)
            station = createObject("roSGNode", "Station")
            station.json = item
            ' HACK: Trim the callsign to just the station letters (e.g. KBTX-DT-AA to KBTX)
            if station.title.inStr("-") > 0 then
                station.title = station.title.mid(0, station.title.inStr("-"))
            end if
            station.affiliate = m.getAffiliate(station.title)
            stations.push(station)
        next
    end if
    return stations
end function

function cbs_getLiveTVOverrideCount() as object
    url = m.apiBaseUrl + "v3.0/roku/dma/override/count.json"
    return m.makeRequest(url, "GET")
end function

function cbs_getAffiliate(station as string) as object
    url = m.apiBaseUrl + "v2.0/cbs/affiliate/search.json"
    url = addQueryString(url, "affiliates", station)
    
    response = m.makeRequest(url, "GET")
    if isAssociativeArray(response) then
        for each item in asArray(response.affiliates)
            affiliate = createObject("roSGNode", "Affiliate")
            affiliate.json = item
            if affiliate.station = station then
                return affiliate
            end if
        next
    end if
    return invalid
end function

function cbs_getLiveChannels() as object
    url = m.apiBaseUrl + "v3.0/roku/multiChannel.json"
    
    channels = []
    response = m.makeRequest(url, "GET")
    if isAssociativeArray(response) and response.success = true then
        for each item in asArray(response.multiChannelGroups)
            channel = createObject("roSGNode", "LiveTVChannel")
            channel.json = item
            channels.push(channel)
        next
    end if
    return channels
end function

function cbs_getExperiments(experimentNames = [] as object) as object
    url = m.apiBaseUrl + "v3.0/roku/user/variants.json"
    url = addQueryString(url, "clientUserGuid", m.user.id)
    url = addQueryString(url, "variantTestName", asArray(experimentNames).join(","))

    experiments = createObject("roSGNode", "ContentNode")
    response = m.makeRequest(url, "POST")
    if isAssociativeArray(response) and response.success = true then
        for each item in asArray(response.experiments)
            experiment = experiments.createChild("Experiment")
            experiment.json = item
        next
    end if
    return experiments
end function

'function cbs_search(term as String, expandDetails = false as boolean, startIndex = 0 as integer, count = 100 as integer) as object
'    results = invalid
'    url = m.apiBaseUrl + "v3.0/roku/contentsearch/search.json"
'    url = addQueryString(url, "term", term)
'    url = addQueryString(url, "termStart", startIndex)
'    url = addQueryString(url, "termCount", count)
'    
'    response = m.makeRequest(url, "GET")
'    if isAssociativeArray(response) and response.success = true then
'        results = createObject("roSGNode", "SearchResults")
'        results.json = response
'    end if
'    return results
'end function

function cbs_search(term as String, expandDetails = false as boolean, startIndex = 0 as integer, count = 100 as integer) as object
    results = invalid
    'url = m.apiBaseUrl + "v2.0/roku/finder/v2/terms.json"
    url = m.apiBaseUrl + "v3.0/roku/contentsearch/search.json"
    url = addQueryString(url, "term", term)
    url = addQueryString(url, "termStart", startIndex)
    url = addQueryString(url, "termCount", count)
    
    response = m.makeRequest(url, "GET")
    if isAssociativeArray(response) and response.success = true then
        results = createObject("roSGNode", "SearchResults")
        results.json = response
    end if
    return results
end function

function cbs_getFavoriteShows() as object
    favorites = []
    url = m.apiBaseUrl + "roku/lists/favoriteshows/unique/favorite-shows.json"
    response = m.makeRequest(url, "GET")
    if isAssociativeArray(response) and response.success = true then
        if response.favshowlist <> invalid then
            for each item in response.favshowlist.showList
                favorite = createObject("roSGNode", "Favorite")
                favorite.json = item
                favorites.push(favorite)
            next
        end if
    end if
    return favorites
end function

function cbs_getShowHistory(relevanceOrder = "recency" as string, page = 1 as integer, count = 50 as integer) as object
    shows = []
    url = m.apiBaseUrl + "v2.0/roku/video/show/history.json"
    url = addQueryString(url, "sortFilter", "relevance")
    url = addQueryString(url, "relevanceOrder", relevanceOrder)
    url = addQueryString(url, "page", page)
    url = addQueryString(url, "rows", count)

    response = m.makeRequest(url, "GET")
    if isAssociativeArray(response) and response.success = true then
        if response.showHistory <> invalid then
            for each item in response.showHistory
                show = createObject("roSGNode", "Show")
                show.json = item
                shows.push(show)
            next
        end if
    end if
    return shows
end function


function cbs_addShowToFavorites(showID as string) as boolean
    url = m.apiBaseUrl + "roku/lists/favoriteshows/unique/favorite-shows/item/add.json"
    postData = {}
    postData["showId"] = showID

    response = m.makeRequest(url, "POST", postData)
    if isAssociativeArray(response) and response.success = true then
        return true
    end if
    return false
end function

function cbs_removeShowFromFavorites(showID as string) as boolean
    url = m.apiBaseUrl + "roku/lists/favoriteshows/unique/favorite-shows/item/delete.json"
    postData = {}
    postData["showId"] = showID

    response = m.makeRequest(url, "POST", postData)
    if isAssociativeArray(response) and response.success = true then
        return true
    end if
    return false
end function

function cbs_getVideoHistory(page = 1 as integer, count = 50 as integer) as object
    episodes = []
    url = m.apiBaseUrl + "v3.0/roku/video/streams/history.json"
    url = addQueryString(url, "page", page)
    url = addQueryString(url, "rows", count)
    
    response = m.makeRequest(url, "GET")
    if isAssociativeArray(response) and response.success = true then
        if response.history <> invalid then
            for each item in response.history
                if item.canModel <> invalid then
                    episode = invalid
                    if item.canModel.mediaType = "Movie" then
                        episode = createObject("roSGNode", "Movie")
                    else
                        episode = createObject("roSGNode", "Episode")
                    end if
                    episode.json = item.canModel
                    if item.medTime <> invalid then
                        episode.resumePoint = item.medtime
                    end if
                    if isAvailable(episode) then
                        episodes.push(episode)
                    end if
                end if
            next
        end if
    end if
    return episodes
end function

function cbs_getContinueWatching(page = 1 as integer, count = 20 as integer) as object
    episodes = []
    url = m.apiBaseUrl + "v3.0/roku/video/continuewatching/watch-history.json"
    url = addQueryString(url, "page", page)
    url = addQueryString(url, "rows", count)
    response = m.makeRequest(url, "GET")
    if isAssociativeArray(response) and response.success = true then
        if response.history <> invalid or response.continueWatching <> invalid then
            if response.history <> invalid then
                history = response.history
            else
                history = response.continueWatching
            end if
            for each item in history
                if item.canModel <> invalid then
                    episode = invalid
                    if item.canModel.mediaType = "Movie" then
                        episode = createObject("roSGNode", "Movie")
                    else
                        episode = createObject("roSGNode", "Episode")
                    end if
                    episode.json = item.canModel
                    if item.medTime <> invalid then
                        episode.resumePoint = item.medtime
                    end if
                    if isAvailable(episode) then
                        episodes.push(episode)
                    end if
                end if
            next
        end if
    end if
    return episodes
end function

function cbs_getResumePoint(contentID as String) as integer
    if m.isAuthenticated() then
        url = m.apiBaseUrl + "v3.0/roku/video/streams.json"
        url = addQueryString(url, "contentId", contentID)
        response = m.makeRequest(url, "GET")
        if isAssociativeArray(response) and response.success = true then
            return asInteger(response.mediaTime) - m.resumeOffset
        end if
    end if
    return 0
end function

function cbs_isOverStreamLimit() as boolean
    url = m.apiBaseUrl + "v3.0/roku/video/streams.json"
    
    response = m.makeRequest(url, "GET")
    if isAssociativeArray(response) and response.success = true then
        return asBoolean(response.overThreshold, false)
    end if
    return false
end function

function cbs_getVideoStreamUrl(id as string, baseUrl = m.selectorUrl as string) as string
    url = ""
    if not isNullOrEmpty(id) then
        url = baseUrl.replace("[PID]", id)
        url = url.replace("[SIGNATURE]", m.getVideoStreamToken(id))
        
        checkHeaders = true
        if baseUrl = m.dashSelectorUrl then
            smilUrl = addQueryString(url, "format", "SMIL")
            smilXml = getUrlToXml(smilUrl)
            if smilXml <> invalid then
                smilJson = parseXmlAsJson(smilXml, true, "")
                if smilJson <> invalid and smilJson.smil <> invalid then
                    smil = smilJson.smil
                    if smil.body <> invalid and smil.body.seq <> invalid then
                        params = []
                        if smil.body.seq.video <> invalid then
                            if isArray(smil.body.seq.video) then
                                smilVideo = smil.body.seq.video[0]
                            else
                                smilVideo = smil.body.seq.video
                            end if
                            src = smilVideo.src
                            if not isNullOrEmpty(src) then
                                url = src
                                checkHeaders = false
                            end if
                            
                            params = asArray(smilVideo.param)
                        else if smil.body.seq.ref <> invalid then
                            params = asArray(smil.body.seq.ref.param)
                        end if
                        for each param in params
                            if param.name = "exception" and param.value = "AnonymousProxyBlocked" then
                                url = constants().errorProxy
                                checkHeaders = false
                                exit for
                            end if
                        next
                    end if
                end if
            end if
        end if

        if checkHeaders then
            ' Retrieve the redirect url from the Location header, if present
            headers = getUrlHeaders(url)
            if headers <> invalid and not isNullOrEmpty(headers.location) then
                url = headers.location
            end if
        end if
    end if
    return url
end function

function cbs_getPlayReadyInfo(id as string) as object
    playReady = invalid
    
    if m.user.status = "ANONYMOUS" then
        url = m.apiBaseUrl + "v3.0/roku/irdeto/anonymousSession.json"
    else
        url = m.apiBaseUrl + "v3.0/roku/irdeto/session.json"
    end if
    url = addQueryString(url, "contentId", id)
    response = m.makeRequest(url, "GET")
    if isAssociativeArray(response) and response.success = true then
        playReady = createObject("roSGNode", "DrmSession")
        playReady.json = response
    end if
    return playReady
end function

function cbs_getVideoStreamToken(id as string) as string
    url = m.apiBaseUrl + "v3.0/roku/video/signature/individualize.json"
    response = m.makeRequest(url, "POST")
    if isAssociativeArray(response) and response.success = true then
        iv = response.iv
        key = response.key
        token = response.cbsToken
        
        postData = {}
        postData["cbsToken"] = token
        postData["pids"] = m.accountPid + "/" + id
        url = m.apiBaseUrl + "v3.0/roku/video/signature/generate.json"
        response = m.makeRequest(url, "POST", postData)
        if isAssociativeArray(response) and response.success = true then
            keyBytes = createObject("roByteArray")
            keyBytes.fromAsciiString(key)
            ivBytes = createObject("roByteArray")
            ivBytes.fromAsciiString(iv)
            encBytes = createObject("roByteArray")
            encBytes.fromBase64String(response.token)
            
            cipher = createObject("roEVPCipher")
            if cipher.setup(false, "aes-128-cbc", keyBytes.toHexString(), ivBytes.toHexString(), 1) = 0 then
                decrypted = cipher.process(encBytes)
                return decrypted.toAsciiString()
            end if
        end if
    end if
    return ""
end function

function cbs_getVilynxHash(owner as string, urlArray as Object) as object
    if owner <> invalid and urlArray <> invalid then
        headers={}
        finalURL = "http://www.vilynx.com/get_hashes.php/?owner=" + owner + "&url="
        for each thisURL in urlArray
            finalURL += thisURL + ","
        end for
        rsp = getUrlToJsonEx(finalURL, 60)
        if rsp.json <> invalid then
            hashesArray = rsp.json.hashes
            vilynxVideos = []
            vilynxRoot = "https://public.vilynx.com/"
            if hashesArray <> invalid or hashesArray <> "" then
                for each hash in hashesArray
                    vilynxItem = createObject("roSGNode","VilynxContentNode")
                    vilynxItem.vilynxThumbnail = vilynxRoot + hash.hash[0] + "/pro69high.viwindow0.jpg"
                    vilynxItem.vilynxUrlHigh = vilynxRoot + hash.hash[0] + "/pro69high.viwindow.mp4"
                    vilynxItem.vilynxUrl = vilynxRoot + hash.hash[0] + "/pro69.viwindow.mp4"
                    vilynxVideos.push(vilynxItem)
                end for
                return vilynxVideos
            end if
        end if      
  end if
  return invalid
end function


function cbs_generateAccessToken(secret as string) as string
    key = "302a6a0d70a7e9b967f91d39fef3e387816e3095925ae4537bce96063311f9c5"
    
    ' Generate a random IV
    ivLength = 16
    iv = getRandomHexString(ivLength * 2)
    
    ' Generate the unique token
    nonce = createObject("roDateTime").asSeconds().toStr()
    token = nonce + "|" + secret
    
    ' Encrypt the token
    cipherText = hexEncrypt("AES-256-CBC", key, iv, token)
    
    ' Build the access token string
    ' IV Length + IV + Encrypted Token
    output = intToHex(ivLength) + iv + cipherText

    ' Base64 encode the access token
    return hexToBase64(output)
end function

function cbs_makeRequest(url as string, method = "POST" as string, postData = invalid as object, format = "json" as string, useCache = false as boolean, responseHeaders = {} as object) As dynamic
    requestID = invalid
    query = ""
    ' Build the post data querystring
    if postData <> invalid then
        for each key In postData
            query = addQueryString(query, key, postData[key])
        next
    end if
    ' Trim off the leading question mark
    if not isNullOrEmpty(query) and query.Mid(0, 1) = "?" then
        query = query.Mid(1)
    end if

    preTokenUrl = url
    url = addQueryString(url, "at", m.generateAccessToken(m.apiKey))
    
'   Uncomment this only for debug channels only 
'    url = addQueryString(url,"LOCATEMEIN","CA")

    debugPrint(postData, "cbs.makeRequest (" + url + ")", 1)
    
    headers = {}
    if not isNullOrEmpty(m.cookies) then
        headers["Cookie"] = m.cookies
    end if

    cacheFilename = "tmp:/" + md5Hash(preTokenUrl + ":" + formatJson(postData)) + ".cache"
    response = invalid
    if useCache then
        if fileExists(cacheFilename) then
            response = readAsciiFile(cacheFilename)
        end if
    end if
    if isNullOrEmpty(response) then
        if method = "POST" then
            response = postUrlToStringEx(url, query, 60, headers)
        else
            response = getUrlToStringEx(url, 60, headers)
        end if
        if response <> invalid and response.responseCode = 200 then
            responseHeaders.append(response.responseHeaders)

            response = response.response
            if format = "json" then
                ' Convert the tracking IDs and dates from longs to strings to avoid json parsing errors
                response = regexReplace(response, "(" + chr(34) + "__FOR_TRACKING_ONLY_MEDIA_ID" + chr(34) + ":|" + chr(34) + "live_date" + chr(34) + ":|" + chr(34) + "expires_on" + chr(34) + ":|" + chr(34) + "created_date" + chr(34) + ":)\s?(\d*)(\W)", "\1" + chr(34) + "\2" + chr(34) + "\3")
            end if
            if useCache then
                writeAsciiFile(cacheFilename, response)
            end if
        else if response.responseCode \ 100 = 5 then
            ' 500 Response, report api down error
            response = "{""errorCode"":" + response.responseCode.toStr() + "}"
        else if response <> invalid then
            response = response.response
        end if
    end if

    if response <> invalid then
        json = ""
        if format = "xml" then
            json = parseXmlAsJson(response)
        else
            json = parseJson(response)
        end if
        return json
    end if
    return invalid
end function