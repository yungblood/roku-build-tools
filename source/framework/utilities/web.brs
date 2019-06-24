'IMPORTS=utilities/device utilities/strings utilities/arrays utilities/debug utilities/cookies utilities/types
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
Function AddQueryString(url As String, parameter As String, value = "" As Dynamic, addIfExists = True As Boolean, encode = True As Boolean) As String
    queryString = parameter
    value = AsString(value)
    If Not IsNullOrEmpty(value) Then
        queryString = queryString + "="
        queryString = queryString + IIf(encode, UrlEncode(value), value)
    End If
    If Not addIfExists Then
        If url.InStr("?" + parameter + "=") > -1 Or url.InStr("&" + parameter + "=") > -1 Or url.InStr("?" + parameter + "&") > -1 Or url.InStr("&" + parameter + "&") > -1 Or EndsWith(url, "?" + parameter) Or EndsWith(url, "&" + parameter) Then
            Return url
        End If
    End If
    Return AddFormattedQueryString(url, queryString)
End Function

Function AddFormattedQueryString(url As String, queryString As String) As String
    If queryString.InStr("?") = 0 Or queryString.InStr("&") = 0 Then
        queryString = queryString.Mid(1)
    End If
    If url.InStr("?") = -1 Then
        url = url + "?"
    Else
        url = url + "&"
    End If
    Return url + queryString
End Function

Function SortQueryString(qs As String) As String
    addQuestion = False
    If Not IsNullOrEmpty(qs) Then
        If qs.Mid(0, 1) = "?" Then
            qs = qs.Mid(1)
            addQuestion = True
        End If
    End If
    queryParts = qs.Tokenize("&")
    SortArray(queryParts)
    outQS = ""
    For Each query in queryParts
        If outQS <> "" Then
            outQS = outQS + "&"
        End If
        outQS = outQS + query
    Next
    If addQuestion Then
        outQS = "?" + outQS
    End If
    Return outQS
End Function

Function ParseQueryString(qs As String, useUrlTransfer = false as boolean) As Object
    querystring = {}
    If qs.InStr("?") > -1 Then
        qs = qs.Mid(qs.InStr("?") + 1)
    End If        
    queryParts = qs.Tokenize("&")
    For each query in queryParts
        qsValueParts = query.Tokenize("=")
        If qsValueParts.Count() >= 2 Then
            querystring[UrlDecode(qsValueParts[0], useUrlTransfer)] = UrlDecode(qsValueParts[1], useUrlTransfer)
        Else
            querystring[UrlDecode(qsValueParts[0], useUrlTransfer)] = ""
        End If
    Next
    Return querystring
End Function

Function UrlEncode(str As String, formal = True As Boolean, useUrlTransfer = false as boolean) As String
    urlEncodeDecode = invalid
    if useUrlTransfer then
        urlEncodeDecode = CreateObject("roUrlTransfer")
    end if
    if urlEncodeDecode = invalid then
        Return str.encodeUriComponent()
    else
        If formal Then
            Return urlEncodeDecode.UrlEncode(str)
        Else
            Return urlEncodeDecode.Escape(str)
        End If
    end if
End Function

Function UrlDecode(str As String, useUrlTransfer = false as boolean) As String
    urlEncodeDecode = invalid
    if useUrlTransfer then
        urlEncodeDecode = CreateObject("roUrlTransfer")
    end if
    str = Replace(str, "+", " ")
    if urlEncodeDecode = invalid then
        Return str.decodeUriComponent()
    else
        Return urlEncodeDecode.Unescape(str)
    end if
End Function

Function GetExtensionFromUrl(url As String) As String
    extension = ""
    query = url.InStr("?")
    If query > -1 Then
        url = url.Mid(0, query)
    End If
    If url.Instr(".") > -1 Then
        For i = url.Len() - 1 To 0 Step -1
            char = url.Mid(i, 1)
            If char <> "." Then
                If char = "/" Then
                    ' We didn't find a dot before hitting
                    ' a slash, so bail with no extension
                    extension = ""
                    Exit For
                End If
                extension = char + extension
            Else
                Exit For
            End If
        Next
    End If
    If Not IsNullOrEmpty(extension) Then
        extension = "." + extension
    End If
    Return extension
