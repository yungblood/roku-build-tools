sub init()
    m.background = m.top.findNode("background")
    m.backgroundImage = m.top.findNode("backgroundImage")
    m.foregroundImage = m.top.findNode("foregroundImage")
    m.label = m.top.findNode("label")
    m.backgroundFocused = m.top.findNode("backgroundFocused")
    m.backgroundImageFocused = m.top.findNode("backgroundImageFocused")
    m.foregroundImageFocused = m.top.findNode("foregroundImageFocused")
    m.labelFocused = m.top.findNode("labelFocused")
    
    m.label.observeField("width", "onLabelWidthChanged")
    
    m.top.observeField("focusedChild", "onFocusChanged")
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    ' Only process key events if we're not in a grid
    if m.top.processKeyEvents and not m.top.gridHasFocus and not m.top.disabled then
        if press then
            key = LCase(key)
            if key = "ok" then
                m.top.buttonSelected = true
                return true
            end if
        end if
    end if
    return false
end function
            
sub onLayoutChanged()
    if m.top.width > 0 and m.top.height > 0 then
        if m.top.vertAlignment = "bottom" then
            m.label.translation = [m.top.padding, 0]
            m.label.width = m.top.width - m.top.padding * 2
            m.label.height = m.top.height - m.top.padding
            m.labelFocused.translation = [m.top.padding, 0]
            m.labelFocused.width = m.top.width - m.top.padding * 2
            m.labelFocused.height = m.top.height - m.top.padding
        else
            m.label.translation = [m.top.padding, m.top.padding]
            m.label.width = m.top.width - m.top.padding * 2
            m.label.height = m.top.height
            m.labelFocused.translation = [m.top.padding, m.top.padding]
            m.labelFocused.width = m.top.width - m.top.padding * 2
            m.labelFocused.height = m.top.height
        end if
        
        m.background.width = m.top.width
        m.background.height = m.top.height
        m.backgroundFocused.width = m.top.width
        m.backgroundFocused.height = m.top.height
        if m.backgroundImage.width > 0 and m.backgroundImage.height > 0 then
            m.backgroundImage.translation = [(m.top.width - m.backgroundImage.width) \ 2, (m.top.height - m.backgroundImage.height) \ 2]
        else
            m.backgroundImage.width = m.top.width
            m.backgroundImage.height = m.top.height
        end if
        if m.backgroundImageFocused.width > 0 and m.backgroundImageFocused.height > 0 then
            m.backgroundImageFocused.translation = [(m.top.width - m.backgroundImageFocused.width) \ 2, (m.top.height - m.backgroundImageFocused.height) \ 2]
        else
            m.backgroundImageFocused.width = m.top.width
            m.backgroundImageFocused.height = m.top.height
        end if
        
        if m.foregroundImage.width > 0 and m.foregroundImage.height > 0 then
            m.foregroundImage.translation = [(m.top.width - m.foregroundImage.width) \ 2, (m.top.height - m.foregroundImage.height) \ 2]
        else
            m.foregroundImage.width = m.top.width
            m.foregroundImage.height = m.top.height
        end if
        if m.foregroundImageFocused.width > 0 and m.foregroundImageFocused.height > 0 then
            m.foregroundImageFocused.translation = [(m.top.width - m.foregroundImageFocused.width) \ 2, (m.top.height - m.foregroundImageFocused.height) \ 2]
        else
            m.foregroundImageFocused.width = m.top.width
            m.foregroundImageFocused.height = m.top.height
        end if
    end if
end sub

sub onLabelWidthChanged()
    m.background.width = m.label.width + (m.top.padding * 2)
    m.backgroundImage.width = m.label.width + (m.top.padding * 2)
    if m.top.foregroundImageWidth = 0 then
        m.foregroundImage.width = m.label.width + (m.top.padding * 2)
    end if
    m.backgroundFocused.width = m.label.width + (m.top.padding * 2)
    m.backgroundImageFocused.width = m.label.width + (m.top.padding * 2)
    if m.top.focusedForegroundImageWidth = 0 then
        m.foregroundImageFocused.width = m.label.width + (m.top.padding * 2)
    end if
end sub

sub onFontChanged()
    m.label.font = m.top.font
    if m.top.focusedFont = invalid then
        m.labelFocused.font = m.top.font
    end if
end sub

sub onFocusedFontChanged()
    m.labelFocused.font = m.top.focusedFont
end sub

sub onTextChanged()
    m.label.text = m.top.text
    m.labelFocused.text = m.top.text
    
    if m.top.width = 0 then
        m.top.width = m.label.boundingRect().width
    end if
end sub

sub onHorizAlignmentChanged()
    m.label.horizAlign = m.top.horizAlignment
    m.labelFocused.horizAlign = m.top.horizAlignment
    onLayoutChanged()
end sub

sub onVertAlignmentChanged()
    m.label.vertAlign = m.top.vertAlignment
    m.labelFocused.vertAlign = m.top.vertAlignment
    onLayoutChanged()
end sub

sub onItemContentChanged()
    m.top.text = m.top.itemContent.title
end sub

sub onDisabledChanged()
    if m.top.disabled then
        m.top.opacity = m.top.disabledOpacity
        if m.top.disabledBackgroundBlendColor <> -1 then
            m.enabledBackgroundBlendColor = m.backgroundImage.blendColor
            m.backgroundImage.blendColor = m.top.disabledBackgroundBlendColor
        end if
        if m.top.disabledTextColor <> -1 then
            m.enabledTextColor = m.label.color
            m.label.color = m.top.disabledTextColor
        end if
    else
        m.top.opacity = 1
        if m.enabledBackgroundBlendColor <> m.enabledBackgroundBlendColor then
            m.backgroundImage.blendColor = m.enabledBackgroundBlendColor
        end if
        if m.enabledTextColor <> invalid then
            m.label.color = m.enabledTextColor
        end if
    end if
end sub

sub onFocusPercentChanged()
    m.background.opacity = 1 - m.top.focusPercent
    m.backgroundImage.opacity = 1 - m.top.focusPercent
    m.foregroundImage.opacity = 1 - m.top.focusPercent
    m.label.opacity = 1 - m.top.focusPercent
    m.backgroundFocused.opacity = m.top.focusPercent
    m.backgroundImageFocused.opacity = m.top.focusPercent
    m.foregroundImageFocused.opacity = m.top.focusPercent
    m.labelFocused.opacity = m.top.focusPercent
end sub

sub onFocusChanged()
    if m.top.gridHasFocus then
        onFocusPercentChanged()
    else
        if m.top.hasFocus() or m.top.forceFocus then
            m.background.opacity = 0
            m.backgroundImage.opacity = 0
            m.foregroundImage.opacity = 0
            m.label.opacity = 0
            m.backgroundFocused.opacity = m.top.focusedOpacity
            m.backgroundImageFocused.opacity = m.top.focusedOpacity
            m.foregroundImageFocused.opacity = m.top.focusedOpacity
            m.labelFocused.opacity = m.top.focusedOpacity
        else
            m.background.opacity = m.top.normalOpacity
            m.backgroundImage.opacity = m.top.normalOpacity
            m.foregroundImage.opacity = m.top.normalOpacity
            m.label.opacity = m.top.normalOpacity
            m.backgroundFocused.opacity = 0
            m.backgroundImageFocused.opacity = 0
            m.foregroundImageFocused.opacity = 0
            m.labelFocused.opacity = 0
        end if
    end if
end sub
