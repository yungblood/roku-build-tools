Library "Roku_Ads.brs"

sub init()
    m.top.functionName = "doWork"
end sub

sub reset()
    config = m.global.config
    m.top.c2 = config.comScoreC2
    m.top.c3 = "CBSRoku"
    m.top.c4 = "CBS.com"
end sub

sub doWork()
    port = createObject("roMessagePort")
    m.top.observeField("content", port)
    m.top.observeField("videoStart", port)
    m.top.observeField("videoEnd", port)
    m.top.observeField("adStart", port)
    m.top.observeField("adEnd", port)
    
    content = invalid
    config = m.global.config
    
    comScore = csComScore()
    comScore.log_debug = false
    comScore.setCustomerC2(config.comScoreC2)
    comScore.setPublisherSecret(config.comScoreSecret)
    comScore.setAppName("CBSRoku")
    comScore.start()
    
    reset()

    streamSense = csStreamingTag()
    while true
        msg = wait(1000, port)
        msgType = type(msg)
        if msgType = "roSGNodeEvent"
            if msg.getField() = "control" then
                if msg.getData() = "stop" then
                    exit while
                end if
            else if msg.getField() = "content" then
                if content = invalid or not content.isSameNode(msg.getData()) then
                    content = msg.getData()
                    streamSenseParams = {}
                    if content.subtype() = "Station" then
                        streamSenseParams = {
                            ns_st_ci: content.id
                            c2: m.top.c2
                            c3: m.top.c3
                            c4: m.top.c4
                            c6: content.comscoreTrackingTitle
                            ns_st_pu: "CBS"
                            ns_st_pr: "*null"
                            ns_st_ep: content.title
                            ns_st_sn: "*null"
                            ns_st_en: "*null"
                            ns_st_st: "CBS"
                            ns_st_cl: "*null"
                            ns_st_ge: "*null"
                            ns_st_ti: "*null"
                            ns_st_ia: "*null"
                            ns_st_ce: "*null"
                            ns_st_ddt: "*null"
                            ms_st_tdt: "*null"
                        }
                    else
                        streamSenseParams = {
                            ns_st_ci: content.id
                            c2: m.top.c2
                            c3: m.top.c3
                            c4: m.top.c4
                            c6: content.comscoreTrackingTitle
                            ns_st_pu: "CBS"
                            ns_st_pr: iif(isNullOrEmpty(content.showName), "*null", content.showName)
                            ns_st_ep: content.title
                            ns_st_sn: iif(isNullOrEmpty(content.seasonNumber), "*null", padLeft(content.seasonNumber, "0", 2))
                            ns_st_en: iif(isNullOrEmpty(content.episodeNumber), "*null", padLeft(content.episodeNumber, "0", 2))
                            ns_st_st: "CBS"
                            ns_st_cl: asString(content.length * 1000)
                            ns_st_ge: iif(isNullOrEmpty(content.topLevelCategory), "*null", content.topLevelCategory)
                            ns_st_ti: "*null"
                            ns_st_ia: "*null"
                            ns_st_ce: "*null"
                            ns_st_ddt: "*null"
                            ns_st_tdt: "*null"
                        }
                    end if
                end if
            else if msg.getField() = "videoStart" then
                streamSense.playVideoContentPart(streamSenseParams)
            else if msg.getField() = "videoEnd" then
                streamSense.stop()
            else if msg.getField() = "adStart" then
                streamSense.stop()
                streamSense.playVideoAdvertisement(streamSenseParams)
            else if msg.getField() = "adEnd" then
            end if
        end if
        comScore.tick()
    end while

    comScore.close()
end sub
