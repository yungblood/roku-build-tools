sub init()
    m.loadedPages = []
    m.loadTasks = []
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        m.top.title = json.title
        m.top.id = json.id.toStr()
        
        if json.shows <> invalid then
            for each item in json.shows
                show = createObject("roSGNode", "ShowGroupItem")
                show.json = item
                m.top.appendChild(show)
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
                loadTask = createObject("roSGNode", "LoadAmlgShowGroupPageTask")
                loadTask.observeField("shows", "onShowsLoaded")
                loadTask.variant = m.top.variant
                loadTask.hideIfTrending = m.top.hideIfTrending
                loadTask.page = page
                loadTask.pageSize = m.top.pageSize
                loadTask.control = "run"
                m.loadTasks[page] = loadTask
                exit for
            end if
        end if
    next
end sub

sub onShowsLoaded(nodeEvent as object)
    task = nodeEvent.getRoSGNode()
    startIndex = task.page * task.pageSize
    shows = task.shows
    if shows.count() = 0 then
        if startIndex = 0 then
            m.top.totalCount = 0
        end if
    else
        if isNullOrEmpty(m.top.displayCallbackUrl) then
            m.top.displayCallbackUrl = shows[0].displayCallbackUrl
            if not isNullOrEmpty(m.top.displayCallbackUrl) then
                ' HACK: This will only get called when the carousel is loaded
                '       so we make the display callback here. If this becomes
                '       more prominent throughout the app, we may need to change
                '       how this works.
                loadCallbackUrl(m.top.displayCallbackUrl)
            end if
        end if
        m.top.appendChildren(shows)
        if shows.count() < task.pageSize or task.page >= m.top.maxPages then
            m.top.totalCount = m.top.getChildCount()
        end if
    end if
    m.loadTasks[task.page] = invalid
end sub