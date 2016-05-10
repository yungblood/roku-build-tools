'IMPORTS=utilities/bits
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
'====================================
' Conversion
'====================================
Function IntToByteArray(value As Integer, short = (value <= &HFFFF) As Boolean, reverse = False As Boolean) As Object
    bytes = CreateObject("roByteArray")
    If Not reverse Then
        If Not short Then
            bytes.Push(BitShiftRight(value, 24) And &HFF)
            bytes.Push(BitShiftRight(value, 16) And &HFF)
        End If
        bytes.Push(BitShiftRight(value, 8) And &HFF)
        bytes.Push(value And &HFF)
    Else
        bytes.Push(value And &HFF)
        bytes.Push(BitShiftRight(value, 8) And &HFF)
        If Not short Then
            bytes.Push(BitShiftRight(value, 16) And &HFF)
            bytes.Push(BitShiftRight(value, 24) And &HFF)
        End If
    End If
    Return bytes
End Function

Function ByteArrayToInt(bytes As Object) As Integer
    result = 0
    For i = 0 To bytes.Count() - 1
        shift = (bytes.Count() - 1 - i) * 8
        byte = bytes[i]
        If byte = invalid Then
            Exit For
        End If
        result = result + BitShiftLeft(byte And &HFF, shift)
    Next
    Return result
End Function

Function IntToBinaryString(input As Integer, padWidth = 0 As Integer) As String
    output = ""
    binary = IntToBinaryArray(input, padWidth)
    For Each element In binary
        output = output + element.ToStr()
    Next
    Return output
End Function

Function IntToBinaryArray(input As Integer, padWidth = 0 As Integer) As Object
    output = []
    current = input
    While current <> 0
        output.Unshift(current Mod 2)
        current = Int(current / 2)
    End While
    For i = 1 To padWidth - output.Count()
        output.Unshift(0)
    Next
    Return IIf(output.Count() = 0, [0], output)
End Function

Function BinaryStringToInt(input As String) As Integer
    binary = []
    For i = 0 To input.Len() - 1
        binary.Push(input.Mid(i, 1).ToInt())
    Next
    Return BinaryArrayToInt(binary)
End Function

Function BinaryArrayToInt(input As Object) As Integer
    output = 0
    For i = 0 To input.Count() - 1
        output = output + input[input.Count() - 1 - i] * 2 ^ i
    Next
    Return output
End Function

Function IntToHex(int As Integer) As String
    Return IntToByteArray(int).ToHexString()
End Function

Function ByteToHex(byte As Integer) As String
    If byte > 255 Then
        byte = 255
    End If
    hexValues = "0123456789ABCDEF"
    hex = hexValues.Mid(Int(byte / 16), 1) + hexValues.Mid((byte Mod 16), 1)
    Return hex
End Function

Function HexToInt(hex As String) As Integer
    If hex.Mid(0, 1) = "#" Then
        hex = hex.Mid(1)
    End If
    ba = CreateObject("roByteArray")
    ba.FromHexString(hex)
    Return ByteArrayToInt(ba)
End Function

Function FloatToString(value As Float, decimalPlaces = 2 As Integer, ensureLeadingZero = True As Boolean) As String
    If Not IsFloat(value) Then
        value = 0.0
    End If
    value = Int(value * 10 ^ decimalPlaces) / (10 ^ decimalPlaces)
    output = Str(value).Trim()
    padding = decimalPlaces
    If output.InStr(".") = -1 Then
        output = output + "."
    End If
    If output.InStr(".") = 0 And ensureLeadingZero Then
        output = "0" + output
    End If
    padding = decimalPlaces - (output.Len() - (output.InStr(".") + 1))
    For i = 1 To padding
        output = output + "0"
    Next
    Return output
End Function


