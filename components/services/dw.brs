function dw() as object
    if m.dw = invalid then
        m.dw = newDW()
    end if
    return m.dw
end function

function newDW() as object
    this                        = {}
    this.className              = "DW"

    this.requests               = []

    this.debug                  = false
    
    this.baseUrl                = "http://dw.cbsi.com/levt/video/e.gif"
    this.baseBeaconUrl          = "http://dw.cbsi.com/levt/beacon/e.gif"
    this.playerID               = ""
    this.userID                 = ""
    this.userStatus             = ""
    this.contSessID             = ""
    this.lastTimestamp          = 0
    
    this.setUserInfo            = dw_setUserInfo

    this.getUserData            = dw_getUserData
    this.getBasePlayerData      = dw_getBasePlayerData
    this.getPlayerData          = dw_getPlayerData
    this.getPlayerLiveData      = dw_getPlayerLiveData
    this.getPlayerAdData        = dw_getPlayerAdData
    
    this.playerInit             = dw_playerInit
    this.playerStart            = dw_playerStart
    this.playerLiveStart        = dw_playerLiveStart
    this.playerAdStart          = dw_playerAdStart
    this.playerEnd              = dw_playerEnd
    this.playerLiveEnd          = dw_playerLiveEnd
    this.playerLiveForcedEnd    = dw_playerLiveForcedEnd
    this.playerAdEnd            = dw_playerAdEnd
    this.playerPlay             = dw_playerPlay
    this.playerLivePlay         = dw_playerLivePlay
    this.playerAdPlay           = dw_playerAdPlay
    this.playerStop             = dw_playerStop
    this.playerLiveStop         = dw_playerLiveStop
    this.playerPause            = dw_playerPause
    this.playerUnpause          = dw_playerUnpause
    this.playerRewind           = dw_playerRewind
    this.playerForward          = dw_playerForward
    this.playerError            = dw_playerError
    this.playerLiveError        = dw_playerLiveError
    
    this.playerPlayPosition     = dw_playerPlayPosition
    this.playerLivePlayPosition = dw_playerLivePlayPosition
    
    this.processRequests        = dw_processRequests
    this.sendRequest            = dw_sendRequest
    
    return this
end function

sub dw_setUserInfo(userID as string, userStatus as string)
    m.userID = userID
    m.userStatus = userStatus
end sub

function dw_getUserData() as object
    data = {}
    data["ursuid"] = m.userID
    data["v25"] = m.userStatus
    'data["v26"] = m.user.Packages
    
    return data
end function

function dw_getBasePlayerData(event as string) as object
    data = {}
    data["event"] = event
    data["siteid"] = 1054
    data["v21"] = "set top box"
    data["v23"] = "cbsicbsott"
    data["componentid"] = m.playerID
    data["distntwrk"] = "can"
    data["mapp"] = "CBS_Roku;ROKU;" + getAppVersion()
    data["part"] = "cbs_roku_app"
    data["device"] = "type:settop;os:roku;ver:" + GetFirmware().FullVersion + ";cpu:" + LCase(GetCpuType()) + ";screensz:" + GetDisplayResolution()
    if not isNullOrEmpty(m.contSessID) then
        data["contsessid"] = m.contSessID
    end if
    if not isNullOrEmpty(m.vguid) then
        data["v16"] = m.vguid
    end if
    
    return data
end function

function dw_getPlayerData(event as string, episode as object, playerTime as integer, mediaTime as integer, videoIndex = 1 as integer) as object
    data = m.getBasePlayerData(event)
    data["playertime"] = playerTime
    data["medtitle"] = episode.trackingTitle
    data["medastid"] = 595
    data["medid"] = episode.mediaID
    data["v22"] = episode.id
    data["medlength"] = episode.length
    data["medtime"] = mediaTime
    data["mednum"] = videoIndex
    data["sdlvrytype"] = 1

    ' append the user data
    data.append(m.getUserData())
    
    return data
end function

