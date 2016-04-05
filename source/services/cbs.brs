Function Cbs() As Object
    If m.Cbs = invalid Then
        m.Cbs = NewCbs()
    End If
    Return m.Cbs
End Function

Function NewCbs() As Object
    this                            = {}
    this.ClassName                  = "Cbs"
    
    this.AuthTokenKey               = "AuthToken"
    
    this.ShowCache                  = {}
    this.AllShows                   = []
    this.ResumePoints               = {}
    this.ResumeOffset               = 3
    
    this.UseStaging                 = False
    this.IsSearchScreenOpened       = False
    this.IsSettingsScreenOpened     = False
    this.AutoPlayEnabled            = True
    
    this.RokuProductCode            = "com.cbsallaccess.subscription.trial" ' "PROD1"
    this.ProductCode                = "CBS_ALL_ACCESS_PACKAGE" '
    this.SignUpUrl                  = "cbs.com/all-access"
    this.TosUrl                     = "http://www.cbs.com/sites/roku/cbs_roku.cfg"
    this.LegalUrl                   = "http://www.cbs.com/sites/roku/cbs_roku_legal_notices.cfg"
    
    this.CSNumber                   = "(888) 274-5343"
    
    this.StagingApiKey              = "c3d24e796cbc78c7"
    this.StagingEndpoint            = "https://test-www.cbs.com/apps-api/"
    this.StagingCodeAuthUrl         = "test-www.cbs.com/roku"
    this.StagingSyncbakKey          = "db166d252cf24aa982a220a4b8475e25"
    this.StagingSyncbakSecret       = "40c9f215dafb43149924e75baf05b5dc"
    this.StagingSyncbakEndpoint     = "https://stage-cbsservice.aws.syncbak.com"
    this.StagingOmnitureSuiteID     = "cbsicbsott-dev,cbsicbsiall-dev"
    this.StagingOmnitureEvar5       = "cbsicbsott-dev"
    this.StagingComScoreC2          = "3002231"
    this.StagingComScoreSecret      = "2cb08ca4d095dd734a374dff8422c2e5"
    this.StagingAkamaiUrl           = "http://ma61-r.analytics.edgesuite.net/config/beacon-5508.xml"
    this.StagingConvivaID           = "c3.CBSCom-Test"
    this.StagingConvivaKey          = "ce4836fb66f6e081bcf6fea7df4531f22ac7ffbb"
    
    this.ProductionApiKey           = "c3d24e796cbc78c7"
    this.ProductionEndpoint         = "https://www.cbs.com/apps-api/"
    this.ProductionCodeAuthUrl      = "cbs.com/roku"
    this.ProductionSyncbakKey       = "db166d252cf24aa982a220a4b8475e25"
    this.ProductionSyncbakSecret    = "40c9f215dafb43149924e75baf05b5dc"
    this.ProductionSyncbakEndpoint  = "https://cbsservice.aws.syncbak.com"
    this.ProductionOmnitureSuiteID  = "cbsicbsott,cbsicbsiall"
    this.ProductionOmnitureEvar5    = "cbsicbsott"
    this.ProductionComScoreC2       = "3002231"
    this.ProductionComScoreSecret   = "2cb08ca4d095dd734a374dff8422c2e5"
    this.ProductionAkamaiUrl        = "http://ma61-r.analytics.edgesuite.net/config/beacon-5508.xml"
    this.ProductionConvivaID        = "c3.CBSCom"
    this.ProductionConvivaKey       = "87a6b28bc7823e67a5bb2a0a6728c702afcae78d"
    
    this.NielsenAppID               = "PEEF1AF93-F59E-414A-96BE-DCE421E5C92D"
    
    this.AkamaiDims                 = {
        device:     "Roku"
        playerID:   GetAppVersion()
    }
    
    this.PhotoImageEndpoint         = "http://wwwimage.cbsstatic.com/thumbnails/photos/w[WIDTH]/"
    this.VideoImageEndpoint         = "http://wwwimage.cbsstatic.com/thumbnails/videos/w[WIDTH]/"
    
    this.StreamUrl                  = "http://link.theplatform.com/s/dJ5BDC/[PID]?mbr=true&manifest=m3u&format=redirect&assetTypes=StreamPack%7COTT"
    this.VmapUrl                    = "http://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/8264/vaw-can/ott/cbs_roku_app&ciu_szs=300x60,300x250&impl=s&gdfp_req=1&env=vp&output=xml_vmap1&unviewed_position_start=1&url=&description_url=&correlator=[timestamp]&scor=[timestamp]&cmsid=2289&vid=[CONTENTID]"
    
    this.ApiKey                     = this.ProductionApiKey
    this.Endpoint                   = this.ProductionEndpoint
    this.OmnitureSuiteID            = this.ProductionOmnitureSuiteID
    this.OmnitureEvar5              = this.ProductionOmnitureEvar5
    this.CodeAuthUrl                = this.ProductionCodeAuthUrl
    
    this.Initialize                 = Cbs_Initialize
    this.LoadDefaultContent         = Cbs_LoadDefaultContent
    
    this.Verify                     = Cbs_Verify
    
    this.GetIPAddress               = Cbs_GetIPAddress
    
    this.IsAuthenticated            = Cbs_IsAuthenticated
    this.IsSubscribed               = Cbs_IsSubscribed
    this.GetLinkCode                = Cbs_GetLinkCode
    this.CheckLinkCode              = Cbs_CheckLinkCode
    this.Logout                     = Cbs_Logout
    
    this.GetTosText                 = Cbs_GetTosText
    this.GetLegalText               = Cbs_GetLegalText
    
    this.GetUpsellInfo              = Cbs_GetUpsellInfo
    this.GetCodeAuthUrl             = Cbs_GetCodeAuthUrl
    
    this.CheckEmailExists           = Cbs_CheckEmailExists
    this.ValidateZipCode            = Cbs_ValidateZipCode
 
    this.Subscribe                  = Cbs_Subscribe
    this.CreateAccount              = Cbs_CreateAccount
    this.GetEntitlement             = Cbs_GetEntitlement
    
    this.GetHomeRows                = Cbs_GetHomeRows
    this.GetSectionVideos           = Cbs_GetSectionVideos
    
    this.SetResumePoint             = Cbs_SetResumePoint
    this.GetResumePoint             = Cbs_GetResumePoint
    this.IsOverStreamLimit          = Cbs_IsOverStreamLimit
    this.GetLiveChannels            = Cbs_GetLiveChannels
    this.GetLiveChannel             = Cbs_GetLiveChannel
    this.GetAffiliate               = Cbs_GetAffiliate
    
    this.GetBigBrotherStreams       = Cbs_GetBigBrotherStreams
    this.GetBigBrotherStreamToken   = Cbs_GetBigBrotherStreamToken
    
    this.GetFeaturedShows           = Cbs_GetFeaturedShows
    this.GetAllShows                = Cbs_GetAllShows
    this.GetGroups                  = Cbs_GetGroups
    this.GetGroupShows              = Cbs_GetGroupShows
    this.GetShow                    = Cbs_GetShow
    this.GetShowsByID               = Cbs_GetShowsByID
    this.IsShowCached               = Cbs_IsShowCached
    this.GetShowAvailableSeasons    = Cbs_GetShowAvailableSeasons
    this.GetShowSeasons             = Cbs_GetShowSeasons
    this.GetShowSections            = Cbs_GetShowSections
    this.GetShowSectionIDs          = Cbs_GetShowSectionIDs
    this.GetShowEpisodes            = Cbs_GetShowEpisodes
    this.GetShowClips               = Cbs_GetShowClips
    this.GetEpisode                 = Cbs_GetEpisode
    this.GetNextEpisode             = Cbs_GetNextEpisode
    
    this.GetCurrentUser             = Cbs_GetCurrentUser
    
    this.CreateFavoriteShows        = Cbs_CreateFavoriteShows
    this.GetFavoriteShowIDs         = Cbs_GetFavoriteShowIDs
    this.AddShowToFavorites         = Cbs_AddShowToFavorites
    this.RemoveShowFromFavorites    = Cbs_RemoveShowFromFavorites
    this.GetMyCbsEpisodes           = Cbs_GetMyCbsEpisodes
    this.GetRecentlyWatched         = Cbs_GetRecentlyWatched
    
    this.Search                     = Cbs_Search
    
    this.GetImageUrl                = Cbs_GetImageUrl
    
    this.Request                    = Cbs_Request
    this.OnResponse                 = Cbs_OnResponse
    this.ProcessResponse            = Cbs_ProcessResponse
    
    Return this
