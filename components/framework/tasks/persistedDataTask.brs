sub init()
end sub

sub onModeChanged()
    m.top.functionName = m.top.mode
    m.top.control = "RUN"
end sub

sub save()
    savePersistedData()
    refresh()
end sub

sub refresh()
    refreshPersistedData()
end sub
