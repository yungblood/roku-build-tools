Function NewLiveFeed(json = invalid As Object) As Object
    this                = NewStreamBase()
    this.ClassName      = "LiveFeed"
    
    this.ShowID         = ""
    this.Show           = invalid
    
    this.Initialize     = LiveFeed_Initialize
    
    this.GetAkamaiDims  = LiveFeed_GetAkamaiDims
    this.GetConvivaName = LiveFeed_GetConvivaName
    
    this.SetShowID      = LiveFeed_SetShowID
    this.GetShow        = LiveFeed_GetShow
    
    this.GetVmapUrl     = LiveFeed_GetVmapUrl
    this.GetStream      = LiveFeed_GetStream

    If json <> invalid Then
        this.Initialize(json)
    End If
    
    Return this
End Function

Sub LiveFeed_Initialize(json As Object)
    m.ID = AsString(json.streamId)
    m.ContentID = AsString(json.streamId)
    m.Channel = AsString(json.channel)
    m.MediaID = AsString(json.streamId)
    m.Name = AsString(json.title)
    m.Description = AsString(json.description_full)

    m.TrackingTitle = AsString(json.medtitle)
    m.TrackingID = AsInteger(json.medid)
    m.TrackingAstID = AsInteger(json.medastid)

    m.Title = m.Name
    m.ShortDescriptionLine1 = m.Name
    
    m.HDPosterUrl = AsString(json.carousel_hd)
    m.SDPosterUrl = AsString(json.carousel_sd)

    m.StreamUrl = AsString(json.hls)

    show = m.GetShow()
    If show <> invalid Then
        m.ShowName = show.Title
    End If
End Sub

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
    Return "[" + m.ContentId + "] " + IIf(IsNullOrEmpty(m.ShowName), "", m.ShowName + " - ") + m.TrackingTitle
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
    Return "" 'Replace(Cbs().VmapUrl, "[CONTENTID]", "px0OafYrFi0JafVspX1dO4FHeC_H9Aaw")
End Function

' Resume param is ignored for live streams, but is necessary to prevent
' extra logic in the video player
Function LiveFeed_GetStream(resume = False As Boolean) As Object
    token = Cbs().GetBigBrotherStreamToken(m.ID)
    'If Not IsNullOrEmpty(token) Then
        Return {
            TitleSeason: m.Title
            StreamFormat: "hls"
            SwitchingStrategy: "full-adaptation"
            Live: True
            PlayStart: NowDate().AsSeconds() + 999999
            VmapUrl: m.GetVmapUrl()
            TrackIDSubtitle: "eia608/1"
            'MinBandwidth: 800
            Stream: {
                ' The token is already URL encoded, so don't encode it when appending to the URL
                Url: AddQueryString(m.StreamUrl, "hdnea", token, True, False)
                Bitrate: 0
            }
        }
    'End If
    Return invalid
End Function