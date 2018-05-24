function cscomscore()as object
if(m.cs_vb=invalid)then
m.cs_vb=cs_vc()
end if
return m.cs_vb
end function
function cs_vc()as object
cs_vxw=createobject("roAssociativeArray")
cs_vxw.log_debug=false
cs_vxw.cs_ve=30*60*1000
cs_vxw.cs_viv=1000*60*60*24
cs_vxw.cs_vg=1000*10
cs_vxw.census_url="http://b.scorecardresearch.com/p2?"
cs_vxw.census_url_secure="https://sb.scorecardresearch.com/p2?"
cs_vxw.cs_vh="4.1.1.171010"
cs_vxw.p_storage=invalid
cs_vxw.cs_vi=createobject("roTimespan")
cs_vxw.cs_vj=createobject("roTimespan")
cs_vxw.cs_vk=createobject("roTimespan")
cs_vxw.cs_vcs=0
cs_vxw.cs_vct=0
cs_vxw.cs_vgh=true
cs_vxw.p_keepalive=invalid
cs_vxw.cs_vge=false
cs_vxw.cs_vqb=createobject("roAssociativeArray")
cs_vxw.p_pixelurl=""
cs_vxw.cs_vca=""
cs_vxw.cs_vcu=""
cs_vxw.cs_vcl=-1
cs_vxw.cs_vcp=-1
cs_vxw.p_genesis=-1
cs_vxw.cs_vfs=0
cs_vxw.cs_vcx=""
cs_vxw.cs_vcz=""
cs_vxw.start=function(labels=invalid as object)as void
m.notify(cseventtype().start,"",labels)
end function
cs_vxw.hidden=function(labels=invalid as object)as void
m.notify(cseventtype().hidden,"",labels)
end function
cs_vxw.view=function(labels=invalid as object)as void
m.notify(cseventtype().view,"",labels)
end function
cs_vxw.close=function()as void
m.notify(cseventtype().close,"",invalid)
end function
cs_vxw.setpublishersecret=function(salt as string)as void
m.cs_vca=salt
end function
cs_vxw.publishersecret=function()as string
return m.cs_vca
end function
cs_vxw.cs_vy=function(cs_vba as boolean)as void
m.cs_vgh=cs_vba
end function
cs_vxw.cs_vba=function()as boolean
return m.cs_vgh
end function
cs_vxw.cs_vbb=function()as object
return m.p_keepalive
end function
cs_vxw.tick=function()as void
m.p_keepalive.tick()
if m.cs_vi.totalmilliseconds()>m.cs_vg then
m.p_storage.cs_vhi("accumulatedForegroundTime",comscore_tostr(m.cs_vj.totalmilliseconds()))
m.p_storage.cs_vhi("totalForegroundTime",comscore_tostr(m.cs_vk.totalmilliseconds()))
m.cs_vi.mark()
end if
end function
cs_vxw.cs_vbc=function()as void
m.p_keepalive.reset()
end function
cs_vxw.cs_vbd=function()as void
m.cs_vj.mark()
end function
cs_vxw.setpixelurl=function(cs_vvw as string)as string
if instr(1,cs_vvw,"?")>0 and right(cs_vvw,1)<>"?" then
cs_vbe=createobject("roAssociativeArray")
cs_vbi=""
labels=right(cs_vvw,len(cs_vvw)-instr(1,cs_vvw,"?")).tokenize("&")
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
m.cs_vqb[label]=cs_vbe[label]
end for
cs_vvw=left(cs_vvw,instr(1,cs_vvw,"?"))+cs_vbi
end if
if instr(1,cs_vvw,"?")=0 and instr(1,cs_vvw,"//")=0 then
if len(m.p_pixelurl)>0 and instr(1,m.p_pixelurl,"?")>0 then
cs_vvw=left(m.p_pixelurl,instr(1,m.p_pixelurl,"?"))+comscore_url_encode(cs_vvw)
else
cs_vvw=cs_vvw+"?"
end if
end if
if right(cs_vvw,1)= "?" then
cs_vvw=cs_vvw+"Application"
end if
m.p_pixelurl=cs_vvw
return m.p_pixelurl
end function
cs_vxw.pixelurl=function()as string
return m.p_pixelurl
end function
cs_vxw.setsecure=function(secure as boolean)as void
m.cs_vge=secure
end function
cs_vxw.secure=function()as boolean
return m.cs_vge
end function
cs_vxw.setcustomerc2=function(c2 as string)as void
m.cs_vqb["c2"]=comscore_url_encode(c2)
if m.secure()then
m.setpixelurl(m.census_url_secure)
else
m.setpixelurl(m.census_url)
end if
end function
cs_vxw.customerc2=function()as string
return m.cs_vqb["c2"]
end function
cs_vxw.getlabels=function()as object
return m.cs_vqb
end function
cs_vxw.setlabels=function(cs_vtw as object)as void
if cs_vtw<>invalid then
for each label in cs_vtw
m.setlabel(label,cs_vtw[label])
end for
end if
end function
cs_vxw.getlabel=function(name as string)as string
return m.cs_vqb[name]
end function
cs_vxw.setlabel=function(key as string,cs_vvw as string)as void
if cs_vvw=invalid then
m.cs_vqb.delete(key)
else
m.cs_vqb[key]=cs_vvw
end if
end function
cs_vxw.setappname=function(name as string)as void
m.cs_vdu=name
end function
cs_vxw.appname=function()as string
return m.cs_vdu
end function
cs_vxw.setappversion=function(version as string)as void
m.cs_vdv=version
end function
cs_vxw.appversion=function()as string
return m.cs_vdv
end function
cs_vxw.adframeworkavailable=function()as boolean
return m.cs_vdw
end function
cs_vxw.setuseraf=function(useraf as boolean)as boolean
m.cs_vgk=useraf
if useraf=true and m.adframeworkavailable()=true then
m.cs_vbt=roku_ads()
if m.cs_vbt<>invalid and findmemberfunction(m.cs_vbt,"enableAdMeasurements")<>invalid then
m.cs_vbt.enableadmeasurements(true)
return true
else
print"Could not enable RAF Ad measurements. Make sure the installed RAF version is greater or equal to 2.1"
end if
end if
return false
end function
cs_vxw.useraf=function()as boolean
return m.cs_vgk
end function
cs_vxw.adinterface=function()as object
return m.cs_vbt
end function
cs_vxw.setuserafsettermethods=function(userafsettermethods as boolean)as void
m.cs_vgn=userafsettermethods
end function
cs_vxw.userafsettermethods=function()as boolean
return m.cs_vgn
end function
cs_vxw.visitorid=function()as string
if m.cs_vcu="" then
di=createobject("roDeviceInfo")
if findmemberfunction(di,"GetPublisherId")<>invalid then
m.cs_vcu=m.cs_vce(di.getpublisherid())+ "-cs62"
else
m.cs_vcu=m.cs_vce(di.getdeviceuniqueid())
end if
m.p_storage.cs_vhi("visitorId",m.cs_vcu)
end if
return m.cs_vcu
end function
cs_vxw.version=function()as string
return m.cs_vcx
end function
cs_vxw.previousversion=function()as string
return m.cs_vcz
end function
cs_vxw.notify=function(cs_vud as string,pixelurl="" as string,labels=invalid as object)as void
if m.cs_vca="" or m.cs_vqb["c2"]=invalid then return
if pixelurl="" then
pixelurl=m.pixelurl()
else
pixelurl=m.setpixelurl(pixelurl)
end if
if labels=invalid then labels=createobject("roAssociativeArray")
if cs_vud<>"close" then
cs_vmu=cs_ves(m,cs_vud,pixelurl,labels)
m.dispatch(cs_vmu)
end if
m.p_storage.cs_vhi("lastActivityTime",str(comscore_unix_time()))
end function
cs_vxw.dispatch=function(cs_vmu as object)as void
m.cs_vfs=m.cs_vfs+1
cs_vmu.labels["ns_ap_ec"]=comscore_tostr(m.cs_vfs)
cs_vcd=cs_vgs(cs_vmu)
cs_vcd.cs_vgv()
end function
cs_vxw.cs_vce=function(cs_vfj as string)as string
cs_vfj=cs_vfj+m.cs_vca
cs_vfk=createobject("roByteArray")
cs_vfk.fromasciistring(cs_vfj)
cs_vfl=createobject("roEVPDigest")
cs_vfl.setup("md5")
cs_vfl.update(cs_vfk)
return cs_vfl.final()
end function
cs_vxw.cs_vci=function()as double
if m.cs_vcl<0 then
if m.p_storage.cs_vhh("installTime")then
cs_vck=comscore_stod(m.p_storage.cs_vhg("installTime"))
else
cs_vck=m.p_genesis
m.p_storage.cs_vhi("installTime",str(cs_vck))
end if
m.cs_vcl=cs_vck
end if
return m.cs_vcl
end function
cs_vxw.cs_vcm=function()as double
if m.cs_vcp<0 then
cs_vco=0
if m.p_storage.cs_vhh("installTime")then
cs_vco=comscore_stod(m.p_storage.cs_vhg("previousGenesis"))
end if
m.cs_vcp=cs_vco
end if
return m.cs_vcp
end function
cs_vxw.cs_vcq=function()as void
cs_vcr=comscore_unix_time()
if cs_vcr-m.p_genesis>m.cs_ve then
m.p_storage.cs_vhi("previousGenesis",str(m.p_genesis))
m.p_genesis=cs_vcr
m.p_storage.cs_vhi("genesis",str(m.p_genesis))
end if
end function
cs_vdh(cs_vxw)
cs_vxw.p_storage=cs_vhd(cs_vxw)
cs_vxw.p_genesis=comscore_unix_time()
cs_vxw.p_keepalive=cs_vee(cs_vxw)
cs_vxw.cs_vci()
cs_vda(cs_vxw)
cs_vdx(cs_vxw)
if cs_vxw.p_storage.cs_vhh("accumulatedForegroundTime")then
cs_vxw.cs_vcs=comscore_stoi(cs_vxw.p_storage.cs_vhg("accumulatedForegroundTime"))
end if
if cs_vxw.p_storage.cs_vhh("totalForegroundTime")then
cs_vxw.cs_vct=comscore_stoi(cs_vxw.p_storage.cs_vhg("totalForegroundTime"))
end if
if cs_vxw.p_storage.cs_vhh("visitorId")then
cs_vxw.cs_vcu=cs_vxw.p_storage.cs_vhg("visitorId")
end if
if cs_vxw.p_storage.cs_vhh("currentVersion")then
if cs_vxw.p_storage.cs_vhg("currentVersion")<>cs_vxw.cs_vh then
cs_vxw.p_storage.cs_vhi("previousVersion",cs_vxw.p_storage.cs_vhg("currentVersion"))
cs_vxw.p_storage.cs_vhi("currentVersion",cs_vxw.cs_vh)
cs_vxw.cs_vcx=cs_vxw.cs_vh
else
cs_vxw.cs_vcx=cs_vxw.p_storage.cs_vhg("currentVersion")
end if
else
cs_vxw.p_storage.cs_vhi("currentVersion",cs_vxw.cs_vh)
cs_vxw.cs_vcx=cs_vxw.cs_vh
end if
if cs_vxw.p_storage.cs_vhh("previousVersion")then
cs_vxw.cs_vcz=cs_vxw.p_storage.cs_vhg("previousVersion")
else
cs_vxw.p_storage.cs_vhi("previousVersion",cs_vxw.cs_vcx)
cs_vxw.cs_vcz=cs_vxw.cs_vcx
end if
cs_vxw.cs_vj.mark()
cs_vxw.cs_vk.mark()
cs_vxw.cs_vi.mark()
if cs_vxw.adframeworkavailable()=true then
cs_vxw.setuseraf(true)
cs_vxw.setuserafsettermethods(true)
end if
return cs_vxw
end function
sub cs_vda(dax as object)
cs_vdb=dax.p_storage
cs_vdd=0
if cs_vdb.cs_vhh("lastActivityTime")then cs_vdd=comscore_stod(cs_vdb.cs_vhg("lastActivityTime"))
cs_vdf=0
if cs_vdb.cs_vhh("genesis")then cs_vdf=comscore_stod(cs_vdb.cs_vhg("genesis"))
if(cs_vdd>0)then
cs_vdg=comscore_unix_time()-cs_vdd
if cs_vdg<dax.cs_ve then
if cs_vdf>0 and cs_vdf<comscore_unix_time()then
dax.p_genesis=cs_vdf
end if
else
cs_vdb.cs_vhi("previousGenesis",str(cs_vdf))
end if
end if
cs_vdb.cs_vhi("genesis",str(dax.p_genesis))
cs_vdb.cs_vhi("lastActivityTime",str(comscore_unix_time()))
end sub
sub cs_vdh(dax as object)
cs_vdi=readasciifile("pkg:/manifest")
title="AppName"
cs_vdr="1"
cs_vds="0"
cs_vdt="0"
adframeworkavailable=false
cs_vfj=cs_vdi.tokenize(chr(10))
for each cs_vdo in cs_vfj
cs_vdo=cs_vdo.trim()
if len(cs_vdo)>0 then
cs_vdp=cs_vdo.tokenize("=")
if cs_vdp.count()=2 then
if cs_vdp[0]= "title" then
title=cs_vdp[1]
else if cs_vdp[0]= "major_version" then
cs_vdr=cs_vdp[1]
else if cs_vdp[0]= "minor_version" then
cs_vds=cs_vdp[1]
else if cs_vdp[0]= "build_version" then
cs_vdt=cs_vdp[1]
else if cs_vdp[0]= "bs_libs_required" and cs_vdp[1]= "roku_ads_lib" then
adframeworkavailable=true
end if
end if
end if
end for
dax.cs_vdu=title
dax.cs_vdv=cs_vdr+"." +cs_vds+"." +cs_vdt
dax.cs_vdw=adframeworkavailable
end sub
sub cs_vdx(dax as object)
cs_vdy=dax.p_storage
if(cs_vdy.cs_vhh("runs"))then
cs_vdz=comscore_tostr(comscore_stoi(cs_vdy.cs_vhg("runs"))+1)
cs_vdy.cs_vhi("runs",cs_vdz)
else
cs_vdy.cs_vhi("runs","0")
end if
end sub
function cseventtype()
if m.cs_veb=invalid then m.cs_veb=cs_vec()
return m.cs_veb
end function
function cs_vec()as object
cs_vsv=createobject("roAssociativeArray")
cs_vsv.view="view"
cs_vsv.hidden="hidden"
cs_vsv.start="start"
cs_vsv.aggregate="aggregate"
cs_vsv.close="close"
cs_vsv.keep_alive="keep-alive"
return cs_vsv
end function
function cs_vee(dax as object)as object
cs_vxw=createobject("roAssociativeArray")
cs_vxw.cs_veg=createobject("roTimespan")
cs_vxw.cs_veh=createobject("roDeviceInfo")
cs_vxw.cs_vei=createobject("roArray",1,true)
cs_vxw.cs_vqa=dax
cs_vek=cs_vxw.cs_veh.getipaddrs()
if cs_vek<>invalid then
for each key in cs_vek
cs_vxw.cs_vei.push(cs_vek[key])
end for
end if
cs_vxw.reset=function()as void
m.cs_veg.mark()
end function
cs_vxw.tick=function()as void
if m.cs_vqa.cs_vba()then
if m.cs_veg.totalmilliseconds()>m.cs_vqa.cs_viv then
m.cs_vqa.notify(cseventtype().keep_alive)
m.cs_veg.mark()
else
cs_ver=false
cs_ven=m.cs_veh.getipaddrs()
if cs_ven<>invalid then
for each key in cs_ven
cs_veq=false
for cs_vyh=0 to m.cs_vei.count()step 1
if m.cs_vei[cs_vyh]=cs_ven[key]then
cs_veq=true
exit for
end if
end for
if cs_veq then
else
m.cs_vei.push(cs_ven[key])
cs_ver=true
end if
end for
if cs_ver then
m.cs_vqa.notify(cseventtype().keep_alive)
m.cs_veg.mark()
end if
end if
end if
end if
end function
if dax.cs_vba()then
cs_vxw.cs_veg.mark()
else
end if
return cs_vxw
end function
function cs_ves(dax as object,cs_vud as string,pixelurl as string,labels as object)as object
dax.cs_vcq()
if cs_vud=cseventtype().start then return cs_vgb(dax,cs_vud,pixelurl,labels)
if cs_vud=cseventtype().aggregate then return cs_vgq(dax,cs_vud,pixelurl,labels)
return csapplicationmeasurement(dax,cs_vud,pixelurl,labels)
end function
function csmeasurement(dax as object)as object
cs_vxw=createobject("roAssociativeArray")
cs_vxw.labels=createobject("roAssociativeArray")
cs_vxw.setpixelurl=function(pixelurl as string)as void
cs_vew=instr(1,pixelurl,"?")
if cs_vew>=1 and len(pixelurl)>cs_vew then
m.labels["name"]=right(pixelurl,len(pixelurl)-cs_vew)
m.pixelurl=left(pixelurl,cs_vew)
else
m.pixelurl=pixelurl
end if
end function
cs_vxw.setpixelurl(dax.pixelurl())
cs_vxw.cs_vex=comscore_unix_time()
cs_vxw.cs_vey=function()as string
cs_vkd=""
cs_vfb=createobject("roArray",110,true)
cs_vfb=["c1","c2","ca2","cb2","cc2","cd2","ns_site","ca_ns_site","cb_ns_site","cc_ns_site","cd_ns_site","ns_vsite","ca_ns_vsite","cb_ns_vsite","cc_ns_vsite","cd_ns_vsite","ns_alias","ca_ns_alias","cb_ns_alias","cc_ns_alias","cd_ns_alias","ns_ap_an","ca_ns_ap_an","cb_ns_ap_an","cc_ns_ap_an","cd_ns_ap_an","ns_ap_pn","ns_ap_pv","c12","ca12","cb12","cc12","cd12","ns_ak","ns_ap_hw","name","ns_ap_ni","ns_ap_ec","ns_ap_ev","ns_ap_device","ns_ap_id","ns_ap_csf","ns_ap_bi","ns_ap_pfm","ns_ap_pfv","ns_ap_ver","ca_ns_ap_ver","cb_ns_ap_ver","cc_ns_ap_ver","cd_ns_ap_ver","ns_ap_sv","ns_ap_bv","ns_ap_cv","ns_ap_smv","ns_type","ca_ns_type","cb_ns_type","cc_ns_type","cd_ns_type","ns_radio","ns_nc","cs_partner","cs_xcid","cs_impid","ns_ap_ui","ca_ns_ap_ui","cb_ns_ap_ui","cc_ns_ap_ui","cd_ns_ap_ui","ns_ap_gs","ns_ap_ie","ns_st_sv","ns_st_pv","ns_st_smv","ns_st_it","ns_st_id","ns_st_ec","ns_st_sp","ns_st_sc","ns_st_psq","ns_st_asq","ns_st_sq","ns_st_ppc","ns_st_apc","ns_st_spc","ns_st_atpc","ns_st_cn","ns_st_ev","ns_st_po","ns_st_cl","ns_st_el","ns_st_sl","ns_st_pb","ns_st_hc","ns_st_mp","ca_ns_st_mp","cb_ns_st_mp","cc_ns_st_mp","cd_ns_st_mp","ns_st_mv","ca_ns_st_mv","cb_ns_st_mv","cc_ns_st_mv","cd_ns_st_mv","ns_st_pn","ns_st_tp","ns_st_ad","ns_st_li","ns_st_ci","ns_st_si","ns_st_pt","ns_st_dpt","ns_st_ipt","ns_st_ap","ns_st_dap","ns_st_et","ns_st_det","ns_st_upc","ns_st_dupc","ns_st_iupc","ns_st_upa","ns_st_dupa","ns_st_iupa","ns_st_lpc","ns_st_dlpc","ns_st_lpa","ns_st_dlpa","ns_st_pa","ns_st_ldw","ns_st_ldo","ns_st_ie","ns_ap_jb","ns_ap_et","ns_ap_res","ns_ap_sd","ns_ap_po","ns_ap_ot","ns_ap_c12m","cs_c12u","ca_cs_c12u","cb_cs_c12u","cc_cs_c12u","cd_cs_c12u","ns_ap_install","ns_ap_updated","ns_ap_lastrun","ns_ap_cs","ns_ap_runs","ns_ap_usage","ns_ap_fg","ns_ap_ft","ns_ap_dft","ns_ap_bt","ns_ap_dbt","ns_ap_dit","ns_ap_as","ns_ap_das","ns_ap_it","ns_ap_uc","ns_ap_aus","ns_ap_daus","ns_ap_us","ns_ap_dus","ns_ap_ut","ns_ap_oc","ns_ap_uxc","ns_ap_uxs","ns_ap_lang","ns_ap_ar","ns_ap_miss","ns_ts","ns_ap_cfg","ns_ap_env","ns_st_ca","ns_st_cp","ns_st_er","ca_ns_st_er","cb_ns_st_er","cc_ns_st_er","cd_ns_st_er","ns_st_pe","ns_st_ui","ca_ns_st_ui","cb_ns_st_ui","cc_ns_st_ui","cd_ns_st_ui","ns_st_bc","ns_st_dbc","ns_st_bt","ns_st_dbt","ns_st_bp","ns_st_lt","ns_st_skc","ns_st_dskc","ns_st_ska","ns_st_dska","ns_st_skd","ns_st_skt","ns_st_dskt","ns_st_pc","ns_st_dpc","ns_st_pp","ns_st_br","ns_st_pbr","ns_st_rt","ns_st_prt","ns_st_ub","ns_st_vo","ns_st_pvo","ns_st_ws","ns_st_pws","ns_st_ki","ns_st_rp","ns_st_bn","ns_st_tb","ns_st_an","ns_st_ta","ns_st_pl","ns_st_pr","ns_st_tpr","ns_st_sn","ns_st_en","ns_st_ep","ns_st_tep","ns_st_sr","ns_st_ty","ns_st_ct","ns_st_cs","ns_st_ge","ns_st_st","ns_st_stc","ns_st_ce","ns_st_ia","ns_st_dt","ns_st_ddt","ns_st_tdt","ns_st_tm","ns_st_dtm","ns_st_ttm","ns_st_de","ns_st_pu","ns_st_ti","ns_st_cu","ns_st_fee","ns_st_ft","ns_st_at","ns_st_pat","ns_st_vt","ns_st_pvt","ns_st_tt","ns_st_ptt","ns_st_cdn","ns_st_pcdn","ns_st_amg","ns_st_ami","ns_st_amp","ns_st_amt","ns_st_ams","ns_ap_i1","ns_ap_i2","ns_ap_i3","ns_ap_i4","ns_ap_i5","ns_ap_i6","ns_ap_referrer","ns_clid","ns_campaign","ns_source","ns_mchannel","ns_linkname","ns_fee","gclid","utm_campaign","utm_source","utm_medium","utm_term","utm_content","ns_ecommerce","ns_ec_sv","ns_client_id","ns_order_id","ns_ec_cur","ns_orderline_id","ns_orderlines","ns_prod_id","ns_qty","ns_prod_price","ns_prod_grp","ns_brand","ns_shop","ns_category","category","ns_c","ns_search_term","ns_search_result","ns_m_exp","ns_m_chs","c3","ca3","cb3","cc3","cd3","c4","ca4","cb4","cc4","cd4","c5","ca5","cb5","cc5","cd5","c6","ca6","cb6","cc6","cd6","c10","c11","c13","c14","c15","c16","c7","c8","c9","ns_ap_er","ns_st_amc"]
cs_vfc={}
for each label in cs_vfb
if m.labels[label]<>invalid then
cs_vkd=cs_vkd+"&" +comscore_url_encode(label)+ "=" +comscore_url_encode(m.labels[label])
cs_vfc.addreplace(label,true)
end if
end for
for each key in m.labels
if m.labels[key]<>invalid and cs_vfc[key]=invalid then
cs_vkd=cs_vkd+"&" +comscore_url_encode(key)+ "=" +comscore_url_encode(m.labels[key])
end if
end for
if len(cs_vkd)>0 then
return right(cs_vkd,len(cs_vkd)-1)
else
return cs_vkd
end if
end function
return cs_vxw
end function
function cs_vff(dax as object,cs_vud as string,pixelurl as string,labels as object)as object
cs_vxw=csmeasurement(dax)
di=createobject("roDeviceInfo")
if pixelurl<>invalid and pixelurl<>"" then cs_vxw.setpixelurl(pixelurl)
cs_vxw.labels["c1"]= "19"
cs_vxw.labels["ns_ap_an"]=dax.appname()
cs_vxw.labels["ns_ap_pn"]= "roku"
if dax.version()<>dax.previousversion()or(dax.p_storage.cs_vhh("runs")=true and comscore_stoi(dax.p_storage.cs_vhg("runs"))=0)then
cs_vxw.labels["c12"]=dax.visitorid()
else
visitorid=""
if dax.p_storage.cs_vhh("visitorId")then
visitorid=dax.p_storage.cs_vhg("visitorId")
else
di=createobject("roDeviceInfo")
cs_vfj=di.getdeviceuniqueid()+dax.cs_vca
cs_vfk=createobject("roByteArray")
cs_vfk.fromasciistring(cs_vfj)
cs_vfl=createobject("roEVPDigest")
cs_vfl.setup("md5")
cs_vfl.update(cs_vfk)
visitorid=cs_vfl.final()
dax.p_storage.cs_vhi("visitorId",visitorid)
end if
cs_vxw.labels["c12"]=visitorid
end if
if findmemberfunction(di,"GetDeviceUniqueId")<>invalid then
cs_vfm=createobject("roByteArray")
cs_vfm.fromasciistring(di.getdeviceuniqueid())
cs_vfn=createobject("roEVPDigest")
cs_vfn.setup("md5")
cs_vfn.update(cs_vfm)
cs_vxw.labels["ns_ap_i1"]=cs_vfn.final()
cs_vfo=createobject("roEVPDigest")
cs_vfo.setup("sha1")
cs_vfo.update(cs_vfm)
cs_vxw.labels["ns_ap_i6"]=cs_vfo.final()
end if
if findmemberfunction(di,"IsAdIdTrackingDisabled")<>invalid and findmemberfunction(di,"GetAdvertisingId")<>invalid then
if di.isadidtrackingdisabled()=false then
cs_vfp=createobject("roByteArray")
cs_vfp.fromasciistring(di.getadvertisingid())
cs_vfq=createobject("roEVPDigest")
cs_vfq.setup("md5")
cs_vfq.update(cs_vfp)
cs_vxw.labels["ns_ap_i3"]=cs_vfq.final()
cs_vfr=createobject("roEVPDigest")
cs_vfr.setup("sha1")
cs_vfr.update(cs_vfp)
cs_vxw.labels["ns_ap_i5"]=cs_vfr.final()
end if
end if
cs_vxw.labels["ns_ap_device"]=di.getmodel()
cs_vxw.labels["ns_ap_as"]=comscore_tostr(dax.p_genesis)
cs_vxw.labels["ns_type"]=cs_vud
cs_vxw.labels["ns_ap_ev"]=cs_vud
cs_vxw.labels["ns_ts"]=comscore_tostr(cs_vxw.cs_vex)
cs_vxw.labels["ns_ap_pfv"]=di.getversion()
cs_vxw.labels["ns_nc"]= "1"
if(labels["ns_st_ev"]=invalid)then
if dax.cs_vfs=0 then
if dax.cs_vct>0 then
cs_vxw.labels["ns_ap_dft"]=comscore_tostr(dax.cs_vcs)
cs_vxw.labels["ns_ap_ft"]=comscore_tostr(dax.cs_vct)
end if
else
cs_vxw.labels["ns_ap_dft"]=comscore_tostr(dax.cs_vj.totalmilliseconds())
cs_vxw.labels["ns_ap_ft"]=comscore_tostr(dax.cs_vk.totalmilliseconds())
end if
end if
cs_vft=dax.getlabels()
for each key in cs_vft
cs_vxw.labels[key]=cs_vft[key]
end for
for each key in labels
cs_vxw.labels[key]=labels[key]
end for
return cs_vxw
end function
function csapplicationmeasurement(dax as object,cs_vud as string,pixelurl as string,labels as object)as object
cs_vfx=cseventtype().hidden
if cs_vud=cseventtype().start or cs_vud=cseventtype().view then cs_vfx=cseventtype().view
cs_vxw=cs_vff(dax,cs_vfx,pixelurl,labels)
cs_vxw.labels["ns_ap_ev"]=cs_vud
cs_vxw.labels["ns_ap_ver"]=dax.appversion()
di=createobject("roDeviceInfo")
if comscore_is26()then
cs_vga=di.getdisplaysize()
cs_vxw.labels["ns_ap_res"]=stri(cs_vga.w).trim()+ "x" +stri(cs_vga.h).trim()
end if
if comscore_is43()then cs_vxw.labels["ns_ap_lang"]=di.getcurrentlocale()
cs_vxw.labels["ns_ap_sv"]=dax.version()
cs_vxw.labels["ns_ap_smv"]= "2.10"
return cs_vxw
end function
function cs_vgb(dax as object,cs_vud as string,pixelurl as string,labels as object)as object
cs_vxw=csapplicationmeasurement(dax,cs_vud,pixelurl,labels)
cs_vxw.labels["ns_ap_install"]= "yes"
cs_vxw.labels["ns_ap_runs"]=dax.p_storage.cs_vhg("runs")
cs_vxw.labels["ns_ap_gs"]=comscore_tostr(dax.cs_vci())
cs_vxw.labels["ns_ap_lastrun"]=comscore_tostr(dax.cs_vcm())
cs_vgp=""
if dax.cs_vge=true then
cs_vgp=cs_vgp+"1"
else
cs_vgp=cs_vgp+"0"
end if
if dax.cs_vgh=true then
cs_vgp=cs_vgp+"1"
else
cs_vgp=cs_vgp+"0"
end if
if dax.cs_vgk=true then
cs_vgp=cs_vgp+"1"
else
cs_vgp=cs_vgp+"0"
end if
if dax.cs_vgn=true then
cs_vgp=cs_vgp+"1"
else
cs_vgp=cs_vgp+"0"
end if
cs_vxw.labels["ns_ap_cfg"]=cs_vgp
return cs_vxw
end function
function cs_vgq(dax as object,cs_vud as string,pixelurl as string,labels as object)as object
cs_vxw=csapplicationmeasurement(dax,cs_vud,pixelurl,labels)
return cs_vxw
end function
function cs_vgs(cs_vmu as object)as object
cs_vxw=createobject("roAssociativeArray")
cs_vxw.cs_vmu=cs_vmu
cs_vxw.cs_vgv=function()as object
cs_vgw=createobject("roUrlTransfer")
m.cs_vgx=createobject("roMessagePort")
cs_vgw.setport(m.cs_vgx)
cs_vgw.setcertificatesfile("common:/certs/ca-bundle.crt")
cs_vgw.enableencodings(true)
cs_vgw.addheader("Expect","")
url=m.cs_vmu.pixelurl+m.cs_vmu.cs_vey()
if cscomscore().log_debug then print"Dispatching: " +url
cs_vgw.seturl(url)
cs_vgw.setrequest("GET")
m.dispatch(cs_vgw)
cscomscore().cs_vbc()
if(m.cs_vmu.labels["ns_st_ev"]=invalid)then
cscomscore().cs_vbd()
end if
end function
cs_vxw.dispatch=function(cs_vgw as object)
if(cs_vgw.asyncgettostring())then wait(500,cs_vgw.getport())
end function
return cs_vxw
end function
function comscoresgbridge(cs_vwe as object)as object
cs_vxw=createobject("roAssociativeArray")
cs_vxw.cs_vwe=cs_vwe
cs_vxw.comscoretask=function()as object
return m.cs_vwe
end function
cs_vxw.setcustomerc2=function(c2 as string)as void
m.cs_vwg("SetCustomerC2",[c2])
end function
cs_vxw.setpublishersecret=function(salt as string)as void
m.cs_vwg("SetPublisherSecret",[salt])
end function
cs_vxw.start=function(labels=invalid as object)as void
m.cs_vwg("Start",[labels])
end function
cs_vxw.view=function(labels=invalid as object)as void
m.cs_vwg("View",[labels])
end function
cs_vxw.hidden=function(labels=invalid as object)as void
m.cs_vwg("Hidden",[labels])
end function
cs_vxw.close=function(labels=invalid as object)as void
m.cs_vwg("Close",[labels])
end function
cs_vxw.tick=function()as void
m.cs_vwg("Tick",invalid)
end function
cs_vxw.setpixelurl=function(cs_vvw as string)as void
m.cs_vwg("SetPixelURL",[cs_vvw])
end function
cs_vxw.setsecure=function(secure as boolean)as void
m.cs_vwg("SetSecure",[secure])
end function
cs_vxw.setlabels=function(cs_vtw as object)as void
m.cs_vwg("SetLabels",[cs_vtw])
end function
cs_vxw.setlabel=function(key as string,cs_vvw as string)as void
m.cs_vwg("SetLabel",[key,cs_vvw])
end function
cs_vxw.setappname=function(name as string)as void
m.cs_vwg("SetAppName",[name])
end function
cs_vxw.setappversion=function(version as string)as void
m.cs_vwg("SetAppVersion",[version])
end function
cs_vxw.cs_vwg=function(name as string,args)
cs_vwh={}
cs_vwh["component"]= "app"
cs_vwh["methodName"]=name
cs_vwh["args"]=args
m.cs_vwe["apiCall"]=cs_vwh
end function
return cs_vxw
end function
function cs_vhd(context as object)as object
cs_vxw=createobject("roAssociativeArray")
cs_vxw.cs_vhf=createobject("roRegistrySection","com.comscore." +context.appname()+ "-2")
cs_vxw.cs_vhg=function(key)as string
if m.cs_vhf.exists(key)then return m.cs_vhf.read(key)
return""
end function
cs_vxw.cs_vhh=function(key)as boolean
return m.cs_vhf.exists(key)
end function
cs_vxw.cs_vhi=function(key,val)as void
m.cs_vhf.write(key,val)
m.cs_vhf.flush()
end function
cs_vxw.cs_vhj=function(key)as void
m.cs_vhf.delete(key)
m.cs_vhf.flush()
end function
return cs_vxw
end function
function comscore_is26()as boolean
if m.cs_vho=invalid then
di=createobject("roDeviceInfo")

