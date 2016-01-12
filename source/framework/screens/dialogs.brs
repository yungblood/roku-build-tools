'IMPORTS=screens/messageDialog
' ******************************************************
' Copyright Steven Kean 2010-2015
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
        OnButtonPressed:    Function(button As Object, sender As Object) As Boolean
                                m.Result = button
                                Return True
                            End Function
        OnIdle:             Function(idleTime As Integer, sender As Object)
                                sender.Close()
                            End Function
        OnInfoPressed:      Function(button As Object, sender As Object)
                                If m.ExitOnOptions Then
                                    sender.Close()
                                End If
                            End Function
    }
    
    messageBox = NewMessageDialog(callback)
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
    
    messageBox.SetIdleInterval(timeout)
    messageBox.Show(True, Not enableOverlay)

    Return callback.Result
End Function
