'IMPORTS=utilities/dateTime
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
'=====================
' Types
'=====================
Function IsXmlElement(value As Dynamic) As Boolean
    Return IsValid(value) And GetInterface(value, "ifXMLElement") <> invalid
End Function

Function IsFunction(value As Dynamic) As Boolean
    Return IsValid(value) And GetInterface(value, "ifFunction") <> invalid
End Function

Function IsBoolean(value As Dynamic) As Boolean
    Return IsValid(value) And GetInterface(value, "ifBoolean") <> invalid
End Function

Function IsInteger(value As Dynamic) As Boolean
    Return IsValid(value) And GetInterface(value, "ifInt") <> invalid And (Type(value) = "roInt" Or Type(value) = "roInteger" Or Type(value) = "Integer")
End Function

Function IsLongInteger(value As Dynamic) As Boolean
    Return IsValid(value) And GetInterface(value, "ifLongInt") <> invalid
End Function

Function IsFloat(value As Dynamic) As Boolean
    Return IsValid(value) And (GetInterface(value, "ifFloat") <> invalid Or (Type(value) = "roFloat" Or Type(value) = "Float"))
End Function

Function IsDouble(value As Dynamic) As Boolean
    Return IsValid(value) And (GetInterface(value, "ifDouble") <> invalid Or (Type(value) = "roDouble" Or Type(value) = "roIntrinsicDouble" Or Type(value) = "Double"))
End Function

Function IsList(value As Dynamic) As Boolean
    Return IsValid(value) And GetInterface(value, "ifList") <> invalid
End Function

Function IsArray(value As Dynamic) As Boolean
    Return IsValid(value) And GetInterface(value, "ifArray") <> invalid
End Function

Function IsAssociativeArray(value As Dynamic) As Boolean
    Return IsValid(value) And GetInterface(value, "ifAssociativeArray") <> invalid
End Function

Function IsString(value As Dynamic) As Boolean
    Return IsValid(value) And GetInterface(value, "ifString") <> invalid
End Function

Function IsDateTime(value As Dynamic) As Boolean
    Return IsValid(value) And (GetInterface(value, "ifDateTime") <> invalid Or Type(value) = "roDateTime")
End Function

Function IsHttpAgent(value As Dynamic) As Boolean
    Return IsValid(value) And GetInterface(value, "ifHttpAgent") <> invalid
End Function

Function IsSGNode(value As Dynamic) As Boolean
    Return IsValid(value) And GetInterface(value, "ifSGNodeField") <> invalid
End Function

Function IsValid(value As Dynamic) As Boolean
    Return Type(value) <> "<uninitialized>" And value <> invalid
End Function

Function ConvertToTypeByValue(input As Dynamic, referenceValue As Dynamic) As Dynamic
    If referenceValue = invalid Then
        Return input
    Else If IsInteger(referenceValue) Then
        Return AsInteger(input)
    Else If IsFloat(referenceValue) Then
        Return AsFloat(input)
    Else If IsDouble(referenceValue) Then
        Return AsDouble(input)
    Else If IsBoolean(referenceValue) Then
        Return AsBoolean(input)
    Else If IsArray(referenceValue) Or IsList(referenceValue) Then
        Return AsArray(input)
    Else If IsAssociativeArray(referenceValue) Then
        Return AsAssociativeArray(input)
    Else If IsDateTime(referenceValue) Then
        Return DateFromISO8601String(input)
    Else If IsXmlElement(referenceValue) Then
        xml = CreateObject("roXmlElement")
        xml.Parse(input)
        Return xml
    Else
        ' Default to string
        Return AsString(input)
    End If
End Function

Function AsString(input As Dynamic, defaultValue = "" As String) As String
    If input = invalid Then
        Return defaultValue
    Else If IsString(input) Then
        Return input
    Else If IsInteger(input) Then
        Return input.ToStr()
    Else If IsLongInteger(input) Then
        Return input.ToStr()
    Else If IsFloat(input) Then
        Return AsString(AsDouble(input))
    Else If IsDouble(input) Then
        output = Str(input)
        If output.InStr("e+") > -1 Then
            exponent = 9
            divisor# = 10 ^ exponent
            high% = Int(input / divisor#)
            low% = input - (high% * divisor#)
            output = high%.ToStr() + PadLeft(low%.ToStr(), "0", exponent)
        End If
        Return output.Trim()
    Else If IsBoolean(input) Then
        Return IIf(input = True, "true", "false")
    Else If IsDateTime(input) Then
        Return DateToISO8601String(input)
    Else
        Return Type(input)
    End If
End Function

Function AsInteger(input As Dynamic, defaultValue = 0 As Integer) As Integer
    If input = invalid Then
        Return defaultValue
    Else If IsString(input) Then
        Return input.ToInt()
    Else If IsInteger(input) Then
        Return input
    Else If IsFloat(input) Then
        Return Int(input)
    Else If IsDouble(input) Then
        output% = input
        Return output%
    Else If IsDateTime(input) Then
        Return input.AsSeconds()
    Else
        Return defaultValue
    End If
End Function

Function AsFloat(input As Dynamic, defaultValue = 0.0 As Float) As Float
    If input = invalid Then
        Return defaultValue
    Else If IsString(input) Then
        Return input.ToFloat()
    Else If IsInteger(input) Then
        Return (input / 1)
    Else If IsFloat(input) Then
        Return input
    Else If IsDouble(input) Then
        output! = input
        Return output!
    Else If IsDateTime(input) Then
        output! = input.AsSeconds()
        Return output!
    Else
        Return defaultValue
    End If
End Function

Function AsDouble(input As Dynamic, defaultValue = 0 As Double) As Double
    output# = defaultValue
    If IsString(input) Then
        If input.Len() <= 9 Then
            output# = input.ToInt()
        Else
            ' Big string, so break it into parts and build the double
            low = input.Mid(input.Len() - 9, 9).ToInt()
            high = input.Mid(0, input.Len() - 9).ToInt()
            output# = high
            output# = output# * 1000000000
            output# = output# + low
        End If
    Else If IsInteger(input) Or IsFloat(input) Then
        output# = input
    Else If IsDateTime(input) Then
        output# = input.AsSeconds()
    End If
    Return output#
End Function

Function AsBoolean(input As Dynamic, defaultValue = False As Boolean) As Boolean
    If input = invalid Then
        Return defaultValue
    Else If IsBoolean(input) Then
        Return input
    Else If IsString(input) Then
        Return LCase(input) = "true"
    Else If IsInteger(input) Or IsFloat(input) Or IsDouble(input) Then
        Return input <> 0
    Else
        Return defaultValue
    End If
End Function

Function AsArray(value As Object) As Object
    If IsValid(value)
        If Not IsArray(value) Then
            Return [value]
        Else
            Return value
        End If
    End If
    Return []
End Function

Function AsAssociativeArray(value As Object) As Object
    If IsValid(value)
        If Not IsAssociativeArray(value) Then
            Return { Value: value }
        Else
            Return value
        End If
    End If
    Return {}
End Function
