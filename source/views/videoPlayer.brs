Function NewVideoPlayer() As Object
    this                            = {}
    this.ClassName                  = "VideoPlayer"
    
    this.Video                      = invalid
    this.Canvas                     = CreateObject("roImageCanvas")
    this.PauseTimer                 = CreateObject("roTimespan")
    this.Position                   = 0
    this.AdCount                    = 0
    this.ResumingAfterAd            = False
    this.IsResume                   = False
    
    this.LiveTimedOut               = False
    this.LiveTimeout                = 2 * 60 * 60 * 1000 ' 2 hours
    this.LiveCTATimeout             = 5 * 60 * 1000      ' 5 minutes
    
    this.Akamai                     = AkaMA_plugin()
    this.StreamSense                = CSStreamingTag()
    this.StreamSenseParams          = {}
    this.bShowAds                   = false
    this.Raf                        = Roku_Ads()
    
    this.playedAdDuration           = 0

    ' Seconds to add to ad break positions
    this.AdPositionOffset           = 1
    
    this.Play                       = VideoPlayer_Play
    this.PlayAd                     = VideoPlayer_PlayAd
    this.GetPlayerPosition          = VideoPlayer_GetPlayerPosition
    
    this.InitAkamai                 = VideoPlayer_InitAkamai
    
    this.OnGetMessage               = VideoPlayer_OnGetMessage
    
    this.OnBeforeNewContent         = VideoPlayer_OnBeforeNewContent
    this.OnStart                    = VideoPlayer_OnStart
    this.OnFirstQuartile            = VideoPlayer_OnFirstQuartile
    this.OnMidpoint                 = VideoPlayer_OnMidpoint
    this.OnThirdQuartile            = VideoPlayer_OnThirdQuartile
    this.OnComplete                 = VideoPlayer_OnComplete
    this.OnClose                    = VideoPlayer_OnClose
    this.OnPositionNotification     = VideoPlayer_OnPositionNotification
    this.OnPause                    = VideoPlayer_OnPause
    this.OnResume                   = VideoPlayer_OnResume
    this.OnSkip                     = VideoPlayer_OnSkip
    this.OnError                    = VideoPlayer_OnError
    this.OnDisposed                 = VideoPlayer_OnDisposed
    
    this.OnIdle                     = VideoPlayer_OnIdle
    
    this.OnAdStart                  = VideoPlayer_OnAdStart
    this.OnAdFirstQuartile          = VideoPlayer_OnAdFirstQuartile
    this.OnAdMidpoint               = VideoPlayer_OnAdMidpoint
    this.OnAdThirdQuartile          = VideoPlayer_OnAdThirdQuartile
    this.OnAdPositionNotification   = VideoPlayer_OnAdPositionNotification
    this.OnAdComplete               = VideoPlayer_OnAdComplete
    this.OnAdClose                  = VideoPlayer_OnAdClose
            
    this.Screen                     = NewVideoScreen()
    this.Screen.SetPositionNotificationPeriod(1)

    this.Screen.GetEventPort().RegisterObserver(this, "GetMessage", "OnGetMessage")
    
    this.Screen.RegisterObserver(this, "BeforeNewContent", "OnBeforeNewContent")
    this.Screen.RegisterObserver(this, "Start", "OnStart")
    this.Screen.RegisterObserver(this, "FirstQuartile", "OnFirstQuartile")
    this.Screen.RegisterObserver(this, "Midpoint", "OnMidpoint")
    this.Screen.RegisterObserver(this, "ThirdQuartile", "OnThirdQuartile")
    this.Screen.RegisterObserver(this, "Complete", "OnComplete")
    this.Screen.RegisterObserver(this, "Close", "OnClose")
    this.Screen.RegisterObserver(this, "PositionNotification", "OnPositionNotification")
    this.Screen.RegisterObserver(this, "Pause", "OnPause")
    this.Screen.RegisterObserver(this, "Resume", "OnResume")
    this.Screen.RegisterObserver(this, "Skip", "OnSkip")
    this.Screen.RegisterObserver(this, "Error", "OnError")
    this.Screen.RegisterObserver(this, "Disposed", "OnDisposed")
    
    EventListener().RegisterObserver(this, "Idle", "OnIdle")
    
    Return this
