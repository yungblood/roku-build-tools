'IMPORTS=utilities/conversion
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
Function IntToBase64(int As Integer, pad = True As Boolean) As String
    result = IntToByteArray(int).ToBase64String()
    If Not pad Then
        While result.Right(1) = "="
            result = result.Left(result.Len() - 1)
        End While
    End If
    Return result
End Function

Function Base64ToInt(base64 As String) As Integer
    ba = CreateObject("roByteArray")
    base64 = base64 + String(base64.Len() Mod 4, "=") 'Add padding characters
    ba.FromBase64String(base64)
    Return ByteArrayToInt(ba)
End Function

Function Base64ToString(base64 As String) As String
    ba = CreateObject("roByteArray")
    base64 = base64 + String(base64.Len() Mod 4, "=") 'Add padding characters
    ba.FromBase64String(base64)
    Return ba.ToAsciiString()
End Function

Function Base64ToHex(base64 As String) As String
    ba = CreateObject("roByteArray")
    ba.FromBase64String(base64)
    Return ba.ToHexString()
End Function

Function HexToBase64(hex As String) As String
    ba = CreateObject("roByteArray")
    ba.FromHexString(hex)
    Return ba.ToBase64String()
End Function

Function Base64Encode(value As String) As String
    ba = CreateObject("roByteArray")
    ba.FromAsciiString(value)
    Return ba.ToBase64String()
End Function

Function Base64Decode(base64 As String) As String
    ba = CreateObject("roByteArray")
    ba.FromBase64String(base64)
    Return ba.ToAsciiString()
End Function