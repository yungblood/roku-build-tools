sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.top)

    content = {}
    content.marquee = api.getMarquee()

    user = getGlobalField("user")
    rows = [] 
    if isSubscriber(m.top) then
        'if user.continueWatching.getChildCount() > 0 then
            rows.push(user.continueWatching)
        'end if
        'if user.showHistory.getChildCount() > 0 then
            rows.push(user.showHistory)
        'end if
    end if
    
    homeRows = api.getHomeRows(10)
    if isArray(homeRows) then
        rows.append(homeRows)
    else if isAssociativeArray(homeRows) then
        m.top.errorCode = asInteger(homeRows.errorCode)
    end if
    content.rows = rows
    m.top.content = content
end sub
