Function NewUser(json = invalid As Object) As Object
    this                            = {}
    this.ClassName                  = "User"
    
    this.Packages                   = []
    this.PackageStatus              = {}
    this.Favorites                  = invalid
    this.ID                         = ""
    
    this.Initialize                 = User_Initialize
    
    this.HasPackage                 = User_HasPackage
    this.GetProductForTracking      = User_GetProductForTracking
    this.GetStatusForTracking       = User_GetStatusForTracking
    this.GetStatusForAds            = User_GetStatusForAds
    
    this.IsSubscriber               = User_IsSubscriber
    this.IsRokuSubscriber           = User_IsRokuSubscriber
    
    this.CanUpgrade                 = User_CanUpgrade
    this.CanDowngrade               = User_CanDowngrade
    this.GetEligibleProducts        = User_GetEligibleProducts       
    
    this.GetMyCbsShows              = User_GetMyCbsShows
    this.GetMyCbsEpisodes           = User_GetMyCbsEpisodes
    this.GetRecentlyWatched         = User_GetRecentlyWatched
    this.GetRecentlyWatchedForShow  = User_GetRecentlyWatchedForShow
    this.AddToRecentlyWatched       = User_AddToRecentlyWatched
    
    this.GetFavorites               = User_GetFavorites
    this.ShowIsInFavorites          = User_ShowIsInFavorites
    this.AddShowToFavorites         = User_AddShowToFavorites
    this.RemoveShowFromFavorites    = User_RemoveShowFromFavorites
    
    If json <> invalid Then
        this.Initialize(json)
    End If
    
    Return this
End Function

Sub User_Initialize(json As Object)
    m.Json = json
    
    m.ID = AsString(json.userId)
    m.FirstName = AsString(json.firstName)
    m.LastName = AsString(json.lastName)
    m.Gender = AsString(json.gender)
    m.Ppid = AsString(json.ppid)
    
    If Not IsNullOrEmpty(json.userStatus) Then
        m.Status = AsString(json.userStatus.description)
    End If
    
    m.IsLoggedIn = AsBoolean(json.isLoggedIn)
    
    m.Packages.Clear()
    For Each package In AsArray(json.cbsPackageInfo)
        m.Packages.Push(package)
    Next
    
    m.PackageStatus = m.json.packageStatus
End Sub

Function User_HasPackage(packageName As String) As Boolean
    For Each package In  m.Packages
        If package.packageCode = packageName Then
            Return True
        End If
    Next
    Return False
End Function

Function User_GetProductForTracking() As String
    If m.Packages.Count() > 0 Then
        Return m.Packages[0].productCode
    End If
    Return ""
End Function

Function User_GetStatusForTracking() As String
    status = ""
    For Each value In AsArray(m.PackageStatus.subscriberPackage)
        If status.Len() > 0 Then
            status = status + ","
        End If
        status = status + "sb|" + AsString(value)
    Next
    For Each value In AsArray(m.PackageStatus.subscriberTrialPackage)
        If status.Len() > 0 Then
            status = status + ","
        End If
        status = status + "tsb|" + AsString(value)
    Next
    For Each value In AsArray(m.PackageStatus.exsubscriberPackage)
        If status.Len() > 0 Then
            status = status + ","
        End If
        status = status + "esb|" + AsString(value)
    Next
    For Each value In AsArray(m.PackageStatus.suspendedPackage)
        If status.Len() > 0 Then
            status = status + ","
        End If
        status = status + "ssb|" + AsString(value)
    Next
    If IsNullOrEmpty(status) Then
        ' Anonymous user
        status = "sb|0"
    End If
    Return status
End Function