End Function

Function VideoPlayer_Play(episodeOrChannel As Object, resume = False As Boolean) As Boolean
    m.Canvas.SetLayer(0, { Color: "#000000" })
    m.Canvas.Show()
    
    m.IsResume = resume
    m.Content = episodeOrChannel
    m.Position = 0
    m.AdCount = 0
    
    If m.Content.ClassName = "Episode" Then
        ' Refresh the content to ensure the user still has permission to view it
        m.Content.Refresh()
        Cbs().GetCurrentUser().AddToRecentlyWatched(m.Content)
    End If
    
    ' Configure StreamSense params
    m.StreamSenseParams = {
        ns_st_ci: m.Content.ContentID
        c2: "3002231"
        c3: "3000008"
        c4: "CBS.com Roku"
        c6: m.Content.TrackingTitle + "--" + "S" + PadLeft(AsString(m.Content.SeasonNumber), "0", 2) + "E" + PadLeft(AsString(m.Content.EpisodeNumber), "0", 2)
    }
    
    ' Initialize Akamai
    m.InitAkamai()
    
    ' Get the stream
    stream = m.Content.GetStream(resume)
    If stream <> invalid Then
        m.PlayerID = MD5Hash(GetDeviceID() + AsString(NowDate().AsSeconds()))
        DW().PlayerInit(m.PlayerID)
        
        If m.Content.ClassName = "Episode" Then
            Omniture().TrackPage("app:roku:video player")
        Else If m.Content.ClassName = "Channel" Or m.Content.ClassName = "LiveFeed" Then
            Omniture().TrackPage("app:roku:live:video player")
        End If

        m.Screen.EnableTrickPlay(stream.Live <> True)
        m.Screen.SetContent(stream)
        m.Screen.Show()
        Return True
    Else
        If Cbs().GetCurrentUser().Status = "SUSPENDED" Then
            ShowMessageBox("Error", "An error occurred when attempting to play this video. Please contact customer support for assistance at (877) 749-9863.", ["OK"], True)
        Else
            ShowMessageBox("Content Unavailable", "The content you are trying to play is currently unavailable. Please try again later.", ["OK"], True)
        End If
    End If
    m.Canvas.Close()
    Return False
End Function

Function VideoPlayer_PlayAd(adPods As Object, resumePosition As Integer, stream As Object) As Boolean
    m.Content.SetResumePoint(resumePosition)
    
    m.Screen.Close(True)
    ' Let comScore know we're stopping playback
    m.StreamSense.Stop()

    ' Let comScore know we're playing an ad
    m.StreamSense.PlayAdvertisement()

    If m.Raf.showAds(adPods)
        stream.PlayStart = resumePosition
        ' Set the resuming after ad flag, so we don't track the start event again
        m.ResumingAfterAd = True
        m.Screen.SetContent(stream)
        m.Screen.Show()
        Return True
    Else
        ' The user exited the ad, so call the close event, and dispose the screen
        m.OnClose(invalid, invalid)
        m.Screen.Dispose()
        Return False
    End If
End Function

Function VideoPlayer_GetPlayerPosition(includeAds = False As Boolean) As Integer
    position = m.Position
    If includeAds
        position = position + m.playedAdDuration
    End If
    Return position
End Function

Sub VideoPlayer_InitAkamai()
    ' Configure Akamai
    config = {
        configXML:          Cbs().AkamaiUrl
        customDimensions:   m.Content.GetAkamaiDims(Cbs().AkamaiDims)
    }
    m.Akamai.pluginMain(config)
    m.Akamai.setViewerDiagnosticId(Cbs().GetCurrentUser().ID)
End Sub

Function VideoPlayer_OnGetMessage(eventData As Object, callbackData As Object) As Object
    msg = invalid
    If eventData.Timeout = -1 Then
        msg = eventData.Port.GetMessage()
    Else
        msg = Wait(eventData.Timeout, eventData.Port)
    End If
    
    If type(msg) = "roVideoScreenEvent"
        m.lastVideoScreenEvent = msg ' used by Raf
    End If
    m.Akamai.pluginEventHandler(msg)
    m.StreamSense.Tick()
    Return msg
