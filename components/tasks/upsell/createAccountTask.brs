sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.top)

    m.top.product = channelStore().getProduct(m.top.productCode)
    
    trackRMFEvent("PNT")
    transactionID = api.subscribe(m.top.productCode)
    if not isNullOrEmpty(transactionID) then
        m.top.transactionID = transactionID
        activationCode = api.createAccount(m.top.accountDetails, transactionID, m.top.productCode, getPersistedDeviceID())
        if not isNullOrEmpty(activationCode) then
            cookies = api.checkActivationCode(activationCode, getPersistedDeviceID())
            if not isNullOrEmpty(cookies) then
                setRegistryValue("AuthToken", activationCode, api.registrySection)
                m.top.cookies = cookies
                m.top.success = true
                return
            else
                m.top.success = false
                return
            end if
        else
            m.top.success = false
            return
        end if
    else
        m.top.error = "NO_TRANSACTION_ID"
        m.top.success = false
        return
    end if
    m.top.success = false
end sub
