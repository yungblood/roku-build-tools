sub init()
    m.top.backgroundUri = "invalid"
    m.top.textColor="0x00000000"
    m.top.maxTextLength = 999999
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    return false 'key <> "unknown"
end function

