'IMPORTS=utilities/arrays utilities/device utilities/strings utilities/web
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
Sub LaunchChannel(channelID As String, params = "" As String)
    url = "http://" + GetIPAddress() + ":8060/launch/" + channelID
    If Not IsNullOrEmpty(params) Then
        url = url + "?" + params
    End If
    PostUrlToString(url)
End Sub

Sub InstallChannel(channelID As String)
    url = "http://" + GetIPAddress() + ":8060/launch/11?contentID=" + channelID
    PostUrlToString(url)
End Sub

Function GetInstalledChannels(refresh = False As Boolean) As Object
    If m.InstalledChannels = invalid Or refresh Then
        m.InstalledChannels = []
        appsUrl = "http://" + GetIPAddress() + ":8060/query/apps"
        appsResponse = GetUrlToString(appsUrl)
        appsXml = CreateObject("roXmlElement")
        If appsXml.Parse(appsResponse) Then
            For Each app In appsXml.app
                channel = {
                    ID:             app@id
                    Version:        app@version
                    Title:          app.GetText()
                    HDPosterUrl:    "http://" + GetIPAddress() + ":8060/query/icon/" + app@id + "#" + Rnd(999999).ToStr()
                    SDPosterUrl:    "http://" + GetIPAddress() + ":8060/query/icon/" + app@id + "#" + Rnd(999999).ToStr()
                }
                m.InstalledChannels.Push(channel)
            Next
        End If
    End If
    Return m.InstalledChannels
End Function

Function IsChannelInstalled(channelID As String) As Boolean
    Return ArrayContains(GetInstalledChannels(), channelID, "ID")
End Function

Sub SendKey(key As String)
    url = "http://" + GetIPAddress() + ":8060/keypress/" + key
    PostUrlToString(url)
End Sub

Sub CheckForUpdates(background = False As Boolean)
    url = "http://" + GetIPAddress() + ":8060/syncchannels/" + IIf(background, "background", "foreground")
    PostUrlToString(url)
End Sub