End Function

Function Cbs_Initialize(useStaging = False As Boolean) As Boolean
    m.UseStaging = useStaging
    If useStaging Then
        m.ApiKey            = m.StagingApiKey
        m.Endpoint          = m.StagingEndpoint
        m.CodeAuthUrl       = m.StagingCodeAuthUrl
        m.OmnitureSuiteID   = m.StagingOmnitureSuiteID
        m.OmnitureEvar5     = m.StagingOmnitureEvar5
        m.ComScoreC2        = m.StagingComScoreC2
        m.ComScoreSecret    = m.StagingComScoreSecret
        m.AkamaiUrl         = m.StagingAkamaiUrl
        Syncbak().Initialize(m.StagingSyncbakKey, m.StagingSyncbakSecret, m.StagingSyncbakEndpoint)

        ConvivaLivePassInit(m.StagingConvivaKey)
        ConvivaLivePassInstance().ToggleTraces(True)
        
        Roku_Ads().SetDebugOutput(True)
    Else
        m.ApiKey            = m.ProductionApiKey
        m.Endpoint          = m.ProductionEndpoint
        m.CodeAuthUrl       = m.ProductionCodeAuthUrl
        m.OmnitureSuiteID   = m.ProductionOmnitureSuiteID
        m.OmnitureEvar5     = m.ProductionOmnitureEvar5
        m.ComScoreC2        = m.ProductionComScoreC2
        m.ComScoreSecret    = m.ProductionComScoreSecret
        m.AkamaiUrl         = m.ProductionAkamaiUrl
        Syncbak().Initialize(m.ProductionSyncbakKey, m.ProductionSyncbakSecret, m.ProductionSyncbakEndpoint)

        'ConvivaLivePassInit(m.ProductionConvivaKey)

        ConvivaLivePassInit(m.StagingConvivaKey)
        'ConvivaLivePassInstance().ToggleTraces(True)
    End If
    Return m.Verify()
End Function

Function Cbs_LoadDefaultContent() As Boolean
    ' Pre-cache all shows
    m.GetAllShows(True)
    If m.AllShows.Count() = 0 Then
        ' We couldn't get the shows, so fail
        Return False
    End If
    
    ' Retrieve live TV
    m.GetLiveChannels()
    Return True
