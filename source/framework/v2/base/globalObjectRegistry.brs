'IMPORTS=utilities/general utilities/strings
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
Function GlobalObjectRegistry() As Object
    If m.GlobalObjectRegistry = invalid Then
        this                    = {}
        this.Objects            = {}

        this.RegisterObject     = GlobalObjectRegistry_RegisterObject
        this.UnregisterObject   = GlobalObjectRegistry_UnregisterObject
        this.GetObject          = GlobalObjectRegistry_GetObject
        
        m.GlobalObjectRegistry = this
    End If
    Return m.GlobalObjectRegistry
End Function

Function GlobalObjectRegistry_RegisterObject(obj As Object) As String
    If IsNullOrEmpty(obj.GlobalObjectRegistryID) Then
        obj.GlobalObjectRegistryID = GenerateGuid()
    End If
    registeredObject = m.Objects[obj.GlobalObjectRegistryID]
    If registeredObject = invalid Then
        registeredObject = {
            Object:         obj
            ReferenceCount: 0
        }
    End If
    registeredObject.ReferenceCount = registeredObject.ReferenceCount + 1
    m.Objects[obj.GlobalObjectRegistryID] = registeredObject
    Return obj.GlobalObjectRegistryID
End Function

Sub GlobalObjectRegistry_UnregisterObject(obj As Object)
    If Not IsNullOrEmpty(obj.GlobalObjectRegistryID) Then
        registeredObject = m.Objects[obj.GlobalObjectRegistryID]
        If registeredObject <> invalid Then
            registeredObject.ReferenceCount = registeredObject.ReferenceCount - 1
            If registeredObject.ReferenceCount = 0 Then
                m.Objects.Delete(obj.GlobalObjectRegistryID)
                ' Remove the registry ID
                obj.Delete("GlobalObjectRegistryID")
            End If
        End If
    End If
End Sub

Function GlobalObjectRegistry_GetObject(id As String) As Object
    registeredObject = m.Objects[id]
    If registeredObject <> invalid Then
        Return registeredObject.Object
    End If
    Return invalid
End Function