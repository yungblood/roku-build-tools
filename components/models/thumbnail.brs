sub init()
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        m.top.width = json.width
        m.top.height = json.height

        ' Truncate to one decimal to account for slight differences in aspect ratio
        m.top.aspect = int(m.top.width / m.top.height * 10) / 10
        m.top.url = json.url
    end if
end sub