Function DW() As Object
    If m.DW = invalid Then
        m.DW = NewDW()
    End If
    Return m.DW
End Function

Function NewDW() As Object
    this                        = {}
    this.ClassName              = "DW"

    this.Requests               = []
    
    this.BaseUrl                = "http://dw.cbsi.com/levt/video/e.gif"
    this.BaseBeaconUrl          = "http://dw.cbsi.com/levt/beacon/e.gif"
    this.PlayerID               = ""

    this.GetUserData            = DW_GetUserData
    this.GetBasePlayerData      = DW_GetBasePlayerData
    this.GetPlayerData          = DW_GetPlayerData
    this.GetPlayerLiveData      = DW_GetPlayerLiveData
    this.GetPlayerAdData        = DW_GetPlayerAdData
    
    this.PlayerInit             = DW_PlayerInit
    this.PlayerStart            = DW_PlayerStart
    this.PlayerLiveStart        = DW_PlayerLiveStart
    this.PlayerAdStart          = DW_PlayerAdStart
    this.PlayerEnd              = DW_PlayerEnd
    this.PlayerLiveEnd          = DW_PlayerLiveEnd
    this.PlayerLiveForcedEnd    = DW_PlayerLiveForcedEnd
    this.PlayerAdEnd            = DW_PlayerAdEnd
    this.PlayerPlay             = DW_PlayerPlay
    this.PlayerLivePlay         = DW_PlayerLivePlay
    this.PlayerAdPlay           = DW_PlayerAdPlay
    this.PlayerStop             = DW_PlayerStop
    this.PlayerLiveStop         = DW_PlayerLiveStop
    this.PlayerPause            = DW_PlayerPause
    this.PlayerUnpause          = DW_PlayerUnpause
    this.PlayerRewind           = DW_PlayerRewind
    this.PlayerForward          = DW_PlayerForward
    this.PlayerError            = DW_PlayerError
    this.PlayerLiveError        = DW_PlayerLiveError
    
    this.PlayerPlayPosition     = DW_PlayerPlayPosition
    this.PlayerLivePlayPosition = DW_PlayerLivePlayPosition
    
    this.ProcessRequests        = DW_ProcessRequests
    this.SendRequest            = DW_SendRequest
    
    Return this
End Function

Function DW_GetUserData() As Object
    user = Cbs().GetCurrentUser()
    data = {}
    data["ursuid"] = user.ID
    data["v25"] = user.GetStatusForTracking()
    'data["v26"] = user.Packages
    
    Return data
End Function

Function DW_GetBasePlayerData(event As String) As Object
    data = {}
    data["event"] = event
    data["siteid"] = 1054
    data["v21"] = "set top box"
    data["v23"] = "cbsicbsott"
    data["componentid"] = m.PlayerID
    data["distntwrk"] = "can"
    data["mapp"] = "CBS_Roku;ROKU;" + GetAppVersion()
    data["part"] = "cbs_roku_app"
    data["device"] = "type:settop;os:roku;ver:" + GetFirmware().FullVersion + ";cpu:" + LCase(GetCpuType()) + ";screensz:" + GetDisplayResolution()
    
    Return data
End Function

Function DW_GetPlayerData(event As String, episode As Object, playerTime As Integer, mediaTime As Integer, videoIndex = 1 As Integer) As Object
    data = m.GetBasePlayerData(event)
    data["playertime"] = playerTime
    data["medtitle"] = episode.TrackingTitle
    data["medastid"] = 595
    data["medid"] = episode.MediaID
    data["v22"] = episode.ContentID
    data["medlength"] = episode.Length
    data["medtime"] = mediaTime
    data["mednum"] = videoIndex
    data["sdlvrytype"] = 1

    ' Append the user data
    data.Append(m.GetUserData())
    
    Return data
End Function

Function DW_GetPlayerLiveData(event As String, channel As Object, playerTime As Integer, mediaTime As Integer, videoIndex = 1 As Integer) As Object
    data = m.GetBasePlayerData(event)
    data["playertime"] = playerTime
    data["medtitle"] = channel.TrackingTitle
    data["medastid"] = channel.TrackingAstID '600
    data["medid"] = channel.TrackingID ' 2344
    data["medlength"] = 0
    data["medtime"] = mediaTime
    data["mednum"] = videoIndex
    data["sdlvrytype"] = 2

    ' Append the user data
    data.Append(m.GetUserData())
    
    Return data
