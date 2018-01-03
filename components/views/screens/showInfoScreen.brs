sub init()
    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.background = m.top.findNode("background")
    m.poster = m.top.findNode("poster")
    m.title = m.top.findNode("title")
    m.description = m.top.findNode("description")

    m.top.setFocus(true)
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.description.setFocus(true)
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    ?"ShowInfoScreen.onKeyEvent: ";key,press
    if press then
    end if
    return false
end function

sub onShowIDChanged()
    m.loadTask = createObject("roSGNode", "ShowInfoScreenTask")
    m.loadTask.observeField("show", "onShowLoaded")
    m.loadTask.showID = m.top.showID
    m.loadTask.control = "run"
end sub

sub onShowLoaded()
    m.top.show = m.loadTask.show
end sub

sub onShowChanged()
    show = m.top.show
    if show <> invalid then
        m.background.uri = getImageUrl(show.heroImageUrl, m.background.width)
        m.poster.uri = getImageUrl(show.descriptionImageUrl, m.poster.width)
        m.title.text = uCase(show.title)
        m.description.text = show.description.replace(chr(13), "")
    end if
end sub
