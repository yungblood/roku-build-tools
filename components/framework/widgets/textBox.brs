sub init()
    m.background = m.top.findNode("background")
    m.focusedBackground = m.top.findNode("focusedBackground")
    m.backgroundRect = m.top.findNode("backgroundRect")
    m.focusedBackgroundRect = m.top.findNode("focusedBackgroundRect")
    m.hintLabel = m.top.findNode("hintLabel")
    m.focusedHintLabel = m.top.findNode("focusedHintLabel")
    m.label = m.top.findNode("label")
    m.focusedLabel = m.top.findNode("focusedLabel")
    m.maskTimer = m.top.findNode("maskTimer")
    m.maskTimer.observeField("fire", "onTimerFired")
    
    m.top.observeField("focusedChild", "onFocusChanged")
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    ' Only process key events if we're not in a grid
    if m.top.processKeyEvents and not m.top.disabled then
        if press then
            key = LCase(key)
            if key = "ok" then
                m.top.textboxSelected = true
                return true
            end if
        end if
    end if
    return false
end function

sub updateLayout()
    m.background.width = m.top.width
    m.focusedBackground.width = m.top.width
    m.backgroundRect.width = m.top.width
    m.focusedBackgroundRect.width = m.top.width
    m.hintLabel.width = m.top.width - (m.top.padding * 2)
    m.focusedHintLabel.width = m.top.width - (m.top.padding * 2)
    m.label.width = m.top.width - (m.top.padding * 2)
    m.focusedLabel.width = m.top.width - (m.top.padding * 2)
    
    m.background.height = m.top.height
    m.focusedBackground.height = m.top.height
    m.backgroundRect.height = m.top.height
    m.focusedBackgroundRect.height = m.top.height
    m.hintLabel.height = m.top.height
    m.focusedHintLabel.height = m.top.height
    m.label.height = m.top.height
    m.focusedLabel.height = m.top.height
    
    m.hintLabel.translation = [m.top.padding, 2]
    m.focusedHintLabel.translation = [m.top.padding, 2]
    m.label.translation = [m.top.padding, 2]
    m.focusedLabel.translation = [m.top.padding, 2]
end sub

sub onFocusChanged()
    m.background.visible = not m.top.hasFocus()
    m.focusedBackground.visible = m.top.hasFocus()
    m.backgroundRect.visible = not m.top.hasFocus()
    m.focusedBackgroundRect.visible = m.top.hasFocus()
    m.label.visible = not m.top.hasFocus()
    m.focusedLabel.visible = m.top.hasFocus()

    if m.top.text <> invalid and m.top.text.Len() > 0 and not m.top.alwaysShowHint then
        m.hintLabel.visible = false
        m.focusedHintLabel.visible = false
    else
        m.hintLabel.visible = not m.top.hasFocus()
        m.focusedHintLabel.visible = m.top.hasFocus()
    end if
    
    if m.focusedLabel.font = invalid then
        m.focusedLabel.font = m.label.font
    end if
    if m.focusedLabel.color = -1 then
        m.focusedLabel.color = m.label.color
    end if
    
    if m.focusedHintLabel.font = invalid then
        m.focusedHintLabel.font = m.hintLabel.font
    end if
    if m.focusedHintLabel.color = -1 then
        m.focusedHintLabel.color = m.hintLabel.color
    end if
end sub

sub onHorizAlignChanged()
    m.label.horizAlign = m.top.horizAlign
    m.focusedLabel.horizAlign = m.top.horizAlign
    if m.top.hintHorizAlign = "" then
        m.hintLabel.horizAlign = m.top.horizAlign
        m.focusedHintLabel.horizAlign = m.top.horizAlign
    end if
end sub

sub onVertAlignChanged()
    m.label.vertAlign = m.top.vertAlign
    m.focusedLabel.vertAlign = m.top.vertAlign
    if m.top.hintVertAlign = "" then
        m.hintLabel.vertAlign = m.top.vertAlign
        m.focusedHintLabel.vertAlign = m.top.vertAlign
    end if
end sub

sub onHintHorizAlignChanged()
    m.hintLabel.horizAlign = m.top.hintHorizAlign
    m.focusedHintLabel.horizAlign = m.top.hintHorizAlign
end sub

sub onHintVertAlignChanged()
    m.hintLabel.vertAlign = m.top.hintVertAlign
    m.focusedHintLabel.vertAlign = m.top.hintVertAlign
end sub

sub onDisabledChanged()
    if m.top.disabled then
        m.top.opacity = m.top.disabledOpacity
    else
        m.top.opacity = 1
    end if
end sub

sub onHintTextChanged()
    m.hintLabel.text = m.top.hintText
    m.focusedHintLabel.text = m.top.hintText
end sub

sub onTextChanged()
    if m.top.text <> invalid and m.top.text.Len() > 0 and not m.top.alwaysShowHint then
        m.hintLabel.visible = false
        m.focusedHintLabel.visible = false
    else
        m.hintLabel.visible = not m.top.hasFocus()
        m.focusedHintLabel.visible = m.top.hasFocus()
    end if
    if m.top.secureMode then
        setSecureText(false)
    else
        m.label.text = m.top.text
        m.focusedLabel.text = m.top.text
    end if
    
    m.top.isValid = isTextValid()
end sub

sub onSecureModeChanged()
    if m.top.secureMode then
        setSecureText(true)
    else
        m.label.text = m.top.text
        m.focusedLabel.text = m.top.text
    end if
end sub

sub onTimerFired()
    if m.top.secureMode then
        setSecureText(true)
    else
        m.label.text = m.top.text
        m.focusedLabel.text = m.top.text
    end if
end sub

sub setSecureText(maskAll = true As Boolean)
    if maskAll then
        m.label.text = stringI(m.top.text.Len(), &H2022)
        m.focusedLabel.text = stringI(m.top.text.Len(), &H2022)
    else
        m.label.text = stringI(m.top.text.Len() - 1, &H2022) + m.top.text.Mid(m.top.text.Len() - 1, 1)
        m.focusedLabel.text = stringI(m.top.text.Len() - 1, &H2022) + m.top.text.Mid(m.top.text.Len() - 1, 1)
        m.maskTimer.control = "start"
    end if
end sub

function isTextValid() as boolean
    if m.top.inputMask <> invalid and m.top.inputMask <> "" then
        if m.inputRegex = invalid then
            m.inputRegex = CreateObject("roRegex", m.top.inputMask, "")
        end if
        if m.inputRegex <> invalid then
            return m.inputRegex.isMatch(m.top.text)
        end if
    end if
    return true
end function
