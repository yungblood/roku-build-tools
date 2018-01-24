sub init()
    m.top.backgroundUri = ""
    m.top.backgroundColor = "0x000000ff"
    m.top.setFocus(true)
    m.top.observeField("focusedChild", "onFocusChanged")

'    m.uvpVideoScreen = m.top.findNode("uvpVideoScreen")
'    m.videoScreen = m.top.findNode("videoScreen")

'    m.liveTVScreen = m.top.findNode("liveTVScreen")
'    m.liveTVScreen.observeField("itemSelected", "onItemSelected")
'    m.liveTVScreen.observeField("buttonSelected", "onButtonSelected")
'    m.liveTVScreen.observeField("menuItemSelected", "onMenuItemSelected")

    m.screens = m.top.findNode("screens")
    m.dialogs = m.top.findNode("dialogs")
    m.waitRect = m.top.findNode("waitRect")
    m.loading = m.top.findNode("loading")
    m.spinner = m.top.findNode("spinner")

    m.dialogTimer = m.top.findNode("dialogTimer")
    m.dialogTimer.observeField("fire", "onDialogTimerFired")

    m.global.addField("dialog", "node", false)
    m.global.observeField("dialog", "onDialogChanged")
    
    m.global.addField("showSpinner", "boolean", true)
    m.global.observeField("showSpinner", "onShowSpinner")
    m.global.addField("showWaitScreen", "boolean", true)
    m.global.observeField("showWaitScreen", "onShowWaitScreen")
    
    m.navigationStack = []

    m.initTask = createObject("roSGNode", "InitializationTask")
    m.initTask.observeField("initialized", "onInitialized")
    m.initTask.control = "RUN"
end sub

sub onFocusChanged()
'    if m.dialogs.getChildCount() > 0 then
'        if not m.dialogs.isInFocusChain() then
'            dialog = m.dialogs.getChild(m.dialogs.getChildCount() - 1)
'            if not dialog.close then
'                dialog.close = true
'            end if
'        end if
'    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    ?"appScene.onKeyEvent", key, press
    if press then
        if key = "back" then
            if not goBackInNavigationStack() then
                dialog = createCbsDialog("", "Are you sure you would like to exit CBS All Access?", ["No", "Yes"])
                dialog.observeField("buttonSelected", "onExitDialogButtonSelected")
                m.global.dialog = dialog
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
        end if
    end if
    return false
end function

