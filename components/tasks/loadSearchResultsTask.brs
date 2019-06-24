sub init()
    m.top.functionName = "doWork"
end sub

sub doWork()
    if m.top.searchTerm.trim() <> "" then
        api = cbs()
        api.initialize(m.top)
        

        m.top.results = api.search(m.top.searchTerm)
    else
        m.top.results = invalid
    end if
end sub
