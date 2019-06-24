'IMPORTS=utilities/strings utilities/types utilities/dateTime
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
'=====================
' Utilities
'=====================
Function IIf(condition As Boolean, result1 As Dynamic, result2 As Dynamic) As Dynamic
    If condition Then
        Return result1
    Else
        Return result2
    End If
End Function

Function Max(a As Dynamic, b As Dynamic) As Dynamic
    Return IIf(a > b, a, b)
End Function

Function Min(a As Dynamic, b As Dynamic) As Dynamic
    Return IIf(a > b, b, a)
End Function

Function ParseIniFile(filePath As String) As Object
    fileContent = ReadAsciiFile(filePath)
    Return ParseIniFileContent(fileContent)
End Function

Function ParseIniFileContent(fileContent As String) As Object
    If IsNullOrEmpty(fileContent) Then
        Return invalid
    End If
    lines = fileContent.GetString().Tokenize(chr(10))
    iniFile = {}
    For Each line In lines
        If line.InStr("#") <> 0 Then    'Skip comments
            If line.InStr("=") > 0 Then
                line = Replace(line, Chr(13), "")
                entryKey = line.Mid(0, line.InStr("=")).Trim()
                entryValue = line.Mid(line.InStr("=") + 1).Trim()
                If iniFile[entryKey] <> invalid Then
                    If Not IsArray(iniFile[entryKey]) Then
                        ' We have multiple values, so convert the current
                        ' value to an array instead
                        iniFile[entryKey] = [iniFile[entryKey]]
                    End If
                    iniFile[entryKey].Push(entryValue)
                Else
                    iniFile[entryKey] = entryValue
                End If
            End If
        End If
    End For
    Return iniFile
End Function

Function GenerateGuid(addBraces = True As Boolean) As String
    hex = GetRandomHexString(32)
    guid = hex.Mid(0, 8) + "-" + hex.Mid(8, 4) + "-" + hex.Mid(12, 4) + "-" + hex.Mid(16, 4) + "-" + hex.Mid(20)
    If addBraces Then
        guid = "{" + guid + "}"
    End If
    Return guid
End Function

Function GetRandomHexString(length As Integer) As String
    bytes = CreateObject("roByteArray")
    For i = 1 to length / 2
        bytes.Push(Rnd(256) - 1)
    Next
    hexString = bytes.ToHexString()
    If length Mod 2 > 0 Then
        hexString = hexString + "0"
    End If
    Return hexString
End Function

Function NewNameValuePair(name As String, value As Dynamic) As Object
    If Not IsValid(value) Then
        value = invalid
    End If
    Return {
        Name:   name
        Value:  value
    }
End Function

