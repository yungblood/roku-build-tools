sub init()
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        if json.slug_label <> invalid then
            ' This is a schedule item from a source other than syncbak
            m.top.id = json.mpxId
            m.top.title = json.slug_label
            m.top.episodeTitle = json.headlineShort
            m.top.description = json.headline
            
            date = createObject("roDateTime")
            date.fromIso8601String(asString(json.startDate))
            m.top.startTime = date.asSeconds()
            date.fromIso8601String(asString(json.endDate))
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
