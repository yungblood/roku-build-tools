Function NewScheduleItem(json = invalid As Object) As Object
    this                = {}
    this.ClassName      = "ScheduleItem"
    
    this.Initialize     = ScheduleItem_Initialize

    If json <> invalid Then
        this.Initialize(json)
    End If
    
    Return this
End Function

Sub ScheduleItem_Initialize(json As Object)
    m.Json = json
    
    m.ID = AsString(json.programId)
    m.EpisodeTitle = AsString(json.episodeTitle)
    m.ShowName = AsString(json.name)
    m.Description = AsString(json.description)
    m.Length = AsInteger(json.duration)
    m.StartTime = DateFromSeconds(AsInteger(json.startTime))
    m.StartTime.ToLocalTime()
    m.EndTime = DateFromSeconds(AsInteger(json.startTime) + m.Length)
    m.EndTime.ToLocalTime()
    
    If Not IsNullOrEmpty(m.ShowName) Then
        m.Title = m.ShowName
    End If
    If Not IsNullOrEmpty(m.EpisodeTitle) Then
        If Not IsNullOrEmpty(m.Title) Then
            m.Title = m.Title + ": "
        End If
        m.Title = m.Title + m.EpisodeTitle
    End If
End Sub
