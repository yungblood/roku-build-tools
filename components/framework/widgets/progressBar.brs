sub init()
    m.backgroundRect = m.top.findNode("backgroundRect")
    m.background = m.top.findNode("background")
    m.barRect = m.top.findNode("barRect")
    m.bar = m.top.findNode("bar")
    m.thumb = m.top.findNode("thumb")
    m.ticks = m.top.findNode("ticks")
end sub

sub updateLayout()
    if m.top.width > 0 and m.top.height > 0 then
        m.backgroundRect.width = m.top.width
        m.backgroundRect.height = m.top.height
        m.background.width = m.top.width
        m.background.height = m.top.height
        
        m.barRect.translation = [m.top.padding, m.top.padding]
        m.barRect.width = m.top.width - (m.top.padding * 2)
        m.barRect.height = m.top.height - (m.top.padding * 2)
        m.bar.translation = [m.top.padding, m.top.padding]
        m.bar.width = m.top.width - (m.top.padding * 2)
        m.bar.height = m.top.height - (m.top.padding * 2)
        
        onValueChanged()
    end if
end sub

sub onValueChanged()
    progress = 0
    range = m.top.maxValue - m.top.minValue
    value = m.top.value - m.top.minValue
    if range > 0 then
        progress = value / range
    end if
    if progress > 1 then
        progress = 1
    end if
    m.barRect.width = (m.top.width - (2 * m.top.padding)) * progress
    m.bar.width = (m.top.width - (2 * m.top.padding)) * progress
    m.barRect.visible = progress > 0
    m.bar.visible = progress > 0

        
    if m.thumb.width > 0 and m.thumb.height > 0 then
        m.thumb.visible = true
        x = m.bar.width - (m.thumb.width / 2)
        if x < 0 then
            x = 0
        else if x - m.thumb.width > m.bar.width then
            x = m.bar.wdith - m.thumb.width
        end if
        y = ((m.top.height - m.thumb.height) / 2)
        m.thumb.translation = [x, y]
    else
        m.thumb.visible = false
    end if
end sub

sub onTickMarksChanged()
    m.top.ticks.removeChildrenIndex(m.top.ticks.getChildCount(), 0)
    range = m.top.maxValue - m.top.minValue
    if range > 0 then
        for each tick in m.top.tickMarks
            tickValue = tick - m.top.minValud
            location = tickValue / range
            x = (m.top.width - (2 * m.top.padding)) + m.top.padding
            y = m.top.padding
            rect = m.ticks.createChild("Rectangle")
            rect.color = m.top.tickColor
            rect.translation = [x, y]
            rect.width = 1
            rect.height = m.top.height - (2 * m.top.padding)
        next
    end if
end sub
