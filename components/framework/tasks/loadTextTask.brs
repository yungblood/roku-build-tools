sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    m.top.text = getUrlToString(m.top.uri)
end sub
