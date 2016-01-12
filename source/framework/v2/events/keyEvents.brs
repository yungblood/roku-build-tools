'IMPORTS=utilities/types
' ******************************************************
' Copyright Steven Kean 2010-2015
' All Rights Reserved.
' ******************************************************
Function KeyMappings() As Object
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

Function KeyMappingsArray() As Object
    If m.KeyMappingsArray = invalid Then
        keys        = []
        mappings = KeyMappings()
        For Each key In mappings
            keys[mappings[key]] = key
        Next
        m.KeyMappingsArray = keys
    End If
    Return m.KeyMappingsArray
End Function

Function GetKeyMapping(keyCode As Integer) As String
    mapping = KeyMappingsArray()[keyCode]
    If mapping = invalid Then
        mapping = Chr(keyCode)
    End If
    Return mapping
End Function

Function NormalizeKeyEvent(event As Object) As Object
    keyEvent = {
        Event:      event
        IsKeyDown:  True
        IsLiteral:  False
        Key:        ""
        KeyIndex:   -1
    }
    If Type(event) = "roUniversalControlEvent" Then
        keyEvent.KeyIndex = event.GetInt()
        If keyEvent.KeyIndex < 100 Then
            m.LastKeyDown = keyEvent.KeyIndex
        Else If IsInteger(m.LastKeyDown) And m.LastKeyDown = keyEvent.KeyIndex - 100 Then 
            m.LastKeyDown = -1
            keyEvent.IsKeyDown = False
            keyEvent.KeyIndex = keyEvent.KeyIndex - 100
        Else
            m.LastKeyDown = keyEvent.KeyIndex
        End If
    Else If event.IsRemoteKeyPressed() Then
        m.LastKeyDown = -1
        keyEvent.KeyIndex = event.GetIndex()
    Else If event.IsButtonInfo() Or event.IsListItemInfo() Then
        m.LastKeyDown = -1
        keyEvent.KeyIndex = 10
    End If
    keyEvent.Key = GetKeyMapping(keyEvent.KeyIndex)
    ' TODO: Need to find a better way to do this
    keyEvent.IsLiteral = (keyEvent.Key.Len() = 1) Or keyEvent.KeyIndex = 11 Or keyEvent.KeyIndex = 15
    Return keyEvent
End Function