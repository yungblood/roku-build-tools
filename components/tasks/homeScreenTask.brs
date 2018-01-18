sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs() 'm.global.api
    api.initialize(m.global.config, m.global.user, m.global.cookies)
    
    content = {}
    content.marquee = api.getMarquee()

    user = m.global.user
    rows = []
    if user.favorites.getChildCount() > 0 then
        rows.push(user.favorites)
    end if
    if user.recentlyWatched.getChildCount() > 0 then
        rows.push(user.recentlyWatched)
    end if
    rows.append(api.getHomeRows(10))

    content.rows = rows
    
    m.top.content = content
end sub
