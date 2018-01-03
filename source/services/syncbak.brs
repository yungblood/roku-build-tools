Function Syncbak() As Object
    If m.Syncbak = invalid Then
        m.Syncbak = NewSyncbak()
    End If
    Return m.Syncbak
End Function

Function NewSyncbak() As Object
    this                    = {}
    this.ClassName          = "Syncbak"
    
    this.Initialize         = Syncbak_Initialize
    
    this.GetChannels        = Syncbak_GetChannels
    this.GetScheduleLegacy  = Syncbak_GetScheduleLegacy
    this.GetSchedule        = Syncbak_GetSchedule
    this.GetStream          = Syncbak_GetStream
    
    this.GetDeviceData      = Syncbak_GetDeviceData
    this.MakeRequest        = Syncbak_MakeRequest
    
    Return this
End Function

Sub Syncbak_Initialize(apiKey As String, apiSecret As String, endpoint As String)
    m.APIKey = apiKey
    m.APISecret = apiSecret
    m.Endpoint = endpoint
End Sub

Function Syncbak_GetChannels() As Object
    channels = []
    response = m.MakeRequest("/v3/channels")
    If response <> invalid Then
        For Each item In AsArray(response.channels)
            channels.Push(NewChannel(item))
        Next
    End If
    Return channels
End Function

Function Syncbak_GetScheduleLegacy(stationID As String, startTime = NowDate() As Object, count = 10 As Integer) As Object
    schedule = []
    params = {}
    params["stationId"] = stationID
    params["startTime"] = startTime.AsSeconds()
    params["count"] = count
    response = m.MakeRequest("/v3/schedule", params)
    If response <> invalid Then
        For Each item In AsArray(response.schedule)
            schedule.Push(NewScheduleItem(item))
        Next
    End If
    Return schedule
End Function

Function Syncbak_GetSchedule(scheduleUrl As String) As Object
    schedule = []
    response = GetUrlToJson(scheduleUrl)
    If response <> invalid Then
        For Each item In AsArray(response.schedule)
            schedule.Push(NewScheduleItem(item))
        Next
    End If
    Return schedule
End Function

Function Syncbak_GetStream(stationID As String, mediaID As String, typeID = -1 As Integer) As String
    params = {}
    params["stationId"] = stationID
    params["mediaId"] = mediaID
    If typeID > -1 Then
        params["typeId"] = typeID
    End If
    response = m.MakeRequest("/v3/streams", params)
    If response <> invalid Then
        For Each item In AsArray(response.streams)
            If item.typeId = 1 Then ' 1 = HLS
                Return item.url '"https://staging-playlistserver.aws.syncbak.com/playlist/66105/master.m3u8?token=DFCCC17E85F447BD9D8150B840354170" '
            End If
        Next
    End If
    Return ""
End Function

Function Syncbak_GetDeviceData() As Object
    If m.DeviceData = invalid Then
        deviceData = {}
        deviceData["deviceId"] = GetDeviceID()
        'deviceData["ip"] = Cbs().GetIPAddress() '"67.221.255.55" ' 
        'deviceData["ip"] = "67.221.255.55" ' 
        deviceData["locationAccuracy"] = 5
        deviceData["locationAge"] = 0
        deviceData["MVPDId"] = "AllAccess"

        m.DeviceData = Base64Encode(FormatJson(deviceData))
    End If
    Return m.DeviceData
End Function

Function Syncbak_MakeRequest(path As String, params = invalid As Object, retryCount = 0 As Integer) As Object
    If IsAssociativeArray(params) Then
        For Each param In params
            path = AddQueryString(path, param, params[param])
        Next
    End If
    url = m.Endpoint + path
    
    expiryDate = NowDate().AsSeconds() + 14400  ' 2 hours
    
    signatureData = AsString(expiryDate) + m.GetDeviceData() + path
    signature = HMACSignature(signatureData, m.APISecret, "sha1", "hexLower")
    
    headers = {}
    headers["api-key"] = m.APIKey
    headers["req-expires"] = AsString(expiryDate)
    headers["signature"] = signature
    headers["device-data"] = m.GetDeviceData()

    response = GetUrlToStringEx(url, 30, headers)

    If response <> invalid Then
        If response.ResponseCode = 200 Then
            Return ParseJson(response.Response)
        Else If response.ResponseCode = 503 Then ' Too busy
            If retryCount = 0 Then
                Sleep(2500)
            Else If retryCount = 1 Then
                Sleep(5000)
            Else
                Sleep(10000)
            End If
            Return m.MakeRequest(path, params, retryCount + 1)
        End If
    End If
    
    Return invalid
End Function