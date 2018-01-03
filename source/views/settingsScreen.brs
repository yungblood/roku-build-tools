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
    this.OnAuthenticationChanged    = SettingsScreen_OnAuthenticationChanged

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

    GlobalEventRegistry().RegisterObserver(this, "AuthenticationChanged", "OnAuthenticationChanged")

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
        If Cbs().GetCurrentUser().CanUpgrade() Then
            row.ContentList.Push({
                Title: "Upgrade"
                ID: "upgrade"
                HDPosterUrl: "pkg:/images/icon_upgrade_hd.jpg"
                SDPosterUrl: "pkg:/images/icon_upgrade_sd.jpg"
                OmnitureData:   {
                    LinkName: "app:roku:CF:upgrade:settings:click"
                    Params: {  
                        v10: "settings"
                        v4: "CIA-00-10abc7a"
                    }
                    Events: ["event19"]
                }
            })
        Else If Cbs().GetCurrentUser().CanDowngrade() Then
            row.ContentList.Push({
                Title: "Manage Account"
                ID: "downgrade"
                HDPosterUrl: "pkg:/images/icon_manageaccount_hd.jpg"
                SDPosterUrl: "pkg:/images/icon_manageaccount_sd.jpg"
                OmnitureData:   {
                    LinkName: "app:roku:CF:downgrade:settings:click"
                    Params: {  
                        v6: "cbs svod|settings"
                        v10: "settings"
                        v4: "CIA-00-10abc7b"
                    }
                    Events: ["event19"]
                }
            })
        End If
        row.ContentList.Push({
            Title: "Sign out"
            ID: "signOut"
            HDPosterUrl: "pkg:/images/icon_signout_hd.png"
            SDPosterUrl: "pkg:/images/icon_signout_sd.png"
            Events: ["event22"]
        })
    Else
        If Cbs().IsCFFlowEnabled Then
            row.ContentList.Push({
                Title: "Start your free trial"
                ID: "signUp"
                HDPosterUrl: "pkg:/images/icon_freetrial_hd.jpg"
                SDPosterUrl: "pkg:/images/icon_freetrial_sd.jpg"
                OmnitureData:   {
                    LinkName: "app:roku:all access:upsell:settings:subscribe:click"
                    Params: {  
                        v10: "settings"
                        v4: "CIA-00-10abc6g"
                    }
                    Events: ["event19"]
                }
            })
            row.ContentList.Push({
                Title: "Sign in"
                ID: "signIn"
                HDPosterUrl: "pkg:/images/icon_signin_hd.jpg"
                SDPosterUrl: "pkg:/images/icon_signin_sd.jpg"
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
        events = eventData.Item.Events
        params = {}
        If eventData.Item.OmnitureData <> invalid Then
            linkName = eventData.Item.OmnitureData.LinkName
            events = eventData.Item.OmnitureData.Events
            params = eventData.Item.OmnitureData.Params
        End If
        ProcessGlobalOption(eventData.Item, linkName, events, params)
        If eventData.Item.ID <> "network" Then
            m.SetupRows()
        End If
    End If
End Sub

Function SettingsScreen_OnDisposed(eventData As Object, callbackData = invalid As Object)
    GlobalEventRegistry().UnregisterObserverForAllEvents(m)
    m.Screen.UnregisterObserverForAllEvents(m)
    m.Screen = invalid
    Cbs().IsSettingsScreenOpened = False

    ' Reset the overhangs
    SetThemeAttribute("GridScreenLogoHD", AsString(m.PreviousOverhangHD))
    SetThemeAttribute("GridScreenLogoSD", AsString(m.PreviousOverhangSD))
    
    Return True
End Function

Sub SettingsScreen_OnAuthenticationChanged(eventData As Object, callbackData = invalid As Object)
    ' Refresh the current user state
    Cbs().GetCurrentUser(True)
    If m.Screen <> invalid Then
        m.SetupRows()
    End If
End Sub
