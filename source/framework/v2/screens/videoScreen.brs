'IMPORTS=v2/screens/baseScreen
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
Function NewVideoScreen() As Object
    this                                = NewBaseScreen("roVideoScreen", ["Idle", "roVideoScreenEvent"])
    this.ClassName                      = "VideoScreen"

    this.ContentList                    = invalid
    this.ItemIndex                      = 0
    this.PositionNotificationPeriod     = 0
    this.Cookies                        = ""
    this.Position                       = 0
    this.Wrap                           = False
    
    this.IgnoreClose                    = False
    this.IsPaused                       = False
    
    this.InitializeScreen               = PreserveBase(this, "InitializeScreen", VideoScreen_InitializeScreen)
    this.Show                           = VideoScreen_Show
    this.Close                          = PreserveBase(this, "Close", VideoScreen_Close)
    this.Dispose                        = PreserveBase(this, "Dispose", VideoScreen_Dispose)

    this.SetContent                     = VideoScreen_SetContent
    this.GetContent                     = VideoScreen_GetContent
    this.GetContentIndex                = VideoScreen_GetContentIndex
    this.SetContentList                 = VideoScreen_SetContentList
    this.UpdateContent                  = VideoScreen_UpdateContent
    
    this.SetPositionNotificationPeriod  = VideoScreen_SetPositionNotificationPeriod
    this.EnableTrickPlay                = VideoScreen_EnableTrickPlay
    
    this.SetCookies                     = VideoScreen_SetCookies
    
    this.SetWrap                        = VideoScreen_SetWrap
    this.SetNext                        = VideoScreen_SetNext
    
    this.Pause                          = VideoScreen_Pause
    this.Resume                         = VideoScreen_Resume

    this.OnEvent                        = VideoScreen_OnEvent
    
    this.GetBaseEventData               = VideoScreen_GetBaseEventData
    
    Return this
End Function

Sub VideoScreen_InitializeScreen()
    m.CallBase("InitializeScreen")
    m.Canvas = CreateObject("roImageCanvas")
    m.Canvas.SetLayer(0, { Color: "#000000" })
    m.Canvas.Show()
    If m.Screen <> invalid Then
        m.Screen.SetPositionNotificationPeriod(1)
        If m.ContentList <> invalid Then
            If m.PositionNotificationPeriod <> invalid Then
                m.SetPositionNotificationPeriod(m.PositionNotificationPeriod)
            End If
            If Not IsNullOrEmpty(m.Cookies) Then
                m.Screen.AddHeader("cookie", m.Cookies)
            End If
            m.SetContentList(m.ContentList, AsInteger(m.ItemIndex))
            m.EnableTrickPlay(m.Get("TrickPlayEnabled", True))
        End If
    End If
End Sub

Sub VideoScreen_Show()
    If Not m.Initialized Then
        m.Initialize()
    End If
    If Not m.SetNext(m.ItemIndex) Then
        m.Close()
    End If
End Sub

Sub VideoScreen_Close(ignoreClose = False As Boolean)
    If ignoreClose Then
        m.IgnoreClose = ignoreClose
        m.Screen.Close()
    Else
        m.CallBase("Close")
    End If
End Sub

Function VideoScreen_Dispose() As Boolean
    m.Canvas = invalid
    Return m.CallBase("Dispose")
End Function

Sub VideoScreen_SetContent(content As Object)
    m.SetContentList([content])
End Sub

Function VideoScreen_GetContent() As Object
    If m.ContentList <> invalid Then
        Return m.ContentList[m.ItemIndex]
    End If
    Return invalid
End Function

Function VideoScreen_GetContentIndex() As Integer
    Return m.ItemIndex
End Function

Sub VideoScreen_SetContentList(contentList As Object, index = 0 As Integer)
    m.Set("ContentList", AsArray(contentList))
    m.Set("ItemIndex", index)
    content = m.ContentList[index]
    If content <> invalid And m.Screen <> invalid Then
        m.Screen.SetContent(content)
    End If
End Sub

Sub VideoScreen_UpdateContent(content As Object)
    m.ContentList[m.ItemIndex] = content
End Sub

Sub VideoScreen_SetPositionNotificationPeriod(period As Integer)
    m.Set("PositionNotificationPeriod", period)
End Sub

Sub VideoScreen_EnableTrickPlay(enable As Boolean)
    m.Set("TrickPlayEnabled", enable)
    If m.Screen <> invalid And CheckFirmware(5) >= 0 Then
        m.Screen.EnableTrickPlay(enable)
    End If
End Sub

Sub VideoScreen_SetCookies(cookies As String)
    m.Cookies = cookies
