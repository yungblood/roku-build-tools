sub init()
    m.top.observeField("focusedChild","onFocusChanged")

    m.hero = m.top.findNode("hero")
    m.shade = m.top.findNode("shade")

    m.fadeOutAnimation = m.top.findNode("fadeOutAnimation")
    m.fadeInAnimation = m.top.findNode("fadeInAnimation")

    m.videoPreview = m.top.findNode("videoPreview")
    m.videoPreview.observeField("state", "onVideoStateChanged")
    m.videoPreview.observeField("position", "onVideoPositionChanged")
end sub

sub onControlChanged(nodeEvent as object)
    control = nodeEvent.getData()
    if m.content <> invalid then
        m.videoPreview.control = control
    end if
end sub

sub onVideoUriChanged(nodeEvent as object)
    uri = nodeEvent.getData()
    if uri <> "" then
        m.content = createObject("roSGNode", "ContentNode")
        m.content.url = uri
        m.content.title = "Preview Video"
        m.content.clipEnd = 18.1

        m.videoPreview.content = m.content
    end if
end sub

sub onThumbnailUriChanged(nodeEvent as object)
    m.hero.uri = nodeEvent.getData()
end sub

sub onVideoStateChanged(nodeEvent as object)
    state = nodeEvent.getData()
    if state = "playing" then
    else if state = "buffering" then
        m.videoPreview.mute = true
    else if state = "finished" or state = "stopped" then
        m.hero.uri = m.top.heroUri
        m.fadeInAnimation.control = "start"
        m.videoPreview.mute = false
    else if state = "error" then
        ? "[Video1] ERROR " ; m.videoPreview.error ; m.videoPreview.errorMsg
    end if
    m.top.videoState = state
end sub

sub onVideoPositionChanged(nodeEvent as object)
    position = nodeEvent.getData()
    if m.hero.opacity = 1 then
        m.fadeOutAnimation.control = "start"
    end if
end sub

sub updateLayout(nodeEvent as object)
    if m.top.width > 0 and m.top.height > 0 then
        m.shade.width = m.top.width
        m.shade.height = m.top.height

        m.videoPreview.width = m.top.width
        m.videoPreview.height = m.top.height
    
        coordX = m.top.width - m.videoPreview.width
        coordY = m.top.height - m.videoPreview.height
    
        m.videoPreview.translation = [coordX, 0]
        m.shade.translation= [coordX, 0]
    end if
end sub
