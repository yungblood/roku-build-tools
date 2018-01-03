sub init()
    m.buttonFont = m.top.findNode("buttonFont")
    m.focusedButtonFont = m.top.findNode("focusedButtonFont")

    m.top.textColor = "0xffffff4c"
    m.top.focusedTextColor="0x1795efff"
    m.top.font = m.buttonFont
    m.top.focusedFont = m.focusedButtonFont
    m.top.height = 90
    m.top.width = 72
    m.top.processKeyEvents = false
end sub
