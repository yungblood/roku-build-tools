Library "Roku_Ads.brs"
Library "IMA3.brs"

sub init()
    m.top.functionName = "doWork"
    
    m.debug = false
end sub

sub doWork()
    m.lastLoopTime = 0
    m.seekThreshold = 2
    
    m.adTicksSet = false
    
    m.cuepoints = []
    m.skippingPod = false

    loadSdk()
    if m.sdk <> invalid then
        m.port = createObject("roMessagePort")
        m.top.observeField("video", m.port)
        while true
            msg = wait(1000, m.port)
            if isIrollEvent(msg) then
                handleIrollEvent(msg)
            else if isIrollPlaybackRequest(msg) then
                handleIrollPlaybackRequest(msg) 
            else if type(msg) = "roSGNodeEvent" and msg.getField() = "video" then
                onVideoChanged()
            else
                if not m.top.streamManagerReady then
                    loadStreamManager()
                    m.adTicksSet = false
                end if
                if isVideoPlaybackEvent(msg) then
                    handlePlaybackStateChanged(msg)
                end if
                if m.streamManager <> invalid then
                    m.streamManager.onMessage(msg)
                    if m.top.video <> invalid and m.top.streamManagerReady then
                        currentTime = m.top.video.position
                        contentTime = m.streamManager.getContentTime(currentTime * 1000) / 1000
                        m.top.contentTime = contentTime
                        
                        if m.lastLoopTime > 0 and abs(currentTime - m.lastLoopTime) > m.seekThreshold then
                            print "Seek detected from "; m.lastLoopTime;" to ";currentTime
                            if m.top.inSnapback or m.skippingPod then
                                ' That seek was us snapping back to content
                                print "Threshold break was snapback or pod skip"
                                m.top.inSnapback = false
                                m.skippingPod = false
                            else
                                ' User seeked
                                print "Threshold break was user seek - sending to onUserSeek"
                                onUserSeek(m.lastLoopTime, currentTime)
                            end if
                        else if type(msg) = "roSGNodeEvent" and msg.getField() = "position" then
                            if not m.adTicksSet then
                                ' set ad indicators on the playback bar
                                hashes = []
                                duration = m.video.duration
                                if duration > 0 then
                                    for each cuepoint in m.cuepoints
                                        if cuepoint.start > 0 then
                                            hashes.push(cuepoint.start / duration)
                                        end if
                                    next
                                    m.video.trickPlayBar.hashMarkPositions = hashes
                                    m.adTicksSet = true
                                end if
                            end if
                            if not m.skippingPod and not m.top.inSnapback then
                                for i = 0 to m.cuepoints.count() - 1
                                    cuepoint = m.cuepoints[i]
                                    ' add a 2 second buffer to the end to avoid ms rounding issues
                                    if cuepoint.start <= currentTime and cuepoint.end > currentTime + 2 then
                                        m.currentCuePoint = cuepoint
                                        if cuepoint.hasPlayed and not m.top.adPlaying then
                                            ' this cuepoint has already played, so
                                            ' we should skip it
                                            print currentTime
                                            print "Seeking past credited cuepoint -";cuepoint.start;"->";cuepoint.end
                                            m.skippingPod = true
                                            m.top.video.seek = cuepoint.end + 1
                                        end if
                                        exit for
                                    end if
                                    if m.currentCuePoint <> invalid then
                                        ' We're no longer in the cuepoint, so mark
                                        ' it as played
                                        m.currentCuePoint.hasPlayed = true
                                    end if
                                    m.currentCuePoint = invalid
                                next
                            end if
                        end if
                        m.lastLoopTime = currentTime
                    end if
                end if
            end if
        end while
    else
        ' TODO: Handle an SDK load failure
    end if
end sub

sub loadSdk()
    sdk = m.sdk
    ' Only do this once per channel execution
    if sdk = invalid then
        print "SDK IS INVALID LOAD IMASDK"
        sdkcode = New_IMASDK()
        m.sdk = sdkcode
        if m.top <> invalid then 'if we are not in an RSG app
            m.top.sdkLoaded = true
        else
            m.top = {}
            m.top.sdkloaded = true
        end if
    end if
end sub

