sub init()
    m.top.omnitureName = "/rendezvous/activation/enter code"
    m.top.omniturePageType = "activation"
    m.top.omnitureSiteHier = "activation|enter code"

    m.background = m.top.findNode("background")
    m.logo = m.top.findNode("logo")
    m.message1 = m.top.findNode("message1")
    m.activationUrl = m.top.findNode("activationUrl")
    m.activationCode = m.top.findNode("activationCode")

    m.loadTask = createObject("roSGNode", "LoadUpsellInfoTask")
    m.loadTask.observeField("upsellInfo", "onUpsellInfoLoaded")
    m.loadTask.upsellType = "rendezvous"
    m.loadTask.control = "run"

    m.tts = createObject("roTextToSpeech")

    m.top.setFocus(true)
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        if key = "back" then
            if m.codeTask <> invalid then
                m.codeTask.cancel = true
            end if
        end if
    end if
    return false
end function

sub onUpsellInfoLoaded()
    m.top.upsellInfo = m.loadTask.upsellInfo
end sub

sub onUpsellInfoChanged()
    upsellInfo = m.top.upsellInfo
    if upsellInfo <> invalid then
        m.background.uri = upsellInfo.hdPosterUrl
        m.logo.uri = upsellInfo.logoUrl
        m.message1.text = "To start streaming your favorite shows follow the steps below" 'upsellInfo.message1
        m.activationUrl.text = "cbs.com/roku" 'upsellInfo.message2
    end if
    m.activationCode.text = "retrieving code..."

    m.codeTask = createObject("roSGNode", "RendezvousTask")
    m.codeTask.observeField("code", "onActivationCodeLoaded")
    m.codeTask.observeField("success", "onActivationSuccessChanged")
    m.codeTask.control = "run"
end sub

sub onCodeChanged()
    m.activationCode.text = m.top.code
end sub

sub onActivationCodeLoaded(nodeEvent as object)
    code = nodeEvent.getData()
    m.top.code = code
    if createObject("roDeviceInfo").isAudioGuideEnabled() then
        ttsCode = ""
        for i = 0 to code.len() - 1 step 1
            ttsCode = ttsCode + " " + code.mid(i, 1)
        next

        text = m.message1.text + " "
        text = text + "Step 1. Visit " + m.activationUrl.text + " on your computer or mobile device "
        text = text + "Step 2. Enter the following code "
        text = text + ttsCode + " "
        text = text + "Step 3. When complete this screen will refresh"

        m.tts.say(text)
    end if
end sub

sub onActivationSuccessChanged()
    if m.codeTask.success = true then
        setGlobalField("cookies", m.codeTask.cookies)
        
        trackScreenView(m.top.omnitureName + "/activation success")
    end if
    m.top.success = m.codeTask.success
end sub
