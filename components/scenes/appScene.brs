sub init()
    m.top.backgroundUri = ""
    m.top.backgroundColor = "0x000000ff"
    m.top.setFocus(true)
    m.top.observeField("focusedChild", "onFocusChanged")
    
    m.screens = m.top.findNode("screens")
    m.dialogs = m.top.findNode("dialogs")
    m.waitRect = m.top.findNode("waitRect")
    m.loading = m.top.findNode("loading")
    m.spinner = m.top.findNode("spinner")

    m.dialogTimer = m.top.findNode("dialogTimer")
    m.dialogTimer.observeField("fire", "onDialogTimerFired")

    addGlobalField("cbsDialog", "node", false)
    observeGlobalField("cbsDialog", "onDialogChanged")
    
    if GetLinkStatus() = false then
        dialog = createCbsDialog("", "There is a problem connecting to the network." + chr(10) + "Please check your network settings.", ["OK"])
        dialog.observeField("buttonSelected", "onExitDialogButtonSelected")
        setGlobalField("cbsDialog", dialog)
    end if

    addGlobalField("showWaitScreen", "boolean", true)
    observeGlobalField("showWaitScreen", "onShowWaitScreen")
    
    m.navigationStack = []

    observeGlobalField("storeDisplayed", "onStoreDisplayed")
    m.allowBackKey = true
end sub

sub reinit(params = {} as object)
    m.initTask = createObject("roSGNode", "InitializationTask")
    m.initTask.observeField("initialized", "onInitialized")
    m.initTask.control = "RUN"
end sub

sub onFocusChanged(nodeEvent as object)
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    ?"appScene.onKeyEvent", key, press
    if press then
        if key = "back" then
            if not m.allowBackKey then
                print "***** Key Lockout is Active, so keypress eaten"
                return true
            end if
            if not goBackInNavigationStack() then
                menu = m.global.findNode("menu")
                if menu <> invalid then
                    if menu.isInFocusChain() then
                        dialog = createCbsDialog("", "Are you sure you would like to exit CBS All Access?", ["No", "Yes"])
                        dialog.observeField("buttonSelected", "onExitDialogButtonSelected")
                        setGlobalField("cbsDialog", dialog)
                    else
                        menu.setFocus(true)
                    end if
                else
                        dialog = createCbsDialog("", "Are you sure you would like to exit CBS All Access?", ["No", "Yes"])
                        dialog.observeField("buttonSelected", "onExitDialogButtonSelected")
                        setGlobalField("cbsDialog", dialog)
                end if
            end if
            return true
        else if key = "unknown" then
            nodes = m.top.getAll()
            counts = {}
            for each node in nodes
                counts[node.subtype()] = asInteger(counts[node.subtype()]) + 1
                if node.subtype() = "Poster" then
                    ?node.uri
                end if
            next
            ?"NODE COUNTS: ";counts
            ?"NODE TOTAL: ";nodes.count()
        else if key = "options" then
        end if
    end if
    return false
end function

