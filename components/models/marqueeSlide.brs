sub init()
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        m.top.id = json.id.toStr()
        m.top.showID = asString(json.show_id)
        m.top.title = json.apps_home_slide_copy
        m.top.actionTitle = json.slide_action_title
        m.top.hdPosterUrl = getImageUrl(json.filePath, 1920)
        
        m.top.deeplink = json.apps_target
    end if
end sub