sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    content = m.top.content
    history = m.global.user.recentlyWatched
    controls = []
    for i = 0 to content.getChildCount() - 1
        item = content.getChild(i)
        historyItem = getChildByID(item.id, history)
        if historyItem <> invalid then
            item.resumePoint = historyItem.resumePoint
        end if
        if i = 0 then
            tile = createObject("roSGNode", "FeaturedEpisodeTile")
            tile.width = 836
            tile.height = 470
            tile.itemContent = item
            controls.push(tile)
        else
            tileGroup = createObject("roSGNode", "FocusLayoutGroup")
            tileGroup.layoutDirection = "vert"
            tileGroup.itemSpacings = [10]

            tile = tileGroup.createChild("FeaturedEpisodeTile")
            tile.width = 409
            tile.height = 230
            tile.itemContent = item
            
            i = i + 1
            if i < 7 then 'content.getChildCount() then
                item = content.getChild(i)
                tile = tileGroup.createChild("FeaturedEpisodeTile")
                tile.width = 409
                tile.height = 230
                tile.itemContent = item
            end if
            controls.push(tileGroup)
        end if
    next
    m.top.controls = controls
end sub
