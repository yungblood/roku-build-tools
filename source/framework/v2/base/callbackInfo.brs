'IMPORTS=v2/base/globalObjectRegistry utilities/general utilities/strings
' ******************************************************
' Copyright Steven Kean 2010-2015
' All Rights Reserved.
' ******************************************************
Function NewCallbackInfo(receiver As Object, callback As String, failureCallback = callback As String, callbackData = invalid As Object) As Object
    this                    = {}
    this.ClassName          = "CallbackInfo"

    If Not IsNullOrEmpty(receiver.GlobalObjectRegistryID) Then
        ' The receiver is registered, so don't reference it directly
        this.ID             = receiver.GlobalObjectRegistryID
    Else
        If Not IsNullOrEmpty(receiver.ObserverID) Then
            this.ID         = receiver.ObserverID
        Else
            this.ID         = GenerateGuid()
        End If
        this.Receiver       = receiver
    End If
    this.SuccessMethod      = callback
    this.FailureMethod      = failureCallback
    this.CallbackData       = callbackData
    
    this.GetReceiver        = CallbackInfo_GetReceiver
    this.Callback           = CallbackInfo_Callback
    this.FailureCallback    = CallbackInfo_FailureCallback
    this.Dispose            = CallbackInfo_Dispose
    
    Return this
End Function

Function CallbackInfo_GetReceiver() As Object
    If m.Receiver <> invalid Then
        Return m.Receiver
    Else If m.ID <> invalid Then
        Return GlobalObjectRegistry().GetObject(m.ID)
    End If
    Return invalid
End Function

Function CallbackInfo_Callback(data = {} As Object) As Dynamic
    receiver = m.GetReceiver()
    If receiver <> invalid Then
        If Not IsNullOrEmpty(m.SuccessMethod) Then
            If IsFunction(receiver[m.SuccessMethod]) Then
                result = receiver[m.SuccessMethod](data, m.CallbackData)
                Return result 
            End If
        End If
    End If
End Function

Function CallbackInfo_FailureCallback(data = {} As Object) As Dynamic
    receiver = m.GetReceiver()
    If receiver <> invalid Then
        If Not IsNullOrEmpty(m.FailureMethod) Then
            If IsFunction(receiver[m.FailureMethod]) Then
                result = receiver[m.FailureMethod](data, m.CallbackData)
                Return result 
            End If
        End If
    End If
End Function

Sub CallbackInfo_Dispose()
    ' De-reference the callback data
    m.Receiver = invalid
    ' De-reference the callback data
    m.CallbackData = invalid
End Sub
