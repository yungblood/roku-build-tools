'IMPORTS=utilities/strings
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
Sub SetTheme(theme As Object)
    m.Theme = theme
    app = CreateObject("roAppManager")
    app.SetTheme(m.Theme)
End Sub

Function GetTheme() As Object
    If m.Theme = invalid Then
        m.Theme = {}
    End If
    Return m.Theme
End Function

Sub SetThemeAttribute(name As String, value As String)
    app = CreateObject("roAppManager")
    app.SetThemeAttribute(name, value)
    
    theme = GetTheme()
    theme[name] = value
End Sub

Function GetThemeAttribute(name As String, defaultValue = "" As String) As String
    theme = GetTheme()
    value = theme[name]
    If IsNullOrEmpty(value) Then
        value = defaultValue
    End If
    Return value
End Function

Sub ClearThemeAttribute(name)
    app = CreateObject("roAppManager")
    app.ClearThemeAttribute(name)

    theme = GetTheme()
    theme.Delete(name)
End Sub