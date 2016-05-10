'IMPORTS=utilities/dateTime utilities/types utilities/general utilities/strings utilities/application utilities/device utilities/web
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
' LogLevels:
'   0 - None
'   1 - Normal
'   2 - Verbose
'   3 - Diagnostic
'   4 - Exhaustive
Sub SetLogLevel(logLevel = 0 As Integer, remoteLoggingUrl = "" As String)
    m.DebugLogLevel = logLevel
    m.RemoteLogUrl  = remoteLoggingUrl
    m.LogRequests   = []
End Sub

Function GetLogLevel() As Integer
    Return m.DebugLogLevel
End Function

Sub DebugPrint(data As Object, prefix = "" As String, logLevel = 0 As Integer, remoteLoggingUrl = "" As String)
    If IsNullOrEmpty(remoteLoggingUrl) And Not IsNullOrEmpty(m.RemoteLogUrl) Then
        remoteLoggingUrl = m.RemoteLogUrl
    End If
    If AsInteger(m.DebugLogLevel) >= logLevel Then
        print Serialize(data, prefix)
        If Not IsNullOrEmpty(remoteLoggingUrl) And m.RemoteLogging <> True Then
            ' Set flag to prevent recursive logging
            m.RemoteLogging = True
            
            manifest = GetManifest()
            fileName = Replace(manifest.title, " ", "") + "." + GetAppVersion() + ".log"
            fileName = UrlEncode(fileName)
            content = UrlEncode(Serialize(data, prefix))
            deviceID = UrlEncode(GetDeviceID())
            m.LogRequests.Push(PostUrlToStringAsync(remoteLoggingUrl, "logFile=" + fileName + "&content=" + content + "&deviceID=" + deviceID))
            ProcessLogRequests()
            m.RemoteLogging = False
        End If
    End If
End Sub

Sub ProcessLogRequests(timeout = 5000 As Integer, blockUntilComplete = False As Boolean)
    For i = 0 To m.LogRequests.Count() - 1
        request = m.LogRequests[i]
        If request <> invalid Then
            msg = invalid
            If blockUntilComplete Then
                If IsRokuOne() Then
                    msg = Wait(timeout, request.GetPort())
                Else
                    msg = Wait(timeout, request.GetMessagePort())
                End If
            Else
                If IsRokuOne() Then
                    msg = request.GetPort().GetMessage()
                Else
                    msg = request.GetMessagePort().GetMessage()
                End If
            End If
            If Type(msg) = "roUrlEvent" And msg.GetInt() = 1 Then
                ' Remove the request from the queue
                m.LogRequests[i] = invalid
            Else If msg = invalid Then
                If blockUntilComplete Then
                    request.AsyncCancel()
                End If
            End If
        End If
    Next
    ' Remove any invalids
    trimmedRequests = []
    For Each request In m.LogRequests
        If request <> invalid Then
            trimmedRequests.Push(request)
        End If
    Next
    ' Reset the requests array
    m.LogRequests = trimmedRequests
End Sub
