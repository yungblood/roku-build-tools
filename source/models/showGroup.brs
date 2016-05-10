Function NewShowGroup(json = invalid As Object) As Object
    this            = {}
    this.ClassName  = "ShowGroup"
    
    this.Initialize = ShowGroup_Initialize
    
    this.GetShows   = ShowGroup_GetShows

    If json <> invalid Then
        this.Initialize(json)
    End If
    
    Return this
End Function

Sub ShowGroup_Initialize(json As Object)
    m.Json = json
    
    m.ID = AsString(json.id)
    m.Name = AsString(json.title)
End Sub

Function ShowGroup_GetShows() As Object
    Return Cbs().GetGroupShows(m.ID)
End Function
