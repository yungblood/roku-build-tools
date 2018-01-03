sub init()
    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.focusable = true
    
    m.content = m.top.findNode("content")
    m.name = m.top.findNode("name")
    m.level = m.top.findNode("level")
    
    m.buttons = m.top.findNode("buttons")
    m.buttons.observeField("buttonSelected", "onButtonSelected")
    
    m.signIn = m.top.findNode("signIn")
    m.freeTrial = m.top.findNode("freeTrial")
    m.upgrade = m.top.findNode("upgrade")
    m.manageAccount = m.top.findNode("manageAccount")
    m.signOut = m.top.findNode("signOut")
    
    m.global.observeField("user", "updateContent")
    updateContent()
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        m.buttons.setFocus(true)
    end if
end sub

sub updateContent()
    m.content.insertChild(m.level, 0)
    m.content.insertChild(m.name, 0)
    m.buttons.appendChild(m.manageAccount)
    m.buttons.appendChild(m.upgrade)
    m.buttons.appendChild(m.signOut)
    m.buttons.appendChild(m.freeTrial)
    m.buttons.appendChild(m.signIn)
    user = m.global.user
    if user <> invalid and user.status <> "ANONYMOUS" then
        m.name.value = user.fullName
        m.level.value = user.packageName
        if not user.canUpgrade then
            m.buttons.removeChild(m.upgrade)
        end if
        if not user.canDowngrade then
            m.buttons.removeChild(m.manageAccount)
        end if
        m.buttons.removeChild(m.freeTrial)
        m.buttons.removeChild(m.signIn)
    else
        m.content.removeChild(m.name)
        m.content.removeChild(m.level)
        m.buttons.removeChild(m.manageAccount)
        m.buttons.removeChild(m.upgrade)
        m.buttons.removeChild(m.signOut)
    end if
end sub

sub onButtonSelected(nodeEvent as object)
    button = m.buttons.getChild(m.buttons.buttonSelected)
    if button <> invalid then
        m.top.buttonSelected = button.id
    end if
end sub