function dw_getPlayerLiveData(event as string, channel as object, playerTime as integer, mediaTime as integer, videoIndex = 1 as integer) as object
    data = m.getBasePlayerData(event)
    data["playertime"] = playerTime
    data["medtitle"] = channel.trackingTitle
    data["medastid"] = channel.trackingAstID '600
    data["medid"] = channel.trackingID ' 2344

    if channel.subtype() = "LiveFeed" or channel.subtype() = "LiveTVChannel" then
        ' We only send v22 on live feeds, not syncbak streams
        data["v22"] = asString(channel.trackingContentID)
    end if

    data["medlength"] = 0
    data["medtime"] = mediaTime
    data["mednum"] = videoIndex
    if channel.subtype() = "LiveTVChannel" then
        data["sdlvrytype"] = 6
    else
        data["sdlvrytype"] = 2
    end if

    ' append the user data
    data.append(m.getUserData())

    return data
end function

function dw_getPlayerAdData(ad as object, adPosition as integer, podNumber as integer, podIndex as integer, adNumber as integer, episode as object, mediaTime as integer) as object
    data = {}
    data["adastid"] = 42
    'data["adbreak"] = ""
    data["adid"] = ad.creativeID
    if isNullOrEmpty(data["adid"]) then
        data["adid"] = "999"
    end if
    data["adlength"] = ad.Length
    data["adnum"] = adNumber
    data["adpod"] = podNumber
    data["adpodpos"] = podIndex
    data["adpos"] = iif(mediaTime = 0, "pre", iif(mediaTime < asInteger(episode.Length), "mid", "post"))
    data["adtime"] = adPosition
    data["adtitle"] = ad.Title
    data["adtype"] = 1
    
    return data
end function

sub dw_playerInit(generateNewPlayerID = true as boolean, vguid = "" as string)
    if isNullOrEmpty(m.playerID) or generateNewPlayerID then
        m.playerID = md5Hash(getPersistedDeviceID() + nowDate().asSeconds().toStr())
        m.contsessID = ""
    else
        m.contSessID = m.playerID
    end if
    m.vguid = vguid
    
    data = m.getBasePlayerData("init")
    data["playertime"] = 0

    ' append the user data
    data.append(m.getUserData())
    
    m.sendRequest(data)
end sub

sub dw_playerStart(episode as object, playerTime as integer, videoIndex = 1 as integer, gestVal = "" as string)
    data = m.getPlayerData("start", episode, playerTime, 0, videoIndex)
    if isNullOrEmpty(gestVal) then
        if episode.subscriptionLevel = "FREE" then
            data["gestval"] = "paywall:0"
        else
            data["gestval"] = "paywall:1"
        end if
    else
        data["gestval"] = gestVal
    end if
    m.sendRequest(data)
end sub

sub dw_playerLiveStart(channel as object, playerTime as integer, videoIndex = 1 as integer)
    data = m.getPlayerLiveData("start", channel, playerTime, 0, videoIndex)
    data["gestval"] = "paywall:1"
    m.sendRequest(data)
end sub

sub dw_playerAdStart(ad as object, podNumber as integer, podIndex as integer, adNumber as integer, episode as object, playerTime as integer, mediaTime as integer, videoIndex = 1 as integer)
    data = m.getPlayerData("start", episode, playerTime, mediaTime, videoIndex)
    if episode.subscriptionLevel = "FREE" then
        data["gestval"] = "paywall:0"
    else
        data["gestval"] = "paywall:1"
    end if
    
    data.append(m.getPlayerAdData(ad, 0, podNumber, podIndex, adNumber, episode, mediaTime))
    
    m.sendRequest(data)
end sub

sub dw_playerEnd(episode as object, playerTime as integer, mediaTime as integer, videoIndex = 1 as integer)
    data = m.getPlayerData("end", episode, playerTime, mediaTime, videoIndex)
    m.sendRequest(data)
end sub

sub dw_playerLiveEnd(channel as object, playerTime as integer, mediaTime as integer, videoIndex = 1 as integer)
    data = m.getPlayerLiveData("end", channel, playerTime, mediaTime, videoIndex)
    m.sendRequest(data)
end sub

sub dw_playerLiveForcedEnd(action as string, channel as object, playerTime as integer, mediaTime as integer, videoIndex = 1 as integer)
    data = m.getPlayerLiveData("forced_end", channel, playerTime, mediaTime, videoIndex)
    data["gestval"] = "action:" + action
    m.sendRequest(data)
