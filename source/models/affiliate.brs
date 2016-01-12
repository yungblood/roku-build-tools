Function NewAffiliate(json = invalid As Object) As Object
    this            = {}
    this.ClassName  = "Affiliate"
    
    this.Initialize = Affiliate_Initialize

    If json <> invalid Then
        this.Initialize(json)
    End If
    
    Return this
End Function

Sub Affiliate_Initialize(json As Object)
    m.ID = AsString(json.id)
    m.Name = AsString(json.affiliateName)
    m.Url = AsString(json.affiliateUrl)
    m.Station = AsString(json.affiliateStation)
    
    m.HDPosterUrl   = Cbs().GetImageUrl(AsString(json.logo), 266)
    m.SDPosterUrl   = Cbs().GetImageUrl(AsString(json.logo), 138)
End Sub
