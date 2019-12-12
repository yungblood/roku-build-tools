sub init()
    m.top.focusable = true
    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.observeField("text", "onTextChanged")
    
    m.label = m.top.findNode("label")
    m.focus = m.top.findNode("focus")
end sub

sub onFocusChanged(nodeEvent as object)
    updateFocus(m.top.hasFocus())
end sub

sub onHighlightedChanged(nodeEvent as object)
    updateHighlight(nodeEvent.getData())
end sub

sub onCategoryChanged(nodeEvent as object)
    category = nodeEvent.getData()
    m.top.text = category.title
end sub

sub onTextChanged(nodeEvent as object)
    ' Force focus/highlight states to ensure size is calculated properly
    updateFocus(true)
    updateFocus(m.top.hasFocus())
    updateHighlight(true)
    updateHighlight(m.top.highlighted)
end sub

sub updateFocus(focused as boolean)
    if focused then
        boundingRect = m.label.boundingRect()
        m.focus.translation = [0, boundingRect.height + 6]
        m.focus.width = boundingRect.width
        m.focus.visible = true
        m.label.opacity = 1
    else
        m.focus.visible = false
        updateHighlight(m.top.highlighted)
    end if
end sub

sub updateHighlight(highlighted as boolean)
    if highlighted then
        m.label.opacity = 1
        m.label.weight = "bold"
 
        ' update the focus width to the bold font
        boundingRect = m.label.boundingRect()
        m.focus.width = boundingRect.width
    else
        m.label.opacity = .75
        m.label.weight = "regular"

        ' update the focus width to the regular font
        boundingRect = m.label.boundingRect()
        m.focus.width = boundingRect.width
    end if
end sub