End Sub

Sub VideoScreen_SetWrap(wrap = True As Boolean)
    m.Wrap = wrap
End Sub

Function VideoScreen_SetNext(index As Integer) As Boolean
    If m.Wrap Then
        index = index Mod m.ContentList.Count()
    End If
    If index < m.ContentList.Count() Then
        m.ItemIndex = index
        If m.RaiseEvent("BeforeNewContent", m.GetBaseEventData()) <> False Then
            m.Screen = CreateObject(m.ScreenType)
            m.Screen.SetMessagePort(m.MessagePort)
            m.InitializeScreen()
            m.Screen.Show()

            Return True
        End If
    End If
    Return False
End Function

Sub VideoScreen_Pause()
    If m.Screen <> invalid Then
        m.Screen.Pause()
    End If
End Sub

Sub VideoScreen_Resume()
    If m.Screen <> invalid Then
        m.Screen.Resume()
    End If
End Sub

Function VideoScreen_OnEvent(eventData As Object, callbackData = invalid As Object) As Boolean
    ' Retrieve the message via the key, to avoid Eclipse parser errors
    msg = eventData["Event"]
    If Type(msg) = "roVideoScreenEvent" Then
        If msg.IsScreenClosed() Then
            If Not m.IgnoreClose Then
                Return m.Dispose()
            End If
            m.IgnoreClose = False
        Else If msg.IsStatusMessage() Then
            message = msg.GetMessage()
            If message = "startup progress" Then
                callbackData = m.GetBaseEventData()
                callbackData.Percentage = Int(msg.GetIndex() / 10)
                m.RaiseEvent("Buffer", callbackData, msg)
            Else
            End If
        Else If msg.IsStreamStarted() Then
            info = msg.GetInfo()
            If info.IsUnderrun Then
                m.RaiseEvent("Rebuffer", m.GetBaseEventData(), msg)
            Else
                If Not m.IsPaused Then
                    m.RaiseEvent("Start", m.GetBaseEventData(), msg)
                End If
            End If
        Else If msg.IsPlaybackPosition() Then
            oldPosition = m.Position
            m.Position = msg.GetIndex()
            callbackData = m.GetBaseEventData()
            If m.IsPaused Then
                m.IsPaused = False
                callbackData.OldPosition = oldPosition
                m.RaiseEvent("Skip", callbackData, msg)
            Else
                content = m.GetContent()
                If AsInteger(content.Length) > 0 Then
                    quarts = AsInteger(content.Length) / 4
                    If m.Position = Int(quarts) Then
                        m.RaiseEvent("FirstQuartile", callbackData, msg)
                    Else If m.Position = Int(quarts * 2) Then
                        m.RaiseEvent("Midpoint", callbackData, msg)
                    Else If m.Position = Int(quarts * 3) Then
                        m.RaiseEvent("ThirdQuartile", callbackData, msg)
                    End If
                End If
                If m.PositionNotificationPeriod > 0 And m.Position Mod m.PositionNotificationPeriod = 0 Then
                    ' We have a position notification, so raise the OnPlaybackPosition event
                    m.RaiseEvent("PositionNotification", callbackData, msg)
                End If
            End If
        Else If msg.IsRequestFailed() Then
            callbackData = m.GetBaseEventData()
            callbackData.Code = msg.GetIndex()
            callbackData.Message = msg.GetMessage()
            callbackData.Info = msg.GetInfo()
            m.RaiseEvent("Error", callbackData, msg)
        Else If msg.IsFullResult() Then
            m.RaiseEvent("Complete", m.GetBaseEventData(), msg)
            m.IgnoreClose = m.SetNext(m.ItemIndex + 1)
        Else If msg.IsPartialResult() Then
            m.RaiseEvent("Close", m.GetBaseEventData(), msg)
        Else If msg.IsPaused() Then
            m.IsPaused = True
            m.RaiseEvent("Pause", m.GetBaseEventData(), msg)
        Else If msg.IsResumed() Then
            m.IsPaused = False
            m.RaiseEvent("Resume", m.GetBaseEventData(), msg)
        'Else If msg.IsStreamSegmentInfo() Then
        'Else If msg.IsTimedMetaData() Then
        End If
    End If
    Return True
End Function

Function VideoScreen_GetBaseEventData(itemIndex = m.ItemIndex As Integer, msg = invalid As Object) As Object
    eventData = {
        ContentList:    m.ContentList
        ItemIndex:      itemIndex
        Item:           invalid
        Position:       m.Position
    }
    If eventData.ContentList <> invalid Then
        eventData.Item = eventData.ContentList[itemIndex]
    End If
    Return eventData
End Function
