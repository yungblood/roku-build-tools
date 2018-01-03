Function OpenItem(item As Object, eventData = invalid As Object, isECP = False As Boolean) As Boolean
    If item.ClassName = "menuItem" Then
        If item.ID = "allShows" Then
            NewAllShowsScreen().Show()
        Else If item.ID = "liveTV" Then
            PlayLiveTV(Cbs().GetCurrentUser().IsSubscriber())
        Else If item.ID = "search" Then
            NewCbsSearchScreen().Show()
        Else If item.ID = "settings" Then
            NewSettingsScreen().Show()
        Else If item.ID = "signUp" Or item.ID = "freeTrial" Then
            If Cbs().IsCFFlowEnabled Then
                NewRegistrationWizard().ShowSubscriptionSelectionScreen()
            Else
                NewRegistrationWizard().Show()
            End If
        Else If item.ID = "upgrade" Then
            NewRegistrationWizard().ShowUpgradeScreen(Cbs().GetCurrentUser().IsRokuSubscriber())
        Else If item.ID = "downgrade" Then
            NewRegistrationWizard().ShowDowngradeScreen(Cbs().GetCurrentUser().IsRokuSubscriber())
        End If
    Else If item.ClassName = "Show" Then
        NewShowScreen().Show(item.ID)
    Else If item.ClassName = "LiveFeed" Then
        If eventData = invalid Then
            eventData = {
                Row: { ContentList: [item] }
                ItemIndex: 0
            }
        End If
        NewLiveFeedScreen().Show(eventData.Row, eventData.ItemIndex, Cbs().GetCurrentUser().IsSubscriber())
    Else If item.ClassName = "SearchResult" Then
        If item.ResultType = "Show" Then
            NewShowScreen().Show(item.ID)
        End If
    Else If item.ClassName = "Episode" Or item.ClassName = "Clip" Then
        screen = NewEpisodeScreen()
        If eventData <> invalid And eventData.Row <> invalid Then
            If eventData.Row.Section <> invalid Then
                screen.SetSection(eventData.Row.Section, eventData.ItemIndex)
            Else
                screen.SetContentList(eventData.Row.ContentList, eventData.ItemIndex)
            End If
        Else
            screen.SetContentList(item)
        End If
        screen.Show(isECP)
    End If
    Return True
End Function

Function PlayItem(item As Object, eventData = invalid As Object) As Boolean
    If item.ID = "liveTV" Then
        PlayLiveTV(Cbs().GetCurrentUser().IsSubscriber())
    End If
    Return True
End Function

Function PlayLiveTV(autoplay = False As Boolean) As Boolean
    liveChannels = Cbs().GetLiveChannels()
    If liveChannels.IsEmpty() Then
        Omniture().TrackPage("app:roku:settings:live tv not available")
        ShowMessageBox("Live TV", "Live TV streams are currently not available in your area. Be sure to check back as we are always adding more stations.", ["OK"], True)
        Return False
    Else
        If liveChannels.Count() = 1 Then
            NewLiveTVScreen().Show(liveChannels[0], autoplay)
        Else
            NewLiveTVSelectionScreen().Show(liveChannels, autoplay)
        End If
    End If
    Return True
End Function

Sub ShowOptionsDialog(showSearch = True As Boolean, showSettings = True As Boolean)
    options = []
    
    'TODO: For testing purposes, should not display when published to production
    If Cbs().UseStaging = True Then
        options.Push({
            Text:   "DEBUG: Display IP Address"
            ID:     "ip"
        })
        options.Push({
            Text:   "DEBUG: Re-authenticate"
            ID:     "reauth"
        })
        options.Push("separator")
    End If
    
    
    If Not Cbs().IsSearchScreenOpened Then
        options.Push({
            Text: "Search"
            ID: "search"
            Events: []
        })
    End If
    options.Push({
        Text: "Help"
        ID: "help"
        Events: ["event19"]
    })
    options.Push({
        Text: "Legal Notices"
        ID: "legal"
        Events: ["event19"]
    })
    If Not Cbs().IsSettingsScreenOpened Then
        options.Push({
            Text: "Settings"
            ID: "settings"
            Events: ["event19"]
        })
    End If