End Function

Function Cbs_Verify() As Boolean
    url = m.Endpoint + "v2.0/integration/token/verification.json"
    result = m.Request(url, "GET")
    Return (result <> invalid And Not IsNullOrEmpty(result.version))
End Function

Function Cbs_GetIPAddress(useCbsApi = True As Boolean) As String
    If useCbsApi Then
        url = "https://www.cbs.com/apps/user/ip.json"
        result = GetUrlToJson(url)
        If result <> invalid And result.success = True Then
            Return result.ip
        End If
    Else
        Return GetExternalIPAddress()
    End If
    Return "Unknown"
End Function

Function Cbs_IsAuthenticated(refresh = False As Boolean) As Boolean
    ' We want to refresh if forced, or we have no cookies
    refresh = refresh Or IsNullOrEmpty(GetCookiesForUrl(m.Endpoint))
    token = Configuration().Get(m.AuthTokenKey, "")
    If Not IsNullOrEmpty(token) Then
        If refresh Then
            Return m.CheckLinkCode(token)
        End If
        Return True
    End If
    Return False
End Function

Function Cbs_IsSubscribed() As Boolean
    Return m.GetCurrentUser().IsSubscriber()
End Function

Function Cbs_GetLinkCode() As Object
    url = m.Endpoint + "v2.0/ott/devices/roku/auth/code.xml"
    url = AddQueryString(url, "deviceId", GetDeviceID())
    url = AddQueryString(url, "ipAddress", m.GetIPAddress())
    url = AddQueryString(url, "newCode", "true")
    
    result = m.Request(url, "GET", invalid, "xml")
    If IsAssociativeArray(result) Then
        Return result.result
    End If
    Return invalid
End Function

Function Cbs_CheckLinkCode(code As String) As Boolean
    url = m.Endpoint + "v2.0/ott/devices/roku/auth/status.xml"
    url = AddQueryString(url, "deviceId", GetDeviceID())
    url = AddQueryString(url, "activationCode", code)
    
    result = m.Request(url, "GET", invalid, "xml")
    If IsAssociativeArray(result) And IsAssociativeArray(result.result) Then
        If result.result.status = "success" Then
            ' Store the authentication token
            Configuration().Set(m.AuthTokenKey, code)
            GlobalEventRegistry().RaiseEvent("AuthenticationChanged", { Authenticated: True })
            Return True
        End If
    End If
    Return False
End Function

Function Cbs_Logout() As Boolean
    url = m.Endpoint + "v2.0/ott/devices/roku/auth/deactivate.json"
    
    postData = {}
    postData["deviceId"] = GetDeviceID()
    
    result = m.Request(url, "POST", postData)
    ' Disconnect client-side regardless if deactivate call fails or not
    'If IsAssociativeArray(result) And result.success = True Then
        ' Reset the user data
        m.ResumePoints.Clear()
        m.CurrentUser = invalid
        Configuration().Remove(m.AuthTokenKey)
        DeleteCookiesForUrl(m.Endpoint)
        GlobalEventRegistry().RaiseEvent("AuthenticationChanged", { Authenticated: False })
        Return True
    'End If
    Return False
End Function

Function Cbs_GetTosText() As String
    If IsNullOrEmpty(m.TosText) Then
        m.TosText = GetUrlToString(m.TosUrl)
    End If
    Return m.TosText
End Function

Function Cbs_GetLegalText() As String
    If IsNullOrEmpty(m.LegalText) Then
        m.LegalText = GetUrlToString(m.LegalUrl)
    End If
    Return m.LegalText
End Function

Function Cbs_GetUpsellInfo() As Object
    url = m.Endpoint + "roku/upsell.json?pageURL=ROKU_ALL_ACCESS_TRIAL" 'ROKU_SIGN_UP_SCREEN" '
    result = m.Request(url, "GET")
    If IsAssociativeArray(result) And result.upsellInfo <> invalid Then
        state = m.GetCurrentUser().State
        If IsNullOrEmpty(state) Then
            state = "ANONYMOUS"
        End If
        upsellInfos = AsArray(result.upsellInfo)
        For Each upsellInfo In upsellInfos
            If ArrayContains(upsellInfo.userStateList, state) Then
                ' TODO: We're using _liveDate and _expireDate instead of liveDate and expireDate, 
                '       because Roku's json parser mangles 64-bit integers.  We should revisit
                '       after all devices have updated to firmware 7.x+
                liveDate = DateFromISO8601String(upsellInfo["_liveDate"]).AsSeconds()
                expireDate = DateFromISO8601String(upsellInfo["_expireDate"]).AsSeconds()
                current = NowDate().AsSeconds()
                If current >= liveDate And current <= expireDate Then
                    info = {
                        Headline:       AsString(upsellInfo.upsellMessage)
                        Message:        AsString(upsellInfo.upsellMessage2)
                        Background:     m.GetImageUrl(upsellInfo.upsellHDImagePath, 1280)
                        ProductCode:    AsString(upsellInfo.aaProductID)
                    }
                    If Not IsHD() Or IsNullOrEmpty(info.Background) Then
                        info.Background = m.GetImageUrl(upsellInfo.upsellImagePath, 720)
                    End If
                    Return info
                End If
            End If
        Next
    End If
    Return {}
End Function

Function Cbs_GetCodeAuthUrl() As String
    url = m.CodeAuthUrl
    Return url
End Function