End Function

Function GetUrlHeadersEx(url As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, requireCertVerification = True As Boolean) As Object
    DebugPrint(url, "GetUrlHeaders", 2)
    timeout = timeout * 1000
    
    response = {
        ResponseCode:           0
        ResponseHeaders:        {}
        ResponseHeadersArray:   []
        Response:               ""
    }
    http = CreateObject("roUrlTransfer")
    http.SetPort(CreateObject("roMessagePort"))
    http.SetUrl(url)
    http.EnableFreshConnection(True)
    http.EnableCookies()
    http.RetainBodyOnError(True)
    http.EnableEncodings(True)
    
    If Not IsNullOrEmpty(certificates) Then
        http.SetCertificatesFile(certificates)
        If certificatesDepth > -1 Then
            http.SetCertificatesDepth(certificatesDepth)
        End If
        http.EnablePeerVerification(requireCertVerification)
        http.EnableHostVerification(requireCertVerification)
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

    If http.AsyncHead() Then
        msg = Wait(timeout, http.GetPort())
        If Type(msg) = "roUrlEvent" And msg.GetInt() = 1 Then
            response.Response = msg.GetString()
            response.ResponseHeaders = msg.GetResponseHeaders()
            response.ResponseHeadersArray = msg.GetResponseHeadersArray()
            response.ResponseCode = msg.GetResponseCode()
            
            ParseCookieHeaders(url, response.ResponseHeadersArray)
            
            DebugPrint(response, "GetUrlHeadersEx (" + url + ")", 3)
        Else If msg = invalid Then
            DebugPrint(url, "GetUrlHeadersEx.Timeout", 0)
            http.AsyncCancel()
            response.ResponseCode = -1
        Else
            DebugPrint(msg, "AsyncHead unknown event", 0)
        End If
    End If
    Return response
End Function

Function GetUrlHeaders(url As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, requireCertVerification = True As Boolean) As Object
    Return GetUrlHeadersEx(url, timeout, headers, certificates, certificatesDepth).ResponseHeaders
End Function

Function GetUrlToStringEx(url As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, method = "GET" As String, requireCertVerification = True As Boolean) As Object
    DebugPrint({ Url: url, Headers: headers }, "GetUrlToStringEx", 2)
    timeout = timeout * 1000
    
    response = {
        ResponseCode:           0
        ResponseHeaders:        {}
        ResponseHeadersArray:   []
        Response:               ""
    }
    If StartsWith(url, "http") Then
        http = CreateObject("roUrlTransfer")
        http.SetPort(CreateObject("roMessagePort"))
        http.SetUrl(url)
        http.SetRequest(method)
        http.EnableFreshConnection(True)
        http.EnableCookies()
        http.RetainBodyOnError(True)
        http.EnableEncodings(True)
        
        If Not IsNullOrEmpty(certificates) Then
            http.SetCertificatesFile(certificates)
            If certificatesDepth > -1 Then
                http.SetCertificatesDepth(certificatesDepth)
            End If
            http.EnablePeerVerification(requireCertVerification)
            http.EnableHostVerification(requireCertVerification)
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

        If http.AsyncGetToString() Then
            msg = Wait(timeout, http.GetPort())
            If Type(msg) = "roUrlEvent" And msg.GetInt() = 1 Then
                response.Response = msg.GetString()
                response.ResponseHeaders = msg.GetResponseHeaders()
                response.ResponseHeadersArray = msg.GetResponseHeadersArray()
                response.ResponseCode = msg.GetResponseCode()
                
                DebugPrint(response, "GetUrlToStringEx (" + url + ")", 3)

                ParseCookieHeaders(url, response.ResponseHeadersArray)
            Else If msg = invalid Then
                DebugPrint(url, "GetUrlToStringEx.Timeout", 0)
                http.AsyncCancel()
                response.ResponseCode = -1
            Else
                DebugPrint(msg, "AsyncGetToString unknown event", 0)
            End If
        End If
    Else
        response.Response = ReadAsciiFile(url)
        response.ResponseCode = 200
    End If
    response.Raw = response.Response
    Return response