Function User_GetStatusForAds() As String
    sb = ""
    For Each value In AsArray(m.PackageStatus.subscriberPackage)
        If sb.Len() > 0 Then
            sb = sb + ","
        End If
        sb = sb + AsString(value)
    Next
    tsb = ""
    For Each value In AsArray(m.PackageStatus.subscriberTrialPackage)
        If tsb.Len() > 0 Then
            tsb = tsb + ","
        End If
        tsb = tsb + AsString(value)
    Next
    esb = ""
    For Each value In AsArray(m.PackageStatus.exsubscriberPackage)
        If esb.Len() > 0 Then
            esb = esb + ","
        End If
        esb = esb + AsString(value)
    Next
    ssb = ""
    For Each value In AsArray(m.PackageStatus.suspendedPackage)
        If ssb.Len() > 0 Then
            ssb = ssb + ","
        End If
        ssb = ssb + AsString(value)
    Next
    status = ""
    If sb.Len() > 0 Then
        status = "sb=" + sb
    End If
    If tsb.Len() > 0 Then
        If status.Len() > 0 Then
            status = status + "&"
        End If
        status = status + "tsb=" + tsb
    End If
    If esb.Len() > 0 Then
        If status.Len() > 0 Then
            status = status + "&"
        End If
        status = status + "esb=" + esb
    End If
    If ssb.Len() > 0 Then
        If status.Len() > 0 Then
            status = status + "&"
        End If
        status = status + "ssb=" + ssb
    End If
    Return status
End Function

Function User_IsSubscriber() As Boolean
    Return (m.Status = "SUBSCRIBER")
End Function

Function User_IsRokuSubscriber() As Boolean
    For Each package In m.Packages
        If package.packageSource = "roku" Then
            Return True
        End If
    Next
    Return False
End Function

Function User_CanUpgrade() As Boolean
    Return m.GetEligibleProducts().Upgrades.Count() > 0
End Function

Function User_CanDowngrade() As Boolean
    Return m.GetEligibleProducts().Downgrades.Count() > 0
End Function

Function User_GetEligibleProducts(refresh = False As Boolean) As Object
    If refresh Or m.EligibleProducts = invalid Then
        m.EligibleProducts = Cbs().GetEligibility()
    End If
    Return m.EligibleProducts
End Function

Function User_GetMyCbsShows(refresh = False As Boolean) As Object
    Return Cbs().GetShowsById(m.GetFavorites(refresh))
End Function

Function User_GetMyCbsEpisodes() As Object
    Return Cbs().GetMyCbsEpisodes()
End Function

Function User_GetRecentlyWatched(refresh = False As Boolean) As Object
    If m.RecentlyWatched = invalid Or refresh Then
        m.RecentlyWatched = Cbs().GetRecentlyWatched(1, 50)
    End If
    Return m.RecentlyWatched
End Function

Function User_GetRecentlyWatchedForShow(showID As String, refresh = False As Boolean) As Object
    recentlyWatched = m.GetRecentlyWatched(refresh)
    For Each episode In recentlyWatched
        If episode.ShowID = showID Then
            Return episode
        End If
    Next
    Return invalid
End Function

Sub User_AddToRecentlyWatched(episode As Object)
    m.GetRecentlyWatched()
    existing = FindElementIndexInArray(m.RecentlyWatched, episode.ContentID, "ContentID")
    If existing > -1 Then
        MoveElementInArray(m.RecentlyWatched, existing, 0)
    Else
        m.RecentlyWatched.Unshift(episode)
    End If
    GlobalEventRegistry().RaiseEvent("RecentlyWatchedChanged")
End Sub

Function User_GetFavorites(refresh = False As Boolean) As Object
    If refresh Or m.Favorites = invalid Then
        m.Favorites = Cbs().GetFavoriteShowIDs()
    End If
    Return m.Favorites
End Function

Function User_ShowIsInFavorites(showID As String) As Boolean
    For Each favorite In AsArray(m.GetFavorites())
        If favorite = showID Then
            Return True
        End If
    Next
    Return False
End Function

Function User_AddShowToFavorites(showID As String) As Boolean
    If Cbs().AddShowToFavorites(showID) Then
        m.GetFavorites(True)
        GlobalEventRegistry().RaiseEvent("FavoritesChanged", { ShowID: showID, Added: True })
        Return True
    End If
    Return False
End Function

Function User_RemoveShowFromFavorites(showID As String) As Boolean
    If Cbs().RemoveShowFromFavorites(showID) Then
        m.GetFavorites(True)
        GlobalEventRegistry().RaiseEvent("FavoritesChanged", { ShowID: showID, Added: False })
        Return True
    End If
    Return False
End Function