End Function

Function VideoPlayer_OnBeforeNewContent(eventData As Object, callbackData As Object) As Boolean
    stream = eventData.Item
    response = GetUrlToStringEx(stream.Stream.Url)
    If response <> invalid Then
        cookies = ""
        For Each header In response.ResponseHeadersArray
            If header["Set-Cookie"] <> invalid Then
                cookies = cookies + header["Set-Cookie"] + ", "
            End If
        Next
        m.Screen.SetCookies(cookies)
    End If
    If AsInteger(stream.PlayStart) > 0 And stream.Live <> True Then
        m.Position = stream.PlayStart
    End If
    If m.Vmap = invalid And Not IsNullOrEmpty(stream.VmapUrl) Then
        vmapUrl = Replace(stream.VmapUrl, "[timestamp]", NowDate().AsSeconds().ToStr())
        vmapUrl = AddQueryString(vmapUrl, "ppid", AsString(Cbs().GetCurrentUser().Ppid))
        
        customParams = "sb=" + AsString(Cbs().GetCurrentUser().GetStatusForAds())
        cbsU = GetCookie("CBS_U")
        If Not IsNullOrEmpty(cbsU) Then
            ' Convert "ge:1|gr:2" to ge=1&gr=2
            customParams = customParams + "&" + cbsU.Replace(":", "=").Replace("|", "&").Replace(Chr(34), "")
        End If
        customParams = customParams + "&ppid=" + AsString(Cbs().GetCurrentUser().Ppid)
        vmapUrl = AddQueryString(vmapUrl, "cust_params", customParams)
        
        m.bShowAds = true
        ConfigureRaf(m.Raf, vmapUrl, m)
        secondsSinceLastPlay = NowDate().AsSeconds() - PlayTimes().GetPlayTime(m.Content.ID)
        If secondsSinceLastPlay > 3600 Then
            ' It's been more than an hour, so play the preroll
            adPods = m.Raf.getAds()
            If adPods <> invalid and adPods.Count() > 0
                ' Let comScore know we're playing an ad
                m.StreamSense.PlayAdvertisement()
                
                If Not m.Raf.showAds(adPods)
                    ' The user exited the ad, so call the close event, and return false
                    m.OnClose(invalid, invalid)
                    Return False
                End If
            End If
        End If
    End If
    ' Record the play time
    PlayTimes().SetPlayTime(m.Content.ID)
    Return True
End Function

Sub VideoPlayer_OnStart(eventData As Object, callbackData As Object)
    ' Let comScore know we're starting playback
    m.StreamSense.PlayContentPart(m.StreamSenseParams)
    
    If Not m.ResumingAfterAd Then
        If m.Content.ClassName = "Episode" Then
            DW().PlayerStart(m.Content, m.GetPlayerPosition(True))
            
            params = {}
            params.v25 = m.Content.Title
            params.v31 = m.Content.MediaID
            params.v32 = "cbs_roku_app|can"
            params.v38 = "video"
            params.v59 = IIf(m.Content.SubscriptionLevel = "FREE", "non-svod", "svod")
            Omniture().TrackEvent("app:roku:video playback:episode " + IIf(m.IsResume, "resume", "start"), [IIf(m.IsResume, "event19", "event52")], params)
        Else If m.Content.ClassName = "Channel" Or m.Content.ClassName = "LiveFeed" Then
            DW().PlayerLiveStart(m.Content, m.GetPlayerPosition(True))
            
            params = {}
            params.v25 = m.Content.TrackingTitle
            params.v31 = m.Content.MediaID
            params.v32 = "cbs_roku_app|can"
            params.v38 = "live"
            Omniture().TrackEvent("app:roku:live:feed:start", ["event52"], params)
        End If
    Else
        ' We need to re-init akamai after resuming from an ad
        m.InitAkamai()
    End If
    m.ResumingAfterAd = False
End Sub

Sub VideoPlayer_OnFirstQuartile(eventData As Object, callbackData As Object)
    ?eventData
End Sub

Sub VideoPlayer_OnMidpoint(eventData As Object, callbackData As Object)
    ?eventData
