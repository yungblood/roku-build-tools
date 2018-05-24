'IMPORTS=utilities/web utilities/encryption
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
'=====================
' Device
'=====================
Function GetFirmware() As Object
    If m.Firmware = invalid Then
        deviceInfo = CreateObject("roDeviceInfo")
        firmware = deviceInfo.GetVersion()
        m.Firmware = {
            FullVersion: firmware
            Major: firmware.Mid(2, 1).ToInt()
            Minor: firmware.Mid(4, 2).ToInt()
            Build: firmware.Mid(7, 5).ToInt()
        }
    End If
    Return m.Firmware
End Function

Function GetModel() As String
    If m.Model = invalid Then
        deviceInfo = CreateObject("roDeviceInfo")
        m.Model = deviceInfo.GetModel()
    End If
    Return m.Model
End Function

Function GetDeviceID() As String
    If m.DeviceID = invalid Then
        deviceInfo = CreateObject("roDeviceInfo")
        m.DeviceID = deviceInfo.GetDeviceUniqueID()
    End If
    Return m.DeviceID
End Function

Function GetHashedDeviceID() As String
    If m.HashedDeviceID = invalid Then
        m.HashedDeviceID = MD5Hash(GetDeviceID())
    End If
    Return m.HashedDeviceID
End Function

Function GetPublisherID() As String
    If m.PublisherID = invalid Then
        If IsRokuOne() Then
            Return GetHashedDeviceID()
        Else
            deviceInfo = CreateObject("roDeviceInfo")
            m.PublisherID = deviceInfo.getClientTrackingID()
        End If
    End If
    Return m.PublisherID
End Function

Function GetAdvertisingID() As String
    If m.AdvertisingID = invalid Then
        If IsRokuOne() Then
            Return GetHashedDeviceID()
        Else
            deviceInfo = CreateObject("roDeviceInfo")
            m.AdvertisingID = deviceInfo.GetAdvertisingID()
        End If
    End If
    Return m.AdvertisingID
End Function

Function GetVerimatrixID() As String
    If m.VerimatrixID = invalid Then
        deviceInfo = CreateObject("roDeviceInfo")
        verimatrixID = "verimatrix-" + deviceInfo.getDeviceUniqueID()
        m.VerimatrixID = EVPDigest(verimatrixID, "sha1")
    End If
    Return m.VerimatrixID
End Function

Function GetIPAddress() As String
    If m.IPAddress = invalid Then
        deviceInfo = CreateObject("roDeviceInfo")
        ipAddresses = deviceInfo.GetIPAddrs()
        For Each eth in ipAddresses
            If Not IsNullOrEmpty(ipAddresses[eth]) Then
                m.EthernetInterface = eth
                m.IPAddress = ipAddresses[eth]
                Exit For
            End If
        Next
    End If
    Return m.IPAddress
End Function

Function GetEthernetInterface() As String
    GetIPAddress()
    Return m.EthernetInterface
End Function

Function GetExternalIPAddress() As String
    If m.PublicIPAddress = invalid Then
        If CheckFirmware(6) >= 0 Then
            deviceInfo = CreateObject("roDeviceInfo")
            m.PublicIPAddress = deviceInfo.GetExternalIP()
        Else
            m.PublicIPAddress = GetPublicIPAddress()
        End If
    End If
    Return m.PublicIPAddress
End Function

Function GetPublicIPAddress(ipLookupUrl = "http://roku.permanence.com/ip.aspx" As String) As String
    If m.PublicIPAddress = invalid Or IsNullOrEmpty(m.PublicIPAddress) Then
        m.PublicIPAddress = GetUrlToString(ipLookupUrl)
    End If
    Return m.PublicIPAddress
End Function

Function GetLinkStatus() As Boolean
    If CheckFirmware(5) >= 0 Then
        deviceInfo = CreateObject("roDeviceInfo")
        Return deviceInfo.GetLinkStatus()
    Else
        ' We can't test via roDeviceInfo, so attempt to retrieve
        ' google.com
        result = GetUrlToStringEx("http://www.google.com")
        Return (result.ResponseCode > 0)
    End If
End Function

Function GetDisplaySize() As Object
    If m.DisplaySize = invalid Then
        deviceInfo = CreateObject("roDeviceInfo")
        m.DisplaySize = deviceInfo.GetDisplaySize()
    End If
    Return m.DisplaySize
End Function

Function GetDisplayResolution() As String
    Return GetDisplaySize().w.ToStr() + "x" + GetDisplaySize().h.ToStr()
End Function

Function GetDisplayInfo() As Object
    If m.DisplayInfo = invalid Then
        deviceInfo = CreateObject("roDeviceInfo")
        m.DisplayInfo = {
            Size:       deviceInfo.GetDisplaySize().w.ToStr() + "x" + deviceInfo.GetDisplaySize().h.ToStr()
            Type:       deviceInfo.GetDisplayType()
            Mode:       deviceInfo.GetDisplayMode()
            Aspect:     deviceInfo.GetDisplayAspectRatio()
            VideoMode:  deviceInfo.GetDisplayMode()
        }
        If Not IsRokuOne() Then
            m.DisplayInfo.VideoMode = deviceInfo.GetVideoMode()
        End If
        If m.DisplayInfo.Type = "4:3 standard" Then
            m.DisplayInfo.Resolution = "720x480"
        Else If m.DisplayInfo.Type = "16:9 anamorphic" Then
            m.DisplayInfo.Resolution = "854x480"
        Else If m.DisplayInfo.VideoMode = "1080p" Then
            m.DisplayInfo.Resolution = "1920x1080"
        Else
            m.DisplayInfo.Resolution = m.DisplayInfo.Size
        End If
    End If
    Return m.DisplayInfo 
