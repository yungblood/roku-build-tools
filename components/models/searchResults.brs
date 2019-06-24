sub init()
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        shows = getGlobalField("showCache")
        for each term in json.terms
            result = createObject("roSGNode", "SearchResult")
            result.json = term
            if result.type = "show" then
                show = shows[result.id]
                if show <> invalid then
                    result.browseImageUrl = show.browseImageUrl
                    result.episodeCount = show.episodeCount
                    result.clipCount = show.clipCount
                    m.top.appendChild(result)
                end if
            else if result.type = "movie" then
                m.top.appendChild(result)
            end if
        next
    end if
end sub