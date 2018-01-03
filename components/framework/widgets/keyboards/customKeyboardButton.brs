sub init()
    m.background = m.top.findNode("background")
    m.focusedBackground = m.top.findNode("focusedBackground")
    m.backgroundRect = m.top.findNode("backgroundRect")
    m.focusedBackgroundRect = m.top.findNode("focusedBackgroundRect")
    m.text = m.top.findNode("text")
    m.icon = m.top.findNode("icon")
end sub

sub onItemContentChanged()
    m.top.text = m.top.itemContent.text
    m.top.iconUri = m.top.itemContent.iconUri
    if m.top.itemContent.backgroundUri <> "" then
        m.background.uri = m.top.itemContent.backgroundUri
        m.background.visible = true
    else
        m.background.visible = false
    end if
    if m.top.itemContent.focusedBackgroundUri <> "" then
        m.focusedBackground.uri = m.top.itemContent.focusedBackgroundUri
        m.focusedBackground.visible = true
    else
        m.focusedBackground.visible = false
    end if
    m.backgroundRect.color = m.top.itemContent.backgroundColor
    m.focusedBackgroundRect.color = m.top.itemContent.focusedBackgroundColor
    
    if m.top.itemContent.font <> invalid then
        m.text.font = m.top.itemContent.font
    end if

    m.top.itemContent.observeField("focused", "onItemFocusChanged")
    m.top.itemContent.observeField("disabled", "onItemDisabledChanged")
    onItemFocusChanged()
    onItemDisabledChanged()
end sub

sub onItemFocusChanged()
    if m.top.gridHasFocus and m.top.itemContent.focused then
        m.focusedBackgroundRect.opacity = 1
        m.focusedBackground.opacity = 1
        m.backgroundRect.opacity = 0
        m.background.opacity = 0
    else
        m.focusedBackground.opacity = 0
        m.focusedBackgroundRect.opacity = 0
        m.background.opacity = 1
        m.backgroundRect.opacity = 1
    end if
end sub

sub onItemDisabledChanged()
    if m.top.itemContent.disabled then
        m.top.opacity = .25
    else
        m.top.opacity = 1
    end if
end sub

sub onFocusChanged()
    if m.top.gridHasFocus then
        m.focusedBackground.opacity = m.top.focusPercent
        m.background.opacity = 1.0 - m.top.focusPercent
        m.focusedBackgroundRect.opacity = m.top.focusPercent
        m.backgroundRect.opacity = 1.0 - m.top.focusPercent
    else
        m.focusedBackground.opacity = 0
        m.focusedBackgroundRect.opacity = 0
        m.background.opacity = 1
        m.backgroundRect.opacity = 1
    end if
end sub

sub updateLayout()
    if m.top.height > 0 and m.top.width > 0 then
        m.background.width = m.top.width
        m.focusedBackground.width = m.top.width
        m.backgroundRect.width = m.top.width
        m.focusedBackgroundRect.width = m.top.width
        m.text.width = m.top.width
        m.icon.width = m.top.width
        m.background.height = m.top.height
        m.focusedBackground.height = m.top.height
        m.backgroundRect.height = m.top.height
        m.focusedBackgroundRect.height = m.top.height
        m.text.height = m.top.height
        m.icon.height = m.top.height
    end if
end sub