End Function

Function DW_GetPlayerAdData(ad As Object, adPosition As Integer, podNumber As Integer, podIndex As Integer, adNumber As Integer, episode As Object, mediaTime As Integer) As Object
    data = {}
    data["adastid"] = 42
    'data["adbreak"] = ""
    data["adid"] = ad.CreativeID
    If IsNullOrEmpty(data["adid"]) Then
        data["adid"] = "999"
    End If
    data["adlength"] = ad.Length
    data["adnum"] = adNumber
    data["adpod"] = podNumber
    data["adpodpos"] = podIndex
    data["adpos"] = IIf(mediaTime = 0, "pre", IIf(mediaTime < AsInteger(episode.Length), "mid", "post"))
    data["adtime"] = adPosition
    data["adtitle"] = ad.Title
    data["adtype"] = 1
    
    Return data
End Function

Sub DW_PlayerInit(playerID As String)
    m.PlayerID = playerID
    
    data = m.GetBasePlayerData("init")
    data["playertime"] = 0

    ' Append the user data
    data.Append(m.GetUserData())
    
    m.SendRequest(data)
End Sub

Sub DW_PlayerStart(episode As Object, playerTime As Integer, videoIndex = 1 As Integer)
    data = m.GetPlayerData("start", episode, playerTime, 0, videoIndex)
    If episode.SubscriptionLevel = "FREE" Then
        data["gestval"] = "paywall:0"
    Else
        data["gestval"] = "paywall:1"
    End If
    m.SendRequest(data)
End Sub

Sub DW_PlayerLiveStart(channel As Object, playerTime As Integer, videoIndex = 1 As Integer)
    data = m.GetPlayerLiveData("start", channel, playerTime, 0, videoIndex)
    data["gestval"] = "paywall:1"
    m.SendRequest(data)
End Sub

Sub DW_PlayerAdStart(ad As Object, podNumber As Integer, podIndex As Integer, adNumber As Integer, episode As Object, playerTime As Integer, mediaTime As Integer, videoIndex = 1 As Integer)
    data = m.GetPlayerData("start", episode, playerTime, 0, videoIndex)
    If episode.SubscriptionLevel = "FREE" Then
        data["gestval"] = "paywall:0"
    Else
        data["gestval"] = "paywall:1"
    End If
    
    data.Append(m.GetPlayerAdData(ad, 0, podNumber, podIndex, adNumber, episode, mediaTime))
    
    m.SendRequest(data)
End Sub

Sub DW_PlayerEnd(episode As Object, playerTime As Integer, mediaTime As Integer, videoIndex = 1 As Integer)
    data = m.GetPlayerData("end", episode, playerTime, mediaTime, videoIndex)
    m.SendRequest(data)
End Sub

Sub DW_PlayerLiveEnd(channel As Object, playerTime As Integer, mediaTime As Integer, videoIndex = 1 As Integer)
    data = m.GetPlayerLiveData("end", channel, playerTime, mediaTime, videoIndex)
    m.SendRequest(data)
End Sub

Sub DW_PlayerLiveForcedEnd(action As String, channel As Object, playerTime As Integer, mediaTime As Integer, videoIndex = 1 As Integer)
    data = m.GetPlayerLiveData("forced_end", channel, playerTime, mediaTime, videoIndex)
    data["gestval"] = "action:" + action
    m.SendRequest(data)
End Sub

Sub DW_PlayerAdEnd(ad As Object, adPosition As Integer, podNumber As Integer, podIndex As Integer, adNumber As Integer, episode As Object, playerTime As Integer, mediaTime As Integer, videoIndex = 1 As Integer)
    data = m.GetPlayerData("end", episode, playerTime, mediaTime, videoIndex)
    data.Append(m.GetPlayerAdData(ad, adPosition, podNumber, podIndex, adNumber, episode, mediaTime))
    m.SendRequest(data)
End Sub

