'IMPORTS=base/screenBase utilities/types
' ******************************************************
' Copyright Steven Kean 2010-2015
' All Rights Reserved.
' ******************************************************
Function NewMessageDialog(callbackObject = invalid As Dynamic, callbackPrefix = "" As String) As Object
    this = NewScreenBase("roMessageDialog", callbackObject, callbackPrefix)
    this.RegisterForEvents(["roMessageDialogEvent"])

    '***********************
    ' Properties
    '***********************
    this.Canvas                 = invalid
    this.Buttons                = []
    
    this.Title                  = ""
    this.Text                   = ""
    this.OverlayEnabled         = False
    this.BackEnabled            = False
    this.MenuTopLeft            = False
    this.BusyAnimation          = False
    this.FocusedMenuItem        = 0
    
    ' Disable system log and web request queue events to avoid idle conflicts
    this.SystemLogEnabled       = False
    this.WebRequestQueueEnabled = False
    
    '***********************
    ' Methods
    '***********************
    this.Show                   = MessageDialog_Show
    this.Close                  = MessageDialog_Close
    this.ProcessMessage         = MessageDialog_ProcessMessage
    'this.Refresh                = MessageDialog_Refresh

    ' UI  
    this.SetTitle               = MessageDialog_SetTitle
    this.SetText                = MessageDialog_SetText
    this.EnableOverlay          = MessageDialog_EnableOverlay
    this.EnableBackButton       = MessageDialog_EnableBackButton
    this.SetMenuTopLeft         = MessageDialog_SetMenuTopLeft
    this.ShowBusyAnimation      = MessageDialog_ShowBusyAnimation
    this.SetButtons             = MessageDialog_SetButtons
    this.SetFocusedMenuItem     = MessageDialog_SetFocusedMenuItem

    ' Initialize the dialog
    this.Init()
    Return this
End Function

Sub MessageDialog_Show(listen = True As Boolean, showCanvas = False As Boolean)
    If showCanvas Then
        ' show a clear canvas first, to workaround multi-keypress
        ' issue on grid screen
        m.Canvas = CreateObject("roImageCanvas")
        m.Canvas.SetLayer(0, { Color: "#00000000", TargetRect: { x: 0, y: 0, w: 1, h: 1 } })
        m.Canvas.Show()
        Sleep(50)
    End If
    ' Show the Dialog
    m.BaseShow(False)
    If listen Then
        ' start the event loop
        m.ListenForEvents()
    End If
End Sub

Sub MessageDialog_Close()
    If m.Canvas <> invalid Then
        ' We have a canvas, so close it
        m.Canvas.Close()
    End If
    ' Close the dialog
    m.BaseClose()
End Sub

Function MessageDialog_ProcessMessage(msg As Dynamic) As Boolean
    If Type(msg) = "roMessageDialogEvent" Then
        If msg.IsScreenClosed() Then
            ' The screen is closing, and we're not refreshing, so exit the event loop
            Return False
        Else If msg.IsButtonPressed() Then
            m.FocusedMenuItem = msg.GetIndex()
            button = m.Buttons[m.FocusedMenuItem]
            If Not IsString(button) Then
                ' It's not a standard string/label button, so get the event details
                If button.Type = "rating" Then
                    button.UserRating = msg.GetData()
                End If
            End If
            If m.Callback("OnButtonPressed", button) = True Then
                ' The callback returned true, so close the dialog
                m.Close()
            End If
        Else If msg.IsButtonInfo() Then
            button = m.Buttons[msg.GetIndex()]
            m.Callback("OnInfoPressed", button)
        End If
    End If
    Return True
End Function
'
'Sub MessageDialog_Refresh()
'    ' Save the old dialog, so it doesn't close yet
'    ' and reset its message port to avoid event conflicts
'    oldScreen = m.Screen
'    oldScreen.SetMessagePort(CreateObject("roMessagePort"))
'
'    m.Screen = CreateObject("roMessageDialog")
'    m.Screen.SetMessagePort(m.EventPort)
'    m.EnableOverlay(m.OverlayEnabled)
'    m.EnableBackButton(m.BackEnabled)
'    m.SetMenuTopLeft(m.MenuTopLeft)
'    If Not IsNullOrEmpty(m.Title) then
'        m.SetTitle(m.Title)
'    End If
'    If Not IsNullOrEmpty(m.Text) Then
'        m.SetText(m.Text)
'    End If
'    If m.BusyAnimation Then
'        m.ShowBusyAnimation()
'    End If
'    m.SetButtons(m.Buttons)
'    m.SetFocusedMenuItem(m.FocusedMenuItem)
'    m.Screen.Show()
'    
'    ' We've displayed a new dialog, so close the old one
'    'oldScreen.Close()
'End Sub

Sub MessageDialog_SetTitle(title As String)
    m.Title = title
    If m.Screen <> invalid Then
        m.Screen.SetTitle(title)
    End If
End Sub

Sub MessageDialog_SetText(text As String)
    m.Text = text
    If m.Screen <> invalid Then
        m.Screen.SetText(text)
    End If
End Sub

Sub MessageDialog_EnableOverlay(enable = True As Boolean)
    m.OverlayEnabled = enable
    If m.Screen <> invalid Then
        m.Screen.EnableOverlay(enable)
    End If
End Sub

Sub MessageDialog_EnableBackButton(enable = True As Boolean)
    m.BackEnabled = enable
    If m.Screen <> invalid Then
        m.Screen.EnableBackButton(enable)
    End If
End Sub

Sub MessageDialog_SetMenuTopLeft(topLeft = True As Boolean)
    m.MenuTopLeft = topLeft
    If m.Screen <> invalid Then
        m.Screen.SetMenuTopLeft(topLeft)
    End If
End Sub

Sub MessageDialog_ShowBusyAnimation()
    m.BusyAnimation = True
    If m.Screen <> invalid Then
        m.Screen.ShowBusyAnimation()
    End If
End Sub

Sub MessageDialog_SetButtons(buttons = ["OK"] As Object)
    m.Buttons = buttons
    If m.Screen <> invalid Then
        For buttonIndex = 0 To buttons.Count() - 1
            buttonText = ""
            button = buttons[buttonIndex]
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
                    m.Screen.AddRatingButton(buttonIndex, button.UserRating, button.AggregateRating, "") 'button.Text)
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
                    End IF
                End If
            End If
        Next
    End If
End Sub

Sub MessageDialog_SetFocusedMenuItem(index As Integer)
    m.FocusedMenuItem = index
    If m.Screen <> invalid Then
        m.Screen.SetFocusedMenuItem(index)
    End If
End Sub