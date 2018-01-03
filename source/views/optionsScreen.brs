Function NewOptionsScreen() As Object
    this                        = {}
    this.ClassName              = "OptionsScreen"
    
    this.AudioGuide             = CreateObject("roAudioGuide")
    
    this.OptionIndex            = 0
    this.ButtonIndex            = -1
        
    this.Setup                  = OptionsScreen_Setup
    this.Show                   = OptionsScreen_Show
    this.Close                  = OptionsScreen_Close
    
    this.CreateOptionButton     = OptionsScreen_CreateOptionButton
    this.CreateButton           = OptionsScreen_CreateButton
    
    Return this
End Function

Sub OptionsScreen_Setup(options As Object, buttons As Object, noButtonsMessage = "" As String, disclaimerText = "" As String, headerImage = "" As String)
    m.Options = options
    m.Buttons = buttons
    m.NoButtonsMessage = noButtonsMessage
    m.DisclaimerText = disclaimerText
    m.HeaderImage = headerImage
    
    If m.Screen = invalid Then
        m.Screen = CreateObject("roImageCanvas")
        m.Screen.SetMessagePort(CreateObject("roMessagePort"))
    End If
End Sub

Function OptionsScreen_Show(options = m.Options As Object, buttons = m.Buttons As Object, noButtonsMessage = m.NoButtonsMessage As String, disclaimerText = m.DisclaimerText As String, headerImage = m.HeaderImage As String, optionIndex = m.OptionIndex As Integer, buttonIndex = m.ButtonIndex As Integer) As Object
    m.Setup(options, buttons, noButtonsMessage, disclaimerText, headerImage)
    
    m.Screen.SetRequireAllImagesToDraw(False)
    bgLayer = [
        {
            Color: "#000000"
        }
        {
            Url: headerImage
            TargetRect: {
                x: 383
                y: 50
                w: 514
                h: 80
            }
        }
        {
            Text: m.DisclaimerText
            TargetRect: {
                x: 0
                y: 660
                w: 1280
                h: 40
            }
            TextAttrs: {
                Font:   GetCanvasFont("Default", IIf(IsHD(), 16, 11))
                Color:  "#f2f2f2"
                HAlign: "Center"
            }
        }
    ]
    
    If m.Buttons.Count() = 0 And Not IsNullOrEmpty(m.NoButtonsMessage) Then
        bgLayer.Push({
            Text: m.NoButtonsMessage
            TargetRect: {
                x: 300
                y: 450
                w: 680
                h: 100
            }
            TextAttrs: {
                Font:   GetCanvasFont("Default", IIf(IsHD(), 20, 13))
                Color:  "#f2f2f2"
                HAlign: "Center"
            }
        })
    End If

    optionLayers = []
    optionWidth = 487
    optionSpacing = 46
    optionCount = m.Options.Count()
    x = Int((1280 - ((optionWidth * optionCount) + ((optionCount - 1) * optionSpacing))) / 2)
    
    For i = 0 To optionCount - 1
        option = m.Options[i]
        optionLayers.Push(m.CreateOptionButton(option, x + (i * (optionWidth + optionSpacing))))
    Next
    
    buttonLayers = []
    buttonHeight = 52
    buttonSpacing = 10
    buttonCount = m.Buttons.Count()
    y = 462
    For i = 0 To buttonCount - 1
        button = m.Buttons[i]
        buttonLayers.Push(m.CreateButton(button, y + (i * (buttonHeight + buttonSpacing))))
    Next
    
    If Not IsHD() Then
        HDTargetRectToSDTargetRect(bgLayer)
        'HDTargetRectToSDTargetRect(optionLayers, True)
        HDTargetRectToSDTargetRect(buttonLayers, True)
    End If
    
    m.Screen.SetLayer(1, bgLayer)
    
    m.OptionIndex = IIf(optionCount > 0 And m.ButtonIndex = -1, m.OptionIndex, -1)
    optionLayer = 50
    For i = 0 To m.Options.Count() - 1
        If i = m.OptionIndex And m.Options[m.OptionIndex].Enabled <> False Then
            m.Screen.SetLayer(optionLayer + i, optionLayers[i].FocusedLayers)
        Else
            m.Screen.SetLayer(optionLayer + i, optionLayers[i].Layers)
        End If
    Next
    
    m.ButtonIndex = IIf(m.OptionIndex > -1, -1, m.ButtonIndex)
    buttonLayer = 100
    For i = 0 To m.Buttons.Count() - 1
        If i = m.ButtonIndex Then
            m.Screen.SetLayer(buttonLayer + i, buttonLayers[i].FocusedLayers)
        Else
            m.Screen.SetLayer(buttonLayer + i, buttonLayers[i].Layers)
        End If
    Next

    m.Screen.Show()
    Sleep(100)
    
    If m.AudioGuide <> invalid Then
        m.AudioGuide.Flush()
        buttonText = ""
        If m.OptionIndex > -1 Then
            buttonText = optionLayers[m.OptionIndex].Text + ",button," + (m.OptionIndex + 1).ToStr() + " of " + (optionLayers.Count() + buttonLayers.Count()).ToStr()
        Else If m.ButtonIndex > -1 Then
            buttonText = buttonLayers[m.ButtonIndex].Text + ",button," + (optionLayers.Count() + m.ButtonIndex + 1).ToStr() + " of " + (optionLayers.Count() + buttonLayers.Count()).ToStr()
        End If
        If Not IsNullOrEmpty(buttonText) Then
            m.AudioGuide.Say(buttonText, True, True)
        End If
    End If
    
    'Omniture().TrackPage("app:roku:launch:splash page")
    While True
        msg = Wait(0, m.Screen.GetMessagePort())
        If Type(msg) = "roImageCanvasEvent" Then
            If msg.IsRemoteKeyPressed() Then
                key = msg.GetIndex()
                If key = 0 Then         ' Back
                    m.Screen.Close()
                Else If key = 6 Then    ' Select
                    If m.OptionIndex > -1 Then
                        Return m.Options[m.OptionIndex]
                    Else If m.ButtonIndex > -1 Then
                        Return m.Buttons[m.ButtonIndex]
                    End If
                Else If key = 2 Or key = 3 Or key = 4 Or key = 5 Then
                    If key = 2 Then     ' Up
                        If m.Buttons.Count() > 0 Then
                            If m.ButtonIndex = 0 Then
                                m.ButtonIndex = -1
                                m.OptionIndex = 0
                            Else If m.ButtonIndex > 0 Then
                                m.ButtonIndex = m.ButtonIndex - 1
                            End If
                        End If
                    Else If key = 3 Then    ' Down
                        If m.Buttons.Count() > 0 Then
                            If m.OptionIndex > -1 Then
                                m.OptionIndex = -1
                                m.ButtonIndex = 0
                            Else If m.ButtonIndex < buttonCount - 1 Then
                                m.ButtonIndex = m.ButtonIndex + 1
                            End If
                        End If
                    Else If key = 4 Then    ' Left
                        If m.OptionIndex > 0 Then
                            m.OptionIndex = m.OptionIndex - 1
                        End If
                    Else If key = 5 Then    ' Right
                        If m.OptionIndex < optionCount - 1 Then
                            m.OptionIndex = m.OptionIndex + 1
                        End If
                    End If
                    For i = 0 To optionCount - 1
                        If i = m.OptionIndex And m.Options[m.OptionIndex].Enabled <> False Then
                            m.Screen.SetLayer(optionLayer + i, optionLayers[i].FocusedLayers)
                        Else
                            m.Screen.SetLayer(optionLayer + i, optionLayers[i].Layers)
                        End If
                    Next
                    For i = 0 To buttonCount - 1
                        If i = m.ButtonIndex Then
                            m.Screen.SetLayer(buttonLayer + i, buttonLayers[i].FocusedLayers)
                        Else
                            m.Screen.SetLayer(buttonLayer + i, buttonLayers[i].Layers)
                        End If
                    Next
                    buttonText = ""
                    If m.OptionIndex > -1 Then
                        buttonText = optionLayers[m.OptionIndex].Text + ",button," + (m.OptionIndex + 1).ToStr() + " of " + (optionLayers.Count() + buttonLayers.Count()).ToStr()
                    Else If m.ButtonIndex > -1 Then
                        buttonText = buttonLayers[m.ButtonIndex].Text + ",button," + (optionLayers.Count() + m.ButtonIndex + 1).ToStr() + " of " + (optionLayers.Count() + buttonLayers.Count()).ToStr()
                    End If
                    If m.AudioGuide <> invalid And Not IsNullOrEmpty(buttonText) Then
                        m.AudioGuide.Say(buttonText, True, True)
                    End If
                End If
            Else If msg.IsScreenClosed() Then
                m.Screen = invalid
                Return invalid
            End If
        End If
    End While
    Return invalid
