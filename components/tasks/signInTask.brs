sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    config = m.global.config
    
    api = cbs()
    api.initialize(config)
    api.clearCache()
    
    authCode = ""
    username = m.top.username
    password = m.top.password
    if isNullOrEmpty(username) and isNullOrEmpty(password) then
        authCode = getRegistryValue("AuthToken", m.top.authToken, api.registrySection)
        username = getRegistryValue("Username", m.top.username, api.registrySection)
        password = getRegistryValue("Password", m.top.password, api.registrySection)
    end if
    if isNullOrEmpty(authCode) and (isNullOrEmpty(username) or isNullOrEmpty(password)) then
        purchases = channelStore().getPurchases()
        if purchases <> invalid and purchases.count() > 0 then
            transactionID = purchases[0].purchaseId
            if not isNullOrEmpty(transactionID) then
                authCode = api.restoreAccount(transactionID)
            end if
        end if
    end if
    
    cookies = ""
    if not isNullOrEmpty(authCode) then
        cookies = api.checkActivationCode(authCode)
    else if not isNullOrEmpty(username) and not isNullOrEmpty(password) then
        cookies = api.signIn(username, password)
    end if
    if not isNullOrEmpty(cookies) then
        ' Save the auth info, in case it's new
        setRegistryValue("AuthToken", authCode, api.registrySection)
        setRegistryValue("Username", username, api.registrySection)
        setRegistryValue("Password", password, api.registrySection)

        m.global.cookies = cookies
        api.setCookies(cookies)
    end if

    stations = []
    if asBoolean(config.syncbak_enabled, true) then
        syncbak().initialize(config.syncbakKey, config.syncbakSecret, config.syncbakBaseUrl)
        stations = syncbak().getChannels()
    else
        nationalFeedID = config.live_tv_national_feed_content_id
        if not isNullOrEmpty(nationalFeedID) then
            nationalFeed = api.getEpisode(nationalFeedID)
            if nationalFeed <> invalid then
                stations.push(nationalFeed)
            end if
        end if
    end if
    channels =  invalid
    if config.liveTVChannels <> invalid then
        channels = createObject("roSGNode", "ContentNode")
        for each item in config.liveTVChannels
            channel = channels.createChild("LiveTVChannel")
            channel.id = item.id
            channel.hdPosterUrl = item.icon
            channel.scheduleUrl = item.scheduleUrl
            channel.streamUrl = item.streamUrl
            channel.title = item.title
            channel.trackingID = item.trackingID
            channel.trackingAstID = item.trackingAstID
            channel.trackingContentID = item.trackingContentID
            channel.trackingTitle = item.trackingTitle
            channel.omnitureTrackingTitle = item.trackingTitle
            channel.convivaTrackingTitle = item.title
            channel.comscoreC2 = item.comscoreC2
            channel.comscoreC3 = item.comscoreC3
            channel.comscoreC4 = item.comscoreC4
        next
    end if
    m.global.liveTVChannels = channels

    m.global.stations = stations
    m.global.station = getRegistryValue("liveTV", "", api.registrySection)

    shows = api.getGroupShows(config.allShowsGroupID)
    showCache = {}
    for each show in shows
        showCache[show.id] = show
    next
    m.global.shows = shows
    m.global.showCache = showCache
    m.global.user = api.getUser()

    m.top.signedIn = (m.global.user.status <> "ANONYMOUS")
end sub
