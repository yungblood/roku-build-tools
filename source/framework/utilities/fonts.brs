'IMPORTS=utilities/strings utilities/debug
' ******************************************************
' Copyright Steven Kean 2010-2015
' All Rights Reserved.
' ******************************************************
Function GetFontRegistry() As Object
    If m.FontRegistry = invalid Then
        m.FontRegistry = CreateObject("roFontRegistry")
    End If
    Return m.FontRegistry
End Function

Function GetFont(fontFamily As String, fontSize As Integer, bold = False As Boolean, italic = False As Boolean, fontPath = "" As String) As Object
    GetFontRegistry()
    If m.FontCache = invalid Then
        m.FontCache = {}
    End If
    fontKey = fontFamily + ":" + fontSize.ToStr() + ":" + IIf(bold, "True", "False") + ":" + IIf(italic, "True", "False") + ":" + fontPath
    If m.FontCache[fontKey] = invalid Then
        font = invalid
        If Not IsNullOrEmpty(fontPath) And Not ArrayContains(m.FontRegistry.GetFamilies(), fontFamily) Then
            RegisterFont(fontPath)
        End If
        If ArrayContains(m.FontRegistry.GetFamilies(), fontFamily) Then
            font = m.FontRegistry.GetFont(fontFamily, fontSize, bold, italic)
        End If
        If font = invalid Then
            If fontFamily <> "Default" Then
                DebugPrint(fontFamily, "Unable to retrieve font, switching to default", 0)
            End If
            font = m.FontRegistry.GetDefaultFont(fontSize, bold, italic)
        End If
        m.FontCache[fontKey] = font
    Else
        font = m.FontCache[fontKey]
    End If
    Return font
End Function

Function GetCanvasFont(fontFamily As String, fontSize As Integer, weight = 0 As Integer, italic = False As Boolean, fontPath = "" As String) As Object
    GetFontRegistry()
    font = invalid
    If Not IsNullOrEmpty(fontPath) And Not ArrayContains(m.FontRegistry.GetFamilies(), fontFamily) Then
        RegisterFont(fontPath)
    End If
    If fontFamily = "Default" Or ArrayContains(m.FontRegistry.GetFamilies(), fontFamily) Then
        font = m.FontRegistry.Get(fontFamily, fontSize, weight, italic)
    End If
    If font = invalid Then
        DebugPrint(fontFamily, "Unable to retrieve font, switching to default", 0)
        font = m.FontRegistry.Get("Default", fontSize, weight, italic)
    End If
    Return font
End Function

Function GetDefaultFont(fontSize As Integer, bold = False As Boolean, italic = False As Boolean) As Object
    Return GetFont("Default", fontSize, bold, italic)
End Function

Function CanvasFontToScreenFont(font As Dynamic) As Object
    If Not IsString(font) Or IsNullOrEmpty(font) Then
        font = "Small"
    End If
    bold     = False
    italics  = False
    fontName = "Default"
    fontSize = 16
    If LCase(font) = "small" Then
        fontSize = 16
    Else If LCase(font) = "medium" Then
        fontSize = 24
    Else If LCase(font) = "large" Then
        fontSize = 36
    Else If LCase(font) = "huge" Then
        fontSize = 48
    Else
        fontParts = font.Tokenize(",")
        fontName  = fontParts[0]
        fontSize  = fontParts[1].ToInt()
        bold      = fontParts[4].ToInt() > 1
        italics   = fontParts[5].ToInt() = 1
    End If
    Return GetFont(fontName, fontSize, bold, italics)
End Function

Function RegisterFont(fontPath As String) As Boolean
    If m.FontRegistry = invalid Then
        m.FontRegistry = CreateObject("roFontRegistry")
    End If
    If m.FontsRegistered = invalid Then
        m.FontsRegistered = {}
    End If
    If m.FontRegistry.Register(fontPath) Then
        m.FontsRegistered[fontPath] = True
        DebugPrint(m.FontRegistry.GetFamilies(), "Successfully registered font (" + fontPath +")", 1)
    End If
    If Not m.FontsRegistered[fontPath] = True Then
        DebugPrint(fontPath, "Failed to register font", 0)
        Return False
    End If
    Return True
End Function

