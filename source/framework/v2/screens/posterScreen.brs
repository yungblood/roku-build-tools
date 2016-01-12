'IMPORTS=v2/screens/baseScreen
' ******************************************************
' Copyright Steven Kean 2010-2015
' All Rights Reserved.
' ******************************************************
Function NewPosterScreen() As Object
    this                        = NewBaseScreen("roPosterScreen", ["Idle", "roPosterScreenEvent"])
    this.ClassName              = "PosterScreen"
    
    this.ListIndex              = 0
    this.ItemIndex              = 0
    
    this.InitializeScreen       = PosterScreen_InitializeScreen
    
    this.ShowMessage            = PosterScreen_ShowMessage

    this.SetListStyle           = PosterScreen_SetListStyle
    this.SetDisplayMode         = PosterScreen_SetDisplayMode
    this.SetLoadingPoster       = PosterScreen_SetLoadingPoster
    
    this.SetListItems           = PosterScreen_SetListItems
    this.SetContentList         = PosterScreen_SetContentList
    this.SetFocusedList         = PosterScreen_SetFocusedList
    this.SetFocusedListItem     = PosterScreen_SetFocusedListItem

    this.OnEvent                = PosterScreen_OnEvent
    
    this.GetBaseEventData       = PosterScreen_GetBaseEventData
    
    Return this
End Function

Sub PosterScreen_InitializeScreen()
    If m.Screen <> invalid Then
        m.SetBreadcrumbText(m.Get("BreadcrumbA", ""), m.Get("BreadcrumbB", ""))
        m.SetListStyle(m.Get("ListStyle", "arced-portrait"))
        m.SetDisplayMode(m.Get("DisplayMode", "scale-to-fill"))
        m.SetLoadingPoster(m.Get("LoadingPosterSD"), m.Get("LoadingPosterHD"))
        
        If m.ListItems <> invalid And (m.ListItems.Count() > 1 Or Not m.ListItems[0].IsEmpty()) Then
            m.SetListItems(m.ListItems)
        End If
    End If
End Sub

Sub PosterScreen_ShowMessage(message As String)
    If m.Screen <> invalid Then
        m.Screen.ShowMessage(message)
    End If
End Sub

Sub PosterScreen_SetListStyle(style As String)
    m.Set("ListStyle", style)
    If m.Screen <> invalid Then
        m.Screen.SetListStyle(m.Get("ListStyle", "arced-portrait"))
    End If
End Sub

Sub PosterScreen_SetDisplayMode(displayMode As String)
    m.Set("DisplayMode", displayMode)
    If m.Screen <> invalid Then
        m.Screen.SetListDisplayMode(m.Get("DisplayMode", "scale-to-fill"))
    End If
End Sub

Sub PosterScreen_SetLoadingPoster(sdPoster As Dynamic, hdPoster = sdPoster As Dynamic)
    m.Set("LoadingPosterSD", sdPoster)
    m.Set("LoadingPosterHD", hdPoster)
    If m.Screen <> invalid And sdPoster <> invalid And hdPoster <> invalid Then
        If CheckFirmware(4) > 0 Then
            m.Screen.SetLoadingPoster(sdPoster, hdPoster)
        End If
    End If
End Sub

Sub PosterScreen_SetListItems(listItems As Object)
    m.ListItems = []
    If IsArray(listItems) Then
        m.ListItems.Append(listItems)
    End If
    If m.Screen <> invalid Then
        ' Set the list names on the grid
        listNames = []
        listStyles = []
        For Each list in m.ListItems
            If list <> invalid Then
                listNames.Push(list.Name)
            End If
        Next
        m.Screen.SetListNames(listNames)
    End If
End Sub

Sub PosterScreen_SetContentList(contentList As Object)
    If m.ListItems = invalid Then
        ' No filter items were set, so create a placeholder
        m.ListItems = [{}]
    End If
    list = m.ListItems[m.ListIndex]
    If list <> invalid Then
        list.ContentList = contentList
        list.IsLoaded = True
        If m.Screen <> invalid Then
            m.Screen.SetContentList(contentList)
        End If
    End If
End Sub

Sub PosterScreen_SetFocusedList(listIndex As Integer)
    m.ListIndex = listIndex
    If m.Screen <> invalid Then
        m.Screen.SetFocusedList(m.ListIndex)
    End If
End Sub

Sub PosterScreen_SetFocusedListItem(itemIndex As Integer)
    list = m.ListItems[m.ListIndex]
    If list <> invalid And list.IsLoaded = True And list.ContentList <> invalid Then
        If itemIndex >= list.ContentList.Count() Then
            itemIndex = 0
        End If
        m.ItemIndex = itemIndex
        If m.Screen <> invalid Then
            m.Screen.SetFocusedListItem(m.ItemIndex)
        End If
    End If
End Sub

Function PosterScreen_OnEvent(eventData As Object, callbackData = invalid As Object) As Boolean
    ' Retrieve the message via the key, to avoid Eclipse parser errors
    msg = eventData["Event"]
    If Type(msg) = "roPosterScreenEvent" Then
        If msg.IsScreenClosed() Then
            Return m.Dispose()
        Else If msg.IsListFocused() Then
            m.ItemIndex = 0
            m.ListIndex = msg.GetIndex()
            ' Store the list's current selected index
            list = m.ListItems[m.ListIndex]
            If list <> invalid Then
                If list.SelectedIndex <> invalid Then
                    m.ItemIndex = list.SelectedIndex
                End If
                If list.ContentList <> invalid And list.IsLoaded <> False Then
                    m.SetContentList(list.ContentList)
                    m.SetFocusedListItem(m.ItemIndex)
                Else
                    m.RaiseEvent("ListLoading", m.GetBaseEventData(m.ListIndex))
                End If
            End If
            ' Raise the list item focused event
            m.RaiseEvent("ListFocused", m.GetBaseEventData())
        Else If msg.IsListItemFocused() Then
            m.ItemIndex = msg.GetIndex()
            ' Store the list's current selected index
            list = m.ListItems[m.ListIndex]
            If list <> invalid Then
                list.SelectedIndex = m.ItemIndex
            End If
            ' Raise the list item focused event
            m.RaiseEvent("ListItemFocused", m.GetBaseEventData())
        Else If msg.IsListItemSelected() Then
            m.ItemIndex = msg.GetIndex()
            ' Raise the list item selected event
            m.RaiseEvent("ListItemSelected", m.GetBaseEventData())
        Else If msg.IsRemoteKeyPressed() Or msg.IsListItemInfo() Then
            data = m.GetBaseEventData()
            If msg.IsListItemInfo() Then
                data.RemoteKey = 10
            Else
                data.RemoteKey = msg.GetIndex()
            End If
            ' Raise the remote key pressed event
            m.RaiseEvent("RemoteKeyPressed", data)
        End If
    Else If msg = invalid Then
    End If
    Return True
End Function

Function PosterScreen_GetBaseEventData(listIndex = m.ListIndex As Integer, itemIndex = m.ItemIndex As Integer) As Object
    eventData = {
        ListItems:  m.ListItems
        ListIndex:  listIndex
        ItemIndex:  itemIndex
        List:       invalid
        Item:       invalid
    }
    If m.ListItems <> invalid Then
        eventData.List = m.ListItems[listIndex]
    End If
    If eventData.List <> invalid And eventData.List.ContentList <> invalid Then
        eventData.Item = eventData.List.ContentList[itemIndex]
    End If
    Return eventData
End Function
