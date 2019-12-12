sub init()
    m.buttonFont = m.top.findNode("buttonFont")
    m.focusedButtonFont = m.top.findNode("focusedButtonFont")

    m.top.textColor = "0xeeeeee80"
    m.top.focusedTextColor="0x0092f3ff"
    m.top.font = m.buttonFont
    m.top.focusedFont = m.focusedButtonFont
    m.top.height = 70
    m.top.width = 70
    m.top.processKeyEvents = false
end sub
