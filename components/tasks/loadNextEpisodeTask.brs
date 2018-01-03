sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.global.config, m.global.user, m.global.cookies)
    episode = m.top.episode
    nextEpisode = api.getNextEpisode(episode.id, episode.showID, true)
    if nextEpisode = invalid and not episode.isFullEpisode then
        section = m.top.section
        if section <> invalid and section.subtype() = "Section" then
            for i = 0 to section.getChildCount() - 1
                if section.getChild(i).id = episode.id then
                    nextEpisode = section.getChild(i + 1)
                    api.populateStream(nextEpisode)
                    exit for
                end if
            next
        end if
    end if
    m.top.nextEpisode = nextEpisode
end sub
