function spotX() as object
    if m.spotX = invalid then
        m.spotX = newSpotX()
    end if
    return m.spotX
end function

function newSpotX() as object
    this                    = {}
    this.className          = "spotx"
    
    this.initialize         = spotx_initialize
    this.getCampaign        = spotx_getCampaign
    this.makeRequest        = spotx_makeRequest
    
    setLogLevel(1)
    
    return this
end function

Sub spotx_initialize(deviceID as string,baseUrl as string, contentPageUrl as string )
    m.deviceID = deviceID
    m.baseUrl = baseUrl
    m.contentPageUrl = contentPageUrl
end Sub

function spotx_getCampaign() as object
    params = {}
    campaign = []
    params["content_page_url"] = m.contentPageUrl
    params["device[ifa]"] = m.deviceID
    response = m.makeRequest("/insights/85394",params)
    if response <> invalid then
        for each item in asArray(response)
            campaign.push(item)
        next
        return campaign  
    end if
    return invalid
end function

function spotx_makeRequest(path as string, params = invalid as object, retryCount = 0 as integer) as object
    if isAssociativeArray(params) then
        for each param in params
            path = addQueryString(path, param, params[param])
        next
    end if
    url = m.baseUrl + path
    response = getUrlToStringEx(url, 30)
    if response <> invalid then
        if response.responseCode = 200 then
            return ParseJson(response.response)
        else if response.responseCode = 503 then ' Too busy
            if retryCount = 0 then
                sleep(2500)
            else if retryCount = 1 then
                sleep(5000)
            else
                sleep(10000)
            end if
            return m.makeRequest(path, params, retryCount + 1)
        end if
    end if
    
    return invalid
end function