End Function

Function GetUrlToString(url As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, method = "GET" As String, requireCertVerification = True As Boolean) As String
    Return GetUrlToStringEx(url, timeout, headers, certificates, certificatesDepth, method, requireCertVerification).Response
End Function

Function GetUrlToStringAsync(url As String, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, method = "GET" As String, requireCertVerification = True As Boolean) As Dynamic
    DebugPrint({ Url: url, Headers: headers }, "GetUrlToStringAsync", 2)

    http = CreateObject("roUrlTransfer")
    http.SetPort(CreateObject("roMessagePort"))
    http.SetUrl(url)
    http.SetRequest(method)
    http.EnableFreshConnection(True)
    http.EnableCookies()
    http.RetainBodyOnError(True)
    http.EnableEncodings(True)
         
    If Not IsNullOrEmpty(certificates) Then
        http.SetCertificatesFile(certificates)
        If certificatesDepth > -1 Then
            http.SetCertificatesDepth(certificatesDepth)
        End If
        http.EnablePeerVerification(requireCertVerification)
        http.EnableHostVerification(requireCertVerification)
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

    If http.AsyncGetToString() Then
        Return http
    End If

    Return invalid
End Function

Function GetUrlToFileEx(url As String, path As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, method = "GET" As String, requireCertVerification = True As Boolean) As Object
    DebugPrint(url, "GetUrlToFileEx", 2)
    timeout = timeout * 1000
    
    response = {
        ResponseCode:           0
        ResponseHeaders:        {}
        ResponseHeadersArray:   []
        Response:               ""
    }

    http = CreateObject("roUrlTransfer")
    http.SetPort(CreateObject("roMessagePort"))
    http.SetUrl(url)
    http.SetRequest(method)
    http.EnableFreshConnection(True)
    http.EnableCookies()
    http.RetainBodyOnError(True)
    http.EnableEncodings(True)

    If Not IsNullOrEmpty(certificates) Then
        http.SetCertificatesFile(certificates)
        If certificatesDepth > -1 Then
            http.SetCertificatesDepth(certificatesDepth)
        End If
        http.EnablePeerVerification(requireCertVerification)
        http.EnableHostVerification(requireCertVerification)
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

    If http.AsyncGetToFile(path) Then
        msg = Wait(timeout, http.GetPort())
        If Type(msg) = "roUrlEvent" And msg.GetInt() = 1 Then
            response.Response = msg.GetString()
            response.ResponseHeaders = msg.GetResponseHeaders()
            response.ResponseHeadersArray = msg.GetResponseHeadersArray()
            response.ResponseCode = msg.GetResponseCode()
            
            ParseCookieHeaders(url, response.ResponseHeadersArray)
            
            DebugPrint(response, "GetUrlToFileEx (" + url + ")", 3)
        Else If msg = invalid Then
            DebugPrint(url, "GetUrlToFileEx.Timeout", 0)
            http.AsyncCancel()
            response.ResponseCode = -1
        Else
            DebugPrint(msg, "AsyncGetToString unknown event", 0)
        End If
    End If

    Return response
End Function

Function GetUrlToFile(url As String, path As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, method = "GET" As String, requireCertVerification = True As Boolean) As Dynamic
    Return GetUrlToFileEx(url, path, timeout, headers, certificates, certificatesDepth, method, requireCertVerification).Response
End Function

