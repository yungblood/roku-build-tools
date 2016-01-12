Function PlayTimes() As Object
    If m.PlayTimes = invalid Then
        m.PlayTimes = NewPlayTimes()
    End If
    Return m.PlayTimes
End Function

Function NewPlayTimes() As Object
    this                = {}
    this.ClassName      = "PlayTimes"
    
    this.PlayTimes      = {}
    
    this.SetPlayTime    = PlayTimes_SetPlayTime
    this.GetPlayTime    = PlayTimes_GetPlayTime
    
    Return this
End Function

Sub PlayTimes_SetPlayTime(id As String, time = NowDate().AsSeconds() As Integer)
    m.PlayTimes[id] = time
End Sub

Function PlayTimes_GetPlayTime(id As String) As Integer
    Return AsInteger(m.PlayTimes[id])
End Function