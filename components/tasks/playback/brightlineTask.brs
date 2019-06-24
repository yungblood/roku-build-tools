sub init()
    'Initialize BrightLine here
    config = getGlobalField("config")
    m.top.manifest = BrightLine_ManifestLoad()
    BrightLine_APILoad()
    m.top.observeField("loadAd", "loadAd")
    m.top.observeField("BLKeyPress", "keyEvent")
    m.top.inAd = false
    
end sub

sub loadAd()
    ?"BL :: loadAd "
    ad = m.top.ad
    
    if m.BrightLineDirect <> invalid then        
        m.BrightLineDirect.adObject = m.top.ad    
        m.BrightLineDirect.visible = true
    else
        ?"BL :: m.BrightLineDirect = invalid"
    end if
end sub

sub keyEvent()
     m.BrightLineDirect.BLKey = m.top.BLKeyPress 
end sub