sub init()
end sub

sub updateMetadata()
    if m.episode <> invalid then
        if m.episode.subtype() = "Movie" then
            m.title.text = m.episode.title
            m.subtitle.text = m.episode.durationString
            m.subtitle2.text = m.episode.rating
        else if m.episode.subtype() = "LiveFeed" then
            m.title.text = m.episode.title
            m.subtitle.text = m.episode.description
        else
            if m.episode.isFullEpisode then
                m.title.text = m.episode.showName
                m.episodeNumber.text = (m.episode.seasonString + " " + m.episode.episodeString).trim()
                m.subtitle.text = m.episode.releaseDate
            else
                m.title.text = m.episode.title
                m.subtitle.text = m.episode.durationString
                m.subtitle2.text = m.episode.showName
            end if
        end if
    end if
end sub
