sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    if m.top.mode = "save" then
        if m.top.values <> invalid then
            values = m.top.values
            for each key in values
                setRegistryValue(key, values[key], m.top.section)
            next
        else
            setRegistryValue(m.top.key, m.top.value, m.top.section)
        end if
    else if m.top.mode = "delete" then
        deleteRegistryValue(m.top.key, m.top.section)
    else
        m.top.value = getRegistryValue(m.top.key, m.top.defaultValue, m.top.section)
    end if
    m.top.complete = true
end sub

sub onModeChanged()
    m.top.control = "run"
end sub
