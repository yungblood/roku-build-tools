Function NewSearchResultsScreen(searchTerm As String) As Object
    this                            = {}
    this.ClassName                  = "SearchResultsScreen"

    this.SearchTerm                 = searchTerm

    this.Show                       = SearchResultsScreen_Show

    this.OnShown                    = SearchResultsScreen_OnShown
    this.OnHidden                   = SearchResultsScreen_OnHidden
    this.OnRemoteKeyPressed         = SearchResultsScreen_OnRemoteKeyPressed
    this.OnListItemSelected         = SearchResultsScreen_OnListItemSelected
    this.OnDisposed                 = SearchResultsScreen_OnDisposed
        
    this.Screen                     = NewPosterScreen()
    this.Screen.SetListStyle("flat-episodic-16x9")
    this.Screen.SetBreadcrumbText("Search Results: " + searchTerm)
    
    this.Screen.RegisterObserver(this, "Shown", "OnShown")
    this.Screen.RegisterObserver(this, "Hidden", "OnHidden")
    this.Screen.RegisterObserver(this, "RemoteKeyPressed", "OnRemoteKeyPressed")
    this.Screen.RegisterObserver(this, "ListItemSelected", "OnListItemSelected")
    this.Screen.RegisterObserver(this, "Disposed", "OnDisposed")

    Return this
End Function

Sub SearchResultsScreen_Show()
    m.PreviousOverhangHD = GetThemeAttribute("OverhangPrimaryLogoHD")
    m.PreviousOverhangSD = GetThemeAttribute("OverhangPrimaryLogoSD")
    m.Screen.Show()
    results = Cbs().Search(m.SearchTerm, True)
    If results <> invalid And results.Count() > 0 Then
        m.Screen.SetContentList(results)
    Else
        m.Screen.ShowMessage("No results found. Try using a different keyword.")
    End If
End Sub

Sub SearchResultsScreen_OnShown(eventData As Object, callbackData = invalid As Object)
    Omniture().TrackPage("app:roku:search results")
End Sub

Sub SearchResultsScreen_OnHidden(eventData As Object, callbackData = invalid As Object)
End Sub

Sub SearchResultsScreen_OnRemoteKeyPressed(eventData As Object, callbackData = invalid As Object)
    If eventData.RemoteKey = 10 Then        ' Options
        ShowOptionsDialog()
        
        ' workaround phantom event issue occuring for some firmware versions
        m.Screen.MessagePort.WaitMessage(500)
    End If
End Sub

Sub SearchResultsScreen_OnListItemSelected(eventData As Object, callbackData = invalid As Object)
    If eventData.Item <> invalid Then
        OpenItem(eventData.Item, eventData)
    End If
End Sub

Sub SearchResultsScreen_OnDisposed(eventData As Object, callbackData = invalid As Object)
    m.Screen.UnregisterObserverForAllEvents(m)
    m.Screen = invalid
    
    ' Reset the overhangs
    SetThemeAttribute("OverhangPrimaryLogoHD", AsString(m.PreviousOverhangHD))
    SetThemeAttribute("OverhangPrimaryLogoSD", AsString(m.PreviousOverhangSD))
End Sub