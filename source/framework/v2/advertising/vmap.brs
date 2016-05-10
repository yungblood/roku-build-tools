'IMPORTS=v2/advertising/vmapAdBreak utilities/web utilities/xml utilities/strings utilities/types utilities/dateTime
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
Function NewVmap(url As String) As Object
    this                                = NewObservable()
    this.ClassName                      = "Vmap"
    
    this.Url                            = url
    
    ' Store the ads in an AA, so we can retrieve them by time key
    this.AdBreaks                       = {}
    this.AdBreakPositions               = []
    
    this.PlayedAds                      = {}
    this.PlayedAdDuration               = 0

    this.Init                           = Vmap_Init
    this.Precache                       = Vmap_Precache
    
    this.GetNormalizedAdBreakPosition   = Vmap_GetNormalizedAdBreakPosition
    this.GetPrecedingAdBreakPosition    = Vmap_GetPrecedingAdBreakPosition
    this.GetAdBreakIndex                = Vmap_GetAdBreakIndex
    this.GetAdBreak                     = Vmap_GetAdBreak
    this.GetPrerollAdBreak              = Vmap_GetPrerollAdBreak
    this.GetPostrollAdBreak             = Vmap_GetPostrollAdBreak
    
    this.SetBreakAsPlayed               = Vmap_SetBreakAsPlayed
    this.PlayAdBreak                    = Vmap_PlayAdBreak
    
    this.GetPlayedAdDuration            = Vmap_GetPlayedAdDuration

    this.OnAdClose                      = Vmap_OnAdClose
    this.OnAdRebuffer                   = Vmap_OnAdRebuffer
    this.OnAdStart                      = Vmap_OnAdStart
    this.OnAdPause                      = Vmap_OnAdPause
    this.OnAdResume                     = Vmap_OnAdResume
    this.OnAdFirstQuartile              = Vmap_OnAdFirstQuartile
    this.OnAdMidpoint                   = Vmap_OnAdMidpoint
    this.OnAdThirdQuartile              = Vmap_OnAdThirdQuartile
    this.OnAdPositionNotification       = Vmap_OnAdPositionNotification
    this.OnAdComplete                   = Vmap_OnAdComplete
    
    this.GetBaseEventData               = Vmap_GetBaseEventData
    
    this.Init()
    Return this
End Function

Sub Vmap_Init()
    xmlString = GetUrlToString(m.Url)
    parsed = ParseXmlAsJson(xmlString, True, "")
    
    If IsAssociativeArray(parsed) And IsAssociativeArray(parsed.VMAP) Then
        For Each adBreak in AsArray(parsed.VMAP.AdBreak)
            ' We're only interested in linear ads
            If adBreak.breakType = "linear" Then
                break = NewVmapAdBreak(adBreak)
                If Not IsNullOrEmpty(break.Url) Or break.Vast <> invalid Then
                    breakKey = ""
                    breakPosition = break.Time
                    If break.Time = -1 Then
                        breakPosition = m.GetNormalizedAdBreakPosition("postroll")
                    Else If break.Time = 0 Then
                        breakPosition = m.GetNormalizedAdBreakPosition("preroll")
                    Else
                        breakPosition = m.GetNormalizedAdBreakPosition(break.Time)
                    End If
                    breakKey = AsString(breakPosition)
                    If m.AdBreaks[breakKey] = invalid Then
                        m.AdBreaks[breakKey] = []
                    End If
                    m.AdBreaks[breakKey].Push(break)
                    m.AdBreakPositions.Push(breakPosition)
                End If
            End If
        Next
        SortArray(m.AdBreakPositions)
    End If
End Sub

Sub Vmap_Precache()
    For Each breakKey In m.AdBreaks
        break = m.GetAdBreak(breakKey, True)
        For Each ad In break
            ad.Populate()
        Next
    Next
End Sub

Function Vmap_GetNormalizedAdBreakPosition(position As Object) As Integer
    If IsString(position) Then
        If position = "preroll" Then
            position = 0
        Else If position = "postroll" Then
            position = 999999
        Else
            position = AsInteger(position)
        End If
    End If
    Return position
End Function

Function Vmap_GetPrecedingAdBreakPosition(position As Integer) As Integer
    adBreakPosition = 0
    For Each breakPosition In m.AdBreakPositions
        If breakPosition < position Then
            adBreakPosition = breakPosition
        End If
    Next
    Return adBreakPosition
End Function

Function Vmap_GetAdBreakIndex(position As Object) As Integer
    position = m.GetNormalizedAdBreakPosition(position)
    For i = 0 To m.AdBreakPositions.Count() - 1
        If m.AdBreakPositions[i] = position Then
            Return i
        End If
    Next
    Return -1
End Function

Function Vmap_GetAdBreak(position As Object, returnIfPlayed As Boolean) As Object
    position = m.GetNormalizedAdBreakPosition(position)
    break = m.AdBreaks[AsString(position)]
    If returnIfPlayed Or m.PlayedAds[AsString(position)] <> True Then
        Return break
    End If
    Return invalid
End Function