sub onExitDialogButtonSelected(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    button = nodeEvent.getData()
    if button = "Yes" then
        m.top.close = true
    end if
    dialog.close = true
end sub

sub onInitialized()
    m.initTask = invalid
    signIn()
end sub

sub signIn(username = "" as string, password = "" as string)
    m.global.showWaitScreen = true
    m.signInTask = createObject("roSGNode", "SignInTask")
    m.signInTask.observeField("signedIn", "onSignedIn")
    m.signInTask.username = username
    m.signInTask.password = password
    m.signInTask.control = "run"
end sub

sub onSignedIn(nodeEvent as object)
    clearNavigationStack()
    if m.global.dialog <> invalid then
        m.global.dialog.close = true
    end if
    m.global.showWaitScreen = false
    if m.upsellItem <> invalid then
        if isString(m.upsellItem) then
            if m.upsellItem = "liveTV" then
                showLiveTVScreen()
            end if
        else
            if canWatch(m.upsellItem, m.global, true) then
                if m.upsellItem.subtype() = "Episode" then
                    showDaiVideoScreen(m.upsellItem.id, m.upsellItem.getParent(), m.upsellSource)
                    'showVideoScreen(m.upsellItem.id, m.upsellItem.getParent(), m.upsellSource)
                else
                    showVideoScreen(m.upsellItem.id, invalid, m.upsellSource)
                end if
            else
                showUpsellScreen(m.upsellItem)
            end if
        end if
    else
        if isAuthenticated(m.global) then
            if not isSubscriber(m.global) then
                showAccountUpsellScreen("reg")
            else
                showHomeScreen()
            end if
        else
            showUpsellScreen()
        end if
        openDeepLink(m.top.ecp)
    end if
    m.top.ecp = invalid
    m.upsellItem = invalid
    m.signInTask = invalid
end sub

sub confirmSignOut()
    dialog = createCbsDialog("", "Are you sure you want to sign out?", ["No", "Yes"])
    dialog.observeField("buttonSelected", "onSignOutDialogButtonSelected")
    m.global.dialog = dialog
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
    m.global.showWaitScreen = true
    m.signOutTask = createObject("roSGNode", "SignOutTask")
    m.signOutTask.observeField("signedOut", "onSignedOut")
    m.signOutTask.control = "run"
end sub

sub onSignedOut()
    clearNavigationStack()
    m.global.showWaitScreen = false

    showUpsellScreen()
end sub

sub upgrade()
    user = m.global.user
    if user.isRokuSubscriber then
        showAccountUpsellScreen("upgrade")
    else
        showAccountUpsellScreen("upgradeExternal")
    end if
end sub

sub downgrade()
    user = m.global.user
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

sub showUpsellScreen(item = invalid as object)
    screen = createObject("roSGNode", "UpsellScreen")
    screen.observeField("buttonSelected", "onUpsellButtonSelected")
    screen.upsellType = "launch"
    m.upsellItem = item
    
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
        'showDaiVideoScreen(source.tourVideoID, invalid, source)
        showDaiVideoScreen(source.tourVideoID, invalid, source)
        'showVideoScreen(source.tourVideoID, invalid, source)
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
        showTosScreen(source.productCode, details)
    end if
end sub

sub showTosScreen(productCode as string, accountDetails as object)
    screen = createObject("roSGNode", "TOSScreen")
    screen.observeField("buttonSelected", "onTosButtonSelected")
    screen.productCode = productCode
    screen.accountDetails = accountDetails
    addToNavigationStack(screen)
end sub

sub onTosButtonSelected(nodeEvent as object)
    source = nodeEvent.getRoSGNode()
    button = nodeEvent.getData()
    if button = "agree" then
        m.global.showWaitScreen = true

        m.createTask = createObject("roSGNode", "CreateAccountTask")
        m.createTask.observeField("success", "onCreateAccountSuccess")
        m.createTask.productCode = source.productCode
        m.createTask.accountDetails = source.accountDetails
        m.createTask.control = "run"
    else
        clearNavigationStack("UpsellScreen")
    end if
end sub

sub onCreateAccountSuccess(nodeEvent as object)
    m.createTask = invalid
    m.global.showWaitScreen = false
    task = nodeEvent.getRoSGNode()
    if task <> invalid then
        product = task.product
        if product = invalid then
            product = {
                price: "$0.00"
            }
        end if
        if task.success then
            dialog = createCbsDialog("Congratulations!", "Your CBS All Access account has been created.", ["OK"])
            dialog.observeField("buttonSelected", "onCreateAccountSuccessDialogClose")
            m.global.dialog = dialog

'            params = {}
'            screenName = "/all access/upsell"
'            pageType = "billing|payment complete"
'            params["purchaseProduct"] = "new"
'            params["purchaseOrderID"] = task.transactionID
'            params["purchasePrice"] = product.price.replace("$", "")
'            params["purchaseCategory"] = iif(params["purchasePrice"] = "5.99", "limited commercials", "commercial free")
'            params["purchaseProductName"] = iif(params["purchasePrice"] = "5.99", "limited commercials", "commercial free")
'            params["purchaseQuantity"] = "1"
'            params["&&products"] = join([params["purchaseCategory"], params["purchaseProduct"], params["purchaseQuantity"], params["purchasePrice"]], ";")
'            trackScreenAction("trackPaymentComplete", params, screenName, pageType, ["event76"])
        else
            if task.error <> "NO_TRANSACTION_ID" then
                dialog = createCbsDialog("Error", "An error occurred when creating your CBS All Access account. Please contact customer support for assistance at " + m.global.config.supportPhone + ".", ["OK"])
                dialog.observeField("buttonSelected", "onCreateAccountFailDialogClose")
                m.global.dialog = dialog

'                params = {}
'                screenName = "/all access/upsell"
'                pageType = iif(product.price.replace("$", "") = "5.99", "billing_failure_Limited Commercial", "billing_failure_Commercial Free")
'                trackScreenAction("trackAppLog", params, screenName, pageType, ["event20"])
            end if
        end if
    else
        dialog = createCbsDialog("Error", "An error occurred validating your subscription. Please contact customer support for assistance at " + m.global.config.supportPhone + ".", ["OK"])
        dialog.observeField("buttonSelected", "onCreateAccountFailDialogClose")
        m.global.dialog = dialog
    end if
end sub

sub onCreateAccountSuccessDialogClose(nodeEvent as object)
    m.global.showWaitScreen = true

    clearNavigationStack("UpsellScreen")
    goBackInNavigationStack()
    dialog = nodeEvent.getRoSGNode()
    if dialog <> invalid then
        dialog.close = true
    end if
    signIn()
end sub

sub onCreateAccountFailDialogClose(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    if dialog <> invalid then
        dialog.close = true
    end if
    clearNavigationStack("UpsellScreen")
    m.global.showWaitScreen = false
end sub

sub performSubscription(productCode as string)
    m.global.showWaitScreen = true

    m.subTask = createObject("roSGNode", "SubscriptionTask")
    m.subTask.observeField("success", "onSubscriptionSuccess")
    if m.global.user.status = "EX_SUBSCRIBER" then
        m.subTask.type = "exsub"
    else
        m.subTask.type = "sub"
    end if
    m.subTask.productCode = productCode
    m.subTask.control = "run"
end sub

sub performUpgrade(productCode as string)
    m.global.showWaitScreen = true

    m.subTask = createObject("roSGNode", "SubscriptionTask")
    m.subTask.observeField("success", "onSubscriptionSuccess")
    m.subTask.type = "upgrade"
    m.subTask.productCode = productCode
    m.subTask.control = "run"
end sub

sub performDowngrade(productCode as string)
    m.global.showWaitScreen = true

    m.subTask = createObject("roSGNode", "SubscriptionTask")
    m.subTask.observeField("success", "onSubscriptionSuccess")
    m.subTask.type = "downgrade"
    m.subTask.productCode = productCode
    m.subTask.control = "run"
end sub

sub onSubscriptionSuccess(nodeEvent as object)
    m.subTask = invalid
    m.global.showWaitScreen = false
    task = nodeEvent.getRoSGNode()
    if task <> invalid then
        if task.success then
            product = task.product
            if product = invalid then
                product = {
                    price: "$0.00"
                }
            end if
            if task.type = "upgrade" then
'                params = {}
'                screenName = "/all access/upsell"
'                pageType = "billing|upgrade complete"
'                params["purchaseOrderID"] = task.transactionID
'                params["purchaseCategory"] = "commercial free"
'                params["purchaseProduct"] = "upgrade"
'                params["purchaseProductName"] = "commercial free"
'                params["purchaseQuantity"] = "1"
'                params["purchasePrice"] = product.price.replace("$", "")
'                params["&&products"] = join([params["purchaseCategory"], params["purchaseProduct"], params["purchaseQuantity"], params["purchasePrice"]], ";")
'                trackScreenAction("trackUpgrade", params, screenName, pageType, ["event107"])
            else if task.type = "downgrade" then
'                params = {}
'                screenName = "/all access/upsell"
'                pageType = "billing|downgrade complete"
'                params["purchaseOrderID"] = task.transactionID
'                params["purchaseCategory"] = "limited commercials"
'                params["purchaseProduct"] = "downgrade"
'                params["purchaseProductName"] = "limited commercials"
'                params["purchaseQuantity"] = "1"
'                params["purchasePrice"] = product.price.replace("$", "")
'                params["&&products"] = join([params["purchaseCategory"], params["purchaseProduct"], params["purchaseQuantity"], params["purchasePrice"]], ";")
'                trackScreenAction("trackDowngrade", params, screenName, pageType, ["event108"])
            else if task.type = "exsub" then
                dialog = createCbsDialog("Congratulations!", "Your account has been re-activated!", ["OK"])
                dialog.observeField("buttonSelected", "onSubscriptionSuccessDialogClose")
                m.global.dialog = dialog
                return
            else if task.type = "sub" then
            end if

            clearNavigationStack("AccountUpsellScreen")
            goBackInNavigationStack()
            signIn()
        else
            if isNullOrEmpty(task.error) then
                if task.type = "upgrade" then
'                    params = {}
'                    screenName = "/all access/upsell"
'                    pageType = "billing_failure_Commercial Free"
'                    trackScreenAction("trackUpgrade", params, screenName, pageType)
                else if task.type = "downgrade" then
'                    params = {}
'                    screenName = "/all access/upsell"
'                    pageType = "billing_failure_Limited Commercial"
'                    trackScreenAction("trackDowngrade", params, screenName, pageType)
                else if task.type = "sub" then
                end if

                dialog = createCbsDialog("Error", "An error occurred when switching your CBS All Access plan. Please contact customer support for assistance at " + m.global.config.supportPhone + ".", ["OK"])
                dialog.observeField("buttonSelected", "onSubscriptionFailDialogClose")
                m.global.dialog = dialog
            end if
        end if
    else
        dialog = createCbsDialog("Error", "An error occurred validating your subscription. Please contact customer support for assistance at " + m.global.config.supportPhone + ".", ["OK"])
        dialog.observeField("buttonSelected", "onSubscriptionFailDialogClose")
        m.global.dialog = dialog
    end if
end sub

sub onSubscriptionSuccessDialogClose(nodeEvent as object)
    m.global.showWaitScreen = true

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
    addToNavigationStack(screen)
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
    if isSubscriber(m.global) then
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
        if isAuthenticated(m.global) then
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

sub showShowScreen(showID = "" as string, replaceCurrent = false as boolean)
    screen = createObject("roSGNode", "ShowScreen")
    screen.showID = showID
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

sub showDaiVideoScreen(episodeID as string, section = invalid as object, source = invalid as object)
    'showUvpVideoScreen(episodeID, section, source)
    'return

    screen = createObject("roSGNode", "DaiVideoScreen")
    screen.useDai = true
    screen.episodeID = episodeID
    screen.section = section
    if source <> invalid then
        screen.omnitureData = source.omnitureData
    end if
    addToNavigationStack(screen)
end sub

sub showVideoScreen(episodeID as string, section = invalid as object, source = invalid as object)
    screen = createObject("roSGNode", "DaiVideoScreen")
    screen.useDai = false
    screen.episodeID = episodeID
    screen.section = section
    if source <> invalid then
        screen.omnitureData = source.omnitureData
    end if
    addToNavigationStack(screen)
'    m.videoScreen.episodeID = episodeID
'    m.videoScreen.section = section
'    if source <> invalid then
'        m.videoScreen.omnitureData = source.omnitureData
'    end if
'    addToNavigationStack(m.videoScreen)
end sub

function openDeepLink(params as object, item = invalid as object) as boolean
    if params <> invalid then
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
                    m.global.liveTVChannel = liveTVChannel
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
        else if params.mediaType = "series" or params.mediaType = "season" or params.mediaType = "special" then
            if not isNullOrEmpty(params.contentID) then
                showShowScreen(params.contentID)
                return true
            else if item <> invalid then
                showShowScreen(item.showID)
                return true
            end if
        end if
    end if
    return false
end function

sub onShowSpinner(nodeEvent as object)
    m.loading.visible = nodeEvent.getData()
    if m.loading.visible then
        if m.spinner.state <> "running" then
            m.spinner.control = "start"
        end if
    else
        m.spinner.control = "stop"
    end if
end sub

sub onShowWaitScreen(nodeEvent as object)
    m.waitRect.visible = nodeEvent.getData()
    m.loading.visible = nodeEvent.getData()
    if m.loading.visible then
        m.spinner.control = "start"
    else
        m.spinner.control = "stop"
    end if
end sub

sub onDialogChanged()
    dialog = m.global.dialog
    if dialog <> invalid then
        dialog.unobserveField("close")
        dialog.observeField("close", "onDialogClosed")
        if dialog.subtype() = "CbsDialog" then
            m.dialogs.appendChild(dialog)
            dialog.setFocus(true)
            m.global.dialog = invalid
        else if (m.top.dialog = invalid or not m.global.dialog.isSameNode(m.top.dialog)) then
            if m.top.dialog <> invalid then
                ' HACK: When swapping out the modal dialog, if one is already open
                '       the device will hang and reboot, so we use a timer to insert
                '       a delay before updating the dialog
                m.top.dialog.close = true
                'm.top.dialog = invalid
                m.dialogTimer.control = "start"
            else
                m.top.dialog = m.global.dialog
                m.top.dialog.setFocus(true)
                m.global.dialog = invalid
            end if
        end if
    end if
end sub

sub onDialogClosed(nodeEvent as object)
    dialog = nodeEvent.getRoSGNode()
    if dialog <> invalid then
        dialog.unobserveField("close")
        if dialog.subtype() = "CbsDialog" then
            m.dialogs.removeChild(dialog)
        end if
        current = invalid
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
    m.top.dialog = m.global.dialog
    if m.top.dialog <> invalid then
        m.top.dialog.setFocus(true)
        m.global.dialog = invalid
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
        screen = m.navigationStack.pop()
        if isSGNode(screen) then
            screen.visible = false
            screen.unobserveField("close")
            if screen.subtype().inStr("VideoScreen") >= 0 then
                screen.control = "stop"
                
                ' update the recently watched
                m.global.user.recentlyWatched.update = true
            else if screen.subtype() = "LiveTVScreen" then
                screen.control = "stop"
            else
                m.screens.removeChild(screen)
            end if
        end if
        if setFocus then
            screen = m.navigationStack.peek()
            if isSGNode(screen) then
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
            m.global.showSpinner = false
            m.global.showWaitScreen = false
        end if
        return true
    end if
    return false
end function

sub addToNavigationStack(screen as object, setFocus = true as boolean, replaceCurrent = false as boolean)
    ?"addToNavigationStack()",screen.subtype()
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
            if isSGNode(previous) and m.global.extremeMemoryManagement then
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
            showShowScreen(source.episode.showID)
        else if source.subtype() = "LiveFeedScreen" then
            showShowScreen(source.liveFeed.showID)
        else if source.hasField("showID") then
            showShowScreen(source.showID)
        end if
    else if buttonID = "favorite" then
        toggleFavorite(source.showID, m.global)
    else if buttonID = "watch" then
        if source.hasField("episode") and source.episode <> invalid then
            episode = source.episode
            if canWatch(episode, m.global) then
                showDaiVideoScreen(episode.ID, episode.getParent(), source)
                'showVideoScreen(episode.ID, episode.getParent(), source)
            else
                showUpsellScreen(episode)
            end if
        else if source.hasField("liveFeed") and source.liveFeed <> invalid then
            liveFeed = source.liveFeed
            if canWatch(liveFeed, m.global) then
                showVideoScreen(liveFeed.id, liveFeed.getParent(), source)
            else
                showUpsellScreen(liveFeed)
            end if
        else if source.hasField("movie") and source.movie <> invalid then
            movie = source.movie
            if canWatch(movie, m.global) then
                showVideoScreen(movie.id, movie.getParent(), source)
            else
                showUpsellScreen(movie)
            end if
        end if
    else if buttonID = "trailer" then
        if source.hasField("movie") and source.movie <> invalid then
            movie = source.movie
            if movie.trailer <> invalid then
                if canWatch(movie.trailer, m.global) then
                    showDaiVideoScreen(movie.trailer.id, invalid, source)
                    'showVideoScreen(movie.trailer.id, invalid, source)
                else
                    showUpsellScreen(movie.trailer)
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
    else if buttonID = "back" or buttonID = "close" then
        goBackInNavigationStack()
    end if
end sub

sub onItemSelected(nodeEvent as object)
    source = nodeEvent.getRoSGNode()
    item = nodeEvent.getData()
    ?"onItemSelected()", item.title
    if item <> invalid then
        if item.subtype() = "Episode" then
            showEpisodeScreen(item, "", false, source)
        else if item.subtype() = "LiveFeed" then
            showLiveFeedScreen(item, source)
        else if item.subtype() = "Show" or item.subtype() = "RelatedShow" or item.subtype() = "ShowGroupItem" then
            showShowScreen(item.id)
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
    if menuItem = "home" then
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

