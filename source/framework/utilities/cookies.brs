'IMPORTS=utilities/strings 
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
Sub EnableCookies(enable = True As Boolean)
    m.EnableCookies = enable
End Sub

Function CookiesEnabled() As Boolean
    Return m.EnableCookies <> False
End Function

Function GetCookieContainer() As Object
    If m.CookieContainer = invalid Then
        m.CookieContainer = {}
    End If
    Return m.CookieContainer
End Function

Function GetCookiesForUrl(url As String) As String
    domain = GetCookieDomain(url)
    path = GetCookiePath(url)
    container = GetCookieContainer()
    cookies = []
    For Each cookieDomain In container
        If EndsWith(domain, cookieDomain) Then
            cookies.Append(container[cookieDomain])
        End If
    Next
    cookieStrings = []
    For cookieIndex = cookies.Count() - 1 To 0 Step -1
        cookie = cookies[cookieIndex]
        If cookie = invalid Or (cookie.Expires > 0 And cookie.Expires <= NowDate().AsSeconds()) Then
            cookies.Delete(cookieIndex)
        Else
            If StartsWith(path, cookie.Path) Then
                cookieStrings.Push(cookie.Name + "=" + cookie.Value)
            End If
        End If
    Next
    Return Join(cookieStrings, "; ")
End Function

Sub DeleteCookiesForUrl(url As String)
    domain = GetCookieDomain(url)
    container = GetCookieContainer()
    container.Delete(domain)
End Sub

Sub DeleteAllCookies()
    GetCookieContainer().Clear()
End Sub

Function GetCookie(cookieName As String, url = "" As String) As String
    domain = ""
    path = ""
    container = GetCookieContainer()
    If Not IsNullOrEmpty(url) Then
        domain = GetCookieDomain(url)
        path = GetCookiePath(url)
    End If
    cookies = []
    For Each cookieDomain In container
        If IsNullOrEmpty(domain) Or EndsWith(domain, cookieDomain) Then
            cookies.Append(container[cookieDomain])
        End If
    Next
    cookieStrings = []
    For cookieIndex = cookies.Count() - 1 To 0 Step -1
        cookie = cookies[cookieIndex]
        If cookie = invalid Or (cookie.Expires > 0 And cookie.Expires <= NowDate().AsSeconds()) Then
            cookies.Delete(cookieIndex)
        Else
            If cookie.Name = cookieName Then
                If IsNullOrEmpty(path) Or StartsWith(path, cookie.Path) Then
                    Return cookie.Value
                End If
            End If
        End If
    Next
    Return ""
End Function

Sub SetCookie(cookieName As String, cookieValue As String, url = "" As String)
    domain = ""
    path = ""
    container = GetCookieContainer()
    If Not IsNullOrEmpty(url) Then
        domain = GetCookieDomain(url)
        path = GetCookiePath(url)
    End If
    cookies = []
    For Each cookieDomain In container
        If IsNullOrEmpty(domain) Or EndsWith(domain, cookieDomain) Then
            cookies.Append(container[cookieDomain])
        End If
    Next
    For Each cookie In cookies
        If cookie.Name = cookieName Then
            cookie.Value = cookieValue
            Return
        End If
    Next
    ' If we get this far, the cookie doesn't exist, so add it
    cookie = {
        Name:       cookieName
        Value:      cookieValue
        Domain:     domain
        Path:       path
        Expires:    0
    }
    cookies = container[cookie.Domain]
    If cookies = invalid Then
        cookies = []
        container[cookie.Domain] = cookies
    End If
    cookies.Push(cookie)
End Sub

Function GetCookieDomain(url As String) As String
    domain = url
    If domain.InStr("://") > -1 Then
        domain = domain.Mid(domain.InStr("://") + 3)
    End If
    If domain.InStr("/") > -1 Then
        domain = domain.Mid(0, domain.InStr("/"))
    End If
    Return LCase(domain)