End Function

Sub OptionsScreen_Close()
    m.Screen.Close()
    m.Screen = invalid
End Sub

Function OptionsScreen_CreateOptionButton(optionInfo As Object, x = 0 As Integer) As Object
    titleFont = "Large" 'GetCanvasFont("Default", IIf(IsHD(), 36, 24))
    subtitleFont = GetCanvasFont("Default", IIf(IsHD(), 20, 13))
    priceFont = "Small" 'GetCanvasFont("Default", IIf(IsHD(), 18, 12))
    trialFont = "Small" 'GetCanvasFont("Default", IIf(IsHD(), 24, 16), 500)
    
    layers = []
    focusedLayers = []
    
    bgLayer = {
        Color: IIf(optionInfo.Enabled <> False, "#0092f2", "#000000")
        TargetRect: {
            x: x
            y: 180
            w: 487
            h: 235
        }
    }
    
    titleLayer = {
        Text: IIf(IsNullOrEmpty(optionInfo.TitleText), invalid, UCase(optionInfo.TitleText))
        TextAttrs: {
            Font:   titleFont
            Color:  "#CCCCCC"
            HAlign: "Center"
        }
        TargetRect: {
            x: x
            y: 240 - IIf(IsNullOrEmpty(optionInfo.SubtitleText), 0, 30)
            w: 487
            h: 36
        }
    }
    
    subtitleLayer = {
        Text: IIf(IsNullOrEmpty(optionInfo.SubtitleText), invalid, optionInfo.SubtitleText)
        TextAttrs: {
            Font:   subtitleFont
            Color:  "#CCCCCC"
            HAlign: "Center"
        }
        TargetRect: {
            x: x
            y: 260
            w: 487
            h: 45
        }
    }

    priceLayer = {
        Text: IIf(IsNullOrEmpty(optionInfo.PriceText), invalid, optionInfo.PriceText)
        TextAttrs: {
            Font:   priceFont
            Color:  "#CCCCCC"
            HAlign: "Center"
        }
        TargetRect: {
            x: x
            y: 305 + IIf(IsNullOrEmpty(optionInfo.SubtitleText), 0, 30)
            w: 487
            h: 20
        }
    }
    
    trialLayer = {
        Text: IIf(IsNullOrEmpty(optionInfo.TrialText), invalid, optionInfo.TrialText)
        TextAttrs: {
            Font:   trialFont
            Color:  "#CCCCCC"
            HAlign: "Center"
        }
        TargetRect: {
            x: x
            y: priceLayer.TargetRect.y + 35
            w: 487
            h: 20
        }
    }
    
    layers.Push(bgLayer)
    layers.Push(titleLayer)
    layers.Push(subtitleLayer)
    layers.Push(priceLayer)
    layers.Push(trialLayer)
    
    focusedLayers.Push(ShallowCopy(bgLayer, 2))
    focusedTitleLayer = ShallowCopy(titleLayer, 2)
    focusedTitleLayer.TextAttrs.Color = "#FFFFFF"
    focusedLayers.Push(focusedTitleLayer)
    
    focusedSubtitleLayer = ShallowCopy(subtitleLayer, 2)
    focusedSubtitleLayer.TextAttrs.Color = "#FFFFFF"
    focusedLayers.Push(focusedSubtitleLayer)
    
    focusedPriceLayer = ShallowCopy(priceLayer, 2)
    focusedPriceLayer.TextAttrs.Color = "#FFFFFF"
    focusedLayers.Push(focusedPriceLayer)
    
    focusedTrialLayer = ShallowCopy(trialLayer, 2)
    focusedTrialLayer.TextAttrs.Color = "#FFFFFF"
    focusedLayers.Push(focusedTrialLayer)
    
    frameLayer = {
        Url: "pkg:/images/upsell/upsell_focus_hd.png"
        TargetRect: {
            x: x - 11
            y: 169
            w: 509
            h: 257
        }
    }
    focusedLayers.Push(frameLayer)

    If Not IsHD() Then
        HDTargetRectToSDTargetRect(layers, True)
        HDTargetRectToSDTargetRect(focusedLayers, True)
    End If
    
    button = {
        ID: optionInfo.ID
        Text: AsString(titleLayer.Text) + "," + AsString(subtitleLayer.Text) + "," + AsString(priceLayer.Text) + "," + AsString(trialLayer.Text)
        Layers: layers
        FocusedLayers: focusedLayers
    }
    Return button
