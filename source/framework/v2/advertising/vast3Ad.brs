'IMPORTS=utilities/web utilities/xml utilities/strings utilities/types utilities/dateTime v2/base/observable
' ******************************************************
' Copyright Steven Kean 2010-2015
' All Rights Reserved.
' ******************************************************
Function NewVast3Ad(adData As Object) As Object
    this                        = NewObservable()
    this.ClassName              = "Vast3Ad"

    this.CountdownPrefix        = "Advertisement: "
    this.ID                     = ""
    this.CreativeID             = ""
    this.PodSequence            = 0
    this.StreamFormat           = "mp4"
    this.Streams                = []
    this.TrackingUrls           = {}
    
    this.Requests               = []
    
    this.Init                   = Vast3Ad_Init
    
    this.Track                  = Vast3Ad_Track
    this.ProcessTrackingEvents  = Vast3Ad_ProcessTrackingEvents
    
    this.Play                   = Vast3Ad_Play
    
    this.GetBaseEventData       = Vast3Ad_GetBaseEventData
    
    this.Init(adData)
    
    Return this
End Function

Sub Vast3Ad_Init(adData As Object)
    If IsAssociativeArray(adData) Then
        m.ID = adData.id
        m.PodSequence = AsInteger(adData.sequence)
        m.SortSequence = AsString(m.PodSequence)
        
        ' We're only interested in inline ads
        ' TODO: add support for skipoffset and progress
        If adData.InLine <> invalid Then
            inlineAd = adData.InLine
            m.System = AsString(inlineAd.AdSystem)
            m.Title = AsString(inlineAd.AdTitle)
            m.Description = AsString(inlineAd.Description)
            For Each error In AsArray(inlineAd.Error)
                If m.TrackingUrls.Error = invalid Then
                    m.TrackingUrls.Error = []
                End If
                If IsAssociativeArray(error) Then
                    error = error["#text"]
                End If
                m.TrackingUrls.Error.Push(error)
            Next
            For Each impression In AsArray(inlineAd.Impression)
                If m.TrackingUrls.Impression = invalid Then
                    m.TrackingUrls.Impression = []
                End If
                If IsAssociativeArray(impression) Then
                    impression = impression["#text"]
                End If
                m.TrackingUrls.Impression.Push(impression)
            Next
            If IsAssociativeArray(inlineAd.Creatives) Then
                For Each creative In AsArray(inlineAd.Creatives.Creative)
                    If creative.Linear <> invalid Then
                        m.CreativeID = AsString(creative.id)
                        m.Length = GetTotalSecondsFromTime(creative.Linear.Duration)
                        If IsAssociativeArray(creative.Linear.MediaFiles) Then
                            For Each mediaFile In AsArray(creative.Linear.MediaFiles.MediaFile)
                                If mediaFile.type = "video/mp4" Then
                                    stream = {
                                        Url:        Replace(mediaFile["#text"], " ", "%20")
                                        Bitrate:    AsInteger(mediaFile.bitrate)
                                        Width:      AsInteger(mediaFile.width)
                                        Height:     AsInteger(mediaFile.height)
                                    }
                                    m.Streams.Push(stream)
                                End If
                            Next
                        End If
                        If m.Streams.Count() > 0 Then
                            ' We have streams, so continue processing
                            If IsAssociativeArray(creative.Linear.TrackingEvents) Then
                                For Each tracking In AsArray(creative.Linear.TrackingEvents.Tracking)
                                    If m.TrackingUrls[tracking["event"]] = invalid Then
                                        m.TrackingUrls[tracking["event"]] = []
                                    End If
                                    m.TrackingUrls[tracking["event"]].Push(tracking["#text"])
                                Next
                            End If
                            ' We're only interested in the first linear creative
                            Exit For
                        End If
                    End If
                Next
            End If
        End If
    End If
End Sub

