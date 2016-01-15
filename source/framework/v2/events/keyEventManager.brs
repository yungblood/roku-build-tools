'IMPORTS=utilities/types
' ******************************************************
' Copyright Steven Kean 2010-2015
' All Rights Reserved.
' ******************************************************
Function KeyEventManager() As Object
    If m.KeyEventManager = invalid Then
        m.KeyEventManager = NewKeyEventManager()
    End If
    Return m.KeyEventManager
End Function

Function NewKeyEventManager() As Object
    this                        = {}
    this.ClassName              = "KeyEventManager"
    
    this.KeyDownIndex           = -1
    this.KeyDownTimer           = CreateObject("roTimespan")
    this.KeyRepeatTime          = 200
    this.KeyDownRepeatCount     = 0
    
    this.GetKeyMappings         = KeyEventManager_GetKeyMappings
    this.GetKeyMappingsArray    = KeyEventManager_GetKeyMappingsArray
    this.GetKeyMapping          = KeyEventManager_GetKeyMapping
    
    this.SetKeyDownRepeatTime   = KeyEventManager_SetKeyDownRepeatTime
    
    this.IsKeyDown              = KeyEventManager_IsKeyDown
    this.SetKeyDown             = KeyEventManager_SetKeyDown
    this.ResetKeyDown           = KeyEventManager_ResetKeyDown
    this.ProcessKeyEvent        = KeyEventManager_ProcessKeyEvent
    
    Return this
End Function

Function KeyEventManager_GetKeyMappings() As Object
    If m.KeyMappings = invalid Then
        keys = {}
        keys["BACK"]            = 0
        keys["UP"]              = 2
        keys["DOWN"]            = 3
        keys["LEFT"]            = 4
        keys["RIGHT"]           = 5
        keys["SELECT"]          = 6
        keys["INSTANTREPLAY"]   = 7
        keys["REWIND"]          = 8
        keys["FASTFORWARD"]     = 9
        keys["INFO"]            = 10
        keys["PLAY"]            = 13
        keys["ABUTTON"]         = 17
        keys["BBUTTON"]         = 18
        keys["VOLUMEUP"]        = 24
        keys["VOLUMEDOWN"]      = 25
        
        keys["BACKSPACE"]       = 11
        keys["ENTER"]           = 15

        m.KeyMappings = keys
    End If
    Return m.KeyMappings
End Function

Function KeyEventManager_GetKeyMappingsArray() As Object
    If m.KeyMappingsArray = invalid Then
        keys = []
        mappings = m.GetKeyMappings()
        For Each key In mappings
            keys[mappings[key]] = key
        Next
        m.KeyMappingsArray = keys
    End If
    Return m.KeyMappingsArray
End Function

Function KeyEventManager_GetKeyMapping(keyCode As Integer) As String
    mapping = m.GetKeyMappingsArray()[keyCode]
    If mapping = invalid Then
        mapping = Chr(keyCode)
    End If
    Return mapping
End Function

Sub KeyEventManager_SetKeyDownRepeatTime(time = 250 As Integer)
    m.KeyDownRepeatTime = time
End Sub

Function KeyEventManager_IsKeyDown() As Boolean
    Return m.KeyDownIndex <> -1
End Function

Sub KeyEventManager_SetKeyDown(keyIndex As Integer)
    If keyIndex <> m.KeyDownIndex Then
        m.ResetKeyDown()
        m.KeyDownIndex = KeyIndex
    End If
End Sub

Sub KeyEventManager_ResetKeyDown()
    m.KeyDownIndex = -1
    m.KeyDownRepeatCount = 0
    m.KeyDownTimer.Mark()
End Sub

Function KeyEventManager_ProcessKeyEvent(event As Object) As Object
    keyEvent = {
        Event:          event
        IsKeyDown:      True
        IsRepeat:       False
        RepeatCount:    0
        IsLiteral:      False
        Key:            ""
        KeyIndex:       -1
    }
    If event = invalid Then
        If m.KeyDownIndex <> -1 Then
            If m.KeyDownTimer.TotalMilliseconds() < m.KeyRepeatTime Then
                Return invalid
            End If
            m.KeyDownRepeatCount = m.KeyDownRepeatCount + 1
            m.KeyDownTimer.Mark()
            keyEvent.IsRepeat = True
            keyEvent.KeyIndex = m.KeyDownIndex
            keyEvent.RepeatCount = m.KeyDownRepeatCount
        Else
            Return invalid
        End If
    Else
        keyDownIndex = m.KeyDownIndex
        m.ResetKeyDown()
        If Type(event) = "roUniversalControlEvent" Then
            keyEvent.KeyIndex = event.GetInt()
            If keyEvent.KeyIndex < 100 Then
                m.SetKeyDown(keyEvent.KeyIndex)
            Else If keyDownIndex = keyEvent.KeyIndex - 100 Then 
                keyEvent.IsKeyDown = False
                keyEvent.KeyIndex = keyEvent.KeyIndex - 100
            Else
                m.SetKeyDown(keyEvent.KeyIndex)
            End If
        Else If event.IsRemoteKeyPressed() Then
            keyEvent.KeyIndex = event.GetIndex()
        Else If event.IsButtonInfo() Or event.IsListItemInfo() Then
            keyEvent.KeyIndex = 10
        End If
    End If
    keyEvent.Key = m.GetKeyMapping(keyEvent.KeyIndex)
    ' TODO: Need to find a better way to do this
    keyEvent.IsLiteral = (keyEvent.Key.Len() = 1) Or keyEvent.KeyIndex = 11 Or keyEvent.KeyIndex = 15
    Return keyEvent
End Function