'sub loadSdk()
'    sdk = m.sdk
'    ' Only do this once per channel execution
'    if sdk = invalid then
''        m.sdk = getImaSdk()
'        sdkUrl = "https://imasdk.googleapis.com/roku/sdkloader/ima3.brs"
'        sdkResponse = getUrlToStringEx(sdkUrl)
'        if sdkResponse.responseCode = 200 then
'            sdkCode = sdkResponse.response
'            error = eval(sdkCode)
'            if type(error) = "roList" then
'                for each e in error
'                    print e
'                    m.top.errors.push(e)
'                end for
'            else if error <> &hE2 and error <> &hFC and error <> &hFF then
'                ' hFC = error on normal end, hE2 = error on return value
'                ' hFF = unknown error
'                print("Error Evaluating SDK: " + stri(error))
'                m.top.errors.push("Error Evaluating SDK: " + stri(error))
'            end if
'            ' This is the AA created in the remote IMA file. Here we store it while it
'            ' is still in scope for this function context.
'            m.sdk = imasdk                        
'            
'            m.top.sdkLoaded = true
'        else
'            print("Error downloading SDK: " + stri(code))
'            m.top.errors.push("Error downloading SDK: " + stri(code))
'        end if
'    end if
'end sub

sub loadStreamManager()
    if m.sdk <> invalid and m.top.video <> invalid and m.top.streamData <> invalid then
        ?"--- Loading Stream Manager ---"
        m.sdk.initSdk()
        setupVideoPlayer()
        request = m.sdk.createStreamRequest()
        
        streamData = m.top.streamData
        if streamData <> invalid then
            if streamData.type = "live" then
                request.assetKey = streamData.assetKey
            else
                request.contentSourceId = streamData.contentSourceId
                request.videoId = streamData.videoId
            end if
            request.apiKey = streamData.apiKey
            if streamData.attemptPreroll <> invalid then
                request.attemptPreroll = streamData.attemptPreroll
            end if
            request.player = m.player
            request.adTagParameters = streamData.adTagParameters
            request.ppid = streamData.ppid
'            request.campaign = streamData.campaign
            request.format = streamData.streamFormat
            
    '        ?"Stream Data: ";streamData
    '        ?"DAI Request: ";request
            
            content = m.top.content
            if content <> invalid then
                config = getGlobalField("config")
                raf = Roku_Ads()
                raf.setDebugOutput(m.debug)
        
                'RAF content params
                raf.setContentID(content.id)
                raf.setContentGenre("General Variety")
                
                'Nielsen content params
                raf.enableNielsenDAR(true)
                raf.setContentLength(asInteger(content.length))
                raf.setNielsenGenre(content.nielsenGenre)
                raf.setNielsenAppID(config.nielsenAppID)
                raf.setNielsenProgramID(asString(content.showName))
            end if
    
            m.cuepoints = []
            requestResult = m.sdk.requestStream(request)
            if requestResult <> invalid then
                print "Error requesting stream ";requestResult
            else
                m.streamManager = invalid
                while m.streamManager = invalid
                    sleep(50)
                    m.streamManager = m.sdk.getStreamManager()
                end while
                if m.streamManager.type = "error" then
                    print "DAI Error: ";m.streamManager.info
                    m.top.error = m.streamManager.info
                    m.streamManager = invalid
                    reset()
                else
                    m.top.streamManagerReady = true
                    addCallbacks()
                    m.player.streamManager = m.streamManager
                    m.streamManager.start()
    
                    m.cuepoints = m.streamManager.getCuePoints()

                    if streamData.bookmarkPosition <> invalid and streamData.bookmarkPosition > 0 then
                        ' Adjust bookmark position for stitched ads
                        streamData.bookmarkPosition = m.streamManager.getStreamTime(streamData.bookmarkPosition * 1000) / 1000
                    end if
                    m.lastLoopTime = 0
                end if
            end if
        end if
    end if
end sub

sub setupVideoPlayer()
    sdk = m.sdk
    m.player = m.sdk.createPlayer()
    m.player.top = m.top

    m.player.loadUrl = function(streamInfo as object)
        streamData = m.top.streamData
        if streamData <> invalid then
            streamData.url = streamInfo.manifest
            streamData.streamFormat = streamInfo.format
            streamData.streamDetails = streamInfo

            if streamInfo.subtitles <> invalid then
                for each subtitle in streamInfo.subtitles
                    if lCase(subtitle.language) = "en" and subtitle.ttml <> invalid then
                        streamData.subtitleConfig = { trackName: subtitle.ttml.toStr() }
                        exit for    
                    else if lCase(subtitle.language) = "en" and subtitle.webvtt <> invalid then
                        streamData.subtitleConfig = { trackName: subtitle.webvtt.toStr() }
                        exit for
                    end if
                end for
            end if
    
            if m.top.video <> invalid then
                m.top.video.content = streamData
            end if
            m.top.videoComplete = false
        end if
    end function

    m.player.adBreakStarted = function(adBreakInfo as object)
        print "---- Ad Break Started ---- ";adBreakInfo
        if m.top.video <> invalid then
            m.top.adPlaying = true
            m.top.video.enableTrickPlay = false
        end if
    end function

    m.player.adBreakEnded = function(adBreakInfo as object)
        print "---- Ad Break Ended ---- ";adBreakInfo
        if m.top.video <> invalid then
            m.top.adPlaying = false
            if m.top.snapbackTime > -1 and m.top.snapbackTime > m.top.video.position then
                m.top.video.seek = m.top.snapbackTime
                m.top.snapbackTime = -1
            end if
            m.top.video.enableTrickPlay = true
            m.top.video.setFocus(true)
        end if
    end function

    m.player.allVideoComplete = function()
        print "---- All Video Complete ---- "
        reset()
        m.top.videoComplete = true
    end function