'    If Cbs().IsAuthenticated() Then
'        options.Push({
'            Text: "Sign out"
'            ID: "signOut"
'            Events: ["event22"]
'        })
'    Else
'        options.Push({
'            Text: "Sign up or Sign in"
'            ID: "signUp"
'            Events: ["event22"]
'        })
'    End If
    result = ShowMessageBox("Options", "", options, True, True, 0, 0, True, True)
    If result <> invalid And result.ID <> "cancel" Then
        linkName = "app:roku:options:" + LCase(AsString(result.Text))
        ProcessGlobalOption(result, linkName, result.Events)
    End If
End Sub

Sub ProcessGlobalOption(option As Object, linkName = "" As String, events = [] As Object, omnitureParams = {} As Object)
    If Not IsNullOrEmpty(linkName) Then
        Omniture().TrackEvent(linkName, events, omnitureParams)
    End If
    
    If option.ID = "search" Then
        NewCbsSearchScreen().Show()
    Else If option.ID = "signOut" Then
        option = ShowMessageBox("Sign out", "Are you sure you want to sign out?", ["No", "Yes"], True)
        If option <> invalid And option = "Yes" Then
            facade = CreateObject("roPosterScreen")
            facade.Show()
            dialog = ShowWaitDialog("Signing out...")
            If Cbs().Logout() Then
                App().Restart = True
                ScreenManager().CloseAll()
            End If
            dialog.Close()
            facade.Close()
        End If
    Else If option.ID = "signIn" Then
        NewRegistrationWizard().AuthenticateWithCode()
    Else If option.ID = "signUp" Or option.ID = "freeTrial" Then
        If Cbs().IsCFFlowEnabled Then
            NewRegistrationWizard().ShowSubscriptionSelectionScreen()
        Else
            NewRegistrationWizard().Show()
        End If
    Else If option.ID = "upgrade" Then
        NewRegistrationWizard().ShowUpgradeScreen(Cbs().GetCurrentUser().IsRokuSubscriber())
    Else If option.ID = "downgrade" Then
        NewRegistrationWizard().ShowDowngradeScreen(Cbs().GetCurrentUser().IsRokuSubscriber())
    Else If option.ID = "help" Then
        ShowMessageBox("Help", "For help or to submit feedback, please visit cbs.com/roku/help or submit feedback at" + Chr(10) + "cbs-roku-feedback@cbsinteractive.com", ["Close"], True)
    Else If option.ID = "legal" Then
        ShowMessageBox("Legal Notices", Cbs().GetLegalText(), ["Close"], True)
    Else If option.ID = "network" Then
        ShowMessageBox("Network Info", "IP Address: " + Cbs().GetIPAddress(), ["Close"], True)
    Else If option.ID = "settings" Then
        NewSettingsScreen().Show()
    Else If option.ID = "ip" Then
        ShowMessageBox("IP Address", "Roku API: " + Cbs().GetIPAddress(False) + Chr(10) + "CBS API: " + Cbs().GetIPAddress(), ["Close"], True)
    Else If option.ID = "reauth" Then
        Cbs().IsAuthenticated(True)
    End If
End Sub

Function GetEcpItem(ecp As Object) As Object
    ecpItem = invalid
    If ecp <> invalid Then
        contentID = ecp.contentID
        If Not IsNullOrEmpty(contentID) Then
            If ecp.mediaType = "episode" Or ecp.mediaType = "clip" Or ecp.mediaType = "season" Then
                ecpItem = Cbs().GetEpisode(contentID)
                If ecp.mediaType = "season" And ecpItem <> invalid And ecpItem.ClassName = "Episode" Then
                    ecpItem = ecpItem.GetShow()
                End If
            Else If ecp.mediaType = "show" Or ecp.mediaType = "series" Then
                ecpItem = Cbs().GetShow(contentID)
                
                'HACK: Workaround for Roku "My Feed" bug that specifies series for some episodes
                If ecpItem = invalid Then
                    ecpItem = Cbs().GetEpisode(contentID)
                End If
            Else If ecp.contentID = "live" Then
                ecpItem = { ClassName: "menuItem", ID: "liveTV" }
            End If
        End If
    End If
    Return ecpItem
End Function
