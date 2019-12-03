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
    m.searchTask = createObject("roSGNode", "LoadSearchResultsTask")
    m.searchTask.observeField("results", "onResultsLoaded")

    m.keyboard = m.top.findNode("keyboard")
    m.keyboard.observeField("buttonSelected", "onKeyboardButtonSelected")

    m.backspace = m.top.findNode("backspace")
    m.space = m.top.findNode("space")

    m.grid = m.top.findNode("grid")
    m.grid.observeField("itemSelected", "onItemSelected")

    m.noResults = m.top.findNode("noResults")

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
    ?"HomeScreen.onKeyEvent: ";key,press
    if press then
        if key = "down" then
            if m.menu.isInFocusChain() then
                m.keyboard.setFocus(true)
                return true
            else if m.keyboard.isInFocusChain() then
                if m.grid.visible then
                    m.grid.setFocus(true)
                    return true
                end if
            else
                if m.grid.hasFocus() then
                    bottomRowItems = m.grid.content.getChildCount()
                    if bottomRowItems MOD m.grid.numColumns > 0 then
                        if m.grid.itemFocused < bottomRowItems - bottomRowItems MOD m.grid.numColumns then
                            scrollSpeed = m.grid.scrollSpeed
                            m.grid.scrollSpeed = 10
                            m.grid.animateToItem = bottomRowItems - 1
                            m.grid.scrollSpeed = scrollSpeed
                        end if
                    end if
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
        m.searchText.text = m.searchText.text + " "
    else if key.id = "backspace" then
        if m.searchText.text.len() > 0 then
            m.searchText.text = m.searchText.text.mid(0, m.searchText.text.len() - 1)
        end if
    else
        m.searchText.text = m.searchText.text + key.text
    end if
end sub

sub onItemSelected(nodeEvent as object)
    list = nodeEvent.getRoSGNode()
    if list <> invalid then
        selected = nodeEvent.getData()
        item = list.content.getChild(selected)
        if item <> invalid then
            omnitureData = getOmnitureData(m.grid.content, selected)
            omnitureData["searchTerm"] = lcase(m.searchText.text)
            omnitureData.v41 = lcase(m.searchText.text)
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

sub onSearchTextChanged()
    m.searchTask.control = "stop"
    if not isNullOrEmpty(m.searchText.text.trim()) then
        m.searchTask.searchTerm = m.searchText.text
        m.searchTask.control = "run"
    else
        m.noResults.visible = false
        m.grid.visible = false
    end if
end sub

sub onResultsLoaded()
    m.grid.content = m.searchTask.results
    if m.searchTask.results = invalid or m.searchTask.results.getChildCount() = 0 then
        m.grid.visible = false
        m.noResults.visible = (m.searchText.text.trim().len() > 0)
        if not isNullOrEmpty(m.searchText.text.trim()) then
            omnitureData = getOmnitureData(m.grid.content, 0)
            omnitureData["searchTerm"] = lcase(m.searchText.text)
            omnitureData.v41 = lcase(m.searchText.text)
            trackScreenAction("trackNoSearchResult", omnitureData)
        end if
    else
        m.grid.visible = true
        m.noResults.visible = false
    end if
end sub

