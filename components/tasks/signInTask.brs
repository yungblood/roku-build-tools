sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    config = getGlobalField("config")

    deviceID = ""
    legacyDeviceID = ""
    persistedDeviceID = getRegistryValue("persistedDeviceID", "", constants().registrySection)
    if isNullOrEmpty(persistedDeviceID) then
        deviceInfo = createObject("roDeviceInfo")
        legacyDeviceID = deviceInfo.getDeviceUniqueID()
        if legacyDeviceID.mid(0, 1) = "0" then
            legacyDeviceID = ""
        end if
        deviceID = deviceInfo.getChannelClientID()
    end if

    api = cbs()
    api.initialize(m.top)
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
                if not isNullOrEmpty(legacyDeviceID) then
                    authCode = api.restoreAccount(transactionID, legacyDeviceID)
                end if
                if isNullOrEmpty(authCode) then
                    authCode = api.restoreAccount(transactionID, deviceID)
                    if not isNullOrEmpty(authCode) then
                        persistedDeviceID = deviceID
                    end if
                else
                    persistedDeviceID = legacyDeviceID
                end if
            end if
        end if
    end if
    
    cookies = ""
    if not isNullOrEmpty(authCode) then
        if not isNullOrEmpty(persistedDeviceID) then
            cookies = api.checkActivationCode(authCode, persistedDeviceID)
        else
            if not isNullOrEmpty(legacyDeviceID) then
                cookies = api.checkActivationCode(authCode, legacyDeviceID)
            end if
            if isNullOrEmpty(cookies) then
                cookies = api.checkActivationCode(authCode, deviceID)
                persistedDeviceID = deviceID
            else
                persistedDeviceID = legacyDeviceID
            end if
        end if
    else if not isNullOrEmpty(username) and not isNullOrEmpty(password) then
        if not isNullOrEmpty(persistedDeviceID) then
            cookies = api.signIn(username, password, persistedDeviceID)
        else
            if not isNullOrEmpty(legacyDeviceID) then
                cookies = api.signIn(username, password, legacyDeviceID)
            end if
            if isNullOrEmpty(cookies) then
                cookies = api.signIn(username, password, deviceID)
                persistedDeviceID = deviceID
            else
                persistedDeviceID = legacyDeviceID
            end if
        end if
    end if
    if isNullOrEmpty(persistedDeviceID) then
        persistedDeviceID = deviceID
    end if
    setRegistryValue("persistedDeviceID", persistedDeviceID, constants().registrySection)
    setGlobalField("deviceID", persistedDeviceID)

    if not isNullOrEmpty(cookies) then
        ' Save the auth info, in case it's new
        setRegistryValue("AuthToken", authCode, api.registrySection)
        setRegistryValue("Username", username, api.registrySection)
        setRegistryValue("Password", password, api.registrySection)

        m.top.cookies = cookies
        api.setCookies(cookies)
    end if

'    stations = []
'    if asBoolean(config.syncbak_enabled, true) then
'        syncbak().initialize(config.syncbakKey, config.syncbakSecret, config.syncbakBaseUrl)
'        stations = syncbak().getChannels()
'    else
'        nationalFeedID = config.live_tv_national_feed_content_id
'        if not isNullOrEmpty(nationalFeedID) then
'            nationalFeed = api.getEpisode(nationalFeedID)
'            if nationalFeed <> invalid then
'                stations.push(nationalFeed)
'            end if
'        end if
'    end if
'
'    liveTVChannels = api.getLiveChannels()
'    if config.liveTVChannels <> invalid then
'        for each channel in liveTVChannels
'            for each override in config.liveTVChannels
'                if override.id = channel.scheduleType then
'                    for each field in override.keys()
'                        if field <> "id" then
'                            channel.setField(field, override[field])
'                        end if
'                    next
'                    exit for
'                end if
'            next
'        next
'    end if
'    channels = createObject("roSGNode", "ContentNode")
'    channels.appendChildren(liveTVChannels)
'    setGlobalField("liveTVChannels", channels)
'
'    setGlobalField("stations", stations)
    m.top.localStation = getRegistryValue("liveTV", "", api.registrySection)
    m.top.localStationLatitude = getRegistryValue("liveTVLatitude", 0.0, api.registrySection)
    m.top.localStationLongitude = getRegistryValue("liveTVLongitude", 0.0, api.registrySection)
    m.top.lastLiveChannel = getRegistryValue("liveTVChannel", "", api.registrySection)
    
    user = api.getUser(true)
    m.top.user = user

    m.top.signedIn = (user.status <> "ANONYMOUS")
end sub