'cs_vld=eval("country=di.GetCountryCode()")
country=di.GetCountryCode()
cs_vld = 252

if cs_vld=252
m.cs_vho=true
else
m.cs_vho=false
end if
end if
return m.cs_vho
end function
function comscore_is43()as boolean
if m.cs_vht=invalid then
di=createobject("roDeviceInfo")

'cs_vld=eval("locale=di.GetCurrentLocale()")
locale=di.GetCurrentLocale()
cs_vld = 252

if cs_vld=252
m.cs_vht=true
else
m.cs_vht=false
end if
end if
return m.cs_vht
end function
function comscore_unix_time()as double
if m.cs_vhv=invalid then
m.cs_vhv=createobject("roAssociativeArray")
m.cs_vhv.cs_vhw=createobject("roTimespan")
cs_vzg=createobject("roDateTime")
cs_vzg.mark()
m.cs_vhv.offset#=cs_vzg.asseconds()*1000#
m.cs_vhv.cs_vhw.mark()
end if
m.p_csmillis#=m.cs_vhv.cs_vhw.totalmilliseconds()
return m.cs_vhv.offset#+m.p_csmillis#
end function
function comscore_tostr(obj as object)as string
cs_vig=type(obj)
if cs_vig="String" or cs_vig="roString" then return obj
if cs_vig="Integer" or cs_vig="roInt" then return stri(obj).trim()
if cs_vig="Double" or cs_vig="roIntrinsicDouble" or cs_vig="Float" or cs_vig="roFloat" then
num#=obj
mil#=1000000
if abs(num#)<=mil#then return str(num#).trim()
cs_vii=int(num#/mil#)
if num#/mil#-cs_vii<0 then cs_vii=cs_vii-1
cs_vij=int((num#-mil#*cs_vii))
cs_vik=cs_vii.tostr()
cs_vil=string(6-cs_vij.tostr().len(),"0")+cs_vij.tostr()
return cs_vik+cs_vil
end if
return"UNKN" +cs_vig
end function
function comscore_stod(obj as string)as double
len=obj.len()
if len<=6 then
cs_vkd#=val(obj)
return cs_vkd#
end if
left=obj.left(len-6)
right=obj.right(6)
left#=val(left)
right#=val(right)
mil#=1000000
cs_vkd#=left#*mil#+right#
return cs_vkd#
end function
function comscore_stoi(obj as string)as integer
return int(val(obj))
end function
function comscore_url_encode(cs_vfj as string)as string
if m.cs_vin=invalid then m.cs_vin=createobject("roUrlTransfer")
return m.cs_vin.urlencode(cs_vfj)
end function
function comscore_extend(toobject as object,fromobject as object)
if toobject<>invalid and fromobject<>invalid and type(toobject)= "roAssociativeArray" and type(fromobject)= "roAssociativeArray" then
for each key in fromobject
toobject.addreplace(key,fromobject[key])
end for
end if
end function
function csstreamsense(dax=invalid as object)as object
cs_vxw=createobject("roAssociativeArray")
onstatechange=invalid
labels=invalid
cs_vxw.cs_vip="roku"
cs_vxw.cs_viq="4.1503.03"
cs_vxw.cs_vir=500#
cs_vxw.cs_vis=10#*1000#
cs_vxw.cs_vit=60#*1000#
cs_vxw.cs_viu=6
cs_vxw.cs_viv=1200000#
cs_vxw.cs_viw=500#
cs_vxw.cs_vix=1500
cs_vxw.cs_vqa=invalid
cs_vxw.cs_vqb=invalid
cs_vxw.p_pixelurl=""
cs_vxw.cs_vpl=0#
cs_vxw.cs_vou=0#
cs_vxw.cs_vpk=invalid
cs_vxw.cs_vnu=0
cs_vxw.cs_vqc=invalid
cs_vxw.cs_vkp=true
cs_vxw.cs_voy=true
cs_vxw.cs_vnw=-1#
cs_vxw.cs_vnf=0
cs_vxw.cs_vng=-1#
cs_vxw.cs_vnc=-1#
cs_vxw.cs_vnn=-1#
cs_vxw.cs_vpf=invalid
cs_vxw.cs_voa=invalid
cs_vxw.cs_vly=invalid
cs_vxw.cs_vka=invalid
cs_vxw.cs_vjx=invalid
cs_vxw.cs_vmp=""
cs_vxw.cs_vmr=""
cs_vxw.cs_vkr=false
cs_vxw.cs_vmk=-1#
cs_vxw.cs_vml=invalid
cs_vxw.cs_vmm=invalid
cs_vxw.engageto=function(screen as object)as void
m.reset()
m.cs_vjx=screen
screen.cs_vlz=m
cs_vjz={}
cs_vjz["ns_st_cu"]=screen.cs_vws.streamurls[0]
if screen.cs_vws.title<>invalid then cs_vjz["ns_st_ep"]=screen.cs_vws.title
m.setclip(cs_vjz)
m.cs_vka=createobject("roTimespan")
end function
cs_vxw.onplayerevent=function(cs_vwu as object)as boolean
cs_vkd=false
m.cs_vqa.tick()
if cs_vwu=invalid then
if m.getstate()=csstreamsensestate().playing and m.cs_vka.totalmilliseconds()>m.cs_vix then
m.notify(csstreamsenseeventtype().pause)
else
m.tick()
end if
else if comscore_is26()and cs_vwu.ispaused()then
m.notify(csstreamsenseeventtype().pause)
else if comscore_is26()and cs_vwu.isstreamstarted()then
m.notify(csstreamsenseeventtype().buffer)
else if cs_vwu.isplaybackposition()then
m.notify(csstreamsenseeventtype().play,cs_vwu.getindex()*1000)
m.cs_vka.mark()
else if cs_vwu.isscreenclosed()or cs_vwu.isfullresult()or cs_vwu.ispartialresult()or cs_vwu.isrequestfailed()then
m.notify(csstreamsenseeventtype().end)
cs_vkd=true
end if
return cs_vkd
end function
cs_vxw.tick=function()as void
cs_vzg=comscore_unix_time()
if m.cs_vnc>=0 and m.cs_vnc<=cs_vzg then
m.cs_vne()
end if
if m.cs_vnn>=0 and m.cs_vnn<=cs_vzg then
m.cs_vnl()
end if
if m.cs_vnw>=0 and m.cs_vnw<=cs_vzg then
m.cs_vns()
end if
if m.cs_vmk>=0 and m.cs_vmk<=cs_vzg then
m.cs_vma(m.cs_vml,m.cs_vmm)
end if
end function
cs_vxw.isidle=function()as boolean
return m.getstate()=csstreamsensestate().idle
end function
cs_vxw.setpixelurl=invalid
cs_vxw.pixelurl=invalid
cs_vxw.notify=function(cs_vud as object,position=-1#as double,eventlabelmap=invalid as object)as void
cs_voz=m.cs_voe(cs_vud)
cs_vmg=createobject("roAssociativeArray")
if eventlabelmap<>invalid then cs_vmg.append(eventlabelmap)
m.cs_vnx(cs_vmg)
if not cs_vmg.doesexist("ns_st_po")then
cs_vmg["ns_st_po"]=comscore_tostr(position)
end if
if cs_vud=csstreamsenseeventtype().play or cs_vud=csstreamsenseeventtype().pause or cs_vud=csstreamsenseeventtype().buffer or cs_vud=csstreamsenseeventtype().end then
if m.ispauseplayswitchdelayenabled()and m.cs_vob(m.cs_vpk)and m.cs_vob(cs_voz)and not(m.cs_vpk=csstreamsensestate().playing and cs_voz=csstreamsensestate().paused and m.cs_vmm=invalid)then
m.cs_vma(cs_voz,cs_vmg,m.cs_vir)
else
m.cs_vma(cs_voz,cs_vmg)
end if
else
if m.cs_vpg(cs_vmg)<0 then
cs_vmg["ns_st_po"]=comscore_tostr(m.cs_vpa(m.cs_vph(cs_vmg)))
end if
labels=m.cs_vpm(cs_vud,cs_vmg)
labels.append(cs_vmg)
m.dispatch(labels,false)
m.cs_vnu=m.cs_vnu+1
end if
end function
cs_vxw.getlabels=function()as object
return m.cs_vqb
end function
cs_vxw.sharingsdkpersistentlabels=function()as boolean
return m.cs_vkp
end function
cs_vxw.sharesdkpersistentlabels=function(flag as boolean)
m.cs_vkp=flag
end function
cs_vxw.ispauseonbufferingenabled=function()as boolean
return m.cs_voy
end function
cs_vxw.setpauseonbufferingenabled=function(pauseonbufferingenabled as boolean)
m.cs_voy=pauseonbufferingenabled
end function
cs_vxw.ispauseplayswitchdelayenabled=function()as boolean
return m.cs_vkr
end function
cs_vxw.setpauseplayswitchdelayenabled=function(pauseplayswitchdelayenabled as boolean)as void
m.cs_vkr=pauseplayswitchdelayenabled
end function
cs_vxw.setclip=function(labels as object,loop=false as boolean)as boolean
cs_vld=false
if m.cs_vpk=csstreamsensestate().idle then
m.cs_vqc.getclip().reset()
m.cs_vqc.getclip().setlabels(labels,invalid)
if loop=true then
m.cs_vqc.cs_vuk()
end if
if m.cs_vqa.useraf()=true and m.cs_vqa.userafsettermethods()=true and m.cs_vky(labels)=true then
if labels["ns_st_ci"]<>invalid and labels["ns_st_ci"]<>"*null" then
m.cs_vkv(labels["ns_st_ci"])
else
m.cs_vkv("")
end if
if labels["ns_st_ge"]<>invalid and labels["ns_st_ge"]<>"*null" then
m.cs_vkw(labels["ns_st_ge"],false)
else
m.cs_vkw("",false)
end if
if labels["ns_st_cl"]<>invalid and labels["ns_st_cl"]<>"*null" then
m.cs_vkx(int(comscore_stoi(labels["ns_st_cl"])/1000))
else
m.cs_vkx(0)
end if
end if
cs_vld=true
end if
return cs_vld
end function
cs_vxw.cs_vkv=function(id as string)as void
if m.cs_vqa.useraf()=true and m.cs_vqa.userafsettermethods()=true and m.cs_vqa.adinterface()<>invalid then
m.cs_vqa.adinterface().setcontentid(id)
if m.cs_vqa.log_debug then print"Content Id successfully set with value " +id
end if
end function
cs_vxw.cs_vkw=function(genres as string,kidscontent as boolean)as void
if m.cs_vqa.useraf()=true and m.cs_vqa.userafsettermethods()=true and m.cs_vqa.adinterface()<>invalid then
m.cs_vqa.adinterface().setcontentgenre(genres,kidscontent)
if m.cs_vqa.log_debug then print"Genre successfully set with value " +genres
end if
end function
cs_vxw.cs_vkx=function(length as integer)as void
if m.cs_vqa.useraf()=true and m.cs_vqa.userafsettermethods()=true and m.cs_vqa.adinterface()<>invalid then
m.cs_vqa.adinterface().setcontentlength(length)
if m.cs_vqa.log_debug then print"Content Length successfully set with value " +comscore_tostr(length)
end if
end function
cs_vxw.cs_vky=function(labels as object)as boolean
cs_vld=false
if labels=invalid then
return true
end if
if labels["ns_st_ad"]=invalid or(labels["ns_st_ad"]<>invalid and(labels["ns_st_ad"]= "pre-roll" or labels["ns_st_ct"]= "aa11" or labels["ns_st_ct"]= "aa31" or labels["ns_st_ct"]= "va11" or labels["ns_st_ct"]= "va31"))then
cs_vld=true
end if
return cs_vld
end function
cs_vxw.setplaylist=function(labels as object)as boolean
cs_vld=false
if m.cs_vpk=csstreamsensestate().idle then
m.cs_vqc.cs_vvg()
m.cs_vqc.reset()
m.cs_vqc.getclip().reset()
m.cs_vqc.setlabels(labels,invalid)
cs_vld=true
end if
return cs_vld
end function
cs_vxw.importstate=function(labels as object)as void
m.reset()
cs_vle=createobject("roAssociativeArray")
cs_vle.append(labels)
m.cs_vqc.cs_vvl(cs_vle,invalid)
m.cs_vqc.getclip().cs_vvl(cs_vle,invalid)
m.cs_vvl(cs_vle)
m.cs_vnu=m.cs_vnu+1
end function
cs_vxw.exportstate=function()as object
return m.cs_voa
end function
cs_vxw.getversion=function()as string
return m.cs_viq
end function
cs_vxw.addlistener=function(cs_vlh as object)as void
if cs_vlh=invalid or cs_vlh.onstatechange=invalid then return
m.cs_vly.push(cs_vlh)
end function
cs_vxw.removelistener=function(cs_vlh as object)as void
if cs_vlh=invalid or cs_vlh.onstatechange=invalid then return
if m.cs_vly.count()>0 then
cs_vlj=0
while cs_vlj<m.cs_vly.count()
if cs_vlh.onstatechange=m.cs_vly[cs_vlj].onstatechange then exit while
cs_vlj=cs_vlj+1
end while
if cs_vlj<m.cs_vly.count()then m.cs_vly.delete(cs_vlj)
end if
end function
cs_vxw.getclip=function()as object
return m.cs_vqc.getclip()
end function
cs_vxw.getplaylist=function()as object
return m.cs_vqc
end function
cs_vxw.setlabels=function(cs_vtw as object)as void
if cs_vtw<>invalid then
for each label in cs_vtw
m.setlabel(label,cs_vtw[label])
end for
end if
end function
cs_vxw.getlabel=function(name as string)as string
return m.cs_vqb[name]
end function
cs_vxw.setlabel=function(name as string,cs_vvw as string)as void
if cs_vvw=invalid then
m.cs_vqb.delete(name)
else
m.cs_vqb[name]=cs_vvw
end if
end function
cs_vxw.reset=function(keeplabels=invalid as object)as void
m.cs_vqc.reset(keeplabels)
m.cs_vqc.cs_vve(0)
m.cs_vqc.cs_vuf(comscore_tostr(comscore_unix_time())+ "_1")
m.cs_vqc.getclip().reset(keeplabels)
if keeplabels<>invalid and type(keeplabels)= "roArray" and keeplabels.count()>0 then
cs_vwm(m.cs_vqb,keeplabels)
else
m.cs_vqb.clear()
end if
m.cs_vnu=1
m.cs_vnf=0
m.cs_vmx()
m.cs_vna()
m.cs_vnw=-1#
m.cs_vnc=-1#
m.cs_vng=-1#
m.cs_vnn=-1#
m.cs_vpk=csstreamsensestate().idle
m.cs_vpl=-1#
m.cs_vpf=invalid
m.cs_vmp=m.cs_vip
m.cs_vmr=m.cs_viq
m.cs_voa=invalid
m.cs_vou=0#
m.cs_vly=createobject("roArray",1,true)
m.cs_vmj()
if m.cs_vjx<>invalid then m.cs_vjx.cs_vlz=invalid
end function
cs_vxw.getstate=function()as object
return m.cs_vpk
end function
cs_vxw.cs_vma=function(cs_voz as object,eventlabelmap as object,cs_vmb=-1#as double)as void
m.cs_vmj()
if cs_vmb>=0 then
m.cs_vmk=comscore_unix_time()+cs_vmb
m.cs_vml=cs_voz
m.cs_vmm=eventlabelmap
else if m.cs_vpi(cs_voz)=true then
cs_vor=m.getstate()
previousstatechangetimestamp#=m.cs_vpl
eventtime#=m.cs_vph(eventlabelmap)
delta#=0
if previousstatechangetimestamp#>=0 then
delta#=eventtime#-previousstatechangetimestamp#
end if
m.cs_voo(m.getstate(),eventlabelmap)
m.cs_vot(cs_voz,eventlabelmap)
m.cs_vpj(cs_voz)
for each cs_vlh in m.cs_vly
if cs_vlh.onstatechange<>invalid then cs_vlh.onstatechange(cs_vor,cs_voz,eventlabelmap,delta#)
end for
m.cs_vvl(eventlabelmap)
m.cs_vqc.cs_vvl(eventlabelmap,cs_voz)
m.cs_vqc.getclip().cs_vvl(eventlabelmap,cs_voz)
cs_vmg=m.cs_vpm(m.cs_voj(cs_voz),eventlabelmap)
cs_vmg.append(eventlabelmap)
if m.cs_vpc(m.cs_vpk)=true then
m.dispatch(cs_vmg)
m.cs_vpf=m.cs_vpk
m.cs_vnu=m.cs_vnu+1
end if
end if
end function
cs_vxw.cs_vmj=function()as void
m.cs_vmk=-1#
m.cs_vml=invalid
m.cs_vmm=invalid
end function
cs_vxw.cs_vvl=function(labels as object)as void
cs_vvw=labels["ns_st_mp"]
if cs_vvw<>invalid then
m.cs_vmp=cs_vvw
labels.delete("ns_st_mp")
end if
cs_vvw=labels["ns_st_mv"]
if cs_vvw<>invalid then
m.cs_vmr=cs_vvw
labels.delete("ns_st_mv")
end if
cs_vvw=labels["ns_st_ec"]
if cs_vvw<>invalid then
m.cs_vnu=comscore_stoi(cs_vvw)
labels.delete("ns_st_ec")
end if
end function
cs_vxw.dispatch=function(eventlabelmap as object,snapshot=true as boolean)as void
if snapshot=true then m.cs_vnz(eventlabelmap)
if not m.cs_vny()then
cs_vmu=cs_vsw(m,m.cs_vqa,eventlabelmap,m.pixelurl())
m.cs_vqa.dispatch(cs_vmu)
end if
end function
cs_vxw.cs_vmv=function()as void
if m.cs_vng>=0 then
interval#=m.cs_vng
else
interval#=m.cs_vit
if m.cs_vnf<m.cs_viu then interval#=m.cs_vis
end if
m.cs_vnc=comscore_unix_time()+interval#
end function
cs_vxw.cs_vmx=function()as void
m.cs_vng=m.cs_vnc-comscore_unix_time()
m.cs_vnc=-1#
end function
cs_vxw.cs_vna=function()as void
m.cs_vng=-1#
m.cs_vnc=-1#
m.cs_vnf=0
end function
cs_vxw.cs_vne=function()as void
m.cs_vnf=m.cs_vnf+1
eventlabelmap=m.cs_vpm(csstreamsenseeventtype().heart_beat,invalid)
m.dispatch(eventlabelmap)
m.cs_vng=-1
m.cs_vmv()
end function
cs_vxw.cs_vnh=function()as void
m.cs_vnj()
m.cs_vnn=comscore_unix_time()+m.cs_viv
end function
cs_vxw.cs_vnj=function()as void
m.cs_vnn=-1#
end function
cs_vxw.cs_vnl=function()as void
eventlabelmap=m.cs_vpm(csstreamsenseeventtype().keep_alive,invalid)
m.dispatch(eventlabelmap)
m.cs_vnu=m.cs_vnu+1
m.cs_vnn=comscore_unix_time()+m.cs_viv
end function
cs_vxw.cs_vno=function()as void
m.cs_vnw=comscore_unix_time()+m.cs_viw
end function
cs_vxw.cs_vnq=function()as void
m.cs_vnw=-1#
end function
cs_vxw.cs_vns=function()as void
if m.cs_vpf=csstreamsensestate().playing then
m.cs_vqc.cs_vva()
m.cs_vqc.cs_vux()
labels=m.cs_vpm(csstreamsenseeventtype().pause,invalid)
m.dispatch(labels)
m.cs_vnu=m.cs_vnu+1
m.cs_vpf=csstreamsensestate().paused
end if
m.cs_vnw=-1#
end function
cs_vxw.cs_vnx=function(eventlabelmap as object)as void
cs_vcr#=m.cs_vph(eventlabelmap)
if cs_vcr#<0 then
eventlabelmap["ns_ts"]=comscore_tostr(comscore_unix_time())
end if
end function
cs_vxw.cs_vny=function()as boolean
if m.cs_vqa.publishersecret()= "" or m.cs_vqa.customerc2()=invalid then return true
return false
end function
cs_vxw.cs_vnz=function(labels as object)as void
m.cs_voa=m.cs_vpm(m.cs_voj(m.cs_vpk),invalid)
m.cs_voa.append(labels)
end function
cs_vxw.cs_vob=function(state as object)as boolean
if state=csstreamsensestate().playing or state=csstreamsensestate().paused then return true
return false
end function
cs_vxw.cs_voe=function(cs_voi as object)as object
if cs_voi=csstreamsenseeventtype().play then return csstreamsensestate().playing
if cs_voi=csstreamsenseeventtype().pause then return csstreamsensestate().paused
if cs_voi=csstreamsenseeventtype().buffer then return csstreamsensestate().buffering
if cs_voi=csstreamsenseeventtype().end then return csstreamsensestate().idle
return invalid
end function
cs_vxw.cs_voj=function(state as object)as object
if state=csstreamsensestate().playing then return csstreamsenseeventtype().play
if state=csstreamsensestate().paused then return csstreamsenseeventtype().pause
if state=csstreamsensestate().buffering then return csstreamsenseeventtype().buffer
if state=csstreamsensestate().idle then return csstreamsenseeventtype().end
return invalid
end function
cs_vxw.cs_voo=function(cs_vor as object,eventlabelmap as object)as void
eventtime#=m.cs_vph(eventlabelmap)
if cs_vor=csstreamsensestate().playing then
m.cs_vqc.cs_vum(eventtime#)
m.cs_vmx()
m.cs_vnj()
else if cs_vor=csstreamsensestate().buffering then
m.cs_vqc.cs_vun(eventtime#)
m.cs_vnq()
else if cs_vor=csstreamsensestate().idle then
keeplabels=createobject("roArray",1,true)
cs_vos=m.cs_vqc.getclip().getlabels()
if cs_vos<>invalid then
for each key in cs_vos
keeplabels.push(key)
end for
end if
m.cs_vqc.getclip().reset(keeplabels)
end if
end function
cs_vxw.cs_vot=function(cs_voz as object,eventlabelmap as object)as void
eventtime#=m.cs_vph(eventlabelmap)
if m.cs_vpg(eventlabelmap)<0 then
eventlabelmap["ns_st_po"]=comscore_tostr(m.cs_vpa(eventtime#))
end if
playerposition#=m.cs_vpg(eventlabelmap)
m.cs_vou=playerposition#
if cs_voz=csstreamsensestate().playing then
m.cs_vmv()
m.cs_vnh()
m.cs_vqc.getclip().cs_vrx(eventtime#)
if m.cs_vpc(cs_voz)=true then
m.cs_vqc.getclip().cs_vuk()
if m.cs_vqc.cs_vuh()<1 then
m.cs_vqc.cs_vui(1)
end if
end if
else if cs_voz=csstreamsensestate().paused then
if m.cs_vpc(cs_voz)then
m.cs_vqc.cs_vux()
end if
else if cs_voz=csstreamsensestate().buffering then
m.cs_vqc.getclip().cs_vsa(eventtime#)
if m.cs_voy=true then
m.cs_vno()
end if
else if cs_voz=csstreamsensestate().idle then
m.cs_vna()
end if
end function
cs_vxw.cs_vpa=function(eventtime as double)as double
cs_vkd#=m.cs_vou
if m.cs_vpk=csstreamsensestate().playing then
cs_vkd#=cs_vkd#+ (eventtime-m.cs_vpl)
end if
return cs_vkd#
end function
cs_vxw.cs_vpc=function(state as object)as boolean
if state=csstreamsensestate().paused and(m.cs_vpf=csstreamsensestate().idle or m.cs_vpf=invalid)then
return false
else
return state<>csstreamsensestate().buffering and m.cs_vpf<>state
end if
end function
cs_vxw.cs_vpg=function(cs_vtw as object)as double
playerposition#= -1#
if cs_vtw.doesexist("ns_st_po")then
playerposition#=comscore_stod(cs_vtw["ns_st_po"])
end if
return playerposition#
end function
cs_vxw.cs_vph=function(cs_vtw as object)as double
cs_vcr#= -1#
if cs_vtw.doesexist("ns_ts")then
cs_vcr#=comscore_stod(cs_vtw["ns_ts"])
end if
return cs_vcr#
end function
cs_vxw.cs_vpi=function(cs_voz as object)as boolean
if cs_voz<>invalid and m.getstate()<>cs_voz then return true
return false
end function
cs_vxw.cs_vpj=function(cs_voz as object)as void
m.cs_vpk=cs_voz
m.cs_vpl=comscore_unix_time()
end function
cs_vxw.cs_vpm=function(cs_vud as object,cs_vtt as object)as object
cs_vtw=createobject("roAssociativeArray")
if cs_vtt<>invalid then
cs_vtw.append(cs_vtt)
end if
if not cs_vtw.doesexist("ns_ts")then
cs_vtw["ns_ts"]=comscore_tostr(comscore_unix_time())
end if
if cs_vud<>invalid and not cs_vtw.doesexist("ns_st_ev")then
cs_vtw["ns_st_ev"]=cs_vud
end if
if m.sharingsdkpersistentlabels()then
cs_vtw.append(m.cs_vqa.getlabels())
end if
cs_vtw.append(m.getlabels())
m.cs_vts(cs_vud,cs_vtw)
m.cs_vqc.cs_vts(cs_vud,cs_vtw)
m.cs_vqc.getclip().cs_vts(cs_vud,cs_vtw)
cs_vpo=createobject("roAssociativeArray")
cs_vpo["ns_st_mp"]=m.cs_vmp
cs_vpo["ns_st_mv"]=m.cs_vmr
cs_vpo["ns_st_ub"]= "0"
cs_vpo["ns_st_br"]= "0"
cs_vpo["ns_st_pn"]= "1"
cs_vpo["ns_st_tp"]= "1"
for each key in cs_vpo
if not cs_vtw.doesexist(key)then cs_vtw[key]=cs_vpo[key]
end for
return cs_vtw
end function
cs_vxw.cs_vts=function(cs_vud as object,cs_vtt as object)as object
cs_vtw=cs_vtt
if cs_vtw=invalid then
cs_vtw=createobject("roAssociativeArray")
end if
cs_vtw["ns_st_ec"]=comscore_tostr(m.cs_vnu)
if not cs_vtw.doesexist("ns_st_po")then
currentposition#=m.cs_vou
eventtime#=m.cs_vph(cs_vtw)
if cs_vud=csstreamsenseeventtype().play or cs_vud=csstreamsenseeventtype().keep_alive or cs_vud=csstreamsenseeventtype().heart_beat or(cs_vud=invalid and cs_vpx=csstreamsensestate().playing)then
currentposition#=currentposition#+ (eventtime#-m.cs_vqc.getclip().cs_vrw())
end if
cs_vtw["ns_st_po"]=comscore_tostr(currentposition#)
end if
if cs_vud=csstreamsenseeventtype().heart_beat then
cs_vtw["ns_st_hc"]=comscore_tostr(m.cs_vnf)
end if
return cs_vtw
end function
if dax<>invalid then
cs_vxw.cs_vqa=dax
else
cs_vxw.cs_vqa=cscomscore()
end if
cs_vxw.setpixelurl=cs_vxw.cs_vqa.setpixelurl
cs_vxw.pixelurl=cs_vxw.cs_vqa.pixelurl
cs_vxw.cs_vqb=createobject("roAssociativeArray")
cs_vxw.cs_vqc=cs_vsy()
cs_vxw.reset()
return cs_vxw
end function
function cs_vqd()as object
cs_vxw=createobject("roAssociativeArray")
cs_vxw.cs_vvx=0
cs_vxw.cs_vvn=0
cs_vxw.cs_vvr=0#
cs_vxw.cs_vsb=-1#
cs_vxw.cs_vut=0#
cs_vxw.cs_vry=-1#
cs_vxw.cs_vsh="1"
cs_vxw.cs_vth=createobject("roAssociativeArray")
cs_vxw.reset=function(keeplabels=invalid as object)as void
if keeplabels<>invalid and type(keeplabels)= "roArray" and keeplabels.count()>0 then
cs_vwm(m.cs_vth,keeplabels)
else
m.cs_vth.clear()
end if
if m.cs_vth["ns_st_cl"]=invalid then
m.cs_vth["ns_st_cl"]= "0"
end if
if m.cs_vth["ns_st_pn"]=invalid then
m.cs_vth["ns_st_pn"]= "1"
end if
if m.cs_vth["ns_st_tp"]=invalid then
m.cs_vth["ns_st_tp"]= "1"
end if
m.cs_vvx=0
m.cs_vvn=0
m.cs_vvr=0#
m.cs_vsb=-1#
m.cs_vut=0#
m.cs_vry=-1#
end function
cs_vxw.setlabels=function(newlabels as object,state=invalid as object)as void
if newlabels<>invalid then
m.cs_vth.append(newlabels)
end if
m.cs_vvl(m.cs_vth,state)
end function
cs_vxw.getlabels=function()as object
return m.cs_vth
end function
cs_vxw.setlabel=function(label as string,cs_vvw as string)as void
cs_vtr=createobject("roAssociativeArray")
cs_vtr[label]=cs_vvw
m.setlabels(cs_vtr)
end function
cs_vxw.getlabel=function(label as string)as string
return m.cs_vth[label]
end function
cs_vxw.cs_vts=function(cs_vud as object,cs_vtt=invalid as object)as object
cs_vtw=cs_vtt
if cs_vtw=invalid then
cs_vtw=createobject("roAssociativeArray")
end if
cs_vtw["ns_st_cn"]=m.cs_vsh
cs_vtw["ns_st_bt"]=comscore_tostr(m.cs_vuo())
if cs_vud=csstreamsenseeventtype().play or cs_vud=invalid
cs_vtw["ns_st_sq"]=comscore_tostr(m.cs_vvn)
end if
if cs_vud=csstreamsenseeventtype().pause or cs_vud=csstreamsenseeventtype().end or cs_vud=csstreamsenseeventtype().keep_alive or cs_vud=csstreamsenseeventtype().heart_beat or cs_vud=invalid
cs_vtw["ns_st_pt"]=comscore_tostr(m.cs_vur())
cs_vtw["ns_st_pc"]=comscore_tostr(m.cs_vvx)
end if
cs_vtw.append(m.cs_vth)
return cs_vtw
end function
cs_vxw.cs_vuu=function()as integer
return m.cs_vvx
end function
cs_vxw.cs_vuv=function(pauses as integer)as void
m.cs_vvx=pauses
end function
cs_vxw.cs_vux=function()as void
m.cs_vvx=m.cs_vvx+1
end function
cs_vxw.cs_vuh=function()as integer
return m.cs_vvn
end function
cs_vxw.cs_vui=function(starts as integer)as void
m.cs_vvn=starts
end function
cs_vxw.cs_vuk=function()as void
m.cs_vvn=m.cs_vvn+1
end function
cs_vxw.cs_vuo=function()as double
cs_vkd#=m.cs_vvr
if m.cs_vsb>=0 then
cs_vkd#=cs_vkd#+ (comscore_unix_time()-m.cs_vsb)
end if
return cs_vkd#
end function
cs_vxw.cs_vup=function(bufferingtime as double)as void
m.cs_vvr=bufferingtime
end function
cs_vxw.cs_vur=function()as double
cs_vkd#=m.cs_vut
if m.cs_vry>=0 then
cs_vkd#=cs_vkd#+ (comscore_unix_time()-m.cs_vry)
end if
return cs_vkd#
end function
cs_vxw.cs_vus=function(cs_vvv as double)as void
m.cs_vut=cs_vvv
end function
cs_vxw.cs_vrw=function()as double
return m.cs_vry
end function
cs_vxw.cs_vrx=function(playbacktimestamp as double)as void
m.cs_vry=playbacktimestamp
end function
cs_vxw.cs_vrz=function()as double
return m.cs_vsb
end function
cs_vxw.cs_vsa=function(bufferingtimestamp as double)as void
m.cs_vsb=bufferingtimestamp
end function
cs_vxw.cs_vsc=function()as string
return m.cs_vsh
end function
cs_vxw.cs_vsd=function(clipid as string)as void
m.cs_vsh=clipid
end function
cs_vxw.cs_vvl=function(labels as object,state as object)as void
cs_vvw=labels["ns_st_cn"]
if cs_vvw<>invalid
m.cs_vsh=cs_vvw
labels.delete("ns_st_cn")
end if
cs_vvw=labels["ns_st_bt"]
if cs_vvw<>invalid
m.cs_vvr=comscore_stod(cs_vvw)
labels.delete("ns_st_bt")
end if
m.cs_vsq("ns_st_cl",labels)
m.cs_vsq("ns_st_pn",labels)
m.cs_vsq("ns_st_tp",labels)
m.cs_vsq("ns_st_ub",labels)
m.cs_vsq("ns_st_br",labels)
if state=csstreamsensestate().playing or state=invalid
cs_vvw=labels["ns_st_sq"]
if(cs_vvw<>invalid)
m.cs_vvn=comscore_stoi(cs_vvw)
labels.delete("ns_st_sq")
end if
end if
if state<>csstreamsensestate().buffering
cs_vvw=labels["ns_st_pt"]
if cs_vvw<>invalid
m.cs_vut=comscore_stod(cs_vvw)
labels.delete("ns_st_pt")
end if
end if
if state=csstreamsensestate().paused or state=csstreamsensestate().idle or state=invalid
cs_vvw=labels["ns_st_pc"]
if cs_vvw<>invalid
m.cs_vvx=comscore_stoi(cs_vvw)
labels.delete("ns_st_pc")
end if
end if
end function
cs_vxw.cs_vsq=function(key as string,labels as object)as void
cs_vvw=labels[key]
if cs_vvw<>invalid then
m.cs_vth[key]=cs_vvw
end if
end function
cs_vxw.reset()
return cs_vxw
end function
function csstreamsenseeventtype()
if m.cs_vst=invalid then m.cs_vst=cs_vsu()
return m.cs_vst
end function
function cs_vsu()as object
cs_vsv=createobject("roAssociativeArray")
cs_vsv.buffer="buffer"
cs_vsv.play="play"
cs_vsv.pause="pause"
cs_vsv.end="end"
cs_vsv.heart_beat="hb"
cs_vsv.custom="custom"
cs_vsv.keep_alive="keep-alive"
return cs_vsv
end function
function cs_vsw(streamsense as object,dax as object,labels as object,pixelurl as string)as object
cs_vxw=csapplicationmeasurement(dax,cseventtype().hidden,pixelurl,labels)
if pixelurl<>invalid and pixelurl<>"" then cs_vxw.setpixelurl(pixelurl)
cs_vxw.labels["ns_st_sv"]=streamsense.getversion()
return cs_vxw
end function
function cs_vsy()as object
cs_vxw=createobject("roAssociativeArray")
cs_vxw.cs_vta=cs_vqd()
cs_vxw.cs_vvt=""
cs_vxw.cs_vvn=0
cs_vxw.cs_vvx=0
cs_vxw.cs_vvp=0
cs_vxw.cs_vvr=0#
cs_vxw.cs_vut=0#
cs_vxw.cs_vth=createobject("roAssociativeArray")
cs_vxw.cs_vvh=0
cs_vxw.cs_vvk=false
cs_vxw.reset=function(keeplabels=invalid as object)as void
if keeplabels<>invalid and type(keeplabels)= "roArray" and keeplabels.count()>0 then
cs_vwm(m.cs_vth,keeplabels)
else
m.cs_vth.clear()
end if
m.cs_vvt=comscore_tostr(comscore_unix_time())+ "_" +comscore_tostr(m.cs_vvh)
m.cs_vvr=0#
m.cs_vut=0#
m.cs_vvn=0
m.cs_vvx=0
m.cs_vvp=0
m.cs_vvk=false
end function
cs_vxw.setlabels=function(newlabels as object,state=invalid as object)as void
if newlabels<>invalid then
m.cs_vth.append(newlabels)
end if
m.cs_vvl(m.cs_vth,state)
end function
cs_vxw.getlabels=function()as object
return m.cs_vth
end function
cs_vxw.setlabel=function(label as string,cs_vvw as string)as void
cs_vtr=createobject("roAssociativeArray")
cs_vtr[label]=cs_vvw
m.setlabels(cs_vtr)
end function
cs_vxw.getlabel=function(label as string)as string
return m.cs_vth[label]
end function
cs_vxw.cs_vts=function(cs_vud as object,cs_vtt=invalid as object)as object
cs_vtw=cs_vtt
if cs_vtw=invalid then
cs_vtw=createobject("roAssociativeArray")
end if
cs_vtw["ns_st_bp"]=comscore_tostr(m.cs_vuo())
cs_vtw["ns_st_sp"]=comscore_tostr(m.cs_vvn)
cs_vtw["ns_st_id"]=comscore_tostr(m.cs_vvt)
if m.cs_vvp>0 then
cs_vtw["ns_st_bc"]=comscore_tostr(m.cs_vvp)
end if
if cs_vud=csstreamsenseeventtype().pause or cs_vud=csstreamsenseeventtype().end or cs_vud=csstreamsenseeventtype().keep_alive or cs_vud=csstreamsenseeventtype().heart_beat or cs_vud=invalid then
cs_vtw["ns_st_pa"]=comscore_tostr(m.cs_vur())
cs_vtw["ns_st_pp"]=comscore_tostr(m.cs_vvx)
end if
if cs_vud=csstreamsenseeventtype().play or cs_vud=invalid then
if not m.cs_vvi()then
cs_vtw["ns_st_pb"]= "1"
m.cs_vvj(true)
end if
end if
cs_vtw.append(m.cs_vth)
return cs_vtw
end function
cs_vxw.getclip=function()as object
return m.cs_vta
end function
cs_vxw.cs_vue=function()as string
return m.cs_vvt
end function
cs_vxw.cs_vuf=function(playlistid as string)as void
m.cs_vvt=playlistid
end function
cs_vxw.cs_vuh=function()as integer
return m.cs_vvn
end function
cs_vxw.cs_vui=function(starts as integer)as void
m.cs_vvn=starts
end function
cs_vxw.cs_vuk=function()as void
m.cs_vvn=m.cs_vvn+1
end function
cs_vxw.cs_vum=function(cs_vzg as double)as void
if m.cs_vta.cs_vrw()>=0 then
diff#=cs_vzg-m.cs_vta.cs_vrw()
m.cs_vta.cs_vrx(-1)
m.cs_vta.cs_vus(m.cs_vta.cs_vur()+diff#)
m.cs_vus(m.cs_vur()+diff#)
end if
end function
cs_vxw.cs_vun=function(cs_vzg as double)as void
if m.cs_vta.cs_vrz()>=0 then
diff#=cs_vzg-m.cs_vta.cs_vrz()
m.cs_vta.cs_vsa(-1)
m.cs_vta.cs_vup(m.cs_vta.cs_vuo()+diff#)
m.cs_vup(m.cs_vuo()+diff#)
end if
end function
cs_vxw.cs_vuo=function()as double
cs_vkd#=m.cs_vvr
if m.cs_vta.cs_vrz()>=0 then
cs_vkd#=cs_vkd#+ (comscore_unix_time()-m.cs_vta.cs_vrz())
end if
return cs_vkd#
end function
cs_vxw.cs_vup=function(bufferingtime as double)as void
m.cs_vvr=bufferingtime
end function
cs_vxw.cs_vur=function()as double
cs_vkd#=m.cs_vut
if m.cs_vta.cs_vrw()>=0 then
cs_vkd#=cs_vkd#+ (comscore_unix_time()-m.cs_vta.cs_vrw())
end if
return cs_vkd#
end function
cs_vxw.cs_vus=function(cs_vvv as double)as void
m.cs_vut=cs_vvv
end function
cs_vxw.cs_vuu=function()as integer
return m.cs_vvx
end function
cs_vxw.cs_vuv=function(pauses as integer)as void
cs_vxw.cs_vvx=pauses
end function
cs_vxw.cs_vux=function()as void
m.cs_vvx=m.cs_vvx+1
m.cs_vta.cs_vux()
end function
cs_vxw.cs_vuz=function()as integer
return m.cs_vvp
end function
cs_vxw.cs_vva=function()as void
m.cs_vvp=m.cs_vvp+1
end function
cs_vxw.cs_vvc=function(rebuffercount as integer)
m.cs_vvp=rebuffercount
end function
cs_vxw.cs_vve=function(playlistcounter as integer)as void
m.cs_vvh=playlistcounter
end function
cs_vxw.cs_vvg=function()as void
m.cs_vvh=m.cs_vvh+1
end function
cs_vxw.cs_vvi=function()as boolean
return m.cs_vvk
end function
cs_vxw.cs_vvj=function(firstplayoccurred as boolean)as void
m.cs_vvk=firstplayoccurred
end function
cs_vxw.cs_vvl=function(labels as object,state as object)as void
cs_vvw=labels["ns_st_sp"]
if cs_vvw<>invalid then
m.cs_vvn=comscore_stoi(cs_vvw)
labels.delete("ns_st_sp")
end if
cs_vvw=labels["ns_st_bc"]
if cs_vvw<>invalid then
m.cs_vvp=comscore_stoi(cs_vvw)
labels.delete("ns_st_bc")
end if
cs_vvw=labels["ns_st_bp"]
if cs_vvw<>invalid then
m.cs_vvr=comscore_stod(cs_vvw)
labels.delete("ns_st_bp")
end if
cs_vvw=labels["ns_st_id"]
if cs_vvw<>invalid then
m.cs_vvt=cs_vvw
labels.delete("ns_st_id")
end if
if state<>csstreamsensestate().buffering then
cs_vvw=labels["ns_st_pa"]
if cs_vvw<>invalid then
cs_vvv=comscore_stod(cs_vvw)
labels.delete("ns_st_pa")
end if
end if
if state=csstreamsensestate().paused or state=csstreamsensestate().idle or state=invalid then
cs_vvw=labels["ns_st_pp"]
if cs_vvw<>invalid then
m.cs_vvx=comscore_stoi(cs_vvw)
labels.delete("ns_st_pp")
end if
end if
end function
cs_vxw.reset()
return cs_vxw
end function
function csstreamsensesgbridge(cs_vwe as object)as object
cs_vxw=createobject("roAssociativeArray")
cs_vxw.cs_vwe=cs_vwe
cs_vwf={}
cs_vwf["component"]= "sta"
cs_vwf["methodName"]= "init"
cs_vxw.cs_vwe["apiCall"]=cs_vwf
cs_vxw.comscoretask=function()as object
return m.cs_vwe
end function
cs_vxw.engageto=function(screen as object)as void
m.cs_vwg("EngageTo",[screen])
end function
cs_vxw.tick=function()as void
m.cs_vwg("Tick",invalid)
end function
cs_vxw.notify=function(cs_vud as object,position=-1#as double,eventlabelmap=invalid as object)as void
m.cs_vwg("Notify",[cs_vud,position,eventlabelmap])
end function
cs_vxw.sharesdkpersistentlabels=function(flag as boolean)
m.cs_vwg("ShareSDKPersistentLabels",[flag])
end function
cs_vxw.setpauseonbufferingenabled=function(pauseonbufferingenabled as boolean)
m.cs_vwg("SetPauseOnBufferingEnabled",[pauseonbufferingenabled])
end function
cs_vxw.setpauseplayswitchdelayenabled=function(pauseplayswitchdelayenabled as boolean)as void
m.cs_vwg("SetPausePlaySwitchDelayEnabled",[pauseplayswitchdelayenabled])
end function
cs_vxw.setclip=function(labels as object,loop=false as boolean)as boolean
m.cs_vwg("SetClip",[labels,loop])
end function
cs_vxw.setplaylist=function(labels as object)as boolean
m.cs_vwg("SetPlaylist",[labels])
end function
cs_vxw.addlistener=function(cs_vlh as object)as void
m.cs_vwg("AddListener",[cs_vlh])
end function
cs_vxw.removelistener=function(cs_vlh as object)as void
m.cs_vwg("RemoveListener",[cs_vlh])
end function
cs_vxw.setlabels=function(cs_vtw as object)as void
m.cs_vwg("SetLabels",[cs_vtw])
end function
cs_vxw.setlabel=function(name as string,cs_vvw as string)as void
m.cs_vwg("SetLabel",[name,cs_vvw])
end function
cs_vxw.reset=function(keeplabels=invalid as object)as void
m.cs_vwg("Reset",[keeplabels])
end function
cs_vxw.cs_vwg=function(name as string,args)
cs_vwh={}
cs_vwh["component"]= "sta"
cs_vwh["methodName"]=name
cs_vwh["args"]=args
m.cs_vwe["apiCall"]=cs_vwh
end function
return cs_vxw
end function
function csstreamingsgbridge(cs_vwe as object)as object
cs_vxw=createobject("roAssociativeArray")
cs_vxw.cs_vwe=cs_vwe
cs_vwf={}
cs_vwf["component"]= "ssw"
cs_vwf["methodName"]= "init"
cs_vxw.cs_vwe["apiCall"]=cs_vwf
cs_vxw.comscoretask=function()as object
return m.cs_vwe
end function
cs_vxw.playvideoadvertisement=function(metadata=invalid as object)as void
m.cs_vwg("PlayVideoAdvertisement",[metadata])
end function
cs_vxw.playaudioadvertisement=function(metadata=invalid as object)as void
m.cs_vwg("PlayAudioAdvertisement",[metadata])
end function
cs_vxw.playvideocontentpart=function(metadata=invalid as object)as void
m.cs_vwg("PlayVideoContentPart",[metadata])
end function
cs_vxw.playaudiocontentpart=function(metadata=invalid as object)as void
m.cs_vwg("PlayAudioContentPart",[metadata])
end function
cs_vxw.stop=function()as void
m.cs_vwg("Stop",invalid)
end function
cs_vxw.tick=function()as void
m.cs_vwg("Tick",invalid)
end function
cs_vxw.cs_vwg=function(name as string,args)
cs_vwh={}
cs_vwh["component"]= "ssw"
cs_vwh["methodName"]=name
cs_vwh["args"]=args
m.cs_vwe["apiCall"]=cs_vwh
end function
return cs_vxw
end function
function csstreamsensestate()
if m.cs_vwj=invalid then m.cs_vwj=cs_vwk()
return m.cs_vwj
end function
function cs_vwk()as object
cs_vwl=createobject("roAssociativeArray")
cs_vwl.buffering="buffering"
cs_vwl.playing="playing"
cs_vwl.paused="paused"
cs_vwl.idle="idle"
return cs_vwl
end function
function cs_vwm(cs_vtr as object,keepkeys as object)
cs_vwn=createobject("roAssociativeArray")
for each keyname in keepkeys
cs_vwn[keyname]=true
end for
cs_vwo=createobject("roArray",30,true)
for each keyname in cs_vtr
if not cs_vwn.doesexist(keyname)then
cs_vwo.push(keyname)
end if
end for
for each keyname in cs_vwo
cs_vtr.delete(keyname)
end for
end function
function csstreamsensevideoscreenwrapper(args as object)as object
cs_vxw=createobject("roAssociativeArray")
cs_vwq=createobject("roMessagePort")
cs_vxw.cs_vwr=createobject("roVideoScreen")
cs_vxw.cs_vwr.setmessageport(cs_vwq)
cs_vxw.cs_vws=createobject("roAssociativeArray")
if type(args)= "roAssociativeArray"
if type(args.url)= "roString" and args.url<>"" then
url=args.url
cs_vxw.cs_vws.streamurls=[url]
end if
if type(args.streamformat)= "roString" and args.streamformat<>"" then
cs_vxw.cs_vws.streamformat=args.streamformat
end if
if type(args.title)= "roString" and args.title<>"" then
cs_vxw.cs_vws.title=args.title
else
cs_vxw.cs_vws.title=""
end if
end if
cs_vxw.cs_vws.streambitrates=[0]
cs_vxw.cs_vws.streamqualities=["SD"]
cs_vxw.cs_vwr.setcontent(cs_vxw.cs_vws)
cs_vxw.cs_vwr.setpositionnotificationperiod(1)
cs_vxw.show=function()as void
m.cs_vwr.show()
while true
cs_vwu=wait(50,m.cs_vwr.getmessageport())
if type(cs_vwu)= "roVideoScreenEvent" then
if cs_vwu.isscreenclosed()
exit while
else if m.cs_vlz<>invalid
if m.cs_vlz.onplayerevent(cs_vwu)then exit while
end if
else if cs_vwu=invalid then
if m.cs_vlz<>invalid then m.cs_vlz.onplayerevent(cs_vwu)
end if
end while
end function
return cs_vxw
end function
function cscontenttype()as object
cs_vxw=createobject("roAssociativeArray")
cs_vxw.cs_vww="12"
cs_vxw.cs_vwx="11"
cs_vxw.cs_vwy="13"
cs_vxw.cs_vwz="22"
cs_vxw.cs_vxa="21"
cs_vxw.cs_vxb="23"
cs_vxw.cs_vxc="99"
cs_vxw.cs_vxo="00"
return cs_vxw
end function
function csadtype()as object
cs_vxw=createobject("roAssociativeArray")
cs_vxw.cs_vxf="11"
cs_vxw.cs_vxg="12"
cs_vxw.cs_vxh="13"
cs_vxw.cs_vxi="21"
cs_vxw.cs_vxj="31"
cs_vxw.cs_vxk="32"
cs_vxw.cs_vxl="33"
cs_vxw.cs_vxm="34"
cs_vxw.cs_vxn="35"
cs_vxw.cs_vxo="00"
return cs_vxw
end function
function csstreamingtag(dax=invalid as object)as object
cs_vxw=createobject("roAssociativeArray")
cs_vxw.cs_vyq=0
cs_vxw.cs_vyl=invalid
cs_vxw.cs_vxs=0
cs_vxw.cs_vze=false
cs_vxw.cs_vxu=csstreamsense(dax)
cs_vxw.cs_vxu.setlabel("ns_st_it","r")
cs_vxw.cs_vxv=function()as object
cs_vxw=createobject("roAssociativeArray")
cs_vxw.cs_vxx="0"
cs_vxw.cs_vxy="1"
cs_vxw.cs_vxz="2"
return cs_vxw
end function
cs_vxw.cs_vzf=cs_vxw.cs_vxv().cs_vxx
cs_vxw.cs_vyb=["ns_st_st","ns_st_ci","ns_st_pr","ns_st_sn","ns_st_en","ns_st_ep","ns_st_ct","ns_st_pu","c3","c4","c6"]
cs_vxw.cs_vzd=0
cs_vxw.cs_vyw=0
cs_vxw.cs_vye=function(metadata as object)as object
if metadata=invalid then
metadata={}
end if
for cs_vyh=0 to m.cs_vyb.count()-1 step 1
if m.cs_vyb[cs_vyh]= "ns_st_ci" and metadata["ns_st_ci"]=invalid then
metadata["ns_st_ci"]= "0"
else if metadata[m.cs_vyb[cs_vyh]]=invalid then
metadata[m.cs_vyb[cs_vyh]]= "*null"
end if
end for
return metadata
end function
cs_vxw.cs_vyg=function(metadata as object)as boolean
for cs_vyh=0 to m.cs_vyb.count()-1 step 1
if not m.cs_vyi(m.cs_vyb[cs_vyh],m.cs_vyl,metadata)then
return false
end if
end for
return true
end function
cs_vxw.cs_vyi=function(label as string,map1 as object,map2 as object)as boolean
if label<>invalid and map1<>invalid and map2<>invalid then
if map1[label]<>invalid and map2[label]<>invalid then
return map1[label]=map2[label]
end if
end if
return false
end function
cs_vxw.cs_vyj=function(cs_vzg as double,metadata as object)as void
m.cs_vzh(cs_vzg)
m.cs_vyq=m.cs_vyq+1
labels={}
labels["ns_st_cn"]=comscore_tostr(m.cs_vyq)
labels["ns_st_pn"]= "1"
labels["ns_st_tp"]= "0"
comscore_extend(labels,metadata)
m.cs_vxu.setclip(labels)
m.cs_vyl=metadata
m.cs_vzd=cs_vzg
m.cs_vyw=0
m.cs_vxu.notify(csstreamsenseeventtype().play,m.cs_vyw)
end function
cs_vxw.cs_vyo=function(metadata as object)as void
cs_vzg=comscore_unix_time()
m.cs_vzh(cs_vzg)
m.cs_vyq=m.cs_vyq+1
metadata=m.cs_vye(metadata)
labels={}
labels["ns_st_cn"]=comscore_tostr(m.cs_vyq)
labels["ns_st_pn"]= "1"
labels["ns_st_tp"]= "1"
labels["ns_st_ad"]= "1"
comscore_extend(labels,metadata)
m.cs_vxu.setclip(labels)
m.cs_vyw=0
m.cs_vxu.notify(csstreamsenseeventtype().play,m.cs_vyw)
m.cs_vzd=cs_vzg
m.cs_vze=false
end function
cs_vxw.cs_vyu=function(timestamp as double)as double
if m.cs_vzd>0 and timestamp>=m.cs_vzd then
m.cs_vyw=m.cs_vyw+timestamp-m.cs_vzd
else
m.cs_vyw=0
end if
return m.cs_vyw
end function
cs_vxw.cs_vyx=function(metadata as object,contenttype as string)as void
cs_vzg=comscore_unix_time()
metadata=m.cs_vye(metadata)
if m.cs_vzf=m.cs_vxv().cs_vxx then
m.cs_vzf=contenttype
end if
if m.cs_vze=true and m.cs_vzf=contenttype then
if not m.cs_vyg(metadata)then
m.cs_vyj(cs_vzg,metadata)
else
m.cs_vxu.getclip().setlabels(metadata)
if m.cs_vxu.getstate()<>csstreamsensestate().playing then
m.cs_vzd=cs_vzg
m.cs_vxu.notify(csstreamsenseeventtype().play,m.cs_vyw)
end if
end if
else
m.cs_vyj(cs_vzg,metadata)
end if
m.cs_vze=true
m.cs_vzf=contenttype
end function
cs_vxw.playvideoadvertisement=function(metadata=invalid as object,mediatype=invalid as object)as void
labels={}
labels["ns_st_ct"]= "va"
if mediatype<>invalid then
labels["ns_st_ct"]= "va" +comscore_tostr(mediatype)
if mediatype=csadtype().cs_vxi or mediatype=csadtype().cs_vxn then
labels["ns_st_li"]= "1"
end if
end if
if metadata<>invalid then
comscore_extend(labels,metadata)
end if
m.cs_vyo(labels)
end function
cs_vxw.playaudioadvertisement=function(metadata=invalid as object,mediatype=invalid as object)as void
labels={}
labels["ns_st_ct"]= "aa"
if mediatype<>invalid then
labels["ns_st_ct"]= "aa" +comscore_tostr(mediatype)
if mediatype=csadtype().cs_vxi or mediatype=csadtype().cs_vxn then
labels["ns_st_li"]= "1"
end if
end if
if metadata<>invalid then
comscore_extend(labels,metadata)
end if
m.cs_vyo(labels)
end function
cs_vxw.playvideocontentpart=function(metadata=invalid as object,mediatype=invalid as object)as void
labels={}
labels["ns_st_ct"]= "vc"
if mediatype<>invalid then
labels["ns_st_ct"]= "vc" +comscore_tostr(mediatype)
if mediatype=cscontenttype().cs_vwy or mediatype=cscontenttype().cs_vxb then
labels["ns_st_li"]= "1"
end if
end if
if metadata<>invalid then
comscore_extend(labels,metadata)
end if
m.cs_vyx(labels,m.cs_vxv().cs_vxz)
end function
cs_vxw.playaudiocontentpart=function(metadata=invalid as object,mediatype=invalid as object)as void
labels={}
labels["ns_st_ct"]= "ac"
if mediatype<>invalid then
labels["ns_st_ct"]= "ac" +comscore_tostr(mediatype)
if mediatype=cscontenttype().cs_vwy or mediatype=cscontenttype().cs_vxb then
labels["ns_st_li"]= "1"
end if
end if
if metadata<>invalid then
comscore_extend(labels,metadata)
end if
m.cs_vyx(labels,m.cs_vxv().cs_vxy)
end function
cs_vxw.stop=function()as void
cs_vzg=comscore_unix_time()
m.cs_vxu.notify(csstreamsenseeventtype().pause,m.cs_vyu(cs_vzg))
end function
cs_vxw.cs_vzh=function(cs_vzg as double)as void
if m.cs_vxu.getstate()<>csstreamsensestate().idle and m.cs_vxu.getstate()<>csstreamsensestate().paused then
m.cs_vxu.notify(csstreamsenseeventtype().end,m.cs_vyu(cs_vzg))
else if m.cs_vxu.getstate()=csstreamsensestate().paused then
m.cs_vxu.notify(csstreamsenseeventtype().end,m.cs_vyw)
end if
end function
cs_vxw.tick=function()as void
m.cs_vxu.tick()
end function
cs_vxw.getstate=function()as object
return m.cs_vxu.getstate()
end function
return cs_vxw
end function
