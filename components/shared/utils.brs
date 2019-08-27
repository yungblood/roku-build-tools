sub showSpinner(context = m.top as object, ignoreContextVisibility = false as boolean)
    if ignoreContextVisibility or context.visible then
        debugPrint(context.subtype(), "showSpinner()", 0)
        scene = context.getScene()
        if scene <> invalid then
            scene.callFunc("showLoading")
        end if
    end if
end sub

sub hideSpinner(context = m.top as object, ignoreContextVisibility = false as boolean)
    if ignoreContextVisibility or context.visible then
        debugPrint(context.subtype(), "hideSpinner()", 0)
        scene = context.getScene()
        if scene <> invalid then
            scene.callFunc("hideLoading")
        end if
    end if
end sub

function createCbsDialog(title as string, message = "" as string, buttons = [] as object, autoClose = false as boolean) as object
    dialog = createObject("roSGNode", "CbsDialog")
    dialog.title = title
    dialog.message = message
    dialog.buttons = buttons
    dialog.autoClose = autoClose
    return dialog
end function

function showPinDialog(title as string, buttons as object, callbackFunction as string) as object
    dialog = createCbsDialog(title)
    dialog.allowBack = true
    dialog.buttonWidth = 450
    dialog.buttonHeight = 73
    dialog.buttonLayoutDirection = "vert"
    dialog.buttons = buttons
    
    dialog.includeMessage = false
    dialog.includeContentSpacer = false
    
    pinPad = dialog.contentGroup.createChild("Pinpad")
    pinPad.id = "pinPad"
    pinPad.pinLength = 4
    pinPad.secureMode = true
    
    font = createObject("roSGNode", "Font")
    font.uri = "pkg:/fonts/Lato-Bold.ttf"
    font.size = 28
    footerLabel = dialog.footerContentGroup.createChild("Label")
    footerLabel.font = font
    footerLabel.color = "0xffffffff"
    footerLabel.width = dialog.buttonWidth
    footerLabel.horizAlign = "center"
    footerLabel.text = "Forgot PIN?"
    
    font = createObject("roSGNode", "Font")
    font.uri = "pkg:/fonts/Lato-Regular.ttf"
    font.size = 28
    footerLabel = dialog.footerContentGroup.createChild("Label")
    footerLabel.translation = [0, 35]
    footerLabel.font = font
    footerLabel.color = "0xffffff9b"
    footerLabel.width = dialog.buttonWidth
    footerLabel.horizAlign = "center"
    footerLabel.text = "Visit www.cbs.com/PIN"
    
    tabOrder = [pinPad]
    tabOrder.append(dialog.tabOrder)
    dialog.tabOrder = tabOrder
    
    dialog.observeField("buttonSelected", callbackFunction)
    setGlobalField("cbsDialog", dialog)
    
    return dialog
end function

sub showPinErrorDialog(title as string, message as string, buttons as object, callbackFunction as string)
    dialog = createCbsDialog(title, message)
    dialog.allowBack = true
    dialog.buttonWidth = 450
    dialog.buttonHeight = 73
    dialog.buttons = buttons

    dialog.includeContentSpacer = false
    
    font = createObject("roSGNode", "Font")
    font.uri = "pkg:/fonts/Lato-Bold.ttf"
    font.size = 28
    footerLabel = dialog.footerContentGroup.createChild("Label")
    footerLabel.font = font
    footerLabel.color = "0xffffffff"
    footerLabel.width = dialog.buttonWidth
    footerLabel.horizAlign = "center"
    footerLabel.text = "Forgot PIN?"
    
    font = createObject("roSGNode", "Font")
    font.uri = "pkg:/fonts/Lato-Regular.ttf"
    font.size = 28
    footerLabel = dialog.footerContentGroup.createChild("Label")
    footerLabel.translation = [0, 35]
    footerLabel.font = font
    footerLabel.color = "0xffffff9b"
    footerLabel.width = dialog.buttonWidth
    footerLabel.horizAlign = "center"
    footerLabel.text = "Visit www.cbs.com/PIN"

    dialog.observeField("buttonSelected", callbackFunction)
    setGlobalField("cbsDialog", dialog)
end sub

