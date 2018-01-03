sub init()
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        m.top.title = json.title
        m.top.type = json.term_type
        if m.top.type = "show" then
            m.top.id = json.show_id
            if json.showAssets <> invalid then
                showAssets = json.showAssets
                if showAssets.filepath_show_browse_poster <> invalid then
                    m.top.browseImageUrl = showAssets.filepath_show_browse_poster
                else if showAssets.filepath_ott_hd_show_logo <> invalid then
                    m.top.browseImageUrl = showAssets.filepath_ott_hd_show_logo
                end if
            end if
        else if m.top.type = "movie" then
            m.top.id = json.movie_content_id
            if json.canMovieImages <> invalid and json.canMovieImages.count() > 0 then
                m.top.browseImageUrl = json.canMovieImages[0].url
            end if
        end if
    end if
end sub