sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.top)
    
    movieGroup = createObject("roSGNode", "MovieGroup")
    
    movies = api.getMovies(0, 24)
    if isAssociativeArray(movies) and movies.errorCode <> invalid then
        m.top.errorCode = movies.errorCode
    else
        movieGroup.appendChildren(movies)
    end if
    m.top.movies = movieGroup
end sub
