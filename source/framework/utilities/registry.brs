'IMPORTS=utilities/strings
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
'=====================
' Registry
'=====================
Function RegRead(key as String, section = invalid As Dynamic) As Dynamic
    If section = invalid Then section = "Default"
    reg = CreateObject("roRegistrySection", section)
    If reg.Exists(key) Then Return reg.Read(key)
    Return invalid
End Function

Sub RegWrite(key as String, val as String, section = invalid As Dynamic)
    If section = invalid Then section = "Default"
    reg = CreateObject("roRegistrySection", section)
    reg.Write(key, val)
    reg.Flush()
End Sub

Sub RegDelete(key as String, section = invalid As Dynamic)
    If section = invalid Then section = "Default"
    reg = CreateObject("roRegistrySection", section)
    reg.Delete(key)
    reg.Flush()
End Sub

Function GetRegistryValues(section As String) As Object
    values = {}
    reg = CreateObject("roRegistrySection", section)
    For Each key In reg.GetKeyList()
        values[key] = reg.Read(key)
    Next
    Return values
End Function

Function SetRegistryValues(section As String, values As Object) As Boolean
    result = True
    reg = CreateObject("roRegistrySection", section)
    For Each key In AsAssociativeArray(values)
        result = reg.Write(key, AsString(values[key])) And result
    Next
    result = reg.Flush() And result
    Return result
End Function

Function GetRegistryValue(key As String, default As Dynamic, section As string) As Dynamic
    value = RegRead(key, section)
    If IsNullOrEmpty(value) Then
        Return default
    End If
    Return value
End Function

Function GetBooleanRegistryValue(key As String, default As Boolean, section As String) As Boolean
    value = LCase(GetRegistryValue(key, IIf(default, "True", "False"), section)).Trim()
    Return (value = "true" Or value = "1")
End Function

Function GetIntegerRegistryValue(key As String, default As Integer, section As String) As Integer
    Return GetRegistryValue(key, default.ToStr(), section).ToInt()
End Function

Function GetStringArrayRegistryValue(key As String, default As Object, section As String, separator = "~" As String) As Object
    value = GetRegistryValue(key, "", section)
    If IsNullOrEmpty(value) Then
        Return default
    End If
    Return value.Tokenize(separator)
End Function

Function GetAssocArrayRegistryValue(key As String, default As Object, section As String) As Object
    value = GetRegistryValue(key, "", section)
    If IsNullOrEmpty(value) Then
        Return default
    End If
    Return ParseJson(value)
End Function

Sub SetRegistryValue(key As String, value As Dynamic, section As String)
    RegWrite(key, AsString(value), section)
End Sub

Sub SetBooleanRegistryValue(key As String, value As Boolean, section As String)
    SetRegistryValue(key, IIf(value, "True", "False"), section)
End Sub

Sub SetIntegerRegistryValue(key As String, value As Integer, section As String)
    SetRegistryValue(key, value.ToStr(), section)
End Sub

Sub SetStringArrayRegistryValue(key As String, value As Object, section As String, separator = "~" As String)
    valueString = ""
    For Each item in value
        If Not IsNullOrEmpty(valueString) Then
            valueString = valueString + separator
        End If
        valueString = valueString + item
    Next
    SetRegistryValue(key, valueString, section)
End Sub

Sub SetAssocArrayRegistryValue(key As String, value As Object, section As String)
    SetRegistryValue(key, FormatJson(value), section)
End Sub

Sub DeleteRegistryValue(key As String, section As String)
    RegDelete(key, section)
End Sub

Sub DeleteRegistrySection(section As String)
    registry = CreateObject("roRegistry")
    registry.Delete(section)
    registry.Flush()
End Sub
