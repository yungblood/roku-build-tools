function cscomscore()as object
if m.cs_vb=invalid then m.cs_vb=cs_vc()
return m.cs_vb
end function
function cs_vc()as object
cs_vfz=createobject("roAssociativeArray")
cs_vfz.log_debug=false
cs_vfz.cs_ve=30*60*1000
cs_vfz.cs_vf=1000*60*60*24
cs_vfz.cs_vg=1000*10
cs_vfz.census_url="http://b.scorecardresearch.com/p2?"
cs_vfz.census_url_secure="https://sb.scorecardresearch.com/p2?"
cs_vfz.cs_vh="2.1408.19"
cs_vfz.p_storage=invalid
cs_vfz.cs_vi=createobject("roTimespan")
cs_vfz.cs_vj=createobject("roTimespan")
cs_vfz.cs_vk=createobject("roTimespan")
cs_vfz.cs_vcm=0
cs_vfz.cs_vcn=0
cs_vfz.cs_vx=false
cs_vfz.p_keepalive=invalid
cs_vfz.cs_vbl=false
cs_vfz.cs_vbn=createobject("roAssociativeArray")
cs_vfz.p_pixelurl=""
cs_vfz.cs_vbu=""
cs_vfz.cs_vbs=""
cs_vfz.cs_vcf=-1
cs_vfz.cs_vcj=-1
cs_vfz.p_genesis=-1
cs_vfz.cs_vfe=0
cs_vfz.start=function(labels=invalid as object)as void
m.cs_vbt(cseventtype().start,"",labels)
end function
cs_vfz.hidden=function(labels=invalid as object)as void
m.cs_vbt(cseventtype().hidden,"",labels)
end function
cs_vfz.view=function(labels=invalid as object)as void
m.cs_vbt(cseventtype().view,"",labels)
end function
cs_vfz.close=function()as void
m.cs_vbt(cseventtype().close,"",invalid)
end function
cs_vfz.setpublishersecret=function(salt as string)as void
m.cs_vbu=salt
end function
cs_vfz.publishersecret=function()as string
return m.cs_vbu
end function
cs_vfz.cs_vw=function(cs_vy as boolean)as void
m.cs_vx=cs_vy
end function
cs_vfz.cs_vy=function()as boolean
return m.cs_vx
end function
cs_vfz.cs_vz=function()as object
return m.p_keepalive
end function
cs_vfz.tick=function()as void
m.p_keepalive.tick()
if m.cs_vi.totalmilliseconds()>m.cs_vg then
m.p_storage.cs_vgd("accumulatedForegroundTime",comscore_tostr(m.cs_vj.totalmilliseconds()))
m.p_storage.cs_vgd("totalForegroundTime",comscore_tostr(m.cs_vk.totalmilliseconds()))
m.cs_vi.mark()
end if
end function
cs_vfz.cs_vba=function()as void
m.p_keepalive.cs_vee()
end function
cs_vfz.cs_vbb=function()as void
m.cs_vj.mark()
end function
cs_vfz.setpixelurl=function(cs_vbo as string)as string
if instr(1,cs_vbo,"?")>0 and right(cs_vbo,1)<>"?" then
cs_vbc=createobject("roAssociativeArray")
cs_vbg=""
labels=right(cs_vbo,len(cs_vbo)-instr(1,cs_vbo,"?")).tokenize("&")
for each label in labels
cs_vbe=label.tokenize("=")
if cs_vbe.count()=2 then
if cs_vbe[0]= "name" then
cs_vbg=cs_vbe[1]
else
cs_vbc[cs_vbe[0]]=cs_vbe[1]
end if
else if cs_vbe.count()=1 then
cs_vbg=comscore_url_encode(cs_vbe[0])
end if
end for
for each label in cs_vbc
m.cs_vbn[label]=cs_vbc[label]
end for
cs_vbo=left(cs_vbo,instr(1,cs_vbo,"?"))+cs_vbg
end if
if instr(1,cs_vbo,"?")=0 and instr(1,cs_vbo,"//")=0 then
if len(m.p_pixelurl)>0 and instr(1,m.p_pixelurl,"?")>0 then
cs_vbo=left(m.p_pixelurl,instr(1,m.p_pixelurl,"?"))+comscore_url_encode(cs_vbo)
else
cs_vbo=cs_vbo+"?"
end if
end if
if right(cs_vbo,1)= "?" then
cs_vbo=cs_vbo+"Application"
end if
m.p_pixelurl=cs_vbo
return m.p_pixelurl
end function
cs_vfz.pixelurl=function()as string
return m.p_pixelurl
end function
cs_vfz.setsecure=function(secure as boolean)
m.cs_vbl=secure
end function
cs_vfz.secure=function()as boolean
return m.cs_vbl
end function
cs_vfz.setcustomerc2=function(c2 as string)as void
m.cs_vbn["c2"]=comscore_url_encode(c2)
if m.secure()then
m.setpixelurl(m.census_url_secure)
else
m.setpixelurl(m.census_url)
end if
end function
cs_vfz.customerc2=function()as string
return m.cs_vbn["c2"]
end function
cs_vfz.getlabels=function()as object
return m.cs_vbn
end function
cs_vfz.setlabels=function(labelmap as object)as void
if labelmap<>invalid then
if m.cs_vbn=invalid then
m.cs_vbn=labelmap
else
m.cs_vbn.append(labelmap)
end if
end if
end function
cs_vfz.getlabel=function(name as string)as string
return m.cs_vbn[name]
end function
cs_vfz.setlabel=function(key as string,cs_vbo as string)as void
if cs_vbo=invalid then
m.cs_vbn.delete(key)
else
m.cs_vbn[key]=cs_vbo
end if
end function
cs_vfz.setappname=function(name as string)as void
m.cs_vdo=name
end function
cs_vfz.appname=function()as string
return m.cs_vdo
end function
cs_vfz.appversion=function()as string
return m.cs_vdp
end function
cs_vfz.visitorid=function()as string
if m.cs_vbs="" then
di=createobject("roDeviceInfo")
m.cs_vbs=m.cs_vby(di.getdeviceuniqueid())
end if
return m.cs_vbs
end function
cs_vfz.version=function()as string
return m.cs_vh
end function
cs_vfz.cs_vbt=function(cs_vfi as string,pixelurl="" as string,labels=invalid as object)as void
if m.cs_vbu="" or m.cs_vbn["c2"]=invalid then return
if pixelurl="" then
pixelurl=m.pixelurl()
else
pixelurl=m.setpixelurl(pixelurl)
end if
if labels=invalid then labels=createobject("roAssociativeArray")
if cs_vfi<>"close" then
cs_vft=cs_vel(m,cs_vfi,pixelurl,labels)
m.dispatch(cs_vft)
end if
m.p_storage.cs_vgd("lastActivityTime",str(comscore_unix_time()))
end function
cs_vfz.dispatch=function(cs_vft as object)as void
m.cs_vfe=m.cs_vfe+1
cs_vft.labels["ns_ap_ec"]=comscore_tostr(m.cs_vfe)
cs_vbx=cs_vfr(cs_vft)
cs_vbx.cs_vfu()
end function
cs_vfz.cs_vby=function(cs_vdh as string)as string
cs_vdh=cs_vdh+m.cs_vbu
cs_vca=createobject("roByteArray")
cs_vca.fromasciistring(cs_vdh)
cs_vcb=createobject("roEVPDigest")
cs_vcb.setup("md5")
cs_vcb.update(cs_vca)
return cs_vcb.final()
end function
cs_vfz.cs_vcc=function()as double
if m.cs_vcf<0 then
if m.p_storage.cs_vgc("installTime")then
cs_vce=comscore_stod(m.p_storage.cs_vgb("installTime"))
else
cs_vce=m.p_genesis
m.p_storage.cs_vgd("installTime",str(cs_vce))
end if
m.cs_vcf=cs_vce
end if
return m.cs_vcf
end function
cs_vfz.cs_vcg=function()as double
if m.cs_vcj<0 then
cs_vci=0
if m.p_storage.cs_vgc("installTime")then
cs_vci=comscore_stod(m.p_storage.cs_vgb("previousGenesis"))
end if
m.cs_vcj=cs_vci
end if
return m.cs_vcj
end function
cs_vfz.cs_vck=function()as void
cs_vcl=comscore_unix_time()
if cs_vcl-m.p_genesis>m.cs_ve then
m.p_storage.cs_vgd("previousGenesis",str(m.p_genesis))
m.p_genesis=cs_vcl
m.p_storage.cs_vgd("genesis",str(m.p_genesis))
end if
end function
cs_vdb(cs_vfz)
cs_vfz.p_storage=cs_vfy(cs_vfz)
cs_vfz.p_genesis=comscore_unix_time()
cs_vco(cs_vfz)
cs_vfz.p_keepalive=cs_vdx(cs_vfz)
cs_vfz.cs_vcc()
cs_vcu(cs_vfz)
cs_vdq(cs_vfz)
if cs_vfz.p_storage.cs_vgc("accumulatedForegroundTime")then
cs_vfz.cs_vcm=comscore_stoi(cs_vfz.p_storage.cs_vgb("accumulatedForegroundTime"))
end if
if cs_vfz.p_storage.cs_vgc("totalForegroundTime")then
cs_vfz.cs_vcn=comscore_stoi(cs_vfz.p_storage.cs_vgb("totalForegroundTime"))
end if
cs_vfz.cs_vj.mark()
cs_vfz.cs_vk.mark()
cs_vfz.cs_vi.mark()
return cs_vfz
end function
function cs_vco(dax as object)as void
cs_vcp=readasciifile("pkg:/source/comScore.properties")
if len(cs_vcp)=0 then return
cs_vcq={}
cs_vdh=cs_vcp.tokenize(chr(10))
for each cs_vdi in cs_vdh
cs_vdi=cs_vdi.trim()
if len(cs_vdi)>0 and left(cs_vdi,1)<>"#" then
cs_vdj=cs_vdi.tokenize("=")
if cs_vdj.count()=2 then
cs_vcq[lcase(cs_vdj[0].trim())]=cs_vdj[1].trim()
end if
end if
end for
if cs_vcq["secure"]<>invalid and(lcase(cs_vcq["secure"])= "yes" or lcase(cs_vcq["Secure"])= "true")then
dax.setsecure(true)
else
dax.setsecure(false)
end if
if cs_vcq["publishersecret"]<>invalid then
dax.setpublishersecret(cs_vcq["publishersecret"])
end if
if cs_vcq["appname"]<>invalid then
dax.setappname(cs_vcq["appname"])
end if
if cs_vcq["customerc2"]<>invalid then
dax.setcustomerc2(cs_vcq["customerc2"])
end if
if cs_vcq["pixelurl"]<>invalid then
dax.setpixelurl(cs_vcq["pixelurl"])
end if
if cs_vcq["keepaliveenabled"]<>invalid then
if(lcase(cs_vcq["keepaliveenabled"])= "yes" or lcase(cs_vcq["keepaliveenabled"])= "true")then
dax.cs_vw(true)
else if(lcase(cs_vcq["keepaliveenabled"])= "no" or lcase(cs_vcq["keepaliveenabled"])= "false")then
dax.cs_vw(false)
end if
else
dax.cs_vw(true)
end if
end function
sub cs_vcu(dax as object)
cs_vcv=dax.p_storage
cs_vcx=0
if cs_vcv.cs_vgc("lastActivityTime")then cs_vcx=comscore_stod(cs_vcv.cs_vgb("lastActivityTime"))
cs_vcz=0
if cs_vcv.cs_vgc("genesis")then cs_vcz=comscore_stod(cs_vcv.cs_vgb("genesis"))
if(cs_vcx>0)then
cs_vda=comscore_unix_time()-cs_vcx
if cs_vda<dax.cs_ve then
if cs_vcz>0 and cs_vcz<comscore_unix_time()then
dax.p_genesis=cs_vcz
end if
else
cs_vcv.cs_vgd("previousGenesis",str(cs_vcz))
end if
end if
cs_vcv.cs_vgd("genesis",str(dax.p_genesis))
cs_vcv.cs_vgd("lastActivityTime",str(comscore_unix_time()))
end sub
sub cs_vdb(dax as object)
cs_vdc=readasciifile("pkg:/manifest")
cs_vdk="AppName"
cs_vdl="1"
cs_vdm="0"
cs_vdn="0"
cs_vdh=cs_vdc.tokenize(chr(10))
for each cs_vdi in cs_vdh
cs_vdi=cs_vdi.trim()
if len(cs_vdi)>0 then
cs_vdj=cs_vdi.tokenize("=")
if cs_vdj.count()=2 then
if cs_vdj[0]= "title" then
cs_vdk=cs_vdj[1]
else if cs_vdj[0]= "major_version" then
cs_vdl=cs_vdj[1]
else if cs_vdj[0]= "minor_version" then
cs_vdm=cs_vdj[1]
else if cs_vdj[0]= "build_version" then
cs_vdn=cs_vdj[1]
end if
end if
end if
end for
dax.cs_vdo=cs_vdk
dax.cs_vdp=cs_vdl+"." +cs_vdm+"." +cs_vdn
end sub
sub cs_vdq(dax as object)
cs_vdr=dax.p_storage
if(cs_vdr.cs_vgc("runs"))then
cs_vds=comscore_tostr(comscore_stoi(cs_vdr.cs_vgb("runs"))+1)
cs_vdr.cs_vgd("runs",cs_vds)
else
cs_vdr.cs_vgd("runs","0")
end if
end sub
function cseventtype()
if m.cs_vdu=invalid then m.cs_vdu=cs_vdv()
return m.cs_vdu
end function
function cs_vdv()as object
cs_vdw=createobject("roAssociativeArray")
cs_vdw.view="view"
cs_vdw.hidden="hidden"
cs_vdw.start="start"
cs_vdw.aggregate="aggregate"
cs_vdw.close="close"
cs_vdw.keep_alive="keep-alive"
return cs_vdw
end function
function cs_vdx(dax as object)as object
cs_vfz=createobject("roAssociativeArray")
cs_vfz.cs_vdz=createobject("roTimespan")
cs_vfz.cs_vea=createobject("roDeviceInfo")
cs_vfz.cs_veb=createobject("roArray",1,true)
cs_vfz.cs_vec=dax
cs_ved=cs_vfz.cs_vea.getipaddrs()
if cs_ved<>invalid then
for each key in cs_ved
cs_vfz.cs_veb.push(cs_ved[key])
end for
end if
cs_vfz.cs_vee=function()as void
m.cs_vdz.mark()
end function
cs_vfz.tick=function()as void
if m.cs_vec.cs_vy()then
if m.cs_vdz.totalmilliseconds()>m.cs_vec.cs_vf then
m.cs_vec.cs_vbt(cseventtype().keep_alive)
m.cs_vdz.mark()
else
cs_vek=false
cs_veg=m.cs_vea.getipaddrs()
if cs_veg<>invalid then
for each key in cs_veg
cs_vej=false
for cs_vei=0 to m.cs_veb.count()step 1
if m.cs_veb[cs_vei]=cs_veg[key]then
cs_vej=true
exit for
end if
end for
if cs_vej then
else
m.cs_veb.push(cs_veg[key])
cs_vek=true
end if
end for
if cs_vek then
m.cs_vec.cs_vbt(cseventtype().keep_alive)
m.cs_vdz.mark()
end if
end if
end if
end if
end function
if dax.cs_vy()then
cs_vfz.cs_vdz.mark()
else
end if
return cs_vfz
end function
function cs_vel(dax as object,cs_vfi as string,pixelurl as string,labels as object)as object
dax.cs_vck()
if cs_vfi=cseventtype().start then return cs_vfn(dax,cs_vfi,pixelurl,labels)
if cs_vfi=cseventtype().aggregate then return cs_vfp(dax,cs_vfi,pixelurl,labels)
return csapplicationmeasurement(dax,cs_vfi,pixelurl,labels)
end function
function csmeasurement(dax as object)as object
cs_vfz=createobject("roAssociativeArray")
cs_vfz.labels=createobject("roAssociativeArray")
cs_vfz.setpixelurl=function(pixelurl as string)as void
cs_vep=instr(1,pixelurl,"?")
if cs_vep>=1 and len(pixelurl)>cs_vep then
m.labels["name"]=right(pixelurl,len(pixelurl)-cs_vep)
m.pixelurl=left(pixelurl,cs_vep)
else
m.pixelurl=pixelurl
end if
end function
cs_vfz.setpixelurl(dax.pixelurl())
cs_vfz.cs_veq=comscore_unix_time()
cs_vfz.cs_ver=function()as string
cs_vex=""
cs_veu=createobject("roArray",110,true)
cs_veu=["c1","c2","ns_site","ns_vsite",
"ns_ap_an","ns_ap_pv","ns_ap_pn","c12","name","ns_ak","ns_ap_i1","ns_ap_i6","ns_ap_ec","ns_ap_ev","ns_ap_device",
"ns_ap_id","ns_ap_csf","ns_ap_bi","ns_ap_pfm","ns_ap_pfv","ns_ap_ver","ns_ap_sv",
"ns_type","ns_radio","ns_nc","ns_ap_ui","ns_ap_gs",
"ns_st_sv","ns_st_pv","ns_st_it","ns_st_id","ns_st_ec","ns_st_sp","ns_st_sq","ns_st_cn",
"ns_st_ev","ns_st_po","ns_st_cl","ns_st_el","ns_st_pb","ns_st_hc","ns_st_mp","ns_st_mv","ns_st_pn",
"ns_st_tp","ns_st_pt","ns_st_pa","ns_st_ad","ns_st_li","ns_st_ci",
"ns_ap_jb","ns_ap_res","ns_ap_c12m","ns_ap_install","ns_ap_updated","ns_ap_lastrun",
"ns_ap_cs","ns_ap_runs","ns_ap_usage","ns_ap_fg","ns_ap_ft","ns_ap_dft","ns_ap_bt","ns_ap_dbt",
"ns_ap_dit","ns_ap_as","ns_ap_das","ns_ap_it","ns_ap_uc","ns_ap_aus","ns_ap_daus","ns_ap_us",
"ns_ap_dus","ns_ap_ut","ns_ap_oc","ns_ap_uxc","ns_ap_uxs","ns_ap_lang","ns_ap_miss","ns_ts",
"ns_st_ca","ns_st_cp","ns_st_er","ns_st_pe","ns_st_ui","ns_st_bc","ns_st_bt",
"ns_st_bp","ns_st_pc","ns_st_pp","ns_st_br","ns_st_ub","ns_st_vo","ns_st_ws","ns_st_pl","ns_st_pr",
"ns_st_ep","ns_st_ty","ns_st_cs","ns_st_ge","ns_st_st","ns_st_dt","ns_st_ct","ns_st_de","ns_st_pu",
"ns_st_cu","ns_st_fee","c7","c9","ns_ap_i3"]
cs_vev={}
for each label in cs_veu
if m.labels[label]<>invalid then
cs_vex=cs_vex+"&" +comscore_url_encode(label)+ "=" +comscore_url_encode(m.labels[label])
cs_vev.addreplace(label,true)
end if
end for
for each key in m.labels
if m.labels[key]<>invalid and cs_vev[key]=invalid then
cs_vex=cs_vex+"&" +comscore_url_encode(key)+ "=" +comscore_url_encode(m.labels[key])
end if
end for
if len(cs_vex)>0 then
return right(cs_vex,len(cs_vex)-1)
else
return cs_vex
end if
end function
return cs_vfz
end function
function cs_vey(dax as object,cs_vfi as string,pixelurl as string,labels as object)as object
cs_vfz=csmeasurement(dax)
di=createobject("roDeviceInfo")
if pixelurl<>invalid and pixelurl<>"" then cs_vfz.setpixelurl(pixelurl)
cs_vfz.labels["c1"]= "19"
cs_vfz.labels["ns_ap_an"]=dax.appname()
cs_vfz.labels["ns_ap_pn"]= "roku"
cs_vfz.labels["c12"]=dax.visitorid()
cs_vfb=createobject("roByteArray")
cs_vfb.fromasciistring(di.getdeviceuniqueid())
cs_vfc=createobject("roEVPDigest")
cs_vfc.setup("md5")
cs_vfc.update(cs_vfb)
cs_vfz.labels["ns_ap_i1"]=cs_vfc.final()
cs_vfd=createobject("roEVPDigest")
cs_vfd.setup("sha1")
cs_vfd.update(cs_vfb)
cs_vfz.labels["ns_ap_i6"]=cs_vfd.final()
cs_vfz.labels["ns_ap_device"]=di.getmodel()
cs_vfz.labels["ns_ap_as"]=comscore_tostr(dax.p_genesis)
cs_vfz.labels["ns_type"]=cs_vfi
cs_vfz.labels["ns_ap_ev"]=cs_vfi
cs_vfz.labels["ns_ts"]=comscore_tostr(cs_vfz.cs_veq)
cs_vfz.labels["ns_ap_pfv"]=di.getversion()
cs_vfz.labels["ns_nc"]= "1"
if dax.cs_vfe=0 then
if dax.cs_vcn>0 then
cs_vfz.labels["ns_ap_dft"]=comscore_tostr(dax.cs_vcm)
cs_vfz.labels["ns_ap_ft"]=comscore_tostr(dax.cs_vcn)
end if
else
cs_vfz.labels["ns_ap_dft"]=comscore_tostr(dax.cs_vj.totalmilliseconds())
cs_vfz.labels["ns_ap_ft"]=comscore_tostr(dax.cs_vk.totalmilliseconds())
end if
cs_vff=dax.getlabels()
for each key in cs_vff
cs_vfz.labels[key]=cs_vff[key]
end for
for each key in labels
cs_vfz.labels[key]=labels[key]
end for
return cs_vfz
end function
function csapplicationmeasurement(dax as object,cs_vfi as string,pixelurl as string,labels as object)as object
cs_vfj=cseventtype().hidden
if cs_vfi=cseventtype().start or cs_vfi=cseventtype().view then cs_vfj=cseventtype().view
cs_vfz=cs_vey(dax,cs_vfj,pixelurl,labels)
cs_vfz.labels["ns_ap_ev"]=cs_vfi
cs_vfz.labels["ns_ap_ver"]=dax.appversion()
di=createobject("roDeviceInfo")
if comscore_is26()then
cs_vfm=di.getdisplaysize()
cs_vfz.labels["ns_ap_res"]=stri(cs_vfm.w).trim()+ "x" +stri(cs_vfm.h).trim()
end if
if comscore_is43()then cs_vfz.labels["ns_ap_lang"]=di.getcurrentlocale()
cs_vfz.labels["ns_ap_sv"]=dax.version()
for each key in labels
cs_vfz.labels[key]=labels[key]
end for
return cs_vfz
end function
function cs_vfn(dax as object,cs_vfi as string,pixelurl as string,labels as object)as object
cs_vfz=csapplicationmeasurement(dax,cs_vfi,pixelurl,labels)
cs_vfz.labels["ns_ap_install"]= "yes"
cs_vfz.labels["ns_ap_runs"]=dax.p_storage.cs_vgb("runs")
cs_vfz.labels["ns_ap_gs"]=comscore_tostr(dax.cs_vcc())
cs_vfz.labels["ns_ap_lastrun"]=comscore_tostr(dax.cs_vcg())
for each key in labels
cs_vfz.labels[key]=labels[key]
end for
return cs_vfz
end function
function cs_vfp(dax as object,cs_vfi as string,pixelurl as string,labels as object)as object
cs_vfz=csapplicationmeasurement(dax,cs_vfi,pixelurl,labels)
return cs_vfz
end function
function cs_vfr(cs_vft as object)as object
cs_vfz=createobject("roAssociativeArray")
cs_vfz.cs_vft=cs_vft
cs_vfz.cs_vfu=function()as object
cs_vfv=createobject("roUrlTransfer")
m.cs_vfw=createobject("roMessagePort")
cs_vfv.setport(m.cs_vfw)
cs_vfv.setcertificatesfile("common:/certs/ca-bundle.crt")
cs_vfv.enableencodings(true)
cs_vfv.addheader("Expect","")
cs_vfx=m.cs_vft.pixelurl+m.cs_vft.cs_ver()
if cscomscore().log_debug then print"Dispatching: " +cs_vfx
cs_vfv.seturl(cs_vfx)
cs_vfv.setrequest("GET")
m.dispatch(cs_vfv)
cscomscore().cs_vba()
cscomscore().cs_vbb()
end function
cs_vfz.dispatch=function(cs_vfv as object)
if(cs_vfv.asyncgettostring())then wait(500,cs_vfv.getport())
end function
return cs_vfz
end function
function cs_vfy(dax as object)as object
cs_vfz=createobject("roAssociativeArray")
cs_vfz.cs_vga=createobject("roRegistrySection","com.comscore." +dax.appname()+ "-2")
cs_vfz.cs_vgb=function(key)as string
if m.cs_vga.exists(key)then return m.cs_vga.read(key)
return""
end function
cs_vfz.cs_vgc=function(key)as boolean
return m.cs_vga.exists(key)
end function
cs_vfz.cs_vgd=function(key,val)as void
m.cs_vga.write(key,val)
m.cs_vga.flush()
end function
cs_vfz.cs_vge=function(key)as void
m.cs_vga.delete(key)
m.cs_vga.flush()
end function
return cs_vfz
end function
function comscore_is26()as boolean
if m.cs_vgj=invalid then
di=createobject("roDeviceInfo")
cs_vgm=eval("country=di.GetCountryCode()")
if cs_vgm=252
m.cs_vgj=true
else
m.cs_vgj=false
end if
end if
return m.cs_vgj
end function
function comscore_is43()as boolean
if m.cs_vgo=invalid then
di=createobject("roDeviceInfo")
cs_vgm=eval("locale=di.GetCurrentLocale()")
if cs_vgm=252
m.cs_vgo=true
else
m.cs_vgo=false
end if
end if
return m.cs_vgo
end function
function comscore_unix_time()as double
if m.cs_vgq=invalid then
m.cs_vgq=createobject("roAssociativeArray")
m.cs_vgq.cs_vgr=createobject("roTimespan")
cs_vgs=createobject("roDateTime")
cs_vgs.mark()
m.cs_vgq.offset#=cs_vgs.asseconds()*1000#
m.cs_vgq.cs_vgr.mark()
end if
m.p_csmillis#=m.cs_vgq.cs_vgr.totalmilliseconds()
return m.cs_vgq.offset#+m.p_csmillis#
end function
function comscore_tostr(obj as object)as string
cs_vhb=type(obj)
if cs_vhb="String" or cs_vhb="roString" then return obj
if cs_vhb="Integer" or cs_vhb="roInt" then return stri(obj).trim()
if cs_vhb="Double" or cs_vhb="roIntrinsicDouble" or cs_vhb="Float" or cs_vhb="roFloat" then
num#=obj
mil#=1000000
if abs(num#)<=mil#then return str(num#).trim()
cs_vhd=int(num#/mil#)
if num#/mil#-cs_vhd<0 then cs_vhd=cs_vhd-1
cs_vhe=int((num#-mil#*cs_vhd))
cs_vhf=cs_vhd.tostr()
cs_vhg=string(6-cs_vhe.tostr().len(),"0")+cs_vhe.tostr()
return cs_vhf+cs_vhg
end if
return"UNKN" +cs_vhb
end function
function comscore_stod(obj as string)as double
len=obj.len()
if len<=6 then
cs_vex#=val(obj)
return cs_vex#
end if
left=obj.left(len-6)
right=obj.right(6)
left#=val(left)
right#=val(right)
mil#=1000000
cs_vex#=left#*mil#+right#
return cs_vex#
end function
function comscore_stoi(obj as string)as integer
return int(val(obj))
end function
function comscore_url_encode(cs_vdh as string)as string
if m.cs_vhi=invalid then m.cs_vhi=createobject("roUrlTransfer")
return m.cs_vhi.urlencode(cs_vdh)
end function
