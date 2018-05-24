function createCbsDialog(title as string, message as string, buttons = [] as object, autoClose = false as boolean) as object
    dialog = createObject("roSGNode", "CbsDialog")
    dialog.title = title
    dialog.message = message
    dialog.buttons = buttons
    dialog.autoClose = autoClose
    return dialog
end function

sub sendDWAnalytics(params as object)
    if m.global.analytics <> invalid then
        m.global.analytics.dwParams = params
    end if
end sub

sub sendSparrowAnalytics(params as object)
    if m.global.analytics <> invalid then
        m.global.analytics.sparrowParams = params
    end if
end sub

function getImageUrl(baseUrl as string, width = 0 as integer, height = 0 as integer) as string
    width = int(width / (1920 / createObject("roDeviceInfo").getUIResolution().width))
    photoImageEndpoint = "http://wwwimage.cbsstatic.com/thumbnails/photos/[WIDTH]/[HEIGHT]"
    videoImageEndpoint = "http://wwwimage.cbsstatic.com/thumbnails/videos/[WIDTH]/[HEIGHT]"
    url = baseUrl
    if baseUrl <> invalid and baseUrl <> "" then
        if baseUrl.inStr("http://thumbnails.cbsig.net") > -1 then
            url = baseUrl.replace("http://thumbnails.cbsig.net", videoImageEndpoint)
        else if baseUrl.inStr("files/") > -1 then
            url = photoImageEndpoint + url.mid(url.inStr(8, "files/") + 6)
        else
            url = videoImageEndpoint + url.mid(url.inStr(8, "/") + 1)
        end if
        if width = 0 then
            url = url.replace("[WIDTH]", "")
        else
            url = url.replace("[WIDTH]", "w" + width.toStr())
        end if
        if height = 0 then
            url = url.replace("[HEIGHT]", "")
        else
            url = url.replace("[HEIGHT]", "h" + height.toStr())
        end if
    end if
    return url
end function

function isSubscriber(context as object) as boolean
    return isAuthenticated(context) and m.global.user.isSubscriber
end function

function isAuthenticated(context as object) as boolean
    cookies = context.cookies
    if not isNullOrEmpty(cookies) then
        return cookies.inStr("CBS_COM=") > -1
    end if
    return false
end function

function isFavorite(showID as string, favorites as object) as boolean
    for i = 0 to favorites.getChildCount() - 1
        favorite = favorites.getChild(i)
        if favorite.showID = showID then
            return true
        end if
    next
    return false
end function

function removeFavorite(showID as string, favorites as object) as boolean
    for i = 0 to favorites.getChildCount() - 1
        favorite = favorites.getChild(i)
        if favorite.showID = showID then
            favorites.removeChild(favorite)
            m.favoritesTask = createObject("roSGNode", "RemoveFromFavoritesTask")
            m.favoritesTask.showID = showID
            m.favoritesTask.control = "run"
            return true
        end if
    next
    return false
end function

function addFavorite(showID as string, favorites as object) as boolean
    for i = 0 to favorites.getChildCount() - 1
        favorite = favorites.getChild(i)
        if favorite.showID = showID then
            return false
        end if
    next
    favorite = favorites.createChild("Favorite")
    favorite.showID = showID
    m.favoritesTask = createObject("roSGNode", "AddToFavoritesTask")
    m.favoritesTask.showID = showID
    m.favoritesTask.control = "run"
    return false
end function

sub toggleFavorite(showID as string, context as object)
    user = context.user
    if user <> invalid then
        favorites = user.favorites
        if isFavorite(showID, favorites) then
            removeFavorite(showID, favorites)
        else
            addFavorite(showID, favorites)
        end if
    end if
end sub

function getChildByID(id as string, parent as object) as object
    for i = 0 to parent.getChildCount() - 1
        child = parent.getChild(i)
        if child.id = id then
            return child
        end if
    next
    return invalid
end function

function isAvailable(episode as object) as boolean
    return episode.status = "AVAILABLE" or episode.status = "DELAYED" or episode.status = "PREMIUM"