End Sub

Sub VideoPlayer_OnThirdQuartile(eventData As Object, callbackData As Object)
    ?eventData
End Sub

Sub VideoPlayer_OnComplete(eventData As Object, callbackData As Object)
    If m.Content.ClassName = "Episode" Then
        ' Set the position to the content length, so tracking is accurate
        m.Position = m.Content.Length
        DW().PlayerEnd(m.Content, m.GetPlayerPosition(True), m.GetPlayerPosition(False))
            
        params = {}
        params.v25 = m.Content.Title
        params.v31 = m.Content.MediaID
        params.v32 = "cbs_roku_app|can"
        params.v38 = "video"
        params.v59 = IIf(m.Content.SubscriptionLevel = "FREE", "non-svod", "svod")
        Omniture().TrackEvent("app:roku:video playback:episode complete", ["event60"], params)

        ' Track the resume point to avoid invalid resume messaging
        m.Content.SetResumePoint(m.GetPlayerPosition(False))
        DW().PlayerPlayPosition(m.Content, m.GetPlayerPosition(False))
    Else If m.Content.ClassName = "Channel" Or m.Content.ClassName = "LiveFeed" Then
        DW().PlayerLiveEnd(m.Content, m.GetPlayerPosition(True), m.GetPlayerPosition(False))
    End If
    If m.bShowAds
        adPods = m.Raf.getAds(m.lastVideoScreenEvent)
        If adPods <> invalid and adPods.Count() > 0
            ' Let comScore know we're playing an ad
            m.StreamSense.PlayAdvertisement()
    
            m.Raf.showAds(adPods)
        End If
    End If
End Sub

Sub VideoPlayer_OnClose(eventData As Object, callbackData As Object)
    If m.Content.ClassName = "Episode" Then
        If eventData <> invalid Then
            ' Track the resume point
            m.Content.SetResumePoint(m.GetPlayerPosition(False))
            DW().PlayerPlayPosition(m.Content, m.GetPlayerPosition(False))
        End If

        DW().PlayerStop(m.Content, m.GetPlayerPosition(True), m.GetPlayerPosition(False))
    Else If m.Content.ClassName = "Channel" Or m.Content.ClassName = "LiveFeed" Then
        If m.LiveTimedOut = True Then
            DW().PlayerLiveForcedEnd("forcedend", m.Content, m.GetPlayerPosition(True), m.GetPlayerPosition(False))
        Else
            DW().PlayerLiveStop(m.Content, m.GetPlayerPosition(True), m.GetPlayerPosition(False))
        End If
    End If
End Sub

Sub VideoPlayer_OnPositionNotification(eventData As Object, callbackData As Object)
    m.Position = eventData.Position
    ' The logic for sending play events is built into the DW class
    If m.Content.ClassName = "Episode" Then
        DW().PlayerPlay(m.Content, m.GetPlayerPosition(True), m.GetPlayerPosition(False))
    Else If m.Content.ClassName = "Channel" Or m.Content.ClassName = "LiveFeed" Then
        DW().PlayerLivePlay(m.Content, m.GetPlayerPosition(True), m.GetPlayerPosition(False))
    End If
    ' Track the playhead position for resumes
    If eventData.Position > 0 And eventData.Position Mod 10 = 0 Then
        DebugPrint(eventData.Position, "Track playhead", 2)
        If m.Content.ClassName = "Episode" Then
            m.Content.SetResumePoint(m.GetPlayerPosition(False))
            DW().PlayerPlayPosition(m.Content, m.GetPlayerPosition(False))
        Else If m.Content.ClassName = "Channel" Or m.Content.ClassName = "LiveFeed" Then
            DW().PlayerLivePlayPosition(m.Content, m.GetPlayerPosition(False))
        End If
    End If
    If m.bShowAds
        ' Check for an ad
        adPosition = eventData.Position + m.AdPositionOffset
        adPods = m.Raf.getAds(m.lastVideoScreenEvent)
        If adPods <> invalid and adPods.Count() > 0
            If m.Content.ClassName = "Episode" Then
                ' Track the resume point
                m.Content.SetResumePoint(m.GetPlayerPosition(False))
                DW().PlayerPlayPosition(m.Content, m.GetPlayerPosition(False))
            End If
            m.PlayAd(adPods, m.Position, eventData.Item)
        End If
    End If
    ' Record the play time
    PlayTimes().SetPlayTime(m.Content.ID)
