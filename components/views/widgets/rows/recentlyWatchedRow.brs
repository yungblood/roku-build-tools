function init()
    m.global.observeField("user", "onUserChanged")

    m.top.visible = false
    m.top.hideIfEmpty = true
end function

sub onUserChanged()
    if m.user = invalid or not m.user.isSameNode(m.global.user) then
        m.user = m.global.user
        m.top.content = m.user.videoHistory
    end if
end sub
