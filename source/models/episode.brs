Function NewEpisode(json = invalid As Object) As Object
    this                        = {}
    this.ClassName              = "Episode"
    
    this.Initialize             = Episode_Initialize
    
    this.UpdateDescription      = Episode_UpdateDescription
    
    this.Refresh                = Episode_Refresh
    
    this.IsFullEpisode          = Episode_IsFullEpisode
    this.IsClip                 = Episode_IsClip
    this.IsAvailable            = Episode_IsAvailable
    
    this.GetShow                = Episode_GetShow
    this.IsShowLoaded           = Episode_IsShowLoaded
    
    this.GetAkamaiDims          = Episode_GetAkamaiDims
    
    this.SetResumePoint         = Episode_SetResumePoint
    this.GetResumePoint         = Episode_GetResumePoint
    this.GetVmapUrl             = Episode_GetVmapUrl
    this.GetStreamUrl           = Episode_GetStreamUrl
    this.GetStream              = Episode_GetStream
    
    If json <> invalid Then
        this.Initialize(json)
    End If
    
    Return this
End Function

Sub Episode_Initialize(json As Object)
    m.ID                    = AsString(json.pid)
    m.ContentID             = AsString(json.contentId)
    m.MediaID               = AsString(json["__FOR_TRACKING_ONLY_MEDIA_ID"])
    m.SeasonNumber          = AsInteger(json.seasonNum)
    m.EpisodeNumber         = AsInteger(json.episodeNum)
    
    m.Description           = AsString(json.description)
    'If IsNullOrEmpty(m.Description) Then
    '    m.Description       = AsString(json.label)
    'End If
    
    m.Rating                = UCase(AsString(json.rating))
    m.Length                = AsInteger(json.duration)
    m.ShowID                = AsString(json.cbsShowId)
    m.ShowName              = AsString(json.seriesTitle)
    
    m.Status                = AsString(json.status)
    'm.Categories = [m.Status]
    m.SubscriptionLevel     = AsString(json.subscriptionLevel)
    
    m.TrackingTitle         = AsString(json.title)
    m.Title                 = AsString(json.label)
    m.TitleSeason           = AsString(json.seriesTitle)
    
    m.FullEpisode           = AsBoolean(json.fullEpisode, True)
    m.TopLevelCategory      = AsString(json.topLevelCategory)
    
    m.AirDate               = DateFromISO8601String(AsString(json["_airDateISO"]))
    m.ReleaseDate           = m.AirDate.AsDateString("short-month-no-weekday")
    m.SubtitleUrl           = AsString(json.closedCaptionUrl)

    m.HDPosterUrl           = Cbs().GetImageUrl(AsString(json.thumbnail), 266)
    m.SDPosterUrl           = Cbs().GetImageUrl(AsString(json.thumbnail), 138)
    For Each thumbnail In AsArray(json.thumbnailSet)
        If thumbnail.width = 1920 And thumbnail.height = 1080 Then
            m.HDPosterUrl   = Cbs().GetImageUrl(AsString(thumbnail.url), 266)
            m.SDPosterUrl   = Cbs().GetImageUrl(AsString(thumbnail.url), 138)
            Exit For
        Else If thumbnail.width = 640 And thumbnail.height = 360 Then
            m.HDPosterUrl   = Cbs().GetImageUrl(AsString(thumbnail.url), 266)
            m.SDPosterUrl   = Cbs().GetImageUrl(AsString(thumbnail.url), 138)
        End If
    Next
    
    If json.thumbnailSheetSet <> invalid Then
        For Each set In AsArray(json.thumbnailSheetSet)
            If IsAssociativeArray(set) Then
                If AsInteger(set.width) = 320 Then
                    m.HDBifUrl = AsString(set.url)
                Else If AsInteger(set.width) = 240 Then
                    m.SDBifUrl = AsString(set.url)
                End If
            End If
        Next
    End If

    m.HomeDescriptionLine1 = m.ShowName
    m.HomeDescriptionLine2 = m.Title
    m.ShowDescriptionLine1 = m.ShowName
    m.ShowDescriptionLine2 = m.Title
    
    If m.FullEpisode Then
        ' We can't use roDateTime.AsDateString("short-date") here, because it truncates 2000-2009 down to a single digit
        m.HomeDescriptionLine2 = AsString(m.AirDate.GetMonth()) + "/" + AsString(m.AirDate.GetDayOfMonth()) + "/" + AsString(m.AirDate.GetYear()).Mid(2)
        If m.SeasonNumber > 0 And m.EpisodeNumber > 0 Then
            m.HomeDescriptionLine2 = Substitute("S{0} Ep{1}", AsString(m.SeasonNumber), AsString(m.EpisodeNumber)) + " " + m.HomeDescriptionLine2
        End If
        m.ShowDescriptionLine1 = m.Title
        m.ShowDescriptionLine2 = m.HomeDescriptionLine2
    Else
        m.ShowDescriptionLine1 = m.Title
        m.ShowDescriptionLine2 = invalid
    End If
