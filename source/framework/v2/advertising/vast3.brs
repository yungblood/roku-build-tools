'IMPORTS=v2/advertising/vast3Ad utilities/arrays utilities/web utilities/xml utilities/strings utilities/types utilities/dateTime
' ******************************************************
' Copyright Steven Kean 2010-2015
' All Rights Reserved.
' ******************************************************
Function NewVast3(urlOrData As Object, allowMultipleAds = True As Boolean) As Object
    this                            = NewObservable()
    this.ClassName                  = "Vast3"
    
    this.Ads                        = []
    this.TrackingRequests           = []
    this.AdIndex                    = 0
    
    this.AllowMultipleAds           = allowMultipleAds
    this.Length                     = 0
    
    this.CountdownPrefix            = "Advertisement: "
    
    this.Init                       = Vast3_Init
    
    this.Merge                      = Vast3_Merge

    this.Track                      = Vast3_Track
    this.ProcessTrackingEvents      = Vast3_ProcessTrackingEvents
    
    this.Play                       = Vast3_Play

    this.OnAdClose                  = Vast3_OnAdClose
    this.OnAdRebuffer               = Vast3_OnAdRebuffer
    this.OnAdStart                  = Vast3_OnAdStart
    this.OnAdPause                  = Vast3_OnAdPause
    this.OnAdResume                 = Vast3_OnAdResume
    this.OnAdFirstQuartile          = Vast3_OnAdFirstQuartile
    this.OnAdMidpoint               = Vast3_OnAdMidpoint
    this.OnAdThirdQuartile          = Vast3_OnAdThirdQuartile
    this.OnAdPositionNotification   = Vast3_OnAdPositionNotification
    this.OnAdComplete               = Vast3_OnAdComplete
    
    this.Init(urlOrData)
    
    Return this
End Function

Sub Vast3_Init(urlOrData As Object)
    vastData = urlOrData
    If IsString(vastData) Then
        xmlString = GetUrlToString(vastData)
        vastData = ParseXmlAsJson(xmlString, True, "")
    End If
    If IsAssociativeArray(vastData) And IsAssociativeArray(vastData.VAST) Then
        For Each adData In AsArray(vastData.VAST.Ad)
            If IsAssociativeArray(adData) Then
                If adData.InLine <> invalid Then
                    ' TODO: Add support for standalone ads
                    ad = NewVast3Ad(adData)
                    If ad.Streams.Count() > 0 Then
                        m.Ads.Push(ad)
                    End If
                Else If adData.Wrapper <> invalid Then
                    ' TODO: Add support for followAdditionalWrappers and fallbackOnNoAd
                    wrapper = adData.Wrapper
                    allowMultipleAds = (wrapper.allowMultipleAds <> "false")
                    vastUrl = wrapper.VASTAdTagURI
                    If Not IsNullOrEmpty(vastUrl) Then
                        vast3 = NewVast3(vastUrl)
                        If vast3.Ads.Count() > 0 Then
                            For Each ad In vast3.Ads
                                If ad.Streams.Count() > 0 Then
                                    ' Update the sort sequence with the wrapper sequence
                                    ad.SortSequence = AsString(AsInteger(adData.sequence)) + "." + ad.SortSequence
    
                                    ' Append the local tracking URLs
                                    For Each error In AsArray(wrapper.Error)
                                        If ad.TrackingUrls.Error = invalid Then
                                            ad.TrackingUrls.Error = []
                                        End If
                                        If IsAssociativeArray(error) Then
                                            error = error["#text"]
                                        End If
                                        ad.TrackingUrls.Error.Push(error)
                                    Next
                                    For Each impression In AsArray(wrapper.Impression)
                                        If ad.TrackingUrls.Impression = invalid Then
                                            ad.TrackingUrls.Impression = []
                                        End If
                                        If IsAssociativeArray(impression) Then
                                            impression = impression["#text"]
                                        End If
                                        ad.TrackingUrls.Impression.Push(impression)
                                    Next
                                    If IsAssociativeArray(wrapper.Creatives) Then
                                        For Each creative In AsArray(wrapper.Creatives.Creative)
                                            If creative.Linear <> invalid Then
                                                If IsAssociativeArray(creative.Linear.TrackingEvents) Then
                                                    For Each tracking In AsArray(creative.Linear.TrackingEvents.Tracking)
                                                        If ad.TrackingUrls[tracking["event"]] = invalid Then
                                                            ad.TrackingUrls[tracking["event"]] = []
                                                        End If
                                                        ad.TrackingUrls[tracking["event"]].Push(tracking["#text"])
                                                    Next
                                                End If
                                            End If
                                        Next
                                    End If
                                    
                                    m.Ads.Push(ad)
                                    
                                    If Not allowMultipleAds Or Not m.AllowMultipleAds Then
                                        ' We're not allowing multiple ads, so bail after this one
                                        Exit For
                                    End If
                                End If
                            Next
                        Else
                            ' Call the No Ads (303) error
                            For Each error In AsArray(wrapper.Error)
                                If IsAssociativeArray(error) Then
                                    error = error["#text"]
                                End If
                                error = Replace(error, "[ERRORCODE]", "303")
                                m.Track(error)
                            Next
                        End If
                    End If
                End If
            End If
            If m.Ads.Count() > 0 And Not m.AllowMultipleAds Then
                Exit For
            End If
        Next
    End If
    ' Sort the ads by sequence
    SortArray(m.Ads, Function(item1, item2) As Boolean : Return item1.SortSequence > item2.SortSequence : End Function)
    For Each ad In m.Ads
        m.Length = m.Length + ad.Length
    Next

    m.ProcessTrackingEvents()
