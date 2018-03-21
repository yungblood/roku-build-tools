sub init()
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        if json.slug_label <> invalid or json.slugLabel <> invalid then
            ' This is a schedule item from a source other than syncbak
            m.top.id = json.mpxId
            m.top.title = json.slug_label
            if isNullOrEmpty(m.top.title) then
                m.top.title = json.slugLabel
            end if
            
            m.top.episodeTitle = json.headlineShort
            m.top.description = json.headline
            
            if json.storyType = "commercial" then
                m.top.episodeTitle = json.headline
            end if
            
            if isNullOrEmpty(m.top.title) then
                m.top.title = m.top.episodeTitle
                m.top.episodeTitle = ""
            end if
            
            date = createObject("roDateTime")
            if isString(json.startDate) or json.startDate = invalid then
                date.fromIso8601String(asString(json.startDate))
            else
                date.fromSeconds(json.startDate)
            end if
            m.top.startTime = date.asSeconds()
            if isString(json.startDate) or json.endDate = invalid  then
                date.fromIso8601String(asString(json.endDate))
            else
                date.fromSeconds(json.endDate)
            end if
            m.top.endTime = date.asSeconds()
            m.top.length = m.top.endTime - m.top.startTime
        else
            m.top.id = json.programId
            m.top.title = json.name
            if json.blackout = true then
                m.top.episodeTitle = "Not Available to Stream"
            else
                m.top.episodeTitle = json.episodeTitle
            end if
            m.top.description = json.description
            m.top.length = json.duration
            m.top.startTime = json.startTime
            m.top.endTime = m.top.startTime + m.top.length
        end if
    end if
end sub
