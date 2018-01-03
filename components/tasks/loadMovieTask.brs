sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.global.config, m.global.user, m.global.cookies)

    if m.top.populateStream then
        if api.isOverStreamLimit() then
            m.top.error = "CONCURRENT_STREAM_LIMIT"
            m.top.episode = invalid
            return
        end if
    end if
    movie = api.getMovie(m.top.movieID, m.top.populateStream)
    m.top.movie = movie
    if movie <> invalid and m.top.loadNextEpisode and not movie.isLive then
        m.top.nextEpisode = api.getNextEpisode(movie.id, movie.showID, m.top.populateStream)
    end if
end sub
