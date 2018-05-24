sub init()
    m.top.omniturePageType = "category_door"

    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.menu = m.top.findNode("menu")
    m.menu.observeField("buttonSelected", "onMenuItemSelected")
    
    m.buttonFont = m.top.findNode("buttonFont")
    m.groups = m.top.findNode("groups")
    m.grid = m.top.findNode("grid")
    m.grid.observeField("itemSelected", "onItemSelected")

    m.global.showSpinner = true

    m.contentTask = createObject("roSGNode", "ShowsScreenTask")
    m.contentTask.observeField("groups", "onGroupsLoaded")
    m.contentTask.control = "run"

    m.top.setFocus(true)
end sub

sub onFocusChanged()
    if m.top.hasFocus() then
        if m.lastFocus = invalid then
            m.groups.setFocus(true)
        else
            m.lastFocus.setFocus(true)
        end if
    end if
    if m.top.isInFocusChain() then
        if m.groups.isInFocusChain() then
            m.lastFocus = m.groups
        else
            m.lastFocus = m.grid
        end if
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        if key = "down" then
            if m.menu.isInFocusChain() then
                m.groups.setFocus(true)
                return true
            else if m.groups.isInFocusChain() then
                m.grid.setFocus(true)
                return true
            end if
        else if key = "up" then
            if m.grid.isInFocusChain() then
                m.menu.setFocus(true)
                return true
            else if m.groups.isInFocusChain() then
                m.menu.setFocus(true)
                return true
            end if
        else if key = "right" then
            if m.groups.isInFocusChain() then
                 m.grid.setFocus(true)
                return true
            end if
        else if key = "left" then
            if m.grid.isInFocusChain() then
                m.groups.setFocus(true)
            end if    
        end if
    end if
    return false
end function

sub onGroupsLoaded()
    groups = m.contentTask.groups
    m.contentTask = invalid

    initialGroup = groups[0]
    for each group in groups
        button = m.groups.createChild("ShowGroupButton")
        button.observeField("buttonSelected", "onGroupSelected")
        button.group = group
        if lCase(group.title) = lCase(m.top.category) then
            initialGroup = group
        end if
    next
    selectGroup(initialGroup)
    
    m.global.showSpinner = false
end sub

sub onGroupSelected(nodeEvent as object)
    button = nodeEvent.getRoSGNode()
    group = button.group
    if group <> invalid then
        selectGroup(group)
    end if
end sub

sub selectGroup(group as object)
    if group <> invalid then
        m.top.omnitureName = "/shows/" + group.title
        trackScreenView()
        trackScreenAction("trackShowFilterSelect", {}, "/shows/filter/" + group.title)
        
        group.loadShows = true
        m.grid.content = group
        
        for i = 0 to m.groups.getChildCount() - 1
            button = m.groups.getChild(i)
            button.highlight = button.group.isSameNode(group)
        next
    end if
end sub

sub onMenuItemSelected(nodeEvent as object)
    m.top.menuItemSelected = nodeEvent.getData()
end sub

sub onItemSelected(nodeEvent as object)
    index = nodeEvent.getData()
    show = m.grid.content.getChild(index)
    if show <> invalid then
        trackScreenAction("trackPodSelect", getOmnitureData(m.grid, index))
        m.top.itemSelected = show
    end if
end sub
