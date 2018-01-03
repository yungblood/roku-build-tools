sub init()
    ?"TestItem.Init"
    m.poster = m.top.findNode("poster")
    
    m.content = invalid
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    ?"TestItem.onKeyEvent: ";key,press
    return false
end function

sub onItemContentChanged()
    if m.content = invalid or not m.content.isSameNode(m.top.itemContent) then
        m.content = m.top.itemContent
        m.poster.uri = "http://staging.permanence.com/imageGenerator/?format=png&w=" + m.poster.width.toStr() + "&h=" + m.poster.height.toStr() + "&color=" + GetRandomHexString(6) + "&text=" + m.content.id
        if not m.content.hasField("targetGroupComponent") then
            m.content.addField("targetGroupComponent", "node", false)
        end if
        m.content.setField("targetGroupComponent", m.top)
    end if
end sub

sub onContentChanged()
    if m.content = invalid or not m.content.isSameNode(m.top.content) then
        m.content = m.top.content
        m.poster.uri = "http://staging.permanence.com/imageGenerator/?format=png&w=" + m.poster.width.toStr() + "&h=" + m.poster.height.toStr() + "&color=" + GetRandomHexString(6) + "&text=" + m.content.id
        if not m.content.hasField("targetGroupComponent") then
            m.content.addField("targetGroupComponent", "node", false)
        end if
        m.content.setField("targetGroupComponent", m.top)
    end if
end sub

Function GetRandomHexString(length As Integer) As String
    bytes = CreateObject("roByteArray")
    For i = 1 to length / 2
        bytes.Push(Rnd(256) - 1)
    Next
    hexString = bytes.ToHexString()
    If length Mod 2 > 0 Then
        hexString = hexString + "0"
    End If
    Return hexString
End Function