end sub

sub dw_playerAdEnd(ad as object, adPosition as integer, podNumber as integer, podIndex as integer, adNumber as integer, episode as object, playerTime as integer, mediaTime as integer, videoIndex = 1 as integer)
    data = m.getPlayerData("end", episode, playerTime, mediaTime, videoIndex)
    data.append(m.getPlayerAdData(ad, adPosition, podNumber, podIndex, adNumber, episode, mediaTime))
    m.sendRequest(data)
end sub

sub dw_playerPlay(episode as object, playerTime as integer, mediaTime as integer, videoIndex = 1 as integer)
    track = false
    gestVal = ""
    if mediaTime > 0 and mediaTime <= 60 then
        ' for 0-60, track every 15 seconds
        track = (mediaTime mod 15 = 0)
    else if mediaTime > 60 then
        ' for 61+, track every minute and at 10% increments
        track = (mediaTime mod 60 = 0)
        if Not track then
            interval = int(episode.length / 10)
            if interval = 0 then
                interval = int(episode.length / 4)
            end if
            track = (interval = 0) or (mediaTime mod interval = 0)
        end if
    end if
    quartile = int(episode.length / 4)
    if quartile > 0 and mediaTime > 0 and mediaTime mod quartile = 0 then
        track = true
        if mediaTime = quartile then
            gestVal = "pct:25"
        else if mediaTime = quartile * 2 then
            gestVal = "pct:50"
        else if mediaTime = quartile * 3 then
            gestVal = "pct:70"
        end if
    end if
    if track then
        data = m.getPlayerData("play", episode, playerTime, mediaTime, videoIndex)
        if Not isNullOrEmpty(gestVal) then
            data["gestval"] = gestVal
        end if
        m.sendRequest(data)
    end if
end sub

sub dw_playerAdPlay(ad as object, adPosition as integer, podNumber as integer, podIndex as integer, adNumber as integer, episode as object, playerTime as integer, mediaTime as integer, videoIndex = 1 as integer)
    interval = int(ad.Length / 10)
    if interval = 0 then
        interval = int(ad.Length / 4)
    end if
    track = (interval = 0) or (adPosition mod interval = 0)
    if track then
        data = m.getPlayerData("play", episode, playerTime + adPosition, mediaTime, videoIndex)
        data.append(m.getPlayerAdData(ad, adPosition, podNumber, podIndex, adNumber, episode, mediaTime))
        
        m.sendRequest(data)
    end if
end sub

sub dw_playerLivePlay(channel as object, playerTime as integer, mediaTime as integer, videoIndex = 1 as integer)
    track = false
    if mediaTime > 0 and mediaTime <= 60 then
        ' for 0-60, track every 5 seconds
        track = (mediaTime mod 5 = 0)
    else if mediaTime > 60 then
        ' for 61+, track every minute and at 10% increments
        track = (mediaTime mod 60 = 0)
    end if
    if track then
        data = m.getPlayerLiveData("play", channel, playerTime, mediaTime, videoIndex)
        m.sendRequest(data)
    end if
end sub

sub dw_playerStop(episode as object, playerTime as integer, mediaTime as integer, videoIndex = 1 as integer)
    data = m.getPlayerData("stop", episode, playerTime, mediaTime, videoIndex)
    m.sendRequest(data)
end sub

sub dw_playerLiveStop(channel as object, playerTime as integer, mediaTime as integer, videoIndex = 1 as integer)
    data = m.getPlayerLiveData("stop", channel, playerTime, mediaTime, videoIndex)
    m.sendRequest(data)
end sub

sub dw_playerPause(episode as object, playerTime as integer, mediaTime as integer, videoIndex = 1 as integer)
    data = m.getPlayerData("pause", episode, playerTime, mediaTime, videoIndex)
    data["gestval"] = "action:pause_button"
    m.sendRequest(data)
end sub

sub dw_playerUnpause(pauseTime as integer, episode as object, playerTime as integer, mediaTime as integer, videoIndex = 1 as integer)
    data = m.getPlayerData("unpause", episode, playerTime, mediaTime, videoIndex)
    data["eventdur"] = pauseTime
    m.sendRequest(data)