Function Cbs_CheckEmailExists(email As String) As Boolean
    If Not IsNullOrEmpty(email) Then
        url = m.Endpoint + "v3.0/useraccount/email/exists.json"
        url = AddQueryString(url, "email", email)
        
        response = m.Request(url, "GET")
        If IsAssociativeArray(response) Then
            Return (response.success = True)
        End If
    End If
    Return False
End Function

Function Cbs_ValidateZipCode(zip As String) As Boolean
    If Not IsNullOrEmpty(zip) Then
        url = m.Endpoint + "v2.0/zipcode/check.json"
        url = AddQueryString(url, "zip", zip)
        url = AddQueryString(url, "country", "US")
        
        response = m.Request(url, "GET")
        If IsAssociativeArray(response) Then
            Return (response.success = True)
        End If
    End If
    Return False
End Function

Function Cbs_Subscribe(product As Object) As String
    If product <> invalid Then
        ' Do the channel store purchase first
        ChannelStore().ClearOrder()
        ChannelStore().AddToOrder(product)
        result = ChannelStore().DoOrder()
        If IsArray(result) And result.Count() > 0 Then
            transaction = result[0]
            Return AsString(transaction.PurchaseId)
        End If
    End If
    Return ""
End Function

Function Cbs_CreateAccount(userData As Object, transactionID As String) As Boolean
'    userData = {
'        FirstName:  ""
'        LastName:   ""
'        Email:      ""
'        Zip:        ""
'        Password:   ""
'        DOB:        ""
'        Gender:     ""
'    }

    If Not IsNullOrEmpty(transactionID) Then
        url = m.Endpoint + "v3.0/roku/useraccount/activate-registration.json"
        
        postData = {}
        postData["email"]           = userData.Email
        postData["password"]        = userData.Password
        postData["confirmPassword"] = userData.Password
        postData["firstName"]       = userData.FirstName
        postData["lastName"]        = userData.LastName
        postData["birthday"]        = userData.DOB
        postData["country"]         = "US"
        postData["gender"]          = UCase(AsString(userData.Gender))
        postData["mpid"]            = 4812
        postData["zip"]             = userData.Zip
        postData["optIn"]           = 1
        postData["deviceId"]        = GetDeviceID()

        response = m.Request(url, "POST", postData)
        If IsAssociativeArray(response) And response.success = True Then
            ' Get the entitlement           
            Return m.GetEntitlement(transactionID)
        End If
    End If
    Return False
End Function

Function Cbs_GetEntitlement(transactionID As String) As Boolean
    url = m.Endpoint + "v2.0/roku/entitlement/purchase.json"
    url = AddQueryString(url, "transactionId", transactionID)
    url = AddQueryString(url, "deviceId", GetDeviceID())
    url = AddQueryString(url, "newPackageCode", m.ProductCode)

    ' Attempt to get the entitlement up to three times
    For i = 1 To 3
        response = m.Request(url, "GET")
        If IsAssociativeArray(response) And response.success = True Then
            ' Store the authentication token
            Configuration().Set(m.AuthTokenKey, response.activationCode)
            Return m.IsAuthenticated(True)
        End If
        Sleep(1000)
    Next
    Return False
End Function

Function Cbs_GetHomeRows(itemsPerRow = 10 As Integer, maxCount = -1 As Integer) As Object
    rows = []
    
    url = m.Endpoint + "v2.0/roku/shows/199951/videos/config/SHOW_HOME_ROKU_SVOD.json"
    url = AddQueryString(url, "platformType", "roku")
    url = AddQueryString(url, "rows", itemsPerRow)
    url = AddQueryString(url, "excludeShow", True)
    
    response = m.Request(url, "GET")
    If IsAssociativeArray(response) And response.success = True Then
        For Each section In AsArray(response.results)
            row = {
                ID:             AsString(section.id)
                Name:           AsString(section.sectionTitle)
                Section:        NewSection(section)
            }
            If row.Section.TotalCount > 0 Then
                If maxCount > -1 And row.Section.TotalCount > maxCount Then
                    row.Section.SetTotalCount(maxCount)
                End If
                rows.Push(row)
            End If
        Next
    End If
    
    Return rows
End Function

Function Cbs_GetSectionVideos(sectionID As String, excludeShow = True As Boolean, params = {} As Object, startIndex = 0 As Integer, count = 10 As Integer, pageInfo = {} As Object) As Object
    videos = []
    pageInfo.StartIndex = startIndex
    pageInfo.Count = 0
    pageInfo.TotalCount = 0
    url = m.Endpoint + "v2.0/roku/videos/section/" + sectionID + ".json"
    url = AddQueryString(url, "begin", startIndex)
    url = AddQueryString(url, "rows", count)
    If excludeShow Then
        url = AddQueryString(url, "excludeShow", True)
    End If
    For Each param In params
        url = AddQueryString(url, param, params[param])
    Next
    response = m.Request(url, "GET")
    If IsAssociativeArray(response) And response.success = True Then
        If IsAssociativeArray(response.sectionItems) Then
            pageInfo.StartIndex = startIndex
            pageInfo.Count = AsArray(response.sectionItems.itemList).Count()
            pageInfo.TotalCount = AsInteger(response.sectionItems.itemCount)
            For Each item In AsArray(response.sectionItems.itemList)
                episode = NewEpisode(item)
                If episode.IsAvailable() Then
                    videos.Push(episode)
                End If
            Next
        End If
    End If
    Return videos
