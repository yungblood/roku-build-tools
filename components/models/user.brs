sub init()
    m.top.favorites = createObject("roSGNode", "Favorites")
    m.top.videoHistory = createObject("roSGNode", "VideoHistory")
    m.top.showHistory = createObject("roSGNode", "ShowHistory")
    m.top.continueWatching = createObject("roSGNode", "ContinueWatching")
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        m.top.id = json.userId
        m.top.ppid = json.ppid
        m.top.firstName = json.firstName
        m.top.lastName = json.lastName
        m.top.gender = json.gender
        
        m.top.fullName = m.top.firstName
        if not isNullOrEmpty(m.top.fullName) then
            m.top.fullName = m.top.fullName + " "
        end if
        m.top.maskedFullName = m.top.fullName + m.top.lastName.mid(0, 1)
        m.top.fullName = m.top.fullName + m.top.lastName

        m.top.email = asString(json.email)
        m.top.maskedEmail = asString(json.maskedEmail)
        
        if json.userStatus <> invalid then
            m.top.status = json.userStatus.description
        end if
        m.top.isSubscriber = (m.top.status = "SUBSCRIBER")
        m.top.isRokuSubscriber = isRokuSubscriber(json.cbsPackageInfo)
        m.top.isAdFree = isAdFree(json.cbsPackageInfo)
        m.top.trackingProduct = getProductForTracking(json.cbsPackageInfo)
        m.top.trackingStatus = getStatusForTracking(json.packageStatus)
        m.top.adStatus = getStatusForAds(json.packageStatus)
        
        m.top.packageName = getPackageName(json.cbsPackageInfo)
        
        'm.top.favorites.update = true
        'm.top.videoHistory.update = true
    end if
end sub

sub onEligibleProductsChanged()
    products = m.top.eligibleProducts
    m.top.canUpgrade = products.upgrades.count() > 0
    m.top.canDowngrade = products.downgrades.count() > 0
end sub

function isRokuSubscriber(packageInfo) as boolean
    for each package in packageInfo
        if package.packageSource = "roku" then
            return true
        end if
    next
    return false
end function

function getPackageName(packageInfo as object) as string
    if m.top.isSubscriber then
        if packageInfo.count() > 0 then
            package = packageInfo[0]
            if package.isAdFree then
                return "Commercial Free"
            else
                return "Limited Commercial"
            end if
        end if
        return "Unknown"
    else
        return "Free Account"
    end if
end function

function isAdFree(packageInfo as object) as boolean
    if m.top.isSubscriber then
        if packageInfo.count() > 0 then
            package = packageInfo[0]
            if package.isAdFree then
                return true
            end if
        end if
    end if
    return false
end function

function getProductForTracking(packageInfo as object) as string
    if packageInfo.count() > 0 then
        return asString(packageInfo[0].productCode)
    end if
    return ""
end function

function getStatusForTracking(packageStatus as object) as string
    status = ""
    for each value In asArray(packageStatus.subscriberPackage)
        if status.len() > 0 then
            status = status + ","
        end if
        status = status + "sb|" + asString(value)
    next
    for each value In asArray(packageStatus.subscriberTrialPackage)
        if status.len() > 0 then
            status = status + ","
        end if
        status = status + "tsb|" + asString(value)
    next
    for each value In asArray(packageStatus.exsubscriberPackage)
        if status.len() > 0 then
            status = status + ","
        end if
        status = status + "esb|" + asString(value)
    next
    for each value In asArray(packageStatus.suspendedPackage)
        if status.len() > 0 then
            status = status + ","
        end if
        status = status + "ssb|" + asString(value)
    next
    if isNullOrEmpty(status) then
        ' Anonymous user
        status = "sb|0"
    end if
    return status
end function

function getStatusForAds(packageStatus as object) as string
    sb = ""
    for each value In asArray(packageStatus.subscriberPackage)
        if sb.len() > 0 then
            sb = sb + ","
        end if
        sb = sb + asString(value)
    next
    tsb = ""
    for each value In asArray(packageStatus.subscriberTrialPackage)
        if tsb.len() > 0 then
            tsb = tsb + ","
        end if
        tsb = tsb + asString(value)
    next
    esb = ""
    for each value In asArray(packageStatus.exsubscriberPackage)
        if esb.len() > 0 then
            esb = esb + ","
        end if
        esb = esb + asString(value)
    next
    ssb = ""
    for each value In asArray(packageStatus.suspendedPackage)
        if ssb.len() > 0 then
            ssb = ssb + ","
        end if
        ssb = ssb + asString(value)
    next
    status = ""
    if sb.len() > 0 then
        status = "sb=" + sb
    end if
    if tsb.len() > 0 then
        if status.len() > 0 then
            status = status + "&"
        end if
        status = status + "tsb=" + tsb
    end if
    if esb.len() > 0 then
        if status.len() > 0 then
            status = status + "&"
        end if
        status = status + "esb=" + esb
    end if
    if ssb.len() > 0 then
        if status.len() > 0 then
            status = status + "&"
        end if
        status = status + "ssb=" + ssb
    end if
    return status
end function