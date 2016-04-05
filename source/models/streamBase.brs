Function NewStreamBase(json = invalid As Object) As Object
    this                        = {}
    this.ClassName              = "StreamBase"

    this.IsFullEpsiode          = Function() As Boolean : Return True  : End Function
    this.IsClip                 = Function() As Boolean : Return False : End Function
    this.IsAvailable            = Function() As Boolean : Return True  : End Function
    this.CanWatch               = Function() As Boolean : Return True  : End Function

    this.IsFullyWatched         = Function() As Boolean : Return False : End Function

    this.GetVmapUrl             = Function() As String  : Return ""    : End Function
    
    this.GetConvivaName         = Function() As String  : Return ""    : End Function
    
    Return this
End Function