'IMPORTS=utilities/arrays
' ******************************************************
' Copyright Steven Kean 2010-2015
' All Rights Reserved.
' ******************************************************
Function ScreenManager() As Object
    If m.ScreenManager = invalid Then
        this                    = NewObservable()
        this.ClassName          = "ScreenManager"
        
        this.Screens            = []
        
        this.AddScreen          = ScreenManager_AddScreen
        this.RemoveScreen       = ScreenManager_RemoveScreen
        this.PeekScreen         = ScreenManager_PeekScreen
        
        this.NotifyZOrderChange = ScreenManager_NotifyZOrderChange
        this.CloseAll           = ScreenManager_CloseAll
        
        m.ScreenManager = this
    End If
    Return m.ScreenManager     
End Function

Function ScreenManager_AddScreen(screen As Object) As Object
    If Not IsAssociativeArray(screen) Then
        screen = {
            Screen:     screen
        }
    End If
    If screen.ScreenID = invalid Then
        screen.ScreenID = GenerateGuid()
    End If
    If Not ArrayContains(m.Screens, screen.ScreenID, "ScreenID") Then
        m.Screens.Push(screen)
        m.RaiseEvent("ScreenAdded", { Screen: screen, Index: m.Screens.Count() - 1 })
        m.NotifyZOrderChange(False)
        m.NotifyZOrderChange(True)
    End If
    Return screen
End Function

Function ScreenManager_RemoveScreen(screen As Object) As Boolean
?"Screen count:";m.Screens.Count()
    If IsAssociativeArray(screen) And Not IsNullOrEmpty(screen.ScreenID) Then
        index = FindElementIndexInArray(m.Screens, screen.ScreenID, "ScreenID")
        If index > -1 Then
            m.Screens.Delete(index)
            m.RaiseEvent("ScreenRemoved", { Screen: screen, Index: index, TopMost: index = m.Screens.Count() })
            If index = m.Screens.Count() Then
                m.NotifyZOrderChange(True)
            End If
            Return True
        End If
    End If
    Return False
End Function

Function ScreenManager_PeekScreen() As Object
    Return m.Screens.Peek()
End Function

Sub ScreenManager_NotifyZOrderChange(topMost As Boolean)
    screen = invalid
    If topMost Then
        screen = m.Screens.Peek()
    Else
        screen = m.Screens[m.Screens.Count() - 2]
    End If
    If screen <> invalid And IsFunction(screen.OnZOrderChange) Then
        screen.OnZOrderChange(topMost)
    End If
End Sub

Sub ScreenManager_CloseAll()
    For i = m.Screens.Count() - 1 To 0 Step -1
        screen = m.Screens[i]
        If IsFunction(screen.Close) Then
            screen.Close()
        End If
    Next
    m.Screens.Clear()
End Sub
