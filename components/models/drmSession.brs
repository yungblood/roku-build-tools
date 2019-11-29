sub init()
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        m.top.sessionID = json.sessionId
        m.top.ticket = json.ticket
        m.top.url = json.url
        m.top.ls_session = json.ls_session
    end if
end sub