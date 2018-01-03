sub init()
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        marquees = json.marquees
        if marquees <> invalid then
            homeMarquee = marquees.homeMarquee
            if homeMarquee <> invalid then
                homeMarquee = homeMarquee[0]
                if homeMarquee <> invalid then
                    for each slide in homeMarquee.homeSlides
                        marqueeSlide = m.top.createChild("MarqueeSlide")
                        marqueeSlide.json = slide
                    next
                end if
            end if
        end if
    end if
end sub