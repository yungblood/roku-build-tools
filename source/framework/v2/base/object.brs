'IMPORTS=
' ******************************************************
' Copyright Steven Kean 2010-2015
' All Rights Reserved.
' ******************************************************
Function NewObject() As Object
    this            = {}
    this.ClassName = "Object"
    
    this.Get        = Object_Get
    this.Set        = Object_Set
    
    Return this
End Function

Function Object_Get(property As String, defaultValue = invalid As Dynamic) As Dynamic
    If m[property] = invalid Then
        Return defaultValue
    End If
    Return ConvertToTypeByValue(m[property], defaultValue)
End Function

Sub Object_Set(property As String, value As Dynamic)
    m[property] = value
End Sub
