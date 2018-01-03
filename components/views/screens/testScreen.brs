sub init()
    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.list = m.top.findNode("list")
    'm.list.initialPositions = [-390, 192, 774, 1356, 1938]
    'm.list.forwardIntermediatePositions = [-976, -394, 188, 770, 1352]
    'm.list.finalPositions = [-1300, -718, -136, 446, 1028]

    m.list.initialPositions             = [ 112,  492, 872, 1252, 1632, 2012]
    m.list.forwardIntermediatePositions = [-608, -228, 152,  532,  912, 1292]
    m.list.finalPositions               = [-648, -268, 112,  492,  872, 1252]
    
    content = createObject("roSGNode", "ContentNode")
    for i = 0 to 20
        child = content.createChild("ContentNode")
        child.id = i.toStr()
    next
    m.list.content = content

    m.top.setFocus(true)
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.list.setFocus(true)
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        if key = "down" then
        else if key = "up" then
        else if key = "options" then
        end if
    end if
    return false
end function
