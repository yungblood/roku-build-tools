Function NewSettingsScreen() As Object
    this                            = {}
    this.ClassName                  = "SettingsScreen"
    
    this.Rows                       = []
    
    this.Show                       = SettingsScreen_Show
    this.SetupRows                  = SettingsScreen_SetupRows

    this.OnShown                    = SettingsScreen_OnShown
    this.OnHidden                   = SettingsScreen_OnHidden
    this.OnRemoteKeyPressed         = SettingsScreen_OnRemoteKeyPressed
    this.OnListItemFocused          = SettingsScreen_OnListItemFocused
    this.OnListItemSelected         = SettingsScreen_OnListItemSelected
    this.OnDisposed                 = SettingsScreen_OnDisposed

    this.Screen                     = NewGridScreen()
    this.Screen.SetGridStyle("two-row-flat-landscape-custom")
    this.Screen.SetDisplayMode("scale-to-fit")
    this.Screen.SetErrorPoster("pkg:/images/icon_generic_sd.jpg", "pkg:/images/icon_generic_hd.jpg")
    this.Screen.SetDescriptionVisible(False)
    this.Screen.SetLoadAsync(False)

    this.Screen.RegisterObserver(this, "Shown", "OnShown")
    this.Screen.RegisterObserver(this, "Hidden", "OnHidden")
    this.Screen.RegisterObserver(this, "RemoteKeyPressed", "OnRemoteKeyPressed")
    this.Screen.RegisterObserver(this, "ListItemFocused", "OnListItemFocused")
    this.Screen.RegisterObserver(this, "ListItemSelected", "OnListItemSelected")
    this.Screen.RegisterObserver(this, "Disposed", "OnDisposed")

    Return this
End Function

Function SettingsScreen_Show() As Boolean
    m.PreviousOverhangHD = GetThemeAttribute("GridScreenLogoHD")
    m.PreviousOverhangSD = GetThemeAttribute("GridScreenLogoSD")
    SetThemeAttribute("GridScreenLogoHD", "")
    SetThemeAttribute("GridScreenLogoSD", "")

    m.SetupRows()
    m.Screen.Show()
    m.Screen.SetDescriptionVisible(False)
    Return True
End Function

Sub SettingsScreen_SetupRows()
    row = {
        Name:           ""
        ID:             "menu"
        ContentList:    []
    }
    row.ContentList.Push({
        Title: "Network Info"
        ID: "network"
        HDPosterUrl: "pkg:/images/icon_networkinfo_hd.png"
        SDPosterUrl: "pkg:/images/icon_networkinfo_sd.png"
        Events: ["event19"]        
    })
    If Cbs().IsAuthenticated() Then
        row.ContentList.Push({
            Title: "Sign out"
            ID: "signOut"
            HDPosterUrl: "pkg:/images/icon_signout_hd.png"
            SDPosterUrl: "pkg:/images/icon_signout_sd.png"
            Events: ["event22"]
        })
    Else
        row.ContentList.Push({
            Title: "Sign up or Sign in"
            ID: "signUp"
            HDPosterUrl: "pkg:/images/icon_signup_hd.png"
            SDPosterUrl: "pkg:/images/icon_signup_sd.png"
            Events: ["event22"]
        })
    End If
    m.Screen.SetRowItems([row])
End Sub

Sub SettingsScreen_OnShown(eventData As Object, callbackData = invalid As Object)
    SetThemeAttribute("GridScreenLogoHD", "")
    SetThemeAttribute("GridScreenLogoSD", "")
    Omniture().TrackPage("app:roku:settings")
    Cbs().IsSettingsScreenOpened = True
End Sub

Sub SettingsScreen_OnHidden(eventData As Object, callbackData = invalid As Object)
End Sub

Sub SettingsScreen_OnRemoteKeyPressed(eventData As Object, callbackData = invalid As Object)
    If eventData.RemoteKey = 10 Then        ' Options
        ShowOptionsDialog()
    Else If eventData.RemoteKey = 13 Then   ' Play
    End If
End Sub

Sub SettingsScreen_OnListItemFocused(eventData As Object, callbackData = invalid As Object)
    ' Make sure the description isn't visible
    m.Screen.SetDescriptionVisible(False)
End Sub

Sub SettingsScreen_OnListItemSelected(eventData As Object, callbackData = invalid As Object)
    If eventData.Item <> invalid Then
        linkName = "app:roku:settings:" + LCase(AsString(eventData.Item.Title))
        ProcessGlobalOption(eventData.Item, linkName, eventData.Item.Events)
        If eventData.Item.ID = "signUp" Or eventData.Item.ID = "signOut" Then
            m.SetupRows()
        End If
    End If
End Sub

Function SettingsScreen_OnDisposed(eventData As Object, callbackData = invalid As Object)
    m.Screen.UnregisterObserverForAllEvents(m)
    m.Screen = invalid
    Cbs().IsSettingsScreenOpened = False

    ' Reset the overhangs
    SetThemeAttribute("GridScreenLogoHD", AsString(m.PreviousOverhangHD))
    SetThemeAttribute("GridScreenLogoSD", AsString(m.PreviousOverhangSD))
    
    Return True
End Function