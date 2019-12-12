sub init()
    m.top.observeField("focusedChild", "onFocusChanged")

    m.textFocus = m.top.findNode("textFocus")
    
    m.buttons = m.top.findNode("buttons")
    m.buttons.observeField("buttonSelected", "onButtonSelected")
    m.buttons.jumpToIndex = 1
    
    m.text = m.top.findNode("text")
    m.text.text = "Loading..."

    m.loadTask = createObject("roSGNode", "LoadTextTask")
    m.loadTask.observeField("text", "onTextLoaded")
    m.loadTask.uri = "http://www.cbs.com/sites/roku/cbs_roku.cfg"
    m.loadTask.control = "run"
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        if key = "down" then
            if m.text.isInFocusChain() then
                m.buttons.setFocus(true)
                m.textFocus.visible = false
                return true
            end if
        else if key = "up" then
            if m.buttons.isInFocusChain() and m.text.focusable then
                m.text.setFocus(true)
                m.textFocus.visible = true
                return true
            end if
        else if key = "back" then
            m.top.buttonSelected = "ok"
            return true
        end if
    end if
    return false
end function

sub onFocusChanged()
    if m.top.hasFocus() then
        m.buttons.setFocus(true)
        setGlobalField("ignoreBack",false)
    end if
end sub

sub onTextLoaded(nodeEvent as object)
    m.text.text = nodeEvent.getData()
end sub

sub onButtonSelected(nodeEvent as object)
    button = m.buttons.getChild(nodeEvent.getData())
    m.top.buttonSelected = button.id
end sub