End Function

Function GetCookiePath(url As String) As String
    path = url
    If path.InStr("://") > -1 Then
        path = path.Mid(path.InStr("://") + 3)
    End If
    If path.InStr("/") > -1 Then
        path = path.Mid(path.InStr("/"))
        If path.InStr("?") > -1 Then
            path = path.Mid(0, path.InStr("?"))
        End If
        If path.InStr("#") > -1 Then
            path = path.Mid(0, path.InStr("#"))
        End If
    Else
        path = "/"
    End If
    Return path
End Function

Function GetCookieDate(date As String) As Object
    If date.InStr(", ") Then
        date = date.Mid(date.InStr(", ") + 2)
    End If
    date = Replace(date, "Jan", "01")
    date = Replace(date, "Feb", "02")
    date = Replace(date, "Mar", "03")
    date = Replace(date, "Apr", "04")
    date = Replace(date, "May", "05")
    date = Replace(date, "Jun", "06")
    date = Replace(date, "Jul", "07")
    date = Replace(date, "Aug", "08")
    date = Replace(date, "Sep", "09")
    date = Replace(date, "Oct", "10")
    date = Replace(date, "Nov", "11")
    date = Replace(date, "Dec", "12")
    date = Replace(date, " GMT", "Z")
    
    date = date.Mid(6, 4) + "-" + date.Mid(3, 2) + "-" + date.Mid(0, 2) + "T" + date.Mid(11) 

    Return DateFromISO8601String(date)
End Function

Sub ParseCookieHeaders(url As String, headerArray As Object)
    container = GetCookieContainer()
    domain = GetCookieDomain(url)
    path = GetCookiePath(url)
    For Each header In headerArray
        cookieString = header["Set-Cookie"]
        If Not IsNullOrEmpty(cookieString) Then
            data = Split(cookieString, ";")
            If data.Count() > 0 Then
                cookie = {
                    Name:       ""
                    Domain:     domain
                    Path:       path
                    Expires:    0
                }
                For i = 0 To data.Count() - 1
                    prop = data[i]
                    propData = []
                    propData[0] = prop.mid(0, prop.inStr("="))
                    propData[1] = prop.mid(prop.inStr("=") + 1)
                    If propData.Count() = 2 Then
                        propName = propData[0].Trim()
                        lCasePropName = LCase(propName)
                        propValue = propData[1].Trim()
                        If i = 0 Then
                            cookie.Name = propName
                            cookie.Value = propValue
                        Else If lCasePropName = "domain" Then
                            cookie.Domain = LCase(propValue)
                        Else If lCasePropName = "path" Then
                            cookie.Path = propValue
                        Else If lCasePropName = "expires" Then
                            cookie.Expires = GetCookieDate(propValue).AsSeconds()
                        Else If lCasePropName = "max-age" Then
                            cookie.Expires = NowDate().AsSeconds() + propValue.ToInt()
                        Else If lCasePropName = "httponly" Then
                        Else If lCasePropName = "secure" Then
                        Else
                        End If
                    End If
                Next
                If Not IsNullOrEmpty(cookie.Name) And Not IsNullOrEmpty(cookie.Domain) Then
                    cookies = container[cookie.Domain]
                    If cookies = invalid Then
                        cookies = []
                        container[cookie.Domain] = cookies
                    End If
                    found = False
                    For i = 0 To cookies.Count() - 1
                        If cookies[i].Name = cookie.Name Then
                            cookies[i] = cookie
                            found = True
                        End If
                    Next
                    If Not found Then
                        cookies.Push(cookie)
                    End If
                End If
            End If
        End If
    Next
End Sub

function parseCookies(cookieString as string) as object
    cookies = {}
    cookieStrings = cookieString.split(";")
    for each cookie in cookieStrings
        cookieParts = cookie.split("=")
        cookies[cookieParts[0].trim()] = cookieParts[1]
    next
    return cookies
end function
