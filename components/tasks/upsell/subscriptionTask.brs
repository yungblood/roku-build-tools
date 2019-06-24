sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.top)

    trackRMFEvent("PNT")
    if m.top.type = "upgrade" or m.top.type = "downgrade" then
        m.top.product = channelStore().getProduct(m.top.productCode)
        transactionID = api.subscribe(m.top.productCode)
        if not isNullOrEmpty(transactionID) then
            m.top.transactionID = transactionID
            if m.top.type = "upgrade" then
                m.top.success = api.upgrade(transactionID)
            else
                m.top.success = api.downgrade(transactionID)
            end if
            return
        else
            m.top.error = "NO_TRANSACTION_ID"
        end if
    else if m.top.type = "sub" or m.top.type = "exsub" then
        m.top.product = channelStore().getProduct(m.top.productCode)
        transactionID = api.subscribe(m.top.productCode)
        if not isNullOrEmpty(transactionID) then
            m.top.transactionID = transactionID
            m.top.success = not isNullOrEmpty(api.getEntitlement(transactionID, m.top.productCode, getPersistedDeviceID()))
            return
        else
            m.top.error = "NO_TRANSACTION_ID"
        end if
    end if
    m.top.success = false
end sub
