sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.top)

    if m.top.refreshParentalControls then
        ' We're refreshing the user to capture any parental control changes
        user = getGlobalField("user")
        refreshedUser = api.getUser()
        if refreshedUser <> invalid then
            ' We reset the json directly to avoid user observer callbacks
            user.json = refreshedUser.json
        end if
    end if

    if m.top.populateStream then
        if api.isOverStreamLimit() then
            m.top.error = "CONCURRENT_STREAM_LIMIT"
            m.top.episode = invalid
            return
        end if
    end if
    episode = api.getEpisode(m.top.episodeID, m.top.populateStream)
    if episode <> invalid and episode.errorCode = invalid then
        if episode <> invalid and episode.isLive and m.top.populateStream then
            hls = parseHls(episode.videoStream.url)
            if hls <> invalid and hls.playlists <> invalid and hls.playlists.count() > 0 then
                hls = parseHls(hls.playlists[0].url)
                if hls <> invalid then
                    if hls.metadata["#EXT-X-PLAYLIST-TYPE"] = "VOD" then
                        episode.videoStream.playStart = 0
                    end if
                end if
            end if
        end if   
        
        m.top.episode = episode
    else
        if episode <> invalid then
            m.top.errorCode = asInteger(episode.errorCode)
        end if
        m.top.episode = invalid
    end if

    if episode <> invalid and m.top.loadNextEpisode and not episode.isLive then
        if episode.isFullEpisode then
            m.top.nextEpisode = api.getNextEpisode(episode.id, episode.showID, m.top.populateStream)
        else
            m.top.nextEpisode = invalid
        end if
    end if
    if episode <> invalid then
        m.top.Episode = episode
    end if
end sub
