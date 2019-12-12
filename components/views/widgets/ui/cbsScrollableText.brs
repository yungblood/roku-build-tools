sub init()
    m.top.observeField("focusedChild", "onFocusChanged")

    m.measure = m.top.findNode("measure")

    m.text = m.top.findNode("text")
    m.text.observeField("text", "onTextChanged")
    
    m.scrollArrows = m.top.findNode("scrollArrows")
    m.scrollArrows.observeField("buttonSelected", "onButtonSelected")
    m.scrollUp = m.top.findNode("scrollUp")
    m.scrollDown = m.top.findNode("scrollDown")
    
    m.scrollAnimation = m.top.findNode("scrollAnimation")
    m.scrollInterp = m.top.findNode("scrollInterp")
    
    m.animTarget = m.top.findNode("animTarget")
    m.animTarget.observeField("height", "onAnimationProgressChanged")
    
    m.scrollHeight = 0
    
    m.scrollPadding = 24
    m.scrollLine = 0

    m.scrollTop = 0
    m.newScrollTop = -1
end sub

sub onButtonSelected(nodeEvent as object)
    buttonIndex = nodeEvent.getData()
    button = m.scrollArrows.getChild(buttonIndex)
    if button.id = "scrollUp" then 
        updateScroll(m.scrollLine - m.top.scrollLines)
    else if button.id = "scrollDown" then
        updateScroll(m.scrollLine + m.top.scrollLines)
    end if
end sub

sub onFocusChanged(nodeEvent as object)
    if m.top.hasFocus() then
        m.scrollArrows.setFocus(true)
    end if
end sub

sub onStyleChanged(nodeEvent as object)
    style = nodeEvent.getData()
    m.measure.style = style
    m.text.style = style
end sub

sub onWeightChanged(nodeEvent as object)
    weight = nodeEvent.getData()
    m.measure.weight = weight
    m.text.weight = weight
end sub

sub onHeightChanged(nodeEvent as object)
    m.scrollHeight = (m.top.height - m.scrollUp.height - m.scrollPadding)
    updateScroll()
end sub

sub onTextChanged(nodeEvent as object)
    updateScroll()
end sub

sub onAnimationProgressChanged(nodeEvent as object)
    updateClippingRect(nodeEvent.getData())
end sub

sub updateClippingRect(scrollTop as float)
    m.text.clippingRect = [
        0
        scrollTop
        m.text.width
        m.scrollHeight
    ]
    m.text.translation = [0, 0 - scrollTop]
    m.scrollArrows.translation = [0, m.top.height - m.scrollUp.height]
    
    m.top.focusable = true
    boundingRect = m.text.boundingRect()
    if scrollTop = 0 then
        m.scrollUp.disabled = true
        m.scrollDown.disabled = false
        m.scrollArrows.jumpToButton = "scrollDown"
    else if scrollTop + m.scrollHeight = boundingRect.height and m.scrollHeight < boundingRect.height then
        m.scrollUp.disabled = false
        m.scrollDown.disabled = true
        m.scrollArrows.jumpToButton = "scrollUp"
    else
        m.scrollUp.disabled = false
        m.scrollDown.disabled = false
        m.top.focusable = false
    end if
    m.scrollTop = scrollTop
end sub

sub updateScroll(scrollLine = 0 as integer)
    measureRect = m.measure.boundingRect()
    boundingRect = m.text.boundingRect()
    lineCount = boundingRect.height / (measureRect.height + m.measure.lineSpacing)
    scrollLineCount = m.scrollHeight / (measureRect.height + m.measure.lineSpacing)
    if boundingRect.height > m.top.height then
        scrollDiff = boundingRect.height - m.scrollHeight
        newScrollTop = (measureRect.height + m.measure.lineSpacing) * scrollLine 'scrollDiff * scrollPercentage
        if newScrollTop <> m.newScrollTop then
            m.newScrollTop = newScrollTop
            if m.newScrollTop < 0 then
                m.newScrollTop = 0
                scrollLine = 0
            else if m.newScrollTop + m.scrollHeight > boundingRect.height then
                m.newScrollTop = boundingRect.height - m.scrollHeight
                scrollLine = lineCount - scrollLineCount
            end if
            if m.newScrollTop <> m.scrollTop then
                m.scrollInterp.keyValue = [m.scrollTop, m.newScrollTop]
                m.scrollAnimation.control = "start"
    
                m.scrollLine = scrollLine
            else
                updateClippingRect(m.scrollTop)
            end if
        else
            updateClippingRect(m.scrollTop)
        end if
        m.scrollArrows.visible = true
    else
        updateClippingRect(0)
        m.scrollArrows.visible = false
        m.top.focusable = false
    end if
end sub
