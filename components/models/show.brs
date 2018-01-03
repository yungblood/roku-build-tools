sub init()
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        show = json
        if json.show <> invalid and json.show.results <> invalid then
            show = json.show.results[0]
        end if
        if show <> invalid then
            m.top.title = show.title
            m.top.id = show.id
            if show.showId <> invalid then
                m.top.id = show.showId
            end if
            m.top.tuneInTime = show.tune_in_time
            m.top.description = show.about
            m.top.categories = show.category
            m.top.isClassic = (show.category = "Classics")
        end if

        if json.episodeVideoCount <> invalid then
            if json.episodeVideoCount.totalEpisodes <> invalid then
                m.top.episodeCount = json.episodeVideoCount.totalEpisodes
            else
                m.top.episodeCount = json.episodeVideoCount.total
            end if
            if json.episodeVideoCount.totalClips <> invalid then
                m.top.clipCount = json.episodeVideoCount.totalClips
            else
                m.top.clipCount = json.episodeVideoCount.clips
            end if
        end if

        showAssets = json.showAssets
        if json.showAssets <> invalid and json.showAssets.results <> invalid then
            showAssets = json.showAssets.results
        end if
        if showAssets <> invalid then
            m.top.heroImageUrl = showAssets.filepath_show_page_header
            m.top.myCbsImageUrl = showAssets.filepath_mycbs_show_image
            m.top.browseImageUrl = showAssets.filepath_show_browse_poster
            m.top.descriptionImageUrl = showAssets.filepath_show_description_poster
            if m.top.browseImageUrl = "" then
                m.top.browseImageUrl = m.top.descriptionImageUrl
            end if
            if m.top.descriptionImageUrl = "" then
                m.top.descriptionImageUrl = m.top.browseImageUrl
            end if
        end if
    end if
end sub