sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.global.config, m.global.user, m.global.cookies)
    episode = m.top.episode
    
    segmentID = "default_free_all_platforms"
    if m.global.user.isSubscriber then
        segmentID = "default_paid_all_platforms"
    end if
    cpInfo = api.getContinuousPlayInfo(episode.id, episode.showID, segmentID)
    if cpInfo <> invalid then
        if cpInfo.episode = invalid then
            if cpInfo.recommendations = invalid or cpInfo.recommendations.count() = 0 then
                if not episode.isFullEpisode then
                    section = m.top.section
                    if section <> invalid and section.subtype() = "Section" then
                        for i = 0 to section.getChildCount() - 1
                            if section.getChild(i).id = episode.id then
                                nextEpisode = section.getChild(i + 1)
                                api.populateStream(nextEpisode)
                                cpInfo.episode = nextEpisode
                                exit for
                            end if
                        next
                    end if
                end if
            end if
        end if
    end if
    m.top.continuousPlayInfo = cpInfo
end sub