Sub DW_PlayerPlay(episode As Object, playerTime As Integer, mediaTime As Integer, videoIndex = 1 As Integer)
    track = False
    gestVal = ""
    If mediaTime > 0 And mediaTime <= 60 Then
        ' For 0-60, track every 15 seconds
        track = (mediaTime Mod 15 = 0)
    Else If mediaTime > 60 Then
        ' For 61+, track every minute and at 10% increments
        track = (mediaTime Mod 60 = 0)
        If Not track Then
            interval = Int(episode.Length / 10)
            If interval = 0 Then
                interval = Int(episode.Length / 4)
            End If
            track = (interval = 0) Or (mediaTime Mod interval = 0)
        End If
    End If
    quartile = Int(episode.Length / 4)
    If quartile > 0 And mediaTime > 0 And mediaTime Mod quartile = 0 Then
        track = True
        If mediaTime = quartile Then
            gestVal = "pct:25"
        Else If mediaTime = quartile * 2 Then
            gestVal = "pct:50"
        Else If mediaTime = quartile * 3 Then
            gestVal = "pct:70"
        End If
    End If
    If track Then
        data = m.GetPlayerData("play", episode, playerTime, mediaTime, videoIndex)
        If Not IsNullOrEmpty(gestVal) Then
            data["gestval"] = gestVal
        End If
        m.SendRequest(data)
    End If
End Sub

Sub DW_PlayerAdPlay(ad As Object, adPosition As Integer, podNumber As Integer, podIndex As Integer, adNumber As Integer, episode As Object, playerTime As Integer, mediaTime As Integer, videoIndex = 1 As Integer)
    interval = Int(ad.Length / 10)
    If interval = 0 Then
        interval = Int(ad.Length / 4)
    End If
    track = (interval = 0) Or (adPosition Mod interval = 0)
    If track Then
        data = m.GetPlayerData("play", episode, playerTime + adPosition, mediaTime, videoIndex)
        data.Append(m.GetPlayerAdData(ad, adPosition, podNumber, podIndex, adNumber, episode, mediaTime))
        
        m.SendRequest(data)
    End If
End Sub

Sub DW_PlayerLivePlay(channel As Object, playerTime As Integer, mediaTime As Integer, videoIndex = 1 As Integer)
    track = False
    If mediaTime > 0 And mediaTime <= 60 Then
        ' For 0-60, track every 5 seconds
        track = (mediaTime Mod 5 = 0)
    Else If mediaTime > 60 Then
        ' For 61+, track every minute and at 10% increments
        track = (mediaTime Mod 60 = 0)
    End If
    If track Then
        data = m.GetPlayerLiveData("play", channel, playerTime, mediaTime, videoIndex)
        m.SendRequest(data)
    End If
End Sub

Sub DW_PlayerStop(episode As Object, playerTime As Integer, mediaTime As Integer, videoIndex = 1 As Integer)
    data = m.GetPlayerData("stop", episode, playerTime, mediaTime, videoIndex)
    m.SendRequest(data)
End Sub

Sub DW_PlayerLiveStop(channel As Object, playerTime As Integer, mediaTime As Integer, videoIndex = 1 As Integer)
    data = m.GetPlayerLiveData("stop", channel, playerTime, mediaTime, videoIndex)
    m.SendRequest(data)
End Sub

Sub DW_PlayerPause(episode As Object, playerTime As Integer, mediaTime As Integer, videoIndex = 1 As Integer)
    data = m.GetPlayerData("pause", episode, playerTime, mediaTime, videoIndex)
    data["gestval"] = "action:pause_button"
    m.SendRequest(data)
End Sub

Sub DW_PlayerUnpause(pauseTime As Integer, episode As Object, playerTime As Integer, mediaTime As Integer, videoIndex = 1 As Integer)
    data = m.GetPlayerData("unpause", episode, playerTime, mediaTime, videoIndex)
    data["eventdur"] = pauseTime
    m.SendRequest(data)
End Sub

Sub DW_PlayerRewind(duration As Integer, episode As Object, playerTime As Integer, mediaTime As Integer, videoIndex = 1 As Integer)
    data = m.GetPlayerData("rewind", episode, playerTime, mediaTime, videoIndex)
    data["eventdur"] = duration
    m.SendRequest(data)
End Sub

