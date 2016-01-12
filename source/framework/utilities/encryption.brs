'IMPORTS=utilities/conversion utilities/base64
' ******************************************************
' Copyright Steven Kean 2010-2015
' All Rights Reserved.
' ******************************************************
'====================================
' Encryption
'====================================
Function HMACSignature(dataString As String, keyString As String, digest = "md5" As String, outputMode = "base64" As String) As String
    hmac = CreateObject("roHMAC") 
    key = CreateObject("roByteArray") 
    key.FromAsciiString(keyString) 
    If hmac.setup(digest, key) = 0 Then
        message = CreateObject("roByteArray") 
        message.FromAsciiString(dataString) 
        result = hmac.Process(message) 
        If outputMode = "base64" Then
            Return result.ToBase64String()
        Else If outputMode.InStr("hex") = 0 Then
            output = result.ToHexString()
            If outputMode = "hex" Or outputMode = "hexUpper" Then
                Return UCase(output)
            Else
                Return LCase(output)
            End If
        Else
            Return result.ToAsciiString()
        End If 
    End If 
    Return ""
End Function

Function Decrypt(method As String, key As String, iv As String, text As String) As String
    Return HexDecrypt(method, Base64ToHex(key), Base64ToHex(iv), Base64ToHex(text))
End Function

Function Encrypt(method As String, key As String, IV As String, text As String) As String
    Return HexToBase64(HexEncrypt(method, Base64ToHex(key), Base64ToHex(iv), text))
End Function

Function HexDecrypt(method As String, key As String, IV As String, text As String) As String
    crypto = CreateObject("roEVPCipher")
    crypto.Setup(False, method, key, iv, 1)
    ba = CreateObject("roByteArray")
    ba.FromHexString(text)
    result = crypto.Process(ba)
    If result <> invalid Then
        Return result.ToAsciiString()
    Else
        Return text
    End If
End Function

Function HexEncrypt(method As String, key As String, iv As String, text As String) As String
    crypto = CreateObject("roEVPCipher")
    crypto.Setup(True, method, key, iv, 1)
    ba = CreateObject("roByteArray")
    ba.FromAsciiString(text)
    result = crypto.Process(ba)
    If result <> invalid Then
        Return result.ToHexString()
    Else
        Return text
    End If
End Function

Function MD5Hash(text As String) As String
    digest = CreateObject("roEVPDigest")
    digest.Setup("md5")
    ba = CreateObject("roByteArray")
    ba.FromAsciiString(text)
    digest.Update(ba)
    Return LCase(digest.Final())
End Function