end sub

sub addCallbacks()
    m.streamManager.addEventListener(m.sdk.AdEvent.ERROR, onError)
    m.streamManager.addEventListener(m.sdk.AdEvent.START, onAdStart)
    m.streamManager.addEventListener(m.sdk.AdEvent.FIRST_QUARTILE, onAdFirstQuartile)
    m.streamManager.addEventListener(m.sdk.AdEvent.MIDPOINT, onAdMidpoint)
    m.streamManager.addEventListener(m.sdk.AdEvent.THIRD_QUARTILE, onAdThirdQuartile)
    m.streamManager.addEventListener(m.sdk.AdEvent.COMPLETE, onAdComplete)
end sub

function reset()
    m.top.snapbackTime = -1
    m.top.streamData = invalid
    m.top.adPlaying = false
    if m.top.video <> invalid then
        m.top.video.enableTrickPlay = true
    end if
    m.top.streamManagerReady = false
end function

sub onVideoChanged()
    if m.video = invalid or not m.video.isSameNode(m.top.video) then
        if m.video <> invalid then
            m.video.unobserveFieldScoped("position")
            m.video.unobserveFieldScoped("timedMetadata")
            m.video.unobserveFieldScoped("state")
        end if
        m.video = m.top.video
        if m.video <> invalid then
            m.video.observeFieldScoped("position", m.port)
            m.video.observeFieldScoped("timedMetadata", m.port)
            m.video.observeFieldScoped("state", m.port)
        end if
    end if
end sub

sub onUserSeek(seekStartTime as integer, seekEndTime as integer)
    previousCuePoint = m.streamManager.getPreviousCuePoint(seekEndTime)
    if previousCuePoint = invalid or previousCuePoint.hasPlayed then
        print "Previous cuepoint was invalid or played"
        return
    else
        print "Previous cuepoint was ";previousCuepoint.start
        ' Add a second to make sure we hit the keyframe at the start of the ad
        print "Seeking to ";previousCuepoint.start + 1
        m.top.video.seek = previousCuePoint.start + 1
        m.top.snapbackTime = seekEndTime
        m.top.inSnapback = true
    end if
end sub

sub onAdStart(ad as object)
    if m.top.video <> invalid then
        print "Callback from SDK -- Start called - "; ad
        'print "ad.breakInfo: "; ad.adBreakInfo
        'print "ad.companions: "; ad.companions
        
        m.top.adStart = getAdEventData(ad)        
       
        'Check for brightline_direct or innovid campanion companion nodes
        for i = 0 to ad.companions.count()
           if ad.companions[i] <> invalid then
               apiframework =  ad.companions[i].apiframework 
               if apiframework <> invalid then
                    apiframework = LCase(ad.companions[i].apiframework)
               end if
               model = getModel().mid (0, 2).toInt() 
               if apiframework = "brightline_direct" then               
                    ad.adURL = ad.companions[i].url
                    ad.contentId = m.top.streamData.contentSourceID
                    ad.adName = ad.adtitle
                    ad.streamFormat = m.top.streamData.STREAMFORMAT
                    ad.startAt = m.top.video.position
                    ad.rendered = false            
                                
                    view = m.top.video.getParent()
                    
                    brightline = getGlobalField("brightline")
                    brightline.ad = {adPods: [ad], videoNode : m.top.video, rsgNode : view}
                    brightline.loadAd = "true"
                    
                else if apiframework = "innovid" and model > 36 then
                    m.video.enableUI = false
                    ad.adURL = ad.companions[i].url
                    ad.streamFormat = "iroll"
                    createIrollAd(ad.adURL, ad.duration, m.top.video.position)
                end if
            end if
        next
    end if
end sub

sub onAdFirstQuartile(ad as object)
    print "Callback from SDK -- First quartile called - "
    m.top.adFirstQuartile = getAdEventData(ad)
end sub

sub onAdMidpoint(ad as object)
    print "Callback from SDK -- Midpoint called - "
    m.top.adMidpoint = getAdEventData(ad)
end sub

sub onAdThirdQuartile(ad as object)
    print "Callback from SDK -- Third quartile called - "
    m.top.adThirdQuartile = getAdEventData(ad)
end sub

