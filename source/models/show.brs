Function NewShow(json = invalid As Object) As Object
    this                        = {}
    this.ClassName              = "Show"
    
    this.Initialize             = Show_Initialize
    
    this.ID                     = ""
    this.EpisodeCount           = 0
    this.ClipCount              = 0
    this.OverhangHD             = ""
    this.OverhangSD             = ""
    
    this.GetSectionIDs          = Show_GetSectionIDs
    this.GetSectionID           = Show_GetSectionID
    
    this.GetRows                = Show_GetRows

    this.GetMostRecentEpisode   = Show_GetMostRecentEpisode
    
    If json <> invalid Then
        this.Initialize(json)
    End If
    
    Return this
End Function

Sub Show_Initialize(json As Object)
    If IsAssociativeArray(json.show) Then
        If AsArray(json.show.results).Count() > 0 Then
            ' This is a show response
            showJson = AsArray(json.show.results)[0]
            If showJson <> invalid Then
                m.ID = AsString(showJson.show_id)
                m.Title = AsString(showJson.title)
                m.SeasonCount = AsInteger(showJson.season)
    
                m.ShortDescriptionLine1 = m.Title
                m.HDPosterUrl = Cbs().GetImageUrl(AsString(showJson.show_thumbnail), 266)
                m.SDPosterUrl = Cbs().GetImageUrl(AsString(showJson.show_thumbnail), 138)
            End If
            If IsAssociativeArray(json.showAssets) Then
                showAssets = json.showAssets.results
                If showAssets <> invalid Then
                    m.OverhangHD    = Cbs().GetImageUrl(AsString(showAssets.filepath_ott_hd_show_image_overhang), 514)
                    m.OverhangSD    = Cbs().GetImageUrl(AsString(showAssets.filepath_ott_sd_show_image_overhang), 262)
                    m.HDPosterUrl   = Cbs().GetImageUrl(AsString(showAssets.filepath_ott_hd_show_logo), 266)
                    m.SDPosterUrl   = Cbs().GetImageUrl(AsString(showAssets.filepath_ott_sd_show_logo), 138)
                End If
            End If
        End If
    Else
        ' This is an inline response
        m.ID = AsString(json.showId)
    
        If json.showDto <> invalid Then
            m.Title = AsString(json.showDto.title)
        End If
        If IsNullOrEmpty(m.Title) Then
            m.Title = AsString(json.title)
        End If
        
        If json.episodeVideoCount <> invalid Then
            m.ClipCount = AsInteger(json.episodeVideoCount.totalClips)
            m.EpisodeCount = AsInteger(json.episodeVideoCount.totalEpisodes)
            If m.EpisodeCount > 0 Then
                m.ShortDescriptionLine1 = AsString(m.EpisodeCount) + " Episode" + IIf(m.EpisodeCount > 1, "s", "")
            End If
            If m.EpisodeCount = 0 And m.ClipCount > 0 Then
                m.ShortDescriptionLine1 = AsString(m.ClipCount) + " Clip" + IIf(m.ClipCount > 1, "s", "")
            End If
        End If
        
        m.Category = AsString(json.category)

        If IsAssociativeArray(json.showAssets) Then
            m.OverhangHD    = Cbs().GetImageUrl(AsString(json.showAssets.filepath_ott_hd_show_image_overhang), 514)
            m.OverhangSD    = Cbs().GetImageUrl(AsString(json.showAssets.filepath_ott_sd_show_image_overhang), 262)
            m.HDPosterUrl   = Cbs().GetImageUrl(AsString(json.showAssets.filepath_ott_hd_show_logo), 266)
            m.SDPosterUrl   = Cbs().GetImageUrl(AsString(json.showAssets.filepath_ott_sd_show_logo), 138)
        End If
        If IsNullOrEmpty(m.HDPosterUrl) Then
            If Not IsNullOrEmpty(json.filepathShowLogo) Then
                m.HDPosterUrl = json.filepathShowLogo 'Cbs().GetImageUrl(AsString(json.filepathShowLogo), 266)
                m.SDPosterUrl = json.filepathShowLogo 'Cbs().GetImageUrl(AsString(json.filepathShowLogo), 138)
            End If
        End If
    
        If IsNullOrEmpty(m.HDPosterUrl) Then
            m.HDPosterUrl   = "pkg:/images/icon_generic_hd.jpg"
        End If
        If IsNullOrEmpty(m.SDPosterUrl) Then
            m.SDPosterUrl   = "pkg:/images/icon_generic_sd.jpg"
        End If
    End If
End Sub

Function Show_GetSectionIDs() As Object
    If m.SectionIDs = invalid Then
        m.SectionIDs = Cbs().GetShowSectionIDs(m.ID)
    End If
    Return m.SectionIDs
End Function

Function Show_GetSectionID(section As String) As String
    Return AsString(m.GetSectionIDs()[section])
End Function

Function Show_GetRows() As Object
    rows = []
    sectionID = m.GetSectionID("Full Episodes")
    If Not IsNullOrEmpty(sectionID) Then
        seasons = Cbs().GetShowSeasons(m.ID, sectionID)
        For Each season In seasons
            row = {
                Name:       season.Title
                Section:    season
            }
            rows.Push(row)
        Next
    End If
    sectionID = m.GetSectionID("Clips")
    If Not IsNullOrEmpty(sectionID) Then
        row = {
            ID:         "clips"
            Name:       "Clips"
            Section:    NewSection()
        }
        row.Section.SetSectionID(sectionID, False)
        rows.Push(row)
    End If
    Return rows
End Function

Function Show_GetMostRecentEpisode() As Object
    sectionID = m.GetSectionID("Full Episodes")
    If Not IsNullOrEmpty(sectionID) Then
        episodes = Cbs().GetSectionVideos(sectionID, False, {}, 0, 1)
        If episodes.Count() > 0 Then
            Return episodes[0]
        End If
    End If
    Return invalid
End Function