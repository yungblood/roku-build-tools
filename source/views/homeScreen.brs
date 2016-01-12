Function NewHomeScreen() As Object
    this                            = {}
    this.ClassName                  = "HomeScreen"
    
    this.Rows                       = []
    this.InitialShow                = True

    this.Show                       = HomeScreen_Show
    this.SetupRows                  = HomeScreen_SetupRows

    this.OnShown                    = HomeScreen_OnShown
    this.OnHidden                   = HomeScreen_OnHidden
    this.OnRowLoading               = HomeScreen_OnRowLoading
    this.OnRemoteKeyPressed         = HomeScreen_OnRemoteKeyPressed
    this.OnListItemFocused          = HomeScreen_OnListItemFocused
    this.OnListItemSelected         = HomeScreen_OnListItemSelected
    this.OnDisposed                 = HomeScreen_OnDisposed
    this.OnFavoritesChanged         = HomeScreen_OnFavoritesChanged
    this.OnRecentlyWatchedChanged   = HomeScreen_OnRecentlyWatchedChanged

    this.Screen                     = NewGridScreen()
    this.Screen.SetGridStyle("two-row-flat-landscape-custom")
    this.Screen.SetDisplayMode("scale-to-fit")
    this.Screen.SetErrorPoster("pkg:/images/icon_generic_sd.jpg", "pkg:/images/icon_generic_hd.jpg")
    this.Screen.SetDescriptionVisible(False)
    this.Screen.SetLoadAsync(False)

    this.Screen.RegisterObserver(this, "Shown", "OnShown")
    this.Screen.RegisterObserver(this, "Hidden", "OnHidden")
    this.Screen.RegisterObserver(this, "RowLoading", "OnRowLoading")
    this.Screen.RegisterObserver(this, "RemoteKeyPressed", "OnRemoteKeyPressed")
    this.Screen.RegisterObserver(this, "ListItemFocused", "OnListItemFocused")
    this.Screen.RegisterObserver(this, "ListItemSelected", "OnListItemSelected")
    this.Screen.RegisterObserver(this, "Disposed", "OnDisposed")
    
    GlobalEventRegistry().RegisterObserver(this, "FavoritesChanged", "OnFavoritesChanged")
    GlobalEventRegistry().RegisterObserver(this, "RecentlyWatchedChanged", "OnRecentlyWatchedChanged")

    Return this
End Function

Function HomeScreen_Show(ecpItem As Dynamic) As Boolean
    m.Screen.Show()

    ' Process any passed in ECP parameters
    If ecpItem = invalid Or Not OpenItem(ecpItem) Then
        m.SetupRows()
    End If
    
    Return True
End Function

Sub HomeScreen_SetupRows()
    m.Rows = []
    m.Rows.Push({
        ID:             "menu"
        Name:           ""
        ContentList:    [
            {
                Title:          "All Shows"
                ID:             "allShows"
                ClassName:      "menuItem"
                HDPosterUrl:    "pkg:/images/icon_shows_hd.png"
                SDPosterUrl:    "pkg:/images/icon_shows_sd.png"
            }
            {
                Title:          "Live TV"
                ID:             "liveTV"
                ClassName:      "menuItem"
                HDPosterUrl:    "pkg:/images/icon_livetv_hd.png"
                SDPosterUrl:    "pkg:/images/icon_livetv_sd.png"
            }
            {
                Title:          "Search"
                ID:             "search"
                ClassName:      "menuItem"
                HDPosterUrl:    "pkg:/images/icon_search_hd.png"
                SDPosterUrl:    "pkg:/images/icon_search_sd.png"
            }
            {
                Text:           ""
                ID:             "settings"
                ClassName:      "menuItem"
                HDPosterUrl:    "pkg:/images/icon_settings_hd.png"
                SDPosterUrl:    "pkg:/images/icon_settings_sd.png"
            }
        ]
    })
    m.Rows.Push({
        ID:     "featured"
        Name:   "Featured Shows"
    })
    m.Rows.Push({
        ID:         "myCBS"
        Name:       "My CBS"
        IsVisible:  Cbs().IsAuthenticated()
    })
    m.Rows.Push({
        ID:         "recentlyWatched"
        Name:       "Recently Watched"
        IsVisible:  Cbs().IsAuthenticated()
    })
    
    m.Rows.Append(Cbs().GetHomeRows(10, 100))
    
    m.Screen.SetRowItems(m.Rows)
    m.Screen.SetDescriptionVisible(False)
End Sub

