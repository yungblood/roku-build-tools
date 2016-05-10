'IMPORTS=v2/screens/messageDialog
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
'=====================
' Dialogs
'=====================
Function ShowRetrievingFacade(message = "Retrieving..." As String, breadcrumbA = "" As String, breadcrumbB = "" As String, show = True As Boolean) As Object
    waitDialog = CreateObject("roPosterScreen")
    waitDialog.SetBreadcrumbText(breadcrumbA, breadcrumbB)
    waitDialog.ShowMessage(message)
    If show Then
        waitDialog.Show()
    End If
    Return waitDialog
End Function

Function ShowWaitDialog(message = "Please wait..." As String, minimumDisplayTime = 0 As Integer) As Object
    waitDialog = CreateObject("roOneLineDialog")
    waitDialog.SetTitle(message)
    waitDialog.ShowBusyAnimation()
    waitDialog.Show()
    
    ' Sleep long enough for the dialog to initialize
    Sleep(100)
    ' Call show again, as some screens (mainly mixed-aspect grid screen) don't
    '  like to show the dialog without the above sleep
    waitDialog.Show()
    
    If minimumDisplayTime > 0 Then
        Sleep(minimumDisplayTime)
    End If
    Return waitDialog
End Function

Function ShowCancellableWaitDialog(message = "Please wait..." As String, enableOverlay = False As Boolean) As Object
    waitDialog = CreateObject("roMessageDialog")
    waitDialog.SetMessagePort(CreateObject("roMessagePort"))
    waitDialog.SetTitle(message)
    waitDialog.EnableOverlay(enableOverlay)
    waitDialog.ShowBusyAnimation()
    waitDialog.AddButton(0, "Cancel")
    waitDialog.Show()
    Return waitDialog
End Function

Function ShowMultilineWaitDialog(message = "Please wait..." As String, title = "" As String, enableOverlay = False As Boolean) As Object
    waitDialog = CreateObject("roMessageDialog")
    waitDialog.SetMessagePort(CreateObject("roMessagePort"))
    If Not IsNullOrEmpty(title) Then
        waitDialog.SetTitle(title)
    End If
    If Not IsNullOrEmpty(message) Then
        waitDialog.SetText(message)
    End If
    waitDialog.EnableOverlay(enableOverlay)
    waitDialog.ShowBusyAnimation()
    waitDialog.Show()
    Return waitDialog
End Function

Function ShowMessageBoxWithTimeout(title As String, message As String, timeout As Integer, buttons = ["OK"], enableOverlay = False As Boolean, topLeft = False As Boolean) As Dynamic
    Return ShowMessageBox(title, message, buttons, enableOverlay, topLeft, 0, timeout)
End Function

Function ShowMessageBox(title As String, message As String, buttons = ["OK"], enableOverlay = False As Boolean, topLeft = False As Boolean, defaultButton = 0 As Integer, timeout = 0 As Integer, enableBackButton = True As Boolean, enableOptionsExit = False As Boolean) As Dynamic
    ' Callback object to handle callbacks from the message
    ' dialog, and store its results
    callback = {
        Result:             invalid
        Timeout:            timeout
        ExitOnOptions:      enableOptionsExit
        OnButtonPressed:    Function(eventData As Object, callbackData = invalid As Object)
                                m.Result = eventData.Button
                                eventData.Sender.Close()
                            End Function
        OnRemoteKeyPressed: Function(eventData As Object, callbackData = invalid As Object)
                                If eventData.RemoteKey = 10 And m.ExitOnOptions Then
                                    eventData.Sender.Close()
                                End If
                            End Function
        OnDisposed:         Function(eventData As Object, callbackData = invalid As Object)
                                Return False
                            End Function
    }
    
    messageBox = NewMessageDialog()

    If Not IsNullOrEmpty(title) Then
        messageBox.SetTitle(title)
    End If
    messageBox.EnableOverlay(enableOverlay)
    messageBox.SetMenuTopLeft(topLeft)
    messageBox.EnableBackButton(enableBackButton)
    
    If Not IsNullOrEmpty(message) Then
        messageBox.SetText(message)
    End If

    messageBox.SetButtons(buttons)
    messageBox.SetFocusedMenuItem(defaultButton)
    
    messageBox.RegisterObserver(callback, "ButtonPressed", "OnButtonPressed")
    messageBox.RegisterObserver(callback, "RemoteKeyPressed", "OnRemoteKeyPressed")
    messageBox.RegisterObserver(callback, "Disposed", "OnDisposed")
    
    messageBox.Show()

    timer = CreateObject("roTimespan")
    ' Block on this dialog's event port
    While EventListener().ListenForOne(messageBox.GetEventPort())
        ' Wait for user interaction or timeout
        If timeout > 0 And timeout <= timer.TotalMilliseconds() Then
            messageBox.Close()
        End If
    End While
    
    Return callback.Result
End Function

Function ShowModalKeyboardScreen(title As String, displayText As String, text = "" As String, buttons = ["OK"] As Object) As Object
    ' Callback object to handle callbacks from the message
    ' dialog, and store its results
    callback = {
        Result:             invalid
        OnButtonPressed:    Function(eventData As Object, callbackData = invalid As Object)
                                m.Result = {
                                    Button: eventData.Button
                                    Text:   eventData.Text
                                }
                                eventData.Sender.Close()
                            End Function
        OnDisposed:         Function(eventData As Object, callbackData = invalid As Object)
                                Return False
                            End Function
    }
    
    keyboardScreen = NewKeyboardScreen()
    If Not IsNullOrEmpty(title) Then
        keyboardScreen.SetTitle(title)
    End If
    If Not IsNullOrEmpty(displayText) Then
        keyboardScreen.SetDisplayText(displayText)
    End If
    If Not IsNullOrEmpty(text) Then
        keyboardScreen.SetText(text)
    End If

    keyboardScreen.SetButtons(buttons)
    
    keyboardScreen.RegisterObserver(callback, "ButtonPressed", "OnButtonPressed")
    keyboardScreen.RegisterObserver(callback, "Disposed", "OnDisposed")
    
    keyboardScreen.Show()

    ' Block on this screen's event port
    While EventListener().ListenForOne(keyboardScreen.GetEventPort())
    End While
    
    Return callback.Result
End Function

