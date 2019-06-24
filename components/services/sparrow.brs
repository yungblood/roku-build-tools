function sparrow() as object
    if m.sparrow = invalid then
        m.sparrow = newSparrow()
    end if
    return m.sparrow
end function

function newSparrow() as object
    this                        = {}
    this.className              = "Sparrow"

    this.requests               = []

    this.debug                  = false
    this.staging                = false
    this.userID                 = ""
    this.siteID                 = 164
    this.playerID               = ""
    this.platform               = "roku"
    this.lastTimestamp          = 0

    this.initialize             = sparrow_initialize
    this.setUserID              = sparrow_setUserID
    this.setSiteID              = sparrow_setSiteID
    
    this.playerInit             = sparrow_playerInit
    
    this.playerPlayPosition     = sparrow_playerPlayPosition
    this.playerLivePlayPosition = sparrow_playerLivePlayPosition
    
    this.processRequests        = sparrow_processRequests
    this.sendRequest            = sparrow_sendRequest
    
    return this
end function

sub sparrow_initialize(url as string)
    m.baseUrl = url
end sub

sub sparrow_setUserID(userID as string)
    m.userID = userID
end sub

sub sparrow_setSiteID(siteID as string)
    m.siteID = siteID
end sub

sub sparrow_playerInit(generateNewPlayerID = true as boolean)
    if isNullOrEmpty(m.playerID) or generateNewPlayerID then
        m.playerID = md5Hash(getPersistedDeviceID() + nowDate().asSeconds().toStr())
    end if
end sub

' ************************
' Resume Position Tracking
' ************************
sub sparrow_playerPlayPosition(episode as object, position as integer)
    data = {}
    data["userid"] = m.userID
    data["contentid"] = asString(episode.trackingContentID)
    data["affiliate"] = false
    data["premium"] = (episode.status = "PREMIUM")
    data["episode"] = episode.isFullEpisode
    data["platform"] = m.platform
    data["medtitle"] = episode.trackingTitle
    data["sessionid"] = m.playerID
    data["medtime"] = position
    data["siteid"] = m.siteID
    
    m.sendRequest(data, true)
end sub

sub sparrow_playerLivePlayPosition(channel as object, position as integer)
    data = {}
    data["userid"] = m.userID
    data["contentid"] = asString(channel.trackingContentID)
    data["affiliate"] = (channel.subtype() = "Station")
    data["premium"] = false
    data["platform"] = m.platform
    data["medtitle"] = channel.trackingTitle
    data["sessionid"] = m.playerID
    data["medtime"] = 0 'position
    data["siteid"] = m.siteID
    
    m.sendRequest(data, true)
end sub

sub sparrow_processRequests(timeout = 5000 as integer, blockUntilComplete = false as boolean)
    for i = 0 To m.requests.Count() - 1
        request = m.requests[i]
        if request <> invalid then
            msg = invalid
            if blockUntilComplete then
                msg = wait(timeout, request.getMessagePort())
            else
                msg = request.getMessagePort().getMessage()
            end if
            if Type(msg) = "roUrlEvent" and msg.getInt() = 1 then
                debugPrint(request.getUrl(), "Sparrow.Complete (" + asString(msg.getResponseCode()) + ")", 2)
                parseCookieHeaders(request.getUrl(), msg.getResponseHeadersArray())
                ' Remove the request from the queue
                m.requests[i] = invalid
            else if msg = invalid then
                if blockUntilComplete then
                    debugPrint(request.getUrl(), "Sparrow.Timeout", 0)
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

sub sparrow_sendRequest(data = {} as object, isBeacon = false as boolean)
    url = m.baseUrl
    
    for each key In data
        url = addQueryString(url, key, data[key])
    next
    timestamp = nowDate().asSeconds()
    if timestamp <= m.lastTimestamp then
        timestamp = m.lastTimestamp + 1
    end if
    url = addQueryString(url, "ts", timestamp)
    m.lastTimestamp = timestamp

    debugPrint(url, "Sparrow.Track." + asString(data["event"]), 2)
    
    ' Send the request asynchronously
    m.requests.Push(GetUrlToStringAsync(url))
    
    ' Process any completed requests
    m.processRequests()
end sub
