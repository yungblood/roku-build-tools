Function NewSection(json = invalid As Object) As Object
    this                    = {}
    this.ClassName          = "Section"
    
    this.SectionID          = invalid
    this.Params             = {}
    this.TotalCount         = -1
    this.PageSize           = 10
    this.ExcludeShow        = True
    this.LastRequestedIndex = -1

    this.Videos             = []
    
    this.Initialize         = Section_Initialize
    this.SetSectionID       = Section_SetSectionID
    this.SetParams          = Section_SetParams
    this.SetTotalCount      = Section_SetTotalCount
    
    this.IsVideoLoaded      = Section_IsVideoLoaded
    
    this.GetVideo           = Section_GetVideo
    this.GetVideos          = Section_GetVideos
    this.LoadVideos         = Section_LoadVideos
    
    If json <> invalid Then
        this.Initialize(json)
    End If
    
    Return this
End Function

Sub Section_Initialize(json As Object)
    m.SectionID = AsString(json.id)
    m.Name      = AsString(json.sectionTitle)
    If IsAssociativeArray(json.sectionItems) Then
        For Each item In AsArray(json.sectionItems.itemList)
            episode = NewEpisode(item)
            If episode.IsAvailable() Then
                m.Videos.Push(episode)
            End If
        Next
        m.LoadVideos()
        itemCount = AsInteger(json.sectionItems.itemCount)
        If itemCount > 0 Then
            m.SetTotalCount(itemCount)
        End If
    End If
End Sub

Sub Section_SetSectionID(sectionID As String, excludeShow = True As Boolean)
    m.SectionID = sectionID
    m.ExcludeShow = excludeShow
End Sub

Sub Section_SetParams(params As Object)
    m.Params = params
End Sub

Sub Section_SetTotalCount(count As Integer)
    m.TotalCount = count
    If m.Videos.Count() > count Then
        For i = 1 To m.Videos.Count() - count
            m.Videos.Pop()
        Next
    End If
    If m.Videos.Count() < count Then
        m.Videos[count - 1] = invalid
    End If
End Sub

Function Section_IsVideoLoaded(index As Integer) As Boolean
    Return (m.Videos[index] <> invalid)
End Function

Function Section_GetVideo(index As Integer, saveAsLastRequested = True As Boolean) As Object
    If m.TotalCount = -1 Or index < m.TotalCount Then
        If m.Videos[index] = invalid Then
            page = Int(index / m.PageSize) + 1
            startIndex = (page - 1) * m.PageSize
            m.LoadVideos(startIndex, m.PageSize)
        End If
        If saveAsLastRequested Then
            m.LastRequestedIndex = index
        End If
        Return m.Videos[index]
    End If
    Return invalid
End Function

Function Section_GetVideos() As Object
    ' Return a copy, so the array cannot be directly modified
    Return ShallowCopy(m.Videos)
End Function

Sub Section_LoadVideos(startIndex = 0 As Integer, count = 10 As Integer)
    loadNewPage = False
    For i = startIndex To startIndex + count - 1
        If m.Videos[i] = invalid Then
            loadNewPage = True
            Exit For
        End If
    Next
    If loadNewPage Then
        ' We haven't loaded this page, yet, so load it now
        page = Int(startIndex / count) + 1
        startIndex = (page - 1) * count
        pageInfo = {}
        items = Cbs().GetSectionVideos(m.SectionID, m.ExcludeShow, m.Params, startIndex, count, pageInfo)
        If m.TotalCount = -1 Then
            m.SetTotalCount(pageInfo.TotalCount)
        End If
        For i = 0 To items.Count() - 1
            index = startIndex + i
            If m.TotalCount > -1 And index >= m.TotalCount Then
                Exit For
            End If
            m.Videos[startIndex + i] = items[i]
        Next
    End If
    
    ' HACK: Capture the next clips for autoplay functionality
    lastClip = invalid
    For Each video In m.Videos
        If video <> invalid And video.IsClip() Then
            If lastClip <> invalid Then
                lastClip.NextClip = video
            End If
            lastClip = video
        End If
    Next
End Sub