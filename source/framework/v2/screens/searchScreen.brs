'IMPORTS=v2/screens/baseScreen
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
Function NewSearchScreen() As Object
    this                            = NewBaseScreen("roSearchScreen", "roSearchScreenEvent")
    this.ClassName                  = "SearchScreen"
    
    this.SearchTerms                = []
    this.Text                       = ""

    this.InitializeScreen           = SearchScreen_InitializeScreen

    this.SetSearchTermHeaderText    = SearchScreen_SetSearchTermHeaderText
    this.SetSearchText              = SearchScreen_SetSearchText
    this.SetEmptySearchTermsText    = SearchScreen_SetEmptySearchTermsText
    this.SetSearchButtonText        = SearchScreen_SetSearchButtonText
    this.SetClearButtonText         = SearchScreen_SetClearButtonText
    this.SetClearButtonEnabled      = SearchScreen_SetClearButtonEnabled
    this.SetSearchTerms             = SearchScreen_SetSearchTerms
    
    this.GetText                    = SearchScreen_GetText

    this.OnEvent                    = SearchScreen_OnEvent

    Return this
End Function

Sub SearchScreen_InitializeScreen()
    If m.Screen <> invalid Then
        m.SetBreadcrumbText(m.Get("BreadcrumbA", ""), m.Get("BreadcrumbB", ""))
        m.SetSearchTermHeaderText(m.Get("SearchTermHeaderText", ""))
        m.SetSearchText(m.Get("SearchText", ""))
        m.SetEmptySearchTermsText(m.Get("EmptySearchTermsText", ""))
        m.SetSearchButtonText(m.Get("SearchButtonText", "Search"))
        m.SetClearButtonText(m.Get("ClearButtonText", "Clear Search History"))
        m.SetClearButtonEnabled(m.Get("ClearButtonEnabled", True))
        m.SetSearchTerms(m.Get("SearchTerms", []))
    End If
End Sub

Sub SearchScreen_SetSearchTermHeaderText(text As String)
    m.Set("SearchTermHeaderText", text)
    If m.Screen <> invalid Then
        m.Screen.SetSearchTermHeaderText(text)
    End If
End Sub

Sub SearchScreen_SetSearchText(text As String)
    m.Set("SearchText", text)
    If m.Screen <> invalid Then
        m.Screen.SetSearchText(text)
    End If
End Sub

Sub SearchScreen_SetEmptySearchTermsText(text As String)
    m.Set("EmptySearchTermsText", text)
    If m.Screen <> invalid Then
        m.Screen.SetEmptySearchTermsText(text)
    End If
End Sub

Sub SearchScreen_SetSearchButtonText(text As String)
    m.Set("SearchButtonText", text)
    If m.Screen <> invalid Then
        m.Screen.SetSearchButtonText(text)
    End If
End Sub

Sub SearchScreen_SetClearButtonText(text As String)
    m.Set("ClearButtonText", text)
    If m.Screen <> invalid Then
        m.Screen.SetClearButtonText(text)
    End If
End Sub

Sub SearchScreen_SetClearButtonEnabled(enabled = True As Boolean)
    m.Set("ClearButtonEnabled", enabled)
    If m.Screen <> invalid Then
        m.Screen.SetClearButtonEnabled(enabled)
    End If
End Sub

Sub SearchScreen_SetSearchTerms(terms As Object, headerText = "" As String)
    ' Save the search terms
    m.Set("SearchTerms", terms)
    
    ' Loop through search terms to build text array
    searchTerms = []
    For Each term in terms
        If IsString(term) Then
            ' This is a text term, so add it directly
            searchTerms.Push(term)
        Else If IsAssociativeArray(term) Then
            ' This is an object, so add it's Text property
            If IsNullOrEmpty(term.Text) Then
                searchTerms.Push(term.Title)
            Else
                searchTerms.Push(term.Text)
            End If
        End If
    Next
    
    ' Set the search term hints and header text
    If Not IsNullOrEmpty(headerText) Then
        m.SetSearchTermHeaderText(headerText)
    End If
    
    If m.Screen <> invalid Then
        'Set the search terms
        m.Screen.SetSearchTerms(searchTerms)
    End If
End Sub

Function SearchScreen_GetText() As String
    Return m.Get("Text", "")
End Function

Function SearchScreen_OnEvent(eventData As Object, callbackData = invalid As Object) As Boolean
    ' Retrieve the message via the key, to avoid Eclipse parser errors
    msg = eventData["Event"]
    If Type(msg) = "roSearchScreenEvent" Then
        If msg.IsScreenClosed() Then
            Return m.Dispose()
        Else If msg.IsCleared() Then
            data = m.GetBaseEventData()
            ' Raise the cleared event
            m.RaiseEvent("Cleared", data)
        Else If msg.IsPartialResult() Then
            data = m.GetBaseEventData()
            data.Text = msg.GetMessage()
            data.Query = data.Text
            m.Set("Text", data.Text)
            ' Raise the partial result event
            m.RaiseEvent("PartialResult", data)
        Else If msg.IsFullResult() Then
            data = m.GetBaseEventData()
            data.Text = msg.GetMessage()
            data.Query = m.Get("Text", data.Text)

            ' Check to see if the entered text is one of the search
            ' terms and set the event info accordingly
            For i = 0 To m.SearchTerms.Count()
                term = m.SearchTerms[i]
                If (IsString(term) And term = data.Text) Or (IsAssociativeArray(term) And ((Not IsNullOrEmpty(term.Text) And term.Text = data.Text) Or (IsNullOrEmpty(term.Text) And term.Title = data.Text))) Then
                    data.ItemIndex = i
                    data.Item = term
                    data.SearchTerm = term
                    Exit For
                End If
            Next

            ' Raise the full result event
            m.RaiseEvent("FullResult", data)
        Else If msg.IsRemoteKeyPressed() Or msg.IsButtonInfo() Then
            data = m.GetBaseEventData()
            data.RemoteKey = IIf(msg.IsButtonInfo(), 10, msg.GetIndex())
            data.Query = m.Get("Text", "")
            data.Text = m.Get("Text", "")
            If msg.IsButtonInfo() Then
                data.ItemIndex = msg.GetIndex()
                data.Item = m.SearchTerms[msg.GetIndex()]
                data.SearchTerm = m.SearchTerms[msg.GetIndex()]
                If data.Item <> invalid Then
                    If IsNullOrEmpty(data.Item.Text) Then
                        data.Text = data.Item.Title
                    Else
                        data.Text = data.Item.Text
                    End If
                End If
            End If
            
            ' Raise the remote key pressed event
            m.RaiseEvent("RemoteKeyPressed", data)
        End If
    End If
    Return True
End Function
