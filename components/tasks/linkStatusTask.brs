sub init()
    m.top.functionName = "doWork"
    m.port = CreateObject("roMessagePort")
    m.deviceInfo = CreateObject("roDeviceInfo")
    m.deviceInfo.SetMessagePort(m.port)
    m.deviceInfo.EnableLinkStatusEvent(true)
end sub

sub doWork()
	while TRUE
		msg = Wait(0, m.port)
		if type(msg) = "roDeviceInfoEvent" then
            info = msg.GetInfo()
            if info.linkstatus <> invalid then
                m.top.status = info.linkStatus
            end if
        end if
	end while
end sub
