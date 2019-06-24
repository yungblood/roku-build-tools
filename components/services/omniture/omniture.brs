function omniture() as object
    if m.omniture = invalid then
        m.omniture = NewOmniture()
    end if
    return m.omniture
end function

function NewOmniture() as object
    this                = {}
    this.className      = "Omniture"
    
    this.omniture       = invalid
    
    this.baseUrl        = "http://om.cbsi.com/b/ss/[SUITE_ID]/1/H.27.4/s06757860819343"
    
    this.initialize     = omniture_initialize
    this.trackPage      = omniture_trackPage
    this.trackEvent     = omniture_trackEvent
    
    return this
end function

sub omniture_initialize(suiteID as string, userID as string, subscriberStatus as string, subscriberProduct as string, evar5 = suiteID as string)
    url = m.baseUrl.replace("[SUITE_ID]", suiteID)
    m.omniture = NWM_Omniture(url, true)
    m.omniture.debug = true
    m.omniture.persistentParams.v1 = "CBS"
    m.omniture.persistentParams.v3 = "roku tv ott|" + lCase(getModel())
    m.omniture.persistentParams.v5 = evar5
    m.omniture.persistentParams.v15 = subscriberStatus
    m.omniture.persistentParams.v32 = "cbs_roku_app|can"
    m.omniture.persistentParams.v58 = getPersistedDeviceID()
    m.omniture.persistentParams.v69 = userID
    m.omniture.persistentParams.l1 = subscriberStatus
    m.omniture.persistentParams.pl = subscriberProduct
end sub

sub omniture_trackPage(pageName as string, events = [] as object, additionalParams = {} as object)
    params = {}
    params.pageName = pageName
    if events <> invalid and events.Count() > 0 then
        params.events = join(events, ",")
    end if
    params.append(additionalParams)
    m.omniture.logEvent(params)
end sub

sub omniture_trackEvent(linkName as string, events = [] as object, additionalParams = {} as object)
    params = {}
    params.pev2 = linkName
    if events <> invalid and events.Count() > 0 then
        params.events = join(events, ",")
    end if
    params.append(additionalParams)
    if params.v46 = invalid then
        params.v46 = linkName
    end if
    m.omniture.logEvent(params)
end sub