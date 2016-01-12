'IMPORTS=v2/screens/baseScreen
' ******************************************************
' Copyright Steven Kean 2010-2015
' All Rights Reserved.
' ******************************************************
Function NewSpringboardScreen() As Object
    this                                = NewBaseScreen("roSpringboardScreen", "roSpringboardScreenEvent")
    this.ClassName                      = "SpringboardScreen"
    
    this.Content                        = invalid
    this.Buttons                        = []

    this.InitializeScreen               = SpringboardScreen_InitializeScreen

    ' UI
    this.SetDisplayMode                 = SpringboardScreen_SetDisplayMode
    this.SetDescriptionStyle            = SpringboardScreen_SetDescriptionStyle
    this.SetPosterStyle                 = SpringboardScreen_SetPosterStyle
    this.SetProgressIndicatorEnabled    = SpringboardScreen_SetProgressIndicatorEnabled
    this.SetProgressIndicator           = SpringboardScreen_SetProgressIndicator
    this.SetStaticRatingEnabled         = SpringboardScreen_SetStaticRatingEnabled
    this.UseStableFocus                 = SpringboardScreen_UseStableFocus
    
    this.SetContent                     = SpringboardScreen_SetContent

    this.AddButton                      = SpringboardScreen_AddButton
    this.ClearButtons                   = SpringboardScreen_ClearButtons
    this.SetButtons                     = SpringboardScreen_SetButtons

    this.OnEvent                        = SpringboardScreen_OnEvent
    
    this.GetBaseEventData               = SpringboardScreen_GetBaseEventData
    
    Return this
End Function

Sub SpringboardScreen_InitializeScreen()
    If m.Screen <> invalid Then
        m.SetBreadcrumbText(m.Get("BreadcrumbA", ""), m.Get("BreadcrumbB", ""))

        If m.Content <> invalid Then
            m.SetContent(m.Content)
        End If
        m.SetDisplayMode(m.Get("DisplayMode", "scale-to-fill"))
        m.SetPosterStyle(m.Get("PosterStyle", ""))
        m.SetProgressIndicatorEnabled(m.Get("ProgressIndicatorEnabled", False))
        m.SetStaticRatingEnabled(m.Get("StaticRatingEnabled", False))
        m.UseStableFocus(m.Get("StableFocus", False))

        m.Screen.ClearButtons()
        buttons = []
        buttons.Append(m.Buttons)
        m.SetButtons(buttons)
    End If
End Sub

Sub SpringboardScreen_SetContent(content As Object)
    m.Content = content
    If m.Screen <> invalid Then
        m.Screen.SetContent(content)
    End If
End Sub

Sub SpringboardScreen_SetDisplayMode(displayMode As String)
    m.Set("DisplayMode", displayMode)
    If m.Screen <> invalid Then
        m.Screen.SetDisplayMode(displayMode)
    End If
End Sub

Sub SpringboardScreen_SetDescriptionStyle(style As String)
    m.Set("DescriptionStyle", style)
    If m.Screen <> invalid Then
        m.Screen.SetDescriptionStyle(style)
    End If
End Sub

Sub SpringboardScreen_SetPosterStyle(style As String)
    If Not IsNullOrEmpty(style) Then
        m.Set("PosterStyle", style)
        If m.Screen <> invalid Then
            m.Screen.SetPosterStyle(style)
        End If
    End If
End Sub

Sub SpringboardScreen_SetProgressIndicatorEnabled(enabled = True As Boolean)
    m.Set("ProgressIndicatorEnabled", enabled)
    If m.Screen <> invalid Then
        m.Screen.SetProgressIndicatorEnabled(enabled)
    End If
End Sub

Sub SpringboardScreen_SetProgressIndicator(progress As Integer, maximum As Integer)
    If m.Screen <> invalid Then
        m.Screen.SetProgressIndicator(progress, maximum)
    End If
End Sub

Sub SpringboardScreen_SetStaticRatingEnabled(enabled = True As Boolean)
    m.Set("StaticRatingEnabled", enabled)
    If m.Screen <> invalid Then
        m.Screen.SetStaticRatingEnabled(enabled)
    End If
End Sub

Sub SpringboardScreen_UseStableFocus(enabled = True As Boolean)
    m.Set("StableFocus", enabled)
    If m.Screen <> invalid Then
        m.Screen.UseStableFocus(enabled)
    End If
End Sub

Sub SpringboardScreen_AddButton(button As Object)
    m.Buttons.Push(button)
    buttonIndex = m.Buttons.Count() - 1
    If m.Screen <> invalid Then
        If IsString(button) Then
            m.Screen.AddButton(buttonIndex, button)
        Else
            If button.Type = "rating" Then
                ' This is a ratings button, so add a ratings button
                m.Screen.AddRatingButton(buttonIndex, button.UserRating, button.AggregateRating)
            Else If button.Type = "thumbs" Then
                If button.Tips = invalid Then
                    ' This is a thumbs button, so add a thumbs up/down button
                    m.Screen.AddThumbsUpDownButton(buttonIndex, button.Rating)
                Else
                    ' This is a thumbs button with tips, so add a thumbs up/down button
                    m.Screen.AddThumbsUpDownButtonWithTips(buttonIndex, button.Rating, button.Tips)
                End If
            Else
                ' We're not sure what type of button this is, so treat it
                ' as a standard label button
                m.Screen.AddButton(buttonIndex, button.Text)
            End If
        End If
    End If
End Sub

Sub SpringboardScreen_ClearButtons()
    m.Buttons.Clear()
    If m.Screen <> invalid Then
        m.Screen.ClearButtons()
    End If
End Sub

Sub SpringboardScreen_SetButtons(buttons As Object)
    m.ClearButtons()
    For Each button In buttons
        m.AddButton(button)
    Next
End Sub

Function SpringboardScreen_OnEvent(eventData As Object, callbackData = invalid As Object) As Boolean
    ' Retrieve the message via the key, to avoid Eclipse parser errors
    msg = eventData["Event"]
    If Type(msg) = "roSpringboardScreenEvent" Then
        If msg.IsScreenClosed() Then
            Return m.Dispose()
        Else If msg.IsButtonPressed() Then
            data = m.GetBaseEventData()
            ' A button on the screen was selected, so get the button details
            data.Button = m.Buttons[msg.GetIndex()]
            If Not IsString(data.Button) Then
                ' It's not a standard string/label button, so get the event details
                If data.Button.Type = "thumbs" Then
                    data.Button.Rating = msg.GetData()
                Else If data.Button.Type = "rating" Then
                    data.Button.UserRating = msg.GetData()
                End If
            End If
            ' Raise the ButtonPressed event
            m.RaiseEvent("ButtonPressed", data)
        Else If msg.IsRemoteKeyPressed() Or msg.IsButtonInfo() Then
            data = m.GetBaseEventData()
            If msg.IsButtonInfo() Then
                data.RemoteKey = 10
            Else
                data.RemoteKey = msg.GetIndex()
            End If
            ' Raise the remote key pressed event
            m.RaiseEvent("RemoteKeyPressed", data)
        End If
    End If
    Return True
End Function

Function SpringboardScreen_GetBaseEventData() As Object
    eventData = {
        Content:    m.Content
    }
    Return eventData
End Function
