'IMPORTS=utilities/general
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
'=====================
' Application
'=====================
Function GetManifest() As Object
    If m.Manifest = invalid Then
        m.Manifest = ParseIniFile("pkg:/manifest")
    End If
    Return m.Manifest
End Function

Function GetAppVersionEx() As Object
    If m.AppVersion = invalid Then
        ' Parse the manifest file for app version
        manifest = GetManifest()
        m.AppVersion = {
            FullVersion: manifest.major_version + "." + manifest.minor_version + "." + manifest.build_version
            Major: manifest.major_version
            Minor: manifest.minor_version
            Build: manifest.build_version
        }
    End If
    Return m.AppVersion
End Function

Function GetAppVersion() As String
    Return GetAppVersionEx().FullVersion
End Function

Function GetAppTitle() As String
    Return GetManifest().title
End Function