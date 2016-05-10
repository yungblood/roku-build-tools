Function NewShow(json = invalid As Object) As Object
    this                        = {}
    this.ClassName              = "Show"
    
    this.Initialize             = Show_Initialize
    
    this.ID                     = ""
    this.EpisodeCount           = 0
    this.ClipCount              = 0
    this.OverhangHD             = ""
    this.OverhangSD             = ""
    
    this.Seasons                = invalid
    
    this.GetSeasons             = Show_GetSeasons
    this.GetSections            = Show_GetSections
    this.GetSectionIDs          = Show_GetSectionIDs
    this.GetSectionID           = Show_GetSectionID
    
    this.GetRows                = Show_GetRows

    this.GetDynamicPlayEpisode  = Show_GetDynamicPlayEpisode
    
    If json <> invalid Then
        this.Initialize(json)
    End If
    
    Return this
End Function

Sub Show_Initialize(json As Object)
    m.Json = json
    
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

Function Show_GetSeasons(refresh = False As Boolean) As Object
    If refresh Or m.Seasons = invalid Then
        sectionID = AsString(m.GetSectionID("Full Episodes"))
        m.Seasons = Cbs().GetShowSeasons(m.ID, sectionID)
    End If
    Return m.Seasons
End Function

Function Show_GetSections() As Object
    If m.Sections = invalid Then
        m.Sections = Cbs().GetShowSections(m.ID)
    End If
    Return m.Sections
End Function

Function Show_GetSectionIDs() As Object
    If m.SectionIDs = invalid Then
        m.SectionIDs = Cbs().GetShowSectionIDs(m.ID)
    End If
    Return m.SectionIDs
End Function

Function Show_GetSectionID(sectionName As String) As String
    sections = m.GetSections()
    section = FindElementInArray(sections, sectionName, "Name")
    If section <> invalid Then
        Return AsString(section.SectionID)
    End If
    Return ""
End Function

Function Show_GetRows() As Object
    rows = []
    For Each section In m.GetSections()
        ' This is necessary to restrict the section to the current show
        section.ExcludeShow = False
        If section.Name = "Full Episodes" Then
            seasons = Cbs().GetShowSeasons(m.ID, section.SectionID)

            If section.SeasonsSortOrder = "asc" Then
                SortArray(seasons, Function(item1 As Object, item2 As Object) As Boolean : Return item1.SeasonNumber > item2.SeasonNumber : End Function)
            Else If section.SeasonsSortOrder = "desc" Then
                SortArray(seasons, Function(item1 As Object, item2 As Object) As Boolean : Return item1.SeasonNumber < item2.SeasonNumber : End Function)
            End If

            For Each season In seasons
                row = {
                    Name:       season.Title
                    Section:    season
                }
                rows.Push(row)
            Next
        Else
            row = {
                ID:         LCase(AsString(section.Name))
                Name:       section.Name
                Section:    section
            }
            rows.Push(row)
        End If
    Next
    Return rows
End Function

Function Show_GetDynamicPlayEpisode() As Object
    hdPoster = invalid
    sdPoster = invalid
    episode = Cbs().GetCurrentUser().GetRecentlyWatchedForShow(m.ID)
    If episode <> invalid Then
        If episode.IsFullyWatched() Then
            episode = episode.GetNextEpisode()
            If episode <> invalid Then
                If episode.ShowID = m.ID Then
                    ' Ensure the "next episode" is from the same show
                    hdPoster = "pkg:/images/icon_watchnext_hd.png"
                    sdPoster = "pkg:/images/icon_watchnext_sd.png"
                Else
                    episode = invalid
                End If
            End If
        Else
            hdPoster = "pkg:/images/icon_continuewatching_hd.jpg"
            sdPoster = "pkg:/images/icon_continuewatching_sd.jpg"
        End If
    End If
    If episode = invalid Then
        ' TODO: The API _should_ return the episodes in the display order, so
        '       grabbing the first episode in the list _should_ be accurate
        sectionID = m.GetSectionID("Full Episodes")
        If Not IsNullOrEmpty(sectionID) Then
            episodes = Cbs().GetSectionVideos(sectionID, False, {}, 0, 1)
            If episodes.Count() > 0 Then
                episode = episodes[0]
            End If
        End If
        If m.Category = "Classics" Then
            hdPoster = "pkg:/images/icon_watchfirst_hd.png"
            sdPoster = "pkg:/images/icon_watchfirst_sd.png"
        Else
            hdPoster = "pkg:/images/icon_watchlatest_hd.png"
            sdPoster = "pkg:/images/icon_watchlatest_sd.png"
        End If
    End If
    
    If episode <> invalid Then
        dynamicPlay = {}
        dynamicPlay.Append(episode)
        dynamicPlay.ID = "dynamicPlay"
        dynamicPlay.HDPosterUrl = hdPoster
        dynamicPlay.SDPosterUrl = sdPoster
        dynamicPlay.Episode = episode
        dynamicPlay.ShowDescription = True
        Return dynamicPlay
    End If
    Return invalid
End Function