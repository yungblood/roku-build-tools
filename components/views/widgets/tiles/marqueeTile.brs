sub init()
    m.poster = m.top.findNode("poster")
    
    m.metadata = m.top.findNode("metadata")
    m.title = m.top.findNode("title")
    m.subtitle = m.top.findNode("subtitle")
    m.actionButton = m.top.findNode("actionButton")
end sub

sub onContentChanged(nodeEvent as object)
    content = nodeEvent.getData()
    m.poster.uri = content.hdPosterUrl
    m.title.text = content.title
    m.subtitle.text = content.subtitle
    m.actionButton.text = content.actionTitle
    
    if m.subtitle.text.trim() = "" then
        m.metadata.removeChild(m.subtitle)
        m.metadata.itemSpacings = [61]
    else
        m.metadata.insertChild(m.subtitle, 1)
        m.metadata.itemSpacings = [-4, 61]
    end if
end sub

sub onGridFocusChanged(nodeEvent as object)
    focused = nodeEvent.getData()
    m.actionButton.forceFocus = focused
end sub

sub updateLayout()
    if m.top.width > 0 and m.top.height > 0 then
        m.poster.width = m.top.width
        m.poster.height = m.top.height
    end if
end sub
