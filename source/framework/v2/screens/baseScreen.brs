'IMPORTS=v2/base/object v2/base/observable v2/events/eventListener v2/screens/screenManager v2/base/inheritance
' ******************************************************
' Copyright Steven Kean 2010-2015
' All Rights Reserved.
' ******************************************************
Function NewBaseScreen(screenType As String, events = [] As Object) As Object
    this                        = NewObservable()
    this.Append(NewObject())
    
    this.ClassName              = "BaseScreen"
    this.ScreenID               = GenerateGuid()
    
    this.MessagePort            = CreateObject("roMessagePort")
    this.EventPort              = invalid
    this.ScreenType             = screenType
    this.Screen                 = invalid
    this.Events                 = AsArray(events)
    
    this.Initialized            = False
    this.Disposed               = False

    this.Initialize             = BaseScreen_Initialize
    this.InitializeScreen       = BaseScreen_InitializeScreen
    this.Dispose                = BaseScreen_Dispose
    
    this.GetEventPort           = BaseScreen_GetEventPort

    this.Show                   = BaseScreen_Show
    this.Close                  = BaseScreen_Close
    
    this.SetBreadcrumbText      = BaseScreen_SetBreadcrumbText
    
    this.IsTopMost              = BaseScreen_IsTopMost
    
    this.OnZOrderChange         = BaseScreen_OnZOrderChange
    this.OnEvent                = BaseScreen_OnEvent
    
    this.GetBaseEventData       = BaseScreen_GetBaseEventData
    
    Return this
End Function

Sub BaseScreen_Initialize()
    If Not m.Initialized Or m.Screen = invalid Then
        If Not IsNullOrEmpty(m.ScreenType) And m.Screen = invalid Then
            m.Screen = CreateObject(m.ScreenType)
            m.Screen.SetMessagePort(m.MessagePort)
        End If
        ' Initialize the event port
        m.GetEventPort()
        ' Initialize the screen
        m.InitializeScreen()
        ' Add the screen to the screen manager
        ScreenManager().AddScreen(m)
    End If
    m.Initialized = True
    m.Disposed = False
End Sub

Sub BaseScreen_InitializeScreen()
    If IsHttpAgent(m.Screen) Then
        m.Screen.SetCertificatesFile("common:/certs/ca-bundle.crt")
    End If
End Sub

Function BaseScreen_Dispose() As Boolean
    If Not m.Disposed Then
        If m.Initialized Then
            If m.Screen <> invalid Then
                m.Screen.Close()
            End If
            m.Screen = invalid
            For Each eventName In m.Events
                EventListener().UnregisterObserver(m, eventName)
            Next
            EventListener().UnregisterPort(m.EventPort)
            m.EventPort = invalid
        End If
        m.Initialized = False
        m.Disposed = True
        ' Remove the screen from the screen manager
        ScreenManager().RemoveScreen(m)
    
        Return m.RaiseEvent("Disposed") <> False
    End If
    Return True
End Function

Function BaseScreen_GetEventPort() As Object
    If m.EventPort = invalid Then
        m.EventPort = EventListener().RegisterPort(m.MessagePort)
        For Each eventName In m.Events
            EventListener().RegisterObserver(m, eventName, "OnEvent", invalid, True, m.EventPort)
        Next
    End If
    Return m.EventPort
End Function

Sub BaseScreen_Show()
    If Not m.Initialized Then
        m.Initialize()
    End If
    If m.Screen <> invalid Then
        m.Screen.Show()
    End If
End Sub

Sub BaseScreen_Close()
    If m.Screen <> invalid Then
        ' TODO: Exclude components that don't support close
        m.Screen.Close()
    End If
End Sub

Sub BaseScreen_SetBreadcrumbText(breadcrumbA = "" As String, breadcrumbB = "" As String)
    m.Set("BreadcrumbA", breadcrumbA)
    m.Set("BreadcrumbB", breadcrumbB)
    If m.Screen <> invalid Then
        ' TODO: exclude screen types that don't support breadcrumbs
        m.Screen.SetBreadcrumbText(breadcrumbA, breadcrumbB)
    End If
End Sub

Function BaseScreen_IsTopMost() As Boolean
    Return ScreenManager().PeekScreen().ScreenID = m.ScreenID
End Function

Sub BaseScreen_OnZOrderChange(topMost As Boolean)
    If topMost Then
        m.RaiseEvent("Shown")
    Else
        m.RaiseEvent("Hidden")
    End If
End Sub

Function BaseScreen_OnEvent(eventData As Object, callbackData As Object) As Boolean
    ' Retrieve the message via the key, to avoid Eclipse parser errors
    msg = eventData["Event"]
    If msg <> invalid Then
        If msg.IsScreenClosed() Then
            Return m.Dispose()
        End If
    End If
    Return True
End Function

Function BaseScreen_GetBaseEventData() As Object
    eventData = {}
    Return eventData
End Function
