sub init()
    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.textbox = m.top.findNode("textbox")
    m.letters = m.top.findNode("letters")
    m.letters.observeField("itemSelected", "onKeySelected")
    m.numbers = m.top.findNode("numbers")
    m.numbers.observeField("itemSelected", "onKeySelected")
    
    m.buttonFont = m.top.findNode("buttonFont")
    
    m.initialized = false
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        if key = "down" then
            if m.letters.isInFocusChain() then
                m.numbers.setFocus(true)
                'm.numbers.jumpToIndex = 0
                return true
            end if
        else if key = "up" then
            if m.numbers.isInFocusChain() then
                m.letters.setFocus(true)
                'm.letters.jumpToIndex = 0
                return true
            end if
        end if
    end if
    return false
end function

sub onFocusChanged()
    initializeKeys()
    if m.top.hasFocus() then
        m.letters.setFocus(true)
    end if
end sub

sub onKeySelected(nodeEvent as object)
    keyboard = nodeEvent.getRoSGNode()
    key = keyboard.getChild(nodeEvent.getData())
    if key.id = "space" then
        m.textbox.text = m.textbox.text + " "
    else if key.id = "backspace" then
        m.textbox.text = m.textbox.text.mid(0, m.textbox.text.len() - 1)
    else
        m.textbox.text = m.textbox.text + key.text
    end if
end sub

sub initializeKeys()
    if not m.initialized then
        m.letters.itemSpacings = [m.top.keySpacing]
        m.numbers.itemSpacings = [m.top.keySpacing]

        keys = m.top.letters
        m.letters.removeChildrenIndex(m.letters.getChildCount(), 0)
        for i = 0 to keys.len() - 1
            m.letters.appendChild(createKey(keys.mid(i, 1)))
        next

        key = createKey("", "space")
        key.foregroundUri = "pkg:/components/framework/widgets/keyboards/images/icon_space_fhd.png"
        key.foregroundBlendColor = m.top.keyTextColor
        key.foregroundImageWidth = 38
        key.foregroundImageHeight = 28
        key.focusedForegroundUri = key.foregroundUri
        key.focusedForegroundBlendColor = m.top.keyFocusedTextColor
        key.focusedForegroundImageWidth = 38
        key.focusedForegroundImageHeight = 28
        key.width = 68
        m.letters.appendChild(key)
        
        key = createKey("", "backspace")
        key.foregroundUri = "pkg:/components/framework/widgets/keyboards/images/icon_backspace_fhd.png"
        key.foregroundBlendColor = m.top.keyTextColor
        key.foregroundImageWidth = 38
        key.foregroundImageHeight = 28
        key.focusedForegroundUri = key.foregroundUri
        key.focusedForegroundBlendColor = m.top.keyFocusedTextColor
        key.focusedForegroundImageWidth = 38
        key.focusedForegroundImageHeight = 28
        key.width = 68
        m.letters.appendChild(key)

        keys = m.top.numbers
        m.numbers.removeChildrenIndex(m.numbers.getChildCount(), 0)
        for i = 0 to keys.len() - 1
            m.numbers.appendChild(createKey(keys.mid(i, 1)))
        next
        
        m.textbox.width = m.letters.boundingRect().width
        m.initialized = true
    end if
end sub

function createKey(text as string, id = "" as string) as object
    key = createObject("roSGNode", "LabelButton")
    key.text = text
    key.id = id
    key.font = m.top.keyFont
    key.backgroundColor = m.top.keyBackgroundColor
    key.focusedBackgroundColor = m.top.keyFocusedBackgroundColor
    key.textColor = m.top.keyTextColor
    key.focusedTextColor = m.top.keyFocusedTextColor
    key.width = m.top.keyWidth
    key.height = m.top.keyHeight
    key.processKeyEvents = false
    
    return key
end function

