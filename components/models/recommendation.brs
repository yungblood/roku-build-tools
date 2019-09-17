sub init()
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        if json.config_type <> invalid then
            m.top.videoType = json.config_type
        else
            m.top.videoType = "episode"
        end if

        model = invalid
        if json.playbackModeCTA <> invalid then
            m.top.callToAction = uCase(json.playbackModeCTA)
            model = json.model
            m.top.bookmarkPosition = asInteger(json.medTime)
        else if json.continuousPlaybackMode <> invalid then
            m.top.callToAction = json.continuousPlaybackMode.replace("_", " ")
            model = json.model
            m.top.bookmarkPosition = asInteger(json.medTime)
        else if json.callToAction <> invalid then
            m.top.callToAction = json.callToAction
            model = json.video.model
            m.top.bookmarkPosition = asInteger(json.video.medTime)
            
            m.top.thumbnailUrl = asString(json.filePathPromoImage)
            m.top.title = asString(json.title)
            m.top.subtitle = asString(json.tuneInTime)
            
            if json.video <> invalid then
                model = json.video.model
            end if
        end if
        
        if model <> invalid then
            video = invalid
            if model.mediaType = "Movie" then
                video = createObject("roSGNode", "Movie")
            else if model.isLive then
                video = createObject("roSGNode", "LiveFeed")
            else
                video = createObject("roSGNode", "Episode")
            end if
            video.json = model
            m.top.video = video
            
            show = getShowFromCache(asString(video.showId))
            if show <> invalid then
                m.top.backgroundUrl = show.heroImageUrl
            end if
        
            if isNullOrEmpty(m.top.thumbnailUrl) then
                if show <> invalid then
                    m.top.thumbnailUrl = show.myCbsImageUrl
                else
                    m.top.thumbnailUrl = video.thumbnailUrl
                end if
            end if
            if isNullOrEmpty(m.top.title) then
                m.top.title = video.title
            end if
            if isNullOrEmpty(m.top.subtitle) then
                m.top.subtitle = (video.seasonString + " " + video.episodeString).trim()
            end if
        end if

    end if
end sub
