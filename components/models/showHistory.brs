sub init()
    m.top.title = "Shows You Watch"
end sub

sub update()
    m.updateTask = createObject("roSGNode", "LoadShowHistoryTask")
    m.updateTask.observeField("history", "onShowHistoryLoaded")
    m.updateTask.control = "run"
end sub

sub onModeChanged(nodeEvent as object)
    mode = nodeEvent.getData()
    if mode = "recentlyWatched" then
        m.top.title = "Recently Watched"
    else
        m.top.title = "Shows You Watch"
    end if
end sub

sub onShowHistoryLoaded(nodeEvent as Object)
'    task = nodeEvent.getRoSGNode()
'    m.top.title = "Shows You Watch (" + task.sortOrder + ")"

    m.top.content = nodeEvent.getData()
end sub

sub onContentChanged(nodeEvent as object)
    m.updateTask = invalid

    shows = []
    shows.append(nodeEvent.getData())
    m.top.removeChildrenIndex(m.top.getChildCount(), 0)
    m.top.appendChildren(shows)
    
    m.top.firstLoad = false
end sub