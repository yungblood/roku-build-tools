'IMPORTS=
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
'=====================
' File System
'=====================
Function GetFileSystem() As Object
    If m.FileSystem = invalid Then
        m.FileSystem = CreateObject("roFileSystem")
    End If
    Return m.FileSystem
End Function

Function FileExists(path As String) As Boolean
    Return GetFileSystem().Exists(path)
End Function

Function FileStats(path As String) As Object
    stat = GetFileSystem().Stat(path)
    If stat = invalid Then
        stat = {
            Type:        "file"
            Permissions: "r"
            Size:        0
        }
    End If
    Return stat
End Function

Function FileDelete(path As String) As Boolean
    Return GetFileSystem().Delete(path)
End Function

Function FileCopy(path As String, destPath As String) As Boolean
    Return GetFileSystem().CopyFile(path, destPath)
End Function

Function FileRename(path As String, destPath As String) As Boolean
    Return GetFileSystem().Rename(path, destPath)
End Function
