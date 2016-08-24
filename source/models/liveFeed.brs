Function NewLiveFeed(json = invalid As Object, sectionName = "" As String) As Object
    this                = NewStreamBase()
    this.ClassName      = "LiveFeed"
    
    this.ShowID         = ""
    this.Show           = invalid
    
    this.Initialize     = LiveFeed_Initialize
    
    this.Refresh        = LiveFeed_Refresh
    
    this.GetAkamaiDims  = LiveFeed_GetAkamaiDims
    this.GetConvivaName = LiveFeed_GetConvivaName
    
    this.SetShowID      = LiveFeed_SetShowID
    this.GetShow        = LiveFeed_GetShow
    
    this.GetVmapUrl     = LiveFeed_GetVmapUrl
    this.GetStreamUrl   = LiveFeed_GetStreamUrl
    this.GetStream      = LiveFeed_GetStream

    If json <> invalid Then
        this.Initialize(json, sectionName)
    End If
    
    Return this
End Function

Sub LiveFeed_Initialize(json As Object, sectionName = "" As String)
    m.Json = json
    
    m.ID                    = AsString(json.pid)
    m.ContentID             = AsString(json.contentId)
    m.MediaID               = AsString(json["__FOR_TRACKING_ONLY_MEDIA_ID"])
    m.Name                  = AsString(json.title)
    m.Title                 = m.Name
    m.ShortDescriptionLine1 = m.Name
    m.Description           = AsString(json.description)
    m.ShowID                = AsString(json.cbsShowId)
    m.ShowName              = AsString(json.seriesTitle)
    If IsNullOrEmpty(m.ShowName) Then
        show = m.GetShow()
        If show <> invalid Then
            m.ShowName = show.Title
        End If
    End If
    
    m.IsLive                = True
    
    m.SectionName           = sectionName
 
    m.TrackingTitle         = m.ShowName + " - " + m.SectionName + " - " + m.Name
    m.TrackingID            = m.MediaID
    m.TrackingAstID         = 595

    m.HDPosterUrl           = AddQueryString(AsString(json.thumbnail), "cachebuster", NowDate().AsSeconds().ToStr())
    m.SDPosterUrl           = AddQueryString(AsString(json.thumbnail), "cachebuster", NowDate().AsSeconds().ToStr())
'    m.HDPosterUrl           = Cbs().GetImageUrl(AsString(json.thumbnail), 266)
'    m.SDPosterUrl           = Cbs().GetImageUrl(AsString(json.thumbnail), 138)
'    For Each thumbnail In AsArray(json.thumbnailSet)
'        If thumbnail.width = 1920 And thumbnail.height = 1080 Then
'            m.HDPosterUrl   = Cbs().GetImageUrl(AsString(thumbnail.url), 266)
'            m.SDPosterUrl   = Cbs().GetImageUrl(AsString(thumbnail.url), 138)
'            Exit For
'        Else If thumbnail.width = 640 And thumbnail.height = 360 Then
'            m.HDPosterUrl   = Cbs().GetImageUrl(AsString(thumbnail.url), 266)
'            m.SDPosterUrl   = Cbs().GetImageUrl(AsString(thumbnail.url), 138)
'        End If
'    Next

End Sub

Function LiveFeed_Refresh() As Boolean
    ' For live feeds, we're only interested in updating the pid
    episode = Cbs().GetEpisode(m.ContentID)
    If episode <> invalid Then
        m.ID = episode.ID
        Return True
    End If
    Return False
End Function

Function LiveFeed_GetAkamaiDims(additionalDims = {} As Object) As Object
    dims = {
        category:   "Live"
        title:      m.TrackingTitle
    }
    If Not IsNullOrEmpty(m.ShowName) Then
        dims.show = m.ShowName
    End If
    
    dims.Append(additionalDims)
    Return dims
End Function

Function LiveFeed_GetConvivaName() As String
    Return IIf(IsNullOrEmpty(m.ShowName), "", m.ShowName + " - ") + m.Name
End Function

Sub LiveFeed_SetShowID(id As String)
    m.ShowID = id
End Sub

Function LiveFeed_GetShow() As Object
    If m.Show = invalid And Not IsNullOrEmpty(m.ShowID) Then
        m.Show = Cbs().GetShow(m.ShowID)
    End If
    Return m.Show
End Function

Function LiveFeed_GetVmapUrl() As String
    Return Replace(Cbs().VmapUrl, "[CONTENTID]", m.ContentID)
End Function

Function LiveFeed_GetStreamUrl() As String
    If Not IsNullOrEmpty(m.ID) Then
        Return Replace(Cbs().StreamUrl, "[PID]", m.ID)
    End If
    Return ""
End Function

' Resume param is ignored for live streams, but is necessary to prevent
' extra logic in the video player
Function LiveFeed_GetStream(resume = False As Boolean) As Object
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
            Live: m.IsLive
            PlayStart: NowDate().AsSeconds() + 999999
            'MinBandwidth: 800
            TrackIDSubtitle: "eia608/1"
            VmapUrl: m.GetVmapUrl()
        }
        Return stream
    End If
    Return invalid
End Function