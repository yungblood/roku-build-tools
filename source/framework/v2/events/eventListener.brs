'IMPORTS=v2/base/globalObjectRegistry v2/events/eventPort v2/events/keyEvents utilities/arrays
' ******************************************************
' Copyright Steven Kean 2010-2015
' All Rights Reserved.
' ******************************************************
Function EventListener() As Object
    If m.EventListener = invalid Then
        this                        = {}
        
        this.IsListening            = False
        this.RequirePrecision       = True
        
        this.RegisteredEvents       = {}
        this.Observers              = []
        this.Ports                  = []
        this.CurrentPort            = 0
        this.LastEventType          = invalid
        this.UserIdleTimer          = CreateObject("roTimespan")
        
        this.UserEvents             = [0, 1, 2, 3, 4, 5, 7, 12, 13, 14, 17, 22, 23]
        this.NonStandardEvents      = ["Idle", "roUniversalControlEvent", "roUrlEvent", "roTextureRequestEvent"]
        
        this.SetRequirePrecision    = EventListener_SetRequirePrecision

        this.GetUserIdleTime        = EventListener_GetUserIdleTime

        this.RegisterPort           = EventListener_RegisterPort
        this.UnregisterPort         = EventListener_UnregisterPort
        this.GetDefaultPort         = EventListener_GetDefaultPort

        this.RegisterObserver       = EventListener_RegisterObserver
        this.UnregisterObserver     = EventListener_UnregisterObserver
        
        this.Listen                 = EventListener_Listen
        this.ListenForOne           = EventListener_ListenForOne
        

        ' Register the default port
        this.EventPort              = NewEventPort()
        this.RegisterPort(this.EventPort)
        
        ' Create a system log
        this.SystemLog              = CreateObject("roSystemLog")
        this.SystemLog.SetMessagePort(this.GetDefaultPort())
        this.SystemLog.EnableType("http.error")
        this.SystemLog.EnableType("http.connect")
        this.SystemLog.EnableType("bandwidth.minute")

        m.EventListener = this
    End If
    Return m.EventListener
End Function

Sub EventListener_SetRequirePrecision(requirePrecision As Boolean)
    m.RequirePrecision = requirePrecision
End Sub

Function EventListener_GetUserIdleTime() As Integer
    Return m.UserIdleTimer.TotalMilliseconds()
End Function

Function EventListener_RegisterPort(eventPort As Object) As Object
    If Type(eventPort) = "roMessagePort" Then
        ' A raw port was passed in, wrap it
        eventPort = NewEventPort(eventPort)
    End If
    If Not ArrayContains(m.Ports, eventPort.ID, "ID") Then
        m.Ports.Push(eventPort)
    End If
    Return eventPort
End Function

Sub EventListener_UnregisterPort(eventPort As Object)
    If IsAssociativeArray(eventPort) Then
        index = FindElementIndexInArray(m.Ports, eventPort.ID, "ID")
        If index > -1 Then
            m.Ports.Delete(index)
        End If
    End If
End Sub

Function EventListener_GetDefaultPort() As Object
    Return m.EventPort.Port
End Function

Sub EventListener_RegisterObserver(observer As Object, event As String, callback As String, callbackData = invalid As Object, allowEventToBubble = True As Boolean, customEventPort = invalid As Object)
    port = m.EventPort
    If customEventPort <> invalid Then
        port = m.RegisterPort(customEventPort)
    End If
    port.RegisterObserver(observer, event, callback, callbackData, allowEventToBubble)
End Sub

Sub EventListener_UnregisterObserver(observer As Object, event As String)
    ' TODO: Support custom event ports?
    For Each port In m.Ports
        port = m.EventPort
        port.UnregisterObserver(observer, event)
    Next
End Sub

Function EventListener_Listen() As Boolean
    If Not m.IsListening Then
        m.IsListening = True
        refreshTimer = CreateObject("roTimespan")
        While m.ListenForOne()
            m.EventPort.RaiseEvent("ScreenRefresh", { LastRefresh: refreshTimer.TotalMilliseconds() })
            refreshTimer.Mark()
        End While
        m.IsListening = False
    End If
End Function

Function EventListener_ListenForOne() As Boolean
    result = True
    For i = 0 To m.Ports.Count() - 1
        m.CurrentPort = (m.CurrentPort + 1) Mod m.Ports.Count()
        eventPort = m.Ports[m.CurrentPort]
        If eventPort <> invalid Then
            ' If we don't require precision, let the system breathe for a millisecond
            msg = eventPort.GetMessage(IIf(m.RequirePrecision, -1, 1))
            If msg <> invalid Or eventPort.Timeout = -1 Or (eventPort.Timeout > 0 And eventPort.EventTimer.TotalMilliseconds() >= eventPort.Timeout) Then
                m.LastEventType = Type(msg)
                eventData = {
                    Event:  msg
                }
                If msg = invalid Then
                    m.LastEventType = "Idle"
                Else
                    eventPort.EventTimer.Mark()
                End If
                eventData.IdleTime = eventPort.EventTimer.TotalMilliseconds()
                eventData.UserIdleTime = m.UserIdleTimer.TotalMilliseconds()
                If m.LastEventType = "roUniversalControlEvent" Then
                    eventData.UserIdleTime = 0
                    m.UserIdleTimer.Mark()
                    result = eventPort.RaiseEvent("KeyEvent", NormalizeKeyEvent(msg))
                End If
                If result <> False Then
                    If msg <> invalid And Not ArrayContains(m.NonStandardEvents, Type(msg)) Then
                        msgType = msg.GetType()
                        If ArrayContains(m.UserEvents, msg.GetType()) Then
                            ' Event type 0 is the isListItemSelected event.  We need to ignore it for screens that auto-advance
                            ' TODO: Find a better way to do this
                            If msg.GetType() <> 0 Or (Type(msg) <> "roAudioPlayerEvent" And Type(msg) <> "roVideoPlayerEvent" And Type(msg) <> "roSlideshowEvent") Then
                                eventData.UserIdleTime = 0
                                m.UserIdleTimer.Mark()
                            End If
                        End If                 
                    End If
                    result = eventPort.RaiseEvent(m.LastEventType, eventData)
                End If

                If Type(msg) = "roSystemLogEvent" Then
                    msgInfo = msg.GetInfo()
                    If msgInfo.LogType = "http.error" Then
                        DebugPrint(msgInfo, msgInfo.LogType, 0)
                    Else If msgInfo.LogType = "http.connect" Then
                        DebugPrint(msgInfo, msgInfo.LogType, 4)
                    Else If msgInfo.LogType = "bandwidth.minute" Then
                        DebugPrint(msgInfo, msgInfo.LogType, 3)
                    End If
                End If
                '?m.LastEventType
            End If
        End If
    Next
    Return (result <> False)
End Function