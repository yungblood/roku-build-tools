sub init()
    m.top.observeField("width", "onFieldUpdated")
    m.top.observeField("height", "onFieldUpdated")
    m.top.observeField("loadWidth", "onFieldUpdated")
    m.top.observeField("loadHeight", "onFieldUpdated")
    m.top.observeField("loadDisplayMode", "onFieldUpdated")
    m.top.observeField("blendColor", "onFieldUpdated")
    m.top.observeField("fadeDuration", "onFieldUpdated")
end sub

sub onFieldUpdated(nodeEvent as object)
    m.top.getChild(0).setField(nodeEvent.getField(), nodeEvent.getData())
    m.top.getChild(1).setField(nodeEvent.getField(), nodeEvent.getData())
end sub

sub onItemContentChanged()
    if m.top.uri <> m.top.itemContent.hdPosterUrl then
        m.top.uri = m.top.itemContent.hdPosterUrl
    end if
end sub

sub onUriChanged(nodeEvent as object)
    ' Rotate the back poster to the front
    poster = m.top.getChild(0)
    poster.uri = "invalid"
    poster.uri = nodeEvent.getData()
    m.top.appendChild(poster)
end sub

sub onFailedBitmapUriChanged(nodeEvent as object)
    poster = m.top.getChild(1)
    poster.failedBitmapUri = nodeEvent.getData()
end sub