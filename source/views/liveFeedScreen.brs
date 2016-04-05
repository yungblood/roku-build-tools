Function NewLiveFeedScreen() As Object
    this                            = {}
    this.ClassName                  = "LiveFeedScreen"
    
    this.Row                        = { ContentList: [] }
    this.ItemIndex                  = 0
    
    this.RefreshTimer               = CreateObject("roTimespan")
    this.RefreshTime                = 15000
    
    this.Show                       = LiveFeedScreen_Show
    this.GetContent                 = LiveFeedScreen_GetContent
    this.ResetContent               = LiveFeedScreen_ResetContent
    this.StartPlayback              = LiveFeedScreen_StartPlayback
    
    this.OnShown                    = LiveFeedScreen_OnShown
    this.OnHidden                   = LiveFeedScreen_OnHidden
    this.OnButtonPressed            = LiveFeedScreen_OnButtonPressed
    this.OnRemoteKeyPressed         = LiveFeedScreen_OnRemoteKeyPressed
    this.OnDisposed                 = LiveFeedScreen_OnDisposed

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

    Return this
End Function

Function LiveFeedScreen_Show(row As Object, index = 0 As Integer, autoPlay = False As Boolean) As Boolean
    m.PreviousOverhangHD = GetThemeAttribute("OverhangPrimaryLogoHD")
    m.PreviousOverhangSD = GetThemeAttribute("OverhangPrimaryLogoSD")
    
    m.Row = row
    m.ItemIndex = index
    
    m.ResetContent()
    m.Screen.Show()

    If autoPlay And Cbs().IsSubscribed() Then
        m.StartPlayback()
    End If

    Return True
End Function

Function LiveFeedScreen_GetContent(showLoading = True As Boolean) As Object
    content = m.Row.ContentList[m.ItemIndex]
    If content <> invalid Then
        If showLoading Then
            m.Screen.SetButtons(["Loading..."])
        End If
        content = ShallowCopy(content)
        content.Actors = ["Big Brother Live Feeds"]
        buttons = []
        If Cbs().IsAuthenticated() Then
            buttons.Push({
                Text: "Watch"
                ID: "watch"
            })
        Else
            buttons.Push({
                Text: "Subscribe to watch"
                ID: "subscribe"
            })
        End If
        content.Buttons = buttons
    End If
    Return content
End Function

Sub LiveFeedScreen_ResetContent(showLoading = True As Boolean)
    content = m.GetContent(showLoading)
    If content <> invalid Then
        ' Update the row's selected index
        m.Row.SelectedIndex = m.ItemIndex

        overhangHD = ""
        overhangSD = ""
        If content <> invalid Then
            show = content.GetShow()
            If show <> invalid Then
                overhangHD = show.OverhangHD
                overhangSD = show.OverhangSD
            End If
        End If
        SetThemeAttribute("OverhangPrimaryLogoHD", overhangHD)
        SetThemeAttribute("OverhangPrimaryLogoSD", overhangSD)

        m.Screen.SetContent(content)
        m.Screen.SetButtons(content.Buttons)
    End If
End Sub

Sub LiveFeedScreen_StartPlayback()
    If Cbs().IsOverStreamLimit() Then
        Omniture().TrackPage("app:roku:settings:concurrent stream limit")
        ShowMessageBox("Concurrent Streams Limit", "You've reached the maximum number of simultaneous video streams for your account. To view this video, close the other videos you're watching and try again.", ["OK"], True)
    Else
        NewVideoPlayer().Play(m.GetContent(False))
    End If
End Sub

Sub LiveFeedScreen_OnShown(eventData As Object, callbackData = invalid As Object)
    Omniture().TrackPage("app:roku:live:bblf:" + LCase(AsString(m.GetContent(False).Title)))
    m.ResetContent()
End Sub

Sub LiveFeedScreen_OnHidden(eventData As Object, callbackData = invalid As Object)
End Sub

Sub LiveFeedScreen_OnButtonPressed(eventData As Object, callbackData = invalid As Object)
    If eventData.Button <> invalid And Not IsString(eventData.Button) Then
        linkName = "app:roku:live:bblf:" + LCase(AsString(m.GetContent(False).Title)) + ":" + LCase(AsString(eventData.Button.Text))
        Omniture().TrackEvent(linkName, ["event19"], { v46: linkName })

        If eventData.Button.ID = "watch" Or eventData.Button.ID = "subscribe" Then
            playContent = True
            If eventData.Button.ID = "subscribe" Then
                playContent = (NewRegistrationWizard().Show() = 1)
            End If
            If playContent Then
                m.StartPlayback()
            End If
        End If
    End If
End Sub

Sub LiveFeedScreen_OnRemoteKeyPressed(eventData As Object, callbackData = invalid As Object)
    If eventData.RemoteKey = 10 Then        ' Options
        ShowOptionsDialog()
    Else If eventData.RemoteKey = 13 Then   ' Play
    Else If eventData.RemoteKey = 4 Then    ' Left
        If m.ItemIndex > 0 Then
            m.ItemIndex = m.ItemIndex - 1
            m.ResetContent()
        End If
    Else If eventData.RemoteKey = 5 Then    ' Right
        If m.Row <> invalid And m.ItemIndex < m.Row.ContentList.Count() - 1 Then
            m.ItemIndex = m.ItemIndex + 1
            m.ResetContent()
        End If
    End If
End Sub

Function LiveFeedScreen_OnDisposed(eventData As Object, callbackData = invalid As Object)
    m.Screen.UnregisterObserverForAllEvents(m)
    m.Screen = invalid

    Return True
End Function


