'IMPORTS=v2/screens/baseScreen
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
Function NewListScreen() As Object
    this                        = NewBaseScreen("roListScreen", "roListScreenEvent")
    this.ClassName              = "ListScreen"
    
    this.ContentList            = invalid
    this.ItemIndex              = 0

    this.InitializeScreen       = ListScreen_InitializeScreen

    this.SetBreadcrumbText      = ListScreen_SetBreadcrumbText
    this.SetHeader              = ListScreen_SetHeader
    this.SetUpBehaviorAtTopRow  = ListScreen_SetUpBehaviorAtTopRow
    
    this.SetContent             = ListScreen_SetContent
    this.SetFocusedListItem     = ListScreen_SetFocusedListItem

    this.OnEvent                = ListScreen_OnEvent
    
    this.GetBaseEventData       = ListScreen_GetBaseEventData
    
    Return this
End Function

Sub ListScreen_InitializeScreen()
    If m.Screen <> invalid Then
        m.SetBreadcrumbText(m.Get("BreadcrumbA", ""), m.Get("BreadcrumbB", ""))
        m.SetUpBehaviorAtTopRow(m.Get("UpBehaviorAtTopRow", "stop"))
        m.SetHeader(m.Get("Header", ""))
        
        If m.ContentList <> invalid Then
            m.SetContent(m.ContentList)
        End If
    End If
End Sub

Sub ListScreen_SetBreadcrumbText(breadcrumbA = "" As String, breadcrumbB = "" As String)
    m.Set("BreadcrumbA", breadcrumbA)
    m.Set("BreadcrumbB", breadcrumbB)
    If m.Screen <> invalid Then
        If CheckFirmware(4) > 0 Then
            m.Screen.SetBreadcrumbText(breadcrumbA, breadcrumbB)
        Else
            title = breadcrumbA
            If Not IsNullOrEmpty(title) And Not IsNullOrEmpty(breadcrumbB) Then
                title = title + " - "
            End If
            title = title + breadcrumbB
            m.Screen.SetTitle(title)
        End If
    End If
End Sub

Sub ListScreen_SetHeader(header As String)
    m.Set("Header", header)
    If m.Screen <> invalid Then
        m.Screen.SetHeader(header)
    End If
End Sub

Sub ListScreen_SetUpBehaviorAtTopRow(behavior As String)
    m.Set("UpBehaviorAtTopRow", behavior)
    If m.Screen <> invalid Then
        If CheckFirmware(4) > 0 Then
            m.Screen.SetUpBehaviorAtTopRow(behavior)
        End If
    End If
End Sub

Sub ListScreen_SetContent(contentList As Object)
    m.ContentList = contentList
    If m.Screen <> invalid Then
        m.Screen.SetContent(contentList)
        m.SetFocusedListItem(m.ItemIndex)
    End If
End Sub

Sub ListScreen_SetFocusedListItem(itemIndex As Integer)
    m.ItemIndex = itemIndex
    If m.Screen <> invalid Then
        m.Screen.SetFocusedListItem(m.ItemIndex)
    End If
End Sub

Function ListScreen_OnEvent(eventData As Object, callbackData = invalid As Object) As Boolean
    ' Retrieve the message via the key, to avoid Eclipse parser errors
    msg = eventData["Event"]
    If Type(msg) = "roListScreenEvent" Then
        If msg.IsScreenClosed() Then
            Return m.Dispose()
        Else If msg.IsListItemFocused() Then
            m.ItemIndex = msg.GetIndex()
            ' Raise the list item focused event
            m.RaiseEvent("ListItemFocused", m.GetBaseEventData())
        Else If msg.IsListItemSelected() Then
            m.ItemIndex = msg.GetIndex()
            ' Raise the list item selected event
            m.RaiseEvent("ListItemSelected", m.GetBaseEventData())
        Else If msg.IsRemoteKeyPressed() Then
            data = m.GetBaseEventData()
            data.RemoteKey = msg.GetIndex()
            ' Raise the remote key pressed event
            m.RaiseEvent("RemoteKeyPressed", data)
        End If
    End If
    Return True
End Function

Function ListScreen_GetBaseEventData(itemIndex = m.ItemIndex As Integer) As Object
    eventData = {
        ContentList:    m.ContentList
        ItemIndex:      itemIndex
        Item:           invalid
    }
    If m.ContentList <> invalid Then
        eventData.Item = m.ContentList[itemIndex]
    End If
    Return eventData
End Function
