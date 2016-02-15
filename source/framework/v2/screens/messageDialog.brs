'IMPORTS=utilities/rects v2/screens/baseScreen
' ******************************************************
' Copyright Steven Kean 2010-2015
' All Rights Reserved.
' ******************************************************
Function NewMessageDialog() As Object
    this                            = NewBaseScreen("roMessageDialog", "roMessageDialogEvent")
    this.ClassName                  = "MessageDialog"
    
    this.Buttons                    = []

    this.InitializeScreen           = MessageDialog_InitializeScreen

    this.SetTitle                   = MessageDialog_SetTitle
    this.SetText                    = MessageDialog_SetText
    
    this.ShowBusyAnimation          = MessageDialog_ShowBusyAnimation
    this.EnableOverlay              = MessageDialog_EnableOverlay
    this.EnableBackButton           = MessageDialog_EnableBackButton
    this.SetMenuTopLeft             = MessageDialog_SetMenuTopLeft
    this.SetFocusedMenuItem         = MessageDialog_SetFocusedMenuItem
    
    this.AddButton                  = MessageDialog_AddButton
    this.SetButtons                 = MessageDialog_SetButtons
    
    this.OnEvent                    = MessageDialog_OnEvent

    Return this
End Function

Sub MessageDialog_InitializeScreen()
    If m.Screen <> invalid Then
        If Not IsNullOrEmpty(m.Get("Title", "")) Then
            m.SetTitle(m.Get("Title", ""))
        End If
        If Not IsNullOrEmpty(m.Get("Text", "")) Then
            m.SetText(m.Get("Text", ""))
        End If
        If m.Get("BusyAnimation", False) Then
            m.ShowBusyAnimation()
        End If
        m.EnableOverlay(m.Get("OverlayEnabled", False))
        m.EnableBackButton(m.Get("BackButtonEnabled", False))
        m.SetMenuTopLeft(m.Get("MenuTopLeft", False))
        m.SetFocusedMenuItem(m.Get("FocusedMenuItem", 0))

        buttons = []
        buttons.Append(m.Buttons)
        m.SetButtons(buttons)
    End If
End Sub

Sub MessageDialog_SetTitle(title As String)
    m.Set("Title", title)
    If m.Screen <> invalid Then
        m.Screen.SetTitle(title)
    End If
End Sub

Sub MessageDialog_SetText(text As String)
    m.Set("Text", text)
    If m.Screen <> invalid Then
        m.Screen.SetText(text)
    End If
End Sub

Sub MessageDialog_ShowBusyAnimation()
    m.Set("BusyAnimation", True)
    If m.Screen <> invalid Then
        m.Screen.ShowBusyAnimation()
    End If
End Sub

Sub MessageDialog_EnableOverlay(enable = True As Boolean)
    m.Set("OverlayEnabled", enable)
    If m.Screen <> invalid Then
        m.Screen.EnableOverlay(enable)
    End If
End Sub

Sub MessageDialog_EnableBackButton(enable = True As Boolean)
    m.Set("BackButtonEnabled", enable)
    If m.Screen <> invalid Then
        m.Screen.EnableBackButton(enable)
    End If
End Sub

Sub MessageDialog_SetMenuTopLeft(topLeft = True As Boolean)
    m.Set("MenuTopLeft", topLeft)
    If m.Screen <> invalid Then
        m.Screen.SetMenuTopLeft(topLeft)
    End If
End Sub

Sub MessageDialog_SetFocusedMenuItem(index As Integer)
    m.Set("FocusedMenuItem", index)
    If m.Screen <> invalid Then
        m.Screen.SetFocusedMenuItem(index)
    End If
End Sub

Sub MessageDialog_AddButton(button As Object)
    m.Buttons.Push(button)
    buttonIndex = m.Buttons.Count() - 1
    If m.Screen <> invalid Then
        If IsString(button) Then
            If button = "separator" Then
                ' Separator is not available on older boxes
                If Not IsRokuOne() Then
                    m.Screen.AddButtonSeparator()
                End If
            Else
                m.Screen.AddButton(buttonIndex, button)
            End If
        Else
            If button.Type = "rating" Then
                ' This is a ratings button, so add a ratings button
                m.Screen.AddRatingButton(buttonIndex, button.UserRating, button.AggregateRating, "")
            Else
                If button.Text = "separator" Then
                    ' Separator is not available on older boxes
                    If Not IsRokuOne() Then
                        m.Screen.AddButtonSeparator()
                    End If
                Else
                    ' We're not sure what type of button this is, so treat it
                    ' as a standard label button
                    m.Screen.AddButton(buttonIndex, button.Text)
                End If
            End If
        End If
    End If
End Sub

Sub MessageDialog_SetButtons(buttons As Object)
    m.Buttons.Clear()
    For Each button In buttons
        m.AddButton(button)
    Next
End Sub

Function MessageDialog_OnEvent(eventData As Object, callbackData = invalid As Object) As Boolean
    ' Retrieve the message via the key, to avoid Eclipse parser errors
    msg = eventData["Event"]
    If Type(msg) = "roMessageDialogEvent" Then
        If msg.IsScreenClosed() Then
            Return m.Dispose()
        Else If msg.IsButtonPressed() Then
            data = m.GetBaseEventData()
            data.ButtonIndex    = msg.GetIndex()
            data.Buttons        = m.Buttons
            data.Button         = m.Buttons[data.ButtonIndex]
            ' Raise the button pressed event
            m.RaiseEvent("ButtonPressed", data)
        Else If msg.IsRemoteKeyPressed() Or msg.IsButtonInfo() Then
            data = m.GetBaseEventData()
            data.RemoteKey = IIf(msg.IsButtonInfo(), 10, msg.GetIndex())
            
            ' Raise the remote key pressed event
            m.RaiseEvent("RemoteKeyPressed", data)
        End If
    End If
    Return True
End Function
