sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    if m.top.mode = "save" then
        setRegistryValue(m.top.key, m.top.value, m.top.section)
    else
        m.top.value = getRegistryValue(m.top.key, m.top.defaultValue, m.top.section)
    end if
end sub

sub onModeChanged()
    m.top.control = "run"
end sub
