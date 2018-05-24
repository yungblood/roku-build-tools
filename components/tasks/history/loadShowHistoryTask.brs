sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    api = cbs()
    api.initialize(m.global.config, m.global.user, m.global.cookies)
    '------Calling api method-------
    m.top.history = api.getShowHistory()
end sub    