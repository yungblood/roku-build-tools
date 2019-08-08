sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    config = getGlobalField("config")
    api = cbs()
    api.initialize(m.top)

    stations = []
    if isNullOrEmpty(m.top.zipCode) then
        stations = api.registerDmaOverride()
    else
        stations = api.registerDmaOverride(m.top.zipCode)
    end if

    m.top.stations = stations
end sub