end function

function canWatch(episode as object, context as object, postSignIn = false as boolean) as boolean
    if episode.status = "AVAILABLE" or (postSignIn and isSubscriber(context)) then
        return isSubscriber(context) or episode.subscriptionLevel = "FREE"
    end if
    return false
end function

function parseDeepLink(link as string) as object 
    link = link.replace("http://www.cbs.com/", "")
    link = link.replace("https://www.cbs.com/", "")
    link = link.replace("cbs://www.cbs.com/", "")
    
    if link.inStr("/") = 0 then
        link = link.mid(1)
    end if
    
    parts = link.split("/")
    params = {}
    if parts.count() = 0 then
        params.mediaType = "screen"
        params.contentID = "home"
    else if parts.count() = 1 then
        params.mediaType = "screen"
        params.contentID = parts[0]
    else
        if parts[0] = "all-access" then
            params.mediaType = "screen"
            params.contentID = "all-access"
        else if parts[0] = "shows" then
            if parts.count() = 2 then
                ' /shows/#featured
                params.mediaType = "screen"
                params.contentID = "shows"
                if parts[1].inStr("#") = 0 then
                    params.category = parts[1].mid(1)
                end if
            else if parts.count() = 3 then
                ' /shows/the-good-fight/
                params.mediaType = "series"
            else if parts[2] = "video" then
                ' /shows/macgyver/video/jfKgYcYhkZ80Yz_q0fIuw48TqQAMu0B5/#open
                params.mediaType = "episode"
                params.contentID = parts[3]
                if parts.peek() = "#open" then
                    params.mediaType = "episodedetails"
                end if
            end if
        else if parts[0] = "movies" then
            if parts.count() = 2 then
                ' /movies/
                params.mediaType = "screen"
                params.contentID = "movies"
            else if parts.count() > 2 then
                params.mediaType = "movie"
                if parts[2] = "trailer" then
                    ' /movies/star-trek-first-contact/trailer/uam4uMDVsHcD6T9FCQCuUekB5vwwGB0a
                    params.contentID = parts[3]
                    params.playTrailer = true
                else
                    ' /movies/star-trek-first-contact/uam4uMDVsHcD6T9FCQCuUekB5vwwGB0a/#open
                    params.contentID = parts[2]
                    if parts.peek() = "#open" then
                        params.mediaType = "moviedetails"
                    end if
                end if
            end if
        else if parts[0] = "live-tv" then
            if parts.count() = 2 then
                if isNullOrEmpty(parts[1]) then
                    ' /live-tv/
                    params.mediaType = "screen"
                    params.contentID = "live-tv"
                else if parts[1] = "stream" then
                    ' /live-tv/stream
                    params.mediaType = "screen"
                    params.contentID = "live-tv/local"
                end if
            else if parts.count() >= 3 then
                if isNullOrEmpty(parts[2]) then
                    ' /live-tv/stream/
                    params.mediaType = "screen"
                    params.contentID = "live-tv/local"
                else
                    ' /live-tv/stream/cbsn/
                    params.mediaType = "screen"
                    params.contentID = "live-tv/" + parts[2]
                end if
            end if
        end if
    end if
    return params
end function

function parseScheduleJson(json as object) as object
    schedule = []
    if json <> invalid then
        now = createObject("roDateTime").asSeconds()
        items = invalid
        if isArray(json) then
            for each item in json
                if item.navigation <> invalid and not item.navigation.data.isEmpty() then
                    items = item.navigation.data
                    exit for
                end if
            next
        else if json.schedule <> invalid then
            if isArray(json.schedule) then
                items = json.schedule
            else if json.schedule.navigation <> invalid then
                items = json.schedule.navigation.data
            end if
        else if json.navigation <> invalid then
            items = json.navigation.data
        end if
        if items <> invalid then
            for each item in items
                program = createObject("roSGNode", "Program")
                program.json = item
                if program.endTime > now or program.endTime = 0 or program.startTime = 0 then
                    schedule.push(program)
                end if
            next
        end if
    end if
    return schedule
end function