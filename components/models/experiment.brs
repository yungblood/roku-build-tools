sub init()
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        m.top.id = json.variantTestName
        m.top.variant = json.variant
    end if
end sub
