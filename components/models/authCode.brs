sub init()
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        m.top.code = json.regCode
        m.top.retryDuration = asInteger(json.retryDuration)
        m.top.retryInterval = asInteger(json.retryInterval)
    end if
end sub