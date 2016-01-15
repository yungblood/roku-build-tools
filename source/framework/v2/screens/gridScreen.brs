'IMPORTS=v2/screens/baseScreen
' ******************************************************
' Copyright Steven Kean 2010-2015
' All Rights Reserved.
' ******************************************************
Function NewGridScreen() As Object
    this                        = NewBaseScreen("roGridScreen", ["Idle", "roGridScreenEvent"])
    this.ClassName              = "GridScreen"
    
    this.InitialLoad            = True
    this.AllLoaded              = False
    this.LoadAsync              = True
    this.LoadIndex              = 0
    this.RowLoadThreshold       = 5 ' Either side of the current row
    this.RowIndex               = 0
    this.ItemIndex              = 0
    this.RowItems               = []
    this.PopulatedRows          = [] ' Track rows that have been populated with SetContentList
    this.LoadingItemID          = "grid_loading"
    
    this.InitializeScreen       = GridScreen_InitializeScreen

    this.SetLoadAsync           = GridScreen_SetLoadAsync
    
    this.ShowMessage            = GridScreen_ShowMessage
    
    this.SetGridStyle           = GridScreen_SetGridStyle
    this.SetDisplayMode         = GridScreen_SetDisplayMode
    this.SetUpBehaviorAtTopRow  = GridScreen_SetUpBehaviorAtTopRow
    this.SetDescriptionVisible  = GridScreen_SetDescriptionVisible
    this.SetCounterVisible      = GridScreen_SetCounterVisible
    this.SetLoadingPoster       = GridScreen_SetLoadingPoster
    this.SetErrorPoster         = GridScreen_SetErrorPoster
    
    this.SetRowItems            = GridScreen_SetRowItems
    this.SetContentList         = GridScreen_SetContentList
    this.SetListVisible         = GridScreen_SetListVisible
    this.GetListVisible         = GridScreen_GetListVisible
    this.SetListOffset          = GridScreen_SetListOffset
    this.SetFocusedListItem     = GridScreen_SetFocusedListItem
    this.GetFocusedListItem     = GridScreen_GetFocusedListItem
    this.GetRowIndex            = GridScreen_GetRowIndex
    this.GetFocusedRowIndex     = GridScreen_GetFocusedRowIndex
    this.GetFocusedRow          = GridScreen_GetFocusedRow
    
    this.ReloadRow              = GridScreen_ReloadRow
    this.LoadRows               = GridScreen_LoadRows
    
    this.OnEvent                = GridScreen_OnEvent
    
    this.GetBaseEventData       = GridScreen_GetBaseEventData
    
    Return this
End Function

Sub GridScreen_InitializeScreen()
    If m.Screen <> invalid Then
        m.SetBreadcrumbText(m.Get("BreadcrumbA", ""), m.Get("BreadcrumbB", ""))
        m.SetGridStyle(m.Get("GridStyle", "flat-movie"))
        m.SetDisplayMode(m.Get("DisplayMode", "scale-to-fill"))
        m.SetUpBehaviorAtTopRow(m.Get("UpBehaviorAtTopRow", "stop"))
        m.SetDescriptionVisible(m.Get("DescriptionVisible", True))
        m.SetCounterVisible(m.Get("CounterVisible", True))
        m.SetLoadingPoster(m.Get("LoadingPosterSD"), m.Get("LoadingPosterHD"))
        m.SetErrorPoster(m.Get("ErrorPosterSD"), m.Get("ErrorPosterHD"))
        
        If m.RowItems <> invalid Then
            m.SetRowItems(m.RowItems)
        End If
    End If
End Sub

Sub GridScreen_SetLoadAsync(async = True As Boolean)
    m.LoadAsync = async
End Sub

Sub GridScreen_ShowMessage(message As String)
    If m.Screen <> invalid Then
        m.Screen.ShowMessage(message)
    End If
End Sub

Sub GridScreen_SetGridStyle(style As String)
    m.Set("GridStyle", style)
    If m.Screen <> invalid Then
        m.Screen.SetGridStyle(m.Get("GridStyle", "flat-movie"))
    End If
End Sub

Sub GridScreen_SetDisplayMode(displayMode As String)
    m.Set("DisplayMode", displayMode)
    If m.Screen <> invalid Then
        m.Screen.SetDisplayMode(m.Get("DisplayMode", "scale-to-fill"))
    End If
End Sub

