Function NewEpisodeScreen() As Object
    this                            = {}
    this.ClassName                  = "EpisodeScreen"
    
    this.ContentList                = []
    this.ItemIndex                  = 0
    
    this.Show                       = EpisodeScreen_Show
    this.SetContentID               = EpisodeScreen_SetContentID
    this.SetContentList             = EpisodeScreen_SetContentList
    this.SetSection                 = EpisodeScreen_SetSection
    this.GetContent                 = EpisodeScreen_GetContent
    this.ResetContent               = EpisodeScreen_ResetContent
    
    this.PrepareContent             = EpisodeScreen_PrepareContent
    
    this.OnShown                    = EpisodeScreen_OnShown
    this.OnHidden                   = EpisodeScreen_OnHidden
    this.OnButtonPressed            = EpisodeScreen_OnButtonPressed
    this.OnRemoteKeyPressed         = EpisodeScreen_OnRemoteKeyPressed
    this.OnDisposed                 = EpisodeScreen_OnDisposed

    this.Screen                     = NewSpringboardScreen()
    this.Screen.UseStableFocus(True)
    this.Screen.SetStaticRatingEnabled(False)
    this.Screen.SetPosterStyle("rounded-rect-16x9-generic")

    this.Screen.RegisterObserver(this, "Shown", "OnShown")
    this.Screen.RegisterObserver(this, "Hidden", "OnHidden")
    this.Screen.RegisterObserver(this, "ButtonPressed", "OnButtonPressed")
    this.Screen.RegisterObserver(this, "RemoteKeyPressed", "OnRemoteKeyPressed")
    this.Screen.RegisterObserver(this, "Disposed", "OnDisposed")

    Return this
End Function

Function EpisodeScreen_Show() As Boolean
    m.PreviousOverhangHD = GetThemeAttribute("OverhangPrimaryLogoHD")
    m.PreviousOverhangSD = GetThemeAttribute("OverhangPrimaryLogoSD")

    m.Screen.Show()
    m.ResetContent(False)
    Return True
End Function

Sub EpisodeScreen_SetContentID(contentID As String)
    m.SetContentList(Cbs().GetEpisode(contentID))
End Sub

Sub EpisodeScreen_SetContentList(contentList As Object, index = 0 As Integer)
    ' Make a copy of the content, so it's not updated out from under us
    m.ContentList = ShallowCopy(AsArray(contentList))
    m.ItemIndex = index
End Sub

Sub EpisodeScreen_SetSection(section As Object, index = 0 As Integer)
    m.Section = section
    m.ItemIndex = index
End Sub

Function EpisodeScreen_GetContent(prepare = True As Boolean) As Object
    If m.Section <> invalid Then
        content = m.Section.GetVideo(m.ItemIndex)
    Else
        content = m.ContentList[m.ItemIndex]
    End If
    If prepare Then
        content = m.PrepareContent(content)
    End If
    Return content
End Function

Sub EpisodeScreen_ResetContent(forceThemeUpdate = True As Boolean)
    If m.Section <> invalid And Not m.Section.IsVideoLoaded(m.ItemIndex) Then
        ' This item isn't loaded, so show a loading button
        m.Screen.SetButtons(["Loading..."])
    End If
    content = m.GetContent()
    If content <> invalid Then
        m.Screen.SetContent(content)
        m.Screen.SetButtons(content.Buttons)

        show = content.GetShow()
        If show <> invalid And Not IsNullOrEmpty(show.OverhangHD) Then
            SetThemeAttribute("OverhangPrimaryLogoHD", show.OverhangHD)
            SetThemeAttribute("OverhangPrimaryLogoSD", show.OverhangSD)
            m.Screen.SetBreadcrumbText("")
        Else
            ClearThemeAttribute("OverhangPrimaryLogoHD")
            ClearThemeAttribute("OverhangPrimaryLogoSD")
            m.Screen.SetBreadcrumbText(content.ShowName)
        End If
        
        If forceThemeUpdate Then
            ' HACK: create a canvas, but don't show it to force a theme update
            canvas = CreateObject("roImageCanvas")
            canvas = invalid
        End If
    End If
End Sub

