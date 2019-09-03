sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.top)

    content = {}
    content.marquee = api.getMarquee()

    user = getGlobalField("user")
    rows = [] 
    if isAuthenticated(m.top) then
        if user.continueWatching.getChildCount()>0 then
            rows.push(user.continueWatching)
        end if
        if user.showHistory.getChildCount()>0 then
            rows.push(user.showHistory)
        end if
    end if

    enableR4Y = false
    model = "Model1"
    config = getGlobalField("config")
    if config <> invalid and config.enableTaplytics = true then
        taplyticsApi = getGlobalComponent("taplytics")
        if taplyticsApi <> invalid then
            response = taplyticsApi.callFunc("getRunningExperimentsAndVariations")
            if response.experiments <> invalid and response.experiments["Recommended + Trending"] <> invalid then
                ' The R4Y experiment is running, get the model(s)
                model = taplyticsApi.callFunc("getValueForVariable", { name: "recommendationcarousel", default: model })
                enableR4Y = true
            end if
        end if
    end if

    if enableR4Y then
        showTrending = false
        if model.mid(model.len() - 1, 1) = "T" then
            model = model.mid(0, model.len() - 1)
            showTrending = true
        end if
    
        recommended = createObject("roSGNode", "AmlgShowGroup")
        recommended.title = "Recommended For You"
        recommended.variant = "showRecommendation" + model
        rows.push(recommended)
    
        if showTrending then
            recommended.hideIfTrending = true
            shows = api.getAmlgVariantShows(recommended.variant, 0, 1, true)
            if shows.count() = 0 then
                ' We either don't have recommendations, or they're the same as trending
                ' so remove the recommended row
                rows.pop()
            end if
    
            row = createObject("roSGNode", "AmlgShowGroup")
            row.title = "Trending Now"
            row.variant = "showRecommendationTrending"
            rows.push(row)
        end if
    end if

    homeRows = api.getHomeRows(10)
    if isArray(homeRows) then
        rows.append(homeRows)
    else if isAssociativeArray(homeRows) then
        m.top.errorCode = asInteger(homeRows.errorCode)
    end if

    liveTVChannels = loadLiveChannels(api)
    localStations = loadLocalLiveStations(api)
    stationID = getGlobalField("localStation")
    updateLocalChannel(localStations, liveTVChannels, stationID)
    
    liveTVChannels.title = "Live TV"
    rows.push(liveTVChannels)

    content.rows = rows
    m.top.content = content
end sub
