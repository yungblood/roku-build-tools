sub init()
    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.background = m.top.findNode("background")

    m.backgroundDarken = m.top.findNode("backgroundDarken")
    m.backgroundDarken.color = getThemeColor("singularity")

    m.metadata = m.top.findNode("metadata")
    m.title = m.top.findNode("title")
    m.description = m.top.findNode("description")

    m.airTime = m.top.findNode("airTime")

    m.tts = createObject("roTextToSpeech")
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.description.setFocus(true)
        setGlobalField("ignoreBack", false)
        hideSpinner()
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    '?"ShowInfoScreen.onKeyEvent: ";key,press
    if press then
        if key = "options" or key = "OK" then
            m.top.close = true
            return true
        end if
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
        m.title.text = show.title
        m.description.text = show.description.replace(chr(13), "")
        
        m.airTime.text = show.tuneInTime

        boundingRect = m.metadata.boundingRect()
        x = boundingRect.x
        y = boundingRect.y + boundingRect.height + 29
        m.description.translation = [x, y]
        m.description.height = 908 - y

        if createObject("roDeviceInfo").isAudioGuideEnabled() then
            m.tts.say(m.title.text)
            m.tts.say(m.airTime.text)
            m.tts.say(m.description.text)
        end if
    end if
end sub
