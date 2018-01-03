sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.global.config, m.global.user, m.global.cookies)
    
    m.top.movies = api.getMovies()
end sub
