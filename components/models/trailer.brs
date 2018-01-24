sub init()
    m.top.observeField("json", "onTrailerJsonChanged")
end sub

sub onTrailerJsonChanged()
    m.top.comscoreTrackingTitle = "Movies"
end sub
