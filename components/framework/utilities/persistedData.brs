function getPersistedData() as object
    context = getGlobalAA().global
    if context <> invalid then
        if not context.hasField("persistedData") then
            setPersistedData({})
        end if
        return context.persistedData
    end if
    return {}
end function

sub setPersistedData(persistedData as object)
    context = getGlobalAA().global
    if context <> invalid then
        if not context.hasField("persistedData") then
            context.addField("persistedData", "assocarray", false)
        end if
        context.persistedData = persistedData
    end if
end sub

sub setPersistedValue(key as string, value as dynamic, saveImmediately = false as boolean)
    persisted = getPersistedData()
    persisted[key] = value
    setPersistedData(persisted)
    
    if saveImmediately then
        savePersistedData()
    end if
end sub

function getPersistedValue(key as string, default as dynamic) as dynamic
    persisted = getPersistedData()
    return ConvertToTypeByValue(persisted[key], default)
end function

sub savePersistedData()
    if not isRegistryAvailable() then
        m.persistedDataTask = CreateObject("roSGNode", "PersistedDataTask")
        m.persistedDataTask.mode = "save"
    else
        SetRegistryValues("persistedData", getPersistedData())
    end if
end sub

sub refreshPersistedData()
    if not isRegistryAvailable() then
        m.persistedDataTask = CreateObject("roSGNode", "PersistedDataTask")
        m.persistedDataTask.mode = "refresh"
    else
        setPersistedData(GetRegistryValues("persistedData"))
    end if
end sub