'IMPORTS=utilities/application utilities/device utilities/general
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
Function ShowSplashScreen() As Dynamic
    this = invalid
    
    manifest = GetManifest()
    If Not IsNullOrEmpty(manifest.splash_screen_sd) And Not IsNullOrEmpty(manifest.splash_screen_hd) Then
        this = {
            Canvas:         invalid
            
            Background:     IIf(IsNullOrEmpty(manifest.splash_color), "#000000", manifest.splash_color)
            HDSplashImage:  manifest.splash_screen_hd
            SDSplashImage:  manifest.splash_screen_sd

            Show:           SplashScreen_Show
            ShowMessage:    SplashScreen_ShowMessage
            AddContent:     SplashScreen_AddContent
            Close:          SplashScreen_Close
        }
        this.Show()
    End If
    
    Return this
End Function

Function SplashScreen_Show() As Boolean
    splashImageUrl = IIf(IsHD(), m.HDSplashImage, m.SDSplashImage)
    splashImage = CreateObject("roBitmap", splashImageUrl)
    If splashImage <> invalid Then
        If m.Canvas = invalid Then
            m.Canvas = CreateObject("roImageCanvas")
        End If
        m.Canvas.SetRequireAllImagesToDraw(False)

        bg = {
            Color: m.Background
        }
        logo = {
            Url: splashImageUrl
            TargetRect: {
                x: Int((m.Canvas.GetCanvasRect().w - splashImage.GetWidth()) / 2)
                y: Int((m.Canvas.GetCanvasRect().h - splashImage.GetHeight()) / 2)
                w: splashImage.GetWidth()
                h: splashImage.GetHeight()
            }
        }
        m.Canvas.SetLayer(0, bg)
        m.Canvas.SetLayer(1, logo)
        m.Canvas.Show()
        
        Return True
    End If
    Return False
End Function

Function SplashScreen_ShowMessage(message = "" As String, x = 0 As Integer, y = -1 As Integer, color = "#FFFFFF" As String, font = "Small" As String) As Boolean
    If m.Canvas <> invalid Then
        If y = -1 Then
            y = Int(m.Canvas.GetCanvasRect().h / 3 * 2)
        End If
        shadow = {
            Text:   message
            TextAttrs: {
                Color:  "#000000"
                Font:   font
                HAlign: "Center"
                VAlign: "Top"
            }
            TargetRect: {
                x: x + 1
                y: y + 1
                w: m.Canvas.GetCanvasRect().w
                h: m.Canvas.GetCanvasRect().h - y
            }
        }
        text = {
            Text:   message
            TextAttrs: {
                Color:  color
                Font:   font
                HAlign: "Center"
                VAlign: "Top"
            }
            TargetRect: {
                x: x
                y: y
                w: m.Canvas.GetCanvasRect().w
                h: m.Canvas.GetCanvasRect().h - y
            }
        }
        m.Canvas.SetLayer(10, [shadow, text])
    End If
End Function

Sub SplashScreen_AddContent(content = [] As Object, layer = 5 As Integer)
    If content <> invalid And Not content.IsEmpty() Then
        m.Canvas.SetLayer(layer, content)
    End If
End Sub

Sub SplashScreen_Close()
    If m.Canvas <> invalid Then
        m.Canvas.Close()
        m.Canvas = invalid
    End If
End Sub
