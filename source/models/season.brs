Function NewSeason() As Object
    this                    = NewSection()
    this.ClassName          = "Season"
    
    this.Initialize         = Season_Initialize
    
    Return this
End Function

Sub Season_Initialize(show As Object, seasonNumber As Integer, sectionID As String)
    m.ID                    = AsString(seasonNumber)
    m.ShowID                = show.ID
    m.ShowTitle             = show.Title
    If AsInteger(seasonNumber) > 0 Then
        m.Title             = "Season " + AsString(seasonNumber) + " Episodes"
    Else
        m.Title             = "Full Episodes"
    End If
    m.SeasonNumber          = seasonNumber
    
    m.SetSectionID(sectionID, False)
    params = {}
    If m.SeasonNumber > 0 Then
        params["params"] = "seasonNum=" + m.SeasonNumber.ToStr()
        params["seasonNum"] = m.SeasonNumber
    End If
    m.SetParams(params)
End Sub