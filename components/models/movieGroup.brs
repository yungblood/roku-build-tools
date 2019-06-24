sub init()
    m.loadedPages = []
    m.loadTasks = []
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        m.top.title = "Movies"

        if json.movies <> invalid then
            for each item in json.movies
                movie = createObject("roSGNode", "movie")
                movie.json = item
                m.top.appendChild(movie)
            next
            m.loadedPages[0] = true
        end if
    end if
end sub

sub onLoadIndexChanged(nodeEvent as object)
    index = nodeEvent.getData()
    for i = 0 to m.top.pageSize - 1
        childIndex = index + i
        if m.top.totalCount = -1 or childIndex < m.top.totalCount then
            page = childIndex \ m.top.pageSize
            if m.loadedPages[page] = invalid then
                m.loadedPages[page] = true
                loadTask = createObject("roSGNode", "LoadMoviesPageTask")
                loadTask.observeField("movies", "onMoviesLoaded")
                loadTask.page = page
                loadTask.pageSize = m.top.pageSize
                loadTask.control = "run"
                m.loadTasks[page] = loadTask
                exit for
            end if
        end if
    next
end sub

sub onMoviesLoaded(nodeEvent as object)
    task = nodeEvent.getRoSGNode()
    startIndex = task.page * task.pageSize
    movies = task.movies
    if movies.count() = 0 then
        if startIndex = 0 then
            m.top.totalCount = 0
        end if
    else
        m.top.appendChildren(movies)
        'if movies.count() < task.pageSize or task.page >= m.top.maxPages then
        '    m.top.totalCount = m.top.getChildCount()
        'end if
    end if
    m.loadTasks[task.page] = invalid
end sub