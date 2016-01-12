Function NewCbsSearchScreen() As Object
    this                            = {}
    this.ClassName                  = "SearchScreen"

    this.Show                       = CbsSearchScreen_Show

    this.OnShown                    = CbsSearchScreen_OnShown
    this.OnHidden                   = CbsSearchScreen_OnHidden
    this.OnRemoteKeyPressed         = CbsSearchScreen_OnRemoteKeyPressed
    this.OnPartialResult            = CbsSearchScreen_OnPartialResult
    this.OnFullResult               = CbsSearchScreen_OnFullResult
    this.OnDisposed                 = CbsSearchScreen_OnDisposed
    
    this.Screen                     = NewSearchScreen()
    this.Screen.SetBreadcrumbText("Search")
    this.Screen.SetSearchTermHeaderText("Search:")
    this.Screen.SetEmptySearchTermsText("Search CBS All Access")
    this.Screen.SetClearButtonEnabled(False)
    
    this.Screen.RegisterObserver(this, "Shown", "OnShown")
    this.Screen.RegisterObserver(this, "Hidden", "OnHidden")
    this.Screen.RegisterObserver(this, "RemoteKeyPressed", "OnRemoteKeyPressed")
    this.Screen.RegisterObserver(this, "PartialResult", "OnPartialResult")
    this.Screen.RegisterObserver(this, "FullResult", "OnFullResult")
    this.Screen.RegisterObserver(this, "Disposed", "OnDisposed")

    Return this
End Function

Sub CbsSearchScreen_Show()
    m.PreviousOverhangHD = GetThemeAttribute("OverhangPrimaryLogoHD")
    m.PreviousOverhangSD = GetThemeAttribute("OverhangPrimaryLogoSD")
    SetThemeAttribute("OverhangPrimaryLogoHD", "")
    SetThemeAttribute("OverhangPrimaryLogoSD", "")

    m.Screen.Show()
End Sub

Sub CbsSearchScreen_OnShown(eventData As Object, callbackData = invalid As Object)
    Omniture().TrackPage("app:roku:search")
    Cbs().isSearchScreenOpened = true
End Sub

Sub CbsSearchScreen_OnHidden(eventData As Object, callbackData = invalid As Object)
End Sub

Sub CbsSearchScreen_OnRemoteKeyPressed(eventData As Object, callbackData = invalid As Object)
    If eventData.RemoteKey = 10 Then        ' Options
        ShowOptionsDialog()
    Else If eventData.RemoteKey = 13 Then   ' Play
        If eventData.Item <> invalid Then
        End If
    End If
End Sub

Sub CbsSearchScreen_OnPartialResult(eventData As Object, callbackData = invalid As Object)
    If IsNullOrEmpty(eventData.Text.Trim()) Then
        m.Screen.SetSearchTermHeaderText("Search:")
        m.Screen.SetEmptySearchTermsText("Search CBS All Access")
        m.Screen.SetSearchTerms([])
    Else
        results = Cbs().Search(eventData.Text.Trim(), False, 0, 9)
        If results.Count() > 0 Then
            m.Screen.SetSearchTermHeaderText("Search: " + Chr(34) + eventData.Text.Trim() + Chr(34))
        Else
            m.Screen.SetSearchTermHeaderText("Search:")
            m.Screen.SetEmptySearchTermsText("No results found. Try using a different keyword.")
        End If
        m.Screen.SetSearchTerms(results)
    End If
End Sub

Sub CbsSearchScreen_OnFullResult(eventData As Object, callbackData = invalid As Object)
    If eventData.SearchTerm <> invalid Then
        OpenItem(eventData.SearchTerm, eventData)
    Else
        If Not IsNullOrEmpty(eventData.Text.Trim()) Then
            NewSearchResultsScreen(eventData.Text).Show()
        Else
            ShowMessageBox("Error", "Please enter a keyword to search.", ["OK"], True)
        End If
    End If
End Sub

Sub CbsSearchScreen_OnDisposed(eventData As Object, callbackData = invalid As Object)
    m.Screen.UnregisterObserverForAllEvents(m)
    m.Screen = invalid
    Cbs().isSearchScreenOpened = false
    
    ' Reset the overhangs
    SetThemeAttribute("OverhangPrimaryLogoHD", AsString(m.PreviousOverhangHD))
    SetThemeAttribute("OverhangPrimaryLogoSD", AsString(m.PreviousOverhangSD))
End Sub
