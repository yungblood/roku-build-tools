'IMPORTS=base/callback base/globals components/webRequestQueue utilities/general utilities/types utilities/arrays utilities/debug
' ******************************************************
' Copyright Steven Kean 2010-2015
' All Rights Reserved.
' ******************************************************
Function NewScreenBase(screenType As String, callbackObject = invalid As Dynamic, callbackPrefix = "" As Dynamic, supportsBreadcrumb = False As Boolean) As Object
    this = {
        Screen:                     invalid
        EventPort:                  CreateObject("roMessagePort")
        IdleTimer:                  CreateObject("roTimeSpan")
        IdleInterval:               1000
        LastIdleNotify:             0
        DelayInterval:              -1
        
        QueuedMessages:             []
        
        ScreenType:                 screenType
        RegisteredEvents:           invalid
        SystemLogEnabled:           True
        WebRequestQueueEnabled:     True
        Listening:                  False
        LastRecordedBandwidth:      0
        PreshowFacade:              invalid
        
        Init:                       Base_Init
        BaseInit:                   Base_Init
        Preshow:                    Base_Preshow
        BasePreshow:                Base_Preshow
        Show:                       Base_Show
        BaseShow:                   Base_Show
        Close:                      Base_Close
        BaseClose:                  Base_Close
        
        RegisterForEvents:          Base_RegisterForEvents
        
        SetMessagePort:             Base_SetMessagePort
        BaseSetMessagePort:         Base_SetMessagePort
        SetIdleInterval:            Base_SetIdleInterval
        BaseSetIdleInterval:        Base_SetIdleInterval
        GetMessage:                 Base_GetMessage
        BaseGetMessage:             Base_GetMessage
        ScrubMessageQueue:          Base_ScrubMessageQueue
        BaseScrubMessageQueue:      Base_ScrubMessageQueue
        ProcessMessageQueue:        Base_ProcessMessageQueue
        BaseProcessMessageQueue:    Base_ProcessMessageQueue
        ListenForEvents:            Base_ListenForEvents
        BaseListenForEvents:        Base_ListenForEvents
        StopListening:              Base_StopListening
        BaseStopListening:          Base_StopListening
        PreProcessMessage:          Base_PreProcessMessage
    }
    
    If supportsBreadcrumb Then
        this.SetBreadcrumbText  = Base_SetBreadcrumbText
        this.BreadcrumbA        = ""
        this.BreadcrumbB        = ""
    End If
    
    ' Register the callback methods for event raising
    RegisterCallback(this, callbackObject, callbackPrefix)
    Return this
End Function

Sub Base_Init()
    If Not IsNullOrEmpty(m.ScreenType) Then
        m.Screen = CreateObject(m.ScreenType)
    End If
    m.SetMessagePort(m.EventPort)
'    ' Set the certificates file, in case we need to load SSL content
'    m.Screen.SetCertificatesFile("common:/certs/ca-bundle.crt")
End Sub

Sub Base_Preshow(message = "Retrieving..." As String)
    If Not IsNullOrEmpty(m.ScreenType) And Eval("m.Screen.ShowMessage(" + Chr(34) + message + Chr(34) + ")") = 252 Then
        m.Screen.Show()
    Else
        ' This screen doesn't support ShowMessage, so show a facade instead
        m.PreshowFacade = CreateObject("roPosterScreen")
        If IsFunction(m.SetBreadcrumbText) Then
            ' Make sure the facade breadcrumb matches the screen's
            breadcrumbA = IIf(IsNullOrEmpty(m.BreadcrumbA), "", m.BreadcrumbA)
            breadcrumbB = IIf(IsNullOrEmpty(m.BreadcrumbB), "", m.BreadcrumbB)
            m.PreshowFacade.SetBreadcrumbText(breadcrumbA, breadcrumbB)
        End If
        m.PreshowFacade.Show()
        m.PreshowFacade.ShowMessage(message)
    End If
    Sleep(100)
End Sub

