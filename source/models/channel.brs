Function NewChannel(json = invalid As Object) As Object
    this                = NewStreamBase()
    this.ClassName      = "Channel"
    
    this.Initialize     = Channel_Initialize
    
    this.GetAkamaiDims  = Channel_GetAkamaiDims
    this.GetConvivaName = Channel_GetConvivaName
    
    this.GetNowPlaying  = Channel_GetNowPlaying
    this.GetSchedule    = Channel_GetSchedule
    this.GetStream      = Channel_GetStream

    If json <> invalid Then
        this.Initialize(json)
    End If
    
    Return this
End Function

Sub Channel_Initialize(json As Object)
    m.Json = json
    
    m.ID = AsString(json.stationId)
    m.ParentID = AsString(json.parentStationId)
    m.MediaID = AsString(json.mediaId)
    m.Name = AsString(json.name)
    m.Description = AsString(json.description)
    m.Token = AsString(json.token)
    
    m.TrackingTitle = m.Name + "-liveTV"
    m.TrackingID = 2344
    m.TrackingAstID = 600
    
    m.ContentID = m.TrackingTitle
    m.Title = m.Name
    m.FullName = m.Name
    m.ShortDescriptionLine1 = m.Name
    If Not IsNullOrEmpty(m.Description) Then
        If Not IsNullOrEmpty(m.FullName) Then
            m.FullName = m.FullName + " - "
        End If
        m.FullName = m.FullName + m.Description
        If Not IsNullOrEmpty(m.ShortDescriptionLine1) Then
            m.ShortDescriptionLine1 = m.ShortDescriptionLine1 + Chr(10)
        End If
        m.ShortDescriptionLine1 = m.ShortDescriptionLine1 + m.Description
    End If
    
    m.HDPosterUrl = "pkg:/images/icon_livetv_hd.png"
    m.SDPosterUrl = "pkg:/images/icon_livetv_sd.png"
    
    affiliate = Cbs().GetAffiliate(m.Name)
    If affiliate <> invalid Then
        m.HDPosterUrl = affiliate.HDPosterUrl
        m.SDPosterUrl = affiliate.SDPosterUrl
        
        m.Title = affiliate.Station
        m.FullName = affiliate.Station
        m.ShortDescriptionLine1 = affiliate.Station
        If Not IsNullOrEmpty(affiliate.Name) Then
            If Not IsNullOrEmpty(m.FullName) Then
                m.FullName = m.FullName + " - "
            End If
            m.FullName = m.FullName + affiliate.Name
            If Not IsNullOrEmpty(m.ShortDescriptionLine1) Then
                m.ShortDescriptionLine1 = m.ShortDescriptionLine1 + Chr(10)
            End If
            m.ShortDescriptionLine1 = m.ShortDescriptionLine1 + affiliate.Name
        End If
    End If
End Sub

Function Channel_GetAkamaiDims(additionalDims = {} As Object) As Object
    dims = {
        category:   "Live"
        title:      m.TrackingTitle
    }
    dims.Append(additionalDims)
    Return dims
End Function

Function Channel_GetConvivaName() As Object
    Return m.TrackingTitle
End Function

Function Channel_GetNowPlaying() As Object
    If m.NowPlaying = invalid Or m.NowPlaying.StartTime.AsSeconds() > LocalNowDate().AsSeconds() Or m.NowPlaying.EndTime.AsSeconds() < LocalNowDate().AsSeconds() Then
        m.NowPlaying = m.GetSchedule(NowDate(), 1)[0]
    End If
    Return m.NowPlaying
End Function

Function Channel_GetSchedule(startTime = NowDate() As Object, count = 10 As Integer) As Object
    Return Syncbak().GetSchedule(m.ID, startTime, count)
End Function

' Resume param is ignored for live streams, but is necessary to prevent
' extra logic in the video player
Function Channel_GetStream(resume = False As Boolean) As Object
    streamUrl = Syncbak().GetStream(m.ID, m.MediaID, 1)  ' TypeID 1 = HLS
    If Not IsNullOrEmpty(streamUrl) Then
        Return {
            Title: m.FullName
            StreamFormat: "hls"
            SwitchingStrategy: "full-adaptation"
            Live: True
            PlayStart: NowDate().AsSeconds() + 999999
            TrackIDSubtitle: "eia608/1"
            'MinBandwidth: 800
            Stream: {
                Url: streamUrl
                Bitrate: 0
            }
        }
    End If
    Return invalid
End Function