sub onAdComplete(ad as object)
    print "Callback from SDK -- Complete called - "

    m.top.adComplete = getAdEventData(ad)
    're-enableUI in case of Innovid ad
    m.video.enableUI = true
end sub

sub onError(error as object)
    print "Callback from SDK -- Error called - "; error
    ' errors are critical and should terminate the stream.
    m.errorState = true
end sub

function getAdEventData(ad as object) as object
    eventData = {}
    eventData.ad = {
        creativeID: ad.adID
        duration: ad.duration
        length: ad.duration
        title: ad.adTitle
    }
    breakInfo = ad.adBreakInfo
    eventData.podIndex = breakInfo.podIndex - 1
    eventData.adIndex = breakInfo.adPosition
    eventData.adCount = breakInfo.totalAds
    eventData.position = breakInfo.timeOffset
    return eventData
end function


' example or json url - http://video.innovid.com/tags/static.innovid.com/roku/1efrlb.json?cb=659ee1e1-1139-561b-37f1-7688826f630b
' @param String url_       - json file url ( as it defined in VAST )
' @param Float duration_   - duration of iroll ad ( as it defined in VAST )
' @param Float renderTime_ - relative position of iroll ad from beginning of SSAI content
function createIrollAd(url_ as String, duration_ as Float, renderTime_ as Float) as Void
  m.irollAd = m.video.getParent().createChild("InnovidAds:DefaultIrollAd")
  m.irollAd.id = "iroll-ad"
  m.irollAd.observeField("event", m.port)
  m.irollAd.observeField("request", m.port)

  size_ = CreateObject("roDeviceInfo").GetUIResolution()


  m.irollAd.action = {
    type:"init",
    uri:url_,
    width: 1920,
    height: 1080,
    ssai:{
      adapter:"default",
      renderTime:renderTime_,
      duration:duration_
    }
  }

  m.irollAd.action = { type : "start" }
end function

function isIrollEvent(msg_ as Object, field_ = "event") as Boolean
  if type( msg_ ) <> "roSGNodeEvent" or m.irollAd = invalid then
    return false
  end if

  target_ = msg_.getRoSGNode()

  if target_ = invalid or msg_.getField() <> field_ then
    return false
  end if

  return m.irollAd.isSameNode( msg_.getRoSGNode() )
end function

function isIrollPlaybackRequest(msg_ as Object) as Boolean
  return isIrollEvent( msg_, "request" )
end function

function isVideoPlaybackEvent(msg_ as Object) as Boolean
  if type( msg_ ) <> "roSGNodeEvent" or msg_.getRoSGNode() = invalid or m.video = invalid then
    return false
  end if

  if not(m.video.isSameNode( msg_.getRoSGNode() )) then
    return false
  end if

  field_ = msg_.getField()

  return field_ = "position" or field_ = "state"
end function

function handleIrollEvent(evt as Object) as Void
  adEvent = evt.getData()
  adId = evt.getNode()
  ' adEvent = {
  ''    type : string,
  ''    data? : object
  ''}
  ? "handleIrollEvent(";adId;", ";adEvent.type;")"
end function

function handleIrollPlaybackRequest(msg_ as Object) as Void
request_ = msg_.getData()
    if request_.type = "request-playback-pause" then
    m.top.video.control = "pause"
    else if request_.type = "request-playback-resume" then
      m.top.video.control = "resume"
    else if request_.type = "request-playback-prepare-to-restart" then
      ' this method called before iroll opens a secondary video player
      ' so, the host app should ( in general )
      ' - save a playback position
      ' - completely stop the current player
      m._restartPosition = m.top.video.position
      m.top.video.control = "stop"
    else if request_.type = "request-playback-restart" then
      m.top.video.control = "play"
      m.top.video.seek = m._restartPosition
      ' this method called after iroll closes a microsite and try to resume ssai playback, the host app should restart a playback from saved position
    end if

    ? "handleIrollPlaybackRequest(";request_.type;", video.state: ";GetGlobalAA().video.state;")"
  end function

function handlePlaybackStateChanged(evt_ as Object) as Void
  ''?"video_ = "video_
''  ?"evt_.getRoSGNode.streamData = "evt_.getRoSGNode().streamData
''  ?"evt_.getRoSGNode.video = "evt_.getRoSGNode().video
''  ?"type of m.irollAd = " type(m.irollAd)
    if GetInterface(evt_.getRoSGNode(), "ifSGNodeDict") <> invalid then
      t = evt_.getRoSGNode()
    end if
    video_ = evt_.getRoSGNode()
  if type(m.irollAd) <> "Invalid" THEN
''  ?" I shouldn't be here"
''  ?"position_ = "video_.position
''  ?"state_ = "video_.state
    m.irollAd.action={
      type:"notifyPlaybackStateChanged",
      position:video_.position,
      state:video_.state
    }
  end if
end function