sub init()
    m.leftWell = m.top.findNode("leftWell")
    m.well = m.top.findNode("well")
    m.rightWell = m.top.findNode("rightWell")
    m.leftProgress = m.top.findNode("leftProgress")
    m.progress = m.top.findNode("progress")
    m.rightProgress = m.top.findNode("rightProgress")
end sub

sub updateLayout()
    if m.top.width > 0 and m.top.height > 0 then
        m.leftWell.height = m.top.height
        m.well.height = m.top.height
        m.rightWell.height = m.top.height
        m.leftProgress.height = m.top.height
        m.progress.height = m.top.height
        m.rightProgress.height = m.top.height
        
        m.well.translation = [m.leftWell.width, 0]
        m.well.width = m.top.width - m.leftWell.width - m.rightWell.width
        m.rightWell.translation = [m.top.width - m.rightWell.width, 0]
        m.progress.translation = [m.leftProgress.width, 0]
        m.rightProgress.translation = [m.top.width - m.rightProgress.width, 0]
        
        updateProgress()
    end if
end sub

sub updateProgress()
    if m.top.maxValue > 0 then
        percent = m.top.value / m.top.maxValue
        if percent > 1 then
            percent = 1
        end if
        if percent > 0 then
            width = (m.top.width - m.leftProgress.width - m.rightProgress.width) * percent

            m.leftProgress.visible = true
            m.leftWell.visible = false
            m.progress.visible = true
            m.progress.width = width
            m.rightProgress.visible = (percent = 1)
            m.rightWell.visible = (percent < 1)
        else
            m.leftProgress.visible = false
            m.progress.visible = false
            m.rightProgress.visible = false
        end if
    else
        m.leftProgress.visible = false
        m.progress.visible = false
        m.rightProgress.visible = false
    end if
end sub