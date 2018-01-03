Function App() As Object
    If m.App = invalid Then
        this                            = {}
        this.Run                        = App_Run
        
        this.OnScreenAdded              = App_OnScreenAdded
        this.OnScreenRemoved            = App_OnScreenRemoved
        
        this.OnAuthenticationChanged    = App_OnAuthenticationChanged
        this.OnIdle                     = App_OnIdle
        
        m.App = this
    End If
    Return m.App
End Function

Sub App_Run(ecp = invalid As Object)
    splash = ShowSplashScreen()
    splash.ShowMessage("Loading...")

    ' Register ScreenManager events
    ScreenManager().RegisterObserver(m, "ScreenAdded", "OnScreenAdded")
    ScreenManager().RegisterObserver(m, "ScreenRemoved", "OnScreenRemoved")
    
    ' Register for global event registry events
    GlobalEventRegistry().RegisterObserver(m, "AuthenticationChanged", "OnAuthenticationChanged")
    
    ' We're not doing high framerate drawing, so let the CPU rest between messages
    EventListener().SetRequirePrecision(False)
    EventListener().RegisterObserver(m, "Idle", "OnIdle")
    
    ' Initialize the services
    If Not Cbs().Initialize(Configuration().Get("UseStaging", False)) Then
        ShowMessageBox("Error", "An error occurred when starting this channel. Please check your network connection and try again.", ["OK"], True)
        ExitUserInterface()
    End If

'Configuration().Set(Cbs().AuthTokenKey, "TEST")
' CF Subscriber
'SetCookie("CBS_COM", "VXNlcm5hbWUxNzcyQGNicy5jb206MTQ5NzcyMTkwNTQ3MzpjOTNjMzI1NTkxMWM1M2RkOTBkYTBmZjE3MWE3MjQ0YzoxLjA", Cbs().Endpoint)
' LC Subscriber
'SetCookie("CBS_COM", "VXNlcm5hbWU0NTU4MEBjYnMuY29tOjE0OTc3MjI5NjU1MTI6ODY5NmNkOGQ4NGU1Yzc5NDdhMWQ1M2QxMzI0ODBiYTU6MS4w", Cbs().Endpoint)
' Ex-Subscriber
'Configuration().Set("AuthToken", "blah")
'SetCookie("CBS_COM", "YW5kQGRyb2lkLmNvbToxNTM4NzY5MDgzOTE5OjY4NGQyMjVjZTM4NWUyNzFjZjBkOGEzY2UyNmI1NjJjOjEuMA", Cbs().Endpoint)

    ' Initialize Omniture
    user = Cbs().GetCurrentUser()
    Omniture().Initialize(Cbs().OmnitureSuiteID, user.ID, user.GetStatusForTracking(), user.GetProductForTracking(), Cbs().OmnitureEvar5)
    
    ' Initialize comScore
    CSComScore().log_debug = (GetLogLevel() > 1)
    CSComScore().SetCustomerC2(Cbs().ComScoreC2)
    CSComScore().SetPublisherSecret(Cbs().ComScoreSecret)
    CSComScore().Start()

    While True
        m.Restart = False
     
        ' Process any passed in ECP parameters
        ecpItem = GetEcpItem(ecp)
        ' Skip registration wizard if we're deep-linking
        If Not Cbs().IsAuthenticated() And ecpItem = invalid Then
            If NewRegistrationWizard().Show() = 0 Then
                Exit While
            End If
        End If
        If Not Cbs().IsAuthenticated() Then
            ' The user didn't authenticate, so load the default content now
            Cbs().LoadDefaultContent()
        End If
        
        facade = CreateObject("roPosterScreen")
        facade.ShowMessage("")
        facade.Show()
        
        If ecpItem = invalid Then
            ecp = NewInterstitialScreen().Show()
            If ecp <> invalid Then
                ecpItem = GetEcpItem(ecp)
            End If
        End If

        ' Show the home screen
        listen = NewHomeScreen().Show(ecpItem)
        If listen Then
            ' Start the event loop
            EventListener().Listen()
        End If
        
        If Not m.Restart Then
            Exit While
        End If
    End While
    
    CSComScore().Close()
End Sub

Sub App_OnScreenAdded(eventData As Object, callbackData = invalid As Object)
'    screen = eventData.Screen
'    If screen <> invalid And Not IsNullOrEmpty(screen.AnalyticsCategory) Then
'        ' Track the screen event
'        Analytics().Screen(screen.AnalyticsCategory, screen.AnalyticsName, screen.AnalyticsData)
'    End If
End Sub

Sub App_OnScreenRemoved(eventData As Object, callbackData = invalid As Object)
'    If eventData.TopMost Then
'        screen = ScreenManager().PeekScreen()
'        If screen <> invalid And Not IsNullOrEmpty(screen.AnalyticsCategory) Then
'            ' Track the return to the previous screen
'            Analytics().Screen(screen.AnalyticsCategory, screen.AnalyticsName, screen.AnalyticsData)
'        End If
'    End If
End Sub

Sub App_OnAuthenticationChanged(eventData As Object, callbackData = invalid As Object)
    user = Cbs().GetCurrentUser(True)
    Omniture().Initialize(Cbs().OmnitureSuiteID, user.ID, user.GetStatusForTracking(), user.GetProductForTracking(), Cbs().OmnitureEvar5)    
    Cbs().LoadDefaultContent()
End Sub

Sub App_OnIdle(eventData As Object, callbackData = invalid As Object)
    CSComScore().Tick()
End Sub