End Function

' **********************
' Playback
' **********************
Sub Cbs_SetResumePoint(contentID As String, position As Integer)
    m.ResumePoints[contentID] = position
End Sub

Function Cbs_GetResumePoint(contentID As String) As Integer
    If m.ResumePoints[contentID] = invalid And m.IsAuthenticated() Then
        url = m.Endpoint + "v3.0/roku/video/streams.json"
        url = AddQueryString(url, "contentId", contentID)
        
        response = m.Request(url, "GET")
        If IsAssociativeArray(response) And response.success = True Then
            m.ResumePoints[contentID] = AsInteger(response.mediaTime)
        End If
    End If
    Return AsInteger(m.ResumePoints[contentID]) - m.ResumeOffset
End Function

Function Cbs_IsOverStreamLimit() As Boolean
    url = m.Endpoint + "v3.0/roku/video/streams.json"
    
    response = m.Request(url, "GET")
    If IsAssociativeArray(response) And response.success = True Then
        Return AsBoolean(response.overThreshold, False)
    End If
    Return False
End Function

Function Cbs_GetLiveChannels() As Object
    If m.LiveChannels = invalid Then
        m.LiveChannels = Syncbak().GetChannels()
    End If
    Return m.LiveChannels
End Function

Function Cbs_GetLiveChannel() As Object
    If m.LiveChannel = invalid Then
        channels = Syncbak().GetChannels()
        m.LiveChannel = channels[0]
        If m.LiveChannel = invalid Then
            m.LiveChannel = {}
        End If
    End If
    Return m.LiveChannel
End Function

Function Cbs_GetAffiliate(station As String) As Object
    url = m.Endpoint + "v2.0/cbs/affiliate/search.json"
    url = AddQueryString(url, "affiliates", station)
    
    response = m.Request(url, "GET")
    If IsAssociativeArray(response) Then
        For Each item In AsArray(response.affiliates)
            affiliate = NewAffiliate(item)
            If affiliate.Station = station Then
                Return affiliate
            End If
        Next
    End If
    Return invalid
End Function

' **********************
' Big Brother
' **********************
Function Cbs_GetBigBrotherStreams() As Dynamic
    streams = []
    url = m.Endpoint + "v3.0/roku/video/bbl/streams.json"
    response = m.Request(url, "GET")
    If IsAssociativeArray(response) Then
        showID = AsString(response.show_id)
        For Each video In AsArray(response.video)
            stream = NewLiveFeed(video)
            stream.SetShowID(showID)
            streams.Push(stream)
        Next
    End If
    Return streams
End Function

Function Cbs_GetBigBrotherStreamToken(id As String, debug = False As Boolean) As String
    url = m.Endpoint + "v3.0/roku/video/bbl/token.json"
    url = AddQueryString(url, "stream", id)
    url = AddQueryString(url, "ip", m.GetIPAddress())
    If debug Then
        url = AddQueryString(url, "tokenGeneration", "true")
    End If

    response = m.Request(url, "GET")
    If IsAssociativeArray(response) Then
        Return AsString(response.token)
    End If
    Return ""
End Function

' **********************
' Shows
' **********************
Function Cbs_GetFeaturedShows() As Dynamic
    shows = []
    url = m.Endpoint + "v2.0/roku/shows/promo/featured.json"
    response = m.Request(url, "GET")
    If IsAssociativeArray(response) Then
        For Each showItem In AsArray(response.featuredShows)
            id = AsString(showItem.showId)
            If Not IsNullOrEmpty(id) Then
                show = m.GetShow(id)
                If show <> invalid Then
                    shows.Push(show)
                End If
            End If
        Next
    End If
    Return shows
End Function

Function Cbs_GetAllShows(refresh = False As Boolean) As Dynamic
    If refresh Or m.AllShows.Count() = 0 Then
        m.AllShows = []
        url = m.Endpoint + "v2.0/roku/shows/groups.json"
        url = AddQueryString(url, "includeAllShowGroups", True)
        response = m.Request(url, "GET")
        If IsAssociativeArray(response) And response.success = True Then
            For Each showItem In AsArray(response.all)
                show = NewShow(showItem)
                ' Cache it based on its ID
                m.ShowCache[show.ID] = show
                m.AllShows.Push(show)
            Next
        End If
    End If
    Return m.AllShows
End Function

Function Cbs_GetGroups() As Object
    groups = []
    url = m.Endpoint + "v2.0/roku/shows/groups.json"
    response = m.Request(url, "GET")
    If IsAssociativeArray(response) And response.success = True Then
        For Each item In AsArray(response.showGroups)
            groups.Push(NewShowGroup(item))
        Next
    End If
    Return groups
End Function

Function Cbs_GetGroupShows(id As String) As Object
    shows = []
    url = m.Endpoint + "v2.0/roku/shows/group/" + id + ".json"
    response = m.Request(url, "GET")
    If IsAssociativeArray(response) And response.success = True And IsAssociativeArray(response.group) Then
        For Each item In AsArray(response.group.showGroupItems)
            show = invalid
            If m.IsShowCached(AsString(item.showId)) Then
                show = m.GetShow(AsString(item.showId))
            Else
                show = NewShow(item)
                m.ShowCache[show.ID] = show
            End If
            If show <> invalid Then
                shows.Push(show)
            End If
        Next
    End If
    Return shows
End Function

Function Cbs_IsShowCached(showID As String) As Boolean
    Return m.ShowCache.DoesExist(showID)
