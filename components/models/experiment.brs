sub init()
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        m.top.id = json.variantTestName
        m.top.variant = json.variant
        
        m.top.enabled = (json.variant <> invalid)
    end if
end sub
