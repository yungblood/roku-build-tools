'IMPORTS=v2/base/observable v2/base/globalObjectRegistry utilities/general
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
Function NewEventPort(port = invalid As Object, timeout = -1 As Integer) As Object
    If port = invalid Then
        port = CreateObject("roMessagePort")
    End If

    this                = NewObservable()
    this.ID             = GenerateGuid()
    this.Port           = port
    this.Timeout        = timeout
    this.EventTimer     = CreateObject("roTimespan")
    
    this.GetMessage     = EventPort_GetMessage

    Return this
End Function

Function EventPort_GetMessage(timeout = -1 As Integer) As Object
    msg = invalid
    If m.HasObservers() Then
        msg = m.RaiseEvent("GetMessage", { Timeout: timeout, Port: m.Port })
    End If
    If msg = invalid And m.Port <> invalid Then
        If timeout = -1 Then
            msg = m.Port.GetMessage()
        Else
            msg = Wait(timeout, m.Port)
        End If
    End If
    Return msg
End Function