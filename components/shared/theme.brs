function theme() as object
    if m.theme = invalid then
        m.theme = {
            colors: {
                laguna:             "0x1056c9ff"
                blueMyMind:         "0x0092f3ff"
                persianRed:         "0xe42121ff"
                singularity:        "0x000000ff"
                darkMatter:         "0x1d1d1dff"
                galaxy:             "0x121212ff"
                nigel:              "0x393939ff"
                celestialSphere:    "0x666666ff"
                fiftyShadesOfCBS:   "0x999999ff"
                meteor:             "0xaaaaaaff"
                solarCloud:         "0xcdcdcdff"
                jupiter:            "0xefefefff"
                milkyWay:           "0xeeeeeeff"
                plasma:             "0xfafafaff"
                snowWhite:          "0xffffffff"
            }
            fonts: {
                giga: {
                    size: 94
                    lineHeight: 72
                    lineSpacing: -45
                    weight: "black"
                }
                mega: {
                    size: 72
                    lineHeight: 80
                    lineSpacing: -10
                    weight: "bold"
                }
                kilo: {
                    size: 56
                    lineHeight: 60
                    lineSpacing: -10
                    weight: "semibold"
                }
                deca: {
                    size: 40
                    lineHeight: 46
                    lineSpacing: -4
                    weight: "semibold"
                }
                deci: {
                    size: 32
                    lineHeight: 38
                    lineSpacing: -3
                    weight: "semibold"
                }
                centi: {
                    size: 28
                    lineHeight: 34
                    lineSpacing: -2
                    weight: "regular"
                }
                micro: {
                    size: 24
                    lineHeight: 30
                    lineSpacing: -2
                    weight: "regular"
                }
                mili: {
                    size: 22
                    lineHeight: 28
                    lineSpacing: -1
                    weight: "regular"
                }
                nano: {
                    size: 18
                    lineHeight: 24
                    lineSpacing: 0
                    weight: "regular"
                }
            }
        }
    end if
    return m.theme
end function

function getThemeColor(name as string, opacity = "ff" as string) as string
    color = theme().colors[name]
    if color <> invalid and opacity <> "ff" then
        color = color.mid(0, color.len() - 2) + opacity
    end if
    return color
end function

function getThemeFont(style as string, weight = "" as string) as object
    font = createObject("roSGNode", "CBSFont")
    fontInfo = theme().fonts[style]
    if fontInfo <> invalid then
        font.fontInfo = fontInfo
        if weight <> invalid and weight <> "" then
            font.weight = weight
        end if
    end if
    return font
end function