Function InitializeFont(font As Dynamic) As Boolean
    If font <> invalid Then
        ' Initialize the font by drawing it to a temp bitmap
        tempBitmap = CreateObject("roBitmap", { Width: 100, Height: 100 })
        If tempBitmap <> invalid Then
            Return tempBitmap.DrawText("Initialize this font.", 0, 0, 0, font)
        End If
        tempBitmap = invalid
    End If
    Return False
End Function

Function GetOneLineWidth(text As String, font As Object, maxWidth = 999999 As Integer, metrics = invalid As Dynamic) As Integer
    If IsNullOrEmpty(text) Then Return 0
    width = 0
    If IsString(font) Then
        If font = "Small" Or font = "Medium" Or font = "Large" Or font = "Huge" Then
            If font = "Small" Then
                letterWidth = 11'14
            Else If font = "Medium" Then
                letterWidth = 15
            Else If font = "Large" Then
                letterWidth = 21
            Else If font = "Huge" Then
                letterWidth = 35
            End If
            width = Len(text) * letterWidth
        Else
            If metrics = invalid Then
                metrics = CreateObject("roFontMetrics", font)
            End If
            width = metrics.Size(text).w
        End If
    Else
        width = font.GetOneLineWidth(text, maxWidth)
    End If
    If width > maxWidth Then
        width = maxWidth
    End If
    Return width
End Function

Function GetOneLineHeight(font As Object, metrics = invalid As Dynamic) As Integer
    height = 0    
    If IsString(font) Then
        If metrics = invalid Then
            metrics = CreateObject("roFontMetrics", font)
        End If
        height = metrics.Size("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789").h
    Else If font <> invalid Then
        height = font.GetOneLineHeight()
    End If
    Return height
End Function

Function GetMultipleLineHeight(text As String, font As Object, maxWidth = 999999 As Integer, maxHeight = 999999 As Integer, lineHeightAdjustment = 0 As Integer, metrics = invalid As Dynamic) As Integer
    lineHeight = GetOneLineHeight(font, metrics) + lineHeightAdjustment
    wrappedText = GetWrappedText(text, font, maxWidth, metrics)
    height = wrappedText.Count() * lineHeight
    If height > maxHeight Then
        height = maxHeight
    End If
    Return height
End Function

Function GetWrappedText(text As String, font As Object, width = 999999 As Integer, metrics = invalid) As Object
    lines = []
    If Not IsNullOrEmpty(text) Then
        startingLines = [text]
        If text.InStr(Chr(10)) > -1 Then
            startingLines = Split(text, Chr(10))
        End If
    
        If IsString(font) And metrics = invalid Then
            If font <> "Small" And font <> "Medium" And font <> "Large" And font <> "Huge" Then
                metrics = CreateObject("roFontMetrics", font)
            End If
        End If
    
        For Each textLine In startingLines
            If GetOneLineWidth(textLine, font, width + 1, metrics) > width Then
                textArray = textLine.Tokenize(" ")
                currentLine = ""
                For Each word In textArray
                    tempLine = (currentLine + " " + word)
                    tempLine = tempLine.Trim()
                    textWidth = GetOneLineWidth(tempLine, font, width + 1, metrics)
                    If textWidth <= width Then 
                        currentLine = tempLine
                    Else
                        If Not IsNullOrEmpty(currentLine) Then
                            lines.Push(currentLine)
                        End If
                        currentLine = word
                    End If
                Next
                If Not IsNullOrEmpty(currentLine) Then
                    lines.Push(currentLine)
                End If
            Else
                lines.Push(textLine)
            End If
        Next
    End If
    Return lines
End Function

Function TrimStringToWidth(text As String, font As Object, width As Integer, metrics = invalid As Dynamic) As String
    If IsNullOrEmpty(text) Or width <= 0 Then Return ""
    If IsString(font) And metrics = invalid Then
        If font <> "Small" And font <> "Medium" And font <> "Large" And font <> "Huge" Then
            metrics = CreateObject("roFontMetrics", font)
        End If
    End If
    If GetOneLineWidth(text, font, width, metrics) >= width Then
        text = text.Mid(0, text.Len() - 1)
        While Not IsNullOrEmpty(text) And GetOneLineWidth(text + "...", font, width, metrics) >= width
            text = text.Mid(0, text.Len() - 1)
        End While
        text = text + "..."
    End If
    Return text
End Function

