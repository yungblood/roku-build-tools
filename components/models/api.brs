sub init()
    cbs().initialize(m.top)
end sub

function request(requestDetails as object) as object
    functionName = requestDetails.functionName
    api = cbs()
    if isFunction(api[functionName]) then
        params = requestDetails.params
        if params = invalid or params.count() = 0 then
            return api[functionName]()
        else if params.count() = 1 then
            return api[functionName](params[0])
        else if params.count() = 2 then
            return api[functionName](params[0], params[1])
        else if params.count() = 3 then
            return api[functionName](params[0], params[1], params[2])
        else if params.count() = 4 then
            return api[functionName](params[0], params[1], params[2], params[3])
        else if params.count() = 5 then
            return api[functionName](params[0], params[1], params[2], params[3], params[4])
        else if params.count() = 6 then
            return api[functionName](params[0], params[1], params[2], params[3], params[4], params[5])
        else if params.count() = 7 then
            return api[functionName](params[0], params[1], params[2], params[3], params[4], params[5], params[6])
        else if params.count() = 8 then
            return api[functionName](params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7])
        else if params.count() = 9 then
            return api[functionName](params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8])
        else if params.count() = 10 then
            return api[functionName](params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8], params[9])
        end if
    end if
    return invalid
end function