End Function

Function OptionsScreen_CreateButton(buttonInfo As Object, y = 0 As Integer) As Object
    buttonFont = GetCanvasFont("Default", IIf(IsHD(), 22, 16))
    
    layers = []
    focusedLayers = []
    
    bgLayer = {
        Url: "pkg:/images/upsell/button_upsell_off.png"
        TargetRect: {
            x: 402
            y: y
            w: 476
            h: 52
        }
    }
    textLayer = {
        Text: buttonInfo.Text
        TextAttrs: {
            Font:   buttonFont
            Color:  "#CCCCCC"
            HAlign: "Center"
        }
        TargetRect: {
            x: 402
            y: y
            w: 476
            h: 52
        }
    }
    layers.Push(bgLayer)
    layers.Push(textLayer)
    
    focusedBGLayer = ShallowCopy(bgLayer, 2)
    focusedBGLayer.Url = "pkg:/images/upsell/button_upsell_on.png"
    focusedLayers.Push(focusedBGLayer)
    
    focusedTextLayer = ShallowCopy(textLayer, 2)
    focusedTextLayer.TextAttrs.Color = "#FFFFFF"
    focusedLayers.Push(focusedTextLayer)
    
    button = {
        ID: buttonInfo.ID
        Text: textLayer.Text
        Layers: layers
        FocusedLayers: focusedLayers
    }
    Return button
End Function
