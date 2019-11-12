sub init()
    m.top.title = "Recently Watched"
end sub

sub update()
    if m.updateTask = invalid then
        m.updateTask = createObject("roSGNode", "LoadVideoHistoryTask")
        m.updateTask.observeField("history", "onHistoryLoaded")
        m.updateTask.control = "run"
    end if
end sub

sub onHistoryLoaded(nodeEvent as object)
    m.updateTask = invalid
    m.top.content = nodeEvent.getData()
end sub

sub onContentChanged(nodeEvent as object)
    episodes = []
    episodes.append(nodeEvent.getData())
    m.top.removeChildrenIndex(m.top.getChildCount(), 0)
    m.top.appendChildren(episodes)
    
    ' Cache the episode resume points by ID, so we can look them up easier when updating
    ' progress bars on the tiles
    cache = {}
    for each episode in episodes
        cache[episode.id] = episode.resumePoint
    next

    m.top.cache = cache
end sub