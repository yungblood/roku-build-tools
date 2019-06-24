sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    config = getGlobalField("config")
    api = cbs()
    api.initialize(m.top)

    stations = []
    stations = api.registerDmaOverride() '.getDmaFromZip(m.top.zipCode)

    m.top.stations = stations
end sub
