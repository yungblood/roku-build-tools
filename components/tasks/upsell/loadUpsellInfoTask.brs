sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.global.config, m.global.user, m.global.cookies)
    
    if m.top.upsellType = "rendezvous" then
        m.top.upsellInfo = api.getUpsellInfo("RENDEZVOUS_SCREEN", m.top.campaign)
    else if m.top.upsellType = "launch" then
        m.top.upsellInfo = api.getUpsellInfo("AA_LAUNCH_SCREEN", m.top.campaign)
    else if m.top.upsellType = "liveTV" then
        m.top.upsellInfo = api.getUpsellInfo("AA_LIVE_LAUNCH_SCREEN", m.top.campaign)
    else if m.top.upsellType = "reg" then
        screenInfo = createObject("roSGNode", "UpsellScreenInfo")
        screenInfo.backgroundInfo = api.getUpsellInfo("AAUPSELLBKCD")
        lcCampaign = api.getCampaignAvailability("CBS_ALL_ACCESS_PACKAGE")
        lcInfo = api.getUpsellInfo("CBS_ALL_ACCESS_PACKAGE", lcCampaign)
        if lcInfo <> invalid then
            omnitureData = {}
            omnitureData["podText"] = "select"
            omnitureData["podSection"] = "limited commercials"
            omnitureData["podPosition"] = 1
            lcInfo.omnitureData = omnitureData
        end if
        
        cfCampaign = api.getCampaignAvailability("CBS_ALL_ACCESS_AD_FREE_PACKAGE")
        cfInfo = api.getUpsellInfo("CBS_ALL_ACCESS_AD_FREE_PACKAGE", cfCampaign)
        if cfInfo <> invalid then
            omnitureData = {}
            omnitureData["podText"] = "select"
            omnitureData["podSection"] = "commercial free"
            omnitureData["podPosition"] = 2
            cfInfo.omnitureData = omnitureData
        end if

        if lcInfo <> invalid and cfInfo <> invalid then
            screenInfo.options = [lcInfo, cfInfo]
'        else if lcInfo <> invalid then
'            screenInfo.options = [lcInfo]
'        else if cfInfo <> invalid then
'            screenInfo.options = [ cfInfo]
        end if
        screenInfo.buttons = [
            constants().tourText
            constants().browseText
        ]

        m.top.upsellScreenInfo = screenInfo
    else if m.top.upsellType = "newSub" then
        screenInfo = createObject("roSGNode", "UpsellScreenInfo")
        screenInfo.backgroundInfo = api.getUpsellInfo("AAUPSELLBKCD")
        lcCampaign = api.getCampaignAvailability("CBS_ALL_ACCESS_PACKAGE")
        lcInfo = api.getUpsellInfo("CBS_ALL_ACCESS_PACKAGE", lcCampaign)
        if lcInfo <> invalid then
            omnitureData = {}
            omnitureData["podText"] = "select"
            omnitureData["podSection"] = "limited commercials"
            omnitureData["podPosition"] = 1
            lcInfo.omnitureData = omnitureData
        end if
        
        cfCampaign = api.getCampaignAvailability("CBS_ALL_ACCESS_AD_FREE_PACKAGE")
        cfInfo = api.getUpsellInfo("CBS_ALL_ACCESS_AD_FREE_PACKAGE", cfCampaign)
        if cfInfo <> invalid then
            omnitureData = {}
            omnitureData["podText"] = "select"
            omnitureData["podSection"] = "commercial free"
            omnitureData["podPosition"] = 2
            cfInfo.omnitureData = omnitureData
        end if

        if lcInfo <> invalid and cfInfo <> invalid then
            screenInfo.options = [lcInfo, cfInfo]
'        else if lcInfo <> invalid then
'            screenInfo.options = [lcInfo]
'        else if cfInfo <> invalid then
'            screenInfo.options = [ cfInfo]
        end if
        screenInfo.buttons = [
            constants().tourText
            constants().signInText
        ]

        m.top.upsellScreenInfo = screenInfo
    else if m.top.upsellType = "liveTVSub" then
        screenInfo = createObject("roSGNode", "UpsellScreenInfo")
        screenInfo.backgroundInfo = api.getUpsellInfo("AAUPSELLBKCD")
        liveInfo = api.getUpsellInfo("LIVETVBUTTON")
        if liveInfo <> invalid then
            screenInfo.options = [liveInfo]
        end if
        screenInfo.buttons = [
            constants().tourText
            constants().signInText
        ]
        m.top.upsellScreenInfo = screenInfo
    else if m.top.upsellType = "upgrade" then
        screenInfo = createObject("roSGNode", "UpsellScreenInfo")
        screenInfo.backgroundInfo = api.getUpsellInfo("AAUPSELLBKCD")
        optionInfo = api.getUpsellInfo("ROKUUPGRADE")
        if optionInfo <> invalid then
            omnitureData = {}
            omnitureData["podText"] = "upgrade"
            omnitureData["podSection"] = "commercial free"
            optionInfo.omnitureData = omnitureData
            screenInfo.options = [optionInfo]
        end if
        screenInfo.buttons = []
        m.top.upsellScreenInfo = screenInfo
    else if m.top.upsellType = "upgradeExternal" then
        screenInfo = createObject("roSGNode", "UpsellScreenInfo")
        screenInfo.backgroundInfo = api.getUpsellInfo("AAUPSELLBKCD")
        optionInfo = api.getUpsellInfo("OTHERUPGRADE")
        if optionInfo <> invalid then
            optionInfo.disabled = true
            screenInfo.options = [optionInfo]
        end if
        m.top.upsellScreenInfo = screenInfo
    else if m.top.upsellType = "downgrade" then
        screenInfo = createObject("roSGNode", "UpsellScreenInfo")
        screenInfo.backgroundInfo = api.getUpsellInfo("AAUPSELLBKCD")
        optionInfo = api.getUpsellInfo("ROKUDOWNGRADE")
        if optionInfo <> invalid then
            optionInfo.disabled = true
            omnitureData = {}
            omnitureData["podText"] = "downgrade"
            omnitureData["podSection"] = "limited commercials"
            optionInfo.omnitureData = omnitureData
            screenInfo.options = [optionInfo]
        end if
        screenInfo.buttons = [
            constants().switchText
        ]
        m.top.upsellScreenInfo = screenInfo
    else if m.top.upsellType = "downgradeExternal" then
        screenInfo = createObject("roSGNode", "UpsellScreenInfo")
        screenInfo.backgroundInfo = api.getUpsellInfo("AAUPSELLBKCD")
        optionInfo = api.getUpsellInfo("OTHERDOWNGRADE")
        if optionInfo <> invalid then
            optionInfo.disabled = true
            screenInfo.options = [optionInfo]
        end if
        screenInfo.buttons = []
        m.top.upsellScreenInfo = screenInfo
    else
        m.top.upsellInfo = invalid
    end if
end sub
