sub init()
    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.backgroundRect = m.top.findNode("backgroundRect")
    m.background = m.top.findNode("background")
    m.focusedBackground = m.top.findNode("focusedBackground")
    m.content = m.top.findNode("content")
    
    m.promo = m.top.findNode("promo")
    m.title = m.top.findNode("title")
    m.subtitle = m.top.findNode("subtitle")
    m.cta = m.top.findNode("cta")
    m.disclaimer = m.top.findNode("disclaimer")
    
    m.focusForeground = "0xffffffff"
    m.foreground = "0xbab9b9ff"
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if m.top.processKeyEvents then
        if press then
            if key = "OK" then
                m.top.buttonSelected = true
                return true
            end if
        end if
    end if
    return false
end function

sub onFocusChanged()
    m.background.visible = not m.top.hasFocus()
    m.focusedBackground.visible = m.top.hasFocus()
    m.promo.visible = m.top.hasFocus()
    
    if m.top.hasFocus() then
        m.top.tts = (m.top.promo + " " + m.top.title + " " + m.top.cta + " " + m.top.subtitle + " " + m.top.disclaimer).trim()
        m.subtitle.color = m.focusForeground
        m.cta.color = m.focusForeground
        m.disclaimer.color = m.focusForeground
    else
        m.subtitle.color = m.foreground
        m.cta.color = m.foreground
        m.disclaimer.color = m.foreground
    end if
end sub

sub updateLayout()
    if m.top.width > 0 and m.top.height > 0 then
        m.backgroundRect.width = m.top.width
        m.backgroundRect.height = m.top.height
        m.background.width = m.top.width
        m.background.height = m.top.height
        m.focusedBackground.width = m.top.width
        m.focusedBackground.height = m.top.height
        m.content.translation = [m.top.width / 2, m.top.height / 2]
        
        m.promo.width = m.top.width
        m.title.width = m.top.width - 70
        m.subtitle.width = m.top.width - 70
        m.cta.width = m.top.width - 140

        m.disclaimer.width = m.top.width - 70
        m.disclaimer.translation = [35, m.top.height - 80]
    end if
end sub

sub onUpsellInfoChanged()
    content = m.top.upsellInfo
    m.top.title = content.message1
    m.top.subtitle = content.message2
    if not isNullOrEmpty(content.message3) then
        'm.top.subtitle = m.top.subtitle + chr(10) + chr(10) + content.message3
        m.top.disclaimer = content.message3
    end if
    m.top.cta = content.callToAction
    if content.disabled = true then
        m.top.disabled = true
    end if
end sub