Sub GridScreen_SetUpBehaviorAtTopRow(behavior As String)
    m.Set("UpBehaviorAtTopRow", behavior)
    If m.Screen <> invalid Then
        m.Screen.SetUpBehaviorAtTopRow(behavior)
    End If
End Sub

Sub GridScreen_SetDescriptionVisible(visible = True As Boolean)
    m.Set("DescriptionVisible", visible)
    If m.Screen <> invalid Then
        m.Screen.SetDescriptionVisible(visible)
    End If
End Sub

Sub GridScreen_SetCounterVisible(visible = True As Boolean)
    m.Set("CounterVisible", visible)
    If m.Screen <> invalid Then
        m.Screen.SetCounterVisible(visible)
    End If
End Sub

Sub GridScreen_SetLoadingPoster(sdPoster As Dynamic, hdPoster = sdPoster As Dynamic)
    m.Set("LoadingPosterSD", sdPoster)
    m.Set("LoadingPosterHD", hdPoster)
    If m.Screen <> invalid And sdPoster <> invalid And hdPoster <> invalid Then
        If CheckFirmware(4) > 0 Then
            m.Screen.SetLoadingPoster(sdPoster, hdPoster)
        End If
    End If
End Sub

Sub GridScreen_SetErrorPoster(sdPoster As Dynamic, hdPoster = sdPoster As Dynamic)
    m.Set("ErrorPosterSD", sdPoster)
    m.Set("ErrorPosterHD", hdPoster)
    If m.Screen <> invalid And sdPoster <> invalid And hdPoster <> invalid Then
        If CheckFirmware(4) > 0 Then
            m.Screen.SetErrorPoster(sdPoster, hdPoster)
        End If
    End If
End Sub

Sub GridScreen_SetRowItems(rowItems As Object)
    m.RowItems = []
    If IsArray(rowItems) Then
        m.RowItems.Append(rowItems)
    End If
    If m.Screen <> invalid Then
        m.Screen.SetupLists(m.RowItems.Count())

        ' Set the row names on the grid
        rowNames = []
        rowStyles = []
        For Each row in m.RowItems
            If row <> invalid Then
                rowNames.Push(row.Name)
                If Not IsNullOrEmpty(row.PosterStyle) Then
                    rowStyles.Push(row.PosterStyle)
                Else
                    rowStyles.Push("landscape")
                End If
            End If
        Next
        m.Screen.SetListNames(rowNames)
        m.Screen.SetListPosterStyles(rowStyles)
        
        For i = 0 To m.RowItems.Count() - 1
            row = m.RowItems[i]
            If row.IsLoaded <> False And row.ContentList <> invalid Then
                m.PopulatedRows[i] = True
                m.Screen.SetContentList(i, row.ContentList)
                If row.SelectedIndex <> invalid Then
                    m.Screen.SetListOffset(i, row.SelectedIndex)
                End If
            Else
                If Not IsNullOrEmpty(m.LoadingPosterHD) Then
                    m.Screen.SetContentList(i, [{ Title: "Loading...", ID: m.LoadingItemID, HDPosterUrl: m.LoadingPosterHD, SDPosterUrl: m.LoadingPosterSD }])
                End If
            End If
            If row.IsVisible = False Then
                m.Screen.SetListVisible(i, False)
            End If
        Next
    End If
    m.InitialLoad = True
    m.AllLoaded = False
End Sub

Sub GridScreen_SetContentList(rowIndex As Integer, contentList As Object)
    row = m.RowItems[rowIndex]
    If row <> invalid Then
        row.ContentList = contentList
        row.IsLoaded = True
        row.IsLoading = False
        If m.Screen <> invalid Then
            m.PopulatedRows[rowIndex] = True
            m.Screen.SetContentList(rowIndex, contentList)
        End If
    End If
End Sub

Sub GridScreen_SetListVisible(rowIndex As Integer, visible = True As Boolean)
    row = m.RowItems[rowIndex]
    If row <> invalid Then
        row.IsVisible = visible
        If m.Screen <> invalid Then
            m.Screen.SetListVisible(rowIndex, visible)
            ' Sleep for a short bit to workaround a hard crash issue that
            ' happens if rows are hidden too quickly after one another
            Sleep(250)
            If Not visible Then
                ' We hid a row, so load the surrounding rows
                m.LoadRows(rowIndex, 1, m.LoadAsync)
            End If
        End If
    End If
