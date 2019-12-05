sub init()
    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.observeField("content", "onContentLoaded")

    m.top.focusXOffset = [128]
    m.top.rowLabelOffset = [[128, 21]]
    m.top.itemComponentName = "GridTile"
    m.top.itemSize = [1920, 390]
    m.top.itemSpacing = [0, 40]

    m.top.rowItemSpacing = [[40, 0]]

    m.top.focusBitmapUri = "pkg:/images/ui/focus_grid_$$RES$$.9.png"
    m.top.vertFocusAnimationStyle = "fixedFocus"
    m.top.numRows = 3

    m.top.rowLabelFont = getThemeFont("deci", "bold")
    m.top.rowLabelColor = getThemeColor("milkyWay")

    m.top.showRowLabel = [false]
    m.top.drawFocusFeedback = false
    
    m.portraitSize = [244, 366]
    m.portraitHeight = 452
    m.landscapeSize = [386, 221]
    m.landscapeHeight = 390

    peekWidth = 120
    m.leftPeek = m.top.findNode("leftPeek")
    m.leftPeek.width = peekWidth
    m.leftPeek.height = 1920
    m.rightPeek = m.top.findNode("rightPeek")
    m.rightPeek.width = peekWidth
    m.rightPeek.height = 1920
    m.rightPeek.translation = [1920 - m.rightPeek.width, 0]

    m.peekAnimation = m.top.findNode("peekAnimation")
    m.leftPeekInterp = m.top.findNode("leftPeekInterp")
    m.rightPeekInterp = m.top.findNode("rightPeekInterp")
    
    m.top.rowTypes = ["landscape"]

    m.firstFade = true
end sub

sub onFocusChanged(nodeEvent as object)
    if m.top.hasFocus() then
        m.top.drawFocusFeedback = true
    end if
end sub

sub onContentLoaded(nodeEvent as object)
    m.top.showRowLabel = [true]
end sub

sub onRowTypesChanged(nodeEvent as object)
    rowTypes = nodeEvent.getData()
    
    rowItemSizes = []
    rowHeights = []
    for each rowType in rowTypes
        if lCase(rowType) = "portrait" then
            rowItemSizes.push(m.portraitSize)
            rowHeights.push(m.portraitHeight)
        else
            rowItemSizes.push(m.landscapeSize)
            rowHeights.push(m.landscapeHeight)
        end if
    next
    m.top.rowItemSize = rowItemSizes
    m.top.rowHeights = rowHeights
end sub

sub onPeekVisibleChanged(nodeEvent as object)
    visible = nodeEvent.getData()
    m.peekAnimation.control = "stop"
    if visible then
        ' the first fade in stutters badly, so delay
        ' for a short period to smooth it out
        if m.firstFade then
            m.peekAnimation.delay = .3
        end if
        m.leftPeekInterp.reverse = false
        m.rightPeekInterp.reverse = false
    else
        m.peekAnimation.delay = 0
        m.leftPeekInterp.reverse = true
        m.rightPeekInterp.reverse = true
    end if
    m.firstFade = false
    m.peekAnimation.control =  "start"
end sub
