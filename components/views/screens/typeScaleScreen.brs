sub init()
    m.col1 = m.top.findNode("col1")
    m.col2 = m.top.findNode("col2")

    fonts = [
        "Giga"
        "Mega"
        "Kilo"
        "Deca"
        "Deci"
        "Centi"
        "Micro"
        "Mili"
        "Nano"
    ]
    for i = 0 to fonts.count() \ 2 - 2
        font = fonts[i]
        label = m.col1.createChild("CBSLabel")
        label.width = 500
        label.style = font
        label.text = font + chr(10) + font
        label.themeColor = "milkyWay"
        label.wrap = true
    next
    for i = fonts.count() \ 2 - 1 to fonts.count() - 1
        font = fonts[i]
        label = m.col2.createChild("CBSLabel")
        label.width = 500
        label.style = font
        label.text = font + chr(10) + font
        label.themeColor = "milkyWay"
        label.wrap = true
    next
end sub
