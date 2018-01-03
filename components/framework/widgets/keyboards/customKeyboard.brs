sub init()
    ?"initializing CustomKeyboard"
    m.keyboard = m.top.findNode("keyboard")
    m.keyboard.observeField("itemFocused", "onItemFocused")
    m.keyboard.observeField("itemUnfocused", "onItemUnfocused")
    m.keyboard.observeField("itemSelected", "onItemSelected")
    
    m.top.observeField("focusedChild", "onFocusChanged")

    'setKeyboard("Alpha")
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    ?"CustomKeyboard.onKeyEvent", key, press
    if press then
        if m.top.wrap and (key = "right" or key = "left") then
            delta = 0
            i = 1
            while i < m.top.numColumns 
                current = m.keyboard.content.getChild(m.keyboard.itemFocused + delta)
                i += current.w
                if key = "right" then
                    delta--
                else
                    delta++
                end if
                ?delta
            end while
            newIndex = m.keyboard.itemFocused + delta
            if newIndex < 0 then
                newIndex = 0
            else if newIndex >= m.keyboard.content.getChildCount() then
                newIndex = m.keyboard.content.getChildCount() - 1
            end if 
            m.keyboard.jumpToItem = newIndex
            return true
        end if
    end if
    return false
end function

sub onFocusChanged()
    if m.top.hasFocus() then
        m.keyboard.setFocus(true)
    end if
end sub

sub setKeyboard(keyboardID as string)
    m.currentKeyboard = keyboardID
    currentFocus = m.keyboard.itemFocused
    keyOffset = 0
    ' Find the new focus index based on current key widths
    if currentFocus <> invalid and currentFocus > -1 then
        for i = 0 to currentFocus - 1
            key = m.keyboard.content.getChild(i)
            if key <> invalid then
                keyOffset = keyOffset + key.w
            end if
        next
    end if
    keys = getKeyboardContent(keyboardID)
    m.keyboard.content = keys
    if keyOffset > 0 then
        newIndex = 0
        newOffset = 0
        for i = 0 to m.keyboard.content.getChildCount() - 1
            key = m.keyboard.content.getChild(i)
            if key <> invalid then
                newOffset = newOffset + key.w
            end if
            if newOffset > keyOffset then
                newIndex = i
                exit for
            end if
        next
        m.keyboard.jumpToItem = newIndex
    end if
    if m.top.disabledKeys.Count() > 0 then
        onDisabledKeysChanged()
    end if
end sub

sub onKeyboardChanged()
    if m.top.currentKeyboard <> m.currentKeyboard then
        setKeyboard(m.top.currentKeyboard)
    end if
end sub

sub onDisabledKeysChanged()
    if m.keyboard.content <> invalid then
        for i = 0 to m.keyboard.content.getChildCount() - 1
            key = m.keyboard.content.getChild(i)
            if m.top.disabledKeys.Count() = 0 then
                key.disabled = false
            else
                match = false
                for Each disabledKey In m.top.disabledKeys
                    if key.id = disabledKey then
                        key.disabled = true
                        match = true
                        exit for
                    end if
                next
                if Not match then
                    key.disabled = false
                end if
            end if
        next
    end if
end sub

sub onAlphaKeysChanged()
    if m.currentKeyboard = "Alpha" then
        setKeyboard("Alpha")
    end if
end sub

sub onUpperAlphaKeysChanged()
    if m.currentKeyboard = "UpperAlpha" then
        setKeyboard("UpperAlpha")
    end if
end sub

sub onSymbolsKeysChanged()
    if m.currentKeyboard = "Symbols" then
        setKeyboard("Symbols")
    end if
end sub

sub onUpperSymbolsKeysChanged()
    if m.currentKeyboard = "UpperSymbols" then
        setKeyboard("UpperSymbols")
    end if
end sub

sub onSpecialKeysChanged()
    if m.currentKeyboard = "Special" then
        setKeyboard("Special")
    end if
end sub

sub onUpperSpecialKeysChanged()
    if m.currentKeyboard = "UpperSpecial" then
        setKeyboard("UpperSpecial")
    end if
end sub

sub onItemFocused()
    if m.keyboard.content = invalid then
        setKeyboard("Alpha")
    end if
    if m.previousFocus <> invalid and m.previousFocus <> m.keyboard.itemFocused then
        previousKey = m.keyboard.content.getChild(m.previousFocus)
        if previousKey <> invalid then
            previousKey.focused = false
        end if
    end if
    key = m.keyboard.content.getChild(m.keyboard.itemFocused)
    if key <> invalid then
        ?"focused: ";key.id
        key.focused = true
        m.previousFocus = m.keyboard.itemFocused
    end if
end sub

sub onItemUnfocused()
    if m.keyboard.content = invalid then
        setKeyboard("Alpha")
    end if
    key = m.keyboard.content.getChild(m.keyboard.itemUnfocused)
    if key <> invalid and key.w > 1 then
        ?"unfocused: ";key.id
        key.focused = false
    end if
