function syncbak() as object
    if m.syncbak = invalid then
        m.syncbak = newSyncbak()
    end if
    return m.syncbak
end function

function newSyncbak() as object
    this                    = {}
    this.className          = "syncbak"
    
    this.initialize         = syncbak_initialize
    
    this.getChannels        = syncbak_getChannels
    this.getSchedule        = syncbak_getSchedule
    this.getStream          = syncbak_getStream
    
    this.getDeviceData      = syncbak_getDeviceData
    this.makeRequest        = syncbak_makeRequest
    
    setLogLevel(1)
    
    return this
end function

Sub syncbak_initialize(apiKey as string, apiSecret as string, baseUrl as string)
    m.apiKey = apiKey
    m.apiSecret = apiSecret
    m.baseUrl = baseUrl
end Sub

function syncbak_getChannels() as object
    channels = []
    response = m.makeRequest("/v3/channels")
    if response <> invalid then
        for each item in asArray(response.channels)
            station = createObject("roSGNode", "Station")
            station.json = item
            station.affiliate = cbs().getAffiliate(station.title)
            channels.push(station)
        next
    end if
    return channels
end function

function syncbak_getSchedule(scheduleUrl as string) as object
    setLogLevel(1)
    response = getUrlToJson(scheduleUrl)
    return parseScheduleJson(response)
end function

function syncbak_getStream(stationID as string, mediaID as string, typeID = -1 as integer) as object
    params = {}
    params["stationId"] = stationID
    params["mediaId"] = mediaID
    if typeID > -1 then
        params["typeId"] = typeID
    end if
    response = m.makeRequest("/v3/streams", params)
    if response <> invalid then
        for each item in asArray(response.streams)
            if item.typeId = 1 then ' 1 = HLS
                stream = createObject("roSGNode", "LiveTVStream")
                stream.streamFormat = "hls"
                stream.switchingStrategy = "full-adaptation"
                stream.live = true

                stream.subtitleConfig = { trackName: "eia608/1" }
                stream.url = item.url
                stream.forwardQueryStringParams = false


                hackModels = ["24", "25", "27", "30", "31", "34", "35", "37", "39"]
                model = getModel().mid(0, 2)
                if arrayContains(hackModels, model) then
                    ' HACK: increased segment count for devices affected by 8.1 playlist issue
                    '       https -> http to reduce handshake delay
                    '       bitrate cap to reduce decoding time
                    stream.playStart = 0
                    stream.url = stream.url.replace("https://", "http://")
                    stream.maxBandwidth = 4000
                else
                    stream.playStart = createObject("roDateTime").asSeconds() + 999999
                end if

                return stream
            end if
        next
    end if
    return invalid
end function

function syncbak_getDeviceData() as object
    if m.deviceData = invalid then
        deviceData = {}
        deviceData["deviceId"] = getPersistedDeviceID()
        deviceData["deviceType"] = 8
        'deviceData["ip"] = Cbs().GetIPAddress() ' 
        'deviceData["ip"] = "65.111.124.2" '"67.221.255.55" '""67.221.255.55" ' "170.20.96.14" '
        deviceData["locationAccuracy"] = 5
        deviceData["locationAge"] = 0
        deviceData["MVPDId"] = "AllAccess"

        m.deviceData = base64Encode(formatJson(deviceData))
    end if
    return m.deviceData
end function

function syncbak_makeRequest(path as string, params = invalid as object, retryCount = 0 as integer) as object
    if isAssociativeArray(params) then
        for each param in params
            path = addQueryString(path, param, params[param])
        next
    end if
    url = m.baseUrl + path
    
    expiryDate = createObject("roDateTime").asSeconds() + 14400  ' 2 hours
    
    signatureData = asString(expiryDate) + m.getDeviceData() + path
    signature = hmacSignature(signatureData, m.apiSecret, "sha1", "hexLower")
    
    headers = {}
    headers["api-key"] = m.apiKey
    headers["req-expires"] = asString(expiryDate)
    headers["signature"] = signature
    headers["device-data"] = m.getDeviceData()

    response = getUrlToStringEx(url, 30, headers)

    if response <> invalid then
        if response.responseCode = 200 then
            return ParseJson(response.response)
        else if response.responseCode = 503 then ' Too busy
            if retryCount = 0 then
                sleep(2500)
            else if retryCount = 1 then
                sleep(5000)
            else
                sleep(10000)
            end if
            return m.makeRequest(path, params, retryCount + 1)
        end if
    end if
    
    return invalid
end function