end sub

sub dw_playerRewind(duration as integer, episode as object, playerTime as integer, mediaTime as integer, videoIndex = 1 as integer)
    data = m.getPlayerData("rewind", episode, playerTime, mediaTime, videoIndex)
    data["eventdur"] = duration
    m.sendRequest(data)
end sub

sub dw_playerForward(duration as integer, episode as object, playerTime as integer, mediaTime as integer, videoIndex = 1 as integer)
    data = m.getPlayerData("forward", episode, playerTime, mediaTime, videoIndex)
    data["eventdur"] = duration
    m.sendRequest(data)
end sub

sub dw_playerError(message as string, episode as object, playerTime as integer, mediaTime as integer, videoIndex = 1 as integer)
    data = m.getPlayerData("errorcard", episode, playerTime, mediaTime, videoIndex)
    data["gestval"] = "error:" + message
    m.sendRequest(data)
end sub

sub dw_playerLiveError(message as string, channel as object, playerTime as integer, mediaTime as integer, videoIndex = 1 as integer)
    data = m.getPlayerLiveData("errorcard", channel, playerTime, mediaTime, videoIndex)
    data["gestval"] = "error:" + message
    m.sendRequest(data)
end sub

' ************************
' Resume Position Tracking
' ************************
sub dw_playerPlayPosition(episode as object, position as integer)
    data = {}
    data["userid"] = m.userID
    data["v22"] = asString(episode.trackingContentID)
    data["affiliate"] = false
    data["premium"] = (episode.status = "PREMIUM")
    data["episode"] = episode.isFullEpisode
    data["platform"] = "roku"
    data["medtitle"] = episode.trackingTitle
    data["sessionid"] = m.playerID
    data["medtime"] = position
    data["siteid"] = 244
    
    m.sendRequest(data, true)
end sub

sub dw_playerLivePlayPosition(channel as object, position as integer)
    data = {}
    data["userid"] = m.userID
    data["v22"] = asString(channel.trackingContentID)
    data["affiliate"] = (channel.subtype() = "Station")
    data["premium"] = false
    data["platform"] = "roku"
    data["medtitle"] = channel.trackingTitle
    data["sessionid"] = m.playerID
    data["medtime"] = 0 'position
    data["siteid"] = 244
    
    m.sendRequest(data, true)
end sub


sub dw_processRequests(timeout = 5000 as integer, blockUntilComplete = false as boolean)
    for i = 0 To m.requests.Count() - 1
        request = m.requests[i]
        if request <> invalid then
            msg = invalid
            if blockUntilComplete then
                msg = Wait(timeout, request.getMessagePort())
            else
                msg = request.getMessagePort().getMessage()
            end if
            if Type(msg) = "roUrlEvent" and msg.getInt() = 1 then
                debugPrint(request.getUrl(), "DW.Complete (" + asString(msg.getResponseCode()) + ")", 2)
                parseCookieHeaders(request.getUrl(), msg.getResponseHeadersArray())
                ' Remove the request from the queue
                m.requests[i] = invalid
            else if msg = invalid then
                if blockUntilComplete then
                    debugPrint(request.getUrl(), "DW.Timeout", 0)
                    request.AsyncCancel()
                end if
            end if
        end if
    next
    ' Remove any invalids, by cloning the array
    trimmedRequests = []
    trimmedRequests.append(m.requests)
    ' Reset the requests array
    m.requests = trimmedRequests
end sub

sub dw_sendRequest(data = {} as object, isBeacon = false as boolean)
setLogLevel(0)
    url = m.baseUrl
    if isBeacon then
        url = m.baseBeaconUrl
    end if
    
    for each key In data
        url = addQueryString(url, key, data[key])
    next
    timestamp = nowDate().asSeconds()
    if timestamp <= m.lastTimestamp then
        timestamp = m.lastTimestamp + 1
    end if
    url = addQueryString(url, "ts", timestamp)
    m.lastTimestamp = timestamp

    debugPrint(url, "DW.Track." + asString(data["event"]), 2)
    
    ' Send the request asynchronously
    m.requests.Push(GetUrlToStringAsync(url))
    
    ' Process any completed requests
    m.processRequests()
end sub
