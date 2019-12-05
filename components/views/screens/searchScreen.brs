sub init()
    m.top.omnitureName = "/search/"
    m.top.omniturePageType = "search"
    m.top.omnitureSiteHier = "search"

    m.top.omnitureStateData = {
        searchEventStart: 1
        e48: 1
    }

    m.top.observeField("focusedChild", "onFocusChanged")

    m.menu = m.top.findNode("menu")
    m.menu.observeField("buttonSelected", "onMenuItemSelected")
    
    m.searchText = m.top.findNode("searchText")
    m.searchText.observeField("text", "onSearchTextChanged")

    m.keyboard = m.top.findNode("keyboard")
    m.keyboard.observeField("buttonSelected", "onKeyboardButtonSelected")

    m.backspace = m.top.findNode("backspace")
    m.space = m.top.findNode("space")

    m.grid = m.top.findNode("grid")
    m.grid.observeField("itemSelected", "onItemSelected")

    m.noResults = m.top.findNode("noResults")

    m.delayTimer = m.top.findNode("delayTimer")
    m.delayTimer.observeField("fire", "onDelayTimerFired")

    m.deviceInfo = createObject("roDeviceInfo")

    m.top.setFocus(true)
end sub

sub updateKeyboard(alpha as boolean)
    m.keyboard.removeChildrenIndex(m.keyboard.getChildCount(), 0)
    keys = "1234567890.,?!@#$%&"
    if alpha then
        keys = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    end if
    for i = 0 to keys.len() - 1
        key = keys.mid(i, 1)
        button = m.keyboard.createChild("KeyboardButton")
        button.text = key
    next
    if alpha then
        button = m.keyboard.createChild("KeyboardButton")
        button.id = "numbers"
        button.text = "123&"
        button.width = 175
    else
        button = m.keyboard.createChild("KeyboardButton")
        button.id = "letters"
        button.text = "ABC"
        button.width = 175
    end if
    m.keyboard.appendChild(m.backspace)
    m.keyboard.appendChild(m.space)
    m.keyboard.buttonFocused = 0
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        hideSpinner()
        updateKeyboard(true)
        m.keyboard.setFocus(true)
        setGlobalField("ignoreBack",false)
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    '?"SearchScreen.onKeyEvent: ";key,press
    if press then
        if m.keyboard.isInFocusChain() then
            if key.inStr("Lit_") = 0 then
                updateSearchText(key.mid(4))
                return true
            else if key = "backspace" or key = "replay" then
                updateSearchText("backspace")
                return true
            end if
        end if
        if key = "down" then
            if m.menu.isInFocusChain() then
                m.keyboard.setFocus(true)
                return true
            else if m.keyboard.isInFocusChain() then
                if m.grid.visible then
                    m.grid.setFocus(true)
                    return true
                end if
            end if
        else if key = "up" then
            if m.keyboard.isInFocusChain() then
                m.menu.setFocus(true)
                return true
            else if m.grid.hasFocus() then
                m.keyboard.setFocus(true)
                return true
            end if
        else if key = "options" then
        end if
    end if
    return false
end function

sub onKeyboardButtonSelected()
    key = m.keyboard.getChild(m.keyboard.buttonSelected)
    if key.id = "letters" then
        updateKeyboard(true)
        m.keyboard.setFocus(true)
    else if key.id = "numbers" then
        updateKeyboard(false)
        m.keyboard.setFocus(true)
    else if key.id = "space" then
        updateSearchText(" ")
    else if key.id = "backspace" then
        updateSearchText("backspace")
    else
        updateSearchText(key.text)
    end if
end sub

sub updateSearchText(key as string)
    if key = "backspace" then
        if m.searchText.text.len() > 0 then
            m.searchText.text = m.searchText.text.mid(0, m.searchText.text.len() - 1)
        end if
    else
        m.searchText.text = m.searchText.text + key
    end if
end sub

sub onItemSelected(nodeEvent as object)
    grid = nodeEvent.getRoSGNode()
    if grid <> invalid then
        selected = nodeEvent.getData()
        item = grid.content.getChild(selected)
        if item <> invalid then
            omnitureData = getOmnitureData(grid.content, selected)
            omnitureData["searchTerm"] = lCase(m.searchText.text)
            omnitureData.v41 = lCase(m.searchText.text)
            omnitureData["searchEventComplete"] = 1
            omnitureData.e49 = 1
            trackScreenAction("trackSearchResult", omnitureData)
            m.top.itemSelected = item
        end if
    end if
end sub

sub onMenuItemSelected(nodeEvent as object)
    selection=nodeEvent.getData()
    if selection = "search" then
        m.keyboard.setFocus(true)
        m.lastFocus = m.keyboard
    else
        m.top.menuItemSelected = selection
    end if
end sub

sub onSearchTextChanged(nodeEvent as object)
    text = nodeEvent.getData()
    stopSearch()
    if not isNullOrEmpty(text) then
        ' Delay before initiating the search, so we don't
        ' send too many requests to the server while the
        ' user is still entering search text
        m.delayTimer.control = "start"
    else
        m.noResults.visible = false
        m.grid.visible = false
    end if
end sub

sub onDelayTimerFired(nodeEvent as object)
    if m.deviceInfo.timeSinceLastKeypress() > 0 then
        if not isNullOrEmpty(m.searchText.text.trim()) then
            search(m.searchText.text)
        end if
    else
        ' The user is still navigating the screen, so restart
        ' the timer
        m.delayTimer.control = "start"
    end if
end sub

sub onResultsLoaded(nodeEvent as object)
    stopSearch()
    results = nodeEvent.getData()
    m.grid.content = results
    if results = invalid or results.getChildCount() = 0 then
        m.grid.visible = false
        if not isNullOrEmpty(m.searchText.text.trim()) then
            m.noResults.visible = true
            omnitureData = getOmnitureData(results, 0)
            omnitureData["searchTerm"] = lCase(m.searchText.text)
            omnitureData.v41 = lCase(m.searchText.text)
            trackScreenAction("trackNoSearchResult", omnitureData)
        else
            m.noResults.visible = false
        end if
    else
        m.grid.visible = true
    end if
end sub

sub search(searchTerm as string)
    stopSearch()
    m.searchTask = createObject("roSGNode", "LoadSearchResultsTask")
    m.searchTask.observeField("results", "onResultsLoaded")
    m.searchTask.searchTerm = searchTerm
    m.searchTask.control = "run"
end sub

sub stopSearch()
    m.delayTimer.control = "stop"
    if m.searchTask <> invalid then
        m.searchTask.control = "stop"
        m.searchTask.unobserveField("results")
        m.searchTask = invalid
    end if
end sub