Function GetUrlToFileAsync(url As String, path As String, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, method = "GET" As String, requireCertVerification = True As Boolean) As Dynamic
    DebugPrint(url, "GetUrlToFileAsync", 2)

    http = CreateObject("roUrlTransfer")
    http.SetPort(CreateObject("roMessagePort"))
    http.SetUrl(url)
    http.SetRequest(method)
    http.EnableFreshConnection(True)
    http.EnableCookies()
    http.RetainBodyOnError(True)
    http.EnableEncodings(True)
         
    If Not IsNullOrEmpty(certificates) Then
        http.SetCertificatesFile(certificates)
        If certificatesDepth > -1 Then
            http.SetCertificatesDepth(certificatesDepth)
        End If
        http.EnablePeerVerification(requireCertVerification)
        http.EnableHostVerification(requireCertVerification)
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

    If http.AsyncGetToFile(path) Then
        Return http
    End If

    Return invalid
End Function

Function PostUrlToStringEx(url As String, postData = "" As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, method = "POST" As String, requireCertVerification = True As Boolean) As Object
    DebugPrint({ Url: url, PostData: postData, Headers: headers }, "PostUrlToStringEx", 2)
    timeout = timeout * 1000
    
    response = {
        ResponseCode:       0
        ResponseHeaders:    {}
        Response:           ""
    }

    http = CreateObject("roUrlTransfer")
    http.SetPort(CreateObject("roMessagePort"))
    http.SetUrl(url)
    http.SetRequest(method)
    http.EnableFreshConnection(True)
    http.EnableCookies()
    http.RetainBodyOnError(True)
    http.EnableEncodings(True)

    If Not IsNullOrEmpty(certificates) Then
        http.SetCertificatesFile(certificates)
        If certificatesDepth > -1 Then
            http.SetCertificatesDepth(certificatesDepth)
        End If
        http.EnablePeerVerification(requireCertVerification)
        http.EnableHostVerification(requireCertVerification)
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

    If http.AsyncPostFromString(postData) Then
        msg = Wait(timeout, http.GetPort())
        If Type(msg) = "roUrlEvent" And msg.GetInt() = 1 Then
            response.Response = msg.GetString()
            response.ResponseHeaders = msg.GetResponseHeaders()
            response.ResponseHeadersArray = msg.GetResponseHeadersArray()
            response.ResponseCode = msg.GetResponseCode()
            
            ParseCookieHeaders(url, response.ResponseHeadersArray)
            
            DebugPrint(response, "PostUrlToStringEx (" + url + ")", 3)
        Else If msg = invalid Then
            DebugPrint(url, "PostUrlToStringEx.Timeout", 0)
            http.AsyncCancel()
            response.ResponseCode = -1
        Else
            DebugPrint(msg, "AsyncPostFromString unknown event", 0)
        End If
    End If
    response.Raw = response.Response
    Return response
End Function

Function PostUrlToString(url As String, postData = "" As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, method = "POST" As String, requireCertVerification = True As Boolean) As String
    Return PostUrlToStringEx(url, postData, timeout, headers, certificates, certificatesDepth, method, requireCertVerification).Response
End Function

Function PostUrlToStringAsync(url As String, postData = "" As String, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, method = "POST" As String, requireCertVerification = True As Boolean) As Dynamic
    DebugPrint({ Url: url, PostData: postData, Headers: headers}, "PostUrlToStringAsync", 2)

    http = CreateObject("roUrlTransfer")
    http.SetPort(CreateObject("roMessagePort"))
    http.SetUrl(url)
    http.SetRequest(method)
    http.EnableFreshConnection(True)
    http.EnableCookies()
    http.RetainBodyOnError(True)
    http.EnableEncodings(True)

    If Not IsNullOrEmpty(certificates) Then
        http.SetCertificatesFile(certificates)
        If certificatesDepth > -1 Then
            http.SetCertificatesDepth(certificatesDepth)
        End If
        http.EnablePeerVerification(requireCertVerification)
        http.EnableHostVerification(requireCertVerification)
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

    If http.AsyncPostFromString(postData) Then
        Return http
    End If

    Return invalid
