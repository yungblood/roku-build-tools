sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.top)

    groups = api.getShowGroups()
    
    if isAssociativeArray(groups) and groups.errorCode <> invalid then
        m.top.errorCode = groups.errorCode
        m.top.groups = []
    else
        m.top.groups = groups
    end if
end sub
