sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.top)
    
    
    accountDetails = m.top.accountDetails
    if api.checkEmailExists(accountDetails.email) then
        m.top.error = "EMAIL_EXISTS"
        m.top.success = false
    else if not api.validateZipCode(accountDetails.zip) then
        m.top.error = "INVALID_ZIP"
        m.top.success = false
    else
        m.top.success = true
    end if
end sub
