'IMPORTS=utilities/debug utilities/general
' ******************************************************
' Copyright Steven Kean 2010-2015
' All Rights Reserved.
' ******************************************************
' Registers the callback object and functions on the parent object
Sub RegisterCallback(parent As Object, callbackObject As Dynamic, callbackPrefix = "" As String)
    parent.CallbackObject = callbackObject
    parent.CallbackPrefix = callbackPrefix
    
    parent.Callback = Common_Callback
    parent.CallbackNoParams = Common_CallbackNoParams
    parent.CallbackExists = Common_CallbackExists
End Sub

' Unregisters and dereferences callback object and functions on parent object
Sub UnregisterCallback(parent As Object)
    parent.CallbackObject = invalid
    parent.CallbackPrefix = ""
    
    parent.Callback = invalid
    parent.CallbackNoParams = invalid
    parent.CallbackExists = invalid
End Sub

Function Common_Callback(functionName As String, value As Dynamic, logLevel = 4 As Integer, sender = m As Object) As Dynamic
    DebugPrint(Serialize(value, "", -1), m.CallbackPrefix + functionName, logLevel)
    If m.CallbackExists(functionName) Then
        Return m.CallbackObject[m.CallbackPrefix + functionName](value, sender)
    End If
    Return invalid
End Function

Function Common_CallbackNoParams(functionName As String, logLevel = 4 As Integer, sender = m As Object) As Dynamic
    DebugPrint(m.CallbackPrefix + functionName, "", logLevel)
    If m.CallbackExists(functionName) Then
        Return m.CallbackObject[m.CallbackPrefix + functionName](sender)
    End If
    Return invalid
End Function

Function Common_CallbackExists(functionName As String) As Boolean
    Return m.CallbackObject <> invalid And m.CallbackObject[m.CallbackPrefix + functionName] <> invalid
End Function