Function Serialize(item As Object, prefix = "" As String, indent = 0 As Integer, replaceQuotes = False As Boolean) As String
    indention = ""
    If indent >= 0 Then
        indention = PadLeft(indention, " ", indent * 4)
    End If
    output = indention + IIf(IsNullOrEmpty(prefix.Trim()), "", prefix + ": ")
    If IsAssociativeArray(item) Then
        output = output + "{" + Chr(10)
        For Each key In item
            If indent = -1 Then 'Shallow
                If IsArray(item[key]) Or IsAssociativeArray(item[key]) Then
                    output = output + Serialize(Type(item[key]), key, 1, replaceQuotes)
                Else
                    output = output + Serialize(item[key], key, 1, replaceQuotes)
                End If
            Else
                output = output + Serialize(item[key], key, indent + 1, replaceQuotes)
            End If
        Next
        output = output + indention + "}"
    Else If IsArray(item) Or IsList(item) Then
        output = output + "[" + Chr(10)
        For Each element In item
            If indent = -1 Then 'Shallow
                If IsArray(element) Or IsAssociativeArray(element) Then
                    output = output + Serialize(Type(element), "", 1, replaceQuotes)
                Else
                    output = output + Serialize(element, " ", 1, replaceQuotes)
                End If
            Else
                output = output + Serialize(element, " ", indent + 1, replaceQuotes)
            End If
        Next
        output = output + indention + "]"
    Else If IsInteger(item) Then
        output = output + item.ToStr()
    Else If IsFloat(item) Then
        output = output + Str(item).Trim()
    Else If IsBoolean(item) Then
        output = output + IIf(item, "True", "False")
    Else If IsString(item) Then
        If Not IsNullOrEmpty(prefix) Then
            output = output + Chr(34)
        End If
        If replaceQuotes Then
            output = output + Replace(item, Chr(34), Chr(34) + "+Chr(34)+" + Chr(34))
        Else
            output = output + item
        End If
        If Not IsNullOrEmpty(prefix) Then
            output = output + Chr(34)
        End If
    Else If IsDateTime(item) Then
        output = output + DateToISO8601String(item)
    Else If item = invalid Then
        output = output + "invalid"
    Else
        If Not IsNullOrEmpty(prefix) Then
            output = output + Chr(34)
        End If
        output = output + "<" + Type(item) + ">"
        If Not IsNullOrEmpty(prefix) Then
            output = output + Chr(34)
        End If
    End If
    If indent > 0 Then
        output = output + Chr(10)
    End If
    Return output
End Function

Function Deserialize(serializedItem As String) As Dynamic
    deserialized = invalid
    'Eval("deserialized=" + serializedItem)
    Return deserialized
End Function

Function SerializeToJson(item As Object, prefix = "" As String, indent = 0 As Integer, addComma = True As Boolean) As String
    indention = ""
    If indent >= 0 Then
        indention = PadLeft(indention, " ", indent * 4)
    End If
    output = indention + IIf(IsNullOrEmpty(prefix.Trim()), "", Chr(34) + prefix + Chr(34) + " : ")
    If IsAssociativeArray(item) Then
        output = output + "{" + Chr(10)
        item.Reset()
        While item.IsNext()
            key = item.Next()
            comma = item.IsNext()
            If indent = -1 Then 'Shallow
                If IsArray(item[key]) Or IsAssociativeArray(item[key]) Then
                    output = output + SerializeToJson(Type(item[key]), key, 1, comma)
                Else
                    output = output + SerializeToJson(item[key], key, 1, comma)
                End If
            Else
                output = output + SerializeToJson(item[key], key, indent + 1, comma)
            End If
        End While
        output = output + indention + "}"
    Else If IsArray(item) Or IsList(item) Then
        output = output + "[" + Chr(10)
        For i = 0 to item.Count() - 1
            element = item[i]
            comma = i < item.Count() - 1
            If indent = -1 Then 'Shallow
                If IsArray(element) Or IsAssociativeArray(element) Then
                    output = output + SerializeToJson(Type(element), "", 1, comma)
                Else
                    output = output + SerializeToJson(element, " ", 1, comma)
                End If
            Else
                output = output + SerializeToJson(element, " ", indent + 1, comma)
            End If
        Next
        output = output + indention + "]"
    Else If IsInteger(item) Then
        output = output + item.ToStr()
    Else If IsFloat(item) Then
        output = output + Str(item).Trim()
    Else If IsBoolean(item) Then
        output = output + IIf(item, "true", "false")
    Else If IsString(item) Then
        output = output + Chr(34)
        output = output + Replace(item, Chr(34), "\" + Chr(34))
        output = output + Chr(34)
    Else If IsDateTime(item) Then
        output = output + Chr(34)
        output = output + DateToISO8601String(item)
        output = output + Chr(34)
    Else If item = invalid Then
        output = output + "null"
    Else
        output = output + Chr(34)
        output = output + "<" + Type(item) + ">"
        output = output + Chr(34)
    End If
    If indent > 0 Then
        output = output + IIf(addComma, ",", "") + Chr(10)
    End If
    Return output
End Function
