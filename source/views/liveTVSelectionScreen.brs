Function NewLiveTVSelectionScreen() As Object
    this                            = {}
    this.ClassName                  = "LiveTVSelectionScreen"
    
    this.Autoplay                   = False

    this.Show                       = LiveTVSelectionScreen_Show

    this.OnShown                    = LiveTVSelectionScreen_OnShown
    this.OnHidden                   = LiveTVSelectionScreen_OnHidden
    this.OnListItemSelected         = LiveTVSelectionScreen_OnListItemSelected
    this.OnRemoteKeyPressed         = LiveTVSelectionScreen_OnRemoteKeyPressed
    this.OnDisposed                 = LiveTVSelectionScreen_OnDisposed

    this.Screen                     = NewListScreen()
    this.Screen.SetBreadcrumbText("You've got options!")
    this.Screen.SetHeader("Select which station you would like to watch:")

    this.Screen.RegisterObserver(this, "Shown", "OnShown")
    this.Screen.RegisterObserver(this, "Hidden", "OnHidden")
    this.Screen.RegisterObserver(this, "ListItemSelected", "OnListItemSelected")
    this.Screen.RegisterObserver(this, "RemoteKeyPressed", "OnRemoteKeyPressed")
    this.Screen.RegisterObserver(this, "Disposed", "OnDisposed")

    Return this
End Function

Function LiveTVSelectionScreen_Show(channels As Object, autoplay = False As Boolean) As Boolean
    m.PreviousOverhangHD = GetThemeAttribute("OverhangPrimaryLogoHD")
    m.PreviousOverhangSD = GetThemeAttribute("OverhangPrimaryLogoSD")
    SetThemeAttribute("OverhangPrimaryLogoHD", "")
    SetThemeAttribute("OverhangPrimaryLogoSD", "")

    m.Autoplay = autoplay
    m.Screen.SetContent(channels)
    m.Screen.Show()
    
    Return True
End Function

Sub LiveTVSelectionScreen_OnShown(eventData As Object, callbackData = invalid As Object)
    Omniture().TrackPage("app:roku:live:station selector")
End Sub

Sub LiveTVSelectionScreen_OnHidden(eventData As Object, callbackData = invalid As Object)
End Sub

Sub LiveTVSelectionScreen_OnListItemSelected(eventData As Object, callbackData = invalid As Object)
    linkName = "app:roku:live:auth:" + LCase(AsString(eventData.Item.Title))
    Omniture().TrackEvent(linkName, ["event19"], { v46: linkName })
    If eventData.Item <> invalid Then
        NewLiveTVScreen().Show(eventData.Item, m.Autoplay)
    End If
End Sub

Sub LiveTVSelectionScreen_OnRemoteKeyPressed(eventData As Object, callbackData = invalid As Object)
    If eventData.RemoteKey = 10 Then        ' Options
        ShowOptionsDialog()
    Else If eventData.RemoteKey = 13 Then   ' Play
    End If
End Sub

Function LiveTVSelectionScreen_OnDisposed(eventData As Object, callbackData = invalid As Object)
    m.Screen.UnregisterObserverForAllEvents(m)
    m.Screen = invalid

    Return True
End Function