End Sub

Sub VideoPlayer_OnPause(eventData As Object, callbackData As Object)
    m.PauseTimer.Mark()
    If m.Content.ClassName = "Episode" Then
        DW().PlayerPause(m.Content, m.GetPlayerPosition(True), m.GetPlayerPosition(False)) 
    
        ' Track the resume point
        m.Content.SetResumePoint(m.GetPlayerPosition(False))
        DW().PlayerPlayPosition(m.Content, m.GetPlayerPosition(False))
    End If
    ' Let comScore know we've stopping playback
    m.StreamSense.Stop()
End Sub

Sub VideoPlayer_OnResume(eventData As Object, callbackData As Object)
    If m.Content.ClassName = "Episode" Then
        DW().PlayerUnpause(m.PauseTimer.TotalSeconds(), m.Content, m.GetPlayerPosition(True), m.GetPlayerPosition(False))
    End If

    ' Let comScore know we've resumed playback
    m.StreamSense.PlayContentPart(m.StreamSenseParams)
End Sub

Sub VideoPlayer_OnSkip(eventData As Object, callbackData As Object)
    ' Let comScore know we're resumed playback
    m.StreamSense.PlayContentPart(m.StreamSenseParams)

    ' Update the stored position to the new position
    m.Position = eventData.Position
    If eventData.OldPosition < eventData.Position Then
        DW().PlayerForward(eventData.Position - eventData.OldPosition, m.Content, m.GetPlayerPosition(True), m.GetPlayerPosition(False)) 
    Else If eventData.OldPosition > eventData.Position Then
        DW().PlayerRewind(eventData.OldPosition - eventData.Position, m.Content, m.GetPlayerPosition(True), m.GetPlayerPosition(False)) 
    End If
    If m.bShowAds
        adPods = m.Raf.getAds(m.lastVideoScreenEvent)
        If adPods <> invalid and adPods.Count() > 0
            m.PlayAd(adPods, m.Position, eventData.Item)
        End If
    End If
End Sub

Sub VideoPlayer_OnError(eventData As Object, callbackData As Object)
    If m.Content.ClassName = "Episode" Then
        DW().PlayerError(eventData.Message, m.Content, m.GetPlayerPosition(True), m.GetPlayerPosition(False))
            
        params = {}
        params.v25 = m.Content.Title
        params.v31 = m.Content.MediaID
        params.v32 = "cbs_roku_app|can"
        params.v38 = "video"
        params.v59 = IIf(m.Content.SubscriptionLevel = "FREE", "non-svod", "svod")
        params.v70 = AsString(eventData.Code)
        Omniture().TrackEvent("app:roku:video playback:" + AsString(eventData.Code) + ":" + LCase(AsString(eventData.Message)), ["event85"], params)
    Else If m.Content.ClassName = "Channel" Or m.Content.ClassName = "LiveFeed" Then
        DW().PlayerLiveError(eventData.Message, m.Content, m.GetPlayerPosition(True), m.GetPlayerPosition(False))

        params = {}
        params.v25 = m.Content.TrackingTitle
        params.v31 = m.Content.MediaID
        params.v32 = "cbs_roku_app|can"
        params.v38 = "live"
        params.v70 = AsString(eventData.Code)
        Omniture().TrackEvent("app:roku:live:feed:" + AsString(eventData.Code) + ":" + LCase(AsString(eventData.Message)), ["event85"], params)
    End If
    ShowMessageBox("Error", "Unfortunately, an error occurred during playback. Please try again.", ["OK"], True)
End Sub

Function VideoPlayer_OnDisposed(eventData As Object, callbackData As Object) As Boolean
    ' Let comScore know we've stopping playback
    m.StreamSense.Stop()

    EventListener().UnregisterObserver(m, "Idle")
    If m.Screen <> invalid Then
        m.Screen.GetEventPort().UnregisterObserverForAllEvents(m)
        m.Screen.UnregisterObserverForAllEvents(m)
        m.Screen = invalid   
    End If 
    m.Canvas.Close()

    ' Exit the event loop if this is the last screen
    Return ScreenManager().Screens.Count() > 0
