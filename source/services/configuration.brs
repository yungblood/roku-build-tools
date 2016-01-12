Function Configuration() As Object
    If m.Configuration = invalid Then
        this = {}
        
        this.RegistrySection    = "CBSAllAccess"
        
        this.DefaultPageSize    = 50
        
        this.UseStaging         = (LCase(AsString(GetManifest().use_staging)) = "true")

        this.Get                = Configuration_Get
        this.Set                = Configuration_Set
        this.Remove             = Configuration_Remove
        
        m.Configuration = this
    End If
    Return m.Configuration
End Function

Function Configuration_Get(property As String, defaultValue = invalid As Dynamic, refresh = False As Boolean) As Dynamic
    If refresh Or Not m.DoesExist(property) Then
        value = GetRegistryValue(property, invalid, m.RegistrySection)
        If value <> invalid Then
            m[property] = ConvertToTypeByValue(value, defaultValue)
        End If
    End If
    If m[property] = invalid Then
        Return defaultValue
    End If
    Return m[property]
End Function

Sub Configuration_Set(property As String, value As Dynamic, storeInRegistry = True As Boolean)
    m[property] = value
    If storeInRegistry Then
        SetRegistryValue(property, AsString(value), m.RegistrySection)
    End If
End Sub

Sub Configuration_Remove(property As String)
    m.Delete(property)
    DeleteRegistryValue(property, m.RegistrySection)
End Sub

