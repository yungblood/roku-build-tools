function cscomscore()as object
if m.cs_vb=invalid then m.cs_vb=cs_vc()
return m.cs_vb
end function
function cs_vc()as object
cs_vxd=createobject("roAssociativeArray")
cs_vxd.log_debug=false
cs_vxd.cs_ve=30*60*1000
cs_vxd.cs_vig=1000*60*60*24
cs_vxd.cs_vg=1000*10
cs_vxd.census_url="http://b.scorecardresearch.com/p2?"
cs_vxd.census_url_secure="https://sb.scorecardresearch.com/p2?"
cs_vxd.cs_vh="3.1503.03"
cs_vxd.p_storage=invalid
cs_vxd.cs_vi=createobject("roTimespan")
cs_vxd.cs_vj=createobject("roTimespan")
cs_vxd.cs_vk=createobject("roTimespan")
cs_vxd.cs_vcp=0
cs_vxd.cs_vcq=0
cs_vxd.cs_vz=false
cs_vxd.p_keepalive=invalid
cs_vxd.cs_vbn=false
cs_vxd.cs_vpi=createobject("roAssociativeArray")
cs_vxd.p_pixelurl=""
cs_vxd.cs_vbx=""
cs_vxd.cs_vcr=""
cs_vxd.cs_vci=-1
cs_vxd.cs_vcm=-1
cs_vxd.p_genesis=-1
cs_vxd.cs_vfu=0
cs_vxd.cs_vcu=""
cs_vxd.cs_vcw=""
cs_vxd.start=function(labels=invalid as object)as void
m.notify(cseventtype().start,"",labels)
end function
cs_vxd.hidden=function(labels=invalid as object)as void
m.notify(cseventtype().hidden,"",labels)
end function
cs_vxd.view=function(labels=invalid as object)as void
m.notify(cseventtype().view,"",labels)
end function
cs_vxd.close=function()as void
m.notify(cseventtype().close,"",invalid)
end function
cs_vxd.setpublishersecret=function(salt as string)as void
m.cs_vbx=salt
end function
cs_vxd.publishersecret=function()as string
return m.cs_vbx
end function
cs_vxd.cs_vy=function(cs_vba as boolean)as void
m.cs_vz=cs_vba
end function
cs_vxd.cs_vba=function()as boolean
return m.cs_vz
end function
cs_vxd.cs_vbb=function()as object
return m.p_keepalive
end function
cs_vxd.tick=function()as void
m.p_keepalive.tick()
if m.cs_vi.totalmilliseconds()>m.cs_vg then
m.p_storage.cs_vgt("accumulatedForegroundTime",comscore_tostr(m.cs_vj.totalmilliseconds()))
m.p_storage.cs_vgt("totalForegroundTime",comscore_tostr(m.cs_vk.totalmilliseconds()))
m.cs_vi.mark()
end if
end function
cs_vxd.cs_vbc=function()as void
m.p_keepalive.reset()
end function
cs_vxd.cs_vbd=function()as void
m.cs_vj.mark()
end function
cs_vxd.setpixelurl=function(cs_vwu as string)as string
if instr(1,cs_vwu,"?")>0 and right(cs_vwu,1)<>"?" then
cs_vbe=createobject("roAssociativeArray")
cs_vbi=""
labels=right(cs_vwu,len(cs_vwu)-instr(1,cs_vwu,"?")).tokenize("&")
for each label in labels
cs_vbg=label.tokenize("=")
if cs_vbg.count()=2 then
if cs_vbg[0]= "name" then
cs_vbi=cs_vbg[1]
else
cs_vbe[cs_vbg[0]]=cs_vbg[1]
end if
else if cs_vbg.count()=1 then
cs_vbi=comscore_url_encode(cs_vbg[0])
end if
end for
for each label in cs_vbe
m.cs_vpi[label]=cs_vbe[label]
end for
cs_vwu=left(cs_vwu,instr(1,cs_vwu,"?"))+cs_vbi
end if
if instr(1,cs_vwu,"?")=0 and instr(1,cs_vwu,"//")=0 then
if len(m.p_pixelurl)>0 and instr(1,m.p_pixelurl,"?")>0 then
cs_vwu=left(m.p_pixelurl,instr(1,m.p_pixelurl,"?"))+comscore_url_encode(cs_vwu)
else
cs_vwu=cs_vwu+"?"
end if
end if
if right(cs_vwu,1)= "?" then
cs_vwu=cs_vwu+"Application"
end if
m.p_pixelurl=cs_vwu
return m.p_pixelurl
end function
cs_vxd.pixelurl=function()as string
return m.p_pixelurl
end function
cs_vxd.setsecure=function(secure as boolean)
m.cs_vbn=secure
end function
cs_vxd.secure=function()as boolean
return m.cs_vbn
end function
cs_vxd.setcustomerc2=function(c2 as string)as void
m.cs_vpi["c2"]=comscore_url_encode(c2)
if m.secure()then
m.setpixelurl(m.census_url_secure)
else
m.setpixelurl(m.census_url)
end if
end function
cs_vxd.customerc2=function()as string
return m.cs_vpi["c2"]
end function
cs_vxd.getlabels=function()as object
return m.cs_vpi
end function
cs_vxd.setlabels=function(cs_vuu as object)as void
if cs_vuu<>invalid then
if m.cs_vpi=invalid then
m.cs_vpi=cs_vuu
else
m.cs_vpi.append(cs_vuu)
end if
end if
end function
cs_vxd.getlabel=function(name as string)as string
return m.cs_vpi[name]
end function
cs_vxd.setlabel=function(key as string,cs_vwu as string)as void
if cs_vwu=invalid then
m.cs_vpi.delete(key)
else
m.cs_vpi[key]=cs_vwu
end if
end function
cs_vxd.setappname=function(name as string)as void
m.cs_vdx=name
end function
cs_vxd.appname=function()as string
return m.cs_vdx
end function
cs_vxd.appversion=function()as string
return m.cs_vdy
end function
cs_vxd.visitorid=function()as string
if m.cs_vcr="" then
di=createobject("roDeviceInfo")
if findmemberfunction(di,"GetPublisherId")<>invalid then
m.cs_vcr=m.cs_vcb(di.getpublisherid())+ "-cs62"
else
m.cs_vcr=m.cs_vcb(di.getdeviceuniqueid())
end if
m.p_storage.cs_vgt("visitorId",m.cs_vcr)
end if
return m.cs_vcr
end function
cs_vxd.version=function()as string
return m.cs_vcu
end function
cs_vxd.previousversion=function()as string
return m.cs_vcw
end function
cs_vxd.notify=function(cs_vvb as string,pixelurl="" as string,labels=invalid as object)as void
if m.cs_vbx="" or m.cs_vpi["c2"]=invalid then return
if pixelurl="" then
pixelurl=m.pixelurl()
else
pixelurl=m.setpixelurl(pixelurl)
end if
if labels=invalid then labels=createobject("roAssociativeArray")
if cs_vvb<>"close" then
cs_vmb=cs_veu(m,cs_vvb,pixelurl,labels)
m.dispatch(cs_vmb)
end if
m.p_storage.cs_vgt("lastActivityTime",str(comscore_unix_time()))
end function
cs_vxd.dispatch=function(cs_vmb as object)as void
m.cs_vfu=m.cs_vfu+1
cs_vmb.labels["ns_ap_ec"]=comscore_tostr(m.cs_vfu)
cs_vca=cs_vgh(cs_vmb)
cs_vca.cs_vgk()
end function
cs_vxd.cs_vcb=function(cs_vfl as string)as string
cs_vfl=cs_vfl+m.cs_vbx
cs_vfm=createobject("roByteArray")
cs_vfm.fromasciistring(cs_vfl)
cs_vfn=createobject("roEVPDigest")
cs_vfn.setup("md5")
cs_vfn.update(cs_vfm)
return cs_vfn.final()
end function
cs_vxd.cs_vcf=function()as double
if m.cs_vci<0 then
if m.p_storage.cs_vgs("installTime")then
cs_vch=comscore_stod(m.p_storage.cs_vgr("installTime"))
else
cs_vch=m.p_genesis
m.p_storage.cs_vgt("installTime",str(cs_vch))
end if
m.cs_vci=cs_vch
end if
return m.cs_vci
end function
cs_vxd.cs_vcj=function()as double
if m.cs_vcm<0 then
cs_vcl=0
if m.p_storage.cs_vgs("installTime")then
cs_vcl=comscore_stod(m.p_storage.cs_vgr("previousGenesis"))
end if
m.cs_vcm=cs_vcl
end if
return m.cs_vcm
end function
cs_vxd.cs_vcn=function()as void
cs_vco=comscore_unix_time()
if cs_vco-m.p_genesis>m.cs_ve then
m.p_storage.cs_vgt("previousGenesis",str(m.p_genesis))
m.p_genesis=cs_vco
m.p_storage.cs_vgt("genesis",str(m.p_genesis))
end if
end function
cs_vdk(cs_vxd)
cs_vxd.p_storage=cs_vgo(cs_vxd)
cs_vxd.p_genesis=comscore_unix_time()
cs_vcx(cs_vxd)
cs_vxd.p_keepalive=cs_veg(cs_vxd)
cs_vxd.cs_vcf()
cs_vdd(cs_vxd)
cs_vdz(cs_vxd)
if cs_vxd.p_storage.cs_vgs("accumulatedForegroundTime")then
cs_vxd.cs_vcp=comscore_stoi(cs_vxd.p_storage.cs_vgr("accumulatedForegroundTime"))
end if
if cs_vxd.p_storage.cs_vgs("totalForegroundTime")then
cs_vxd.cs_vcq=comscore_stoi(cs_vxd.p_storage.cs_vgr("totalForegroundTime"))
end if
if cs_vxd.p_storage.cs_vgs("visitorId")then
cs_vxd.cs_vcr=cs_vxd.p_storage.cs_vgr("visitorId")
end if
if cs_vxd.p_storage.cs_vgs("currentVersion")then
if cs_vxd.p_storage.cs_vgr("currentVersion")<>cs_vxd.cs_vh then
cs_vxd.p_storage.cs_vgt("previousVersion",cs_vxd.p_storage.cs_vgr("currentVersion"))
cs_vxd.p_storage.cs_vgt("currentVersion",cs_vxd.cs_vh)
cs_vxd.cs_vcu=cs_vxd.cs_vh
else
cs_vxd.cs_vcu=cs_vxd.p_storage.cs_vgr("currentVersion")
end if
else
cs_vxd.p_storage.cs_vgt("currentVersion",cs_vxd.cs_vh)
cs_vxd.cs_vcu=cs_vxd.cs_vh
end if
if cs_vxd.p_storage.cs_vgs("previousVersion")then
cs_vxd.cs_vcw=cs_vxd.p_storage.cs_vgr("previousVersion")
else
cs_vxd.p_storage.cs_vgt("previousVersion",cs_vxd.cs_vcu)
cs_vxd.cs_vcw=cs_vxd.cs_vcu
end if
cs_vxd.cs_vj.mark()
cs_vxd.cs_vk.mark()
cs_vxd.cs_vi.mark()
return cs_vxd
end function
function cs_vcx(dax as object)as void
cs_vcy=readasciifile("pkg:/source/comScore.properties")
if len(cs_vcy)=0 then return
cs_vcz={}
cs_vfl=cs_vcy.tokenize(chr(10))
for each cs_vdr in cs_vfl
cs_vdr=cs_vdr.trim()
if len(cs_vdr)>0 and left(cs_vdr,1)<>"#" then
cs_vds=cs_vdr.tokenize("=")
if cs_vds.count()=2 then
cs_vcz[lcase(cs_vds[0].trim())]=cs_vds[1].trim()
end if
end if
end for
if cs_vcz["secure"]<>invalid and(lcase(cs_vcz["secure"])= "yes" or lcase(cs_vcz["Secure"])= "true")then
dax.setsecure(true)
else
dax.setsecure(false)
end if
if cs_vcz["publishersecret"]<>invalid then
dax.setpublishersecret(cs_vcz["publishersecret"])
end if
if cs_vcz["appname"]<>invalid then
dax.setappname(cs_vcz["appname"])
end if
if cs_vcz["customerc2"]<>invalid then
dax.setcustomerc2(cs_vcz["customerc2"])
end if
if cs_vcz["pixelurl"]<>invalid then
dax.setpixelurl(cs_vcz["pixelurl"])
end if
if cs_vcz["keepaliveenabled"]<>invalid then
if(lcase(cs_vcz["keepaliveenabled"])= "yes" or lcase(cs_vcz["keepaliveenabled"])= "true")then
dax.cs_vy(true)
else if(lcase(cs_vcz["keepaliveenabled"])= "no" or lcase(cs_vcz["keepaliveenabled"])= "false")then
dax.cs_vy(false)
end if
else
dax.cs_vy(true)
end if
end function
sub cs_vdd(dax as object)
cs_vde=dax.p_storage
cs_vdg=0
if cs_vde.cs_vgs("lastActivityTime")then cs_vdg=comscore_stod(cs_vde.cs_vgr("lastActivityTime"))
cs_vdi=0
if cs_vde.cs_vgs("genesis")then cs_vdi=comscore_stod(cs_vde.cs_vgr("genesis"))
if(cs_vdg>0)then
cs_vdj=comscore_unix_time()-cs_vdg
if cs_vdj<dax.cs_ve then
if cs_vdi>0 and cs_vdi<comscore_unix_time()then
dax.p_genesis=cs_vdi
end if
else
cs_vde.cs_vgt("previousGenesis",str(cs_vdi))
end if
end if
cs_vde.cs_vgt("genesis",str(dax.p_genesis))
cs_vde.cs_vgt("lastActivityTime",str(comscore_unix_time()))
end sub
sub cs_vdk(dax as object)
cs_vdl=readasciifile("pkg:/manifest")
title="AppName"
cs_vdu="1"
cs_vdv="0"
cs_vdw="0"
cs_vfl=cs_vdl.tokenize(chr(10))
for each cs_vdr in cs_vfl
cs_vdr=cs_vdr.trim()
if len(cs_vdr)>0 then
cs_vds=cs_vdr.tokenize("=")
if cs_vds.count()=2 then
if cs_vds[0]= "title" then
title=cs_vds[1]
else if cs_vds[0]= "major_version" then
cs_vdu=cs_vds[1]
else if cs_vds[0]= "minor_version" then
cs_vdv=cs_vds[1]
else if cs_vds[0]= "build_version" then
cs_vdw=cs_vds[1]
end if
end if
end if
end for
dax.cs_vdx=title
dax.cs_vdy=cs_vdu+"." +cs_vdv+"." +cs_vdw
end sub
sub cs_vdz(dax as object)
cs_vea=dax.p_storage
if(cs_vea.cs_vgs("runs"))then
cs_veb=comscore_tostr(comscore_stoi(cs_vea.cs_vgr("runs"))+1)
cs_vea.cs_vgt("runs",cs_veb)
else
cs_vea.cs_vgt("runs","0")
end if
end sub
function cseventtype()
if m.cs_ved=invalid then m.cs_ved=cs_vee()
return m.cs_ved
end function
function cs_vee()as object
cs_vtt=createobject("roAssociativeArray")
cs_vtt.view="view"
cs_vtt.hidden="hidden"
cs_vtt.start="start"
cs_vtt.aggregate="aggregate"
cs_vtt.close="close"
cs_vtt.keep_alive="keep-alive"
return cs_vtt
end function
function cs_veg(dax as object)as object
cs_vxd=createobject("roAssociativeArray")
cs_vxd.cs_vei=createobject("roTimespan")
cs_vxd.cs_vej=createobject("roDeviceInfo")
cs_vxd.cs_vek=createobject("roArray",1,true)
cs_vxd.cs_vph=dax
cs_vem=cs_vxd.cs_vej.getipaddrs()
if cs_vem<>invalid then
for each key in cs_vem
cs_vxd.cs_vek.push(cs_vem[key])
end for
end if
cs_vxd.reset=function()as void
m.cs_vei.mark()
end function
cs_vxd.tick=function()as void
if m.cs_vph.cs_vba()then
if m.cs_vei.totalmilliseconds()>m.cs_vph.cs_vig then
m.cs_vph.notify(cseventtype().keep_alive)
m.cs_vei.mark()
else
cs_vet=false
cs_vep=m.cs_vej.getipaddrs()
if cs_vep<>invalid then
for each key in cs_vep
cs_ves=false
for cs_ver=0 to m.cs_vek.count()step 1
if m.cs_vek[cs_ver]=cs_vep[key]then
cs_ves=true
exit for
end if
end for
if cs_ves then
else
m.cs_vek.push(cs_vep[key])
cs_vet=true
end if
end for
if cs_vet then
m.cs_vph.notify(cseventtype().keep_alive)
m.cs_vei.mark()
end if
end if
end if
end if
end function
if dax.cs_vba()then
cs_vxd.cs_vei.mark()
else
end if
return cs_vxd
end function
function cs_veu(dax as object,cs_vvb as string,pixelurl as string,labels as object)as object
dax.cs_vcn()
if cs_vvb=cseventtype().start then return cs_vgd(dax,cs_vvb,pixelurl,labels)
if cs_vvb=cseventtype().aggregate then return cs_vgf(dax,cs_vvb,pixelurl,labels)
return csapplicationmeasurement(dax,cs_vvb,pixelurl,labels)
end function
function csmeasurement(dax as object)as object
cs_vxd=createobject("roAssociativeArray")
cs_vxd.labels=createobject("roAssociativeArray")
cs_vxd.setpixelurl=function(pixelurl as string)as void
cs_vey=instr(1,pixelurl,"?")
if cs_vey>=1 and len(pixelurl)>cs_vey then
m.labels["name"]=right(pixelurl,len(pixelurl)-cs_vey)
m.pixelurl=left(pixelurl,cs_vey)
else
m.pixelurl=pixelurl
end if
end function
cs_vxd.setpixelurl(dax.pixelurl())
cs_vxd.cs_vez=comscore_unix_time()
cs_vxd.cs_vfa=function()as string
cs_vjo=""
cs_vfd=createobject("roArray",110,true)
cs_vfd=["c1","c2","ca2","cb2","cc2","cd2","ns_site","ca_ns_site","cb_ns_site","cc_ns_site","cd_ns_site","ns_vsite","ca_ns_vsite","cb_ns_vsite","cc_ns_vsite","cd_ns_vsite","ns_ap_an","ca_ns_ap_an","cb_ns_ap_an","cc_ns_ap_an","cd_ns_ap_an","ns_ap_pn","ns_ap_pv","c12","ca12","cb12","cc12","cd12","ns_ak","ns_ap_hw","name","ns_ap_ni","ns_ap_ec","ns_ap_ev","ns_ap_device","ns_ap_id","ns_ap_csf","ns_ap_bi","ns_ap_pfm","ns_ap_pfv","ns_ap_ver","ca_ns_ap_ver","cb_ns_ap_ver","cc_ns_ap_ver","cd_ns_ap_ver","ns_ap_sv","ns_ap_cv","ns_type","ca_ns_type","cb_ns_type","cc_ns_type","cd_ns_type","ns_radio","ns_nc","ns_ap_ui","ca_ns_ap_ui","cb_ns_ap_ui","cc_ns_ap_ui","cd_ns_ap_ui","ns_ap_gs","ns_st_sv","ns_st_pv","ns_st_it","ns_st_id","ns_st_ec","ns_st_sp","ns_st_sq","ns_st_cn","ns_st_ev","ns_st_po","ns_st_cl","ns_st_el","ns_st_pb","ns_st_hc","ns_st_mp","ca_ns_st_mp","cb_ns_st_mp","cc_ns_st_mp","cd_ns_st_mp","ns_st_mv","ca_ns_st_mv","cb_ns_st_mv","cc_ns_st_mv","cd_ns_st_mv","ns_st_pn","ns_st_tp","ns_st_pt","ns_st_pa","ns_st_ad","ns_st_li","ns_st_ci","ns_ap_jb","ns_ap_res","ns_ap_c12m","ns_ap_install","ns_ap_updated","ns_ap_lastrun","ns_ap_cs","ns_ap_runs","ns_ap_usage","ns_ap_fg","ns_ap_ft","ns_ap_dft","ns_ap_bt","ns_ap_dbt","ns_ap_dit","ns_ap_as","ns_ap_das","ns_ap_it","ns_ap_uc","ns_ap_aus","ns_ap_daus","ns_ap_us","ns_ap_dus","ns_ap_ut","ns_ap_oc","ns_ap_uxc","ns_ap_uxs","ns_ap_lang","ns_ap_ar","ns_ap_miss","ns_ts","ns_st_ca","ns_st_cp","ns_st_er","ca_ns_st_er","cb_ns_st_er","cc_ns_st_er","cd_ns_st_er","ns_st_pe","ns_st_ui","ca_ns_st_ui","cb_ns_st_ui","cc_ns_st_ui","cd_ns_st_ui","ns_st_bc","ns_st_bt","ns_st_bp","ns_st_pc","ns_st_pp","ns_st_br","ns_st_ub","ns_st_vo","ns_st_ws","ns_st_pl","ns_st_pr","ns_st_ep","ns_st_ty","ns_st_ct","ns_st_cs","ns_st_ge","ns_st_st","ns_st_dt","ns_st_de","ns_st_pu","ns_st_cu","ns_st_fee","ns_ap_i1","ns_ap_i2","ns_ap_i3","ns_ap_i4","ns_ap_i5","ns_ap_i6","ns_ap_referrer","ns_clid","ns_campaign","ns_source","ns_mchannel","ns_linkname","ns_fee","gclid","utm_campaign","utm_source","utm_medium","utm_term","utm_content","c3","ca3","cb3","cc3","cd3","c4","ca4","cb4","cc4","cd4","c5","ca5","cb5","cc5","cd5","c6","ca6","cb6","cc6","cd6","c10","c11","c13","c14","c15","c16","c7","c8","c9"]
cs_vfe={}
for each label in cs_vfd
if m.labels[label]<>invalid then
cs_vjo=cs_vjo+"&" +comscore_url_encode(label)+ "=" +comscore_url_encode(m.labels[label])
cs_vfe.addreplace(label,true)
end if
end for
for each key in m.labels
if m.labels[key]<>invalid and cs_vfe[key]=invalid then
cs_vjo=cs_vjo+"&" +comscore_url_encode(key)+ "=" +comscore_url_encode(m.labels[key])
end if
end for
if len(cs_vjo)>0 then
return right(cs_vjo,len(cs_vjo)-1)
else
return cs_vjo
end if
end function
return cs_vxd
end function
function cs_vfh(dax as object,cs_vvb as string,pixelurl as string,labels as object)as object
cs_vxd=csmeasurement(dax)
di=createobject("roDeviceInfo")
if pixelurl<>invalid and pixelurl<>"" then cs_vxd.setpixelurl(pixelurl)
cs_vxd.labels["c1"]= "19"
cs_vxd.labels["ns_ap_an"]=dax.appname()
cs_vxd.labels["ns_ap_pn"]= "roku"
if dax.version()<>dax.previousversion()or(dax.p_storage.cs_vgs("runs")=true and comscore_stoi(dax.p_storage.cs_vgr("runs"))=0)then
cs_vxd.labels["c12"]=dax.visitorid()
else
visitorid=""
if dax.p_storage.cs_vgs("visitorId")then
visitorid=dax.p_storage.cs_vgr("visitorId")
else
di=createobject("roDeviceInfo")
cs_vfl=di.getdeviceuniqueid()+dax.cs_vbx
cs_vfm=createobject("roByteArray")
cs_vfm.fromasciistring(cs_vfl)
cs_vfn=createobject("roEVPDigest")
cs_vfn.setup("md5")
cs_vfn.update(cs_vfm)
visitorid=cs_vfn.final()
dax.p_storage.cs_vgt("visitorId",visitorid)
end if
cs_vxd.labels["c12"]=visitorid
end if
if findmemberfunction(di,"GetDeviceUniqueId")<>invalid then
cs_vfo=createobject("roByteArray")
cs_vfo.fromasciistring(di.getdeviceuniqueid())
cs_vfp=createobject("roEVPDigest")
cs_vfp.setup("md5")
cs_vfp.update(cs_vfo)
cs_vxd.labels["ns_ap_i1"]=cs_vfp.final()
cs_vfq=createobject("roEVPDigest")
cs_vfq.setup("sha1")
cs_vfq.update(cs_vfo)
cs_vxd.labels["ns_ap_i6"]=cs_vfq.final()
end if
if findmemberfunction(di,"IsAdIdTrackingDisabled")<>invalid and findmemberfunction(di,"GetAdvertisingId")<>invalid then
if di.isadidtrackingdisabled()=false then
cs_vfr=createobject("roByteArray")
cs_vfr.fromasciistring(di.getadvertisingid())
cs_vfs=createobject("roEVPDigest")
cs_vfs.setup("md5")
cs_vfs.update(cs_vfr)
cs_vxd.labels["ns_ap_i3"]=cs_vfs.final()
cs_vft=createobject("roEVPDigest")
cs_vft.setup("sha1")
cs_vft.update(cs_vfr)
cs_vxd.labels["ns_ap_i5"]=cs_vft.final()
end if
end if
cs_vxd.labels["ns_ap_device"]=di.getmodel()
cs_vxd.labels["ns_ap_as"]=comscore_tostr(dax.p_genesis)
cs_vxd.labels["ns_type"]=cs_vvb
cs_vxd.labels["ns_ap_ev"]=cs_vvb
cs_vxd.labels["ns_ts"]=comscore_tostr(cs_vxd.cs_vez)
cs_vxd.labels["ns_ap_pfv"]=di.getversion()
cs_vxd.labels["ns_nc"]= "1"
if dax.cs_vfu=0 then
if dax.cs_vcq>0 then
cs_vxd.labels["ns_ap_dft"]=comscore_tostr(dax.cs_vcp)
cs_vxd.labels["ns_ap_ft"]=comscore_tostr(dax.cs_vcq)
end if
else
cs_vxd.labels["ns_ap_dft"]=comscore_tostr(dax.cs_vj.totalmilliseconds())
cs_vxd.labels["ns_ap_ft"]=comscore_tostr(dax.cs_vk.totalmilliseconds())
end if
cs_vfv=dax.getlabels()
for each key in cs_vfv
cs_vxd.labels[key]=cs_vfv[key]
end for
for each key in labels
cs_vxd.labels[key]=labels[key]
end for
return cs_vxd
end function
function csapplicationmeasurement(dax as object,cs_vvb as string,pixelurl as string,labels as object)as object
cs_vfz=cseventtype().hidden
if cs_vvb=cseventtype().start or cs_vvb=cseventtype().view then cs_vfz=cseventtype().view
cs_vxd=cs_vfh(dax,cs_vfz,pixelurl,labels)
cs_vxd.labels["ns_ap_ev"]=cs_vvb
cs_vxd.labels["ns_ap_ver"]=dax.appversion()
di=createobject("roDeviceInfo")
if comscore_is26()then
cs_vgc=di.getdisplaysize()
cs_vxd.labels["ns_ap_res"]=stri(cs_vgc.w).trim()+ "x" +stri(cs_vgc.h).trim()
end if
if comscore_is43()then cs_vxd.labels["ns_ap_lang"]=di.getcurrentlocale()
cs_vxd.labels["ns_ap_sv"]=dax.version()
for each key in labels
cs_vxd.labels[key]=labels[key]
end for
return cs_vxd
end function
function cs_vgd(dax as object,cs_vvb as string,pixelurl as string,labels as object)as object
cs_vxd=csapplicationmeasurement(dax,cs_vvb,pixelurl,labels)
cs_vxd.labels["ns_ap_install"]= "yes"
cs_vxd.labels["ns_ap_runs"]=dax.p_storage.cs_vgr("runs")
cs_vxd.labels["ns_ap_gs"]=comscore_tostr(dax.cs_vcf())
cs_vxd.labels["ns_ap_lastrun"]=comscore_tostr(dax.cs_vcj())
for each key in labels
cs_vxd.labels[key]=labels[key]
end for
return cs_vxd
end function
function cs_vgf(dax as object,cs_vvb as string,pixelurl as string,labels as object)as object
cs_vxd=csapplicationmeasurement(dax,cs_vvb,pixelurl,labels)
return cs_vxd
end function
function cs_vgh(cs_vmb as object)as object
cs_vxd=createobject("roAssociativeArray")
cs_vxd.cs_vmb=cs_vmb
cs_vxd.cs_vgk=function()as object
cs_vgl=createobject("roUrlTransfer")
m.cs_vgm=createobject("roMessagePort")
cs_vgl.setport(m.cs_vgm)
cs_vgl.setcertificatesfile("common:/certs/ca-bundle.crt")
cs_vgl.enableencodings(true)
cs_vgl.addheader("Expect","")
url=m.cs_vmb.pixelurl+m.cs_vmb.cs_vfa()
if cscomscore().log_debug then print"Dispatching: " +url
cs_vgl.seturl(url)
cs_vgl.setrequest("GET")
m.dispatch(cs_vgl)
cscomscore().cs_vbc()
cscomscore().cs_vbd()
end function
cs_vxd.dispatch=function(cs_vgl as object)
if(cs_vgl.asyncgettostring())then wait(500,cs_vgl.getport())
end function
return cs_vxd
end function
function cs_vgo(dax as object)as object
cs_vxd=createobject("roAssociativeArray")
cs_vxd.cs_vgq=createobject("roRegistrySection","com.comscore." +dax.appname()+ "-2")
cs_vxd.cs_vgr=function(key)as string
if m.cs_vgq.exists(key)then return m.cs_vgq.read(key)
return""
end function
cs_vxd.cs_vgs=function(key)as boolean
return m.cs_vgq.exists(key)
end function
cs_vxd.cs_vgt=function(key,val)as void
m.cs_vgq.write(key,val)
m.cs_vgq.flush()
end function
cs_vxd.cs_vgu=function(key)as void
m.cs_vgq.delete(key)
m.cs_vgq.flush()
end function
return cs_vxd
end function
function comscore_is26()as boolean
if m.cs_vgz=invalid then
di=createobject("roDeviceInfo")
cs_vki=eval("country=di.GetCountryCode()")
if cs_vki=252
m.cs_vgz=true
else
m.cs_vgz=false
end if
end if
return m.cs_vgz
end function
function comscore_is43()as boolean
if m.cs_vhe=invalid then
di=createobject("roDeviceInfo")
cs_vki=eval("locale=di.GetCurrentLocale()")
if cs_vki=252
m.cs_vhe=true
else
m.cs_vhe=false
end if
end if
return m.cs_vhe
end function
function comscore_unix_time()as double
if m.cs_vhg=invalid then
m.cs_vhg=createobject("roAssociativeArray")
m.cs_vhg.cs_vhh=createobject("roTimespan")
cs_vra=createobject("roDateTime")
cs_vra.mark()
m.cs_vhg.offset#=cs_vra.asseconds()*1000#
m.cs_vhg.cs_vhh.mark()
end if
m.p_csmillis#=m.cs_vhg.cs_vhh.totalmilliseconds()
return m.cs_vhg.offset#+m.p_csmillis#
end function
function comscore_tostr(obj as object)as string
cs_vhr=type(obj)
if cs_vhr="String" or cs_vhr="roString" then return obj
if cs_vhr="Integer" or cs_vhr="roInt" then return stri(obj).trim()
if cs_vhr="Double" or cs_vhr="roIntrinsicDouble" or cs_vhr="Float" or cs_vhr="roFloat" then
num#=obj
mil#=1000000
if abs(num#)<=mil#then return str(num#).trim()
cs_vht=int(num#/mil#)
if num#/mil#-cs_vht<0 then cs_vht=cs_vht-1
cs_vhu=int((num#-mil#*cs_vht))
cs_vhv=cs_vht.tostr()
cs_vhw=string(6-cs_vhu.tostr().len(),"0")+cs_vhu.tostr()
return cs_vhv+cs_vhw
end if
return"UNKN" +cs_vhr
end function
function comscore_stod(obj as string)as double
len=obj.len()
if len<=6 then
cs_vjo#=val(obj)
return cs_vjo#
end if
left=obj.left(len-6)
right=obj.right(6)
left#=val(left)
right#=val(right)
mil#=1000000
cs_vjo#=left#*mil#+right#
return cs_vjo#
end function
function comscore_stoi(obj as string)as integer
return int(val(obj))
end function
function comscore_url_encode(cs_vfl as string)as string
if m.cs_vhy=invalid then m.cs_vhy=createobject("roUrlTransfer")
return m.cs_vhy.urlencode(cs_vfl)
end function
function comscore_extend(toobject as object,fromobject as object)
if toobject<>invalid and fromobject<>invalid and type(toobject)= "roAssociativeArray" and type(fromobject)= "roAssociativeArray" then
for each key in fromobject
toobject.addreplace(key,fromobject[key])
end for
end if
end function
function csstreamsense(dax=invalid as object)as object
cs_vxd=createobject("roAssociativeArray")
onstatechange=invalid
labels=invalid
cs_vxd.cs_via="roku"
cs_vxd.cs_vib="4.1503.03"
cs_vxd.cs_vic=500#
cs_vxd.cs_vid=10#*1000#
cs_vxd.cs_vie=60#*1000#
cs_vxd.cs_vif=6
cs_vxd.cs_vig=1200000#
cs_vxd.cs_vih=500#
cs_vxd.cs_vii=1500
cs_vxd.cs_vph=invalid
cs_vxd.cs_vpi=invalid
cs_vxd.p_pixelurl=""
cs_vxd.cs_vos=0#
cs_vxd.cs_vob=0#
cs_vxd.cs_vor=invalid
cs_vxd.cs_vnb=0
cs_vxd.cs_vpj=invalid
cs_vxd.cs_vka=true
cs_vxd.cs_vof=true
cs_vxd.cs_vnd=-1#
cs_vxd.cs_vmm=0
cs_vxd.cs_vmn=-1#
cs_vxd.cs_vmj=-1#
cs_vxd.cs_vmu=-1#
cs_vxd.cs_vom=invalid
cs_vxd.cs_vnh=invalid
cs_vxd.cs_vlf=invalid
cs_vxd.cs_vjl=invalid
cs_vxd.cs_vji=invalid
cs_vxd.cs_vlw=""
cs_vxd.cs_vly=""
cs_vxd.cs_vkc=false
cs_vxd.cs_vlr=-1#
cs_vxd.cs_vls=invalid
cs_vxd.cs_vlt=invalid
cs_vxd.engageto=function(screen as object)as void
m.reset()
m.cs_vji=screen
screen.cs_vlg=m
cs_vjk={}
cs_vjk["ns_st_cu"]=screen.cs_vxg.streamurls[0]
if screen.cs_vxg.title<>invalid then cs_vjk["ns_st_ep"]=screen.cs_vxg.title
m.setclip(cs_vjk)
m.cs_vjl=createobject("roTimespan")
end function
cs_vxd.onplayerevent=function(cs_vxi as object)as boolean
cs_vjo=false
m.cs_vph.tick()
if cs_vxi=invalid then
if m.getstate()=csstreamsensestate().playing and m.cs_vjl.totalmilliseconds()>m.cs_vii then
m.notify(csstreamsenseeventtype().pause)
else
m.tick()
end if
else if comscore_is26()and cs_vxi.ispaused()then
m.notify(csstreamsenseeventtype().pause)
else if comscore_is26()and cs_vxi.isstreamstarted()then
m.notify(csstreamsenseeventtype().buffer)
else if cs_vxi.isplaybackposition()then
m.notify(csstreamsenseeventtype().play,cs_vxi.getindex()*1000)
m.cs_vjl.mark()
else if cs_vxi.isscreenclosed()or cs_vxi.isfullresult()or cs_vxi.ispartialresult()or cs_vxi.isrequestfailed()then
m.notify(csstreamsenseeventtype().end)
cs_vjo=true
end if
return cs_vjo
end function
cs_vxd.tick=function()as void
cs_vra=comscore_unix_time()
if m.cs_vmj>=0 and m.cs_vmj<=cs_vra then
m.cs_vml()
end if
if m.cs_vmu>=0 and m.cs_vmu<=cs_vra then
m.cs_vms()
end if
if m.cs_vnd>=0 and m.cs_vnd<=cs_vra then
m.cs_vmz()
end if
if m.cs_vlr>=0 and m.cs_vlr<=cs_vra then
m.cs_vlh(m.cs_vls,m.cs_vlt)
end if
end function
cs_vxd.isidle=function()as boolean
return m.getstate()=csstreamsensestate().idle
end function
cs_vxd.setpixelurl=invalid
cs_vxd.pixelurl=invalid
cs_vxd.notify=function(cs_vvb as object,position=-1#as double,eventlabelmap=invalid as object)as void
cs_vog=m.cs_vnl(cs_vvb)
cs_vln=createobject("roAssociativeArray")
if eventlabelmap<>invalid then cs_vln.append(eventlabelmap)
m.cs_vne(cs_vln)
if not cs_vln.doesexist("ns_st_po")then
cs_vln["ns_st_po"]=comscore_tostr(position)
end if
if cs_vvb=csstreamsenseeventtype().play or cs_vvb=csstreamsenseeventtype().pause or cs_vvb=csstreamsenseeventtype().buffer or cs_vvb=csstreamsenseeventtype().end then
if m.ispauseplayswitchdelayenabled()and m.cs_vni(m.cs_vor)and m.cs_vni(cs_vog)and not(m.cs_vor=csstreamsensestate().playing and cs_vog=csstreamsensestate().paused and m.cs_vlt=invalid)then
m.cs_vlh(cs_vog,cs_vln,m.cs_vic)
else
m.cs_vlh(cs_vog,cs_vln)
end if
else
if m.cs_von(cs_vln)<0 then
cs_vln["ns_st_po"]=comscore_tostr(m.cs_voh(m.cs_voo(cs_vln)))
end if
labels=m.cs_vot(cs_vvb,cs_vln)
labels.append(cs_vln)
m.dispatch(labels,false)
m.cs_vnb=m.cs_vnb+1
end if
end function
cs_vxd.getlabels=function()as object
return m.cs_vpi
end function
cs_vxd.sharingsdkpersistentlabels=function()as boolean
return m.cs_vka
end function
cs_vxd.sharesdkpersistentlabels=function(flag as boolean)
m.cs_vka=flag
end function
cs_vxd.ispauseonbufferingenabled=function()as boolean
return m.cs_vof
end function
cs_vxd.setpauseonbufferingenabled=function(pauseonbufferingenabled as boolean)
m.cs_vof=pauseonbufferingenabled
end function
cs_vxd.ispauseplayswitchdelayenabled=function()as boolean
return m.cs_vkc
end function
cs_vxd.setpauseplayswitchdelayenabled=function(pauseplayswitchdelayenabled as boolean)as void
m.cs_vkc=pauseplayswitchdelayenabled
end function
cs_vxd.setclip=function(labels as object,loop=false as boolean)as boolean
cs_vki=false
if m.cs_vor=csstreamsensestate().idle then
m.cs_vpj.getclip().reset()
m.cs_vpj.getclip().setlabels(labels,invalid)
if loop=true then
m.cs_vpj.cs_vvi()
end if
cs_vki=true
end if
return cs_vki
end function
cs_vxd.setplaylist=function(labels as object)as boolean
cs_vki=false
if m.cs_vor=csstreamsensestate().idle then
m.cs_vpj.cs_vwe()
m.cs_vpj.reset()
m.cs_vpj.getclip().reset()
m.cs_vpj.setlabels(labels,invalid)
cs_vki=true
end if
return cs_vki
end function
cs_vxd.importstate=function(labels as object)as void
m.reset()
cs_vkj=createobject("roAssociativeArray")
cs_vkj.append(labels)
m.cs_vpj.cs_vwj(cs_vkj,invalid)
m.cs_vpj.getclip().cs_vwj(cs_vkj,invalid)
m.cs_vwj(cs_vkj)
m.cs_vnb=m.cs_vnb+1
end function
cs_vxd.exportstate=function()as object
return m.cs_vnh
end function
cs_vxd.getversion=function()as string
return m.cs_vib
end function
cs_vxd.addlistener=function(cs_vkm as object)as void
if cs_vkm=invalid or cs_vkm.onstatechange=invalid then return
m.cs_vlf.push(cs_vkm)
end function
cs_vxd.removelistener=function(cs_vkm as object)as void
if cs_vkm=invalid or cs_vkm.onstatechange=invalid then return
if m.cs_vlf.count()>0 then
cs_vko=0
while cs_vko<m.cs_vlf.count()
if cs_vkm.onstatechange=m.cs_vlf[cs_vko].onstatechange then exit while
cs_vko=cs_vko+1
end while
if cs_vko<m.cs_vlf.count()then m.cs_vlf.delete(cs_vko)
end if
end function
cs_vxd.getclip=function()as object
return m.cs_vpj.getclip()
end function
cs_vxd.getplaylist=function()as object
return m.cs_vpj
end function
cs_vxd.setlabels=function(cs_vuu as object)as void
if cs_vuu<>invalid then
if m.cs_vpi=invalid then
m.cs_vpi=cs_vuu
else
m.cs_vpi.append(cs_vuu)
end if
end if
end function
cs_vxd.getlabel=function(name as string)as string
return m.cs_vpi[name]
end function
cs_vxd.setlabel=function(name as string,cs_vwu as string)as void
if cs_vwu=invalid then
m.cs_vpi.delete(name)
else
m.cs_vpi[name]=cs_vwu
end if
end function
cs_vxd.reset=function(keeplabels=invalid as object)as void
m.cs_vpj.reset(keeplabels)
m.cs_vpj.cs_vwc(0)
m.cs_vpj.cs_vvd(comscore_tostr(comscore_unix_time())+ "_1")
m.cs_vpj.getclip().reset(keeplabels)
if keeplabels<>invalid and type(keeplabels)= "roArray" and keeplabels.count()>0 then
cs_vxa(m.cs_vpi,keeplabels)
else
m.cs_vpi.clear()
end if
m.cs_vnb=1
m.cs_vmm=0
m.cs_vme()
m.cs_vmh()
m.cs_vnd=-1#
m.cs_vmj=-1#
m.cs_vmn=-1#
m.cs_vmu=-1#
m.cs_vor=csstreamsensestate().idle
m.cs_vos=-1#
m.cs_vom=invalid
m.cs_vlw=m.cs_via
m.cs_vly=m.cs_vib
m.cs_vnh=invalid
m.cs_vob=0#
m.cs_vlf=createobject("roArray",1,true)
m.cs_vlq()
if m.cs_vji<>invalid then m.cs_vji.cs_vlg=invalid
end function
cs_vxd.getstate=function()as object
return m.cs_vor
end function
cs_vxd.cs_vlh=function(cs_vog as object,eventlabelmap as object,cs_vli=-1#as double)as void
m.cs_vlq()
if cs_vli>=0 then
m.cs_vlr=comscore_unix_time()+cs_vli
m.cs_vls=cs_vog
m.cs_vlt=eventlabelmap
else if m.cs_vop(cs_vog)=true then
cs_vny=m.getstate()
previousstatechangetimestamp#=m.cs_vos
eventtime#=m.cs_voo(eventlabelmap)
delta#=0
if previousstatechangetimestamp#>=0 then
delta#=eventtime#-previousstatechangetimestamp#
end if
m.cs_vnv(m.getstate(),eventlabelmap)
m.cs_voa(cs_vog,eventlabelmap)
m.cs_voq(cs_vog)
for each cs_vkm in m.cs_vlf
if cs_vkm.onstatechange<>invalid then cs_vkm.onstatechange(cs_vny,cs_vog,eventlabelmap,delta#)
end for
m.cs_vwj(eventlabelmap)
m.cs_vpj.cs_vwj(eventlabelmap,cs_vog)
m.cs_vpj.getclip().cs_vwj(eventlabelmap,cs_vog)
cs_vln=m.cs_vot(m.cs_vnq(cs_vog),eventlabelmap)
cs_vln.append(eventlabelmap)
if m.cs_voj(m.cs_vor)=true then
m.dispatch(cs_vln)
m.cs_vom=m.cs_vor
m.cs_vnb=m.cs_vnb+1
end if
end if
end function
cs_vxd.cs_vlq=function()as void
m.cs_vlr=-1#
m.cs_vls=invalid
m.cs_vlt=invalid
end function
cs_vxd.cs_vwj=function(labels as object)as void
cs_vwu=labels["ns_st_mp"]
if cs_vwu<>invalid then
m.cs_vlw=cs_vwu
labels.delete("ns_st_mp")
end if
cs_vwu=labels["ns_st_mv"]
if cs_vwu<>invalid then
m.cs_vly=cs_vwu
labels.delete("ns_st_mv")
end if
cs_vwu=labels["ns_st_ec"]
if cs_vwu<>invalid then
m.cs_vnb=comscore_stoi(cs_vwu)
labels.delete("ns_st_ec")
end if
end function
cs_vxd.dispatch=function(eventlabelmap as object,snapshot=true as boolean)as void
if snapshot=true then m.cs_vng(eventlabelmap)
if not m.cs_vnf()then
cs_vmb=cs_vtu(m,m.cs_vph,eventlabelmap,m.pixelurl())
m.cs_vph.dispatch(cs_vmb)
end if
end function
cs_vxd.cs_vmc=function()as void
if m.cs_vmn>=0 then
interval#=m.cs_vmn
else
interval#=m.cs_vie
if m.cs_vmm<m.cs_vif then interval#=m.cs_vid
end if
m.cs_vmj=comscore_unix_time()+interval#
end function
cs_vxd.cs_vme=function()as void
m.cs_vmn=m.cs_vmj-comscore_unix_time()
m.cs_vmj=-1#
end function
cs_vxd.cs_vmh=function()as void
m.cs_vmn=-1#
m.cs_vmj=-1#
m.cs_vmm=0
end function
cs_vxd.cs_vml=function()as void
m.cs_vmm=m.cs_vmm+1
eventlabelmap=m.cs_vot(csstreamsenseeventtype().heart_beat,invalid)
m.dispatch(eventlabelmap)
m.cs_vmn=-1
m.cs_vmc()
end function
cs_vxd.cs_vmo=function()as void
m.cs_vmq()
m.cs_vmu=comscore_unix_time()+m.cs_vig
end function
cs_vxd.cs_vmq=function()as void
m.cs_vmu=-1#
end function
cs_vxd.cs_vms=function()as void
eventlabelmap=m.cs_vot(csstreamsenseeventtype().keep_alive,invalid)
m.dispatch(eventlabelmap)
m.cs_vnb=m.cs_vnb+1
m.cs_vmu=comscore_unix_time()+m.cs_vig
end function
cs_vxd.cs_vmv=function()as void
m.cs_vnd=comscore_unix_time()+m.cs_vih
end function
cs_vxd.cs_vmx=function()as void
m.cs_vnd=-1#
end function
cs_vxd.cs_vmz=function()as void
if m.cs_vom=csstreamsensestate().playing then
m.cs_vpj.cs_vvy()
m.cs_vpj.cs_vvv()
labels=m.cs_vot(csstreamsenseeventtype().pause,invalid)
m.dispatch(labels)
m.cs_vnb=m.cs_vnb+1
m.cs_vom=csstreamsensestate().paused
end if
m.cs_vnd=-1#
end function
cs_vxd.cs_vne=function(eventlabelmap as object)as void
cs_vco#=m.cs_voo(eventlabelmap)
if cs_vco#<0 then
eventlabelmap["ns_ts"]=comscore_tostr(comscore_unix_time())
end if
end function
cs_vxd.cs_vnf=function()as boolean
if m.cs_vph.publishersecret()= "" or m.cs_vph.customerc2()=invalid then return true
return false
end function
cs_vxd.cs_vng=function(labels as object)as void
m.cs_vnh=m.cs_vot(m.cs_vnq(m.cs_vor),invalid)
m.cs_vnh.append(labels)
end function
cs_vxd.cs_vni=function(state as object)as boolean
if state=csstreamsensestate().playing or state=csstreamsensestate().paused then return true
return false
end function
cs_vxd.cs_vnl=function(cs_vnp as object)as object
if cs_vnp=csstreamsenseeventtype().play then return csstreamsensestate().playing
if cs_vnp=csstreamsenseeventtype().pause then return csstreamsensestate().paused
if cs_vnp=csstreamsenseeventtype().buffer then return csstreamsensestate().buffering
if cs_vnp=csstreamsenseeventtype().end then return csstreamsensestate().idle
return invalid
end function
cs_vxd.cs_vnq=function(state as object)as object
if state=csstreamsensestate().playing then return csstreamsenseeventtype().play
if state=csstreamsensestate().paused then return csstreamsenseeventtype().pause
if state=csstreamsensestate().buffering then return csstreamsenseeventtype().buffer
if state=csstreamsensestate().idle then return csstreamsenseeventtype().end
return invalid
end function
cs_vxd.cs_vnv=function(cs_vny as object,eventlabelmap as object)as void
eventtime#=m.cs_voo(eventlabelmap)
if cs_vny=csstreamsensestate().playing then
m.cs_vpj.cs_vvk(eventtime#)
m.cs_vme()
m.cs_vmq()
else if cs_vny=csstreamsensestate().buffering then
m.cs_vpj.cs_vvl(eventtime#)
m.cs_vmx()
else if cs_vny=csstreamsensestate().idle then
keeplabels=createobject("roArray",1,true)
cs_vnz=m.cs_vpj.getclip().getlabels()
if cs_vnz<>invalid then
for each key in cs_vnz
keeplabels.push(key)
end for
end if
m.cs_vpj.getclip().reset(keeplabels)
end if
end function
cs_vxd.cs_voa=function(cs_vog as object,eventlabelmap as object)as void
eventtime#=m.cs_voo(eventlabelmap)
if m.cs_von(eventlabelmap)<0 then
eventlabelmap["ns_st_po"]=comscore_tostr(m.cs_voh(eventtime#))
end if
playerposition#=m.cs_von(eventlabelmap)
m.cs_vob=playerposition#
if cs_vog=csstreamsensestate().playing then
m.cs_vmc()
m.cs_vmo()
m.cs_vpj.getclip().cs_vsv(eventtime#)
if m.cs_voj(cs_vog)=true then
m.cs_vpj.getclip().cs_vvi()
if m.cs_vpj.cs_vvf()<1 then
m.cs_vpj.cs_vvg(1)
end if
end if
else if cs_vog=csstreamsensestate().paused then
if m.cs_voj(cs_vog)then
m.cs_vpj.cs_vvv()
end if
else if cs_vog=csstreamsensestate().buffering then
m.cs_vpj.getclip().cs_vsy(eventtime#)
if m.cs_vof=true then
m.cs_vmv()
end if
else if cs_vog=csstreamsensestate().idle then
m.cs_vmh()
end if
end function
cs_vxd.cs_voh=function(eventtime as double)as double
cs_vjo#=m.cs_vob
if m.cs_vor=csstreamsensestate().playing then
cs_vjo#=cs_vjo#+ (eventtime-m.cs_vos)
end if
return cs_vjo#
end function
cs_vxd.cs_voj=function(state as object)as boolean
if state=csstreamsensestate().paused and(m.cs_vom=csstreamsensestate().idle or m.cs_vom=invalid)then
return false
else
return state<>csstreamsensestate().buffering and m.cs_vom<>state
end if
end function
cs_vxd.cs_von=function(cs_vuu as object)as double
playerposition#= -1#
if cs_vuu.doesexist("ns_st_po")then
playerposition#=comscore_stod(cs_vuu["ns_st_po"])
end if
return playerposition#
end function
cs_vxd.cs_voo=function(cs_vuu as object)as double
cs_vco#= -1#
if cs_vuu.doesexist("ns_ts")then
cs_vco#=comscore_stod(cs_vuu["ns_ts"])
end if
return cs_vco#
end function
cs_vxd.cs_vop=function(cs_vog as object)as boolean
if cs_vog<>invalid and m.getstate()<>cs_vog then return true
return false
end function
cs_vxd.cs_voq=function(cs_vog as object)as void
m.cs_vor=cs_vog
m.cs_vos=comscore_unix_time()
end function
cs_vxd.cs_vot=function(cs_vvb as object,cs_vur as object)as object
cs_vuu=createobject("roAssociativeArray")
if cs_vur<>invalid then
cs_vuu.append(cs_vur)
end if
if not cs_vuu.doesexist("ns_ts")then
cs_vuu["ns_ts"]=comscore_tostr(comscore_unix_time())
end if
if cs_vvb<>invalid and not cs_vuu.doesexist("ns_st_ev")then
cs_vuu["ns_st_ev"]=cs_vvb
end if
if m.sharingsdkpersistentlabels()then
cs_vuu.append(m.cs_vph.getlabels())
end if
cs_vuu.append(m.getlabels())
m.cs_vuq(cs_vvb,cs_vuu)
m.cs_vpj.cs_vuq(cs_vvb,cs_vuu)
m.cs_vpj.getclip().cs_vuq(cs_vvb,cs_vuu)
cs_vov=createobject("roAssociativeArray")
cs_vov["ns_st_mp"]=m.cs_vlw
cs_vov["ns_st_mv"]=m.cs_vly
cs_vov["ns_st_ub"]= "0"
cs_vov["ns_st_br"]= "0"
cs_vov["ns_st_pn"]= "1"
cs_vov["ns_st_tp"]= "1"
for each key in cs_vov
if not cs_vuu.doesexist(key)then cs_vuu[key]=cs_vov[key]
end for
return cs_vuu
end function
cs_vxd.cs_vuq=function(cs_vvb as object,cs_vur as object)as object
cs_vuu=cs_vur
if cs_vuu=invalid then
cs_vuu=createobject("roAssociativeArray")
end if
cs_vuu["ns_st_ec"]=comscore_tostr(m.cs_vnb)
if not cs_vuu.doesexist("ns_st_po")then
currentposition#=m.cs_vob
eventtime#=m.cs_voo(cs_vuu)
if cs_vvb=csstreamsenseeventtype().play or cs_vvb=csstreamsenseeventtype().keep_alive or cs_vvb=csstreamsenseeventtype().heart_beat or(cs_vvb=invalid and cs_vpe=csstreamsensestate().playing)then
currentposition#=currentposition#+ (eventtime#-m.cs_vpj.getclip().cs_vsu())
end if
cs_vuu["ns_st_po"]=comscore_tostr(currentposition#)
end if
if cs_vvb=csstreamsenseeventtype().heart_beat then
cs_vuu["ns_st_hc"]=comscore_tostr(m.cs_vmm)
end if
return cs_vuu
end function
if dax<>invalid then
cs_vxd.cs_vph=dax
else
cs_vxd.cs_vph=cscomscore()
end if
cs_vxd.setpixelurl=cs_vxd.cs_vph.setpixelurl
cs_vxd.pixelurl=cs_vxd.cs_vph.pixelurl
cs_vxd.cs_vpi=createobject("roAssociativeArray")
cs_vxd.cs_vpj=cs_vtw()
cs_vxd.reset()
return cs_vxd
end function
function csstreamingtag(dax=invalid as object)as object
cs_vxd=createobject("roAssociativeArray")
cs_vxd.cs_vpl=0
cs_vxd.cs_vpm=1
cs_vxd.cs_vpn=2
cs_vxd.cs_vql=0
cs_vxd.cs_vqx=0
cs_vxd.cs_vqn=0
cs_vxd.cs_vqg=invalid
cs_vxd.cs_vqy=false
cs_vxd.cs_vqz=0
cs_vxd.cs_vpu=csstreamsense(dax)
cs_vxd.cs_vpu.setlabel("ns_st_it","r")
cs_vxd.cs_vpv=function(metadata as object)as object
if metadata=invalid then
metadata={}
end if
if metadata["ns_st_ci"]=invalid then
metadata["ns_st_ci"]= "0"
end if
if metadata["c3"]=invalid then
metadata["c3"]= "*null"
end if
if metadata["c4"]=invalid then
metadata["c4"]= "*null"
end if
if metadata["c6"]=invalid then
metadata["c6"]= "*null"
end if
return metadata
end function
cs_vxd.cs_vpy=function(timestamp as double)as double
if m.cs_vqx>0 and timestamp>=m.cs_vqx then
m.cs_vqn=m.cs_vqn+timestamp-m.cs_vqx
else
m.cs_vqn=0
end if
return m.cs_vqn
end function
cs_vxd.cs_vqb=function(cs_vra as double)as void
if m.cs_vpu.getstate()<>csstreamsensestate().idle and m.cs_vpu.getstate()<>csstreamsensestate().paused then
m.cs_vpu.notify(csstreamsenseeventtype().end,m.cs_vpy(cs_vra))
else if m.cs_vpu.getstate()=csstreamsensestate().paused then
m.cs_vpu.notify(csstreamsenseeventtype().end,m.cs_vqn)
end if
end function
cs_vxd.cs_vqc=function(metadata as object)as boolean
return m.cs_vqd("ns_st_ci",m.cs_vqg,metadata)and m.cs_vqd("c3",m.cs_vqg,metadata)and m.cs_vqd("c4",m.cs_vqg,metadata)and m.cs_vqd("c6",m.cs_vqg,metadata)
end function
cs_vxd.cs_vqd=function(label as string,map1 as object,map2 as object)as boolean
if label<>invalid and map1<>invalid and map2<>invalid then
if map1[label]<>invalid and map2[label]<>invalid then
return map1[label]=map2[label]
end if
end if
return false
end function
cs_vxd.cs_vqe=function(cs_vra as double,metadata as object)as void
m.cs_vqb(cs_vra)
m.cs_vql=m.cs_vql+1
labels={}
labels["ns_st_cn"]=comscore_tostr(m.cs_vql)
labels["ns_st_pn"]= "1"
labels["ns_st_tp"]= "0"
comscore_extend(labels,metadata)
m.cs_vpu.setclip(labels)
m.cs_vqg=metadata
m.cs_vqx=cs_vra
m.cs_vqn=0
m.cs_vpu.notify(csstreamsenseeventtype().play,m.cs_vqn)
end function
cs_vxd.cs_vqj=function(metadata as object)as void
cs_vra=comscore_unix_time()
m.cs_vqb(cs_vra)
m.cs_vql=m.cs_vql+1
metadata=m.cs_vpv(metadata)
labels={}
labels["ns_st_cn"]=comscore_tostr(m.cs_vql)
labels["ns_st_pn"]= "1"
labels["ns_st_tp"]= "1"
labels["ns_st_ad"]= "1"
comscore_extend(labels,metadata)
m.cs_vpu.setclip(labels)
m.cs_vqn=0
m.cs_vpu.notify(csstreamsenseeventtype().play,m.cs_vqn)
m.cs_vqx=cs_vra
m.cs_vqy=false
end function
cs_vxd.cs_vqq=function(metadata as object,contenttype as integer)as void
cs_vra=comscore_unix_time()
metadata=m.cs_vpv(metadata)
if m.cs_vqz=m.cs_vpl then
m.cs_vqz=contenttype
end if
if m.cs_vqy=true and m.cs_vqz=contenttype then
if not m.cs_vqc(metadata)then
m.cs_vqe(cs_vra,metadata)
else
m.cs_vpu.getclip().setlabels(metadata)
if m.cs_vpu.getstate()<>csstreamsensestate().playing then
m.cs_vqx=cs_vra
m.cs_vpu.notify(csstreamsenseeventtype().play,m.cs_vqn)
end if
end if
else
m.cs_vqe(cs_vra,metadata)
end if
m.cs_vqy=true
m.cs_vqz=contenttype
end function
cs_vxd.playadvertisement=function()as void
labels={}
labels["ns_st_ct"]= "va"
m.cs_vqj(labels)
end function
cs_vxd.playvideoadvertisement=function(metadata=invalid as object)as void
labels={}
labels["ns_st_ct"]= "va"
if metadata<>invalid then
comscore_extend(labels,metadata)
end if
m.cs_vqj(labels)
end function
cs_vxd.playaudioadvertisement=function(metadata=invalid as object)as void
labels={}
labels["ns_st_ct"]= "aa"
if metadata<>invalid then
comscore_extend(labels,metadata)
end if
m.cs_vqj(labels)
end function
cs_vxd.playcontentpart=function(metadata=invalid as object)as void
labels={}
labels["ns_st_ct"]= "vc"
if metadata<>invalid then
comscore_extend(labels,metadata)
end if
m.cs_vqq(labels,m.cs_vpn)
end function
cs_vxd.playvideocontentpart=function(metadata=invalid as object)as void
labels={}
labels["ns_st_ct"]= "vc"
if metadata<>invalid then
comscore_extend(labels,metadata)
end if
m.cs_vqq(labels,m.cs_vpn)
end function
cs_vxd.playaudiocontentpart=function(metadata=invalid as object)as void
labels={}
labels["ns_st_ct"]= "ac"
if metadata<>invalid then
comscore_extend(labels,metadata)
end if
m.cs_vqq(labels,m.cs_vpm)
end function
cs_vxd.stop=function()as void
cs_vra=comscore_unix_time()
m.cs_vpu.notify(csstreamsenseeventtype().pause,m.cs_vpy(cs_vra))
end function
cs_vxd.tick=function()as void
m.cs_vpu.tick()
end function
cs_vxd.getstate=function()as object
return m.cs_vpu.getstate()
end function
return cs_vxd
end function
function cs_vrb()as object
cs_vxd=createobject("roAssociativeArray")
cs_vxd.cs_vwv=0
cs_vxd.cs_vwl=0
cs_vxd.cs_vwp=0#
cs_vxd.cs_vsz=-1#
cs_vxd.cs_vvr=0#
cs_vxd.cs_vsw=-1#
cs_vxd.cs_vtf="1"
cs_vxd.cs_vuf=createobject("roAssociativeArray")
cs_vxd.reset=function(keeplabels=invalid as object)as void
if keeplabels<>invalid and type(keeplabels)= "roArray" and keeplabels.count()>0 then
cs_vxa(m.cs_vuf,keeplabels)
else
m.cs_vuf.clear()
end if
if m.cs_vuf["ns_st_cl"]=invalid then
m.cs_vuf["ns_st_cl"]= "0"
end if
if m.cs_vuf["ns_st_pn"]=invalid then
m.cs_vuf["ns_st_pn"]= "1"
end if
if m.cs_vuf["ns_st_tp"]=invalid then
m.cs_vuf["ns_st_tp"]= "1"
end if
m.cs_vwv=0
m.cs_vwl=0
m.cs_vwp=0#
m.cs_vsz=-1#
m.cs_vvr=0#
m.cs_vsw=-1#
end function
cs_vxd.setlabels=function(newlabels as object,state=invalid as object)as void
if newlabels<>invalid then
m.cs_vuf.append(newlabels)
end if
m.cs_vwj(m.cs_vuf,state)
end function
cs_vxd.getlabels=function()as object
return m.cs_vuf
end function
cs_vxd.setlabel=function(label as string,cs_vwu as string)as void
cs_vup=createobject("roAssociativeArray")
cs_vup[label]=cs_vwu
m.setlabels(cs_vup)
end function
cs_vxd.getlabel=function(label as string)as string
return m.cs_vuf[label]
end function
cs_vxd.cs_vuq=function(cs_vvb as object,cs_vur=invalid as object)as object
cs_vuu=cs_vur
if cs_vuu=invalid then
cs_vuu=createobject("roAssociativeArray")
end if
cs_vuu["ns_st_cn"]=m.cs_vtf
cs_vuu["ns_st_bt"]=comscore_tostr(m.cs_vvm())
if cs_vvb=csstreamsenseeventtype().play or cs_vvb=invalid
cs_vuu["ns_st_sq"]=comscore_tostr(m.cs_vwl)
end if
if cs_vvb=csstreamsenseeventtype().pause or cs_vvb=csstreamsenseeventtype().end or cs_vvb=csstreamsenseeventtype().keep_alive or cs_vvb=csstreamsenseeventtype().heart_beat or cs_vvb=invalid
cs_vuu["ns_st_pt"]=comscore_tostr(m.cs_vvp())
cs_vuu["ns_st_pc"]=comscore_tostr(m.cs_vwv)
end if
cs_vuu.append(m.cs_vuf)
return cs_vuu
end function
cs_vxd.cs_vvs=function()as integer
return m.cs_vwv
end function
cs_vxd.cs_vvt=function(pauses as integer)as void
m.cs_vwv=pauses
end function
cs_vxd.cs_vvv=function()as void
m.cs_vwv=m.cs_vwv+1
end function
cs_vxd.cs_vvf=function()as integer
return m.cs_vwl
end function
cs_vxd.cs_vvg=function(starts as integer)as void
m.cs_vwl=starts
end function
cs_vxd.cs_vvi=function()as void
m.cs_vwl=m.cs_vwl+1
end function
cs_vxd.cs_vvm=function()as double
cs_vjo#=m.cs_vwp
if m.cs_vsz>=0 then
cs_vjo#=cs_vjo#+ (comscore_unix_time()-m.cs_vsz)
end if
return cs_vjo#
end function
cs_vxd.cs_vvn=function(bufferingtime as double)as void
m.cs_vwp=bufferingtime
end function
cs_vxd.cs_vvp=function()as double
cs_vjo#=m.cs_vvr
if m.cs_vsw>=0 then
cs_vjo#=cs_vjo#+ (comscore_unix_time()-m.cs_vsw)
end if
return cs_vjo#
end function
cs_vxd.cs_vvq=function(cs_vwt as double)as void
m.cs_vvr=cs_vwt
end function
cs_vxd.cs_vsu=function()as double
return m.cs_vsw
end function
cs_vxd.cs_vsv=function(playbacktimestamp as double)as void
m.cs_vsw=playbacktimestamp
end function
cs_vxd.cs_vsx=function()as double
return m.cs_vsz
end function
cs_vxd.cs_vsy=function(bufferingtimestamp as double)as void
m.cs_vsz=bufferingtimestamp
end function
cs_vxd.cs_vta=function()as string
return m.cs_vtf
end function
cs_vxd.cs_vtb=function(clipid as string)as void
m.cs_vtf=clipid
end function
cs_vxd.cs_vwj=function(labels as object,state as object)as void
cs_vwu=labels["ns_st_cn"]
if cs_vwu<>invalid
m.cs_vtf=cs_vwu
labels.delete("ns_st_cn")
end if
cs_vwu=labels["ns_st_bt"]
if cs_vwu<>invalid
m.cs_vwp=comscore_stod(cs_vwu)
labels.delete("ns_st_bt")
end if
m.cs_vto("ns_st_cl",labels)
m.cs_vto("ns_st_pn",labels)
m.cs_vto("ns_st_tp",labels)
m.cs_vto("ns_st_ub",labels)
m.cs_vto("ns_st_br",labels)
if state=csstreamsensestate().playing or state=invalid
cs_vwu=labels["ns_st_sq"]
if(cs_vwu<>invalid)
m.cs_vwl=comscore_stoi(cs_vwu)
labels.delete("ns_st_sq")
end if
end if
if state<>csstreamsensestate().buffering
cs_vwu=labels["ns_st_pt"]
if cs_vwu<>invalid
m.cs_vvr=comscore_stod(cs_vwu)
labels.delete("ns_st_pt")
end if
end if
if state=csstreamsensestate().paused or state=csstreamsensestate().idle or state=invalid
cs_vwu=labels["ns_st_pc"]
if cs_vwu<>invalid
m.cs_vwv=comscore_stoi(cs_vwu)
labels.delete("ns_st_pc")
end if
end if
end function
cs_vxd.cs_vto=function(key as string,labels as object)as void
cs_vwu=labels[key]
if cs_vwu<>invalid then
m.cs_vuf[key]=cs_vwu
end if
end function
cs_vxd.reset()
return cs_vxd
end function
function csstreamsenseeventtype()
if m.cs_vtr=invalid then m.cs_vtr=cs_vts()
return m.cs_vtr
end function
function cs_vts()as object
cs_vtt=createobject("roAssociativeArray")
cs_vtt.buffer="buffer"
cs_vtt.play="play"
cs_vtt.pause="pause"
cs_vtt.end="end"
cs_vtt.heart_beat="hb"
cs_vtt.custom="custom"
cs_vtt.keep_alive="keep-alive"
return cs_vtt
end function
function cs_vtu(streamsense as object,dax as object,labels as object,pixelurl as string)as object
cs_vxd=csapplicationmeasurement(dax,cseventtype().hidden,pixelurl,labels)
if pixelurl<>invalid and pixelurl<>"" then cs_vxd.setpixelurl(pixelurl)
cs_vxd.labels["ns_st_sv"]=streamsense.getversion()
return cs_vxd
end function
function cs_vtw()as object
cs_vxd=createobject("roAssociativeArray")
cs_vxd.cs_vty=cs_vrb()
cs_vxd.cs_vwr=""
cs_vxd.cs_vwl=0
cs_vxd.cs_vwv=0
cs_vxd.cs_vwn=0
cs_vxd.cs_vwp=0#
cs_vxd.cs_vvr=0#
cs_vxd.cs_vuf=createobject("roAssociativeArray")
cs_vxd.cs_vwf=0
cs_vxd.cs_vwi=false
cs_vxd.reset=function(keeplabels=invalid as object)as void
if keeplabels<>invalid and type(keeplabels)= "roArray" and keeplabels.count()>0 then
cs_vxa(m.cs_vuf,keeplabels)
else
m.cs_vuf.clear()
end if
m.cs_vwr=comscore_tostr(comscore_unix_time())+ "_" +comscore_tostr(m.cs_vwf)
m.cs_vwp=0#
m.cs_vvr=0#
m.cs_vwl=0
m.cs_vwv=0
m.cs_vwn=0
m.cs_vwi=false
end function
cs_vxd.setlabels=function(newlabels as object,state=invalid as object)as void
if newlabels<>invalid then
m.cs_vuf.append(newlabels)
end if
m.cs_vwj(m.cs_vuf,state)
end function
cs_vxd.getlabels=function()as object
return m.cs_vuf
end function
cs_vxd.setlabel=function(label as string,cs_vwu as string)as void
cs_vup=createobject("roAssociativeArray")
cs_vup[label]=cs_vwu
m.setlabels(cs_vup)
end function
cs_vxd.getlabel=function(label as string)as string
return m.cs_vuf[label]
end function
cs_vxd.cs_vuq=function(cs_vvb as object,cs_vur=invalid as object)as object
cs_vuu=cs_vur
if cs_vuu=invalid then
cs_vuu=createobject("roAssociativeArray")
end if
cs_vuu["ns_st_bp"]=comscore_tostr(m.cs_vvm())
cs_vuu["ns_st_sp"]=comscore_tostr(m.cs_vwl)
cs_vuu["ns_st_id"]=comscore_tostr(m.cs_vwr)
if m.cs_vwn>0 then
cs_vuu["ns_st_bc"]=comscore_tostr(m.cs_vwn)
end if
if cs_vvb=csstreamsenseeventtype().pause or cs_vvb=csstreamsenseeventtype().end or cs_vvb=csstreamsenseeventtype().keep_alive or cs_vvb=csstreamsenseeventtype().heart_beat or cs_vvb=invalid then
cs_vuu["ns_st_pa"]=comscore_tostr(m.cs_vvp())
cs_vuu["ns_st_pp"]=comscore_tostr(m.cs_vwv)
end if
if cs_vvb=csstreamsenseeventtype().play or cs_vvb=invalid then
if not m.cs_vwg()then
cs_vuu["ns_st_pb"]= "1"
m.cs_vwh(true)
end if
end if
cs_vuu.append(m.cs_vuf)
return cs_vuu
end function
cs_vxd.getclip=function()as object
return m.cs_vty
end function
cs_vxd.cs_vvc=function()as string
return m.cs_vwr
end function
cs_vxd.cs_vvd=function(playlistid as string)as void
m.cs_vwr=playlistid
end function
cs_vxd.cs_vvf=function()as integer
return m.cs_vwl
end function
cs_vxd.cs_vvg=function(starts as integer)as void
m.cs_vwl=starts
end function
cs_vxd.cs_vvi=function()as void
m.cs_vwl=m.cs_vwl+1
end function
cs_vxd.cs_vvk=function(cs_vra as double)as void
if m.cs_vty.cs_vsu()>=0 then
diff#=cs_vra-m.cs_vty.cs_vsu()
m.cs_vty.cs_vsv(-1)
m.cs_vty.cs_vvq(m.cs_vty.cs_vvp()+diff#)
m.cs_vvq(m.cs_vvp()+diff#)
end if
end function
cs_vxd.cs_vvl=function(cs_vra as double)as void
if m.cs_vty.cs_vsx()>=0 then
diff#=cs_vra-m.cs_vty.cs_vsx()
m.cs_vty.cs_vsy(-1)
m.cs_vty.cs_vvn(m.cs_vty.cs_vvm()+diff#)
m.cs_vvn(m.cs_vvm()+diff#)
end if
end function
cs_vxd.cs_vvm=function()as double
cs_vjo#=m.cs_vwp
if m.cs_vty.cs_vsx()>=0 then
cs_vjo#=cs_vjo#+ (comscore_unix_time()-m.cs_vty.cs_vsx())
end if
return cs_vjo#
end function
cs_vxd.cs_vvn=function(bufferingtime as double)as void
m.cs_vwp=bufferingtime
end function
cs_vxd.cs_vvp=function()as double
cs_vjo#=m.cs_vvr
if m.cs_vty.cs_vsu()>=0 then
cs_vjo#=cs_vjo#+ (comscore_unix_time()-m.cs_vty.cs_vsu())
end if
return cs_vjo#
end function
cs_vxd.cs_vvq=function(cs_vwt as double)as void
m.cs_vvr=cs_vwt
end function
cs_vxd.cs_vvs=function()as integer
return m.cs_vwv
end function
cs_vxd.cs_vvt=function(pauses as integer)as void
cs_vxd.cs_vwv=pauses
end function
cs_vxd.cs_vvv=function()as void
m.cs_vwv=m.cs_vwv+1
m.cs_vty.cs_vvv()
end function
cs_vxd.cs_vvx=function()as integer
return m.cs_vwn
end function
cs_vxd.cs_vvy=function()as void
m.cs_vwn=m.cs_vwn+1
end function
cs_vxd.cs_vwa=function(rebuffercount as integer)
m.cs_vwn=rebuffercount
end function
cs_vxd.cs_vwc=function(playlistcounter as integer)as void
m.cs_vwf=playlistcounter
end function
cs_vxd.cs_vwe=function()as void
m.cs_vwf=m.cs_vwf+1
end function
cs_vxd.cs_vwg=function()as boolean
return m.cs_vwi
end function
cs_vxd.cs_vwh=function(firstplayoccurred as boolean)as void
m.cs_vwi=firstplayoccurred
end function
cs_vxd.cs_vwj=function(labels as object,state as object)as void
cs_vwu=labels["ns_st_sp"]
if cs_vwu<>invalid then
m.cs_vwl=comscore_stoi(cs_vwu)
labels.delete("ns_st_sp")
end if
cs_vwu=labels["ns_st_bc"]
if cs_vwu<>invalid then
m.cs_vwn=comscore_stoi(cs_vwu)
labels.delete("ns_st_bc")
end if
cs_vwu=labels["ns_st_bp"]
if cs_vwu<>invalid then
m.cs_vwp=comscore_stod(cs_vwu)
labels.delete("ns_st_bp")
end if
cs_vwu=labels["ns_st_id"]
if cs_vwu<>invalid then
m.cs_vwr=cs_vwu
labels.delete("ns_st_id")
end if
if state<>csstreamsensestate().buffering then
cs_vwu=labels["ns_st_pa"]
if cs_vwu<>invalid then
cs_vwt=comscore_stod(cs_vwu)
labels.delete("ns_st_pa")
end if
end if
if state=csstreamsensestate().paused or state=csstreamsensestate().idle or state=invalid then
cs_vwu=labels["ns_st_pp"]
if cs_vwu<>invalid then
m.cs_vwv=comscore_stoi(cs_vwu)
labels.delete("ns_st_pp")
end if
end if
end function
cs_vxd.reset()
return cs_vxd
end function
function csstreamsensestate()
if m.cs_vwx=invalid then m.cs_vwx=cs_vwy()
return m.cs_vwx
end function
function cs_vwy()as object
cs_vwz=createobject("roAssociativeArray")
cs_vwz.buffering="buffering"
cs_vwz.playing="playing"
cs_vwz.paused="paused"
cs_vwz.idle="idle"
return cs_vwz
end function
function cs_vxa(cs_vup as object,keepkeys as object)
cs_vxb=createobject("roAssociativeArray")
for each keyname in keepkeys
cs_vxb[keyname]=true
end for
cs_vxc=createobject("roArray",30,true)
for each keyname in cs_vup
if not cs_vxb.doesexist(keyname)then
cs_vxc.push(keyname)
end if
end for
for each keyname in cs_vxc
cs_vup.delete(keyname)
end for
end function
function csstreamsensevideoscreenwrapper(args as object)as object
cs_vxd=createobject("roAssociativeArray")
cs_vxe=createobject("roMessagePort")
cs_vxd.cs_vxf=createobject("roVideoScreen")
cs_vxd.cs_vxf.setmessageport(cs_vxe)
cs_vxd.cs_vxg=createobject("roAssociativeArray")
if type(args)= "roAssociativeArray"
if type(args.url)= "roString" and args.url<>"" then
url=args.url
cs_vxd.cs_vxg.streamurls=[url]
end if
if type(args.streamformat)= "roString" and args.streamformat<>"" then
cs_vxd.cs_vxg.streamformat=args.streamformat
end if
if type(args.title)= "roString" and args.title<>"" then
cs_vxd.cs_vxg.title=args.title
else
cs_vxd.cs_vxg.title=""
end if
end if
cs_vxd.cs_vxg.streambitrates=[0]
cs_vxd.cs_vxg.streamqualities=["SD"]
cs_vxd.cs_vxf.setcontent(cs_vxd.cs_vxg)
cs_vxd.cs_vxf.setpositionnotificationperiod(1)
cs_vxd.show=function()as void
m.cs_vxf.show()
while true
cs_vxi=wait(50,m.cs_vxf.getmessageport())
if type(cs_vxi)= "roVideoScreenEvent" then
if cs_vxi.isscreenclosed()
exit while
else if m.cs_vlg<>invalid
if m.cs_vlg.onplayerevent(cs_vxi)then exit while
end if
else if cs_vxi=invalid then
if m.cs_vlg<>invalid then m.cs_vlg.onplayerevent(cs_vxi)
end if
end while
end function
return cs_vxd
end function
