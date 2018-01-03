function init()
    m.top.visible = false
end function

sub onBaseContentChanged()
    if m.content = invalid or not m.content.isSameNode(m.top.content) then
        if m.content <> invalid then
            m.content.unobserveField("change")
        end if
        m.content = m.top.content
        if m.content <> invalid then
            m.content.observeField("change", "onBaseContentUpdated")
        end if

        resetFocus = m.top.isInFocusChain()
        if m.rowTitle <> invalid then
            m.rowTitle.text = m.content.title
        end if
        change = {
            operation: "setall"
            index1: 0
            index2: 0
        }
        if onContentUpdated <> invalid then
            onContentUpdated(change)
        end if
        if resetFocus then
            m.top.setFocus(true)
        end if
        m.top.visible = (m.content.getChildCount() > 0 or not m.top.hideIfEmpty)
    end if
end sub

sub onBaseContentUpdated(nodeEvent as object)
    if onContentUpdated <> invalid then
        change = nodeEvent.getData()
        ' HACK: in 7.6, Roku changed the way multiple adds and removes are
        '       reported, so we mimic the 7.5 way here, so we can support
        '       both firmware versions
        if change.operation = "add" then
            startIndex = change.index1
            if change.index2 > change.index1 then
                endIndex = change.index2
            else
                endIndex = startIndex
            end if
            for i = startIndex to endIndex
                adjustedChange = {
                    operation: change.operation
                    index1: i
                    index2: 0
                }
                onContentUpdated(adjustedChange)
            next
        else if change.operation = "remove" then
            startIndex = change.index2
            if change.index2 > change.index1 then
                endIndex = change.index1
            else
                endIndex = startIndex
            end if
            for i = startIndex to endIndex step -1
                adjustedChange = {
                    operation: change.operation
                    index1: i
                    index2: 0
                }
                onContentUpdated(adjustedChange)
            next
        else
            onContentUpdated(change)
        end if
    end if
    m.top.visible = (m.content.getChildCount() > 0 or not m.top.hideIfEmpty)
end sub