Sub HomeScreen_OnShown(eventData As Object, callbackData = invalid As Object)
    SetThemeAttribute("GridScreenLogoHD", "")
    SetThemeAttribute("GridScreenLogoSD", "")
    Omniture().TrackPage("app:roku:home")
    
    If Not m.InitialShow And m.Rows.Count() = 0 Then
        ' We're showing the screen for at least the second time, and don't have any
        ' rows, so setup the rows now
        m.SetupRows()
    End If
    
    ' Update the selected index for the focused row
    row = m.Screen.GetFocusedRow()
    If row <> invalid And row.Section <> invalid And row.Section.LastRequestedIndex > -1 Then
        m.Screen.SetFocusedListItem(m.Screen.GetFocusedRowIndex(), row.Section.LastRequestedIndex)
    End If
    m.InitialShow = False
End Sub

Sub HomeScreen_OnHidden(eventData As Object, callbackData = invalid As Object)
End Sub

Sub HomeScreen_OnRowLoading(eventData As Object, callbackData = invalid As Object)
    If eventData.Row <> invalid Then
        If eventData.Row.ContentList = invalid Or eventData.Row.IsLoaded = False Then
            content = invalid
            If eventData.Row.ID = "featured" Then
                content = Cbs().GetFeaturedShows()
            Else If eventData.Row.ID = "myCBS" Then
                content = Cbs().GetCurrentUser().GetMyCbsShows(True)
            Else If eventData.Row.ID = "recentlyWatched" Then
                content = Cbs().GetCurrentUser().GetRecentlyWatched()
            Else If eventData.Row.Section <> invalid Then
                ' Load the first page of videos
                eventData.Row.Section.GetVideo(0)
                content = eventData.Row.Section.GetVideos()
            End If
            If content <> invalid And content.Count() > 0 Then
                For Each item In content
                    If item <> invalid And item.ClassName = "Episode" Then
                        item.UpdateDescription("Home")
                    End If
                Next
                m.Screen.SetContentList(eventData.RowIndex, content)
            Else
                m.Screen.SetListVisible(eventData.RowIndex, False)
            End If
        End If
    End If
End Sub

Sub HomeScreen_OnRemoteKeyPressed(eventData As Object, callbackData = invalid As Object)
    If eventData.RemoteKey = 10 Then        ' Options
        ShowOptionsDialog()
    Else If eventData.RemoteKey = 13 Then   ' Play
        item = m.Screen.GetFocusedListItem()
        If item <> invalid Then
            PlayItem(item)
        End If
    End If
End Sub

Sub HomeScreen_OnListItemFocused(eventData As Object, callbackData = invalid As Object)
    ' Make sure the description isn't visible
    m.Screen.SetDescriptionVisible(False)
    
    If eventData.Row <> invalid And eventData.Row.Section <> invalid Then
        resetContent = False
        For i = 0 To 3
            index = eventData.ItemIndex + i
            If eventData.Row.ContentList = invalid Or eventData.Row.ContentList[index] = invalid Then
                resetContent = True
            End If
            ' Request the video to force a page load, if necessary
            eventData.Row.Section.GetVideo(index, False)
        Next
        If resetContent Then
            content = eventData.Row.Section.GetVideos()
            For Each item In content
                If item <> invalid And item.ClassName = "Episode" Then
                    item.UpdateDescription("Home")
                End If
            Next
            m.Screen.SetContentList(eventData.RowIndex, content)
        End If
    End If
End Sub

Sub HomeScreen_OnListItemSelected(eventData As Object, callbackData = invalid As Object)
    If eventData.Row <> invalid And eventData.Item <> invalid Then
        linkName = "app:roku:home:" + LCase(AsString(eventData.Row.Name)) + ":" + LCase(AsString(eventData.Item.Title))
        If eventData.Row.ID = "menu" Then
            linkName = "app:roku:home:" + LCase(AsString(eventData.Item.Title))
        End If
        Omniture().TrackEvent(linkName, ["event19"], { v46: linkName })

        OpenItem(eventData.Item, eventData)
    End If
End Sub

Function HomeScreen_OnDisposed(eventData As Object, callbackData = invalid As Object)
    m.Screen.UnregisterObserverForAllEvents(m)
    m.Screen = invalid
    
    GlobalEventRegistry().UnregisterObserverForAllEvents(m)
    
    ' Exit the event loop if this is the last screen
    Return ScreenManager().Screens.Count() > 0
End Function

Sub HomeScreen_OnFavoritesChanged(eventData As Object, callbackData = invalid As Object)
    m.Screen.ReloadRow("myCBS", False, True, True)
End Sub

Sub HomeScreen_OnRecentlyWatchedChanged(eventData As Object, callbackData = invalid As Object)
    m.Screen.ReloadRow("recentlyWatched", False, True, True)
End Sub
