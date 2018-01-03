Function NewInterstitialScreen() As Object
    this                            = {}
    this.ClassName                  = "InterstitialScreen"

    this.Show                       = InterstitialScreen_Show

    Return this
End Function

Function InterstitialScreen_Show() As Object
    screen = CreateObject("roImageCanvas")
    screen.SetMessagePort(CreateObject("roMessagePort"))
    screen.SetRequireAllImagesToDraw(False)
    
    upsellInfo = Cbs().GetUpsellInfo("ROKUPROMO")
    If upsellInfo.Response = invalid Or upsellInfo.Response.IsEmpty() Then
        Return invalid
    End If
    layers = [
        {
            Color: "#000e1b"
        }
        {
            Url: upsellInfo.Background
            TargetRect: {
                x: 0
                y: 0
                w: 1280
                h: 720
            }
        }
    ]
    
    deeplink = {
        contentID: upsellInfo.Response.contentID
        mediaType: upsellInfo.Response.callToActionURL
    }
    
    continueText = UCase(upsellInfo.Response.upsellMessage)
    deeplinkText = UCase(upsellInfo.Response.callToAction)
    buttonFont = GetCanvasFont("Default", IIf(IsHD(), 24, 18))
    buttons = [
        {
            ID: "deeplink"
            Text: deeplinkText
            Layers:  [
                {
                    Url: "pkg:/images/upsell/button_interstitial_off.png"
                    TargetRect: {
                        x: 770
                        y: 550
                        w: 177
                        h: 100
                    }
                }
                {
                    Text: deeplinkText
                    TextAttrs: {
                        Font:   buttonFont
                        Color:  "#CCCCCC"
                        HAlign: "Left"
                        VAlign: "Top"
                    }
                    TargetRect: {
                        x: 780
                        y: 560
                        w: 157
                        h: 80
                    }
                }
            ]
            FocusedLayers:  [
                {
                    Url: "pkg:/images/upsell/button_interstitial_on.png"
                    TargetRect: {
                        x: 770
                        y: 550
                        w: 177
                        h: 100
                    }
                }
                {
                    Text: deeplinkText
                    TextAttrs: {
                        Font:   buttonFont
                        Color:  "#FFFFFF"
                        HAlign: "Left"
                        VAlign: "Top"
                    }
                    TargetRect: {
                        x: 780
                        y: 560
                        w: 157
                        h: 80
                    }
                }
            ]
        }
        {
            ID: "continue"
            Text: continueText
            Layers:  [
                {
                    Url: "pkg:/images/upsell/button_interstitial_off.png"
                    TargetRect: {
                        x: 966
                        y: 550
                        w: 177
                        h: 100
                    }
                }
                {
                    Text: continueText
                    TextAttrs: {
                        Font:   buttonFont
                        Color:  "#CCCCCC"
                        HAlign: "Left"
                        VAlign: "Top"
                    }
                    TargetRect: {
                        x: 976
                        y: 560
                        w: 157
                        h: 80
                    }
                }
            ]
            FocusedLayers:  [
                {
                    Url: "pkg:/images/upsell/button_interstitial_on.png"
                    TargetRect: {
                        x: 966
                        y: 550
                        w: 177
                        h: 100
                    }
                }
                {
                    Text: continueText
                    TextAttrs: {
                        Font:   buttonFont
                        Color:  "#FFFFFF"
                        HAlign: "Left"
                        VAlign: "Top"
                    }
                    TargetRect: {
                        x: 976
                        y: 560
                        w: 157
                        h: 80
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
    
    buttonIndex = 0
    buttonLayer = 2
    For i = 0 To buttons.Count() - 1
        If i = buttonIndex Then
            screen.SetLayer(buttonLayer + i, buttons[i].FocusedLayers)
        Else
            screen.SetLayer(buttonLayer + i, buttons[i].Layers)
        End If
    Next
    
    screen.Show()
    Sleep(1000)
    
    If m.AudioGuide <> invalid Then
        m.AudioGuide.Flush()
        m.AudioGuide.Say("CBS All Access", True, True)
        button = buttons[buttonIndex]
        m.AudioGuide.Say(button.Text + ", button, " + (buttonIndex + 1).ToStr() + " of " + buttons.Count().ToStr(), False, True)
    End If

    'Omniture().TrackPage("app:roku:launch:interstitial page")
    While True
        msg = Wait(0, screen.GetMessagePort())
        If Type(msg) = "roImageCanvasEvent" Then
            If msg.IsRemoteKeyPressed() Then
                key = msg.GetIndex()
                If key = 0 Then         ' Back
                    screen.Close()
                Else If key = 6 Then    ' Select
                    button = buttons[buttonIndex]
                    If button <> invalid Then
                        If button.ID = "continue" Then
                            Return invalid
                        Else If button.ID = "deeplink" Then
                            'Omniture().TrackEvent(deeplinkText, ["event19"], { v46: "roku:interstitial:" + LCase(deeplinkText) })
                            Return deeplink
                        End If
                    End If
                Else
                    If key = 4 Then         ' Left
                        buttonIndex = buttonIndex - 1
                    Else If key = 5 Then    ' Right
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
                            button = buttons[i]
                            If m.AudioGuide <> invalid Then
                                m.AudioGuide.Say(button.Text + ", button, " + (i + 1).ToStr() + " of " + buttons.Count().ToStr(), True, True)
                            End If
                        Else
                            screen.SetLayer(buttonLayer + i, buttons[i].Layers)
                        End If
                    Next
                End If
            Else If msg.IsScreenClosed() Then
                Return invalid
            End If
        End If
    End While
    Return invalid
End Function
