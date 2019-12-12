sub init()
    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.observeField("content", "onContentLoaded")

    m.top.itemComponentName = "PosterTile"
    m.top.numColumns = 5
    m.top.numRows = 3
    m.top.focusBitmapUri = "pkg:/images/ui/focus_grid_$$RES$$.9.png"
    m.top.vertFocusAnimationStyle = "fixedFocus"
    m.top.itemSpacing = [40, 40]
    m.top.itemSize = [244, 366]
    m.top.rowHeights = [366]
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        if key = "down" then
            ' HACK: the grid control won't animate to the last row if the focused
            '       item in the previous row doesn't have an item directly below
            '       it, so we detect that and animate to the last item instead
            itemCount = m.top.content.getChildCount()
            remainder = itemCount mod m.top.numColumns
            if remainder > 0 then
                focused = m.top.itemFocused
                if focused < itemCount - remainder and focused >= itemCount - m.top.numColumns then
                    scrollSpeed = m.top.scrollSpeed
                    m.top.scrollSpeed = 10
                    m.top.animateToItem = itemCount - 1
                    m.top.scrollSpeed = scrollSpeed
                    return true
                end if
            end if
        end if
    end if
    return false
end function

sub onFocusChanged(nodeEvent as object)
    if m.top.hasFocus() then
    end if
end sub