End Function

Function GetUrlToXmlEx(url As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, method = "GET" As String, requireCertVerification = True As Boolean) As Dynamic
    xml = CreateObject("roXmlElement")
    response = GetUrlToStringEx(url, timeout, headers, certificates, certificatesDepth, method, requireCertVerification)
    If response <> invalid Then
        If Not IsNullOrEmpty(response.Response) And xml.Parse(response.Response) Then
            response.Xml = xml
        Else
            response.Xml = invalid
        End If
    End If
    Return response
End Function

Function GetUrlToXml(url As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, method = "GET" As String, requireCertVerification = True As Boolean) As Dynamic
    Return GetUrlToXmlEx(url, timeout, headers, certificates, certificatesDepth, method, requireCertVerification).Xml
End Function

Function PostUrlToXmlEx(url As String, postData = "" As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, method = "POST" As String, requireCertVerification = True As Boolean) As Dynamic
    xml = CreateObject("roXmlElement")
    response = PostUrlToStringEx(url, postData, timeout, headers, certificates, certificatesDepth, method, requireCertVerification)
    If response <> invalid Then
        If Not IsNullOrEmpty(response.Response) And xml.Parse(response.Response) Then
            response.Xml = xml
        Else
            response.Xml = invalid
        End If
    End If
    Return response
End Function

Function PostUrlToXml(url As String, postData = "" As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, method = "POST" As String, requireCertVerification = True As Boolean) As Dynamic
    Return PostUrlToXmlEx(url, postData, timeout, headers, certificates, certificatesDepth, method, requireCertVerification).Xml
End Function

Function PutUrlToStringEx(url As String, postData = "" As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, requireCertVerification = True As Boolean) As Object
    Return PostUrlToStringEx(url, postData, timeout, headers, certificates, certificatesDepth, "PUT", requireCertVerification)
End Function

Function PutUrlToString(url As String, postData = "" As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, requireCertVerification = True As Boolean) As String
    Return PostUrlToString(url, postData, timeout, headers, certificates, certificatesDepth, "PUT", requireCertVerification)
End Function

Function PutUrlToXmlEx(url As String, postData = "" As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, requireCertVerification = True As Boolean) As Dynamic
    Return PostUrlToXmlEx(url, postData, timeout, headers, certificates, certificatesDepth, "PUT", requireCertVerification)
End Function

Function PutUrlToXml(url As String, postData = "" As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, requireCertVerification = True As Boolean) As Dynamic
    Return PostUrlToXml(url, postData, timeout, headers, certificates, certificatesDepth, "PUT", requireCertVerification)
End Function

Function PutUrlToJsonEx(url As String, postData = "" As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, requireCertVerification = True As Boolean) As Dynamic
    Return PostUrlToJsonEx(url, postData, timeout, headers, certificates, certificatesDepth, "PUT", requireCertVerification)
End Function

Function PutUrlToJson(url As String, postData = "" As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, requireCertVerification = True As Boolean) As Dynamic
    Return PostUrlToJson(url, postData, timeout, headers, certificates, certificatesDepth, "PUT", requireCertVerification)
End Function

Function DeleteUrlToStringEx(url As String, postData = "" As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, requireCertVerification = True As Boolean) As Object
    Return PostUrlToStringEx(url, postData, timeout, headers, certificates, certificatesDepth, "DELETE", requireCertVerification)
End Function

Function DeleteUrlToString(url As String, postData = "" As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, requireCertVerification = True As Boolean) As String
    Return PostUrlToString(url, postData, timeout, headers, certificates, certificatesDepth, "DELETE", requireCertVerification)
End Function

Function DeleteUrlToXmlEx(url As String, postData = "" As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, requireCertVerification = True As Boolean) As Dynamic
    Return PostUrlToXmlEx(url, postData, timeout, headers, certificates, certificatesDepth, "DELETE", requireCertVerification)
End Function