Function Vmap_GetPrerollAdBreak(returnIfPlayed As Boolean) As Object
    Return m.GetAdBreak("preroll", returnIfPlayed)
End Function

Function Vmap_GetPostrollAdBreak(returnIfPlayed As Boolean) As Object
    Return m.GetAdBreak("postroll", returnIfPlayed)
End Function

Sub Vmap_SetBreakAsPlayed(position As Object)
    position = m.GetNormalizedAdBreakPosition(position)
    m.PlayedAds[AsString(position)] = True
End Sub

Function Vmap_PlayAdBreak(position As Object, allowPause = False As Boolean, markAsPlayed = True As Boolean) As Boolean
    adBreak = m.GetAdBreak(position, True)
    If adBreak <> invalid And adBreak.Count() > 0 Then
        vast = invalid
        For Each ad In adBreak
            ad.Populate()
            If ad.Vast <> invalid Then
                If vast = invalid Then
                    vast = ad.Vast
                Else
                    vast.Merge(ad.Vast)
                End If
            End If
        Next
        If vast <> invalid Then
            vast.RegisterObserver(m, "AdClose", "OnAdClose")
            vast.RegisterObserver(m, "AdRebuffer", "OnAdRebuffer")
            vast.RegisterObserver(m, "AdStart", "OnAdStart")
            vast.RegisterObserver(m, "AdPause", "OnAdPause")
            vast.RegisterObserver(m, "AdResume", "OnAdResume")
            vast.RegisterObserver(m, "AdFirstQuartile", "OnAdFirstQuartile")
            vast.RegisterObserver(m, "AdMidpoint", "OnAdMidpoint")
            vast.RegisterObserver(m, "AdThirdQuartile", "OnAdThirdQuartile")
            vast.RegisterObserver(m, "AdPositionNotification", "OnAdPositionNotification")
            vast.RegisterObserver(m, "AdComplete", "OnAdComplete")
            continue = True
            m.AdPosition = position
            If vast.Play(position = "preroll", allowPause) Then
                If markAsPlayed Then
                    m.SetBreakAsPlayed(position)
                End If
            Else
                continue = False
            End If
            vast.UnregisterObserverForAllEvents(m)
            If Not continue Then
                Return False
            End If
        End If
    End If
    Return True
End Function

Function Vmap_GetPlayedAdDuration() As Integer
    Return m.PlayedAdDuration
End Function

Sub Vmap_OnAdClose(eventData As Object, callbackData = invalid As Object)
    eventData = m.GetBaseEventData(eventData)
    m.RaiseEvent("AdClose", eventData)
End Sub

Sub Vmap_OnAdRebuffer(eventData As Object, callbackData = invalid As Object)
    eventData = m.GetBaseEventData(eventData)
    m.RaiseEvent("AdRebuffer", eventData)
End Sub

Sub Vmap_OnAdStart(eventData As Object, callbackData = invalid As Object)
    eventData = m.GetBaseEventData(eventData)
    m.RaiseEvent("AdStart", eventData)
End Sub

Sub Vmap_OnAdPause(eventData As Object, callbackData = invalid As Object)
    eventData = m.GetBaseEventData(eventData)
    m.RaiseEvent("AdPause", eventData)
End Sub

Sub Vmap_OnAdResume(eventData As Object, callbackData = invalid As Object)
    eventData = m.GetBaseEventData(eventData)
    m.RaiseEvent("AdResume", eventData)
End Sub

Sub Vmap_OnAdFirstQuartile(eventData As Object, callbackData = invalid As Object)
    eventData = m.GetBaseEventData(eventData)
    m.RaiseEvent("AdFirstQuartile", eventData)
End Sub

Sub Vmap_OnAdMidpoint(eventData As Object, callbackData = invalid As Object)
    eventData = m.GetBaseEventData(eventData)
    m.RaiseEvent("AdMidpoint", eventData)
End Sub

Sub Vmap_OnAdThirdQuartile(eventData As Object, callbackData = invalid As Object)
    eventData = m.GetBaseEventData(eventData)
    m.RaiseEvent("AdThirdQuartile", eventData)
End Sub

Sub Vmap_OnAdPositionNotification(eventData As Object, callbackData = invalid As Object)
    eventData = m.GetBaseEventData(eventData)
    m.RaiseEvent("AdPositionNotification", eventData)
End Sub

Sub Vmap_OnAdComplete(eventData As Object, callbackData = invalid As Object)
    ' Add this ad's length to the overall ad duration
    m.PlayedAdDuration = m.PlayedAdDuration + eventData.Ad.Length

    eventData = m.GetBaseEventData(eventData)
    m.RaiseEvent("AdComplete", eventData)
End Sub

Function Vmap_GetBaseEventData(eventData As Object) As Object
    Return {
        PodPosition:    m.AdPosition
        PodNumber:      m.GetAdBreakIndex(m.AdPosition)
        PodIndex:       eventData.AdIndex
        Ad:             eventData.Ad
        AdLength:       eventData.Ad.Length
        Position:       eventData.Position
    }
End Function
