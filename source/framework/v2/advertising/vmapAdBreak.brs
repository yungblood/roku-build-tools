'IMPORTS=v2/advertising/vast3 utilities/web utilities/xml utilities/strings utilities/types utilities/dateTime
' ******************************************************
' Copyright Steven Kean 2010-2015
' All Rights Reserved.
' ******************************************************
Function NewVmapAdBreak(breakData As Object) As Object
    this = {}
    this.ClassName      = "VmapAdBreak"
    
    this.ID             = ""
    this.Url            = ""
    this.Vast           = invalid
    this.Time           = invalid
    this.TrackingEvents = {}
    
    this.Init           = VmapAdBreak_Init
    
    this.Populate       = VmapAdBreak_Populate
    
    this.Init(breakData)
    
    Return this
End Function

Sub VmapAdBreak_Init(breakData As Object)
    If IsAssociativeArray(breakData) Then
        m.TrackingEvents = {}
        m.ID = breakData.breakId
        ' We don't support "percentage" or "position" based ads
        If Not IsNullOrEmpty(breakData.timeOffset) Then
            If breakData.timeOffset = "start" Then
                m.Time = 0
            Else If breakData.timeOffset = "end" Then
                m.Time = -1
            Else If breakData.timeOffset.InStr(":") > 0 Then
                m.Time = GetTotalSecondsFromTime(breakData.timeOffset)
            End If
            If breakData.TrackingEvents <> invalid Then
                For Each tracking In AsArray(breakData.TrackingEvents.Tracking)
                    If m.TrackingEvents[tracking.event] = invalid Then
                        m.TrackingEvents[tracking.event] = []
                    End If
                    m.TrackingEvents[tracking.event].Push(tracking["#text"])
                Next
            End If
            If IsAssociativeArray(breakData.AdSource) Then
                m.AllowMultipleAds = (breakData.AdSource.allowMultipleAds <> "false")
                m.FollowRedirects = (breakData.AdSource.followRedirects <> "false")
                If breakData.AdSource.VASTAdData <> invalid Then
                    m.Vast = NewVast3(breakData.AdSource.VASTAdData)
                Else If breakData.AdSource.AdTagURI <> invalid Then
                    If IsString(breakData.AdSource.AdTagURI) Then
                        m.Url = breakData.AdSource.AdTagURI
                    Else If StartsWith(breakData.AdSource.AdTagURI.templateType, "vast") Then
                        ' We only handle VAST ad URLs
                        m.Url = breakData.AdSource.AdTagURI["#text"]
                    End If
                End If
            End If
        End If
    End If
End Sub

Sub VmapAdBreak_Populate(refresh = False As Boolean)
    If Not IsNullOrEmpty(m.Url) Then
        If refresh Or m.Vast = invalid Then
            m.Vast = NewVast3(m.Url, m.AllowMultipleAds)
        End If
    End If
End Sub