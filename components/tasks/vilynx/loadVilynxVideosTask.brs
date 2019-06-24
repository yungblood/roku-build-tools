sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    model = getModel().mid (0, 2).toInt()
    if model > 35 then 'and isSubscriber(m.top) then 
        api = cbs()
        api.initialize(m.top)
        config = getGlobalField("config")
    
        videos = api.getVilynxHash(config.vilynxOwnerKey, m.top.vilynxIDs)
        m.top.vilynxVideos = videos
    else
        m.top.vilynxVideos = []
    end if
end Sub
