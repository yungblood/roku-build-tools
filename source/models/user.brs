Function NewUser(json = invalid As Object) As Object
    this                            = {}
    this.ClassName                  = "User"
    
    this.Packages                   = []
    this.Favorites                  = []
    this.ID                         = ""
    
    this.Initialize                 = User_Initialize
    
    this.HasPackage                 = User_HasPackage
    this.GetStatusForTracking       = User_GetStatusForTracking
    this.GetStatusForAds            = User_GetStatusForAds
    
    this.IsSubscriber               = User_IsSubscriber
    
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
End Sub

Function User_HasPackage(packageName As String) As Boolean
    For Each package In  m.Packages
        If package.packageCode = packageName Then
            Return True
        End If
    Next
    Return False
End Function

Function User_GetStatusForTracking() As String
    status = "anon"
    If m.Status = "REGISTERED" Then
        status = "reg"
    Else If m.Status = "SUBSCRIBER" Then
        status = "reg;sub"
        foundTrial = False
        For Each package In m.Packages
            If package.packageStatus = "TRIAL" Then
                status = status + ";trial"
                foundTrial = True
                Exit For
            End If
        Next
        If Not foundTrial Then
            status = status + ";pay"
        End If
    Else If m.Status = "EX_SUBSCRIBER" Then
        status = "reg;sub;exsub"
    Else If m.Status = "SUSPENDED" Then
        status = "reg;sub;susp"
    End If
    Return status
End Function

Function User_GetStatusForAds() As Integer
    status = 0
    If m.Status = "REGISTERED" Then
        status = 2
    Else If m.Status = "SUBSCRIBER" Then
        status = 1
        foundTrial = False
        For Each package In m.Packages
            If package.packageStatus = "TRIAL" Then
                foundTrial = True
                Exit For
            End If
        Next
        If Not foundTrial Then
            status = 5
        End If
    Else If m.Status = "EX_SUBSCRIBER" Then
        status = 4
    Else If m.Status = "SUSPENDED" Then
        status = 3
    End If
    Return status
End Function

Function User_IsSubscriber() As Boolean
    Return (m.Status = "SUBSCRIBER")
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