Function EpisodeScreen_PrepareContent(content As Object) As Object
    prepared = invalid
    If content <> invalid Then
        If Not content.IsShowLoaded() Or Cbs().IsAuthenticated() Then
            m.Screen.SetButtons(["Loading..."])
            ' Populate the show
            content.GetShow()
        End If

        prepared = ShallowCopy(content, 1)
        If content.SeasonNumber > 0 And content.EpisodeNumber > 0 Then
            prepared.Actors = [Substitute("Season {0} / Episode {1}", AsString(content.SeasonNumber), AsString(content.EpisodeNumber))]
        End If
        prepared.Delete("TitleSeason")
        
        buttons = []
        If Cbs().IsAuthenticated() Or (content.IsClip() And content.IsAvailable()) Then
            If content.GetResumePoint() > 0 And content.GetResumePoint() < content.Length - 10 Then
                buttons.Push({
                    Text: "Resume"
                    ID: "resume"
                })
                buttons.Push({
                    Text: "Watch from beginning"
                    ID: "watch"
                })
            Else
                buttons.Push({
                    Text: "Watch"
                    ID: "watch"
                })
            End If
        Else
            buttons.Push({
                Text: "Watch (Subscription Required)"
                ID: "subscribe"
            })
        End If
        If Cbs().IsAuthenticated() And prepared.ShowID <> "-1" Then
            If Cbs().GetCurrentUser().ShowIsInFavorites(prepared.ShowID) Then
                buttons.Push({
                    Text: "Remove show from My CBS"
                    ID: "removeFavorite"
                })
            Else
                buttons.Push({
                    Text: "Add show to My CBS"
                    ID: "addFavorite"
                })
            End If
        End If
        If content.IsFullEpisode() Then
            buttons.Push({
                Text: "See more episodes"
                ID: "show"
            })
        End If
        prepared.Buttons = buttons
    End If
    Return prepared
End Function

Sub EpisodeScreen_OnShown(eventData As Object, callbackData = invalid As Object)
    content = m.GetContent(False)
    Omniture().TrackPage("app:roku:" + IIf(content.IsFullEpisode(), "episode", "clip") + ":" + LCase(AsString(content.Title)))
    m.ResetContent()
End Sub

Sub EpisodeScreen_OnHidden(eventData As Object, callbackData = invalid As Object)
End Sub

Sub EpisodeScreen_OnButtonPressed(eventData As Object, callbackData = invalid As Object)
    If eventData.Button <> invalid And Not IsString(eventData.Button) Then
        content = m.GetContent(False)
        linkName = "app:roku:" + IIf(content.IsFullEpisode(), "episode", "clip") + ":" + LCase(AsString(content.Title)) + ":" + LCase(AsString(eventData.Button.Text))
        Omniture().TrackEvent(linkName, ["event19"], { v46: linkName })
        
        If eventData.Button.ID = "watch" Or eventData.Button.ID = "resume" Or eventData.Button.ID = "subscribe" Then
            playContent = True
            If eventData.Button.ID = "subscribe" Then
                playContent = (NewRegistrationWizard().Show() = 1)
            End If
            If playContent Then
                If Cbs().IsOverStreamLimit() Then
                    Omniture().TrackPage("app:roku:settings:concurrent stream limit")
                    ShowMessageBox("Concurrent Streams Limit", "You've reached the maximum number of simultaneous video streams for your account. To view this video, close the other videos you're watching and try again.", ["OK"], True)
                Else
                    NewVideoPlayer().Play(content, (eventData.Button.ID = "resume"))
                End If
            End If
        Else If eventData.Button.ID = "addFavorite" Then
            dialog = ShowWaitDialog("Adding show to My CBS...")
            Cbs().GetCurrentUser().AddShowToFavorites(content.ShowID)
            dialog.Close()
            m.ResetContent(False)
        Else If eventData.Button.ID = "removeFavorite" Then
            dialog = ShowWaitDialog("Removing show from My CBS...")
            Cbs().GetCurrentUser().RemoveShowFromFavorites(content.ShowID)
            dialog.Close()
            m.ResetContent(False)
        Else If eventData.Button.ID = "show" Then
            OpenItem(content.GetShow())
        End If
    End If
End Sub

Sub EpisodeScreen_OnRemoteKeyPressed(eventData As Object, callbackData = invalid As Object)
    If eventData.RemoteKey = 10 Then        ' Options
        ShowOptionsDialog()
    Else If eventData.RemoteKey = 13 Then   ' Play
    Else If eventData.RemoteKey = 4 Then    ' Left
        If m.ItemIndex > 0 Then
            m.ItemIndex = m.ItemIndex - 1
            m.ResetContent()
        End If
    Else If eventData.RemoteKey = 5 Then    ' Right
        If (m.Section <> invalid And m.ItemIndex < m.Section.TotalCount - 1) Or m.ItemIndex < m.ContentList.Count() - 1 Then
            m.ItemIndex = m.ItemIndex + 1
            m.ResetContent()
        End If
    End If
End Sub

Function EpisodeScreen_OnDisposed(eventData As Object, callbackData = invalid As Object)
    m.Screen.UnregisterObserverForAllEvents(m)
    m.Screen = invalid
    
    ' Reset the overhangs
    SetThemeAttribute("OverhangPrimaryLogoHD", AsString(m.PreviousOverhangHD))
    SetThemeAttribute("OverhangPrimaryLogoSD", AsString(m.PreviousOverhangSD))

    Return True
End Function
