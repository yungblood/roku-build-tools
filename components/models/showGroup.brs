sub init()
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
        end if
    end if
end sub

sub onLoadShows()
    if m.top.getChildCount() = 0 then
        m.loadTask = createObject("roSGNode", "LoadShowsTask")
        m.loadTask.observeField("shows", "onShowsLoaded")
        m.loadTask.groupID = m.top.id
        m.loadTask.control = "run"
    end if
end sub

sub onShowsLoaded()
    m.top.appendChildren(m.loadTask.shows)
    m.loadTask = invalid
end sub