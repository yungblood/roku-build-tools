'IMPORTS=utilities/arrays utilities/cookies utilities/debug utilities/strings utilities/types 
' ******************************************************
' Copyright Steven Kean 2010-2015
' All Rights Reserved.
' ******************************************************
Function GetWebRequestQueue() As Object
    If m.WebRequestQueue = invalid Then
        this = {
            EventPort:              CreateObject("roMessagePort")
            MaxConcurrentRequests:  10
            Requests:               []
            PendingRequests:        []
            
            ProcessRequests:        WebRequestQueue_ProcessRequests
            QueuePendingRequests:   WebRequestQueue_QueuePendingRequests
            
            GetUrlTransfer:         WebRequestQueue_GetUrlTransfer
            PrepRequest:            WebRequestQueue_PrepRequest
            QueueGetRequest:        WebRequestQueue_QueueGetRequest
            QueuePostRequest:       WebRequestQueue_QueuePostRequest
        }
        m.WebRequestQueue = this
    End If
    Return m.WebRequestQueue
End Function

Function WebRequestQueue_ProcessRequests(processTime = 0 As Integer) As Boolean
    processedRequests = False
    timer = CreateObject("roTimespan")
    While timer.TotalMilliseconds() <= processTime And Not m.Requests.IsEmpty()
        msg = m.EventPort.GetMessage()
        If msg <> invalid And Type(msg) = "roUrlEvent" Then
            requestID = AsString(msg.GetSourceIdentity())
            requestIndex = FindElementIndexInArray(m.Requests, requestID, "ID")
            If requestIndex > -1 Then
                request = m.Requests[requestIndex]
                
                DebugPrint(request.RequestTimer.TotalMilliseconds(), "WebRequestQueue.ProcessRequests (" + requestID + ": " + request.Http.GetUrl() + ")", 2)
                
                response = {}
                response.Response               = msg.GetString()
                response.ResponseHeaders        = msg.GetResponseHeaders()
                response.ResponseHeadersArray   = msg.GetResponseHeadersArray()
                response.ResponseCode           = msg.GetResponseCode()
                
                ParseCookieHeaders(request.Http.GetUrl(), response.ResponseHeadersArray)

                ' Delete this request from the queue
                m.Requests.Delete(requestIndex)
                m.QueuePendingRequests()
                
                response.CallbackData = request.CallbackData
                If request.CallbackObject <> invalid And Not IsNullOrEmpty(request.CallbackMethod) Then
                    If IsFunction(request.CallbackObject[request.CallbackMethod]) Then
                        request.CallbackObject[request.CallbackMethod](response)
                    End If
                End If
            End If
            processedRequests = True
        End If
    End While
    Return processedRequests
End Function

Sub WebRequestQueue_QueuePendingRequests()
    activeRequests = []
    activeRequests.Append(m.Requests)
    m.Requests = activeRequests
    
    For i = m.Requests.Count() To m.MaxConcurrentRequests
        If m.PendingRequests.Count() = 0 Then
            Exit For
        End If
        request = m.PendingRequests.Shift()
        request.Http = m.GetUrlTransfer(request.Url, request.Headers, request.Certificates, request.CertificatesDepth)
        request.ID = AsString(request.Http.GetIdentity())
        If request.Type = "POST" Then
            request.Http.AsyncPostFromString(request.PostData)
        Else
            request.Http.AsyncGetToString()
        End If
        request.RequestTimer.Mark()
        m.Requests.Push(request)
        
        DebugPrint(request.Url, "WebRequestQueue.QueuePendingRequests", 2)
    Next
End Sub

Function WebRequestQueue_GetUrlTransfer(url As String, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer) As Object
    http = CreateObject("roUrlTransfer")
    http.SetPort(m.EventPort)
    http.SetUrl(url)
    http.EnableFreshConnection(True)
    If Not IsRokuOne() Then
        http.RetainBodyOnError(True)
        http.EnableEncodings(True)
    End If
    If Not IsNullOrEmpty(certificates) Then
        http.SetCertificatesFile(certificates)
        If certificatesDepth > -1 Then
            http.SetCertificatesDepth(certificatesDepth)
        End If
    End If
    If IsAssociativeArray(headers) Then
        http.SetHeaders(headers)
    End If
    If CookiesEnabled() Then
        cookies = GetCookiesForUrl(url)
        If Not IsNullOrEmpty(cookies) Then
            http.AddHeader("Cookie", cookies)
            DebugPrint(cookies, "Adding Cookies", 2)
        End If
    End If
    Return http
End Function

Function WebRequestQueue_PrepRequest(url As String, postData = "" As String, callbackObject = invalid As Object, callbackMethod = "" As String, callbackData = invalid As Object, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, method = "GET" As String) As Object
    request = {
        ID:                 invalid
        Http:               invalid
        CallbackObject:     callbackObject
        CallbackMethod:     callbackMethod
        CallbackData:       callbackData
        Url:                url
        PostData:           postData
        Headers:            headers
        Certificates:       certificates
        CertificatesDepth:  certificatesDepth
        Method:             method
        RequestTimer:       CreateObject("roTimespan")
        Type:               method
    }
    Return request
End Function
 
Sub WebRequestQueue_QueueGetRequest(url As String, callbackObject As Object, callbackMethod As String, callbackData = invalid As Object, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, method = "GET" As String)
    DebugPrint(url, "WebRequestQueue.QueueGetRequest", 2)
    request = m.PrepRequest(url, "", callbackObject, callbackMethod, callbackData, headers, certificates, certificatesDepth, method)
    request.Type = "GET"
    m.PendingRequests.Push(request)
    m.QueuePendingRequests()
End Sub
 
Sub WebRequestQueue_QueuePostRequest(url As String, postData = "" As String, callbackObject = invalid As Object, callbackMethod = "" As String, callbackData = invalid As Object, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, method = "POST" As String)
    DebugPrint(url, "WebRequestQueue.QueuePostRequest", 2)
    If IsNullOrEmpty(postData) Then
        postData = ""
    End If
    request = m.PrepRequest(url, postData, callbackObject, callbackMethod, callbackData, headers, certificates, certificatesDepth, method)
    request.Type = "POST"
    m.PendingRequests.Push(request)
    m.QueuePendingRequests()
End Sub
