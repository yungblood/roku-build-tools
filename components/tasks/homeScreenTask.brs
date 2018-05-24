sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.global.config, m.global.user, m.global.cookies)
    
    content = {}
    content.marquee = api.getMarquee()

    user = m.global.user
    rows = [] 
    if user.continueWatching.getChildCount() > 0 then
        rows.push(user.continueWatching)
    end if
    if user.showHistory.getChildCount() > 0 then
        rows.push(user.showHistory)
    end if
    
    rows.append(api.getHomeRows(10))

    content.rows = rows
    
    m.top.content = content
end sub
