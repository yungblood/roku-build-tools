sub init()
    m.top.title = "Recently Watched"
end sub

sub update()
    m.updateTask = createObject("roSGNode", "LoadRecentlyWatchedTask")
    m.updateTask.observeField("episodes", "onEpisodesLoaded")
    m.updateTask.control = "run"
end sub

sub onEpisodesLoaded(nodeEvent as object)
    m.top.content = nodeEvent.getData()
end sub

sub onContentChanged(nodeEvent as object)
    m.updateTask = invalid

    episodes = []
    episodes.append(nodeEvent.getData())
    m.top.removeChildrenIndex(m.top.getChildCount(), 0)
    m.top.appendChildren(episodes)
end sub