End Function

Function Cbs_GetShow(showID As String) As Object
    If IsNullOrEmpty(showID) Or showID = "-1" Then
        Return invalid
    End If
    show = m.ShowCache[showID]
    If show = invalid Or (show.ClipCount = 0 And show.EpisodeCount = 0) Then
        url = m.Endpoint + "v2.0/roku/shows/" + showID + ".json"
        response = m.Request(url, "GET")
        If response <> invalid And response.show <> invalid Then
            show = NewShow(response)
            If Not IsNullOrEmpty(show.ID) Then
                m.ShowCache[showID] = show
            End If
        End If
    End If
    Return m.ShowCache[showID]
End Function

Function Cbs_GetShowsById(showIDs As Object) As Object
    shows = []
    For Each id In AsArray(showIDs)
        show = m.GetShow(id)
        If show <> invalid Then
            shows.Push(show)
        End If
    Next
    Return shows
End Function

Function Cbs_GetShowAvailableSeasons(showID As String) As Object
    seasons = []
    url = m.Endpoint + "v2.0/roku/shows/" + showID + "/video/season/availability.json" '".json"
    response = m.Request(url, "GET")
    If IsAssociativeArray(response) And response.success = True And IsAssociativeArray(response.video_available_season) Then
        For Each item In AsArray(response.video_available_season.itemList)
            seasons.Push({
                Number: AsInteger(item.seasonNum)
                TotalCount: AsInteger(item.totalCount)
            })
        Next
    End If
    Return seasons
End Function

Function Cbs_GetShowSeasons(showID As String, sectionID As String) As Object
    seasons = []
    show = m.GetShow(showID)
    If show <> invalid Then
        availableSeasons = m.GetShowAvailableSeasons(showID)
        If availableSeasons.Count() > 0 Then
            url = m.Endpoint + "v2.0/roku/shows/" + showID + ".json"
            response = m.Request(url, "GET")
            If IsAssociativeArray(response) And IsAssociativeArray(response.season) Then
                seasonDetails = AsArray(response.season.results)
                For Each availableSeason In availableSeasons
                    season = NewSeason()
                    season.Initialize(show, availableSeason.Number, sectionID)
                    season.SetTotalCount(availableSeason.TotalCount)
                    seasons.Push(season)
                Next
            End If
        End If
    End If
    Return seasons
End Function

Function Cbs_GetShowSections(showID As String) As Object
    sections = []
    If Not IsNullOrEmpty(showID) Then
        url = m.Endpoint + "v2.0/roku/shows/" + showID + "/videos/config/DEFAULT_ROKU_SVOD.json"
        url = AddQueryString(url, "platformType", "roku")
        url = AddQueryString(url, "begin", 0)
        url = AddQueryString(url, "rows", 0)
        response = m.Request(url, "GET")
        If IsAssociativeArray(response) And response.success = True And response.videoSectionMetadata <> invalid Then
            For Each result In AsArray(response.videoSectionMetadata)
                If IsAssociativeArray(result) Then
                    sections.Push(NewSection(result))
                End If
            Next
        End If
    End If
    Return sections
End Function

Function Cbs_GetShowSectionIDs(showID As String) As Object
    sectionIDs = {}
    If Not IsNullOrEmpty(showID) Then
        url = m.Endpoint + "v2.0/roku/shows/" + showID + "/videos/config/DEFAULT_ROKU_SVOD.json"
        url = AddQueryString(url, "platformType", "roku")
        url = AddQueryString(url, "begin", 0)
        url = AddQueryString(url, "rows", 0)
        response = m.Request(url, "GET")
        If IsAssociativeArray(response) And response.success = True And response.videoSectionMetadata <> invalid Then
            For Each result In AsArray(response.videoSectionMetadata)
                If IsAssociativeArray(result) Then
                    sectionIDs[result.title] = AsString(result.sectionId)
                End If
            Next
        End If
    End If
    Return sectionIDs
End Function

Function Cbs_GetShowEpisodes(showID As String, season As Integer, startIndex = 0 As Integer, count = 100 As Integer, pageInfo = {} As Object) As Object
    episodes = []
    pageInfo.StartIndex = startIndex
    pageInfo.Count = 0
    pageInfo.TotalCount = 0

    If Not IsNullOrEmpty(showID) Then
        url = m.Endpoint + "v2.0/roku/shows/" + showID + "/videos/config/DEFAULT_ROKU_SVOD.json"
        url = AddQueryString(url, "platformType", "roku")
        url = AddQueryString(url, "begin", startIndex)
        url = AddQueryString(url, "rows", count)
        If season > 0 Then
            url = AddQueryString(url, "params", "seasonNum=" + season.ToStr())
            url = AddQueryString(url, "seasonNum", season)
        End If
        response = m.Request(url, "GET")
        If IsAssociativeArray(response) And response.success = True And response.results <> invalid Then
            For Each result In AsArray(response.results)
                If IsAssociativeArray(result) And result.section_type = "Full Episodes" And IsAssociativeArray(result.sectionItems) Then
                    pageInfo.StartIndex = startIndex
                    pageInfo.Count = AsArray(result.sectionItems.itemList).Count()
                    pageInfo.TotalCount = AsInteger(result.sectionItems.itemCount)
                    For Each episodeItem In AsArray(result.sectionItems.itemList)
                        episode = NewEpisode(episodeItem)
                        If episode.IsAvailable() Then
                            episodes.Push(episode)
                        End If
                    Next
                    Exit For
                End If
            Next
        End If
    End If
    Return episodes
