sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.top)

    dynamicPlay = api.getDynamicPlayEpisode(m.top.showID)
    
    if dynamicPlay = invalid and m.top.enableFallback then
        sections = api.getShowSections(m.top.showID)
        if sections <> invalid then
            for each section in sections
                if section.subtype() = "Section" then
                    videos = api.getSectionVideos(section.id, section.excludeShow, section.params, 0, 1)
                    if videos.count() > 0 then
                        episode = videos[0]
                        if episode.subtype() <> "LiveFeed" then
                            dynamicPlay = createObject("roSGNode", "DynamicPlayEpisode")
                            dynamicPlay.episode = episode
                            dynamicPlay.title = "Watch"
                            exit for
                        end if
                    end if
                end if
            next
        end if
    end if

    m.top.episode = dynamicPlay
end sub
