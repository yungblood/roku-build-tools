sub init()
    m.top.observeField("json", "onMovieJsonChanged")
end sub

sub onMovieJsonChanged()
    json = m.top.json
    if json <> invalid then
        m.top.subtitle = m.top.rating + " | " + m.top.durationString + " | " + m.top.releaseDate
        if json.thumbnailSet <> invalid then
            for each thumbnail in json.thumbnailSet
                if thumbnail.assetType = "PosterArt" then
                    m.top.browseImageUrl = thumbnail.url
                else
                    m.top.thumbnailUrl = thumbnail.url
                end if
            next
        end if
        m.top.comscoreTrackingTitle = m.top.title
        m.top.convivaTrackingTitle = m.top.title

        m.top.audio_guide_text = m.top.title
    end if
end sub