End Function

Function Cbs_GetShowClips(showID As String, startIndex = 0 As Integer, count = 100 As Integer, pageInfo = {} As Object) As Object
    clips = []
    pageInfo.StartIndex = startIndex
    pageInfo.Count = 0
    pageInfo.TotalCount = 0

    If Not IsNullOrEmpty(showID) Then
        url = m.Endpoint + "v2.0/roku/shows/" + showID + "/videos/config/DEFAULT_ROKU_SVOD.json"
        url = AddQueryString(url, "platformType", "roku")
        url = AddQueryString(url, "begin", startIndex)
        url = AddQueryString(url, "rows", count)
        response = m.Request(url, "GET")
        If IsAssociativeArray(response) And response.success = True And response.results <> invalid Then
            For Each result In AsArray(response.results)
                If IsAssociativeArray(result) And result.section_type = "Clips" And IsAssociativeArray(result.sectionItems) Then
                    pageInfo.StartIndex = startIndex
                    pageInfo.Count = AsArray(result.sectionItems.itemList).Count()
                    pageInfo.TotalCount = AsInteger(result.sectionItems.itemCount)
                    For Each clipItem In AsArray(result.sectionItems.itemList)
                        clip = NewEpisode(clipItem)
                        If clip.IsAvailable() Then
                            clips.Push(clip)
                        End If
                    Next
                    Exit For
                End If
            Next
        End If
    End If
    Return clips
End Function

Function Cbs_GetEpisode(contentID As String) As Object
    url = m.Endpoint + "v2.0/roku/videos/item.json"
    url = AddQueryString(url, "contentId", contentID)
    response = m.Request(url, "GET")
    If IsAssociativeArray(response) And response.success = True And IsAssociativeArray(response.results) Then
        item = AsArray(response.results.itemList)[0]
        If item <> invalid Then
            Return NewEpisode(item)
        End If
    End If
    Return invalid
End Function

Function Cbs_GetNextEpisode(showID As String, contentID As String) As Object
    If Not IsNullOrEmpty(showID) And Not IsNullOrEmpty(contentID) Then
        url = m.Endpoint + "v3.0/roku/shows/" + showID + "/video/autoplay/nextEpisode.json"
        url = AddQueryString(url, "contentId", contentID)
        response = m.Request(url, "GET")
        If IsAssociativeArray(response) And response.success = True Then
            item = response.nextVideo
            If item <> invalid Then
                Return NewEpisode(item)
            End If
        End If
    End If
    Return invalid
End Function


' **********************
' User
' **********************
Function Cbs_GetCurrentUser(refresh = False As Boolean) As Object
    If Not m.IsAuthenticated() Then
        Return NewUser()
    End If
    If m.CurrentUser = invalid Or refresh Then
        url = m.Endpoint + "v3.0/roku/login/status.json"

        response = m.Request(url, "GET")
        If IsAssociativeArray(response) And response.success = True Then
            m.CurrentUser = NewUser(response)
        Else
            ' An error occurred, so return an empty user
            Return NewUser()
        End If
    End If
    Return m.CurrentUser
End Function

' **********************
' Favorites
' **********************
Function Cbs_CreateFavoriteShows() As Boolean
    url = m.Endpoint + "roku/lists/favoriteshows/create.json"
    postData = {}
    postData["uniqueName"] = "favorite-shows"
    
    response = m.Request(url, "POST", postData)
    If IsAssociativeArray(response) And response.success = True Then
        Return True
    End If
    Return False
End Function

Function Cbs_GetFavoriteShowIDs() As Dynamic
    showIDs = []
    If m.IsAuthenticated() Then
        url = m.Endpoint + "roku/lists/favoriteshows/unique/favorite-shows.json"
        response = m.Request(url, "GET")
        If IsAssociativeArray(response) And response.success = True Then
            If response.favshowlist <> invalid Then
                For Each show In AsArray(response.favshowlist.showList)
                    showIDs.Push(AsString(show.cbsShowId))
                Next
            End If
        End If
    End If
    Return showIDs
End Function

Function Cbs_AddShowToFavorites(showID As String) As Boolean
    If m.GetFavoriteShowIDs() = invalid Then
        m.CreateFavoriteShows()
    End If
    
    url = m.Endpoint + "roku/lists/favoriteshows/unique/favorite-shows/item/add.json"
    postData = {}
    postData["showId"] = showID
    
    response = m.Request(url, "POST", postData)
    If IsAssociativeArray(response) And response.success = True Then
        Return True
    End If
    Return False
End Function

Function Cbs_RemoveShowFromFavorites(showID As String) As Boolean
    url = m.Endpoint + "roku/lists/favoriteshows/unique/favorite-shows/item/delete.json"
    postData = {}
    postData["showId"] = showID
    
    response = m.Request(url, "POST", postData)
    If IsAssociativeArray(response) And response.success = True Then
        Return True
    End If
    Return False
End Function

