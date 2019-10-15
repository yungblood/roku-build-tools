sub init()
end sub

sub onJsonChanged(nodeEvent as object)
    json = nodeEvent.getData()
    if json <> invalid then
        if json.channelStreams <> invalid then
            json = json.channelStreams[0]
            
            m.top.id = json.id
            m.top.title = json.title
            m.top.type = json.stream_type
            m.top.scheduleType = json.schedule_type
            m.top.hdPosterUrl = getImageUrl(json.filepath_logo, 0, 72)
            m.top.sdPosterUrl = getImageUrl(json.filepath_logo, 0, 30)
            m.top.contentID = json.mpx_ref_id
            m.top.trackingAstID = "595"
            m.top.trackingContentID = json.mpx_ref_id
            m.top.comscoreC2 = "3005086"

            content = invalid
            if json.streamContent <> invalid then
                content = createObject("roSGNode", "Episode")
                content.json = json.streamContent
                m.top.content = content
                
                m.top.trackingID = content.mediaID
                m.top.trackingTitle = content.title
                m.top.convivaTrackingTitle = content.title
                m.top.comscoreTrackingTitle = content.title
                if m.top.type = "syncbak" then
                    m.top.scheduleType = "local"
                else
                    m.top.streamUrl = content.liveStreamingUrl
                end if
            end if
            
            if json.is_fallback_enabled = true then
                m.top.isFallback = true
                m.top.streamUrl = json.fallback_url
                m.top.contentID = json.fallback_ref_id
                m.top.trackingContentID = json.fallback_ref_id
                m.top.scheduleType = json.fallback_schedule_type
            end if
        end if
    end if
end sub