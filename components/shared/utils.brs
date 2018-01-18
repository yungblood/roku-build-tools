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

function getImageUrl(baseUrl as string, width as integer) as string
    width = int(width / (1920 / createObject("roDeviceInfo").getUIResolution().width))
    photoImageEndpoint = "http://wwwimage.cbsstatic.com/thumbnails/photos/w[WIDTH]/"
    videoImageEndpoint = "http://wwwimage.cbsstatic.com/thumbnails/videos/w[WIDTH]/"
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
            url = url.replace("[WIDTH]", width.toStr())
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
    link = link.replace("http://www.cbs.com", "")
    link = link.replace("https://www.cbs.com", "")
    link = link.replace("cbs://www.cbs.com", "")
    ' HACK: some deep links have a / before the #, some don't, so
    '       we ensure all do.  Empty entries will be removed later
    link = link.replace("#", "/#")
    
    parts = link.split("/")
    for i = parts.count() - 1 to 0 step -1
        if isNullOrEmpty(parts[i]) then
            parts.delete(i)
        end if
    next
    params = {}
    if parts.count() = 0 then
        params.mediaType = "screen"
        params.contentID = "home"
    else if parts.count() = 1 then
        params.mediaType = "screen"
        params.contentID = parts[0]
    else
        if parts.peek().mid(0, 1) = "#" then
            if parts.peek() = "#open" then
                if parts[0] = "movies" then
                    params.mediaType = "moviedetails"
                else
                    params.mediaType = "episodedetails"
                end if
                params.contentID = parts[parts.count() - 2]
            else
                if parts[0] = "shows" then
                    params.mediaType = "screen"
                    params.contentID = "shows"
                    params.category = parts.peek().mid(1)
                end if
            end if
        else
            if parts.count() = 2 and parts[0] = "shows" then
                params.mediaType = "series"
            else if parts[0] = "live-tv" then
                params.mediaType = "screen"
                params.contentID = "live-tv/" + parts.peek()
            else
                if parts[0] = "movies" then
                    params.mediaType = "movie"
                else
                    params.mediaType = "episode"
                end if
                params.contentID = parts.peek()
            end if
        end if
    end if
    return params
end function


