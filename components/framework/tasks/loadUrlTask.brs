sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    m.top.response = getUrlToStringEx(m.top.uri)
end sub
