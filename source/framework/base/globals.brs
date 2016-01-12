'IMPORTS=
' ******************************************************
' Copyright Steven Kean 2010-2015
' All Rights Reserved.
' ******************************************************
Function GetSystemLog() As Object
    If m.SystemLog = invalid Then
        m.SystemLog = CreateObject("roSystemLog")
        m.SystemLog.SetMessagePort(CreateObject("roMessagePort"))
        m.SystemLog.EnableType("http.error")
        m.SystemLog.EnableType("http.connect")
        m.SystemLog.EnableType("bandwidth.minute")
    End If
    Return m.SystemLog
End Function

Function GetMessagePort() As Object
    If m.MessagePort = invalid Then
        m.MessagePort = CreateObject("roMessagePort")
    End If
    Return m.MessagePort
End Function

Sub SetLastRecordedBandwidth(bandwidth As Integer)
    m.LastRecordedBandwidth = bandwidth
End Sub

Function GetLastRecordedBandwidth() As Integer
    If m.LastRecordedBandwidth = invalid Then
        m.LastRecordedBandwidth = 0
    End If
    Return m.LastRecordedBandwidth
End Function