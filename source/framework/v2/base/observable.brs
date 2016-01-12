'IMPORTS=v2/base/callbackInfo v2/base/globalObjectRegistry utilities/arrays
' ******************************************************
' Copyright Steven Kean 2010-2015
' All Rights Reserved.
' ******************************************************
Function NewObservable() As Object
    this                                = {}

    this.Observers                      = {}
    
    this.HasObservers                   = Observable_HasObservers
    this.GetObservers                   = Observable_GetObservers
    
    this.RegisterObserver               = Observable_RegisterObserver
    this.UnregisterObserver             = Observable_UnregisterObserver
    this.UnregisterObserverForAllEvents = Observable_UnregisterObserverForAllEvents

    this.RaiseEvent                     = Observable_RaiseEvent
    
    Return this
End Function

Function Observable_HasObservers() As Boolean
    Return Not m.Observers.IsEmpty()
End Function

Function Observable_GetObservers(event As String) As Object
    If Not m.Observers.DoesExist(event) Then
        m.Observers[event] = []
    End If
    Return m.Observers[event]
End Function

Sub Observable_RegisterObserver(observer As Object, event As String, callback As String, callbackData = invalid As Object, allowEventToBubble = True As Boolean)
    If IsNullOrEmpty(observer.ObserverID) Then
        If IsNullOrEmpty(observer.GlobalObjectRegistryID) Then
            observer.ObserverID = GenerateGuid()
        Else
            observer.ObserverID = observer.GlobalObjectRegistryID
        End If
    End If
    callbackInfo = NewCallbackInfo(observer, callback, callback, callbackData)
    callbackInfo.AllowBubble = allowEventToBubble
    observers = m.GetObservers(event)
    If Not ArrayContains(observers, callbackInfo.ID, "ID") Then
        observers.Push(callbackInfo)
    End If
End Sub

Sub Observable_UnregisterObserver(observer As Object, event As String)
    observers = m.GetObservers(event)
    index = FindElementIndexInArray(observers, observer.ObserverID, "ID")
    If index > -1 Then
        callbackInfo = observers[index]
        callbackInfo.Dispose()
        observers.Delete(index)
    End If
End Sub

Sub Observable_UnregisterObserverForAllEvents(observer As Object)
    For Each eventKey In m.Observers
        m.UnregisterObserver(observer, eventKey)
    Next
End Sub

Function Observable_RaiseEvent(event As String, eventData = {} As Object) As Dynamic
    If event <> "Idle" And event <> "ScreenRefresh" And event <> "GetMessage" Then
        DebugPrint(event, "Observable.RaiseEvent", 3)
    End If
    If eventData = invalid Then
        eventData = {}
    End If
    If eventData.Sender = invalid Then
        eventData.Sender = m
    End If
    If eventData.EventType = invalid Then
        eventData.EventType = event
    End If
    
    result = invalid
    observers = m.GetObservers(event)
    ' This is the first pass, so set the bubbled flag to false
    eventData.EventBubbled = False
    If observers <> invalid Then
        For i = observers.Count() - 1 To 0 Step -1
            callbackInfo = observers[i]
            If callbackInfo <> invalid Then
                eventData.AllowBubble = callbackInfo.AllowBubble
                result = callbackInfo.Callback(eventData)
                If eventData.AllowBubble = False Then
                    ' Event has been handled by an observer that disallows bubbling,
                    ' so stop raising the events
                    Exit For
                Else
                    ' The event is bubbling, so set the flag to true
                    eventData.EventBubbled = True
                End If
            End If
        Next
    End If
    Return result
End Function
