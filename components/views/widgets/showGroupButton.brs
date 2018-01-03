sub init()
    m.buttonFont = m.top.findNode("buttonFont")
    m.focusedButtonFont = m.top.findNode("focusedButtonFont")

    m.top.textColor = "0x939392ff"
    m.top.focusedTextColor="0x939392ff"
    
    m.top.focusedBackgroundUri = "pkg:/images/menu_focus_$$RES$$.9.png"
    m.top.font = m.buttonFont
    m.top.focusedFont = m.buttonFont
    m.top.height = 60
end sub

sub onGroupChanged()
    m.top.text = m.top.group.title
end sub

sub onHighlightChanged()
    if m.top.highlight then
        m.top.textColor = "0x0092f3ff"
        m.top.focusedTextColor = "0x0092f3ff"
    else
        m.top.textColor = "0x939392ff"
        m.top.focusedTextColor = "0x939392ff"
    end if
end sub

