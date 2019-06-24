function init()
    observeGlobalField("user", "onUserChanged")

    m.top.visible = false
    m.top.hideIfEmpty = true
end function

sub onUserChanged(nodeEvent as object)
    user = nodeEvent.getData()
    if m.user = invalid or not m.user.isSameNode(user) then
        m.user = user
        m.top.content = m.user.videoHistory
    end if
end sub
