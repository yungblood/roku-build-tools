sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.top)

    movies = api.getMovies(m.top.page, m.top.pageSize)
    m.top.movies = movies
end sub