Sub DW_PlayerForward(duration As Integer, episode As Object, playerTime As Integer, mediaTime As Integer, videoIndex = 1 As Integer)
    data = m.GetPlayerData("forward", episode, playerTime, mediaTime, videoIndex)
    data["eventdur"] = duration
    m.SendRequest(data)
End Sub

Sub DW_PlayerError(message As String, episode As Object, playerTime As Integer, mediaTime As Integer, videoIndex = 1 As Integer)
    data = m.GetPlayerData("errorcard", episode, playerTime, mediaTime, videoIndex)
    data["gestval"] = "error:" + message
    m.SendRequest(data)
End Sub

Sub DW_PlayerLiveError(message As String, channel As Object, playerTime As Integer, mediaTime As Integer, videoIndex = 1 As Integer)
    data = m.GetPlayerLiveData("errorcard", channel, playerTime, mediaTime, videoIndex)
    data["gestval"] = "error:" + message
    m.SendRequest(data)
End Sub

' ************************
' Resume Position Tracking
' ************************
Sub DW_PlayerPlayPosition(episode As Object, position As Integer)
    data = {}
    data["userid"] = Cbs().GetCurrentUser().ID
    data["v22"] = episode.ContentID
    data["affiliate"] = False
    data["premium"] = (episode.Status = "PREMIUM")
    data["episode"] = episode.IsFullEpisode()
    data["platform"] = "roku"
    data["medtitle"] = episode.TrackingTitle
    data["sessionid"] = m.PlayerID
    data["medtime"] = position
    data["siteid"] = 244
    
    m.SendRequest(data, True)
End Sub

Sub DW_PlayerLivePlayPosition(channel As Object, position As Integer)
    data = {}
    data["userid"] = Cbs().GetCurrentUser().ID
    'data["v22"] = episode.ContentID
    data["affiliate"] = (channel.ClassName = "Channel")
    data["premium"] = False
    data["platform"] = "roku"
    data["medtitle"] = channel.TrackingTitle
    data["sessionid"] = m.PlayerID
    data["medtime"] = 0 'position
    data["siteid"] = 244
    
    m.SendRequest(data, True)
End Sub


Sub DW_ProcessRequests(timeout = 5000 As Integer, blockUntilComplete = False As Boolean)
    For i = 0 To m.Requests.Count() - 1
        request = m.Requests[i]
        If request <> invalid Then
            msg = invalid
            If blockUntilComplete Then
                If CheckFirmware(4) >= 0 Then
                    msg = Wait(timeout, request.GetMessagePort())
                Else
                    msg = Wait(timeout, request.GetPort())
                End If
            Else
                If CheckFirmware(4) >= 0 Then
                    msg = request.GetMessagePort().GetMessage()
                Else
                    msg = request.GetPort().GetMessage()
                End If
            End If
            If Type(msg) = "roUrlEvent" And msg.GetInt() = 1 Then
                DebugPrint(request.GetUrl(), "DW.Complete (" + AsString(msg.GetResponseCode()) + ")", 1)
                ParseCookieHeaders(request.GetUrl(), msg.GetResponseHeadersArray())
                ' Remove the request from the queue
                m.Requests[i] = invalid
            Else If msg = invalid Then
                If blockUntilComplete Then
                    DebugPrint(request.GetUrl(), "DW.Timeout", 0)
                    request.AsyncCancel()
                End If
            End If
        End If
    Next
    ' Remove any invalids, by cloning the array
    trimmedRequests = []
    trimmedRequests.Append(m.Requests)
    ' Reset the requests array
    m.Requests = trimmedRequests
End Sub

Sub DW_SendRequest(data = {} As Object, isBeacon = False As Boolean)
    url = m.BaseUrl
    If isBeacon Then
        url = m.BaseBeaconUrl
    End If
    
    For Each key In data
        url = AddQueryString(url, key, data[key])
    Next
    url = AddQueryString(url, "ts", NowDate().AsSeconds())

    DebugPrint(url, "DW.Track." + AsString(data["event"]), 0)
    
    ' Send the request asynchronously
    m.Requests.Push(GetUrlToStringAsync(url))
    
    ' Process any completed requests
    m.ProcessRequests()
End Sub