End Function

Sub VideoPlayer_OnIdle(eventData As Object, callbackData As Object)
    If (m.Content.ClassName = "Channel" Or m.Content.ClassName = "LiveFeed") And eventData.UserIdleTime >= m.LiveTimeout Then
        m.Screen.Pause()
        DW().PlayerLiveForcedEnd("prompt", m.Content, m.GetPlayerPosition(True), m.GetPlayerPosition(False))
        result = ShowMessageBoxWithTimeout("Are you still watching?", "", m.LiveCTATimeout, ["Continue watching"], True)
        If result = "Continue watching" Then
            DW().PlayerLiveForcedEnd("resume", m.Content, m.GetPlayerPosition(True), m.GetPlayerPosition(False))
            m.Screen.Resume()
        Else
            m.LiveTimedOut = True
            m.Screen.Close()
        End If
    End If
End Sub

Function GetAkamaiAdParams(ad As Object, position As Integer) As Object
    Return {
        adId:           AsString(ad.adId)
        startPos:       AsString(position)
        adDuration:     AsString(ad.duration)
        adTitle:        AsString(ad.adTitle)
        headPosition:   position
    }
End Function

Sub VideoPlayer_OnAdStart(eventData As Object)
    m.AdCount = m.AdCount + 1
    DW().PlayerAdStart(eventData.Ad, eventData.PodIndex + 1, eventData.AdIndex, m.AdCount, m.Content, m.GetPlayerPosition(True), m.GetPlayerPosition(False))
    
    ad = eventData.Ad
    ' TODO: Currently Akamai only supports pre-rolls
    If m.Position = 0 And ad <> invalid Then
        m.Akamai.handleAdLoaded(GetAkamaiAdParams(ad, m.GetPlayerPosition(False) - m.AdPositionOffset))
        m.Akamai.handleAdStarted(GetAkamaiAdParams(ad, m.GetPlayerPosition(False) - m.AdPositionOffset))
    End If
End Sub

Sub VideoPlayer_OnAdFirstQuartile(eventData As Object)
    ad = eventData.Ad
    ' TODO: Currently Akamai only supports pre-rolls
    If m.Position = 0 And ad <> invalid Then
        m.Akamai.handleAdFirstQuartile(GetAkamaiAdParams(ad, m.GetPlayerPosition(False) - m.AdPositionOffset))
    End If
End Sub

Sub VideoPlayer_OnAdMidpoint(eventData As Object)
    ad = eventData.Ad
    ' TODO: Currently Akamai only supports pre-rolls
    If m.Position = 0 And ad <> invalid Then
        m.Akamai.handleAdMidpoint(GetAkamaiAdParams(ad, m.GetPlayerPosition(False) - m.AdPositionOffset))
    End If
End Sub

Sub VideoPlayer_OnAdThirdQuartile(eventData As Object)
    ad = eventData.Ad
    ' TODO: Currently Akamai only supports pre-rolls
    If m.Position = 0 And ad <> invalid Then
        m.Akamai.handleAdThirdQuartile(GetAkamaiAdParams(ad, m.GetPlayerPosition(False) - m.AdPositionOffset))
    End If
End Sub

Sub VideoPlayer_OnAdPositionNotification(eventData As Object)
    DW().PlayerAdPlay(eventData.Ad, eventData.Position, eventData.PodIndex + 1, eventData.AdIndex, m.AdCount, m.Content, m.GetPlayerPosition(True), m.GetPlayerPosition(False))
End Sub

