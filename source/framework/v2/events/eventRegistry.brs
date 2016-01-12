'IMPORTS=v2/base/observable
' ******************************************************
' Copyright Steven Kean 2010-2015
' All Rights Reserved.
' ******************************************************
Function GlobalEventRegistry() As Object
    If m.EventRegistry = invalid Then
        this            = NewObservable()
        
        this.ClassName  = "GlobalEventRegistry"
        
        m.EventRegistry = this
    End If
    Return m.EventRegistry
End Function