Sub Base_Show(listenForEvents = True As Boolean)
    If Not IsNullOrEmpty(m.ScreenType) And m.Screen <> invalid Then
        ' Show the screen
        m.Screen.Show()
        ' Clear the preshow
        Eval("m.Screen.ClearMessage()")
    End If
    If m.PreshowFacade <> invalid Then
        m.PreshowFacade.Close()
        m.PreshowFacade = invalid
    End If

    If listenForEvents Then
        m.ListenForEvents()
    End If
End Sub

Sub Base_Close()
    ' Close the screen
    If Not IsNullOrEmpty(m.ScreenType) And m.Screen <> invalid Then
        m.Screen.Close()
    End If
    m.Listening = False
End Sub

Sub Base_RegisterForEvents(events As Object)
    If IsString(events) Then
        m.RegisteredEvents = [events]
    Else If IsArray(events) Then
        m.RegisteredEvents = events
    End If
End Sub

Sub Base_SetMessagePort(port As Object)
    ' Set the screen message port
    If Not IsNullOrEmpty(m.ScreenType) And m.Screen <> invalid Then
        ' Some screens don't have a SetMessagePort method, so try
        ' eval'ing it first, then fail over to SetPort
        If Eval("m.Screen.SetMessagePort(port)") <> 252 Then
            Eval("m.Screen.SetPort(port)")
        End If
    End If
    m.EventPort = port
End Sub

Sub Base_SetIdleInterval(interval As Integer)
    m.IdleInterval = interval
End Sub

Function Base_GetMessage(ignoreWaitCallback = False As Boolean) As Dynamic
    timer = CreateObject("roTimespan")
    timeout = IIf(m.DelayInterval = -1, m.IdleInterval, m.DelayInterval)

    ' Process the web request queue (if enabled)
    If m.WebRequestQueueEnabled Then
        GetWebRequestQueue().ProcessRequests(timeout)
    End If

    port = m.EventPort
    If IsArray(port) Then
        If m.PortIndex = invalid Then
            m.PortIndex = 0
        End If
        port = port[m.PortIndex]
        m.PortIndex = m.PortIndex + 1
        If m.PortIndex >= m.EventPort.Count() Then
            m.PortIndex = 0
        End If
    End If
    msg = invalid
    If Not m.WebRequestQueueEnabled Or timer.TotalMilliseconds() < timeout Then
        If m.SystemLogEnabled Then
            ' Process system log events first
            msg = GetSystemLog().GetMessagePort().GetMessage()
        End If
    
        If msg = invalid Then
            If m.QueuedMessages.Count() > 0 Then
                msg = m.QueuedMessages.Shift()
            Else If Not ignoreWaitCallback And m.CallbackExists("OnWait") Then
                msg = m.Callback("OnWait", port, 5)
            Else If IsFunction(m.InternalWait) Then
                msg = m.InternalWait(timeout, port)
            Else
                msg = Wait(timeout, port)
            End If
        End If
    End If
    Return msg
End Function

Function Base_ScrubMessageQueue(eventType = "" As String, ofType = -1 As Integer) As Boolean
    scrubbedMessages = False
    If m.Listening Then
        queuedMessages = []
        While True
            msg = invalid
            If m.QueuedMessages.Count() > 0 Then
                msg = m.QueuedMessages.Shift()
            Else
                For Each port In AsArray(m.EventPort)
                    msg = port.GetMessage()
                    If msg <> invalid Then
                        Exit For
                    End If
                Next
            End If
            If msg <> invalid Then
                msgType = 0
                If Type(msg) <> "roUniversalControlEvent" Then
                    ' roUniversalControlEvents don't have a GetType method
                    msgType = msg.GetType()
                End If
                If (IsNullOrEmpty(eventType) Or Type(msg) = eventType) And (ofType = -1 Or msgType = ofType) Then
                    ' This message matches the scrub type, so ignore it
                    scrubbedMessages = True
                    DebugPrint(Type(msg) + ": " + AsString(msgType), "Scrubbing Message", 2)
                Else
                    ' This message doesn't match the scrub type, so queue it for processing
                    queuedMessages.Push(msg)
                End If
            Else
                Exit While
            End If
        End While
        m.QueuedMessages.Append(queuedMessages)
    End If
    Return scrubbedMessages
