sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.global.config, m.global.user, m.global.cookies)
    
    while true and not m.top.cancel
        authCode = api.getActivationCode()
        if authCode <> invalid then
            m.top.code = authCode.code
            
            timeout = createObject("roTimespan")
            while timeout.totalMilliseconds() < authCode.retryDuration and not m.top.cancel
                sleep(authCode.retryInterval)
                cookies = api.checkActivationCode(authCode.code)
                if not isNullOrEmpty(cookies) then
                    setRegistryValue("AuthToken", authCode.code, api.registrySection)
                    m.top.cookies = cookies
                    m.top.success = true
                    return
                end if
            end while
        else
            m.top.code = "Error"
            m.top.success = false
            return
        end if
    end while
    m.top.success = false
end sub