End Sub

Function GridScreen_GetListVisible(rowIndex As Integer) As Boolean
    row = m.RowItems[rowIndex]
    If row <> invalid Then
        Return AsBoolean(row.IsVisible, True)
    End If
    Return False
End Function

Sub GridScreen_SetListOffset(rowIndex As Integer, itemIndex As Integer)
    row = m.RowItems[rowIndex]
    If row <> invalid Then
        row.SelectedIndex = itemIndex
        If m.Screen <> invalid Then
            If rowIndex = m.RowIndex Then
                ' This is the current row, so set the focus item, so we
                ' get an isListItemFocused event
                m.Screen.SetFocusedListItem(rowIndex, itemIndex)
            Else
                m.Screen.SetListOffset(rowIndex, itemIndex)
            End If
        End If
    End If
End Sub

Sub GridScreen_SetFocusedListItem(rowIndex As Integer, itemIndex As Integer, force = False As Boolean)
    row = m.RowItems[rowIndex]
    If force Or (row <> invalid And row.IsLoaded = True And row.ContentList <> invalid) Then
        m.RowIndex = rowIndex
        If row = invalid Or row.ContentList = invalid Or itemIndex >= row.ContentList.Count() Then
            itemIndex = 0
        End If
        m.ItemIndex = itemIndex
        If m.Screen <> invalid Then
            m.Screen.SetFocusedListItem(m.RowIndex, m.ItemIndex)
        End If
    End If
End Sub

Function GridScreen_GetFocusedListItem() As Object
    row = m.RowItems[m.RowIndex]
    If row <> invalid Then
        If row.ContentList <> invalid Then
            Return row.ContentList[m.ItemIndex]
        End If
    End If
    Return invalid
End Function

Function GridScreen_GetRowIndex(id As String) As Integer
    Return FindElementIndexInArray(m.RowItems, id, "ID")
End Function

Function GridScreen_GetFocusedRowIndex() As Integer
    Return m.RowIndex
End Function

Function GridScreen_GetFocusedRow() As Object
    If m.RowItems <> invalid Then
        Return m.RowItems[m.RowIndex]
    End If
    Return invalid
End Function

Sub GridScreen_ReloadRow(rowIndexOrID As Dynamic, async = m.LoadAsync As Boolean, showIfHidden = True As Boolean, resetIndex = False As Boolean)
    rowIndex = AsInteger(rowIndexOrID)
    If IsString(rowIndexOrID) Then
        rowIndex = m.GetRowIndex(rowIndexOrID)
    End If
    row = m.RowItems[rowIndex]
    If row <> invalid Then
        row.IsLoading = False
        row.IsLoaded = False
        If resetIndex Then
            row.SelectedIndex = 0
        End If
        If showIfHidden And row.IsVisible = False Then
            m.SetListVisible(rowIndex, True)
        End If
        m.LoadRows(rowIndex, 0, async)
    End If
End Sub

Sub GridScreen_LoadRows(rowIndex As Integer, threshold = 0 As Integer, async = True As Boolean)
    ' Raise the row loading event for the current row (if necessary)
    row = m.RowItems[rowIndex]
    If row <> invalid And row.IsLoading <> True And (row.ContentList = invalid Or row.IsLoaded = False) Then
        row.IsLoading = True
        m.RaiseEvent("RowLoading" + IIf(async, "Async", ""), m.GetBaseEventData(rowIndex, AsInteger(row.SelectedIndex)))
        If row.SelectedIndex <> invalid Then
            m.SetListOffset(rowIndex, row.SelectedIndex)
        End If
    End If
    ' Raise the row loading events for the surrounding rows (if necessary)
    If async Then
        For i = 1 To threshold
            If rowIndex - i >= 0 Then
                row = m.RowItems[rowIndex - i]
                If row <> invalid And row.IsLoading <> True And (row.ContentList = invalid Or row.IsLoaded = False) Then
                    row.IsLoading = True
                    m.RaiseEvent("RowLoading" + IIf(async, "Async", ""), m.GetBaseEventData(rowIndex - i, AsInteger(row.SelectedIndex)))
                Else If row <> invalid And row.IsVisible = False Then
                    ' This row isn't visible, so bump the threshold up one
                    threshold = threshold + 1
                End If
            End If
            If rowIndex + i < m.RowItems.Count() Then
                row = m.RowItems[rowIndex + i]
                If row <> invalid And row.IsLoading <> True And (row.ContentList = invalid Or row.IsLoaded = False) Then
                    row.IsLoading = True
                    m.RaiseEvent("RowLoading" + IIf(async, "Async", ""), m.GetBaseEventData(rowIndex + i, AsInteger(row.SelectedIndex)))
                Else If row <> invalid And row.IsVisible = False Then
                    ' This row isn't visible, so bump the threshold up one
                    threshold = threshold + 1
                End If
            End If
        Next
    End If
