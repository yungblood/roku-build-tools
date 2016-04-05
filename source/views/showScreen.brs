Function NewShowScreen() As Object
    this                            = {}
    this.ClassName                  = "ShowScreen"
    
    this.Rows                       = []
    
    this.Show                       = ShowScreen_Show
    this.SetupRows                  = ShowScreen_SetupRows

    this.OnShown                    = ShowScreen_OnShown
    this.OnHidden                   = ShowScreen_OnHidden
    this.OnRowLoading               = ShowScreen_OnRowLoading
    this.OnRemoteKeyPressed         = ShowScreen_OnRemoteKeyPressed
    this.OnListItemFocused          = ShowScreen_OnListItemFocused
    this.OnListItemSelected         = ShowScreen_OnListItemSelected
    this.OnDisposed                 = ShowScreen_OnDisposed
    this.OnFavoritesChanged         = ShowScreen_OnFavoritesChanged

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

    Return this
End Function

Function ShowScreen_Show(showID As String) As Boolean
    ' Get the show
    m.ShowItem = Cbs().GetShow(showID)
    
    If m.ShowItem <> invalid And (m.ShowItem.EpisodeCount > 0 Or m.ShowItem.ClipCount > 0) Then
        m.PreviousOverhangHD = GetThemeAttribute("GridScreenLogoHD")
        m.PreviousOverhangSD = GetThemeAttribute("GridScreenLogoSD")
        SetThemeAttribute("GridScreenLogoHD", m.ShowItem.OverhangHD)
        SetThemeAttribute("GridScreenLogoSD", m.ShowItem.OverhangSD)
        
        If AsInteger(m.ShowItem.EpisodeCount) > 0 Then
            m.Screen.SetBreadcrumbText(AsString(m.ShowItem.EpisodeCount) + " Episode" + IIf(m.ShowItem.EpisodeCount > 1, "s", ""))
        End If

        ' Show the screen while we load the content
        m.Screen.Show()
        
        m.SetupRows()
        m.Screen.Show()
        m.Screen.SetDescriptionVisible(False)
        
        Return True
    Else
        m.Screen.Show()
        m.Screen.ShowMessage("No content is currently available. Please try again later.")
    End If
    Return False
End Function

Sub ShowScreen_SetupRows()
    m.Rows = []
    m.Rows.Push({
        Name:   ""
        ID:     "menu"
    })
    ' Check for Big Brother streams
    If m.ShowItem <> invalid And m.ShowItem.ID = "5692" Then
        m.rows.Push({
            Name:   "Live Feeds"
            ID:     "bigBrotherLive"
        })
    End If

    m.Rows.Append(m.ShowItem.GetRows())
    m.Screen.SetRowItems(m.Rows)
End Sub

Sub ShowScreen_OnShown(eventData As Object, callbackData = invalid As Object)
    If m.ShowItem <> invalid Then
        Omniture().TrackPage("app:roku:show:" + LCase(AsString(m.ShowItem.Title)))
    End If
    
    ' Update the selected index for the focused row
    row = m.Screen.GetFocusedRow()
    If row <> invalid Then
        If row.Section <> invalid And row.Section.LastRequestedIndex > -1 Then
            m.Screen.SetFocusedListItem(m.Screen.GetFocusedRowIndex(), row.Section.LastRequestedIndex)
        Else
            m.Screen.SetFocusedListItem(m.Screen.GetFocusedRowIndex(), AsInteger(row.SelectedIndex))
        End If
    End If
    
    ' Reload the menu row, to update the dynamic play button
    m.Screen.ReloadRow("menu")
    
    ' Reload the big brother live row, if present
    m.Screen.ReloadRow("bigBrotherLive")
End Sub

Sub ShowScreen_OnHidden(eventData As Object, callbackData = invalid As Object)
End Sub

