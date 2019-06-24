sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.top)
    

    m.top.show = api.getShow(m.top.showID)
end sub