Function Cbs_GetMyCbsEpisodes(count = 100 As Integer) As Object
    episodes = []
    showIDs = m.GetFavoriteShows()
    
    url = m.Endpoint + "v2.0/roku/mycbs.json"
    url = AddQueryString(url, "showIdList", Join(showIDs, ","))
    url = AddQueryString(url, "episodes", "true")
    url = AddQueryString(url, "maxVideoCount", count)
    
    response = m.Request(url, "GET")
    If IsAssociativeArray(response) And response.success = True Then
        For Each show In AsArray(response.results)
            For Each episodeItem In AsArray(show.canVideos)
                episode = NewEpisode(episodeItem)
                If episode.IsAvailable() Then
                    episodes.Push(episode)
                End If
            Next
        Next
    End If
    Return episodes
End Function

Function Cbs_GetRecentlyWatched(page = 1, count = 10 As Integer) As Object
    episodes = []
    If m.IsAuthenticated() Then
        url = m.Endpoint + "v3.0/roku/video/streams/history.json"
        url = AddQueryString(url, "page", page)
        url = AddQueryString(url, "rows", count)
        
        response = m.Request(url, "GET")
        If IsAssociativeArray(response) And response.success = True Then
            For Each historyItem In AsArray(response.history)
                If historyItem.canModel <> invalid Then
                    episode = NewEpisode(historyItem.canModel)
                    If episode.IsAvailable() Then
                        episodes.Push(episode)
                    End If
                End If
            Next
        End If
    End If
    Return episodes
End Function

' **********************
' Search
' **********************
Function Cbs_Search(term As String, expandDetails = False As Boolean, startIndex = 0 As Integer, count = 100 As Integer) As Object
    results = []
    url = m.Endpoint + "v2.0/roku/finder/v1/terms.json"
    url = AddQueryString(url, "term", term)
    url = AddQueryString(url, "termStart", startIndex)
    url = AddQueryString(url, "termCount", count)
    
    response = m.Request(url, "GET")
    If IsAssociativeArray(response) And response.success = True Then
        For Each item In AsArray(response.terms)
            searchResult = NewSearchResult(item)
            If expandDetails Then
                result = searchResult.GetShow()
                result.ShortDescriptionLine2 = result.ShortDescriptionLine1
                result.ShortDescriptionLine1 = searchResult.Title
                results.Push(result)
            Else
                results.Push(searchResult)
            End If
        Next
    End If
    Return results
End Function

Function Cbs_GetImageUrl(baseUrl As String, width As Integer) As String
    url = baseUrl
    If Not IsNullOrEmpty(baseUrl) Then
        If StartsWith(baseUrl, "files/") Then
            url = Replace(url, "files/", m.PhotoImageEndpoint)
        Else
            url = m.VideoImageEndpoint + url.Mid(url.InStr(8, "/") + 1)
        End If
        url = Replace(url, "[WIDTH]", width.ToStr())
    End If
    Return url
End Function

Function Cbs_Request(url As String, method = "POST" As String, postData = invalid As Object, format = "json" As String, async = False As Boolean, callbackInfo = invalid As Object) As Dynamic
    requestID = invalid
    query = ""
    ' Build the post data querystring
    If postData <> invalid Then
        For Each key In postData
            query = AddQueryString(query, key, postData[key])
        Next
    End If
    ' Trim off the leading question mark
    If Not IsNullOrEmpty(query) And query.Mid(0, 1) = "?" Then
        query = query.Mid(1)
    End If

    url = AddQueryString(url, "at", GenerateAccessToken(m.ApiKey))

    DebugPrint(postData, "Cbs.Request (" + url + ")", 1)

    If async Then
        If callbackInfo <> invalid Then
            callbackInfo.Format = format
        End If
        callback = NewCallbackInfo(m, "OnResponse", "OnResponse", callbackInfo)
        If method = "POST" Then
            requestID = WebRequestQueue().Post(url, query, callback, True)
        Else
            requestID = WebRequestQueue().Get(url, callback, True)
        End If
    Else
        response = invalid
        If method = "POST" Then
            response = PostUrlToStringEx(url, query, 60)
        Else
            response = GetUrlToStringEx(url, 60)
        End If
        If response <> invalid And response.ResponseCode = 200 Then
            json = ""
            If format = "xml" Then
                json = ParseXmlAsJson(response.Response)
            Else
                ' Convert the tracking IDs from longs to strings to avoid json parsing errors
                response.Response = RegexReplace(response.Response, "(" + Chr(34) + "__FOR_TRACKING_ONLY_MEDIA_ID" + Chr(34) + ":)\s?(\d*)(\W)", "\1" + Chr(34) + "\2" + Chr(34) + "\3")
                json = ParseJson(response.Response)
            End If
            Return m.ProcessResponse(json)
        End If
    End If
    Return requestID
End Function

Sub Cbs_OnResponse(eventData As Object, callbackData As Object)
    If eventData.Response <> invalid Then
        format = "json"
        If callbackData <> invalid Then
            format = AsString(callbackData.ResponseType)
        End If
        json = ""
        If format = "xml" Then
            json = ParseXmlAsJson(response.Response)
        Else
            ' Convert the tracking IDs from longs to strings to avoid json parsing errors
            response.Response = RegexReplace(response.Response, "(" + Chr(34) + "__FOR_TRACKING_ONLY_MEDIA_ID" + Chr(34) + ":)\s?(\d*)(\W)", "\1" + Chr(34) + "\2" + Chr(34) + "\3")
            json = ParseJson(response.Response)
        End If
        response = m.ProcessResponse(json)
        If callbackData <> invalid And callbackData.ClassName = "CallbackInfo" Then
            callbackData.Callback(response)
        End If
    End If
End Sub

Function Cbs_ProcessResponse(response As Object) As Object
    Return response
End Function