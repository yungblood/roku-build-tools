Function NewSearchResult(json = invalid As Object) As Object
    this                = {}
    this.ClassName      = "SearchResult"
    
    this.Initialize     = SearchResult_Initialize
    
    this.GetShow        = SearchResult_GetShow
    this.IsShowLoaded   = SearchResult_IsShowLoaded
    
    If json <> invalid Then
        this.Initialize(json)
    End If
    
    Return this
End Function

Sub SearchResult_Initialize(json As Object)
    m.Json = json
    
    m.Title = AsString(json.show_title)
    m.ID = AsString(json.cbs_show_id)
    m.ResultType = "Show"
End Sub

Function SearchResult_GetShow() As Object
    If m.Show = invalid Then
        m.Show = Cbs().GetShow(m.ID)
    End If
    Return m.Show
End Function

Function SearchResult_IsShowLoaded() As Boolean
    If m.Show = invalid And Not Cbs().IsShowCached(m.ID) Then
        Return False
    End If
    Return True
End Function
