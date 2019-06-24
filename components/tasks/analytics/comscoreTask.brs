Library "Roku_Ads.brs"

sub init()
    m.top.functionName = "doWork"
end sub

sub reset(params = {} as object)
    config = getGlobalField("config")
    m.top.c2 = config.comScoreC2
    m.top.c3 = "CBSRoku"
    m.top.c4 = "CBS.com"
    
    m.streamSenseParams = {}
end sub

sub doWork()
    port = createObject("roMessagePort")
    m.top.observeField("content", port)
    m.top.observeField("videoStart", port)
    m.top.observeField("videoEnd", port)
    m.top.observeField("adStart", port)
    m.top.observeField("adEnd", port)
    
    content = invalid
    config = getGlobalField("config")
    
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
        if msgType = "roSGNodeEvent" then
            if msg.getField() = "control" then
                if msg.getData() = "stop" then
                    exit while
                end if
            else if msg.getField() = "content" then
                if content = invalid or not content.isSameNode(msg.getData()) then
                    content = msg.getData()
                    streamSenseParams = getStreamSenseParams(content, true)
                end if
            else if msg.getField() = "videoStart" then
                streamSense.playVideoContentPart(getStreamSenseParams(m.top.content))
            else if msg.getField() = "videoEnd" then
                streamSense.stop()
            else if msg.getField() = "adStart" then
                streamSense.stop()
                streamSense.playVideoAdvertisement(getStreamSenseParams(m.top.content))
            else if msg.getField() = "adEnd" then
            end if
        end if
        comScore.tick()
    end while

    comScore.close()
end sub

function getStreamSenseParams(content as object, refresh = false as boolean) as object
    streamSenseParams = m.streamSenseParams
    if (refresh or streamSenseParams.isEmpty()) and content <> invalid then
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
        m.streamSenseParams = streamSenseParams
    end if
    return streamSenseParams
end function