End Sub

Function GridScreen_OnEvent(eventData As Object, callbackData = invalid As Object) As Boolean
    ' Retrieve the message via the key, to avoid Eclipse parser errors
    msg = eventData["Event"]
    If Type(msg) = "roGridScreenEvent" Then
        If msg.IsScreenClosed() Then
            Return m.Dispose()
        Else If msg.IsListItemFocused() Then
            m.InitialLoad = False
            m.RowIndex = msg.GetIndex()
            m.ItemIndex = msg.GetData()
            ' Store the row's current selected index
            row = m.RowItems[m.RowIndex]
            If row <> invalid Then
                row.SelectedIndex = m.ItemIndex
            End If
            ' Make sure the surrounding rows have been populated, if they're already marked as loaded
            For i = -1 To 1
                rowIndex = m.RowIndex + i
                row = m.RowItems[rowIndex]
                If row <> invalid And row.IsLoaded = True And row.ContentList <> invalid And m.PopulatedRows[rowIndex] <> True Then
                    m.SetContentList(rowIndex, row.ContentList)
                End If
            Next
            ' Raise the list item focused event
            m.RaiseEvent("ListItemFocused", m.GetBaseEventData())
            ' Load the current and surrounding rows
            If m.LoadAsync Then
                m.LoadRows(m.RowIndex, m.RowLoadThreshold, True)
            Else
                m.LoadIndex = m.RowIndex
            End If
        Else If msg.IsListItemSelected() Then
            m.RowIndex = msg.GetIndex()
            m.ItemIndex = msg.GetData()
            ' Raise the list item selected event
            data = m.GetBaseEventData()
            If data.Item <> invalid And data.Item.ID <> m.LoadingItemID Then
                m.RaiseEvent("ListItemSelected", data)
            End If
        Else If msg.IsRemoteKeyPressed() Then
            data = m.GetBaseEventData()
            data.RemoteKey = msg.GetIndex()
            ' Raise the remote key pressed event
            m.RaiseEvent("RemoteKeyPressed", data)
        End If
    Else If msg = invalid Then
        If m.InitialLoad And eventData.IdleTime > 1000 And m.RowItems <> invalid Then
            ' It's been over a second and we're still in an initial load state,
            ' so go ahead and raise a ListItemFocused event
            m.InitialLoad = False
            m.RaiseEvent("ListItemFocused", m.GetBaseEventData())
        End If
        If Not m.InitialLoad And eventData.IdleTime > 250 And m.RowItems <> invalid Then
            If m.LoadAsync Then
                ' Load the current and surrounding rows
                m.LoadRows(m.RowIndex, m.RowLoadThreshold, True)
            Else If Not m.AllLoaded Then
                found = False
                For i = 0 To m.RowItems.Count() - 1
                    loadIndex = (m.LoadIndex + i) Mod m.RowItems.Count()
                    row = m.RowItems[loadIndex]
                    If row <> invalid And (row.ContentList = invalid Or row.IsLoaded = False) And row.IsLoading <> True Then
                        found = True
                        m.LoadIndex = loadIndex
                        m.LoadRows(loadIndex, 0, False)
                        Exit For
                    End If
                Next
                If Not found Then
                    m.AllLoaded = True
                End If
            End If
        End If
    End If
    Return True
End Function

Function GridScreen_GetBaseEventData(rowIndex = m.RowIndex As Integer, itemIndex = m.ItemIndex As Integer) As Object
    eventData = {
        RowItems:   m.RowItems
        RowIndex:   rowIndex
        ItemIndex:  itemIndex
        Row:        invalid
        Item:       invalid
    }
    If m.RowItems <> invalid Then
        eventData.Row = m.RowItems[rowIndex]
    End If
    If eventData.Row <> invalid And eventData.Row.ContentList <> invalid Then
        eventData.Item = eventData.Row.ContentList[itemIndex]
    End If
    Return eventData
End Function
