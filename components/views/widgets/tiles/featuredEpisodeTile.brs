sub init()
end sub

sub updateMetadata()
    if m.episode <> invalid then
        if m.episode.subtype() = "Movie" then
            m.title.text = m.episode.title
            m.subtitle.text = m.episode.rating + " | " + m.episode.durationString
        else if m.episode.subtype() = "LiveFeed" then
            m.title.text = m.episode.title
            m.subtitle.text = m.episode.description
        else
            if m.episode.isFullEpisode then
                m.title.text = m.episode.showName
                subtitle = (m.episode.seasonString + " " + m.episode.episodeString).trim()
                if not isNullOrEmpty(subtitle) then
                    subtitle = subtitle + " | "
                end if
                subtitle = subtitle + m.episode.airDateString
                m.subtitle.text = subtitle
            else
                m.title.text = m.episode.title
                m.subtitle.text = "(" + m.episode.durationString + ") " + m.episode.showName
            end if
        end if
    end if
end sub