sub onExitDialogButtonSelected(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    button = nodeEvent.getData()
    menu = m.global.findNode("menu")
    if menu <> invalid then menu.setFocus(true)
    if button = "Yes" or button = "OK" then
        m.top.close = true
    end if
    dialog.close = true
end sub

sub onInitialized(nodeEvent as object)
    m.initTask = invalid

    config = getGlobalField("config")
    if config <> invalid and config.enableTaplytics = true then
        m.taplytics = m.top.findNode("taplytics")
        m.taplytics.callFunc("startTaplytics", {})
    end if

    'signUp("PROD1")
    signIn()
end sub

sub signIn(username = "" as string, password = "" as string)
    setGlobalField("showWaitScreen", true)
    m.signInTask = createObject("roSGNode", "SignInTask")
    m.signInTask.observeField("signedIn", "onSignedIn")
    m.signInTask.username = username
    m.signInTask.password = password
    m.signInTask.control = "run"
end sub

sub onSignedIn(nodeEvent as object)
    ' Capture and reset the upsellItem here, in case one of the subsequent calls
    ' needs to set it
    upsellItem = m.upsellItem
    m.upsellItem = invalid

    config = getGlobalField("config")

    task = nodeEvent.getRoSGNode()

    setGlobalField("cookies", task.cookies)
    setGlobalField("localStation", task.localStation)
    setGlobalField("localStationLatitude", task.localStationLatitude)
    setGlobalField("localStationLongitude", task.localStationLongitude)
    setGlobalField("lastLiveChannel", task.lastLiveChannel)
    setGlobalField("user", task.user)

    user = getGlobalField("user")
    user.favorites.update = true
    user.videoHistory.update = true

    ' Notify Roku that we're an authenticated user
    if isAuthenticated(m.top) then
        trackRMFEvent("Roku_Authenticated")
        
        adobe = getGlobalField("adobe")
        if adobe <> invalid then
            adobe.syncIdentifier = user.id
        end if
    end if

    if m.taplytics <> invalid then
        m.taplytics.callFunc("setUserAttributes", { user_id: user.id, plan: user.trackingProduct })
    end if

    clearNavigationStack()
    
    dialog = getGlobalField("dialog")
    if dialog <> invalid then
        dialog.close = true
    end if
    setGlobalField("showWaitScreen", false)
    if upsellItem <> invalid then
        if isString(upsellItem) then
            if upsellItem = "liveTV" then
                showLiveTVScreen()
            end if
        else
            if canWatch(upsellItem, m.top, true) then
                if upsellItem.subtype() = "Episode" then
                    showVideoScreen(upsellItem.id, upsellItem.getParent(), m.upsellSource)
                else
                    showVideoScreen(upsellItem.id, invalid, m.upsellSource, -1, false)
                end if
            else
                if isAuthenticated(m.top) and not isSubscriber(m.top) then
                    if m.navigationStack.count() = 0 then
                        ' This is the first screen of the app, so we need to give
                        ' the user something to "back" up to from the upsell
                        showUpsellScreen()
                    end if
                    m.upsellItem = upsellItem
                    showAccountUpsellScreen("reg")
                else
                    showUpsellScreen(upsellItem)
                end if
            end if
        end if
    else
        if isAuthenticated(m.top) then
            if not isSubscriber(m.top) then
                if m.navigationStack.count() = 0 then
                    ' This is the first screen of the app, so we need to give
                    ' the user something to "back" up to from the upsell
                    showUpsellScreen()
                end if
                showAccountUpsellScreen("reg")
                m.top.ecp = invalid
            else
                showHomeScreen()
            end if
        else
            if m.top.deeplink = invalid and (m.top.ecp = invalid or m.top.ecp.mediaType = invalid) then
                showUpsellScreen()
            else
                showHomeScreen()
            end if
        end if
        if m.top.deeplink <> invalid then
            openDeepLink(m.top.deeplink)
        else
            openDeepLink(m.top.ecp)
        end if 
    end if
    m.top.ecp = invalid
    m.signInTask = invalid
    
    ' (re)load show cache
    setGlobalField("shows", [])
    m.showCacheTask = createObject("roSGNode", "LoadShowsTask")
    m.showCacheTask.observeField("shows", "onShowCacheLoaded")
    m.showCacheTask.groupID = config.allShowsGroupID
    m.showCacheTask.control = "run"
end sub

sub onDeeplinkChanged(nodeEvent as object)
    deeplink = nodeEvent.getData()
    if deeplink <> invalid and not deeplink.isEmpty() then
        openDeepLink(deeplink)
    end if
end sub

sub onShowCacheLoaded(nodeEvent as object)
    shows = nodeEvent.getData()
    showCache = {}
    for each show in shows
        showCache[show.id] = show
    next
    setGlobalField("shows", shows)
    setGlobalField("showCache", showCache)
    m.showCacheTask = invalid
end sub

sub confirmSignOut()
    dialog = createCbsDialog("", "Are you sure you want to sign out?", ["No", "Yes"])
    dialog.observeField("buttonSelected", "onSignOutDialogButtonSelected")
    setGlobalField("cbsDialog", dialog)
end sub

sub onSignOutDialogButtonSelected(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    button = nodeEvent.getData()
    if button = "Yes" then
        signOut()
    end if
    dialog.close = true
end sub

sub signOut()
    setGlobalField("showWaitScreen", true)
    m.signOutTask = createObject("roSGNode", "SignOutTask")
    m.signOutTask.observeField("signedOut", "onSignedOut")
    m.signOutTask.control = "run"
end sub

sub onSignedOut()
    clearNavigationStack()
    setGlobalField("showWaitScreen", false)

    if m.taplytics <> invalid then
        m.taplytics.callFunc("resetAppUser")
    end if

    showUpsellScreen()
end sub

sub upgrade()
    user = getGlobalField("user")
    if user.isRokuSubscriber then
        showAccountUpsellScreen("upgrade")
    else
        showAccountUpsellScreen("upgradeExternal")
    end if
end sub

sub downgrade()
    user = getGlobalField("user")
    if user.isRokuSubscriber then
        showAccountUpsellScreen("downgrade")
    else
        showAccountUpsellScreen("downgradeExternal")
    end if
end sub

sub showTestScreen()
    screen = createObject("roSGNode", "TestScreen")
    addToNavigationStack(screen)
end sub

sub showUpsellScreen(item = invalid as object, bypassUpsellIfAuth = false as boolean)
    m.upsellItem = item
    if bypassUpsellIfAuth and isAuthenticated(m.top) then
        showAccountUpsellScreen("reg")
        return
    end if
    screen = createObject("roSGNode", "UpsellScreen")
    screen.observeField("buttonSelected", "onUpsellButtonSelected")
    screen.upsellType = "launch"
    
    signUpText = constants().signUpText
    signInText = constants().signInText
    browseText = constants().browseText
    buttons = [
        signUpText
        signInText
        browseText
    ]
    screen.buttons = buttons
    addToNavigationStack(screen)
end sub

sub showLiveTVUpsellScreen()
    screen = createObject("roSGNode", "UpsellScreen")
    screen.observeField("buttonSelected", "onUpsellButtonSelected")
    screen.upsellType = "liveTV"
    m.upsellItem = "liveTV"
    
    signUpText = constants().signUpText
    signInText = constants().signInText
    browseText = constants().browseText
    buttons = [
        signUpText
        signInText
        browseText
    ]
    screen.buttons = buttons
    addToNavigationStack(screen)
end sub

sub showAccountUpsellScreen(mode = "newSub" as string)
    screen = createObject("roSGNode", "AccountUpsellScreen")
    screen.observeField("buttonSelected", "onUpsellButtonSelected")
    screen.observeField("optionSelected", "onUpsellOptionSelected")
    screen.mode = mode
    addToNavigationStack(screen)
end sub

sub onUpsellButtonSelected(nodeEvent as object)
    source = nodeEvent.getRoSGNode()
    button = nodeEvent.getData()
    if button = constants().signUpText then
        showAccountUpsellScreen()
    else if button = constants().signInText then
        showSignInScreen()
    else if button = constants().browseText then
        showHomeScreen()
    else if button = constants().switchText then
        if source.options <> invalid then
            option = source.options[0]
            if option <> invalid then
                performDowngrade(option.productCode)
            end if
        end if
    else if button = constants().tourText then
        showVideoScreen(source.tourVideoID, invalid, source)
    end if
end sub

sub onUpsellOptionSelected(nodeEvent as object)
    source = nodeEvent.getRoSGNode()
    option = nodeEvent.getData()
    if source.mode = "newSub" then
        signUp(option.productCode)
    else if source.mode = "reg" then
        performSubscription(option.productCode)
    else if source.mode = "upgrade" then
        performUpgrade(option.productCode)
    else if source.mode = "downgrade" then
        performDowngrade(option.productCode)
    end if
end sub

sub signUp(productCode as string)
    screen = createObject("roSGNode", "CreateAccountScreen")
    screen.observeField("buttonSelected", "onButtonSelected")
    screen.observeField("accountDetails", "onAccountDetailsCollected")
    screen.productCode = productCode
    addToNavigationStack(screen)
end sub

sub onAccountDetailsCollected(nodeEvent as object)
    source = nodeEvent.getRoSGNode()
    details = nodeEvent.getData()
    if details <> invalid then
        'showTosScreen(source.productCode, details)
        setGlobalField("showWaitScreen", true)

        m.createTask = createObject("roSGNode", "CreateAccountTask")
        m.createTask.observeField("success", "onCreateAccountSuccess")
        m.createTask.productCode = source.productCode
        m.createTask.accountDetails = details
        m.createTask.control = "run"
    else
        clearNavigationStack("UpsellScreen")
    end if
end sub

sub showTosScreen()
    screen = createObject("roSGNode", "TOSScreen")
    screen.observeField("buttonSelected", "onTosButtonSelected")
    addToNavigationStack(screen)
end sub

sub onTosButtonSelected(nodeEvent as object)
    goBackInNavigationStack()
'    source = nodeEvent.getRoSGNode()
'    button = nodeEvent.getData()
'    if button = "agree" then
'        setGlobalField("showWaitScreen", true)
'
'        m.createTask = createObject("roSGNode", "CreateAccountTask")
'        m.createTask.observeField("success", "onCreateAccountSuccess")
'        m.createTask.productCode = source.productCode
'        m.createTask.accountDetails = source.accountDetails
'        m.createTask.control = "run"
'    else
'        clearNavigationStack("UpsellScreen")
'    end if
end sub

sub onCreateAccountSuccess(nodeEvent as object)
    m.createTask = invalid
    setGlobalField("showWaitScreen", false)
    config = getGlobalField("config")
    task = nodeEvent.getRoSGNode()
    if task <> invalid then
        product = task.product
        if product = invalid then
            product = {
                price: "$0.00"
                cost: "$0.00"
            }
        end if
        if task.success then
            dialog = createCbsDialog("Congratulations!", "Your CBS All Access account has been created.", ["OK"])
            dialog.observeField("buttonSelected", "onCreateAccountSuccessDialogClose")
            setGlobalField("cbsDialog", dialog)

            params = {}
            screenName = "all-access/subscription/payment/confirmation/"
            pageType = "svod_complete"
            siteHier = iif(params["purchasePrice"] = "5.99", "billing|payment complete|limited commercial", "billing|payment complete|commercial free")
            params["siteHier"] = "billing|payment complete"
            params["purchaseProduct"] = "new"
            params["purchaseOrderID"] = asString(task.transactionID)
            params["purchasePrice"] = asString(product.price).replace("$", "")
            ' It seems at some point "price" changed to "cost", so support both
            if isNullOrEmpty(params["purchasePrice"]) then
                params["purchasePrice"] = asString(product.cost).replace("$", "")
            end if
            params["purchaseCategory"] = iif(params["purchasePrice"] = "5.99", "limited commercials", "commercial free")
            params["purchaseProductName"] = iif(params["purchasePrice"] = "5.99", "limited commercials", "commercial free")
            params["purchaseQuantity"] = "1"
            params["productPricingPlan"] = "monthly"
            params["productOfferperiod"] = "1-week trial"
            params["purchasePaymentMethod"] = "roku"
            params["purchaseEventOrderComplete"] = "1"
            params["&&products"] = join([params["purchaseCategory"], params["purchaseProduct"], params["purchaseQuantity"], params["purchasePrice"]], ";")
            trackScreenAction("trackPaymentComplete", params, screenName, pageType, ["event76"], siteHier)

            trackRMFEvent("USC")
        else
            if task.error <> "NO_TRANSACTION_ID" then
                dialog = createCbsDialog("Error", "An error occurred when creating your CBS All Access account. Please contact customer support for assistance at " + config.supportPhone + ".", ["OK"])
                dialog.observeField("buttonSelected", "onCreateAccountFailDialogClose")
                setGlobalField("cbsDialog", dialog)

                params = {}
                screenName = "/all access/upsell"
                pageType = "billing_failure" 'iif(product.price.replace("$", "") = "5.99", "billing_failure_Limited Commercial", "billing_failure_Commercial Free")
                siteHier = "upsell|payment|fail"
                trackScreenAction("trackAppLog", params, screenName, pageType, ["event20"], siteHier)
            end if
        end if
    else
        dialog = createCbsDialog("Error", "An error occurred validating your subscription. Please contact customer support for assistance at " + config.supportPhone + ".", ["OK"])
        dialog.observeField("buttonSelected", "onCreateAccountFailDialogClose")
        setGlobalField("cbsDialog", dialog)
    end if
end sub

sub onCreateAccountSuccessDialogClose(nodeEvent as object)
    setGlobalField("showWaitScreen", true)

    dialog = nodeEvent.getRoSGNode()
    if dialog <> invalid then
        dialog.close = true
    end if
    clearNavigationStack()
    reinit()
end sub

sub onCreateAccountFailDialogClose(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    if dialog <> invalid then
        dialog.close = true
    end if
    clearNavigationStack("UpsellScreen")
    setGlobalField("showWaitScreen", false)
end sub

sub performSubscription(productCode as string)
    setGlobalField("showWaitScreen", true)

    m.subTask = createObject("roSGNode", "SubscriptionTask")
    m.subTask.observeField("success", "onSubscriptionSuccess")
    user = getGlobalField("user")
    if user.status = "EX_SUBSCRIBER" then
        m.subTask.type = "exsub"
    else
        m.subTask.type = "sub"
    end if
    m.subTask.productCode = productCode
    m.subTask.control = "run"
end sub

sub performUpgrade(productCode as string)
    setGlobalField("showWaitScreen", true)

    m.subTask = createObject("roSGNode", "SubscriptionTask")
    m.subTask.observeField("success", "onSubscriptionSuccess")
    m.subTask.type = "upgrade"
    m.subTask.productCode = productCode
    m.subTask.control = "run"
end sub

sub performDowngrade(productCode as string)
    setGlobalField("showWaitScreen", true)

    m.subTask = createObject("roSGNode", "SubscriptionTask")
    m.subTask.observeField("success", "onSubscriptionSuccess")
    m.subTask.type = "downgrade"
    m.subTask.productCode = productCode
    m.subTask.control = "run"
end sub

sub onSubscriptionSuccess(nodeEvent as object)
    m.subTask = invalid
    setGlobalField("showWaitScreen", false)
    config = getGlobalField("config")
    task = nodeEvent.getRoSGNode()
    if task <> invalid then
        if task.success then
            product = task.product
            if product = invalid then
                product = {
                    price: "$0.00"
                    cost: "$0.00"
                }
            end if
            if task.type = "upgrade" then
                params = {}
                screenName = "all-access/subscription/payment/confirmation/"
                pageType = "svod_complete"
                siteHier = "billing|payment complete|upgrade"
                params["purchaseOrderID"] = task.transactionID
                params["purchaseCategory"] = "commercial free"
                params["purchaseProduct"] = "upgrade"
                params["purchaseProductName"] = "commercial free"
                params["productOfferperiod"] = "full"
                params["purchaseQuantity"] = "1"
                params["purchasePrice"] = asString(product.price).replace("$", "")
                ' It seems at some point "price" changed to "cost", so support both
                if isNullOrEmpty(params["purchasePrice"]) then
                    params["purchasePrice"] = asString(product.cost).replace("$", "")
                end if
                params["&&products"] = join([params["purchaseCategory"], params["purchaseProduct"], params["purchaseQuantity"], params["purchasePrice"]], ";")
                trackScreenAction("trackUpgrade", params, screenName, pageType, ["event107"], siteHier)
            else if task.type = "downgrade" then
                params = {}
                screenName = "all-access/subscription/payment/confirmation/"
                pageType = "billing|downgrade complete"
                siteHier = "billing|payment complete|downgrade"
                params["purchaseOrderID"] = task.transactionID
                params["purchaseCategory"] = "limited commercials"
                params["purchaseProduct"] = "downgrade"
                params["productOfferperiod"] = "full"
                params["purchaseProductName"] = "limited commercials"
                params["purchaseQuantity"] = "1"
                params["purchasePrice"] = asString(product.price).replace("$", "")
                ' It seems at some point "price" changed to "cost", so support both
                if isNullOrEmpty(params["purchasePrice"]) then
                    params["purchasePrice"] = asString(product.cost).replace("$", "")
                end if
                params["&&products"] = join([params["purchaseCategory"], params["purchaseProduct"], params["purchaseQuantity"], params["purchasePrice"]], ";")
                trackScreenAction("trackDowngrade", params, screenName, pageType, ["event108"], siteHier)
            else if task.type = "exsub" then
                dialog = createCbsDialog("Congratulations!", "Your account has been re-activated!", ["OK"])
                dialog.observeField("buttonSelected", "onSubscriptionSuccessDialogClose")
                setGlobalField("cbsDialog", dialog)
                return
            else if task.type = "sub" then
            end if

            trackRMFEvent("USC")

            clearNavigationStack("AccountUpsellScreen")
            goBackInNavigationStack()
            reinit()
        else
            if isNullOrEmpty(task.error) then
                if task.type = "upgrade" then
                    params = {}
                    screenName = "/all access/upsell"
                    pageType = "billing_failure"
                    siteHier = "upsell|payment|fail"
                    trackScreenAction("trackUpgrade", params, screenName, pageType, [], siteHier)
                else if task.type = "downgrade" then
                    params = {}
                    screenName = "/all access/upsell"
                    pageType = "billing_failure"
                    siteHier = "upsell|payment|fail"
                    trackScreenAction("trackDowngrade", params, screenName, pageType, [], siteHier)
                else if task.type = "sub" then
                end if

                dialog = createCbsDialog("Error", "An error occurred when switching your CBS All Access plan. Please contact customer support for assistance at " + config.supportPhone + ".", ["OK"])
                dialog.observeField("buttonSelected", "onSubscriptionFailDialogClose")
                setGlobalField("cbsDialog", dialog)
            end if
        end if
    else
        dialog = createCbsDialog("Error", "An error occurred validating your subscription. Please contact customer support for assistance at " + config.supportPhone + ".", ["OK"])
        dialog.observeField("buttonSelected", "onSubscriptionFailDialogClose")
        setGlobalField("cbsDialog", dialog)
    end if
end sub

sub onSubscriptionSuccessDialogClose(nodeEvent as object)
    setGlobalField("showWaitScreen", true)

    clearNavigationStack("AccountUpsellScreen")
    goBackInNavigationStack()
    dialog = nodeEvent.getRoSGNode()
    if dialog <> invalid then
        dialog.close = true
    end if
    signIn()
end sub

sub onSubscriptionFailDialogClose(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    if dialog <> invalid then
        dialog.close = true
    end if
    goBackInNavigationStack()
end sub

sub showSignInScreen()
    screen = createObject("roSGNode", "SignInScreen")
    screen.observeField("buttonSelected", "onButtonSelected")
    addToNavigationStack(screen)
end sub

sub showEmailSignInScreen()
    screen = createObject("roSGNode", "EmailSignInScreen")
    screen.observeField("buttonSelected", "onButtonSelected")
    screen.observeField("success", "onSignedIn")
    addToNavigationStack(screen, false)
end sub

sub showRendezvousScreen()
    screen = createObject("roSGNode", "RendezvousScreen")
    screen.observeField("success", "onRendezvousSuccess")
    addToNavigationStack(screen)
end sub

sub onRendezvousSuccess(nodeEvent as object)
    success = nodeEvent.getData()
    if success = true then
        clearNavigationStack()
        signIn()
    end if
end sub

sub showHomeScreen()
    screen = createObject("roSGNode", "HomeScreen")
    screen.observeField("itemSelected", "onItemSelected")
    screen.observeField("buttonSelected", "onButtonSelected")
    screen.observeField("menuItemSelected", "onMenuItemSelected")
    addToNavigationStack(screen, true, true)
end sub

sub showShowsScreen(category = "" as string)
    screen = createObject("roSGNode", "ShowsScreen")
    screen.category = category
    screen.observeField("itemSelected", "onItemSelected")
    screen.observeField("buttonSelected", "onButtonSelected")
    screen.observeField("menuItemSelected", "onMenuItemSelected")
    addToNavigationStack(screen, true, true)
end sub

sub showMoviesScreen()
    screen = createObject("roSGNode", "MoviesScreen")
    screen.observeField("itemSelected", "onItemSelected")
    screen.observeField("buttonSelected", "onButtonSelected")
    screen.observeField("menuItemSelected", "onMenuItemSelected")
    addToNavigationStack(screen, true, true)
end sub

sub showLiveTVScreen()
    if isSubscriber(m.top) then
        current = getCurrentScreen()
        if current <> invalid and current.subtype() = "LiveTVScreen" then
            current.showChannels = true
        else
            screen = createObject("roSGNode", "LiveTVScreen")
            screen.observeField("itemSelected", "onItemSelected")
            screen.observeField("buttonSelected", "onButtonSelected")
            screen.observeField("menuItemSelected", "onMenuItemSelected")
            addToNavigationStack(screen, true, true)
        end if
    else
        if isAuthenticated(m.top) then
            m.upsellItem = "liveTV"
            showAccountUpsellScreen("reg")
        else
            showLiveTVUpsellScreen()
        end if
    end if
end sub

sub showLiveFeedScreen(liveFeed as object, source = invalid as object)
    screen = createObject("roSGNode", "LiveFeedScreen")
    if source <> invalid then
        screen.omnitureName = source.omnitureName
        screen.omniturePageType = source.omniturePageType
        screen.omnitureData = source.omnitureData
    end if
    screen.liveFeed = liveFeed

    'screen.observeField("itemSelected", "onItemSelected")
    screen.observeField("buttonSelected", "onButtonSelected")
    addToNavigationStack(screen)
end sub

sub showSearchScreen()
    screen = createObject("roSGNode", "SearchScreen")
    screen.observeField("itemSelected", "onItemSelected")
    screen.observeField("menuItemSelected", "onMenuItemSelected")
    addToNavigationStack(screen, true, true)
end sub

sub showSettingsScreen()
    screen = createObject("roSGNode", "SettingsScreen")
    screen.observeField("itemSelected", "onItemSelected")
    screen.observeField("menuItemSelected", "onMenuItemSelected")
    screen.observeField("buttonSelected", "onButtonSelected")
    addToNavigationStack(screen, true, true)
end sub

sub showShowScreen(showID = "" as string, episodeID = "" as string, source = invalid as object, replaceCurrent = false as boolean, autoplay = false as boolean)
    screen = createObject("roSGNode", "ShowScreen")
    screen.showID = showID
    screen.episodeID = episodeID
    screen.autoplay = autoplay
    if source <> invalid then
        if source.hasField("additionalContext") then
            screen.additionalContext = source.additionalContext
        end if
    end if
    screen.observeField("itemSelected", "onItemSelected")
    screen.observeField("buttonSelected", "onButtonSelected")
    addToNavigationStack(screen, true, replaceCurrent)
end sub

sub showShowInfoScreen(showID as string)
    screen = createObject("roSGNode", "ShowInfoScreen")
    screen.observeField("buttonSelected", "onButtonSelected")
    screen.showID = showID
    addToNavigationStack(screen)
end sub

sub showEpisodeScreen(episode as object, episodeID = "" as string, autoPlay = false as boolean, source = invalid as object, replaceCurrent = false as boolean)
    screen = createObject("roSGNode", "EpisodeScreen")
    if source <> invalid then
        screen.omnitureName = source.omnitureName
        screen.omniturePageType = source.omniturePageType
        screen.omnitureData = source.omnitureData
        if source.hasField("additionalContext") then
            screen.additionalContext = source.additionalContext
        end if
        
        ' override autoplay, if the source screen has it set (typically for "series" deeplink)
        if source.autoplay = true then
            ' reset outoplay on the source
            source.autoplay = false
            autoPlay = true
        end if
    end if
    screen.autoPlay = autoPlay
    if episode <> invalid then
        screen.episode = episode
    else
        screen.episodeID = episodeID
    end if
    'screen.observeField("itemSelected", "onItemSelected")
    screen.observeField("buttonSelected", "onButtonSelected")
    addToNavigationStack(screen, true, replaceCurrent)
end sub

sub showMovieScreen(movie as object, movieID = "" as string, autoPlay = false as boolean, source = invalid as object)
    screen = createObject("roSGNode", "MovieScreen")
    if source <> invalid then
        screen.omnitureData = source.omnitureData
    end if
    screen.autoPlay = autoPlay
    if movie <> invalid then
        screen.movie = movie
    else
        screen.movieID = movieID
    end if
    'screen.observeField("itemSelected", "onItemSelected")
    screen.observeField("buttonSelected", "onButtonSelected")
    addToNavigationStack(screen)
end sub

sub showUvpVideoScreen(episodeID as string, section = invalid as object, source = invalid as object)
    screen = createObject("roSGNode", "UvpVideoScreen")
    screen.episodeID = episodeID
    screen.section = section
    if source <> invalid then
        screen.omnitureData = source.omnitureData
    end if
    addToNavigationStack(screen)
end sub

sub showVideoScreen(episodeID as string, section = invalid as object, source = invalid as object, resumePoint = -1 as integer, useDai = true as boolean)
    config = getGlobalField("config")
    if config.enableGeoBlock and config.currentCountryCode <> config.appCountryCode and not config.geoBlocked then
        dialog = createCbsDialog("", "Due to licensing restrictions, video is not available outside your country.", ["CLOSE"])
        dialog.observeField("buttonSelected", "onLicensingDialogClosed")
        setGlobalField("cbsDialog", dialog)
        return
    end if

    screen = createObject("roSGNode", "VideoScreen")
    screen.observeField("buttonSelected", "onButtonSelected")
    screen.useDai = useDai and config.useDai
    screen.episodeID = episodeID
    screen.resumePoint = resumePoint
    screen.section = section
    if source <> invalid then
        screen.omnitureData = source.omnitureData
        if source.hasField("additionalContext") then
            screen.additionalContext = source.additionalContext
        end if
    end if
    addToNavigationStack(screen)
end sub

sub onLicensingDialogClosed(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    button = nodeEvent.getData()
    if button = "CLOSE" then
        dialog.close = true
    end if
end sub

function openDeepLink(params as object, item = invalid as object) as boolean
    if params <> invalid then
        ' If video is currently playing, close the video screen
        current = getCurrentScreen()
        if current <> invalid and current.subtype() = "VideoScreen" then
            current.close = true
        end if

        if not isNullOrEmpty(params.correlator) then
            setGlobalField("correlator", params.correlator)
        end if
        if params.source <> invalid and params.mediaType <> invalid then
            deeplink = ""
            if params.source = "meta-search" then
                deeplink = "roku_global_search|roku|search"
            else
                deeplink = "roku_" + params.source + "|roku|referral"
            end if
            deeplink = deeplink + "|open"
            setGlobalField("deeplinkForTracking", deeplink)
        end if
        if params.mediaType = "screen" then
            if params.contentID = "home" then
                showHomeScreen()
                return true
            else if params.contentID = "shows" then
                showShowsScreen(asString(params.category))
                return true
            else if params.contentID = "movies" then
                showMoviesScreen()
                return true
            else if params.contentID.inStr("live-tv") = 0 then
                liveTVChannel = params.contentID.mid(8)
                ' "stream" is used to indicate the last played stream
                ' versus an empty string which indicates local
                if liveTVChannel <> "stream" then
                    setGlobalField("lastLiveChannel", liveTVChannel)
                end if
                showLiveTVScreen()
                return true
            else if params.contentID = "all-access" then
                showUpsellScreen()
                return true
            end if
        else if params.mediaType = "episode" or params.mediaType = "short-form" then
            showEpisodeScreen(invalid, params.contentID, true)
            return true
        else if params.mediaType = "episodedetails" then
            showEpisodeScreen(invalid, params.contentID, false)
            return true
        else if params.mediaType = "movie" then
            showMovieScreen(invalid, params.contentID, true)
            return true
        else if params.mediaType = "moviedetails" then
            showMovieScreen(invalid, params.contentID, false)
            return true
        else if params.mediaType = "series" or params.mediaType = "special" then
            if not isNullOrEmpty(params.contentID) then
                if params.mediaType = "series" then
                    showShowScreen("", params.contentID, invalid, false, true)
                else
                    showShowScreen(params.contentID)
                end if
                return true
            else if item <> invalid then
                showShowScreen(item.showID)
                return true
            end if
        else if params.mediaType = "season" then
            if not isNullOrEmpty(params.contentID) then
                showShowScreen("", params.contentID)
                return true
            end if
        end if
    end if
    return false
end function

function showLoading()
    m.loading.visible = true
    if m.spinner.state <> "running" then
        m.spinner.control = "start"
    end if
end function

function hideLoading()
    m.loading.visible = false
    m.spinner.control = "stop"
end function

sub onShowWaitScreen(nodeEvent as object)
    m.waitRect.visible = nodeEvent.getData()
    m.loading.visible = nodeEvent.getData()
    if m.loading.visible then
        m.spinner.control = "start"
    else
        m.spinner.control = "stop"
    end if
end sub

sub onDialogChanged(nodeEvent as object)
    dialog = nodeEvent.getData()
    if dialog <> invalid then
        dialog.unobserveField("close")
        dialog.observeField("close", "onDialogClosed")
        if dialog.subtype() = "CbsDialog" then
            m.dialogs.appendChild(dialog)
            dialog.setFocus(true)
            setGlobalField("cbsDialog", invalid)
        else if (m.top.dialog = invalid or not dialog.isSameNode(m.top.dialog)) then
            if m.top.dialog <> invalid then
                ' HACK: When swapping out the modal dialog, if one is already open
                '       the device will hang and reboot, so we use a timer to insert
                '       a delay before updating the dialog
                m.top.dialog.close = true
                'm.top.dialog = invalid
                m.dialogTimer.control = "start"
            else
                m.top.dialog = dialog
                m.top.dialog.setFocus(true)
                setGlobalField("cbsDialog", invalid)
            end if
        end if
    end if
end sub

sub onDialogClosed(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    if dialog <> invalid then
        dialog.unobserveField("close")
        current = invalid
        if dialog.subtype() = "CbsDialog" then
            m.dialogs.removeChild(dialog)
            current = dialog.returnFocus
        end if
        if m.dialogs.getChildCount() > 0 then
            current = m.dialogs.getChild(m.dialogs.getChildCount() - 1)
        end if
        if current = invalid then
            current = getCurrentScreen()
        end if
        if current <> invalid then
            current.setFocus(true)
        end if
    end if
end sub

sub onDialogTimerFired()
    m.top.dialog = getGlobalField("cbsDialog")
    if m.top.dialog <> invalid then
        m.top.dialog.setFocus(true)
        setGlobalField("cbsDialog", invalid)
    end if
end sub

sub clearNavigationStack(targetScreen = "" as string)
    screen = invalid
    while goBackInNavigationStack(false)
        screen = m.navigationStack.peek()
        if screen <> invalid and screen.subtype() = targetScreen then
            exit while
        end if
    end while
    if screen <> invalid then
        screen.visible = true
        screen.setFocus(true)
    end if
end sub

function goBackInNavigationStack(setFocus = true as boolean) as boolean
    if m.navigationStack.count() > 1 then
        episodeID = ""
        screen = m.navigationStack.pop()
        if isSGNode(screen) then
            screen.visible = false
            screen.unobserveField("close")
            if screen.subtype().inStr("VideoScreen") >= 0 then
                screen.control = "stop"
                ' Capture the episode ID, so we can update the episode screen, if appropriate
                episodeID = screen.episodeID

                ' update the recently watched
                user = getGlobalField("user")
                user.videoHistory.update = true
                user.continueWatching.update = true
                user.showHistory.update = true
            else if screen.subtype() = "LiveTVScreen" then
                screen.control = "stop"
            else
                m.screens.removeChild(screen)
            end if
        end if
        if setFocus then
            screen = m.navigationStack.peek()
            if isSGNode(screen) then
                if screen.subtype() = "EpisodeScreen" then
                    if not isNullOrEmpty(episodeID) then
                        ' update the episode screen to the last viewed video
                        screen.episodeID = episodeID
                    end if
                end if
                screen.visible = true
                screen.setFocus(true)
            else
                history = m.navigationStack.pop()
                if history.screenType = "HomeScreen" then
                    showHomeScreen()
                else if history.screenType = "ShowScreen" then
                    showShowScreen(history.showID)
                else if history.screenType = "EpisodeScreen" then
                    showEpisodeScreen(history.episode)
                end if
            end if
            
            ' close the wait spinner, if open
            hideSpinner()
            setGlobalField("showWaitScreen", false)
        end if
        return true
    end if
    return false
end function

sub addToNavigationStack(screen as object, setFocus = true as boolean, replaceCurrent = false as boolean)
    if m.navigationStack.count() > 0 then
        previous = m.navigationStack.peek()
        if isSGNode(previous) then
            previous.visible = false
        end if
        if replaceCurrent then
            m.navigationStack.pop()
            if isSGNode(previous) then
                previous.unobserveField("close")
                m.screens.removeChild(previous)
            end if
        else
            if isSGNode(previous) and getGlobalField("extremeMemoryManagement") = true then
                history = {
                    screenType: previous.subtype()
                }
                if history.screenType = "HomeScreen" then
                else if history.screenType = "ShowScreen" then
                    history.showID = previous.showID
                else if history.screenType = "EpisodeScreen" then
                    history.episode = previous.episode
                else
                    history = invalid
                end if
                if history <> invalid then
                    previous.unobserveField("close")
                    m.screens.removeChild(previous)
                    m.navigationStack.pop()
                    m.navigationStack.push(history)
                    ?runGarbageCollector()
                end if
            end if
        end if
    end if
    
    screen.observeField("close", "onScreenClosed")
    
    m.navigationStack.push(screen)
    m.screens.appendChild(screen)
    
    if setFocus then
        screen.visible = true
        screen.setFocus(true)
    end if
end sub

sub onScreenClosed(nodeEvent as object)
    screen = nodeEvent.getRoSGNode()
    if screen <> invalid then
        screen.unobserveField("close")
    end if
    goBackInNavigationStack()
end sub

function getCurrentScreen() as object
    return m.navigationStack.peek()
end function

sub onButtonSelected(nodeEvent as object)
    buttonID = nodeEvent.getData()
    source = nodeEvent.getRoSGNode()
    if buttonID = "showInfo" then
        if source.subtype() = "EpisodeScreen" then
            showShowInfoScreen(source.episode.showID)
        else if source.subtype() = "LiveFeedScreen" then
            showShowScreen(source.liveFeed.showID)
        else if source.hasField("showID") then
            showShowInfoScreen(source.showID)
        end if
    else if buttonID = "show" then
        if source.subtype() = "EpisodeScreen" then
            showShowScreen(source.episode.showID, "", source)
        else if source.subtype() = "LiveFeedScreen" then
            showShowScreen(source.liveFeed.showID, "", source)
        else if source.hasField("showID") then
            showShowScreen(source.showID, "", source)
        end if
    else if buttonID = "favorite" then
        toggleFavorite(source.showID, m.top)
    else if buttonID = "liveTV" then
        showLiveTVScreen()
    else if buttonID = "watch" or buttonID = "resume" then
        if source.hasField("episode") and source.episode <> invalid then
            episode = source.episode
            if canWatch(episode, m.top) then
                showVideoScreen(episode.ID, episode.getParent(), source, iif(buttonID = "resume", episode.resumePoint, 0))
            else
                showUpsellScreen(episode, true)
            end if
        else if source.hasField("liveFeed") and source.liveFeed <> invalid then
            liveFeed = source.liveFeed
            if canWatch(liveFeed, m.top) then
                showVideoScreen(liveFeed.id, liveFeed.getParent(), source)
            else
                showUpsellScreen(liveFeed, true)
            end if
        else if source.hasField("movie") and source.movie <> invalid then
            movie = source.movie
            if canWatch(movie, m.top) then
                showVideoScreen(movie.id, movie.getParent(), source, iif(buttonID = "resume", movie.resumePoint, 0))
            else
                showUpsellScreen(movie, true)
            end if
        end if
    else if buttonID = "trailer" then
        if source.hasField("movie") and source.movie <> invalid then
            movie = source.movie
            if movie.trailer <> invalid then
                if canWatch(movie.trailer, m.top) then
                    showVideoScreen(movie.trailer.id, invalid, source)
                else
                    showUpsellScreen(movie.trailer, true)
                end if
            end if
        end if
    else if buttonID = "freeTrial" then
        showAccountUpsellScreen()
    else if buttonID = "signIn"
        showSignInScreen()
    else if buttonID = "signInOnWeb" then
        showRendezvousScreen()
    else if buttonID = "signInWithEmail" then
        showEmailSignInScreen()
    else if buttonID = "signOut" then
        confirmSignOut()
    else if buttonID = "manageAccount" then
        downgrade()
    else if buttonID = "upgrade" then
        upgrade()
    else if buttonID = "tos" then
        showTosScreen()
    else if buttonID = "back" or buttonID = "close" then
        goBackInNavigationStack()
    end if
end sub

sub onItemSelected(nodeEvent as object)
    source = nodeEvent.getRoSGNode()
    item = nodeEvent.getData()
    ?"onItemSelected()", item.title
    if item <> invalid then
        if source <> invalid then
            ' set the source field to invalid, so we don't get further updates
            source.setField(nodeEvent.getField(), invalid)
        end if
        
        if item.hasField("clickCallbackUrl") and not isNullOrEmpty(item.clickCallbackUrl) then
            loadCallbackUrl(item.clickCallbackUrl)
        end if

        if item.subtype() = "Episode" then
            showEpisodeScreen(item, "", false, source, false)
        else if item.subtype() = "LiveTVChannel" then
            setGlobalField("lastLiveChannel", item.scheduleType)
            showLiveTVScreen()
        else if item.subtype() = "LiveFeed" then
            showLiveFeedScreen(item, source)
        else if item.subtype() = "Show" or item.subtype() = "RelatedShow" or item.subtype() = "ShowGroupItem" then
            showShowScreen(item.id, "", source)
        else if item.subtype() = "Favorite" then
            showShowScreen(item.showID)
        else if item.subtype() = "SearchResult" then
            if item.type = "show" then
                showShowScreen(item.id)
            else if item.type = "movie" then
                showMovieScreen(invalid, item.id)
            end if
        else if item.subtype() = "MarqueeSlide" then
            if not isNullOrEmpty(item.deeplink) then
                openDeepLink(parseDeepLink(item.deeplink), item)
            else if not isNullOrEmpty(item.showID) then
                showShowScreen(item.showID)
            end if
        else if item.subtype() = "Movie" then
            'showMovieScreen(item, "", false, source)
            showMovieScreen(invalid, item.id, false, source)
        end if
    end if
end sub

sub onMenuItemSelected(nodeEvent as object)
    menuItem = nodeEvent.getData()
    if menuItem = "home" 
        showHomeScreen()
    else if menuItem = "shows" then
        showShowsScreen()
    else if menuItem = "liveTV" then
        showLiveTVScreen()
    else if menuItem = "movies" then
        showMoviesScreen()
    else if menuItem = "search" then
        showSearchScreen()
    else if menuItem = "settings" then
        showSettingsScreen()
    end if
end sub
