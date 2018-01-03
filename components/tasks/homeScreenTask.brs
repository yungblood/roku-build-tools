sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs() 'm.global.api
    api.initialize(m.global.config, m.global.user, m.global.cookies)
    
    content = {}
    content.marquee = api.getMarquee()

    user = m.global.user
    rows = [
        user.favorites
        user.recentlyWatched
    ]
    rows.append(api.getHomeRows(1))

    content.rows = rows
    
    m.top.content = content
end sub