End Function

Function Base_ProcessMessageQueue(ignoreResults = False As Boolean, eatMessages = False As Boolean) As Boolean
    If m.Listening Then
        While True
            msg = invalid
            If m.QueuedMessages.Count() > 0 Then
                msg = m.QueuedMessages.Shift()
            Else
                For Each port In AsArray(m.EventPort)
                    msg = port.GetMessage()
                    If msg <> invalid Then
                        Exit For
                    End If
                Next
            End If
            If msg <> invalid Then
                If Not eatMessages Then
                    result = m.PreProcessMessage(msg)
                    If Not ignoreResults And Not result Then
                        ' The result indicates that we should stop listening, so
                        ' set that flag now
                        m.Listening = result
                    End If
                End If
            Else
                Exit While
            End If
        End While
        Return m.Listening
    End If
    ' We're not listening yet, so just return true
    Return True
End Function

Sub Base_ListenForEvents()
    ' Start listening for events on the assigned message port
    m.Listening = True
    While m.Listening
        m.Listening = m.PreProcessMessage(m.GetMessage())
    End While
End Sub

Sub Base_StopListening()
    m.Listening = False
End Sub

Function Base_PreProcessMessage(msg As Dynamic) As Boolean
    If msg = invalid Then
        If m.IdleTimer.TotalMilliseconds() >= m.IdleInterval And m.IdleTimer.TotalMilliseconds() - m.LastIdleNotify >= m.IdleInterval Then
            m.Callback("OnIdle", m.IdleTimer.TotalMilliseconds(), 5)
            m.LastIdleNotify = m.IdleTimer.TotalMilliseconds()
        End If
        Return m.ProcessMessage(msg) And m.Listening
    Else If ArrayContains(m.RegisteredEvents, Type(msg)) Then
        ' This is one of our events, so reset the idle timer
        m.IdleTimer.Mark()
        m.LastIdleNotify = 0
        Return m.ProcessMessage(msg) And m.Listening
    Else If IsAssociativeArray(msg) And ArrayContains(m.RegisteredEvents, msg.EventType) Then
        ' This is a custom "fake" event, so treat it the same as a real event
        ' The consumer is responsible for knowing the difference
        m.IdleTimer.Mark()
        m.LastIdleNotify = 0
        Return m.ProcessMessage(msg) And m.Listening
    Else If Type(msg) = "roSystemLogEvent" Then
        ' Process system log events
        msgInfo = msg.GetInfo()
        If msgInfo.LogType = "http.error" Then
            DebugPrint(msgInfo, msgInfo.LogType, 2)
            m.Callback("OnHttpError", msgInfo)
        Else If msgInfo.LogType = "http.connect" Then
            DebugPrint(msgInfo, msgInfo.LogType, 3)
            m.Callback("OnHttpConnect", msgInfo)
        Else If msgInfo.LogType = "bandwidth.minute" Then
            DebugPrint(msgInfo, msgInfo.LogType, 3)
            ' Set the global bandwidth
            SetLastRecordedBandwidth(msgInfo.bandwidth)
            m.LastRecordedBandwidth = msgInfo.bandwidth
            m.Callback("OnBandwidthMeasurement", msgInfo)
        End If
    Else
        m.Callback("OnUnknownEvent", msg)
    End If
    Return True
End Function

Sub Base_SetBreadcrumbText(breadcrumbA As String, breadcrumbB = "" As String)
    m.BreadcrumbA = IIf(IsNullOrEmpty(breadcrumbA), "", breadcrumbA)
    m.BreadcrumbB = IIf(IsNullOrEmpty(breadcrumbB), "", breadcrumbB)
    If Not IsNullOrEmpty(m.ScreenType) And m.Screen <> invalid Then
        m.Screen.SetBreadcrumbText(breadcrumbA, breadcrumbB)
    End If
    If m.PreshowFacade <> invalid Then
        m.PreshowFacade.SetBreadcrumbText(breadcrumbA, breadcrumbB)
    End If
End Sub