end sub

sub onItemSelected()
    ?"onItemSelected: ";m.keyboard.itemSelected
    key = m.keyboard.content.getChild(m.keyboard.itemSelected)
    if key <> invalid then
        if Not key.disabled then
            m.top.keyHandled = false
            m.top.keySelected = key.id
            if Not m.top.keyHandled then
                if key.id = "DONE" then
                else if key.id = "CLEAR" then
                    m.top.text = ""
                else if key.id = "ALPHA" then
                    setKeyboard("Alpha")
                else if key.id = "UPPERALPHA" then
                    setKeyboard("UpperAlpha")
                else if key.id = "SYMBOLS" then
                    setKeyboard("Symbols")
                else if key.id = "UPPERSYMBOLS" then
                    setKeyboard("UpperSymbols")
                else if key.id = "SPECIALS" then
                    setKeyboard("Special")
                else if key.id = "UPPERSPECIALS" then
                    setKeyboard("UpperSpecial")
                else if key.id = "SPACE" then
                    m.top.text = m.top.text + " "
                else if key.id = "BACKSPACE" then
                    m.top.text = m.top.text.Mid(0, m.top.text.Len() - 1)
                else
                    m.top.text = m.top.text + key.text
                end if
            end if
            ?"Text: """;m.top.text;""""
        end if
    end if
end sub

function getKeyboardContent(keyboardID as string) as object
    timer = CreateObject("roTimespan")
    keysID = LCase(keyboardID.Mid(0, 1)) + keyboardID.Mid(1) + "Keys"
    keys = m.top.getField(keysID)
    content = CreateObject("roSGNode", "ContentNode")
    if keys <> invalid then
        specialRegex = CreateObject("roRegex", "{{(.*?)(?:,(\d))?}}", "i")
        x = 0
        for i = 0 to keys.Len() - 1
            addKey = true
            text = keys.Mid(i, 1)
            id = text
            width = 1
            iconUri = ""
            font = m.top.keyFont
            if text = "{" then
                if m.top.controlKeyFont <> invalid then
                    font = m.top.controlKeyFont
                end if
                if keys.Mid(i + 1, 1) = "{" then
                    closeBrackets = keys.InStr(i, "}}")
                    special = keys.Mid(i, closeBrackets + 2 - i)
                    matches = specialRegex.Match(special)
                    if matches.Count() > 0 then
                        id = matches[1]
                        if matches.Count() > 2 then
                            width = matches[2].ToInt()
                        end if
                        if width = 0 then
                            width = 1
                        end if
                        if id = "SPACE" then
                            text = m.top.spaceText
                            iconUri = m.top.spaceIconUri
                        else if id = "BACKSPACE" then
                            text = m.top.backspaceText
                            iconUri = m.top.backspaceIconUri
                        else if id = "ALPHA" then
                            text = m.top.alphaText
                            iconUri = m.top.alphaIconUri
                        else if id = "UPPERALPHA" then
                            text = m.top.upperAlphaText
                            iconUri = m.top.upperAlphaIconUri
                        else if id = "SYMBOLS" then
                            text = m.top.symbolsText
                            iconUri = m.top.symbolsIconUri
                        else if id = "UPPERSYMBOLS" then
                            text = m.top.upperSymbolsText
                            iconUri = m.top.upperSymbolsIconUri
                        else if id = "SPECIALS" then
                            text = m.top.specialText
                            iconUri = m.top.specialIconUri
                        else if id = "UPPERSPECIALS" then
                            text = m.top.upperSpecialText
                            iconUri = m.top.upperSpecialIconUri
                        else if id = "CLEAR" then
                            text = "Clear"
                        else if id = "DONE" then
                            text = "Done"
                        else
                            text = id
                        end if
                    else
                        addKey = false
                    end if
                    i = i + special.Len() - 1
                end if
            end if
            if addKey then
                node = CreateObject("roSGNode", "CustomKeyboardButtonContentNode")
                node.id = id
                if font <> invalid then
                    node.font = font
                end if
                node.text = text
                node.iconUri = iconUri
                node.backgroundUri = m.top.keyBackgroundUri
                node.focusedBackgroundUri = m.top.keyFocusedBackgroundUri
                node.backgroundColor = m.top.keyBackgroundColor
                node.focusedBackgroundColor = m.top.keyFocusedBackgroundColor
                node.focused = false
                node.disabled = false
                node.x = x Mod m.keyboard.numColumns
                node.y = int(x / m.keyboard.numColumns)
                node.w = width
                node.h = 1
                content.AppendChild(node)

                x = x + width
            end if
        next
    end if
    ?"getKeyboardContent:";timer.TotalMilliseconds()
    m.top.currentKeyboard = keyboardID
    return content
end function