Sub Vast3Ad_Track(event As String)
    urls = m.TrackingUrls[event]
    If urls <> invalid And Not IsArray(urls) Then
        urls = [urls]
    End If
    If urls <> invalid Then
        For Each url In urls
            If Not IsNullOrEmpty(url) Then
                url = Replace(url, "{", "%7B")
                url = Replace(url, "}", "%7D")
                url = Replace(url, "$", "%24")
                url = Replace(url, "|", "%7C")
                url = Replace(url, "[", "%5B")
                url = Replace(url, "]", "%5D")
            
                DebugPrint(url, "Vast3Ad.Track." + event, 1)
                ' Request the url asynchronously, so we don't block
                m.Requests.Push(GetUrlToStringAsync(url))
            End If
        Next
    End If
    ' Process any completed requests
    m.ProcessTrackingEvents()
End Sub

Sub Vast3Ad_ProcessTrackingEvents(timeout = 1000 As Integer, blockUntilComplete = False As Boolean)
    For i = m.Requests.Count() - 1 To 0 Step -1
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
                DebugPrint(request.GetUrl(), "Vast3Ad.Tracking.Complete", 1)
                ParseCookieHeaders(request.GetUrl(), msg.GetResponseHeadersArray())
                ' Remove the request from the queue
                m.Requests.Delete(i)
            Else If msg = invalid Then
                If blockUntilComplete Then
                    DebugPrint(request.GetUrl(), "Vast3Ad.Tracking.Timeout", 0)
                    request.AsyncCancel()
                End If
            End If
        End If
    Next
End Sub


