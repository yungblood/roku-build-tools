sub init()
    m.backgroundImage.loadSync = true
    m.top.backgroundUri = "pkg:/images/ui/button_unfocused_$$RES$$.9.png"
    m.top.focusedBackgroundUri = "pkg:/images/ui/button_focused.png"
    
    m.top.textColor = getThemeColor("milkyWay")
    
    m.top.forceUpperCase = true
    m.top.height = 70
    m.top.style = "micro"
    m.top.weight = "semibold"
    m.top.wrap = false
    m.top.paddingLeft = 64
    m.top.paddingRight = 64
end sub

sub updateFont()
    font = getThemeFont(m.top.style, m.top.weight)
    m.top.font = font
    m.top.focusedFont = font
end sub
