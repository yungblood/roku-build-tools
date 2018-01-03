sub init()
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        m.top.sessionID = json.sessionId
        m.top.ticket = json.ticket
        m.top.url = json.url
    end if
end sub