Sub VideoPlayer_OnAdComplete(eventData As Object)
    ad = eventData.Ad
    DW().PlayerAdEnd(ad, AsInteger(ad.Duration) - 1, eventData.PodIndex + 1, eventData.AdIndex, m.AdCount, m.Content, m.GetPlayerPosition(True), m.GetPlayerPosition(False))
    
    ' TODO: Currently Akamai only supports pre-rolls
    If m.Position = 0 And ad <> invalid Then
        m.Akamai.handleAdComplete(GetAkamaiAdParams(ad, m.GetPlayerPosition(False) - m.AdPositionOffset))
        m.Akamai.handleAdEnd(GetAkamaiAdParams(ad, m.GetPlayerPosition(False) - m.AdPositionOffset), m.GetPlayerPosition(False))
    End If
End Sub

Sub VideoPlayer_OnAdClose(eventData As Object)
    ad = eventData.Ad
    ' TODO: Currently Akamai only supports pre-rolls
    If m.Position = 0 And ad <> invalid Then
        m.Akamai.handleAdStopped(GetAkamaiAdParams(ad, m.GetPlayerPosition(False) - m.AdPositionOffset), m.GetPlayerPosition(False))
    End If
End Sub


Sub RafCallback(videoPlayer = invalid As Dynamic, eventType = invalid As Dynamic, ctx = invalid As Dynamic)
    If not IsAssociativeArray(videoPlayer) then return
    
    eventData = RafGetEventData(ctx)
    If not IsAssociativeArray(eventData) then return
    
    eventType = LCase(AsString(eventType))
    
    If eventType = "start"
        videoPlayer.OnAdStart(eventData)
    Else If eventType = "firstquartile"
        videoPlayer.OnAdFirstQuartile(eventData)
    Else If eventType = "midpoint"
        videoPlayer.OnAdMidpoint(eventData)
    Else If eventType = "thirdquartile"
        videoPlayer.OnAdThirdQuartile(eventData)
    Else If eventType.Len() = 0 and IsAssociativeArray(ctx) and ctx.time <> invalid ' position notification
        videoPlayer.OnAdPositionNotification(eventData)
    Else If eventType = "complete"
        If IsInteger(videoPlayer.playedAdDuration) and IsInteger(eventData.ad.duration)
            videoPlayer.playedAdDuration = videoPlayer.playedAdDuration + eventData.ad.Duration
        End If
        videoPlayer.OnAdComplete(eventData)
    Else If eventType = "close"
        videoPlayer.OnAdClose(eventData)
    End If
End Sub


Function RafGetEventData(ctx As Object) as Object
    If not IsAssociativeArray(ctx) or not IsAssociativeArray(ctx.ad) then return invalid
    
    eventData = {
        PodIndex    : AsInteger(0) 'TODO replace once podIndex is available
        AdIndex     : AsInteger(ctx.adIndex)
        Position    : AsInteger(ctx.time)
    }
    
    ad = ctx.ad
    
    ' make it compatible with DW analytics naming
    ad.length = AsInteger(ad.duration)
    ad.title = AsString(ad.adTitle)
    
    eventData.ad = ad
    
    return eventData
End Function


sub ConfigureRaf(raf as Object, adUrl as String, videoPlayer as Object, bUseNielsen = true as Boolean)
    if not IsAssociativeArray(raf) then return
    
    episode = videoPlayer.content
    raf.setAdUrl(adUrl)
    raf.setContentId(AsString(episode.contentId))
    raf.setContentGenre("General Variety")
    raf.setContentLength(AsInteger(episode.length)) ' seconds
    raf.setTrackingCallback(RafCallback, videoPlayer)
    
    if bUseNielsen
        ConfigureEpisodeForNielsen(episode)
        raf.enableNielsenDAR(true)
        raf.setNielsenProgramId(AsString(episode.nielsenID)) ' a human readable designation of the show or category this content belongs to
        raf.setNielsenGenre(episode.genreNielsen) ' in most cases this will be the same for all content in a channel
        if IsString(Cbs().nielsenAppID)
            raf.setNielsenAppId(Cbs().nielsenAppID) ' assigned by Nielsen
        end if
    end if
end sub


sub ConfigureEpisodeForNielsen(episode as Object)
    if not IsAssociativeArray(episode) then return
    
    episode.genreNielsen = "GV"
    if IsString(episode.showName)
        episode.nielsenID = episode.showName
    else
        episode.nielsenID = "CBAA"
    end if
    
    if not IsValid(episode.length)
        episode.length = 1
    end if
end sub