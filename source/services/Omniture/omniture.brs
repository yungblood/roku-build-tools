Function Omniture() As Object
    If m.Omniture = invalid Then
        m.Omniture = NewOmniture()
    End If
    Return m.Omniture
End Function

Function NewOmniture() As Object
    this                = {}
    this.ClassName      = "Omniture"
    
    this.Omniture       = invalid
    
    this.BaseUrl        = "http://om.cbsi.com/b/ss/[SUITE_ID]/1/H.27.4/s06757860819343"
    
    this.Initialize     = Omniture_Initialize
    this.TrackPage      = Omniture_TrackPage
    this.TrackEvent     = Omniture_TrackEvent
    
    Return this
End Function

Sub Omniture_Initialize(suiteID As String, userID As String, subscriberStatus As String, subscriberProduct As String, evar5 = suiteID As String)
    url = Replace(m.BaseUrl, "[SUITE_ID]", suiteID)
    m.Omniture = NWM_Omniture(url)
    m.Omniture.debug = False
    m.Omniture.persistentParams.v1 = "CBS"
    m.Omniture.persistentParams.v3 = "roku tv ott|" + LCase(GetModel())
    m.Omniture.persistentParams.v5 = evar5
    'm.Omniture.persistentParams.v15 = subscriberStatus
    m.Omniture.persistentParams.v32 = "cbs_roku_app"
    m.Omniture.persistentParams.v69 = userID
    m.Omniture.persistentParams.l1 = subscriberStatus
    m.Omniture.persistentParams.pl = subscriberProduct
End Sub

Sub Omniture_TrackPage(pageName As String, events = [] As Object, additionalParams = {} As Object)
    params = {}
    params.pageName = pageName
    If events <> invalid And events.Count() > 0 Then
        params.events = Join(events, ",")
    End If
    params.Append(additionalParams)
    m.Omniture.LogEvent(params)
End Sub

Sub Omniture_TrackEvent(linkName As String, events = [] As Object, additionalParams = {} As Object)
    params = {}
    params.pev2 = linkName
    If events <> invalid And events.Count() > 0 Then
        params.events = Join(events, ",")
    End If
    params.Append(additionalParams)
    If params.v46 = invalid Then
        params.v46 = linkName
    End If
    m.Omniture.LogEvent(params)
End Sub