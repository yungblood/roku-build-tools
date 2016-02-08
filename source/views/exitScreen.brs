Function ShowExitScreen() As Boolean
    screen = CreateObject("roImageCanvas")
    screen.SetMessagePort(CreateObject("roMessagePort"))
    screen.SetRequireAllImagesToDraw(False)
    
    layers = [
        {
            Color: "#000000"
        }
        {
            Text: "Are you sure you would like to exit CBS All Access?"
            TargetRect: {
                x: 0
                y: 240
                w: 1280
                h: 90
            }
            TextAttrs: {
                Font:   "Medium" 'GetCanvasFont("Default", IIf(IsHD(), 22, 15))
                Color:  "#c9d3df"
                HAlign: "Center"
                VAlign: "Top"
            }
        }
    ]
    
    exitText = "Exit"
    cancelText = "Back"
    buttonFont = GetCanvasFont("Default", IIf(IsHD(), 22, 16))
    buttons = [
        {
            ID: "exit"
            Layers:  [
                {
                    Url: "pkg:/images/button_upsell_off.png"
                    TargetRect: {
                        x: 402
                        y: 372
                        w: 476
                        h: 52
                    }
                }
                {
                    Text: exitText
                    TextAttrs: {
                        Font:   buttonFont
                        Color:  "#CCCCCC"
                        HAlign: "Center"
                    }
                    TargetRect: {
                        x: 402
                        y: 372
                        w: 476
                        h: 52
                    }
                }
            ]
            FocusedLayers:  [
                {
                    Url: "pkg:/images/button_upsell_on.png"
                    TargetRect: {
                        x: 402
                        y: 372
                        w: 476
                        h: 52
                    }
                }
                {
                    Text: exitText
                    TextAttrs: {
                        Font:   buttonFont
                        Color:  "#FFFFFF"
                        HAlign: "Center"
                    }
                    TargetRect: {
                        x: 402
                        y: 372
                        w: 476
                        h: 52
                    }
                }
            ]
        }
        {
            ID: "cancel"
            Layers: [
                {
                    Url: "pkg:/images/button_upsell_off.png"
                    TargetRect: {
                        x: 402
                        y: 434
                        w: 476
                        h: 52
                    }
                }
                {
                    Text: cancelText
                    TextAttrs: {
                        Font:   buttonFont
                        Color:  "#CCCCCC"
                        HAlign: "Center"
                    }
                    TargetRect: {
                        x: 402
                        y: 434
                        w: 476
                        h: 52
                    }
                }
            ]
            FocusedLayers:  [
                {
                    Url: "pkg:/images/button_upsell_on.png"
                    TargetRect: {
                        x: 402
                        y: 434
                        w: 476
                        h: 52
                    }
                }
                {
                    Text: cancelText
                    TextAttrs: {
                        Font:   buttonFont
                        Color:  "#FFFFFF"
                        HAlign: "Center"
                    }
                    TargetRect: {
                        x: 402
                        y: 434
                        w: 476
                        h: 52
                    }
                }
            ]
        }
    ]
    
    If Not IsHD() Then
        HDTargetRectToSDTargetRect(layers)
        HDTargetRectToSDTargetRect(buttons, True)
    End If
    
    screen.SetLayer(1, layers)
    
    buttonIndex = 1
    buttonLayer = 2
    For i = 0 To buttons.Count() - 1
        If i = buttonIndex Then
            screen.SetLayer(buttonLayer + i, buttons[i].FocusedLayers)
        Else
            screen.SetLayer(buttonLayer + i, buttons[i].Layers)
        End If
    Next
    
    screen.Show()
    Omniture().TrackPage("app:roku:exit:exit page")
    While True
        msg = Wait(0, screen.GetMessagePort())
        If Type(msg) = "roImageCanvasEvent" Then
            If msg.IsRemoteKeyPressed() Then
                key = msg.GetIndex()
                If key = 0 Then         ' Back
                    'screen.Close()
                Else If key = 6 Then    ' Select
                    button = buttons[buttonIndex]
                    If button <> invalid Then
                        If button.ID = "exit" Then
                            Omniture().TrackEvent(exitText, ["event19"], { v46: "roku:exit:" + LCase(exitText) })
                            Return True
                        Else If button.ID = "cancel" Then
                            Omniture().TrackEvent(cancelText, ["event19"], { v46: "roku:exit:" + LCase(cancelText) })
                            Return False
                        End If
                    End If
                Else
                    If key = 2 Then         ' Up
                        buttonIndex = buttonIndex - 1
                    Else If key = 3 Then    ' Down
                        buttonIndex = buttonIndex + 1
                    End If
                    If buttonIndex < 0 Then
                        buttonIndex = 0
                    Else If buttonIndex >= buttons.Count() Then
                        buttonIndex = buttons.Count() - 1
                    End If
                    For i = 0 To buttons.Count() - 1
                        If i = buttonIndex Then
                            screen.SetLayer(buttonLayer + i, buttons[i].FocusedLayers)
                        Else
                            screen.SetLayer(buttonLayer + i, buttons[i].Layers)
                        End If
                    Next
                End If
            Else If msg.IsScreenClosed() Then
                Return False
            End If
        End If
    End While
    Return False
 End Function