sub sendDWAnalytics(params as object)
    analytics = getGlobalField("analytics")
    if analytics <> invalid then
        analytics.dwParams = params
    end if
end sub

sub sendSparrowAnalytics(params as object)
    analytics = getGlobalField("analytics")
    if analytics <> invalid then
        analytics.sparrowParams = params
    end if
end sub

function getImageUrl(baseUrl as string, width = 0 as integer, height = 0 as integer) as string
    width = int(width / (1920 / createObject("roDeviceInfo").getUIResolution().width))
    unscaledImageEndpoint = "http://wwwimage.cbsstatic.com/base/"
    photoImageEndpoint = "http://wwwimage.cbsstatic.com/thumbnails/photos/[WIDTHxHEIGHT]"
    videoImageEndpoint = "https://thumbnails.cbsig.net/_x/[WIDTH]/[HEIGHT]"
    url = baseUrl
    if baseUrl <> invalid and baseUrl <> "" then
'        if baseUrl.inStr("http://thumbnails.cbsig.net") > -1 then
'            url = baseUrl.replace("http://thumbnails.cbsig.net", videoImageEndpoint)
'        else 
        if baseUrl.inStr("files/") > -1 then
            if width > 0 or height > 0 then
                url = photoImageEndpoint + url.mid(url.inStr(8, "files/") + 6)
                resize = ""
                if width > 0 then
                    resize = "w" + width.toStr()
                end if
                if height > 0 then
                    if not isNullOrEmpty(resize) then
                        resize = resize + "-"
                    end if
                    resize = resize + "h" + height.toStr()
                end if
                url = url.replace("[WIDTHxHEIGHT]", resize)
            else
                url = unscaledImageEndpoint + url
            end if
        else
            url = videoImageEndpoint + url.mid(url.inStr(8, "/") + 1)
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
    end if
    return url
end function

function isSubscriber(context as object) as boolean
    user = getGlobalField("user", context)
    return isAuthenticated(context) and user.isSubscriber
end function

function isAuthenticated(context as object) as boolean
    cookies = getGlobalField("cookies", context)
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
    user = getGlobalField("user", context)
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

function loadLocalLiveStations(api as object) as object
    config = getGlobalField("config")
    stations = []
    if asBoolean(config.syncbak_enabled, true) then
        syncbak().initialize(config.syncbakKey, config.syncbakSecret, config.syncbakBaseUrl)
        syncbak().setLocation(getGlobalField("localStationLatitude"), getGlobalField("localStationLongitude"))
        stations = syncbak().getChannels()
    else
        nationalFeedID = config.live_tv_national_feed_content_id
        if not isNullOrEmpty(nationalFeedID) then
            nationalFeed = api.getEpisode(nationalFeedID)
            if nationalFeed <> invalid then
                stations.push(nationalFeed)
            end if
        end if
    end if
    return stations
end function

function loadLiveChannels(api as object) as object
    config = getGlobalField("config")
    liveTVChannels = api.getLiveChannels()
    if config.liveTVChannels <> invalid then
        for each channel in liveTVChannels
            for each override in config.liveTVChannels
                if override.id = channel.scheduleType or (override.id = "local" and channel.type = "syncbak") then
                    for each field in override.keys()
                        if field <> "id" then
                            channel.setField(field, override[field])
                        end if
                    next
                    exit for
                end if
            next
        next
    end if
    channels = createObject("roSGNode", "LiveTVChannels")
    channels.appendChildren(liveTVChannels)
    return channels
end function

sub updateLocalChannel(liveStations as object, channels as object, stationID = "" as string)
    for i = 0 to channels.getChildCount() - 1
        channelItem = channels.getChild(i)
        if channelItem.scheduleType = "local" and not channelItem.isFallback then
            if liveStations.count() > 1 and not isNullOrEmpty(stationID) then
                for each station in liveStations
                    if station.id = stationID then
                        channelItem.title = station.station
                        channelItem.affiliate = station.affiliate
                        channelItem.scheduleUrl = station.scheduleUrl
                        channelItem.isTuned = false
                        exit for
                    end if
                next
            else
                station = liveStations[0]
                if station <> invalid then
                    channelItem.affiliate = station.affiliate
                    channelItem.title = station.title
                    channelItem.affiliate = station.affiliate
                    channelItem.scheduleUrl = station.scheduleUrl
                    channelItem.isTuned = false
                end if
            end if
            exit for
        end if
    next