Function Vast3Ad_Play(isPreRoll = False As Boolean, allowPause = False As Boolean, countdownStart = m.Length As Integer, countdownPrefix = m.CountdownPrefix) As Boolean
    messagePort = CreateObject("roMessagePort")
    
    ' Create and setup the overlay canvas
    canvas = CreateObject("roImageCanvas")
    canvas.SetMessagePort(messagePort)
    canvas.SetRequireAllImagesToDraw(False)
    videoLayer = {
        Color: "#00FFFFFF"
        CompositionMode: "Source"
    }
    textLayer = [
        { Color: "#FF000000" }
        {
            Text: "Your video will " + IIf(isPreRoll, "begin", "resume") + " in a few moments..."
            TextAttrs: {
                Color: "#FFB3B3B3"
                Font: "Small"
            }
        }
    ]
    
    ' Setup the ad countdown overlay layer
    countdownText = CreateObject("roString")
    countdownLayer = [
        ' Shadow
        {
            Text: countdownText
            TextAttrs: {
                Color:  "#CC000000"
                Font:   "Small"
                HAlign: "Left"
                VAlign: "Top"
            }
            TargetRect: {
                x: Int(canvas.GetCanvasRect().w * .05) + 1
                y: Int(canvas.GetCanvasRect().h * .05) + 1
                w: canvas.GetCanvasRect().w
                h: canvas.GetCanvasRect().h
            }
        }
        ' Text
        {
            Text: countdownText
            TextAttrs: {
                Color:  "#CCFFFFFF"
                Font:   "Small"
                HAlign: "Left"
                VAlign: "Top"
            }
            TargetRect: {
                x: Int(canvas.GetCanvasRect().w * .05)
                y: Int(canvas.GetCanvasRect().h * .05)
                w: canvas.GetCanvasRect().w
                h: canvas.GetCanvasRect().h
            }
        }

    ]
    
    canvas.SetLayer(0, textLayer)
    canvas.Show()
    
    ' Create the video player
    player = CreateObject("roVideoPlayer")
    player.SetMessagePort(messagePort)
    player.SetPositionNotificationPeriod(1)
    player.SetCertificatesFile("common:/certs/ca-bundle.crt")
    player.SetContentList([m])

    ' Start playback
    player.Play()
    
    ' Listen for video and user events
    isPaused = False
    playbackCancelled = False
    While True
        msg = Wait(5000, messagePort)
        If msg = invalid Then
            If Not isPaused Then
                ' We've gone more than 5 seconds without an event, so assume
                ' we've hung, and bail out of the ad
                m.Track("error")
                Exit While
            End If
        Else If Type(msg) = "roImageCanvasEvent" Then
            If msg.IsRemoteKeyPressed() Then
                remoteKey = msg.GetIndex()
                If remoteKey = 13 And allowPause Then
                    ' Play/Pause was pressed, toggle the state
                    If isPaused Then
                        player.Resume()
                    Else
                        player.Pause()
                    End If
                Else If remoteKey = 0 Or remoteKey = 2 Then ' Back or Up
                    player.Stop()
                    ' Playback was either stopped by the user
                    m.Track("closeLinear")
                    m.RaiseEvent("Close", m.GetBaseEventData())
                    playbackCancelled = True
                    Exit While
                End If
            End If
        Else If Type(msg) = "roVideoPlayerEvent" Then
            If msg.IsStreamStarted() Then
                info = msg.GetInfo()
                If info.IsUnderrun Then
                    m.RaiseEvent("Rebuffer", m.GetBaseEventData())
                Else
                    If Not isPaused Then
                        m.RaiseEvent("Start", m.GetBaseEventData())
                    End If
                End If
            Else If msg.IsPaused() Then
                isPaused = True
                m.Track("pause")
                m.RaiseEvent("Pause", m.GetBaseEventData())
            Else If msg.IsResumed() Then
                isPaused = False
                m.Track("resume")
                m.RaiseEvent("Resume", m.GetBaseEventData())
            Else If msg.IsStatusMessage() Then
                If msg.GetMessage() = "start of play" Then
                    ' Done buffering, so clear the message layer
                    canvas.SetLayer(0, videoLayer)
                End If
            Else If msg.IsPlaybackPosition() Then
                m.Position = msg.GetIndex()
                
                If countdownStart > 0 And countdownStart - m.Position > 0 Then
                    ' Show the countdown overlay
                    countdown = GetDurationString(countdownStart - m.Position, False, False, " seconds", " minutes ", " hours ", " days ", " second", " minute ", " hour ", " day ")
                    countdownText.SetString(countdownPrefix + "Your video will " + IIf(isPreRoll, "begin", "resume") + " in " + countdown)
                    canvas.SetLayer(1, countdownLayer)
                Else
                    ' Hide the countdown overlay
                    canvas.ClearLayer(1)
                End If
                
                ' Calculate the video quartiles and track as appropriate
                quarts = m.Length / 4
                If m.Position = 0 Then
                    m.Track("impression")
                    m.Track("creativeView")
                    m.Track("start")
                Else If m.Position = Int(quarts) Then
                    m.Track("firstQuartile")
                    m.RaiseEvent("FirstQuartile", m.GetBaseEventData())
                Else If m.Position = Int(quarts * 2) Then
                    m.Track("midpoint")
                    m.RaiseEvent("Midpoint", m.GetBaseEventData())
                Else If m.Position = Int(quarts * 3) Then
                    m.Track("thirdQuartile")
                    m.RaiseEvent("ThirdQuartile", m.GetBaseEventData())
                End If
                m.RaiseEvent("PositionNotification", m.GetBaseEventData())
            Else If msg.IsFullResult() Then
                ' Successfully completed playback
                m.Track("complete")
                m.RaiseEvent("Complete", m.GetBaseEventData())
                Exit While
            Else If msg.IsPartialResult() Or msg.IsRequestFailed() Then
                ' Playback was either stopped by the user or due to an error
                m.Track("closeLinear")
                playbackCancelled = msg.IsPartialResult()
                m.RaiseEvent("Close", m.GetBaseEventData())
                Exit While
            End If
        End If
    End While
    ' We're done, so ensure all tracking events have processed
    m.ProcessTrackingEvents(1000, True)
    Return Not playbackCancelled
End Function

Function Vast3Ad_GetBaseEventData() As Object
    eventData = {
        Ad:         m
        Length:     m.Length
        Position:   m.Position
    }
    Return eventData
End Function