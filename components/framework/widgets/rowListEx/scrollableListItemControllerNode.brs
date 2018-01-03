sub init()
    ?"ScrollableListItemControllerNode.init"
end sub

sub updateComponentPosition()
    if m.itemComponent <> invalid then
        currRect = m.top.currRect
        m.itemComponent.translation = [currRect.x, currRect.y]
    end if
end sub

sub onContentChanged()
    if m.content = invalid or not m.content.isSameNode(m.top.itemContent) then
        m.content = m.top.itemContent
        if m.itemComponent = invalid then
            m.itemComponent = createObject("roSGNode", m.content.itemComponentName)
            m.content.parentGroup.insertChild(m.itemComponent, m.content.index)
            updateComponentPosition()
        end if
        m.itemComponent.itemContent = m.content.itemContent
        m.content.itemComponent = m.itemComponent
    end if
end sub
