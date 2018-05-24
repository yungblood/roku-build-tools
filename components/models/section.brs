sub init()
    m.loadedPages = []
    m.loadTasks = []
    
    user = m.global.user
    if user <> invalid and user.videoHistory <> invalid then
        user.videoHistory.observeField("cache", "onVideoHistoryChanged")
    end if
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        m.top.title = json.title
        if m.top.title = invalid or m.top.title = "" then
            m.top.title = json.sectionTitle
        end if
        if json.id <> invalid then
            m.top.id = json.id.toStr()
        end if
        if m.top.id = invalid or m.top.id = "" then
            m.top.id = json.sectionId.toStr()
        end if
        m.top.type = json.section_type
        m.top.displaySeasons = json.display_seasons
        m.top.seasonSortOrder = json.seasons_sort_order
        
        if json.sectionItems <> invalid then
            for each item in json.sectionItems.itemList
                if item.mediaType = "Movie" then
                    movie = m.top.createChild("Movie")
                    movie.json = item
                else
                    episode = m.top.createChild("Episode")
                    episode.json = item
                end if
            next
            m.loadedPages[0] = true
            updateResumePoints()
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
                loadTask = createObject("roSGNode", "LoadSectionPageTask")
                loadTask.observeField("videos", "onVideosLoaded")
                loadTask.sectionID = m.top.id
                loadTask.excludeShow = m.top.excludeShow
                loadTask.params = m.top.params
                loadTask.page = page
                loadTask.pageSize = m.top.pageSize
                loadTask.control = "run"
                m.loadTasks[page] = loadTask
                exit for
            end if
        end if
    next
end sub

sub onTotalCountChanged()
    'm.top.createChildren(m.top.totalCount - m.top.getchildCount(), "ContentNode")
end sub

sub onVideoHistoryChanged(nodeEvent as object)
    updateResumePoints(nodeEvent.getData())
end sub

sub updateResumePoints(history = invalid as object)
    if history = invalid then
        user = m.global.user
        if user <> invalid and user.videoHistory <> invalid then
            history = user.videoHistory.cache
        end if
    end if
    if history <> invalid then
        for i = 0 to m.top.getChildCount() - 1
            child = m.top.getChild(i)
            resumePoint = history[child.id]
            if resumePoint <> invalid then
                child.resumePoint = resumePoint
            end if
        next
    end if
end sub

sub onVideosLoaded(nodeEvent as object)
    task = nodeEvent.getRoSGNode()
    startIndex = task.page * task.pageSize
    videos = task.videos
    if videos.count() = 0 then
        if startIndex = 0 then
            m.top.totalCount = 0
        end if
    else
        m.top.appendChildren(videos)
        if videos.count() < task.pageSize or task.page >= m.top.maxPages then
            m.top.totalCount = m.top.getChildCount()
        end if
    end if
    m.loadTasks[task.page] = invalid
    updateResumePoints()
end sub