Function DeleteUrlToXml(url As String, postData = "" As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, requireCertVerification = True As Boolean) As Dynamic
    Return PostUrlToXml(url, postData, timeout, headers, certificates, certificatesDepth, "DELETE", requireCertVerification)
End Function

Function DeleteUrlToJsonEx(url As String, postData = "" As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, requireCertVerification = True As Boolean) As Dynamic
    Return PostUrlToJsonEx(url, postData, timeout, headers, certificates, certificatesDepth, "DELETE", requireCertVerification)
End Function

Function DeleteUrlToJson(url As String, postData = "" As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, requireCertVerification = True As Boolean) As Dynamic
    Return PostUrlToJson(url, postData, timeout, headers, certificates, certificatesDepth, "DELETE", requireCertVerification)
End Function

Function GetBitmapFromUrl(url As String, timeout = 30 As Integer, extension = "" As String) As Object
    imageUrl = url
    If url.InStr("http") = 0 Then
        If IsNullOrEmpty(extension) Then
            extension = GetExtensionFromUrl(url)
        End If
        imageUrl = "tmp:/tmpFile_" + MD5Hash(url) + extension
        If Not FileExists(imageUrl) Then
            GetUrlToFile(url, imageUrl, timeout)
        End If
    End If
    bitmap = invalid
    If FileExists(imageUrl) Then
        bitmap = CreateObject("roBitmap", imageUrl)
        If bitmap = invalid Then
            DebugPrint(url, "GetBitmapFromUrl.Retry", 0)
            bitmap = CreateObject("roBitmap", imageUrl)
        End If
    End If
    Return bitmap
End Function

Function GetBitmapFromUrlAsync(url As String, extension = "" As String) As String
    imageUrl = url
    If url.InStr("http") = 0 Then
        If IsNullOrEmpty(extension) Then
            extension = GetExtensionFromUrl(url)
        End If
        imageUrl = "tmp:/tmpFile_" + MD5Hash(url) + extension
        If Not FileExists(imageUrl) Then
            If m.WebClients = invalid Then
                m.WebClients = []
            End If
            m.WebClients.Push(GetUrlToFileAsync(url, imageUrl))
        End If
    End If
    Return imageUrl
End Function

Function GetUrlToJsonEx(url As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, method = "GET" As String, requireCertVerification = True As Boolean) As Dynamic
    response = GetUrlToStringEx(url, timeout, headers, certificates, certificatesDepth, method, requireCertVerification)
    If response <> invalid Then
        response.Json = invalid
        If Not IsNullOrEmpty(response.Response) Then
            json = ParseJSON(response.Response)
            If json <> invalid Then
                response.Json = json
            End If
        End If
    End If
    Return response
End Function

Function GetUrlToJson(url As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, method = "GET" As String) As Dynamic
    Return GetUrlToJsonEx(url, timeout, headers, certificates, certificatesDepth, method).Json
End Function

Function PostUrlToJsonEx(url As String, postData = "" As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, method = "POST" As String, requireCertVerification = True As Boolean) As Dynamic
    response = PostUrlToStringEx(url, postData, timeout, headers, certificates, certificatesDepth, method, requireCertVerification)
    If response <> invalid Then
        If Not IsNullOrEmpty(response.Response) Then
            response.Json = ParseJson(response.Response)
        Else
            response.Json = invalid
        End If
    End If
    Return response
End Function

Function PostUrlToJson(url As String, postData = "" As String, timeout = 30 As Integer, headers = invalid As Object, certificates = "common:/certs/ca-bundle.crt" As String, certificatesDepth = -1 As Integer, method = "POST" As String, requireCertVerification = True As Boolean) As Dynamic
    Return PostUrlToJsonEx(url, postData, timeout, headers, certificates, certificatesDepth, method, requireCertVerification).Json
End Function

Function UrlExists(url As String, timeout = 30 As Integer) As Boolean
    headers = GetUrlHeadersEx(url, timeout)
    Return (Int(headers.ResponseCode / 100) = 2)
End Function