End Function

Function IsHD() As Boolean
    If m.DisplayIsHD = invalid Then
        deviceInfo = CreateObject("roDeviceInfo")
        m.DisplayIsHD = deviceInfo.GetDisplayType() = "HDTV"
    End If
    Return m.DisplayIsHD
End Function

Function IsSD() As Boolean
    If m.DisplayIsSD = invalid Then
        deviceInfo = CreateObject("roDeviceInfo")
        m.DisplayIsSD = deviceInfo.GetDisplayType() = "4:3 standard"
    End If
    Return m.DisplayIsSD
End Function

' Gets the locale for the player
Function GetCurrentLocale() As String
    ' Initialize the country variable
    If m.Locale = invalid Then
        m.Locale = invalid
        deviceInfo = CreateObject("roDeviceInfo")
        If Not IsRokuOne() Then
            m.Locale = deviceInfo.GetCurrentLocale()
        End If
        ' If the lookup failed, set the locale to US
        If m.Locale = invalid Then
           m.Locale = "en_US"
        End If
    End If
    Return m.Locale
End Function

' Gets the country code for the player
Function GetCountryCode() As String
    ' Initialize the country variable
    If m.CountryCode = invalid Then
        m.CountryCode = invalid
        deviceInfo = CreateObject("roDeviceInfo")
        If Not IsRokuOne() Then
            m.CountryCode = deviceInfo.GetCountryCode()
        End If
        ' If the lookup failed, set the country to US
        If m.CountryCode = invalid Then
           m.CountryCode = "US"
        End If
    End If
    Return m.CountryCode
End Function

Function GetTimeZone() As String
    If m.TimeZone = invalid Then
        m.TimeZone = invalid
        deviceInfo = CreateObject("roDeviceInfo")
        m.TimeZone = deviceInfo.GetTimeZone()
        ' If the lookup failed, set the country to US/Eastern
        If m.TimeZone = invalid Then
           m.TimeZone = "US/Eastern"
        End If
    End If
    Return m.TimeZone
End Function

Function GetCaptionsMode() as Dynamic
    If CheckFirmware(5, 3) >= 0 Then
        If m.CaptionsMode = invalid Then
            deviceInfo = CreateObject("roDeviceInfo")
            m.CaptionsMode = deviceInfo.GetCaptionsMode()
        End If
        Return m.CaptionsMode
    Else
        Return invalid
    End If
End Function

Function SetCaptionsMode(enabled As Boolean) as Dynamic
    m.CaptionsMode = IIf(enabled, "on", "off")
End Function

Function GetCreationTime() As Object
    If m.CreationTime = invalid Then
        If CheckFirmware(6, 1) >= 0 Then
            deviceInfo = CreateObject("roDeviceInfo")
            creationTime = deviceInfo.GetCreationTime()
            If Not IsNullOrEmpty(creationTime) Then
                m.CreationTime = DateFromISO8601String(creationTime)
            Else
                m.CreationTime = CreateObject("roDateTime")
            End If
        Else
            m.CreationTime = CreateObject("roDateTime")
        End If
    End If
    Return m.CreationTime
End Function

Function IsRokuOne() As Boolean
    Return CheckFirmware(4) < 0
End Function

Function IsRokuTwo() As Boolean
    Return GetModel().Mid(0, 1) = "3"
End Function

Function CheckFirmware(major As Integer, minor = -1 As Integer, build = -1 As Integer) As Integer
    firmware = GetFirmware()
    If firmware.Major > major Then
        Return 1
    Else If firmware.Major < major Then
        Return -1
    Else If minor <> -1 Then
        If firmware.Minor > minor Then
            Return 1
        Else If firmware.Minor < minor Then
            Return -1
        Else If build <> -1 Then
            If firmware.Build > build Then
                Return 1
            Else If firmware.Build < build Then
                Return -1
            End If
        End If
    End If
    Return 0
End Function

Function GetCpuType() As String
    If m.CpuType = invalid Then
        model = GetModel()
        If model.Mid(0, 1) = "3" Or model.Mid(0, 1) = "4" Then
            m.CpuType = "ARM"
        Else
            m.CpuType = "MIPS"
        End If
    End If
    Return m.CpuType
End Function

Function GetDeviceCreationTime() As Object
    deviceInfo = CreateObject("roDeviceInfo")
    creationTime = deviceInfo.GetCreationTime()
    If IsNullOrEmpty(creationTime) Then
        print "Creation time is empty"
        Return invalid
    End If
    dt = CreateObject("roDateTime")
    dt.FromISO8601String(creationTime)
    If dt.AsSeconds() <= 0 Then
        Return invalid
    End If
    print "Found valid creation time:"; dt.AsSeconds()
    Return dt
End Function