end sub

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
        else if json.playlists <> invalid and asArray(json.playlists).count() > 0 then
            items = json.playlists[0].items
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

function createKeyPadDialog(title as string, message as string, text = "" as string, buttons = ["OK"]) as object
    dialog = createMessageDialog(title, message, buttons, "KeyPadDialog")
    dialog.width = 900
    dialog.text = text
    return dialog
end function

function getParentScreen(context = m.top as object) as object
    parent = context.getParent()
    while parent <> invalid and parent.subtype().inStr("Screen") = -1
        parent = parent.getParent()
    end while
    return parent
end function

sub addGlobalField(field as string, fieldType as string, alwaysNotify = false as boolean, context = m.top as object)
    scene = context.getScene()
    if scene <> invalid then
        scene.addField(field, fieldType, alwaysNotify)
        return
    end if
    globalNode = m.global
    if globalNode <> invalid then
        globalNode.addField(field, fieldType, alwaysNotify)
    end if
end sub

function getGlobalField(field as string, context = m.top as object) as object
    scene = context.getScene()
    if scene <> invalid and scene.hasField(field) then
        return scene.getField(field)
    end if
    globalNode = m.global
    if globalNode <> invalid and globalNode.hasField(field) then
        return globalNode.getField(field)
    end if
    return invalid
end function

sub setGlobalField(field as string, value as dynamic, context = m.top as object)
    scene = context.getScene()
    if scene <> invalid and scene.hasField(field) then
        scene.setField(field, value)
        return
    end if
    globalNode = m.global
    if globalNode <> invalid and globalNode.hasField(field) then
        globalNode.setField(field, value)
    end if
end sub

function getGlobalComponent(id as string, context = m.top as object) as object
    scene = context.getScene()
    if scene <> invalid then
        return scene.findNode(id)
    end if
    globalNode = m.global
    if globalNode <> invalid then
        return globalNode.findNode(id)
    end if
    return invalid
end function

sub observeGlobalField(field as string, callbackOrPort as object, context = m.top as object)
    scene = context.getScene()
    if scene <> invalid and scene.hasField(field) then
        scene.observeField(field, callbackOrPort)
        return
    end if
    globalNode = m.global
    if globalNode <> invalid and globalNode.hasField(field) then
        globalNode.observeField(field, callbackOrPort)
    end if
end sub

sub showApiError(closeApp = true as boolean)
    dialog = createCbsDialog("Error", "Uh-oh. An error has occurred, but we're working on fixing it. We'll be up and streaming again shortly!", ["OK"])
    if closeApp then
        dialog.observeField("buttonSelected", "onFatalError")
    else
        dialog.observeField("buttonSelected", "onApiErrorDialogClosed")
    end if
    setGlobalField("cbsDialog", dialog)
    hideSpinner()
end sub

sub onApiErrorDialogClosed(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    dialog.close = true
end sub

sub onFatalError()
    setGlobalField("close", true)
end sub

sub trackRMFEvent(eventName as string)
    correlator = getGlobalField("correlator")
    rac = getGlobalField("rac")
    if rac = invalid then
        rac = createObject("roSGNode", "Roku_Analytics:AnalyticsNode")
        rac.debug = true
        rac.init = { RED: {} }
        setGlobalField("rac", rac)
    end if
    if not isNullOrEmpty(correlator) then
        rac.trackEvent = { RED: { eventName: eventName, correlator: correlator } }
    else
        rac.trackEvent = { RED: { eventName: eventName } }
    end if
end sub

function getPersistedDeviceID() as string
    return getGlobalField("deviceID")
end function

sub loadCallbackUrl(url as string)
    m.callbackTask = createObject("roSGNode", "LoadUrlTask")
    m.callbackTask.observeField("response", "onCallbackTaskResponse")
    m.callbackTask.uri = url
    m.callbackTask.control = "run"
end sub

sub onCallbackTaskResponse(nodeEvent as object)
    m.callbackTask = invalid
end sub
