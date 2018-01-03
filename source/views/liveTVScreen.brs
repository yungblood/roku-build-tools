Function NewLiveTVScreen() As Object
    this                            = {}
    this.ClassName                  = "LiveTVScreen"
    
    this.Channel                    = invalid
    
    this.RefreshTimer               = CreateObject("roTimespan")
    this.RefreshTime                = 15000
    
    this.Show                       = LiveTVScreen_Show
    this.SetChannel                 = LiveTVScreen_SetChannel
    this.GetContent                 = LiveTVScreen_GetContent
    this.ResetContent               = LiveTVScreen_ResetContent
    this.StartPlayback              = LiveTVScreen_StartPlayback
    
    this.OnShown                    = LiveTVScreen_OnShown
    this.OnHidden                   = LiveTVScreen_OnHidden
    this.OnButtonPressed            = LiveTVScreen_OnButtonPressed
    this.OnRemoteKeyPressed         = LiveTVScreen_OnRemoteKeyPressed
    this.OnDisposed                 = LiveTVScreen_OnDisposed
    this.OnIdle                     = LiveTVScreen_OnIdle

    this.Screen                     = NewSpringboardScreen()
    this.Screen.UseStableFocus(True)
    this.Screen.SetStaticRatingEnabled(False)
    this.Screen.SetPosterStyle("rounded-rect-16x9-generic")
    this.Screen.SetDisplayMode("photo-fit")

    this.Screen.RegisterObserver(this, "Shown", "OnShown")
    this.Screen.RegisterObserver(this, "Hidden", "OnHidden")
    this.Screen.RegisterObserver(this, "ButtonPressed", "OnButtonPressed")
    this.Screen.RegisterObserver(this, "RemoteKeyPressed", "OnRemoteKeyPressed")
    this.Screen.RegisterObserver(this, "Disposed", "OnDisposed")
    EventListener().RegisterObserver(this, "Idle", "OnIdle")

    Return this
End Function

Function LiveTVScreen_Show(channel = invalid As Object, autoPlay = False As Boolean) As Boolean
    m.PreviousOverhangHD = GetThemeAttribute("OverhangPrimaryLogoHD")
    m.PreviousOverhangSD = GetThemeAttribute("OverhangPrimaryLogoSD")
    SetThemeAttribute("OverhangPrimaryLogoHD", "")
    SetThemeAttribute("OverhangPrimaryLogoSD", "")

    If channel <> invalid Then
        m.SetChannel(channel)
    End If
    m.ResetContent()
    m.Screen.Show()
    If autoPlay And Cbs().IsSubscribed() Then
        m.StartPlayback()
    End If
    Return True
End Function

Sub LiveTVScreen_SetChannel(channel As Object)
    m.Channel = channel
    m.Screen.SetBreadcrumbText(m.Channel.FullName)
End Sub

Function LiveTVScreen_GetContent(showLoading = True As Boolean) As Object
    content = invalid
    If m.Channel <> invalid Then
        If showLoading Then
            m.Screen.SetButtons(["Loading..."])
        End If

        ' Get now playing data
        content = m.Channel.GetNowPlaying()
        If content <> invalid Then
            content.HDPosterUrl = m.Channel.HDPosterUrl
            content.SDPosterUrl = m.Channel.SDPosterUrl
            content.Actors = [GetTimeString(content.StartTime) + " | LIVE NOW"]
        Else
            content = {}
        End If
        buttons = []
        If Cbs().IsSubscribed() Then
            buttons.Push({
                Text: "Watch"
                ID: "watch"
            })
        Else
            buttons.Push({
                Text: "Subscribe to watch"
                ID: "subscribe"
                OmnitureData:   {
                    LinkName: "app:roku:all access:upsell:Limited Commercial:live-tv:click"
                    Params: {  
                        v10: "livetv_upsell"
                        v4: "CIA-00-10abc6f"
                    }
                    Events: ["event19"]
                }
            })
        End If
        content.Buttons = buttons
    End If
    Return content
End Function

Sub LiveTVScreen_ResetContent(showLoading = True As Boolean)
    content = m.GetContent(showLoading)
    If content <> invalid Then
        m.Screen.SetContent(content)
        m.Screen.SetButtons(content.Buttons)
    End If
End Sub

Sub LiveTVScreen_StartPlayback()
    If Cbs().IsOverStreamLimit() Then
        Omniture().TrackPage("app:roku:settings:concurrent stream limit")
        ShowMessageBox("Concurrent Streams Limit", "You've reached the maximum number of simultaneous video streams for your account. To view this video, close the other videos you're watching and try again.", ["OK"], True)
    Else
        NewVideoPlayer().Play(m.Channel)
    End If
End Sub

Sub LiveTVScreen_OnShown(eventData As Object, callbackData = invalid As Object)
    Omniture().TrackPage("app:roku:live-tv")
    m.ResetContent()
End Sub

Sub LiveTVScreen_OnHidden(eventData As Object, callbackData = invalid As Object)
End Sub

Sub LiveTVScreen_OnButtonPressed(eventData As Object, callbackData = invalid As Object)
    If eventData.Button <> invalid And Not IsString(eventData.Button) Then
        linkName = "app:roku:live-tv:" + LCase(AsString(eventData.Button.Text))
        Omniture().TrackEvent(linkName, ["event19"], { v46: linkName })

        If eventData.Button.ID = "watch" Or eventData.Button.ID = "subscribe" Then
            If eventData.Button.OmnitureData <> invalid Then
                linkName = eventData.Button.OmnitureData.LinkName
                events = eventData.Button.OmnitureData.Events
                params = eventData.Button.OmnitureData.Params
                Omniture().TrackEvent(linkName, events, params)
            End If

            playContent = True
            If eventData.Button.ID = "subscribe" Then
                If Cbs().IsCFFlowEnabled Then
                    playContent = NewRegistrationWizard().ShowLiveTVUpsellScreen()
                Else
                    playContent = (NewRegistrationWizard().Show() = 1)
                End If
                If playContent Then
                    playContent = Cbs().GetCurrentUser().IsSubscriber()
                End If
            End If
            If playContent Then
                m.StartPlayback()
            End If
        End If
    End If
End Sub

Sub LiveTVScreen_OnRemoteKeyPressed(eventData As Object, callbackData = invalid As Object)
    If eventData.RemoteKey = 10 Then        ' Options
        ShowOptionsDialog()
    Else If eventData.RemoteKey = 13 Then   ' Play
    End If
End Sub

Function LiveTVScreen_OnDisposed(eventData As Object, callbackData = invalid As Object)
    EventListener().UnregisterObserver(m, "Idle")
    m.Screen.UnregisterObserverForAllEvents(m)
    m.Screen = invalid

    Return True
End Function

Function LiveTVScreen_OnIdle(eventData As Object, callbackData = invalid As Object)
    If m.RefreshTimer.TotalMilliseconds() >= m.RefreshTime Then
        m.ResetContent(False)
        m.RefreshTimer.Mark()
    End If
End Function


