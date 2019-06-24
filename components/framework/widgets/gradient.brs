sub init()
    m.gradient = m.top.findNode("gradient")
end sub

sub calculateGradient()
    if m.top.width > 0 and m.top.height > 0 and m.top.direction <> "" then
        steps = 0
        finish = 0
        if m.top.direction = "horiz" then
            steps = m.top.width
            finish = m.top.width
        else
            steps = m.top.height
            finish = m.top.height
        end if

        startColors = getRgba(m.top.startColor)
        endColors = getRgba(m.top.endColor)
        change = {
            r: (endColors.r - startColors.r) / steps
            g: (endColors.g - startColors.g) / steps
            b: (endColors.b - startColors.b) / steps
            a: (endColors.a - startColors.a) / steps
        }

        m.gradient.layoutDirection = m.top.direction
        m.gradient.removeChildrenIndex(m.gradient.getChildCount(), 0)
        color = startColors
        for i = 0 To finish
            gradientColor = getColor(color.r, color.g, color.b, color.a)
            rect = m.gradient.createChild("Rectangle")
            if m.top.direction = "horiz" then
                rect.width = m.top.width / steps
                rect.height = m.top.height
                rect.color = gradientColor
            else
                rect.width = m.top.width
                rect.height = m.top.height / steps
                rect.color = gradientColor
            end if
            
            color.r = color.r + change.r
            color.g = color.g + change.g
            color.b = color.b + change.b
            color.a = color.a + change.a
        next
    end if
end sub

function getRgba(color as integer) as object
    return {
        r: (color >> 24 and &hff)
        g: (color >> 16 and &hff)
        b: (color >> 8 and &hff)
        a: (color and &hff)
    }
end function

function getColor(red as integer, blue as integer, green as integer, alpha as integer) as integer
    return (red << 24) + (blue << 16) + (green << 8) + alpha
end function