Sub ShowScreen_OnRowLoading(eventData As Object, callbackData = invalid As Object)
    If eventData.Row <> invalid Then
        If eventData.Row.ContentList = invalid Or eventData.Row.IsLoaded = False Then
            content = invalid
            If eventData.Row.ID = "menu" Then
                content = []
                episode = m.ShowItem.GetDynamicPlayEpisode()
                If episode <> invalid Then
                    content.Push(episode)
                End If
                If m.ShowItem.ClipCount > 0 Then
                    content.Push({
                        ID: "clips"
                        HDPosterUrl:    "pkg:/images/icon_clips_hd.png"
                        SDPosterUrl:    "pkg:/images/icon_clips_sd.png"
                    })
                End If
                If Cbs().IsAuthenticated() Then
                    If Cbs().GetCurrentUser().ShowIsInFavorites(m.ShowItem.ID) Then
                        content.Push({
                            ID:             "removeFromFavorites"
                            ShowID:         m.ShowItem.ID
                            HDPosterUrl:    "pkg:/images/icon_remove_hd.png"
                            SDPosterUrl:    "pkg:/images/icon_remove_sd.png"
                        })
                    Else
                        content.Push({
                            ID:             "addToFavorites"
                            ShowID:         m.ShowItem.ID
                            HDPosterUrl:    "pkg:/images/icon_add_hd.png"
                            SDPosterUrl:    "pkg:/images/icon_add_sd.png"
                        })
                    End If
                End If
            Else If eventData.Row.ID = "bigBrotherLive" Then
                content = Cbs().GetBigBrotherStreams()
            Else If eventData.Row.Section <> invalid Then
                eventData.Row.Section.GetVideo(0)
                content = eventData.Row.Section.GetVideos()
            End If
            If content <> invalid And content.Count() > 0 Then
                For Each item In content
                    If item <> invalid And item.ClassName = "Episode" Then
                        item.UpdateDescription("Show")
                    End If
                Next
                m.Screen.SetContentList(eventData.RowIndex, content)
            Else
                m.Screen.SetListVisible(eventData.RowIndex, False)
            End If
        End If
    End If
End Sub

Sub ShowScreen_OnRemoteKeyPressed(eventData As Object, callbackData = invalid As Object)
    If eventData.RemoteKey = 10 Then        ' Options
        ShowOptionsDialog()
    Else If eventData.RemoteKey = 13 Then   ' Play
    End If
End Sub

Sub ShowScreen_OnListItemFocused(eventData As Object, callbackData = invalid As Object)
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
                    item.UpdateDescription("Show")
                End If
            Next
            m.Screen.SetContentList(eventData.RowIndex, content)
        End If
    End If
End Sub

Sub ShowScreen_OnListItemSelected(eventData As Object, callbackData = invalid As Object)
    If eventData.Row <> invalid And eventData.Item <> invalid Then
        linkName = "app:roku:show:" + LCase(AsString(m.ShowItem.Title)) + ":" + LCase(AsString(eventData.Row.Name)) + ":" + LCase(AsString(eventData.Item.Title))
        If eventData.Row.ID = "menu" Then
            linkName = "app:roku:show:" + LCase(AsString(m.ShowItem.Title)) + ":" + LCase(AsString(eventData.Item.Title))
        End If
        Omniture().TrackEvent(linkName, ["event19"], { v46: linkName })
    End If
    If eventData.Item <> invalid Then
        If eventData.Row <> invalid And eventData.Row.ID = "menu" Then
            If eventData.Item.ID = "dynamicPlay" Then
                OpenItem(eventData.Item.Episode)
            Else If eventData.Item.ID = "clips" Then
                index = m.Screen.GetRowIndex("clips")
                If index > -1 Then
                    m.Screen.SetFocusedListItem(index, 0, True)
                End If
            Else If eventData.Item.ID = "removeFromFavorites" Then
                dialog = ShowWaitDialog("Removing show from My CBS...")
                Cbs().GetCurrentUser().RemoveShowFromFavorites(m.ShowItem.ID)
                dialog.Close()
            Else If eventData.Item.ID = "addToFavorites" Then
                dialog = ShowWaitDialog("Adding show to My CBS...")
                Cbs().GetCurrentUser().AddShowToFavorites(m.ShowItem.ID)
                dialog.Close()
            End If
        Else
            OpenItem(eventData.Item, eventData)
        End If
    End If
End Sub

Function ShowScreen_OnDisposed(eventData As Object, callbackData = invalid As Object)
    m.Screen.UnregisterObserverForAllEvents(m)
    m.Screen = invalid
    
    GlobalEventRegistry().UnregisterObserverForAllEvents(m)
    
    ' Reset the overhangs
    SetThemeAttribute("GridScreenLogoHD", AsString(m.PreviousOverhangHD))
    SetThemeAttribute("GridScreenLogoSD", AsString(m.PreviousOverhangSD))
    
    Return True
End Function

Sub ShowScreen_OnFavoritesChanged(eventData As Object, callbackData = invalid As Object)
    If m.ShowItem <> invalid And eventData.ShowID = m.ShowItem.ID Then
        m.Screen.ReloadRow("menu")
    End If
End Sub