Function NewAllShowsScreen() As Object
    this                            = {}
    this.ClassName                  = "AllShowsScreen"
    
    this.Show                       = AllShowsScreen_Show

    this.OnShown                    = AllShowsScreen_OnShown
    this.OnHidden                   = AllShowsScreen_OnHidden
    this.OnRowLoading               = AllShowsScreen_OnRowLoading
    this.OnRemoteKeyPressed         = AllShowsScreen_OnRemoteKeyPressed
    this.OnListItemFocused          = AllShowsScreen_OnListItemFocused
    this.OnListItemSelected         = AllShowsScreen_OnListItemSelected
    this.OnDisposed                 = AllShowsScreen_OnDisposed
    
    this.Screen                     = NewGridScreen()
    this.Screen.SetGridStyle("two-row-flat-landscape-custom")
    this.Screen.SetDisplayMode("scale-to-fit")
    this.Screen.SetErrorPoster("pkg:/images/icon_generic_sd.jpg", "pkg:/images/icon_generic_hd.jpg")
    'this.Screen.SetCounterVisible(False)
    this.Screen.SetDescriptionVisible(False)
    this.Screen.SetLoadAsync(False)
    
    this.Screen.SetBreadcrumbText("Shows")

    this.Screen.RegisterObserver(this, "Shown", "OnShown")
    this.Screen.RegisterObserver(this, "Hidden", "OnHidden")
    this.Screen.RegisterObserver(this, "RowLoading", "OnRowLoading")
    this.Screen.RegisterObserver(this, "RemoteKeyPressed", "OnRemoteKeyPressed")
    this.Screen.RegisterObserver(this, "ListItemFocused", "OnListItemFocused")
    this.Screen.RegisterObserver(this, "ListItemSelected", "OnListItemSelected")
    this.Screen.RegisterObserver(this, "Disposed", "OnDisposed")

    Return this
End Function

Function AllShowsScreen_Show() As Boolean
    m.Screen.Show()
    
'    shows = Cbs().GetAllShows()
'    
'    rows = []
'    For i = 0 To shows.Count() - 1 Step 4
'        row = {}
'        row.ContentList = []
'        For j = 0 To 3
'            show = shows[i + j]
'            If show <> invalid Then
'                row.ContentList.Push(show)
'            End If
'        Next
'        If row.ContentList.Count() > 0 Then
'            rows.Push(row)
'        End If
'    Next
'    m.Screen.SetRowItems(rows)
    m.Screen.SetRowItems(Cbs().GetGroups())
    m.Screen.SetDescriptionVisible(False)

    Return True
End Function

Sub AllShowsScreen_OnShown(eventData As Object, callbackData = invalid As Object)
    Omniture().TrackPage("app:roku:all shows")
End Sub

Sub AllShowsScreen_OnHidden(eventData As Object, callbackData = invalid As Object)
End Sub

Sub AllShowsScreen_OnRowLoading(eventData As Object, callbackData = invalid As Object)
    If eventData.Row <> invalid Then
        If eventData.Row.ContentList = invalid Or eventData.Row.IsLoaded = False Then
            content = invalid
            If eventData.Row.ClassName = "ShowGroup" Then
                content = eventData.Row.GetShows()
            End If
            If content <> invalid And content.Count() > 0 Then
                m.Screen.SetContentList(eventData.RowIndex, content)
            Else
                m.Screen.SetListVisible(eventData.RowIndex, False)
            End If
        End If
    End If
End Sub

Sub AllShowsScreen_OnRemoteKeyPressed(eventData As Object, callbackData = invalid As Object)
    If eventData.RemoteKey = 10 Then        ' Options
        ShowOptionsDialog()
    Else If eventData.RemoteKey = 13 Then   ' Play
    End If
End Sub

Sub AllShowsScreen_OnListItemFocused(eventData As Object, callbackData = invalid As Object)
    ' Make sure the description isn't visible
    m.Screen.SetDescriptionVisible(False)
End Sub

Sub AllShowsScreen_OnListItemSelected(eventData As Object, callbackData = invalid As Object)
    If eventData.Row <> invalid And eventData.Item <> invalid Then
        linkName = "app:roku:all shows:" + LCase(AsString(eventData.Row.Name)) + ":" + LCase(AsString(eventData.Item.Title))
        Omniture().TrackEvent(linkName, ["event19"], { v46: linkName })

        OpenItem(eventData.Item)
    End If
End Sub

Function AllShowsScreen_OnDisposed(eventData As Object, callbackData = invalid As Object)
    m.Screen.UnregisterObserverForAllEvents(m)
    m.Screen = invalid
    
    Return True
End Function

