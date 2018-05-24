sub init()
    m.top.title = "Continue Watching"
end sub

sub update()
    if m.updateTask = invalid then
        m.updateTask = createObject("roSGNode", "LoadContinueWatchingTask")
        m.updateTask.observeField("episodes", "onContinueWatchingLoaded")
        m.updateTask.control = "run"
    end if
end sub

sub onContinueWatchingLoaded(nodeEvent as Object)
    m.updateTask = invalid
    m.top.content = nodeEvent.getData()
end sub

sub onContentChanged(nodeEvent as object)
    shows =[]
    shows.append(nodeEvent.getData())
    m.top.removeChildrenIndex(m.top.getChildCount(), 0)
    m.top.appendChildren(shows)
end sub