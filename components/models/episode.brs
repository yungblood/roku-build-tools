sub init()
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then

'       After discussing further with the comscore and conviva folks, this should no longer be necessary
'        ' HACK: This should ultimately be fixed in the CMS, but as that's not currently
'        '       an option, we replace occurrences of CBS All Access Movies with just Movies
'        json.seriesTitle = json.seriesTitle.replace("CBS All Access Movies", "Movies")

        m.top.id                = asString(json.contentId)
        m.top.pid               = asString(json.pid)
        m.top.mediaID           = asString(json["__FOR_TRACKING_ONLY_MEDIA_ID"])
        m.top.seasonNumber      = asString(json.seasonNum)
        m.top.episodeNumber     = asString(json.episodeNum)
        m.top.description       = asString(json.description)
        m.top.rating            = uCase(asString(json.rating))
        m.top.length            = asInteger(json.duration)
        m.top.showID            = asString(json.cbsShowId)
        m.top.showName          = asString(json.seriesTitle)
        m.top.status            = asString(json.status)
        m.top.subscriptionLevel = asString(json.subscriptionLevel)
        m.top.trackingTitle     = asString(json.title)
        m.top.trackingContentID = asString(json.contentId)
        m.top.title             = asString(json.label)
        m.top.titleSeason       = asString(json.seriesTitle)
        m.top.isFullEpisode     = asBoolean(json.fullEpisode, true)
        m.top.isLive            = asBoolean(json.isLive, false)
        m.top.isProtected       = asBoolean(json.isProtected, false)
        m.top.topLevelCategory  = asString(json.topLevelCategory)
        
        m.top.audio_guide_text = m.top.showName + " " + m.top.title
        
        m.top.premiumAudioAvailable = asBoolean(json.premiumAudioAvailable)

        if asInteger(m.top.seasonNumber) > 0 then
            m.top.seasonString = "S" + asString(m.top.seasonNumber)
        end if
        if asInteger(m.top.episodeNumber) > 0 then
            m.top.episodeString = "E" + asString(m.top.episodeNumber)
        end if
        m.top.durationString    = getDurationStringStandard(m.top.length)
        
        m.top.convivaTrackingTitle = m.top.showName + " - " + m.top.title
        m.top.comscoreTrackingTitle = m.top.showName '+ " - " + m.top.title + "--" + m.top.seasonNumber + m.top.episodeNumber
        
        if isNullOrEmpty(m.top.showName) then
            m.top.nielsenID = "CBAA"
        else
            m.top.nielsenID = m.top.showName
        end if
        
        airDate                 = dateFromISO8601String(asString(json["_airDateISO"]))
        m.top.airDate           = airDate.asSeconds()
        
        ' We can't use roDateTime.asDateString("short-date") here, because it truncates 2000-2009 down to a single digit
        m.top.airDateString     = asString(airDate.getMonth()) + "/" + asString(airDate.getDayOfMonth()) + "/" + asString(airDate.getYear()).mid(2)
        
        m.top.releaseDate       = airDate.asDateString("short-month-no-weekday")
        m.top.subtitleConfig    = { trackName: json.closedCaptionUrl }

        if json.endCreditsChapterTime <> invalid then
            m.top.endCreditsChapterTime = getTotalSecondsFromTime(json.endCreditsChapterTime)
            m.top.endCreditsChapterEnd = m.top.endCreditsChapterTime + 30
            if m.top.endCreditsChapterEnd > m.top.length then
                m.top.endCreditsChapterEnd = m.top.length
            end if
        end if
        
        thumbnails = []
        if json.thumbnailSet <> invalid then
            ' Sort by width (descending)
            json.thumbnailSet.sortBy("width", "r")
            thumbnails.Append(json.thumbnailSet)
        end if
        
        if thumbnails.count() > 0 then
            m.top.thumbnailUrl = thumbnails[0].url
            m.top.hdPosterUrl = thumbnails[0].url
        else
            m.top.thumbnailUrl = json.thumbnail
            m.top.hdPosterUrl = json.thumbnail
        end if
                
'        if json.thumbnailSheetSet <> invalid then
'            for each set in asArray(json.thumbnailSheetSet)
'                if isAssociativeArray(set) then
'                    if asInteger(set.width) = 320 then
'                        m.top.hdBifUrl = asString(set.url)
'                    else if asInteger(set.width) = 240 then
'                        m.top.sdBifUrl = asString(set.url)
'                    end if
'                end if
'            next
'        end if

        m.top.liveStreamingUrl = json.liveStreamingUrl
    end if
end sub