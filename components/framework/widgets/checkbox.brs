sub init()
    m.background = m.top.findNode("background")
    m.backgroundImage = m.top.findNode("backgroundImage")
    m.controls = m.top.findNode("controls")
    m.label = m.top.findNode("label")
    m.checkbox = m.top.findNode("checkbox")
    m.checkLabel = m.top.findNode("checkLabel")
    m.backgroundFocused = m.top.findNode("backgroundFocused")
    m.backgroundImageFocused = m.top.findNode("backgroundImageFocused")
    m.controlsFocused = m.top.findNode("controlsFocused")
    m.labelFocused = m.top.findNode("labelFocused")
    m.checkboxFocused = m.top.findNode("checkboxFocused")
    m.checkLabelFocused = m.top.findNode("checkLabelFocused")
    
    m.top.observeField("focusedChild", "onFocusChanged")
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    ' Only process key events if we're not in a grid
    if not m.top.disabled then
        if press then
            key = LCase(key)
            if key = "ok" then
                if m.top.autoToggle then
                    m.top.checked = not m.top.checked
                end if
                m.top.buttonSelected = true
                return true
            end if
        end if
    end if
    return false
end function
            
sub updateLayout()
    width = m.top.width
    height = m.top.height

    boundingRect = m.controls.boundingRect()

    if width = 0 then
        width = boundingRect.width + m.top.padding * 2
    else
        m.checkLabel.width = width - (m.checkbox.boundingRect().width + m.label.boundingRect().width) - m.top.padding * 2
        m.checkLabelFocused.width = width - (m.checkboxFocused.boundingRect().width + m.labelFocused.boundingRect().width) - m.top.padding * 2
    end if
    if height = 0 then
        height = boundingRect.height + m.top.padding * 2
    end if
    ?width
    if width > 0 and height > 0 then
        m.background.width = width
        m.background.height = height
        m.backgroundImage.width = width
        m.backgroundImage.height = height
'        m.label.width = width
'        m.label.height = height
        m.backgroundFocused.width = width
        m.backgroundFocused.height = height
        m.backgroundImageFocused.width = width
        m.backgroundImageFocused.height = height
'        m.labelFocused.width = width
'        m.labelFocused.height = height

        m.controls.translation = [m.top.padding, height / 2]
        m.controlsFocused.translation = [m.top.padding, height / 2]
    end if
end sub

sub onFontChanged()
    m.label.font = m.top.font
    if m.top.focusedFont = invalid then
        m.labelFocused.font = m.top.font
    end if
    updateLayout()
end sub

sub onFocusedFontChanged()
    m.labelFocused.font = m.top.focusedFont
    updateLayout()
end sub

sub onTextChanged()
    m.label.text = m.top.text
    m.labelFocused.text = m.top.text
    updateLayout()
end sub

sub updateIcons()
    if m.top.checked then
        m.checkbox.uri = m.top.checkedIconUri
        m.checkboxFocused.uri = m.top.focusedCheckedIconUri
        m.checkLabel.text = m.top.checkedText
        m.checkLabelFocused.text = m.top.checkedText
    else
        m.checkbox.uri = m.top.uncheckedIconUri
        m.checkboxFocused.uri = m.top.focusedUncheckedIconUri
        m.checkLabel.text = m.top.uncheckedText
        m.checkLabelFocused.text = m.top.uncheckedText
    end if
    updateLayout()
end sub

sub onCheckChanged()
    updateIcons()
end sub

sub onCheckPaddingChanged()
    m.controls.itemSpacings = [m.top.checkPadding, 0]
    m.controlsFocused.itemSpacings = [m.top.checkPadding, 0]
    updateLayout()
end sub

sub onItemContentChanged()
    m.top.text = m.top.itemContent.title
end sub

sub onDisabledChanged()
    if m.top.disabled then
        m.top.opacity = m.top.disabledOpacity
    else
        m.top.opacity = 1
    end if
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.backgroundFocused.opacity = 1
        m.backgroundImageFocused.opacity = 1
        m.controlsFocused.opacity = 1
        m.background.opacity = 0
        m.backgroundImage.opacity = 0
        m.controls.opacity = 0
    else
        m.background.opacity = 1
        m.backgroundImage.opacity = 1
        m.controls.opacity = 1
        m.backgroundFocused.opacity = 0
        m.backgroundImageFocused.opacity = 0
        m.controlsFocused.opacity = 0
    end if
    updateLayout()
end sub
