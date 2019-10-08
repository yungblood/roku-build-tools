function getImaSdk() as object


imasdk = {}
imasdk.CreateAdBreakInfo = function() as object
adBreakInfo = createobject("roAssociativeArray")
adBreakInfo.duration = -1
adBreakInfo.adPosition = -1
adBreakInfo.totalAds = -1
adBreakInfo.podIndex = -1
adBreakInfo.timeOffset = -1
return adBreakInfo
end function
imasdk.CreateAdInfo = function() as object
adInfo = createobject("roAssociativeArray")
adInfo.adid = ""
adInfo.duration = -1
adInfo.adtitle = ""
adInfo.adDescription = ""
adInfo.adSystem = ""
adInfo.adBreakInfo = m.CreateAdBreakInfo()
return adInfo
end function
imasdk.ErrorEvent = {
ERROR : "0",
COULD_NOT_LOAD_STREAM: "1000",
STREAM_API_KEY_NOT_VALID: "1002",
BAD_STREAM_REQUEST: "1003"
INVALID_RESPONSE: "1004"
}
imasdk.AdEvent = {
START: "start",
CREATIVE_VIEW: "creativeView",
FIRST_QUARTILE: "firstQuartile",
IMPRESSION: "impression",
MIDPOINT: "midpoint",
THIRD_QUARTILE: "thirdQuartile",
COMPLETE: "complete",
ERROR: "error"
}
imasdk.StreamType = {
LIVE: 1,
VOD: 2
}
imasdk.CreateCuePoint = function() as object
cuepoint = {}
cuepoint.START = -1
cuepoint.end = -1
cuepoint.hasPlayed = false
return cuepoint
end function
imasdk.CreateError = function() as object
ERROR = createobject("roAssociativeArray")
ERROR.id = ""
ERROR.info = ""
ERROR.type = "error"
return ERROR
end function
imasdk.createPlayer = function() as object
player = {}
player.loadUrl = function(streamInfo as object) as Void
end function
player.adBreakStarted = function(adBreakInfo as object) as Void
end function
player.adBreakEnded = function(adBreakInfo as object) as Void
end function
player.allVideoComplete = function() as Void
end function
return player
end function
imasdk.initSdk = function() as Void
if m.sdkSingleton = invalid
m.sdkSingleton = m.CreateSdkImpl()
end if
end function
imasdk.requestStream = function(streamRequest as object) as object
return m.sdkSingleton.requestStream(streamRequest)
end function
imasdk.getStreamManager = function() as object
return m.sdkSingleton.getStreamManager()
end function
imasdk.setCertificate = function(certificateRef as string) as Void
m.certificate = certificateRef
end function
imasdk.getCertificate = function() as string
if m.certificate = invalid
return "common:/certs/ca-bundle.crt"
end if
return m.certificate
end function
m.sdkSingleton = invalid
imasdk.CreateStreamInfo = function() as object
streamInfo = {}
streamInfo.manifest = ""
streamInfo.subtitles = invalid
streamInfo.streamId = ""
streamInfo.StreamType = -1
return streamInfo
end function
imasdk.CreateStreamManager = function(streamRequest as object, streamInitResponse as object) as object
obj = m.createIMAObject("streamManager")
obj.impl = obj.sdk.createStreamManagerImpl(streamRequest, streamInitResponse)
return obj
end function
StreamManager = {}
StreamManager.addEventListener = function(event as string, callback as function) as Void
m.impl.addEventListener(event, callback)
end function
StreamManager.onMessage = function(msg as object) as Void
m.impl.onMessage(msg)
end function
StreamManager.START = function() as Void
m.impl.START()
end function
StreamManager.getStreamTime = function(contentTime as integer) as integer
return m.impl.getStreamTime(contentTime)
end function
StreamManager.getContentTime = function(streamTime as integer) as integer
return m.impl.getContentTime(streamTime)
end function
StreamManager.getPreviousCuePoint =  function(time as integer) as object
return m.impl.getPreviousCuePoint(time)
end function
StreamManager.getCuePoints =  function() as object
return m.impl.getCuePoints()
end function
StreamManager.enableInteractiveAds = function(videoPlayer as object) as object
return m.impl.enableInteractiveAds(videoPlayer)
end function
imasdk.StreamManager = StreamManager
imasdk.CreateStreamRequest = function() as object
obj = m.createIMAObject("adsRequest")
obj.player = invalid
obj.assetKey = ""
obj.apiKey = ""
obj.contentSourceId = ""
obj.videoId = ""
obj.adTagParameters = ""
obj.ppid = ""
obj.authToken = ""
obj.streamActivityMonitorId = ""
obj.testStreamUrl = ""
return obj
end function
imasdk.a = function() as object
obj = m.createIMAObject("Ad")
obj.b = []
obj.c = []
obj.d = []
obj.id = "-1"
return obj
end function
e = {}
e.f = function(creativeid as string) as object
for each g in m.b
if g.id = creativeid then
return g
end if
end for
return invalid
end function
e.h = function() as object
return m.b
end function
e.push = function(g as object) as Void
m.b.push(g)
end function
imasdk["ad"] = e
imasdk.i = function(j as object) as object
obj = m.createIMAObject("adDataLoader")
obj.k = {}
obj.l = createobject("roMessagePort")
obj.n = invalid
obj.j = j
obj.o = createobject("roTimespan")
obj.p = 10
return obj
end function
q = {}
q.r = function() as boolean
s = m.t()
m.n = m.sdk.u()
l = m.l
m.n.setmessageport(l)
m.n.seturl(s)
m.n.addheader("Accept", "application/json")
m.n.asyncgettostring()
m.o.mark()
if not m.j.v()
return m.w()
end if
return true
end function
q.w = function() as boolean
x = m.l.waitmessage(5000)
if m.y(x)
z = x.getstring()
m.k = parsejson(z)
if m.k = invalid
m.k = {}
end if
else
return false
end if
ab = m.bb()
ab.sortby("start")
return true
end function
q.t = function() as string
if m.j.v()
return m.j.cb()
end if
return m.j.db()
end function
q.eb = function() as Void
if m.o.totalseconds() > m.p
m.r()
end if
x = m.l.getmessage()
if m.y(x)
z = x.getstring()
m.k = parsejson(z)
if m.k = invalid
m.k = {}
end if
end if
end function
q.y = function(x as object) as boolean
if x = invalid or type(x) <> "roUrlEvent"
return false
end if
if x.getstring() = ""
return false
end if
return true
end function
q.fb = function(p as integer) as Void
m.p = p
end function
q.gb = function(hb as string) as string
if not m.ib(hb)
return ""
end if
jb = m.k["tags"]
kb = jb[hb]
return kb["ad"]
end function
q.lb = function(hb as string) as string
if not m.ib(hb)
return ""
end if
jb = m.k["tags"]
kb = jb[hb]
return kb["type"]
end function
q.mb = function(nb as string) as object
ads = m.k["ads"]
if ads = invalid
return invalid
end if
return ads[nb]
end function
q.ob = function(nb as string, adInfo as object) as object
adInfo.adtitle = ""
adInfo.adDescription = ""
e = m.mb(nb)
if e = invalid
return invalid
end if
if e["vast"] = invalid
return invalid
end if
pb = m.sdk.qb()
rb = pb.parse(e["vast"])
sb = rb.tb()
if sb = invalid
return invalid
end if
if sb.b.count() < 1
return invalid
end if
g = sb.b[0]
ub = g.vb
if sb.c <> invalid
ub["impression"] = sb.c
end if
adInfo.adtitle = sb.wb
adInfo.adDescription = sb.xb
adInfo.adid = sb.id
adInfo.adSystem = sb.yb
adInfo.duration = m.zb(nb)
adInfo.adBreakInfo.duration = m.ac(nb)
adInfo.adBreakInfo.adPosition = m.bc(nb)
adInfo.adBreakInfo.totalAds = m.cc(nb)
return ub
end function
q.dc = function() as string
return m.adtitle
end function
q.ec = function() as string
return m.adDescription
end function
q.ib = function(hb as string) as boolean
jb = m.k["tags"]
if jb = invalid
return false
end if
if jb[hb] = invalid
return false
end if
return true
end function
q.zb = function(nb as string) as integer
e = m.mb(nb)
return m.fc(e, "duration")
end function
q.gc = function(nb as string) as object
e = m.mb(nb)
if e = invalid
return invalid
end if
hc = e["break"]
if hc = invalid
return invalid
end if
ic = m.k["breaks"]
if ic = invalid
return invalid
end if
return ic[hc]
end function
q.ac = function(nb as string) as integer
jc = m.gc(nb)
return m.fc(jc, "duration")
end function
q.bc = function(nb as string) as integer
e = m.mb(nb)
return m.fc(e, "position")
end function
q.cc = function(nb as string) as integer
jc = m.gc(nb)
return m.fc(jc, "ads")
end function
q.fc = function(obj as object, kc as string) as integer
if obj = invalid or obj[kc] = invalid
return -1
end if
return obj[kc]
end function
q.bb = function() as object
if m.k["cuepoints"] = invalid
return []
end if
return m.k["cuepoints"]
end function
q.lc = function() as object
if m.k["times"] = invalid
return createobject("roArray", 0, false)
end if
return m.k["times"]
end function
q.mc = function(time as integer) as object
if m.k["times"] = invalid
return createobject("roArray", 0, false)
end if
nc = time.tostr()
oc = m.k["times"]
if oc[nc] = invalid
return createobject("roArray", 0, false)
end if
return oc[nc]
end function
imasdk["AdDataLoader"] = q
imasdk.pc = function() as object
obj = m.createIMAObject("Ads")
obj.ads = []
return obj
end function
ads= {}
ads.mb = function(adid as string) as object
for each e in m.ads
if e.id = adid then
return e
end if
end for
return invalid
end function
ads.qc = function() as object
return m.ads
end function
ads.tb = function() as object
if m.ads.count() <0
return invalid
end if
return m.ads[0]
end function
ads.push = function(e as object) as Void
m.ads.push(e)
end function
imasdk["ads"] = ads
imasdk.rc = function() as object
obj = {}
obj.width = -1
obj.height = -1
obj.url = ""
obj.sc = ""
obj.vb = {}
return obj
end function
imasdk.tc = function() as object
obj = {}
obj.uc = true
obj.duration = -1
obj.id = "-1"
obj.vc = ""
obj.mimetype = ""
obj.vb = {}
obj.wc = []
obj.xc = []
return obj
end function
imasdk.yc = function() as object
obj = m.createIMAObject("eventCallbacks")
obj.zc = {}
obj.zc[obj.sdk.AdEvent.START] = []
obj.zc[obj.sdk.AdEvent.FIRST_QUARTILE] = []
obj.zc[obj.sdk.AdEvent.MIDPOINT] = []
obj.zc[obj.sdk.AdEvent.THIRD_QUARTILE] = []
obj.zc[obj.sdk.AdEvent.COMPLETE] = []
obj.zc[obj.sdk.AdEvent.ERROR] = []
return obj
end function
bd = {}
bd.addEventListener = function(event as string, callback as function) as Void
if m.zc[event] <> invalid
m.zc[event].push(callback)
end if
end function
bd.cd = function(event as string, adInfo as object) as Void
for each callback in m.zc[event]
dd = getglobalaa()["callFunctionInGlobalNamespace"]
dd(callback, adInfo)
end for
end function
bd.ed = function(fd as integer, gd as string) as Void
ERROR = m.sdk.CreateError()
ERROR.id = fd
ERROR.info = gd
dd = getglobalaa()["callFunctionInGlobalNamespace"]
dd(m.sdk.AdEvent.ERROR, ERROR)
endfunction
imasdk["EventCallbacks"] = bd
imasdk.hd = {
jd: "START",
kd: "FIRSTQUARTILE",
ld: "MIDPOINT",
md: "THIRDQUARTILE",
nd: "COMPLETE"
}
imasdk.od = {
LIVE : "live",
pd: "on_demand"
}
imasdk.qd = {
rd: 10
}
imasdk.sd = {
td: "https://pubads.g.doubleclick.net/ssai/event/",
ud: "https://dai.google.com/ondemand/hls/content/"
}
imasdk.vd = {
wd: 0,
xd: 1,
yd: 2,
zd: 3
}
imasdk.ae = {
be: "r.3.23.0"
}
imasdk.CreateSdkImpl = function() as object
obj = m.createIMAObject("sdkImpl")
obj.ce = invalid
obj.streamInitResponse = invalid
obj.streamRequest = invalid
return obj
end function
de = {}
de.requestStream = function(streamRequest as object) as object
m.streamRequest = streamRequest
m.ce = invalid
m.streamInitResponse = m.sdk.ee()
return m.streamInitResponse.fe(streamRequest)
end function
de.getStreamManager = function() as object
if m.ce <> invalid
return m.ce
end if
ge = m.streamInitResponse.he()
if ge = invalid
return invalid
end if
if ge["type"] = "error"
return ge
end if
m.ce = m.sdk.CreateStreamManager(m.streamRequest, m.streamInitResponse)
return m.ce
end function
imasdk["SdkImpl"] = de
imasdk.ee = function() as object
obj = m.createIMAObject("streamInitResponse")
obj.k = invalid
obj.n = invalid
return obj
end function
streamInitResponse = {}
streamInitResponse.fe = function(streamRequest as object) as object
ERROR = m.ie(streamRequest)
if ERROR <> invalid
return ERROR
end if
je = m.ke(streamRequest)
m.n = m.sdk.u()
l = createobject("roMessagePort")
m.n.setmessageport(l)
m.n.seturl(je)
if streamRequest.authToken <> ""
le = "DCLKDAI token=" + chr(34) + streamRequest.authToken + chr(34)
me = "Authorization"
m.n.addheader(me, le)
else if streamRequest.apiKey <> ""
le = "DCLKDAI key=" + chr(34) + streamRequest.apiKey + chr(34)
me = "Authorization"
m.n.addheader(me, le)
end if
ne = m.oe(streamRequest)
m.n.asyncpostfromstring(ne)
return invalid
end function
streamInitResponse.ie = function(streamRequest as object) as object
pe = m.qe(streamRequest.contentSourceId)
re = m.qe(streamRequest.assetKey)
se = m.qe(streamRequest.videoId)
te = m.qe(streamRequest.testStreamUrl)
if te
else if not re and not pe
ERROR = m.sdk.CreateError()
ERROR.id = m.sdk.ErrorEvent.BAD_STREAM_REQUEST
ERROR.info = "Stream request must contain an assetKey for live or conentSourceId for VOD."
return ERROR
else if re and pe
ERROR = m.sdk.CreateError()
ERROR.id = m.sdk.ErrorEvent.BAD_STREAM_REQUEST
ERROR.info = "Cannot determine stream type. Specify only assetKey or contentSourceId."
return ERROR
else if pe and not se
ERROR = m.sdk.CreateError()
ERROR.id = m.sdk.ErrorEvent.BAD_STREAM_REQUEST
ERROR.info = "Missing videoId in VOD stream request."
return ERROR
else if type(streamRequest.apiKey) <> "roString"
ERROR = m.sdk.CreateError()
ERROR.id = m.sdk.ErrorEvent.BAD_STREAM_REQUEST
ERROR.info = "ApiKey must be a string."
return ERROR
else if type(streamRequest.authToken) <> "roString"
ERROR = m.sdk.CreateError()
ERROR.id = m.sdk.ErrorEvent.BAD_STREAM_REQUEST
ERROR.info = "authToken must be a string."
return ERROR
else if type(streamRequest.streamActivityMonitorId) <> "roString"
ERROR = m.sdk.CreateError()
ERROR.id = m.sdk.ErrorEvent.BAD_STREAM_REQUEST
ERROR.info = "streamActivityMonitorId must be a string."
return ERROR
end if
return invalid
end function
streamInitResponse.qe = function(ue as dynamic) as boolean
ve = type(ue)
if ve = "roString" or ve = "String"
return len(ue) > 0
end if
return false
end function
streamInitResponse.he = function() as object
if m.k <> invalid
return {type: "ready"}
end if
l = m.n.getmessageport()
x = l.getmessage()
if x = invalid
return invalid
end if
if m.we(x)
if x.getresponsecode() = 404
ERROR = m.sdk.CreateError()
ERROR.id = m.sdk.ErrorEvent.COULD_NOT_LOAD_STREAM
ERROR.info = "The stream could not be loaded."
return ERROR
end if
if x.getresponsecode() = 401
ERROR = m.sdk.CreateError()
ERROR.id = m.sdk.ErrorEvent.STREAM_API_KEY_NOT_VALID
ERROR.info = "The stream key was not valid."
return ERROR
end if
end if
m.k = parsejson(x)
if not m.isvalid()
ERROR = m.sdk.CreateError()
ERROR.id = m.sdk.ErrorEvent.INVALID_RESPONSE
ERROR.info = "The servers response was not valid."
return ERROR
end if
return {type: "ready"}
end function
streamInitResponse.we = function(x as dynamic) as boolean
return type(x) = "roUrlEvent"
end function
streamInitResponse.ke = function(streamRequest as object) as string
url = ""
if m.qe(streamRequest.testStreamUrl)
url = streamRequest.testStreamUrl
else if m.qe(streamRequest.assetKey)
url = m.xe(streamRequest)
else if m.qe(streamRequest.contentSourceId)
url = m.ye(streamRequest)
else
m.sdk.log("generateStreamRequestUrl: Invalid state reached.")
end if
return url
end function
streamInitResponse.oe = function(streamRequest as object) as string
ze = createobject("roArray", 10, true)
af = m.bf()
ze.push("rdid="+ af.getadvertisingid())
ze.push("idtype=rida")
if not af.isadidtrackingdisabled()
ze.push("is_lat=0")
else
ze.push("is_lat=1")
end if
ze.push("submodel=" + af.getmodel())
if streamRequest.streamActivityMonitorId <> ""
ze.push("dai-sam-id=" + streamRequest.streamActivityMonitorId)
end if
ze.push("sdkv=" + m.sdk.ae.be)
if streamRequest.ppid <> ""
cf = createobject("roRegex", "ppid=", "")
if cf.ismatch(streamRequest.adTagParameters)
else
ze.push("ppid=" + streamRequest.ppid)
end if
end if
adTagParameters = m.df(streamRequest.adTagParameters)
if adTagParameters <> ""
ze.push(adTagParameters)
end if
ef = m.ff()
wb = ef.gettitle()
if wb <> invalid and wb <> ""
n = createobject("roUrlTransfer")
gf = n.escape(wb)
ze.push("an=" + gf)
end if
hf = ef.getid()
if hf <> invalid and hf <> ""
ze.push("msid=" + hf)
end if
ze.push("frm=0")
ze.push("correlator=" + m.jf())
ne = ""
for each kf in ze
if ne <> ""
ne = ne + "&"
end if
ne = ne + kf
end for
return ne
end function
streamInitResponse.df = function(in as string) as string
lf = createobject("roRegex", "&", "")
mf = lf.split(in)
nf = createobject("roRegex", "=", "")
of = ""
for each kf in mf
pf = nf.split(kf)
if pf.count() = 2
kc = pf.getentry(0)
qf = pf.getentry(1)
if m.rf(kc)
if of <> ""
of = of + "&"
end if
of = of + kf
end if
end if
end for
return of
end function
streamInitResponse.rf = function(kc as string) as boolean
sf = createobject("roRegex", "^imafw_", "")
if sf.ismatch(kc)
return true
end if
tf = createobject("roRegex", ",", "")
uf = "cust_params,iu,tfcd,description_url,durl,dai-ah,dai-dlid,dai-ot,dai-ov,sz,ppid"
vf = tf.split(uf)
for each wf in vf
if wf = kc
return true
end if
end for
return false
end function
streamInitResponse.jf = function() as string
xf = rnd(32767)
yf = rnd(32767)
zf = xf.tostr() + yf.tostr()
return zf
end function
streamInitResponse.xe = function(streamRequest as object) as string
return m.sdk.sd.td + streamRequest.assetKey + "/streams"
end function
streamInitResponse.ye = function(streamRequest as object) as string
return m.sdk.sd.ud + streamRequest.contentSourceId + "/vid/" + streamRequest.videoId + "/streams"
end function
streamInitResponse.bf = function() as object
return createobject("roDeviceInfo")
end function
streamInitResponse.ff = function() as object
return createobject("roAppInfo")
end function
streamInitResponse.isvalid = function() as boolean
if m.k = invalid
return false
end if
StreamType = m.k.lookup("stream_type")
if not m.ag("stream_id")
m.sdk.log("Internal Error: stream_id missing.")
end if
if StreamType = m.sdk.od.LIVE
if not m.ag("id3_events_url")
m.sdk.log("Internal Error: No tracking pings.")
end if
else if StreamType = m.sdk.od.pd
if not m.ag("time_events_url")
m.sdk.log("Internal Error: No tracking pings.")
end if
else
m.sdk.log("Internal Error: Streamtype invalid.")
end if
return m.ag("stream_manifest")
end function
streamInitResponse.v = function() as boolean
return m.k["stream_type"] = m.sdk.od.LIVE
end function
streamInitResponse.ag = function(kc as string) as boolean
qf = m.k.lookup(kc)
return qf <> invalid and qf <> ""
end function
streamInitResponse.bg = function() as string
if m.k = invalid or m.k["stream_id"] = invalid
return ""
end if
return m.k["stream_id"]
end function
streamInitResponse.cg = function() as string
return m.k["stream_type"]
end function
streamInitResponse.dg = function() as string
return m.k["stream_manifest"]
end function
streamInitResponse.eg = function() as integer
fg = m.k["polling_frequency"]
if fg = invalid
fg = m.sdk.qd.rd
end if
return fg
end function
streamInitResponse.gg = function() as object
subtitles = m.k["subtitles"]
if subtitles <> invalid and type(subtitles) = "roArray"
return m.k["subtitles"]
end if
return []
end function
streamInitResponse.cb = function() as string
return m.k["id3_events_url"]
end function
streamInitResponse.db = function() as string
return m.k["time_events_url"]
end function
imasdk["StreamInitResponse"] = streamInitResponse
imasdk.createStreamManagerImpl = function(streamRequest as object, streamInitResponse as object) as object
obj = m.createIMAObject("streamManagerImpl")
obj.player = streamRequest.player
obj.hg = createobject("roAssociativeArray")
obj.adInfo = obj.sdk.CreateAdInfo()
obj.nb = ""
obj.vb = invalid
obj.bd = obj.sdk.yc()
obj.streamInitResponse = streamInitResponse
obj.q = obj.sdk.i(streamInitResponse)
obj.ig = -1
obj.jg = -1
obj.kg = false
obj.lg = 0
obj.mg = 0
obj.ng = 0
obj.og = invalid
obj.pg = createobject("roMessagePort")
return obj
end function
qg = {}
qg.START = function() as Void
m.q.fb(m.streamInitResponse.eg())
m.q.r()
info = m.sdk.CreateStreamInfo()
info.manifest = m.streamInitResponse.dg()
info.subtitles = m.streamInitResponse.gg()
info.streamId = m.streamInitResponse.bg()
if m.streamInitResponse.v()
info.StreamType = m.sdk.StreamType.LIVE
else
info.StreamType = m.sdk.StreamType.VOD
end if
m.player.loadUrl(info)
end function
qg.onMessage = function(msg as object) as Void
vd = m.rg(msg)
if vd = m.sdk.vd.zd
m.sdk.log("All video is completed - full result")
m.player.allVideoComplete()
else if vd = m.sdk.vd.xd
m.sg(msg)
end if
if m.streamInitResponse.v()
m.tg(msg)
else
m.ug(msg)
end if
end function
qg.rg = function(msg as object) as integer
if m.vg(msg)
if msg.isplaybackposition()
return m.sdk.vd.xd
else if msg.istimedmetadata()
return m.sdk.vd.yd
else if msg.isfullresult()
return m.sdk.vd.zd
end if
else if m.wg(msg)
xg = msg.getfield()
if xg = "position"
return m.sdk.vd.xd
else if xg = "timedMetaData"
return m.sdk.vd.yd
else if xg = "state"
if msg.getdata() = "finished"
return m.sdk.vd.zd
end if
end if
end if
return m.sdk.vd.wd
end function
qg.yg = function(msg as object) as integer
if m.vg(msg)
return msg.getindex()
else if m.wg(msg)
return msg.getdata()
end if
end function
qg.tg = function(msg as object) as Void
m.q.eb()
vd = m.rg(msg)
if vd <> m.sdk.vd.yd
return
end if
if m.vg(msg)
zg = msg.getinfo()
for each kc in zg
ah = zg[kc]
m.bh(ah)
end for
else if m.wg(msg)
ah = msg.getdata()["TXXX"]
m.bh(ah)
end if
end function
qg.sg = function(msg as object) as Void
m.ng = m.yg(msg)
if not m.kg or m.adInfo = invalid or m.adInfo.adBreakInfo = invalid or m.adInfo.adBreakInfo.duration = invalid
return
end if
if m.ng > m.mg + m.adInfo.adBreakInfo.duration + 3
m.ch()
else if m.nb <> "" and m.adInfo.duration <> invalid and m.adInfo.duration <> -1
if m.ng > m.lg + m.adInfo.duration + 3
m.ch()
end if
end if
end function
qg.dh = function(msg as object) as Void
if m.og <> invalid
eh = m.sdk.fh()
eh.stitchedadhandledevent(msg, m.og)
end if
end function
qg.ug = function(msg as object) as Void
m.dh(msg)
vd = m.rg(msg)
if vd <> m.sdk.vd.xd
return
end if
ng = m.yg(msg)
if ng = m.ig or ng = m.jg
return
end if
m.jg = m.ig
m.ig = ng
if m.ig <> m.jg + 1
m.gh(ng - 1)
end if
m.gh(ng)
end function
qg.gh = function(time as integer) as Void
hh = m.q.mc(time)
for each event in hh
nb = event["ad"]
ih = event["type"]
if ih <> invalid and nb <> invalid
m.jh(nb, ih, time)
end if
end for
end function
qg.wg = function(msg as object) as boolean
return type(msg) = "roSGNodeEvent"
end function
qg.vg = function(msg as object) as boolean
return type(msg) = "roVideoScreenEvent" or type(msg) = "roVideoPlayerEvent"
end function
qg.kh = function(msg as object) as boolean
return msg.isstatusmessage() and msg.getmessage() = "startup progress"
end function
qg.lh = function(nb as string) as boolean
return m.hg[nb] <> invalid
end function
qg.mh = function(nb as string, time as integer) as Void
if not m.lh(nb)
m.hg[nb] = true
m.nb = nb
m.vb = m.q.ob(nb, m.adInfo)
adBreakInfo = m.adInfo.adBreakInfo
if (adBreakInfo.adPosition = 1)
adBreakInfo.timeOffset = time
adBreakInfo.podIndex = m.nh(time)
m.player.adBreakStarted(adBreakInfo)
m.kg = true
m.mg = time
end if
m.lg = time
m.oh(m.sdk.AdEvent.START)
m.ph(m.sdk.AdEvent.IMPRESSION)
m.ph(m.sdk.AdEvent.CREATIVE_VIEW)
else
m.nb = ""
end if
end function
qg.qh = function() as Void
m.oh(m.sdk.AdEvent.COMPLETE)
m.nb = ""
m.vb = invalid
adBreakInfo = m.adInfo.adBreakInfo
if (adBreakInfo.adPosition = adBreakInfo.totalAds)
m.ch()
end if
end function
qg.ch = function() as Void
adBreakInfo = m.adInfo.adBreakInfo
m.player.adBreakEnded(adBreakInfo)
m.kg = false
m.nb = ""
end function
qg.bh = function(rh as string) as Void
event = m.q.lb(rh)
nb = m.q.gb(rh)
if event <> "" and nb <> ""
m.jh(nb, event, m.ng)
end if
end function
qg.jh = function(nb as string, event as string, time as integer) as Void
event = ucase(event)
if event = m.sdk.hd.jd
m.mh(nb, time)
end if
if m.nb <> nb
m.nb = ""
return
end if
if event = m.sdk.hd.jd
return
else if event = m.sdk.hd.kd
m.oh(m.sdk.AdEvent.FIRST_QUARTILE)
else if event = m.sdk.hd.ld
m.oh(m.sdk.AdEvent.MIDPOINT)
else if event = m.sdk.hd.md
m.oh(m.sdk.AdEvent.THIRD_QUARTILE)
else if event = m.sdk.hd.nd
m.qh()
else
m.sdk.log("handleEvent:Unexpected event type " + event)
end if
end function
qg.oh = function(ih as string) as Void
m.ph(ih)
m.bd.cd(ih, m.adInfo)
end function
qg.ph = function(ih as string) as Void
if m.vb <> invalid and m.vb[ih] <> invalid
m.sdk.sh(m.vb[ih], ih)
end if
end function
qg.gg = function() as object
return m.streamInitResponse.gg()
end function
qg.addEventListener = function(event as string, callback as function) as Void
m.bd.addEventListener(event, callback)
end function
qg.getStreamTime = function(contentTime as integer) as integer
ab = m.q.bb()
if m.streamInitResponse.v() or type(ab) <> "roArray"
return contentTime
end if
th = 0
uh = contentTime
for each cuepoint in ab
vh = (cuepoint["start"] * 1000) - th
if vh >= uh
return th + uh
else
uh = uh - vh
end if
th = cuepoint["end"] * 1000
end for
return th + uh
end function
qg.getContentTime = function(streamTime as integer) as integer
ab = m.q.bb()
if streamTime < 0
streamTime = m.ng * 1000
end if
if m.streamInitResponse.v() or type(ab) <> "roArray"
return streamTime
end if
th = 0
contentTime = 0
for each cuepoint in ab
vh = (cuepoint["start"] * 1000) - th
if streamTime <= (cuepoint["start"] * 1000)
return contentTime + (streamTime - th)
else if streamTime <= cuepoint["end"] * 1000
return contentTime + vh
else
contentTime = contentTime + vh
end if
th = cuepoint["end"] * 1000
end for
return contentTime + (streamTime - th)
end function
qg.wh = function(xh as object) as object
hasPlayed = false
hh = m.q.mc(xh.START)
for each event in hh
nb = event["ad"]
ih = ucase(event["type"])
if nb <> invalid and ih = m.sdk.hd.jd and m.lh(nb)
hasPlayed = true
exit for
end if
end for
yh = m.sdk.CreateCuePoint()
yh["start"] = xh["start"]
yh["end"] = xh["end"]
yh["hasPlayed"] = hasPlayed
return yh
end function
qg.getCuePoints = function() as object
ab = m.q.bb()
zh = []
for each cuepoint in ab
ai = m.wh(cuepoint)
zh.push(ai)
end for
return zh
end function
qg.getPreviousCuePoint = function(time as integer) as object
ab = m.q.bb()
bi = invalid
for each cuepoint in ab
if time >= cuepoint.START
bi = cuepoint
else
exit for
end if
end for
if bi = invalid
return invalid
end if
return m.wh(bi)
end function
qg.nh = function(time as integer) as integer
ab = m.q.bb()
ci = 0
for each cuepoint in ab
if time = cuepoint.START
return ci
end if
ci = ci + 1
end for
return -1
end function
qg.enableInteractiveAds = function(videoPlayer as object) as Void
if m.streamInitResponse.v() or videoPlayer = invalid
return
end if
ei = false
if type(videoPlayer) = "roVideoPlayer"
ei = true
m.og = m.fi(videoPlayer)
else if type(videoPlayer) = "roAssociativeArray"
if videoPlayer.doesexist("port") and videoPlayer.doesexist("sgnode")
ei = true
end if
m.og = videoPlayer
end if
if not ei
m.sdk.log("Warning: Invalid object for interactive ads.")
return
end if
m.gi()
end function
qg.gi = function() as Void
pb = m.sdk.qb()
hi = m.sdk.ii()
adpods = []
oc = m.q.lc()
for each time in oc
for each event in oc[time]
if ucase(event["type"]) = m.sdk.hd.jd
e = m.q.mb(event["ad"])
if e <> invalid
ads = pb.parse(e["vast"])
sb = ads.tb()
if hi.ji(sb)
ki = hi.li(sb, val(time, 10))
adpods.push(ki)
end if
end if
end if
end for
end for
mi = m.sdk.fh()
mi.stitchedadsinit(adpods)
end function
qg.fi = function(ni as object) as object
oi = {}
oi["GetMessagePort"] = function() as object
return m.player.getmessageport()
end function
oi["Pause"] = function() as boolean
return m.player.pause()
end function
oi["Resume"] = function() as boolean
return m.player.resume()
end function
oi["Seek"] = function(pi as integer) as boolean
return m.player.seek(pi)
end function
oi["Play"] = function() as boolean
return m.player.play()
end function
oi["Stop"] = function() as boolean
return m.player.stop()
end function
oi.player = ni
return oi
end function
imasdk["StreamManagerImpl"] = qg
imasdk.qi = createobject("roRegex", "\[[A-Za-z0-9\-\_]*\]", "")
imasdk.ri = createobject("roRegex", ".*(doubleclick\.net|googleadservices\.com)\/(pagead\/conversion|pagead\/adview|pcs\/view)", "")
imasdk.si = createobject("roRegex", "(?=.*\bai\=\b)(?=.*\bsigh\=\b)", "")
imasdk.ti = createobject("roRegex", "imrworldwide\.com", "")
imasdk.loadUrl = function(url as string) as string
l = m.ui()
n = m.u()
n.seturl(url)
n.setport(l)
n.asyncgettostring()
vi = 4000
event = l.waitmessage(vi)
if event = invalid
m.log("Event is invalid. Possible timeout on loading URL")
return ""
else if m.we(event)
wi = event.getresponsecode()
if wi < 0
m.log("Transfer failed reason: " + event.getfailurereason())
return ""
else if wi <> 200
m.log("Transfer failed, got code " + xi(wi))
return ""
end if
yi = event.getstring()
return yi
else
m.log("Unknown Ad Request Event: " + type(event))
end if
return ""
end function
imasdk.we = function(object) as boolean
return type(event) = "roUrlEvent"
end function
imasdk.zi = function(aj as string) as object
bj = createobject("roXmlElement")
if aj = invalid or not bj.parse(aj) then
return invalid
end if
return bj
end function
imasdk.fh = function() as object
return roku_ads()
end function
imasdk.cj = function(dj as string) as boolean
return m.ti.ismatch(dj)
end function
imasdk.ej = function(dj as string) as boolean
return m.ri.ismatch(dj) and m.si.ismatch(dj)
end function
imasdk.fj = function(dj as string) as string
gj = m.qi.replaceall(dj, "")
if m.ej(gj)
gj = gj + "&ssss=gima&sdkv=" + m.ae.be
end if
return gj
end function
imasdk.sh = function(sd as object, hj as string) as Void
ij = createobject("roArray", 5, true)
for each dj in sd
if m.cj(dj)
m.jj(dj, hj)
else
kj = {}
kj.l = m.ui()
kj.n = m.u()
dj = m.fj(dj)
kj.n.seturl(dj)
kj.n.setport(kj.l)
kj.n.asyncgettostring()
ij.push(kj)
end if
end for
lj = createobject("roTimespan")
lj.mark()
mj = 0
while not ij.isempty() and lj.totalmilliseconds() < 5000
kj = ij.getentry(mj)
x = kj.l.waitmessage(10)
if x <> invalid
ij.delete(mj)
end if
mj = mj + 1
if mj >= ij.count()
mj = 0
end if
end while
end function
imasdk.jj = function(dj as string, hj as string) as Void
nj = {}
nj["event"] = hj
nj["url"] = dj
nj["triggered"] = false
oj = [nj]
pj = {}
pj["tracking"] = oj
pj["adServer"] = invalid
qj = {}
qj["type"] = hj
mi = m.fh()
ge = mi.firetrackingevents(pj, qj)
end function
imasdk.ui = function() as object
return createobject("roMessagePort")
end function
imasdk.createIMAObject = function(rj as string) as object
obj = {
sdk: m
}
if type(m[rj]) = "roAssociativeArray" then
obj.append(m[rj])
end if
return obj
end function
imasdk.log = function(x) as Void
sj = createobject("roDateTime")
tj = "IMA (" + sj.gethours().tostr() + ":" + sj.getminutes().tostr() + ":" + sj.getseconds().tostr() + "): "
print tj; x
end function
imasdk.uj = function(time as string) as integer
vj = box(time).tokenize(":")
wj = vj[0].toint() * 3600
wj = wj + vj[1].toint() * 60
wj = wj + vj[2].toint()
return wj
end function
imasdk.u = function() as object
m.n = createobject("roUrlTransfer")
m.n.setcertificatesfile(m.getCertificate())
m.n.addheader("X-Roku-Reserved-Dev-Id", "")
m.n.initclientcertificates()
if m.getCertificate() <> "common:/certs/ca-bundle.crt"
m.n.enablehostverification(false)
m.n.enablepeerverification(false)
end if
return m.n
end function
getglobalaa()["callFunctionInGlobalNamespace"] = function(dd as function, ue as object) as Void
dd(ue)
end function
imasdk.xj = function() as object
obj = m.createIMAObject("vastAd")
obj.b = []
obj.c = []
obj.d = []
obj.id = "-1"
obj.wb = ""
obj.xb = ""
obj.yb = ""
return obj
end function
sb = {}
sb.f = function(creativeid as string) as object
for each g in m.b
if g.id = creativeid then
return g
end if
end for
return invalid
end function
sb.h = function() as object
return m.b
end function
sb.push = function(g as object) as Void
m.b.push(g)
end function
imasdk["vastAd"] = sb
imasdk.qb = function() as object
obj = m.createIMAObject("VastParser")
return obj
end function
pb = {}
pb.parse = function(aj as object) as object
ads = m.sdk.pc()
yj = m.sdk.zi(aj)
if yj = invalid
return ads
end if
if yj.getnamedelementsci("ad") <> invalid then
for each zj in yj.getnamedelementsci("ad")
e = m.ak(zj)
ads.push(e)
end for
end if
return ads
end function
pb.ak = function(yj as object) as object
e = m.sdk.xj()
if yj.hasattribute("id") then
e.id = yj.getattributes().id
end if
for each zj in yj.getnamedelementsci("inline")
m.bk(zj, e)
end for
return e
end function
pb.bk = function(yj as object, e as object) as Void
m.ck(yj, e, "ad")
end function
pb.dk = function(yj as object, e as object) as Void
e.c.push(m.ek(yj))
end function
pb.fk = function(yj as object, e as object) as Void
e.wb = m.ek(yj)
end function
pb.gk = function(yj as object, e as object) as Void
e.xb = m.ek(yj)
end function
pb.hk = function(yj as object, e as object) as Void
e.yb = m.ek(yj)
end function
pb.ik = function(yj as object, e as object) as Void
e.d.push(m.ek(yj))
end function
pb.jk = function(yj as object, e as object) as Void
for each zj in yj.getnamedelementsci("creative")
m.kk(zj, e)
end for
end function
pb.kk = function(yj as object, e as object) as Void
g = m.sdk.tc()
if yj.hasattribute("id")
g.id = yj.getattributes().id
end if
if yj.hasattribute("apiFramework")
g.vc = yj.getattributes()["apiFramework"]
end if
e.b.push(g)
for each zj in yj.getnamedelementsci("linear")
m.lk(zj, g)
end for
for each zj in yj.getnamedelementsci("companionads")
m.mk(zj, g)
end for
end function
pb.mk = function(yj as object, g as object) as Void
g.uc = false
for each zj in yj.getnamedelementsci("companion")
m.nk(zj, g)
end for
end function
pb.lk = function(yj as object, g as object) as Void
g.uc = true
m.ck(yj, g, "creative")
end function
pb.ok = function(yj as object, g as object) as Void
g.duration = m.sdk.uj(m.ek(yj))
end function
pb.pk = function(yj as object, qk as object) as Void
if not yj.hasattribute("event")
return
end if
event = yj.getattributes()["event"]
if event = invalid
m.sdk.log("Tracking element without event id.")
return
end if
if qk.vb[event] = invalid
qk.vb[event] = []
end if
qk.vb[event].push(m.ek(yj))
end function
pb.rk = function(yj as object, obj as object) as Void
for each zj in yj.getnamedelementsci("tracking")
m.pk(zj, obj)
end for
end function
pb.sk = function(yj as object, g as object) as Void
for each zj in yj.getnamedelementsci("mediafile")
m.tk(zj, g)
end for
end function
pb.tk = function(yj as object, g as object) as Void
uk = {}
uk.append(yj.getattributes())
uk.url = m.ek(yj)
g.wc.push(uk)
end function
pb.nk = function(yj as object, g as object) as Void
vk = m.sdk.rc()
if yj.hasattribute("width")
width = strtoi(yj.getattributes()["width"])
if width <> invalid
vk.width = width
end if
end if
if yj.hasattribute("height")
height = strtoi(yj.getattributes()["height"])
if height <> invalid
vk.height = height
end if
end if
m.ck(yj, vk, "companion")
g.xc.push(vk)
end function
pb.wk = function(yj as object, obj as object) as Void
if yj.hasattribute("creativeType")
obj.sc = yj.getattributes()["creativeType"]
end if
obj.url = m.ek(yj)
end function
pb.ck = function(yj as object, qk as object, xk as string) as Void
if yj.getchildelements() = invalid then
return
end if
for each zj in yj.getchildelements()
yk = lcase(zj.getname())
if lcase(xk) = "ad"
if yk = "impression"
m.dk(zj, qk)
else if yk = "error"
m.ik(zj, qk)
else if yk = "creatives"
m.jk(zj, qk)
else if yk = "adtitle"
m.fk(zj, qk)
else if yk = "description"
m.gk(zj, qk)
else if yk = "adsystem"
m.hk(zj, qk)
end if
else if lcase(xk) = "creative"
if yk = "duration"
m.ok(zj, qk)
else if yk = "trackingevents"
m.rk(zj, qk)
else if yk = "mediafiles"
m.sk(zj, qk)
else if yk = "mediafiles"
m.sk(zj, qk)
end if
else if lcase(xk) = "companion"
if yk = "staticresource"
m.wk(zj, qk)
else if yk = "trackingevents"
m.rk(zj, qk)
end if
end if
end for
end function
pb.ek = function(yj as object)
if yj = invalid
return ""
end if
if yj.gettext() = invalid
return ""
end if
return yj.gettext().trim()
end function
imasdk["vastParser"] = pb
imasdk.ii = function() as object
obj = m.createIMAObject("vastToRafConverter")
return obj
end function
zk = {}
zk.ji = function(sb as object) as boolean
if sb.b.count() <> 2
return false
end if
al = m.al(sb)
bl = m.bl(sb)
if al = invalid or bl = invalid
return false
end if
if bl.vc = ""
return false
end if
return true
end function
zk.cl = function(sb as object, ng as integer) as object
adpods = []
dl = m.li(sb, ng)
adpods.push(dl)
return adpods
end function
zk.al = function(sb as object) as object
for each g in sb.b
if g.xc.count() = 0
return g
end if
end for
return invalid
end function
zk.bl = function(sb as object) as object
for each g in sb.b
if g.vc <> "" and g.xc.count() = 1
return g
end if
end for
return invalid
end function
zk.li = function(sb as object, ng as integer) as object
dl = {}
if sb.b.count() = 0
return dl
end if
al = m.al(sb)
dl["viewed"] = false
dl["renderSequence"] = "midroll"
dl["duration"] = al.duration
dl["renderTime"] = ng
dl["backfilled"] = false
dl["ads"] = []
dl["ads"].push(m.el(sb))
return dl
end function
zk.el = function(sb as object) as object
e = {}
al = m.al(sb)
bl = m.bl(sb)
fl = {}
gl = bl.xc[0]
fl["url"] = gl.url
fl["mimetype"] = gl.sc
e["duration"] = al.duration
e["streamFormat"] = bl.vc
e["adServer"] = sb.yb
e["adId"] = sb.id
e["adTitle"] = sb.wb
e["creativeId"] = al.id
e["streams"] = []
e["streams"].push(fl)
e["tracking"] = []
e["companionAds"] = []
e["companionAds"].push(m.hl(bl))
return e
end function
zk.hl = function(bl as object) as object
vk = {}
gl = bl.xc[0]
vk["url"] = gl.url
vk["width"] = gl.width
vk["height"] = gl.height
vk["mimeType"] = gl.sc
vk["tracking"] = m.il(gl.vb)
return vk
end function
zk.il = function(vb as object) as object
hh = []
for each kc in vb
for each url in vb[kc]
event = {}
event["event"] = kc
event["url"] = url
event["triggered"] = false
hh.push(event)
end for
end for
return hh
end function
imasdk["vastToRafConverter"] = zk

return imasdk
end function
