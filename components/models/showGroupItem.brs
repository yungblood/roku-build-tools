sub init()
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        m.top.title = json.title
        if isNullOrEmpty(m.top.title) then
            m.top.title = json.showTitle
        end if
        m.top.id = json.showId.toStr()
        m.top.tuneInTime = json.tune_in_time
        
        if json.episodeVideoCount <> invalid then
            m.top.episodeCount = json.episodeVideoCount.totalEpisodes
            m.top.clipCount = json.episodeVideoCount.totalClips
        end if
        showAssets = json.showAssets
        if showAssets <> invalid then
            m.top.heroImageUrl = showAssets.filepath_show_page_header
            m.top.myCbsImageUrl = showAssets.filepath_mycbs_show_image
            m.top.descriptionImageUrl = showAssets.filepath_show_description_poster
            if isNullOrEmpty(m.top.browseImageUrl) then
                m.top.browseImageUrl = m.top.descriptionImageUrl
            end if
            if isNullOrEmpty(m.top.descriptionImageUrl) then
                m.top.descriptionImageUrl = m.top.browseImageUrl
            end if

            if isNullOrEmpty(m.top.browseImageUrl) then
                m.top.browseImageUrl = showAssets.filepath_show_browse_poster
            end if
        end if

        if json.callbacks <> invalid then
            m.top.displayCallbackUrl = json.callbacks.amlg_onSetDisplayCallback
            m.top.clickCallbackUrl = json.callbacks.amlg_onItemClickCallback
        end if
    end if
end sub