End Sub  

Sub Vast3_Merge(urlOrData As Object)
    vast = urlOrData
    If IsString(vast) Then
        vast = NewVast3(urlOrData)
    End If
    If vast <> invalid And vast.Ads.Count() > 0 Then
        m.Ads.Append(vast.Ads)
        m.Length = m.Length + vast.Length
    End If
End Sub  

Sub Vast3_Track(url As String)
    url = Replace(url, "{", "%7B")
    url = Replace(url, "}", "%7D")
    url = Replace(url, "$", "%24")
    url = Replace(url, "|", "%7C")
    url = Replace(url, "[", "%5B")
    url = Replace(url, "]", "%5D")

    DebugPrint(url, "Vast3.Track", 1)
    ' Request the url asynchronously, so we don't block
    m.TrackingRequests.Push(GetUrlToStringAsync(url))
End Sub

Sub Vast3_ProcessTrackingEvents(timeout = 1000 As Integer)
    For Each request In m.TrackingRequests
        msg = invalid
        If IsRokuOne() Then
            msg = Wait(timeout, request.GetPort())
        Else
            msg = Wait(timeout, request.GetMessagePort())
        End If
        If Type(msg) = "roUrlEvent" And msg.GetInt() = 1 Then
            DebugPrint(request.GetUrl(), "Vast3.Tracking.Complete", 1)
            ParseCookieHeaders(request.GetUrl(), msg.GetResponseHeadersArray())
        Else If msg = invalid Then
            DebugPrint(request.GetUrl(), "Vast3.Tracking.Timeout", 0)
            request.AsyncCancel()
        End If
    Next
    m.TrackingRequests.Clear()
End Sub

Function Vast3_Play(isPreroll = False As Boolean, allowPause = False As Boolean) As Boolean
    canvas = CreateObject("roImageCanvas")
    canvas.SetLayer(0, { Color: "#FF000000" })
    canvas.Show()

    result = True
    countdownStart = m.Length
    For i = 0 To m.Ads.Count() - 1
        m.AdIndex = i
        ad = m.Ads[i]
        
        ' Register for the ad events
        ad.RegisterObserver(m, "Close", "OnAdClose")
        ad.RegisterObserver(m, "Rebuffer", "OnAdRebuffer")
        ad.RegisterObserver(m, "Start", "OnAdStart")
        ad.RegisterObserver(m, "Pause", "OnAdPause")
        ad.RegisterObserver(m, "Resume", "OnAdResume")
        ad.RegisterObserver(m, "FirstQuartile", "OnAdFirstQuartile")
        ad.RegisterObserver(m, "Midpoint", "OnAdMidpoint")
        ad.RegisterObserver(m, "ThirdQuartile", "OnAdThirdQuartile")
        ad.RegisterObserver(m, "PositionNotification", "OnAdPositionNotification")
        ad.RegisterObserver(m, "Complete", "OnAdComplete")
        
        continue = True
        If ad.Play(isPreroll, allowPause, countdownStart, m.CountdownPrefix) Then
            countdownStart = countdownStart - ad.Length
        Else
            continue = False
        End If
        
        ' Unregister for the ad events
        ad.UnregisterObserverForAllEvents(m)
        If Not continue Then
            Return False
        End If
    Next
    Return result
End Function

Sub Vast3_OnAdClose(eventData As Object, callbackData = invalid As Object)
    eventData.AdIndex = m.AdIndex
    m.RaiseEvent("AdClose", eventData)
End Sub

Sub Vast3_OnAdRebuffer(eventData As Object, callbackData = invalid As Object)
    eventData.AdIndex = m.AdIndex
    m.RaiseEvent("AdRebuffer", eventData)
End Sub

Sub Vast3_OnAdStart(eventData As Object, callbackData = invalid As Object)
    eventData.AdIndex = m.AdIndex
    m.RaiseEvent("AdStart", eventData)
End Sub

Sub Vast3_OnAdPause(eventData As Object, callbackData = invalid As Object)
    eventData.AdIndex = m.AdIndex
    m.RaiseEvent("AdPause", eventData)
End Sub

Sub Vast3_OnAdResume(eventData As Object, callbackData = invalid As Object)
    eventData.AdIndex = m.AdIndex
    m.RaiseEvent("AdResume", eventData)
End Sub

Sub Vast3_OnAdFirstQuartile(eventData As Object, callbackData = invalid As Object)
    eventData.AdIndex = m.AdIndex
    m.RaiseEvent("AdFirstQuartile", eventData)
End Sub

Sub Vast3_OnAdMidpoint(eventData As Object, callbackData = invalid As Object)
    eventData.AdIndex = m.AdIndex
    m.RaiseEvent("AdMidpoint", eventData)
End Sub

Sub Vast3_OnAdThirdQuartile(eventData As Object, callbackData = invalid As Object)
    eventData.AdIndex = m.AdIndex
    m.RaiseEvent("AdThirdQuartile", eventData)
End Sub

Sub Vast3_OnAdPositionNotification(eventData As Object, callbackData = invalid As Object)
    eventData.AdIndex = m.AdIndex
    m.RaiseEvent("AdPositionNotification", eventData)
End Sub

Sub Vast3_OnAdComplete(eventData As Object, callbackData = invalid As Object)
    eventData.AdIndex = m.AdIndex
    m.RaiseEvent("AdComplete", eventData)
End Sub