End Sub

Sub Episode_UpdateDescription(screen As String)
    m.ShortDescriptionLine1 = m[screen + "DescriptionLine1"]
    m.ShortDescriptionLine2 = m[screen + "DescriptionLine2"]
End Sub

Sub Episode_Refresh()
    episode = Cbs().GetEpisode(m.ContentID)
    If episode <> invalid Then
        m.Append(episode)
    End If
End Sub

Function Episode_IsFullEpisode() As Boolean
    Return m.FullEpisode
End Function

Function Episode_IsClip() As Boolean
    Return Not m.FullEpisode
End Function

Function Episode_IsAvailable() As Boolean
    Return (m.Status = "AVAILABLE" Or m.Status = "DELAYED" Or m.Status = "PREMIUM")
End Function

Function Episode_GetShow() As Object
    If m.Show = invalid Then
        m.Show = Cbs().GetShow(m.ShowID)
    End If
    Return m.Show
End Function

Function Episode_IsShowLoaded() As Boolean
    If m.Show = invalid And Not Cbs().IsShowCached(m.ShowID) Then
        Return False
    End If
    Return True
End Function

Function Episode_GetAkamaiDims(additionalDims = {} As Object) As Object
    dims = {
        show: m.ShowName
        category: m.TopLevelCategory
        title: m.TrackingTitle
    }
    dims.Append(additionalDims)
    Return dims
End Function

Sub Episode_SetResumePoint(position As Integer)
    Cbs().SetResumePoint(m.ContentID, position)
End Sub

Function Episode_GetResumePoint() As Integer
    Return Cbs().GetResumePoint(m.ContentID)
End Function

Function Episode_GetVmapUrl() As String
    Return Replace(Cbs().VmapUrl, "[CONTENTID]", m.ContentID)
End Function

Function Episode_GetStreamUrl() As String
    If Not IsNullOrEmpty(m.ID) Then
        Return Replace(Cbs().StreamUrl, "[PID]", m.ID)
    End If
    Return ""
End Function

Function Episode_GetStream(resume = False As Boolean) As Object
    streamUrl = m.GetStreamUrl()
    If Not IsNullOrEmpty(streamUrl) Then
        stream = {
            ContentID: m.ID
            Title: m.Title
            TitleSeason: m.ShowName
            StreamFormat: "hls"
            Stream: {
                Bitrate: 0
                Url: m.GetStreamUrl()
            }
            SwitchingStrategy: "full-adaptation"
            'MinBandwidth: 800
            VmapUrl: m.GetVmapUrl()
            SubtitleUrl: m.SubtitleUrl
            SDBifUrl: m.SDBifUrl
            HDBifUrl: m.HDBifUrl
        }
        If m.SeasonNumber > 0 And m.EpisodeNumber > 0 Then
            stream.Title = Substitute("S{0} Ep{1}", AsString(m.SeasonNumber), AsString(m.EpisodeNumber)) + " | " + stream.Title
        End If
        If resume Then
            stream.PlayStart = m.GetResumePoint()
        End If
        Return stream
    End If
    Return invalid
End Function
