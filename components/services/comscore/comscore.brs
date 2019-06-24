function cscomscore()as object
if(m.cs_vb=invalid)then
m.cs_vb=cs_vc()
end if
return m.cs_vb
end function
function cs_vc()as object
cs_vyf=createobject("roAssociativeArray")
cs_vyf.log_debug=false
cs_vyf.cs_ve=30*60*1000
cs_vyf.cs_vkc=1000*60*60*24
cs_vyf.cs_vg=1000*10
cs_vyf.census_url="http://b.scorecardresearch.com/p2?"
cs_vyf.census_url_secure="https://sb.scorecardresearch.com/p2?"
cs_vyf.cs_vh="4.5.0.190328"
cs_vyf.cs_vi="NO-RAF"
cs_vyf.cs_vj="REGULAR"
cs_vyf.cs_vk="REGULAR"
cs_vyf.p_storage=invalid
cs_vyf.cs_vl=createobject("roTimespan")
cs_vyf.cs_vm=createobject("roTimespan")
cs_vyf.cs_vn=createobject("roTimespan")
cs_vyf.cs_vcx=0
cs_vyf.cs_vcy=0
cs_vyf.cs_vhy=true
cs_vyf.p_keepalive=invalid
cs_vyf.cs_vhv=true
cs_vyf.cs_vri=createobject("roAssociativeArray")
cs_vyf.p_pixelurl=""
cs_vyf.cs_vce=""
cs_vyf.cs_vcz=""
cs_vyf.cs_vcp=-1
cs_vyf.cs_vct=-1
cs_vyf.p_genesis=-1
cs_vyf.cs_vhj=0
cs_vyf.cs_vdc=""
cs_vyf.cs_vde=""
cs_vyf.cs_vcw=invalid
cs_vyf.start=function(labels=invalid as object)as void
m.notify(cseventtype().start,"",labels)
end function
cs_vyf.hidden=function(labels=invalid as object)as void
m.notify(cseventtype().hidden,"",labels)
end function
cs_vyf.view=function(labels=invalid as object)as void
m.notify(cseventtype().view,"",labels)
end function
cs_vyf.close=function()as void
m.notify(cseventtype().close,"",invalid)
end function
cs_vyf.setpublishersecret=function(salt as string)as void
m.cs_vce=salt
end function
cs_vyf.publishersecret=function()as string
return m.cs_vce
end function
cs_vyf.cs_vbc=function(cs_vbe as boolean)as void
m.cs_vhy=cs_vbe
end function
cs_vyf.cs_vbe=function()as boolean
return m.cs_vhy
end function
cs_vyf.cs_vbf=function()as object
return m.p_keepalive
end function
cs_vyf.tick=function()as void
m.p_keepalive.tick()
if m.cs_vl.totalmilliseconds()>m.cs_vg then
m.p_storage.cs_viz("accumulatedForegroundTime",comscore_tostr(m.cs_vm.totalmilliseconds()))
m.p_storage.cs_viz("totalForegroundTime",comscore_tostr(m.cs_vn.totalmilliseconds()))
m.cs_vl.mark()
end if
end function
cs_vyf.cs_vbg=function()as void
m.p_keepalive.reset()
end function
cs_vyf.cs_vbh=function()as void
m.cs_vm.mark()
end function
cs_vyf.setpixelurl=function(cs_vxd as string)as string
if instr(1,cs_vxd,"?")>0 and right(cs_vxd,1)<>"?" then
cs_vbi=createobject("roAssociativeArray")
cs_vbm=""
labels=right(cs_vxd,len(cs_vxd)-instr(1,cs_vxd,"?")).tokenize("&")
for each label in labels
cs_vbk=label.tokenize("=")
if cs_vbk.count()=2 then
if cs_vbk[0]= "name" then
cs_vbm=cs_vbk[1]
else
cs_vbi[cs_vbk[0]]=cs_vbk[1]
end if
else if cs_vbk.count()=1 then
cs_vbm=comscore_url_encode(cs_vbk[0])
end if
end for
for each label in cs_vbi
m.cs_vri[label]=cs_vbi[label]
end for
cs_vxd=left(cs_vxd,instr(1,cs_vxd,"?"))+cs_vbm
end if
if instr(1,cs_vxd,"?")=0 and instr(1,cs_vxd,"//")=0 then
if len(m.p_pixelurl)>0 and instr(1,m.p_pixelurl,"?")>0 then
cs_vxd=left(m.p_pixelurl,instr(1,m.p_pixelurl,"?"))+comscore_url_encode(cs_vxd)
else
cs_vxd=cs_vxd+"?"
end if
end if
if right(cs_vxd,1)= "?" then
cs_vxd=cs_vxd+"Application"
end if
m.p_pixelurl=cs_vxd
return m.p_pixelurl
end function
cs_vyf.pixelurl=function()as string
return m.p_pixelurl
end function
cs_vyf.setsecure=function(secure as boolean)as void
m.cs_vhv=secure
end function
cs_vyf.secure=function()as boolean
return m.cs_vhv
end function
cs_vyf.setcustomerc2=function(c2 as string)as void
m.cs_vri["c2"]=comscore_url_encode(c2)
if m.secure()then
m.setpixelurl(m.census_url_secure)
else
m.setpixelurl(m.census_url)
end if
end function
cs_vyf.customerc2=function()as string
return m.cs_vri["c2"]
end function
cs_vyf.getlabels=function()as object
return m.cs_vri
end function
cs_vyf.setlabels=function(cs_vvd as object)as void
if cs_vvd<>invalid then
for each label in cs_vvd
m.setlabel(label,cs_vvd[label])
end for
end if
end function
cs_vyf.getlabel=function(name as string)as string
return m.cs_vri[name]
end function
cs_vyf.setlabel=function(key as string,cs_vxd as string)as void
if cs_vxd=invalid then
m.cs_vri.delete(key)
else
m.cs_vri[key]=cs_vxd
end if
end function
cs_vyf.setappname=function(name as string)as void
m.cs_vdz=name
end function
cs_vyf.appname=function()as string
return m.cs_vdz
end function
cs_vyf.setappversion=function(version as string)as void
m.cs_vea=version
end function
cs_vyf.appversion=function()as string
return m.cs_vea
end function
cs_vyf.adframeworkavailable=function()as boolean
return m.cs_veb
end function
cs_vyf.setuseraf=function(useraf as boolean)as boolean
m.cs_vib=useraf
if useraf=true and m.adframeworkavailable()=true then
m.cs_vbx=roku_ads()
if m.cs_vbx<>invalid and m.cs_vbx.enableadmeasurements<>invalid then
m.cs_vbx.enableadmeasurements(true)
return true
else
print"Could not enable RAF Ad measurements. Make sure the installed RAF version is greater or equal to 2.1"
end if
end if
return false
end function
cs_vyf.useraf=function()as boolean
return m.cs_vib
end function
cs_vyf.adinterface=function()as object
return m.cs_vbx
end function
cs_vyf.setuserafsettermethods=function(userafsettermethods as boolean)as void
m.cs_vie=userafsettermethods
end function
cs_vyf.userafsettermethods=function()as boolean
return m.cs_vie
end function
cs_vyf.visitorid=function()as string
if m.cs_vcz="" then
cs_vhq=createobject("roDeviceInfo")
if findmemberfunction(cs_vhq,"GetChannelClientId")<>invalid then
m.cs_vcz=m.cs_vci(cs_vhq.getchannelclientid())+ "-cs62"
else
m.cs_vcz=m.cs_vci(cs_vhq.getchannelclientid())
end if
m.p_storage.cs_viz("visitorId",m.cs_vcz)
end if
return m.cs_vcz
end function
cs_vyf.version=function()as string
return m.cs_vdc
end function
cs_vyf.previousversion=function()as string
return m.cs_vde
end function
cs_vyf.notify=function(cs_vvk as string,pixelurl="" as string,labels=invalid as object)as void
if m.cs_vce="" or m.cs_vri["c2"]=invalid then return
if pixelurl="" then
pixelurl=m.pixelurl()
else
pixelurl=m.setpixelurl(pixelurl)
end if
if labels=invalid then labels=createobject("roAssociativeArray")
if cs_vvk<>"close" then
cs_vob=cs_vgj(m,cs_vvk,pixelurl,labels)
m.dispatch(cs_vob)
end if
m.p_storage.cs_viz("lastActivityTime",str(comscore_unix_time()))
end function
cs_vyf.dispatch=function(cs_vob as object)as void
m.cs_vhj=m.cs_vhj+1
cs_vob.labels["ns_ap_ec"]=comscore_tostr(m.cs_vhj)
cs_vch=cs_vij(cs_vob)
cs_vch.cs_vim()
end function
cs_vyf.cs_vci=function(cs_vha as string)as string
cs_vha=cs_vha+m.cs_vce
cs_vhb=createobject("roByteArray")
cs_vhb.fromasciistring(cs_vha)
cs_vhc=createobject("roEVPDigest")
cs_vhc.setup("md5")
cs_vhc.update(cs_vhb)
return cs_vhc.final()
end function
cs_vyf.cs_vcm=function()as double
if m.cs_vcp<0 then
if m.p_storage.cs_viy("installTime")then
cs_vco=comscore_stod(m.p_storage.cs_vix("installTime"))
else
cs_vco=m.p_genesis
m.p_storage.cs_viz("installTime",str(cs_vco))
end if
m.cs_vcp=cs_vco
end if
return m.cs_vcp
end function
cs_vyf.cs_vcq=function()as double
if m.cs_vct<0 then
cs_vcs=0
if m.p_storage.cs_viy("installTime")then
cs_vcs=comscore_stod(m.p_storage.cs_vix("previousGenesis"))
end if
m.cs_vct=cs_vcs
end if
return m.cs_vct
end function
cs_vyf.cs_vcu=function()as void
cs_vcv=comscore_unix_time()
if cs_vcv-m.p_genesis>m.cs_ve then
m.p_storage.cs_viz("previousGenesis",str(m.p_genesis))
m.p_genesis=cs_vcv
m.p_storage.cs_viz("genesis",str(m.p_genesis))
end if
end function
cs_vdm(cs_vyf)
cs_vyf.p_storage=cs_viu(cs_vyf)
cs_vyf.p_genesis=comscore_unix_time()
cs_vyf.cs_vcw=cs_vef(cs_vyf)
cs_vyf.p_keepalive=cs_vfv(cs_vyf)
cs_vyf.cs_vcm()
cs_vdf(cs_vyf)
cs_vec(cs_vyf)
if cs_vyf.p_storage.cs_viy("accumulatedForegroundTime")then
cs_vyf.cs_vcx=comscore_stoi(cs_vyf.p_storage.cs_vix("accumulatedForegroundTime"))
end if
if cs_vyf.p_storage.cs_viy("totalForegroundTime")then
cs_vyf.cs_vcy=comscore_stoi(cs_vyf.p_storage.cs_vix("totalForegroundTime"))
end if
if cs_vyf.p_storage.cs_viy("visitorId")then
cs_vyf.cs_vcz=cs_vyf.p_storage.cs_vix("visitorId")
end if
if cs_vyf.p_storage.cs_viy("currentVersion")then
if cs_vyf.p_storage.cs_vix("currentVersion")<>cs_vyf.cs_vh then
cs_vyf.p_storage.cs_viz("previousVersion",cs_vyf.p_storage.cs_vix("currentVersion"))
cs_vyf.p_storage.cs_viz("currentVersion",cs_vyf.cs_vh)
cs_vyf.cs_vdc=cs_vyf.cs_vh
else
cs_vyf.cs_vdc=cs_vyf.p_storage.cs_vix("currentVersion")
end if
else
cs_vyf.p_storage.cs_viz("currentVersion",cs_vyf.cs_vh)
cs_vyf.cs_vdc=cs_vyf.cs_vh
end if
if cs_vyf.p_storage.cs_viy("previousVersion")then
cs_vyf.cs_vde=cs_vyf.p_storage.cs_vix("previousVersion")
else
cs_vyf.p_storage.cs_viz("previousVersion",cs_vyf.cs_vdc)
cs_vyf.cs_vde=cs_vyf.cs_vdc
end if
cs_vyf.cs_vm.mark()
cs_vyf.cs_vn.mark()
cs_vyf.cs_vl.mark()
if cs_vyf.adframeworkavailable()=true and cs_vyf.cs_vk<>cs_vyf.cs_vi then
cs_vyf.setuseraf(true)
cs_vyf.setuserafsettermethods(true)
else
cs_vyf.setuseraf(false)
cs_vyf.setuserafsettermethods(false)
end if
return cs_vyf
end function
sub cs_vdf(dax as object)
cs_vdg=dax.p_storage
cs_vdi=0
if cs_vdg.cs_viy("lastActivityTime")then cs_vdi=comscore_stod(cs_vdg.cs_vix("lastActivityTime"))
cs_vdk=0
if cs_vdg.cs_viy("genesis")then cs_vdk=comscore_stod(cs_vdg.cs_vix("genesis"))
if(cs_vdi>0)then
cs_vdl=comscore_unix_time()-cs_vdi
if cs_vdl<dax.cs_ve then
if cs_vdk>0 and cs_vdk<comscore_unix_time()then
dax.p_genesis=cs_vdk
end if
else
cs_vdg.cs_viz("previousGenesis",str(cs_vdk))
end if
end if
cs_vdg.cs_viz("genesis",str(dax.p_genesis))
cs_vdg.cs_viz("lastActivityTime",str(comscore_unix_time()))
end sub
sub cs_vdm(dax as object)
cs_vdn=readasciifile("pkg:/manifest")
cs_vdv="AppName"
cs_vdw="1"
cs_vdx="0"
cs_vdy="0"
adframeworkavailable=false
cs_vha=cs_vdn.tokenize(chr(10))
for each cs_vdt in cs_vha
cs_vdt=cs_vdt.trim()
if len(cs_vdt)>0 then
cs_vdu=cs_vdt.tokenize("=")
if cs_vdu.count()=2 then
if cs_vdu[0]= "title" then
cs_vdv=cs_vdu[1]
else if cs_vdu[0]= "major_version" then
cs_vdw=cs_vdu[1]
else if cs_vdu[0]= "minor_version" then
cs_vdx=cs_vdu[1]
else if cs_vdu[0]= "build_version" then
cs_vdy=cs_vdu[1]
else if cs_vdu[0]= "bs_libs_required" and cs_vdu[1]= "roku_ads_lib" then
adframeworkavailable=true
end if
end if
end if
end for
dax.cs_vdz=cs_vdv
dax.cs_vea=cs_vdw+"." +cs_vdx+"." +cs_vdy
dax.cs_veb=adframeworkavailable
end sub
sub cs_vec(dax as object)
cs_ved=dax.p_storage
if(cs_ved.cs_viy("runs"))then
cs_vee=comscore_tostr(comscore_stoi(cs_ved.cs_vix("runs"))+1)
cs_ved.cs_viz("runs",cs_vee)
else
cs_ved.cs_viz("runs","0")
end if
end sub
function cs_vef(dax as object)as object
cs_vyf=createobject("roAssociativeArray")
cs_vyf.cs_vez=false
cs_vyf.cs_vfg=true
cs_vyf.cs_vfe=""
cs_vyf.cs_vff=""
cs_vyf.cs_vel="crossPublisherIdHash"
cs_vyf.cs_vrh=dax
cs_vyf.cs_ven=function()as void
cs_vfb=m.cs_vfj()
cs_vey=m.cs_vfn(cs_vfb)
if m.cs_vfg
m.cs_vfe=cs_vfb
if m.cs_vrh.p_storage.cs_viy(m.cs_vel)then
m.cs_vff=m.cs_vrh.p_storage.cs_vix(m.cs_vel)
end if
end if
if m.cs_vrh.p_storage.cs_viy(m.cs_vel)=false then
m.cs_vfe=cs_vfb
m.cs_vrh.p_storage.cs_viz(m.cs_vel,cs_vey)
m.cs_vff=cs_vey
else if((cs_vfb="none" and m.cs_vff="none")or(m.cs_vfg=false and m.cs_vff="none")or(cs_vfb<>"none" and cs_vey=m.cs_vff))
else
m.cs_vez=true
if(m.cs_vfg=false or cs_vfb="none" )
m.cs_vfe="none"
m.cs_vff="none"
else
m.cs_vfe=cs_vfb
m.cs_vff=cs_vey
end if
m.cs_vrh.p_storage.cs_viz(m.cs_vel,m.cs_vff)
end if
m.cs_vfg=false
end function
cs_vyf.cs_vfh=function()as string
return m.cs_vfe
end function
cs_vyf.cs_vfi=function()as boolean
return m.cs_vez
end function
cs_vyf.cs_vfj=function()as string
cs_vfm="none"
cs_vfl=createobject("roDeviceInfo")
if not cs_vfl.isridadisabled()
cs_vfm=cs_vfl.getrida()
end if
return cs_vfm
end function
cs_vyf.cs_vfn=function(string as string)as string
cs_vhb=createobject("roByteArray")
cs_vhb.fromasciistring(string)
cs_vhc=createobject("roEVPDigest")
cs_vhc.setup("md5")
cs_vmk=cs_vhc.process(cs_vhb)
return cs_vmk
end function
return cs_vyf
end function
function cseventtype()
if m.cs_vfs=invalid then m.cs_vfs=cs_vft()
return m.cs_vfs
end function
function cs_vft()as object
cs_vuc=createobject("roAssociativeArray")
cs_vuc.view="view"
cs_vuc.hidden="hidden"
cs_vuc.start="start"
cs_vuc.aggregate="aggregate"
cs_vuc.close="close"
cs_vuc.keep_alive="keep-alive"
return cs_vuc
end function
function cs_vfv(dax as object)as object
cs_vyf=createobject("roAssociativeArray")
cs_vyf.cs_vfx=createobject("roTimespan")
cs_vyf.cs_vfy=createobject("roDeviceInfo")
cs_vyf.cs_vfz=createobject("roArray",1,true)
cs_vyf.cs_vrh=dax
cs_vgb=cs_vyf.cs_vfy.getipaddrs()
if cs_vgb<>invalid then
for each key in cs_vgb
cs_vyf.cs_vfz.push(cs_vgb[key])
end for
end if
cs_vyf.reset=function()as void
m.cs_vfx.mark()
end function
cs_vyf.tick=function()as void
if m.cs_vrh.cs_vbe()then
if m.cs_vfx.totalmilliseconds()>m.cs_vrh.cs_vkc then
m.cs_vrh.notify(cseventtype().keep_alive)
m.cs_vfx.mark()
else
cs_vgi=false
cs_vge=m.cs_vfy.getipaddrs()
if cs_vge<>invalid then
for each key in cs_vge
cs_vgh=false
for cs_vyq=0 to m.cs_vfz.count()step 1
if m.cs_vfz[cs_vyq]=cs_vge[key]then
cs_vgh=true
exit for
end if
end for
if cs_vgh then
else
m.cs_vfz.push(cs_vge[key])
cs_vgi=true
end if
end for
if cs_vgi then
m.cs_vrh.notify(cseventtype().keep_alive)
m.cs_vfx.mark()
end if
end if
end if
end if
end function
if dax.cs_vbe()then
cs_vyf.cs_vfx.mark()
else
end if
return cs_vyf
end function
function cs_vgj(dax as object,cs_vvk as string,pixelurl as string,labels as object)as object
dax.cs_vcu()
if cs_vvk=cseventtype().start then return cs_vhs(dax,cs_vvk,pixelurl,labels)
if cs_vvk=cseventtype().aggregate then return cs_vih(dax,cs_vvk,pixelurl,labels)
return csapplicationmeasurement(dax,cs_vvk,pixelurl,labels)
end function
function csmeasurement(dax as object)as object
cs_vyf=createobject("roAssociativeArray")
cs_vyf.labels=createobject("roAssociativeArray")
cs_vyf.setpixelurl=function(pixelurl as string)as void
cs_vgn=instr(1,pixelurl,"?")
if cs_vgn>=1 and len(pixelurl)>cs_vgn then
m.labels["name"]=right(pixelurl,len(pixelurl)-cs_vgn)
m.pixelurl=left(pixelurl,cs_vgn)
else
m.pixelurl=pixelurl
end if
end function
cs_vyf.setpixelurl(dax.pixelurl())
cs_vyf.cs_vgo=comscore_unix_time()
cs_vyf.cs_vgp=function()as string
cs_vlk=""
cs_vgs=createobject("roArray",110,true)
cs_vgs=["c1","c2","ca2","cb2","cc2","cd2","ns_site","ca_ns_site","cb_ns_site","cc_ns_site","cd_ns_site","ns_vsite","ca_ns_vsite","cb_ns_vsite","cc_ns_vsite","cd_ns_vsite","ns_alias","ca_ns_alias","cb_ns_alias","cc_ns_alias","cd_ns_alias","ns_ap_an","ca_ns_ap_an","cb_ns_ap_an","cc_ns_ap_an","cd_ns_ap_an","ns_ap_pn","ns_ap_pv","c12","ca12","cb12","cc12","cd12","ns_ak","ns_ar","ns_ap_hw","name","ns_ap_ni","ns_ap_ec","ns_ap_ev","ns_ap_device","ns_ap_id","ns_ap_csf","ns_ap_bi","ns_ap_pfm","ns_ap_pfv","ns_ap_ver","ca_ns_ap_ver","cb_ns_ap_ver","cc_ns_ap_ver","cd_ns_ap_ver","ns_ap_sv","ns_ap_bv","ns_ap_cv","ns_ap_smv","ns_type","ca_ns_type","cb_ns_type","cc_ns_type","cd_ns_type","ns_radio","ns_nc","cs_partner","cs_xcid","cs_impid","ns_ap_ui","ca_ns_ap_ui","cb_ns_ap_ui","cc_ns_ap_ui","cd_ns_ap_ui","ns_ap_gs","ns_ap_ie","ns_st_sv","ns_st_pv","ns_st_smv","ns_st_it","ns_st_id","ns_st_ec","ns_st_sp","ns_st_sc","ns_st_psq","ns_st_asq","ns_st_sq","ns_st_ppc","ns_st_apc","ns_st_spc","ns_st_atpc","ns_st_cn","ns_st_ev","ns_st_po","ns_st_cl","ns_st_el","ns_st_sl","ns_st_pb","ns_st_hc","ns_st_mp","ca_ns_st_mp","cb_ns_st_mp","cc_ns_st_mp","cd_ns_st_mp","ns_st_mv","ca_ns_st_mv","cb_ns_st_mv","cc_ns_st_mv","cd_ns_st_mv","ns_st_pn","ns_st_tp","ns_st_ad","ns_st_li","ns_st_ci","ns_st_si","ns_st_pt","ns_st_dpt","ns_st_ipt","ns_st_ap","ns_st_dap","ns_st_et","ns_st_det","ns_st_upc","ns_st_dupc","ns_st_iupc","ns_st_upa","ns_st_dupa","ns_st_iupa","ns_st_lpc","ns_st_dlpc","ns_st_lpa","ns_st_dlpa","ns_st_pa","ns_st_ldw","ns_st_ldo","ns_st_ie","ns_ap_jb","ns_ap_et","ns_ap_res","ns_ap_sd","ns_ap_po","ns_ap_ot","ns_ap_c12m","cs_c12u","ca_cs_c12u","cb_cs_c12u","cc_cs_c12u","cd_cs_c12u","ns_ap_install","ns_ap_updated","ns_ap_lastrun","ns_ap_cs","ns_ap_runs","ns_ap_usage","ns_ap_fg","ns_ap_ft","ns_ap_dft","ns_ap_bt","ns_ap_dbt","ns_ap_dit","ns_ap_as","ns_ap_das","ns_ap_it","ns_ap_uc","ns_ap_aus","ns_ap_daus","ns_ap_us","ns_ap_dus","ns_ap_ut","ns_ap_oc","ns_ap_uxc","ns_ap_uxs","ns_ap_lang","ns_ap_ar","ns_ap_miss","ns_ts","ns_ap_cfg","ns_ap_env","ns_st_ca","ns_st_cp","ns_st_er","ca_ns_st_er","cb_ns_st_er","cc_ns_st_er","cd_ns_st_er","ns_st_pe","ns_st_ui","ca_ns_st_ui","cb_ns_st_ui","cc_ns_st_ui","cd_ns_st_ui","ns_st_bc","ns_st_dbc","ns_st_bt","ns_st_dbt","ns_st_bp","ns_st_lt","ns_st_skc","ns_st_dskc","ns_st_ska","ns_st_dska","ns_st_skd","ns_st_skt","ns_st_dskt","ns_st_pc","ns_st_dpc","ns_st_pp","ns_st_br","ns_st_pbr","ns_st_rt","ns_st_prt","ns_st_ub","ns_st_vo","ns_st_pvo","ns_st_ws","ns_st_pws","ns_st_ki","ns_st_rp","ns_st_bn","ns_st_tb","ns_st_an","ns_st_ta","ns_st_pl","ns_st_pr","ns_st_tpr","ns_st_sn","ns_st_en","ns_st_ep","ns_st_tep","ns_st_sr","ns_st_ty","ns_st_ct","ns_st_cs","ns_st_ge","ns_st_st","ns_st_stc","ns_st_ce","ns_st_ia","ns_st_dt","ns_st_ddt","ns_st_tdt","ns_st_tm","ns_st_dtm","ns_st_ttm","ns_st_de","ns_st_pu","ns_st_ti","ns_st_cu","ns_st_fee","ns_st_ft","ns_st_at","ns_st_pat","ns_st_vt","ns_st_pvt","ns_st_tt","ns_st_ptt","ns_st_cdn","ns_st_pcdn","ns_st_amg","ns_st_ami","ns_st_amp","ns_st_amt","ns_st_ams","ns_ap_i1","ns_ap_i2","ns_ap_i3","ns_ap_i4","ns_ap_i5","ns_ap_i6","ns_ap_referrer","ns_clid","ns_campaign","ns_source","ns_mchannel","ns_linkname","ns_fee","gclid","utm_campaign","utm_source","utm_medium","utm_term","utm_content","ns_ecommerce","ns_ec_sv","ns_client_id","ns_order_id","ns_ec_cur","ns_orderline_id","ns_orderlines","ns_prod_id","ns_qty","ns_prod_price","ns_prod_grp","ns_brand","ns_shop","ns_category","category","ns_c","ns_search_term","ns_search_result","ns_m_exp","ns_m_chs","c3","ca3","cb3","cc3","cd3","c4","ca4","cb4","cc4","cd4","c5","ca5","cb5","cc5","cd5","c6","ca6","cb6","cc6","cd6","c10","c11","c13","c14","c15","c16","c7","c8","c9","ns_ap_er","ns_st_amc"]
cs_vgt={}
for each label in cs_vgs
if m.labels[label]<>invalid then
cs_vlk=cs_vlk+"&" +comscore_url_encode(label)+ "=" +comscore_url_encode(m.labels[label])
cs_vgt.addreplace(label,true)
end if
end for
for each key in m.labels
if m.labels[key]<>invalid and cs_vgt[key]=invalid then
cs_vlk=cs_vlk+"&" +comscore_url_encode(key)+ "=" +comscore_url_encode(m.labels[key])
end if
end for
if len(cs_vlk)>0 then
return right(cs_vlk,len(cs_vlk)-1)
else
return cs_vlk
end if
end function
return cs_vyf
end function
function cs_vgw(dax as object,cs_vvk as string,pixelurl as string,labels as object)as object
cs_vyf=csmeasurement(dax)
cs_vhq=createobject("roDeviceInfo")
if pixelurl<>invalid and pixelurl<>"" then cs_vyf.setpixelurl(pixelurl)
cs_vyf.labels["c1"]= "19"
cs_vyf.labels["ns_ap_an"]=dax.appname()
cs_vyf.labels["ns_ap_pn"]= "roku"
if dax.cs_vhv then
dax.cs_vcw.cs_ven()
cs_vyf.labels["ns_ar"]=dax.cs_vcw.cs_vfh()
if dax.cs_vcw.cs_vfi()then
cs_vyf.labels["ns_ap_ni"]= "1"
end if
end if
if dax.version()<>dax.previousversion()or(dax.p_storage.cs_viy("runs")=true and comscore_stoi(dax.p_storage.cs_vix("runs"))=0)then
cs_vyf.labels["c12"]=dax.visitorid()
else
visitorid=""
if dax.p_storage.cs_viy("visitorId")then
visitorid=dax.p_storage.cs_vix("visitorId")
else
cs_vhq=createobject("roDeviceInfo")
cs_vha=cs_vhq.getchannelclientid()+dax.cs_vce
cs_vhb=createobject("roByteArray")
cs_vhb.fromasciistring(cs_vha)
cs_vhc=createobject("roEVPDigest")
cs_vhc.setup("md5")
cs_vhc.update(cs_vhb)
visitorid=cs_vhc.final()
dax.p_storage.cs_viz("visitorId",visitorid)
end if
cs_vyf.labels["c12"]=visitorid
end if
if findmemberfunction(cs_vhq,"GetChannelClientId")<>invalid then
cs_vhd=createobject("roByteArray")
cs_vhd.fromasciistring(cs_vhq.getchannelclientid())
cs_vhe=createobject("roEVPDigest")
cs_vhe.setup("md5")
cs_vhe.update(cs_vhd)
cs_vyf.labels["ns_ap_i1"]=cs_vhe.final()
cs_vhf=createobject("roEVPDigest")
cs_vhf.setup("sha1")
cs_vhf.update(cs_vhd)
cs_vyf.labels["ns_ap_i6"]=cs_vhf.final()
end if
if findmemberfunction(cs_vhq,"IsRIDADisabled")<>invalid and findmemberfunction(cs_vhq,"GetRIDA")<>invalid then
if cs_vhq.isridadisabled()=false then
cs_vhg=createobject("roByteArray")
cs_vhg.fromasciistring(cs_vhq.getrida())
cs_vhh=createobject("roEVPDigest")
cs_vhh.setup("md5")
cs_vhh.update(cs_vhg)
cs_vyf.labels["ns_ap_i3"]=cs_vhh.final()
cs_vhi=createobject("roEVPDigest")
cs_vhi.setup("sha1")
cs_vhi.update(cs_vhg)
cs_vyf.labels["ns_ap_i5"]=cs_vhi.final()
end if
end if
cs_vyf.labels["ns_ap_device"]=cs_vhq.getmodel()
cs_vyf.labels["ns_ap_as"]=comscore_tostr(dax.p_genesis)
cs_vyf.labels["ns_type"]=cs_vvk
cs_vyf.labels["ns_ap_ev"]=cs_vvk
cs_vyf.labels["ns_ts"]=comscore_tostr(cs_vyf.cs_vgo)
cs_vyf.labels["ns_ap_pfv"]=cs_vhq.getversion()
cs_vyf.labels["ns_nc"]= "1"
if(labels["ns_st_ev"]=invalid)then
if dax.cs_vhj=0 then
if dax.cs_vcy>0 then
cs_vyf.labels["ns_ap_dft"]=comscore_tostr(dax.cs_vcx)
cs_vyf.labels["ns_ap_ft"]=comscore_tostr(dax.cs_vcy)
end if
else
cs_vyf.labels["ns_ap_dft"]=comscore_tostr(dax.cs_vm.totalmilliseconds())
cs_vyf.labels["ns_ap_ft"]=comscore_tostr(dax.cs_vn.totalmilliseconds())
end if
end if
cs_vhk=dax.getlabels()
for each key in cs_vhk
cs_vyf.labels[key]=cs_vhk[key]
end for
for each key in labels
cs_vyf.labels[key]=labels[key]
end for
return cs_vyf
end function
function csapplicationmeasurement(dax as object,cs_vvk as string,pixelurl as string,labels as object)as object
cs_vho=cseventtype().hidden
if cs_vvk=cseventtype().start or cs_vvk=cseventtype().view then cs_vho=cseventtype().view
cs_vyf=cs_vgw(dax,cs_vho,pixelurl,labels)
cs_vyf.labels["ns_ap_ev"]=cs_vvk
cs_vyf.labels["ns_ap_ver"]=dax.appversion()
cs_vhq=createobject("roDeviceInfo")
cs_vhr=cs_vhq.getdisplaysize()
cs_vyf.labels["ns_ap_res"]=stri(cs_vhr.w).trim()+ "x" +stri(cs_vhr.h).trim()
cs_vyf.labels["ns_ap_lang"]=cs_vhq.getcurrentlocale()
cs_vyf.labels["ns_ap_sv"]=dax.version()
cs_vyf.labels["ns_ap_smv"]= "2.10"
return cs_vyf
end function
function cs_vhs(dax as object,cs_vvk as string,pixelurl as string,labels as object)as object
cs_vyf=csapplicationmeasurement(dax,cs_vvk,pixelurl,labels)
cs_vyf.labels["ns_ap_install"]= "yes"
cs_vyf.labels["ns_ap_runs"]=dax.p_storage.cs_vix("runs")
cs_vyf.labels["ns_ap_gs"]=comscore_tostr(dax.cs_vcm())
cs_vyf.labels["ns_ap_lastrun"]=comscore_tostr(dax.cs_vcq())
cs_vig=""
if dax.cs_vhv=true then
cs_vig=cs_vig+"1"
else
cs_vig=cs_vig+"0"
end if
if dax.cs_vhy=true then
cs_vig=cs_vig+"1"
else
cs_vig=cs_vig+"0"
end if
if dax.cs_vib=true then
cs_vig=cs_vig+"1"
else
cs_vig=cs_vig+"0"
end if
if dax.cs_vie=true then
cs_vig=cs_vig+"1"
else
cs_vig=cs_vig+"0"
end if
cs_vyf.labels["ns_ap_cfg"]=cs_vig
return cs_vyf
end function
function cs_vih(dax as object,cs_vvk as string,pixelurl as string,labels as object)as object
cs_vyf=csapplicationmeasurement(dax,cs_vvk,pixelurl,labels)
return cs_vyf
end function
function cs_vij(cs_vob as object)as object
cs_vyf=createobject("roAssociativeArray")
cs_vyf.cs_vob=cs_vob
cs_vyf.cs_vim=function()as object
cs_vin=createobject("roUrlTransfer")
m.cs_vio=createobject("roMessagePort")
cs_vin.setport(m.cs_vio)
cs_vin.setcertificatesfile("common:/certs/ca-bundle.crt")
cs_vin.enableencodings(true)
cs_vin.addheader("Expect","")
cs_vip=m.cs_vob.pixelurl+m.cs_vob.cs_vgp()
if cscomscore().log_debug then print"Dispatching: " +cs_vip
cs_vin.seturl(cs_vip)
cs_vin.setrequest("GET")
m.dispatch(cs_vin)
cscomscore().cs_vbg()
if(m.cs_vob.labels["ns_st_ev"]=invalid)then
cscomscore().cs_vbh()
end if
end function
cs_vyf.dispatch=function(cs_vin as object)
if(cs_vin.asyncgettostring())then wait(500,cs_vin.getport())
end function
return cs_vyf
end function
function comscoresgbridge(cs_vxl as object)as object
cs_vyf=createobject("roAssociativeArray")
cs_vyf.cs_vxl=cs_vxl
cs_vyf.comscoretask=function()as object
return m.cs_vxl
end function
cs_vyf.setcustomerc2=function(c2 as string)as void
m.cs_vxn("SetCustomerC2",[c2])
end function
cs_vyf.setpublishersecret=function(salt as string)as void
m.cs_vxn("SetPublisherSecret",[salt])
end function
cs_vyf.start=function(labels=invalid as object)as void
m.cs_vxn("Start",[labels])
end function
cs_vyf.view=function(labels=invalid as object)as void
m.cs_vxn("View",[labels])
end function
cs_vyf.hidden=function(labels=invalid as object)as void
m.cs_vxn("Hidden",[labels])
end function
cs_vyf.close=function()as void
m.cs_vxn("Close",invalid)
end function
cs_vyf.tick=function()as void
m.cs_vxn("Tick",invalid)
end function
cs_vyf.setpixelurl=function(cs_vxd as string)as void
m.cs_vxn("SetPixelURL",[cs_vxd])
end function
cs_vyf.setsecure=function(secure as boolean)as void
m.cs_vxn("SetSecure",[secure])
end function
cs_vyf.setlabels=function(cs_vvd as object)as void
m.cs_vxn("SetLabels",[cs_vvd])
end function
cs_vyf.setlabel=function(key as string,cs_vxd as string)as void
m.cs_vxn("SetLabel",[key,cs_vxd])
end function
cs_vyf.setappname=function(name as string)as void
m.cs_vxn("SetAppName",[name])
end function
cs_vyf.setappversion=function(version as string)as void
m.cs_vxn("SetAppVersion",[version])
end function
cs_vyf.setuseraf=function(enabled as boolean)as void
m.cs_vxn("SetUseRAF",[enabled])
end function
cs_vyf.setuserafsettermethods=function(enabled as boolean)as void
m.cs_vxn("SetUseRAFSetterMethods",[enabled])
end function
cs_vyf.cs_vxn=function(name as string,args)
cs_vxo={}
cs_vxo["component"]= "app"
cs_vxo["methodName"]=name
cs_vxo["args"]=args
m.cs_vxl["apiCall"]=cs_vxo
end function
return cs_vyf
end function
function cs_viu(context as object)as object
cs_vyf=createobject("roAssociativeArray")
cs_vyf.cs_viw=createobject("roRegistrySection","com.comscore." +context.appname()+ "-2")
cs_vyf.cs_vix=function(key)as string
if m.cs_viw.exists(key)then return m.cs_viw.read(key)
return""
end function
cs_vyf.cs_viy=function(key)as boolean
return m.cs_viw.exists(key)
end function
cs_vyf.cs_viz=function(key,val)as void
m.cs_viw.write(key,val)
m.cs_viw.flush()
end function
cs_vyf.cs_vja=function(key)as void
m.cs_viw.delete(key)
m.cs_viw.flush()
end function
return cs_vyf
end function
function comscore_unix_time()as double
if m.cs_vjc=invalid then
m.cs_vjc=createobject("roAssociativeArray")
m.cs_vjc.cs_vjd=createobject("roTimespan")
cs_vzr=createobject("roDateTime")
cs_vzr.mark()
m.cs_vjc.offset#=cs_vzr.asseconds()*1000#
m.cs_vjc.cs_vjd.mark()
end if
m.p_csmillis#=m.cs_vjc.cs_vjd.totalmilliseconds()
return m.cs_vjc.offset#+m.p_csmillis#
end function
function comscore_tostr(obj as object)as string
cs_vjn=type(obj)
if cs_vjn="String" or cs_vjn="roString" then return obj
if cs_vjn="Integer" or cs_vjn="roInt" then return stri(obj).trim()
if cs_vjn="Double" or cs_vjn="roIntrinsicDouble" or cs_vjn="Float" or cs_vjn="roFloat" then
num#=obj
mil#=1000000
if abs(num#)<=mil#then return str(num#).trim()
cs_vjp=int(num#/mil#)
if num#/mil#-cs_vjp<0 then cs_vjp=cs_vjp-1
cs_vjq=int((num#-mil#*cs_vjp))
cs_vjr=cs_vjp.tostr()
cs_vjs=string(6-cs_vjq.tostr().len(),"0")+cs_vjq.tostr()
return cs_vjr+cs_vjs
end if
return"UNKN" +cs_vjn
end function
function comscore_stod(obj as string)as double
len=obj.len()
if len<=6 then
cs_vlk#=val(obj)
return cs_vlk#
end if
left=obj.left(len-6)
right=obj.right(6)
left#=val(left)
right#=val(right)
mil#=1000000
cs_vlk#=left#*mil#+right#
return cs_vlk#
end function
function comscore_stoi(obj as string)as integer
return int(val(obj))
end function
function comscore_url_encode(cs_vha as string)as string
if m.cs_vju=invalid then m.cs_vju=createobject("roUrlTransfer")
return m.cs_vju.urlencode(cs_vha)
end function
function comscore_extend(toobject as object,fromobject as object)
if toobject<>invalid and fromobject<>invalid and type(toobject)= "roAssociativeArray" and type(fromobject)= "roAssociativeArray" then
for each key in fromobject
toobject.addreplace(key,fromobject[key])
end for
end if
end function
function csstreamsense(dax=invalid as object)as object
cs_vyf=createobject("roAssociativeArray")
onstatechange=invalid
labels=invalid
cs_vyf.cs_vjw="roku"
cs_vyf.cs_vjx="4.1503.03"
cs_vyf.cs_vjy=500#
cs_vyf.cs_vjz=10#*1000#
cs_vyf.cs_vka=60#*1000#
cs_vyf.cs_vkb=6
cs_vyf.cs_vkc=1200000#
cs_vyf.cs_vkd=500#
cs_vyf.cs_vke=1500
cs_vyf.cs_vrh=invalid
cs_vyf.cs_vri=invalid
cs_vyf.p_pixelurl=""
cs_vyf.cs_vqs=0#
cs_vyf.cs_vqb=0#
cs_vyf.cs_vqr=invalid
cs_vyf.cs_vpb=0
cs_vyf.cs_vrj=invalid
cs_vyf.cs_vlw=true
cs_vyf.cs_vqf=true
cs_vyf.cs_vpd=-1#
cs_vyf.cs_vom=0
cs_vyf.cs_von=-1#
cs_vyf.cs_voj=-1#
cs_vyf.cs_vou=-1#
cs_vyf.cs_vqm=invalid
cs_vyf.cs_vph=invalid
cs_vyf.cs_vnf=invalid
cs_vyf.cs_vlh=invalid
cs_vyf.cs_vle=invalid
cs_vyf.cs_vnw=""
cs_vyf.cs_vny=""
cs_vyf.cs_vly=false
cs_vyf.cs_vnr=-1#
cs_vyf.cs_vns=invalid
cs_vyf.cs_vnt=invalid
cs_vyf.engageto=function(screen as object)as void
m.reset()
m.cs_vle=screen
screen.cs_vng=m
cs_vlg={}
cs_vlg["ns_st_cu"]=screen.videoclip.streamurls[0]
if screen.videoclip.cs_vdv<>invalid then cs_vlg["ns_st_ep"]=screen.videoclip.cs_vdv
m.setclip(cs_vlg)
m.cs_vlh=createobject("roTimespan")
end function
cs_vyf.onplayerevent=function(cs_vlj as object)as boolean
cs_vlk=false
m.cs_vrh.tick()
if cs_vlj=invalid then
if m.getstate()=csstreamsensestate().playing and m.cs_vlh.totalmilliseconds()>m.cs_vke then
m.notify(csstreamsenseeventtype().pause)
else
m.tick()
end if
else if cs_vlj.ispaused()then
m.notify(csstreamsenseeventtype().pause)
else if cs_vlj.isstreamstarted()then
m.notify(csstreamsenseeventtype().buffer)
else if cs_vlj.isplaybackposition()then
m.notify(csstreamsenseeventtype().play,cs_vlj.getindex()*1000)
m.cs_vlh.mark()
else if cs_vlj.isscreenclosed()or cs_vlj.isfullresult()or cs_vlj.ispartialresult()or cs_vlj.isrequestfailed()then
m.notify(csstreamsenseeventtype().end)
cs_vlk=true
end if
return cs_vlk
end function
cs_vyf.tick=function()as void
cs_vzr=comscore_unix_time()
if m.cs_voj>=0 and m.cs_voj<=cs_vzr then
m.cs_vol()
end if
if m.cs_vou>=0 and m.cs_vou<=cs_vzr then
m.cs_vos()
end if
if m.cs_vpd>=0 and m.cs_vpd<=cs_vzr then
m.cs_voz()
end if
if m.cs_vnr>=0 and m.cs_vnr<=cs_vzr then
m.cs_vnh(m.cs_vns,m.cs_vnt)
end if
end function
cs_vyf.isidle=function()as boolean
return m.getstate()=csstreamsensestate().idle
end function
cs_vyf.setpixelurl=invalid
cs_vyf.pixelurl=invalid
cs_vyf.notify=function(cs_vvk as object,position=-1#as double,eventlabelmap=invalid as object)as void
cs_vqg=m.cs_vpl(cs_vvk)
cs_vnn=createobject("roAssociativeArray")
if eventlabelmap<>invalid then cs_vnn.append(eventlabelmap)
m.cs_vpe(cs_vnn)
if not cs_vnn.doesexist("ns_st_po")then
cs_vnn["ns_st_po"]=comscore_tostr(position)
end if
if cs_vvk=csstreamsenseeventtype().play or cs_vvk=csstreamsenseeventtype().pause or cs_vvk=csstreamsenseeventtype().buffer or cs_vvk=csstreamsenseeventtype().end then
if m.ispauseplayswitchdelayenabled()and m.cs_vpi(m.cs_vqr)and m.cs_vpi(cs_vqg)and not(m.cs_vqr=csstreamsensestate().playing and cs_vqg=csstreamsensestate().paused and m.cs_vnt=invalid)then
m.cs_vnh(cs_vqg,cs_vnn,m.cs_vjy)
else
m.cs_vnh(cs_vqg,cs_vnn)
end if
else
if m.cs_vqn(cs_vnn)<0 then
cs_vnn["ns_st_po"]=comscore_tostr(m.cs_vqh(m.cs_vqo(cs_vnn)))
end if
labels=m.cs_vqt(cs_vvk,cs_vnn)
labels.append(cs_vnn)
m.dispatch(labels,false)
m.cs_vpb=m.cs_vpb+1
end if
end function
cs_vyf.getlabels=function()as object
return m.cs_vri
end function
cs_vyf.sharingsdkpersistentlabels=function()as boolean
return m.cs_vlw
end function
cs_vyf.sharesdkpersistentlabels=function(flag as boolean)
m.cs_vlw=flag
end function
cs_vyf.ispauseonbufferingenabled=function()as boolean
return m.cs_vqf
end function
cs_vyf.setpauseonbufferingenabled=function(pauseonbufferingenabled as boolean)
m.cs_vqf=pauseonbufferingenabled
end function
cs_vyf.ispauseplayswitchdelayenabled=function()as boolean
return m.cs_vly
end function
cs_vyf.setpauseplayswitchdelayenabled=function(pauseplayswitchdelayenabled as boolean)as void
m.cs_vly=pauseplayswitchdelayenabled
end function
cs_vyf.setclip=function(labels as object,loop=false as boolean)as boolean
cs_vmk=false
if m.cs_vqr=csstreamsensestate().idle then
m.cs_vrj.getclip().reset()
m.cs_vrj.getclip().setlabels(labels,invalid)
if loop=true then
m.cs_vrj.cs_vvr()
end if
if m.cs_vrh.useraf()=true and m.cs_vrh.userafsettermethods()=true and m.cs_vmf(labels)=true then
if labels["ns_st_ci"]<>invalid and labels["ns_st_ci"]<>"*null" then
m.cs_vmc(labels["ns_st_ci"])
else
m.cs_vmc("")
end if
if labels["ns_st_ge"]<>invalid and labels["ns_st_ge"]<>"*null" then
m.cs_vmd(labels["ns_st_ge"],false)
else
m.cs_vmd("",false)
end if
if labels["ns_st_cl"]<>invalid and labels["ns_st_cl"]<>"*null" then
m.cs_vme(int(comscore_stoi(labels["ns_st_cl"])/1000))
else
m.cs_vme(0)
end if
end if
cs_vmk=true
end if
return cs_vmk
end function
cs_vyf.cs_vmc=function(id as string)as void
if m.cs_vrh.useraf()=true and m.cs_vrh.userafsettermethods()=true and m.cs_vrh.adinterface()<>invalid then
m.cs_vrh.adinterface().setcontentid(id)
if m.cs_vrh.log_debug then print"Content Id successfully set with value " +id
end if
end function
cs_vyf.cs_vmd=function(genres as string,kidscontent as boolean)as void
if m.cs_vrh.useraf()=true and m.cs_vrh.userafsettermethods()=true and m.cs_vrh.adinterface()<>invalid then
m.cs_vrh.adinterface().setcontentgenre(genres,kidscontent)
if m.cs_vrh.log_debug then print"Genre successfully set with value " +genres
end if
end function
cs_vyf.cs_vme=function(length as integer)as void
if m.cs_vrh.useraf()=true and m.cs_vrh.userafsettermethods()=true and m.cs_vrh.adinterface()<>invalid then
m.cs_vrh.adinterface().setcontentlength(length)
if m.cs_vrh.log_debug then print"Content Length successfully set with value " +comscore_tostr(length)
end if
end function
cs_vyf.cs_vmf=function(labels as object)as boolean
cs_vmk=false
if labels=invalid then
return true
end if
if labels["ns_st_ad"]=invalid or(labels["ns_st_ad"]<>invalid and(labels["ns_st_ad"]= "pre-roll" or labels["ns_st_ct"]= "aa11" or labels["ns_st_ct"]= "aa31" or labels["ns_st_ct"]= "va11" or labels["ns_st_ct"]= "va31"))then
cs_vmk=true
end if
return cs_vmk
end function
cs_vyf.setplaylist=function(labels as object)as boolean
cs_vmk=false
if m.cs_vqr=csstreamsensestate().idle then
m.cs_vrj.cs_vwn()
m.cs_vrj.reset()
m.cs_vrj.getclip().reset()
m.cs_vrj.setlabels(labels,invalid)
cs_vmk=true
end if
return cs_vmk
end function
cs_vyf.importstate=function(labels as object)as void
m.reset()
cs_vml=createobject("roAssociativeArray")
cs_vml.append(labels)
m.cs_vrj.cs_vws(cs_vml,invalid)
m.cs_vrj.getclip().cs_vws(cs_vml,invalid)
m.cs_vws(cs_vml)
m.cs_vpb=m.cs_vpb+1
end function
cs_vyf.exportstate=function()as object
return m.cs_vph
end function
cs_vyf.getversion=function()as string
return m.cs_vjx
end function
cs_vyf.addlistener=function(cs_vmo as object)as void
if cs_vmo=invalid or cs_vmo.onstatechange=invalid then return
m.cs_vnf.push(cs_vmo)
end function
cs_vyf.removelistener=function(cs_vmo as object)as void
if cs_vmo=invalid or cs_vmo.onstatechange=invalid then return
if m.cs_vnf.count()>0 then
cs_vmq=0
while cs_vmq<m.cs_vnf.count()
if cs_vmo.onstatechange=m.cs_vnf[cs_vmq].onstatechange then exit while
cs_vmq=cs_vmq+1
end while
if cs_vmq<m.cs_vnf.count()then m.cs_vnf.delete(cs_vmq)
end if
end function
cs_vyf.getclip=function()as object
return m.cs_vrj.getclip()
end function
cs_vyf.getplaylist=function()as object
return m.cs_vrj
end function
cs_vyf.setlabels=function(cs_vvd as object)as void
if cs_vvd<>invalid then
for each label in cs_vvd
m.setlabel(label,cs_vvd[label])
end for
end if
end function
cs_vyf.getlabel=function(name as string)as string
return m.cs_vri[name]
end function
cs_vyf.setlabel=function(name as string,cs_vxd as string)as void
if cs_vxd=invalid then
m.cs_vri.delete(name)
else
m.cs_vri[name]=cs_vxd
end if
end function
cs_vyf.reset=function(keeplabels=invalid as object)as void
m.cs_vrj.reset(keeplabels)
m.cs_vrj.cs_vwl(0)
m.cs_vrj.cs_vvm(comscore_tostr(comscore_unix_time())+ "_1")
m.cs_vrj.getclip().reset(keeplabels)
if keeplabels<>invalid and type(keeplabels)= "roArray" and keeplabels.count()>0 then
cs_vxt(m.cs_vri,keeplabels)
else
m.cs_vri.clear()
end if
m.cs_vpb=1
m.cs_vom=0
m.cs_voe()
m.cs_voh()
m.cs_vpd=-1#
m.cs_voj=-1#
m.cs_von=-1#
m.cs_vou=-1#
m.cs_vqr=csstreamsensestate().idle
m.cs_vqs=-1#
m.cs_vqm=invalid
m.cs_vnw=m.cs_vjw
m.cs_vny=m.cs_vjx
m.cs_vph=invalid
m.cs_vqb=0#
m.cs_vnf=createobject("roArray",1,true)
m.cs_vnq()
if m.cs_vle<>invalid then m.cs_vle.cs_vng=invalid
end function
cs_vyf.getstate=function()as object
return m.cs_vqr
end function
cs_vyf.cs_vnh=function(cs_vqg as object,eventlabelmap as object,cs_vni=-1#as double)as void
m.cs_vnq()
if cs_vni>=0 then
m.cs_vnr=comscore_unix_time()+cs_vni
m.cs_vns=cs_vqg
m.cs_vnt=eventlabelmap
else if m.cs_vqp(cs_vqg)=true then
cs_vpy=m.getstate()
previousstatechangetimestamp#=m.cs_vqs
eventtime#=m.cs_vqo(eventlabelmap)
delta#=0
if previousstatechangetimestamp#>=0 then
delta#=eventtime#-previousstatechangetimestamp#
end if
m.cs_vpv(m.getstate(),eventlabelmap)
m.cs_vqa(cs_vqg,eventlabelmap)
m.cs_vqq(cs_vqg)
for each cs_vmo in m.cs_vnf
if cs_vmo.onstatechange<>invalid then cs_vmo.onstatechange(cs_vpy,cs_vqg,eventlabelmap,delta#)
end for
m.cs_vws(eventlabelmap)
m.cs_vrj.cs_vws(eventlabelmap,cs_vqg)
m.cs_vrj.getclip().cs_vws(eventlabelmap,cs_vqg)
cs_vnn=m.cs_vqt(m.cs_vpq(cs_vqg),eventlabelmap)
cs_vnn.append(eventlabelmap)
if m.cs_vqj(m.cs_vqr)=true then
m.dispatch(cs_vnn)
m.cs_vqm=m.cs_vqr
m.cs_vpb=m.cs_vpb+1
end if
end if
end function
cs_vyf.cs_vnq=function()as void
m.cs_vnr=-1#
m.cs_vns=invalid
m.cs_vnt=invalid
end function
cs_vyf.cs_vws=function(labels as object)as void
cs_vxd=labels["ns_st_mp"]
if cs_vxd<>invalid then
m.cs_vnw=cs_vxd
labels.delete("ns_st_mp")
end if
cs_vxd=labels["ns_st_mv"]
if cs_vxd<>invalid then
m.cs_vny=cs_vxd
labels.delete("ns_st_mv")
end if
cs_vxd=labels["ns_st_ec"]
if cs_vxd<>invalid then
m.cs_vpb=comscore_stoi(cs_vxd)
labels.delete("ns_st_ec")
end if
end function
cs_vyf.dispatch=function(eventlabelmap as object,snapshot=true as boolean)as void
if snapshot=true then m.cs_vpg(eventlabelmap)
if not m.cs_vpf()then
cs_vob=cs_vud(m,m.cs_vrh,eventlabelmap,m.pixelurl())
m.cs_vrh.dispatch(cs_vob)
end if
end function
cs_vyf.cs_voc=function()as void
if m.cs_von>=0 then
interval#=m.cs_von
else
interval#=m.cs_vka
if m.cs_vom<m.cs_vkb then interval#=m.cs_vjz
end if
m.cs_voj=comscore_unix_time()+interval#
end function
cs_vyf.cs_voe=function()as void
m.cs_von=m.cs_voj-comscore_unix_time()
m.cs_voj=-1#
end function
cs_vyf.cs_voh=function()as void
m.cs_von=-1#
m.cs_voj=-1#
m.cs_vom=0
end function
cs_vyf.cs_vol=function()as void
m.cs_vom=m.cs_vom+1
eventlabelmap=m.cs_vqt(csstreamsenseeventtype().heart_beat,invalid)
m.dispatch(eventlabelmap)
m.cs_von=-1
m.cs_voc()
end function
cs_vyf.cs_voo=function()as void
m.cs_voq()
m.cs_vou=comscore_unix_time()+m.cs_vkc
end function
cs_vyf.cs_voq=function()as void
m.cs_vou=-1#
end function
cs_vyf.cs_vos=function()as void
eventlabelmap=m.cs_vqt(csstreamsenseeventtype().keep_alive,invalid)
m.dispatch(eventlabelmap)
m.cs_vpb=m.cs_vpb+1
m.cs_vou=comscore_unix_time()+m.cs_vkc
end function
cs_vyf.cs_vov=function()as void
m.cs_vpd=comscore_unix_time()+m.cs_vkd
end function
cs_vyf.cs_vox=function()as void
m.cs_vpd=-1#
end function
cs_vyf.cs_voz=function()as void
if m.cs_vqm=csstreamsensestate().playing then
m.cs_vrj.cs_vwh()
m.cs_vrj.cs_vwe()
labels=m.cs_vqt(csstreamsenseeventtype().pause,invalid)
m.dispatch(labels)
m.cs_vpb=m.cs_vpb+1
m.cs_vqm=csstreamsensestate().paused
end if
m.cs_vpd=-1#
end function
cs_vyf.cs_vpe=function(eventlabelmap as object)as void
cs_vcv#=m.cs_vqo(eventlabelmap)
if cs_vcv#<0 then
eventlabelmap["ns_ts"]=comscore_tostr(comscore_unix_time())
end if
end function
cs_vyf.cs_vpf=function()as boolean
if m.cs_vrh.publishersecret()= "" or m.cs_vrh.customerc2()=invalid then return true
return false
end function
cs_vyf.cs_vpg=function(labels as object)as void
m.cs_vph=m.cs_vqt(m.cs_vpq(m.cs_vqr),invalid)
m.cs_vph.append(labels)
end function
cs_vyf.cs_vpi=function(state as object)as boolean
if state=csstreamsensestate().playing or state=csstreamsensestate().paused then return true
return false
end function
cs_vyf.cs_vpl=function(cs_vpp as object)as object
if cs_vpp=csstreamsenseeventtype().play then return csstreamsensestate().playing
if cs_vpp=csstreamsenseeventtype().pause then return csstreamsensestate().paused
if cs_vpp=csstreamsenseeventtype().buffer then return csstreamsensestate().buffering
if cs_vpp=csstreamsenseeventtype().end then return csstreamsensestate().idle
return invalid
end function
cs_vyf.cs_vpq=function(state as object)as object
if state=csstreamsensestate().playing then return csstreamsenseeventtype().play
if state=csstreamsensestate().paused then return csstreamsenseeventtype().pause
if state=csstreamsensestate().buffering then return csstreamsenseeventtype().buffer
if state=csstreamsensestate().idle then return csstreamsenseeventtype().end
return invalid
end function
cs_vyf.cs_vpv=function(cs_vpy as object,eventlabelmap as object)as void
eventtime#=m.cs_vqo(eventlabelmap)
if cs_vpy=csstreamsensestate().playing then
m.cs_vrj.cs_vvt(eventtime#)
m.cs_voe()
m.cs_voq()
else if cs_vpy=csstreamsensestate().buffering then
m.cs_vrj.cs_vvu(eventtime#)
m.cs_vox()
else if cs_vpy=csstreamsensestate().idle then
keeplabels=createobject("roArray",1,true)
cs_vpz=m.cs_vrj.getclip().getlabels()
if cs_vpz<>invalid then
for each key in cs_vpz
keeplabels.push(key)
end for
end if
m.cs_vrj.getclip().reset(keeplabels)
end if
end function
cs_vyf.cs_vqa=function(cs_vqg as object,eventlabelmap as object)as void
eventtime#=m.cs_vqo(eventlabelmap)
if m.cs_vqn(eventlabelmap)<0 then
eventlabelmap["ns_st_po"]=comscore_tostr(m.cs_vqh(eventtime#))
end if
playerposition#=m.cs_vqn(eventlabelmap)
m.cs_vqb=playerposition#
if cs_vqg=csstreamsensestate().playing then
m.cs_voc()
m.cs_voo()
m.cs_vrj.getclip().cs_vte(eventtime#)
if m.cs_vqj(cs_vqg)=true then
m.cs_vrj.getclip().cs_vvr()
if m.cs_vrj.cs_vvo()<1 then
m.cs_vrj.cs_vvp(1)
end if
end if
else if cs_vqg=csstreamsensestate().paused then
if m.cs_vqj(cs_vqg)then
m.cs_vrj.cs_vwe()
end if
else if cs_vqg=csstreamsensestate().buffering then
m.cs_vrj.getclip().cs_vth(eventtime#)
if m.cs_vqf=true then
m.cs_vov()
end if
else if cs_vqg=csstreamsensestate().idle then
m.cs_voh()
end if
end function
cs_vyf.cs_vqh=function(eventtime as double)as double
cs_vlk#=m.cs_vqb
if m.cs_vqr=csstreamsensestate().playing then
cs_vlk#=cs_vlk#+ (eventtime-m.cs_vqs)
end if
return cs_vlk#
end function
cs_vyf.cs_vqj=function(state as object)as boolean
if state=csstreamsensestate().paused and(m.cs_vqm=csstreamsensestate().idle or m.cs_vqm=invalid)then
return false
else
return state<>csstreamsensestate().buffering and m.cs_vqm<>state
end if
end function
cs_vyf.cs_vqn=function(cs_vvd as object)as double
playerposition#= -1#
if cs_vvd.doesexist("ns_st_po")then
playerposition#=comscore_stod(cs_vvd["ns_st_po"])
end if
return playerposition#
end function
cs_vyf.cs_vqo=function(cs_vvd as object)as double
cs_vcv#= -1#
if cs_vvd.doesexist("ns_ts")then
cs_vcv#=comscore_stod(cs_vvd["ns_ts"])
end if
return cs_vcv#
end function
cs_vyf.cs_vqp=function(cs_vqg as object)as boolean
if cs_vqg<>invalid and m.getstate()<>cs_vqg then return true
return false
end function
cs_vyf.cs_vqq=function(cs_vqg as object)as void
m.cs_vqr=cs_vqg
m.cs_vqs=comscore_unix_time()
end function
cs_vyf.cs_vqt=function(cs_vvk as object,cs_vva as object)as object
cs_vvd=createobject("roAssociativeArray")
if cs_vva<>invalid then
cs_vvd.append(cs_vva)
end if
if not cs_vvd.doesexist("ns_ts")then
cs_vvd["ns_ts"]=comscore_tostr(comscore_unix_time())
end if
if cs_vvk<>invalid and not cs_vvd.doesexist("ns_st_ev")then
cs_vvd["ns_st_ev"]=cs_vvk
end if
if m.sharingsdkpersistentlabels()then
cs_vvd.append(m.cs_vrh.getlabels())
end if
cs_vvd.append(m.getlabels())
m.cs_vuz(cs_vvk,cs_vvd)
m.cs_vrj.cs_vuz(cs_vvk,cs_vvd)
m.cs_vrj.getclip().cs_vuz(cs_vvk,cs_vvd)
cs_vqv=createobject("roAssociativeArray")
cs_vqv["ns_st_mp"]=m.cs_vnw
cs_vqv["ns_st_mv"]=m.cs_vny
cs_vqv["ns_st_ub"]= "0"
cs_vqv["ns_st_br"]= "0"
cs_vqv["ns_st_pn"]= "1"
cs_vqv["ns_st_tp"]= "1"
for each key in cs_vqv
if not cs_vvd.doesexist(key)then cs_vvd[key]=cs_vqv[key]
end for
return cs_vvd
end function
cs_vyf.cs_vuz=function(cs_vvk as object,cs_vva as object)as object
cs_vvd=cs_vva
if cs_vvd=invalid then
cs_vvd=createobject("roAssociativeArray")
end if
cs_vvd["ns_st_ec"]=comscore_tostr(m.cs_vpb)
if not cs_vvd.doesexist("ns_st_po")then
currentposition#=m.cs_vqb
eventtime#=m.cs_vqo(cs_vvd)
if cs_vvk=csstreamsenseeventtype().play or cs_vvk=csstreamsenseeventtype().keep_alive or cs_vvk=csstreamsenseeventtype().heart_beat or(cs_vvk=invalid and cs_vre=csstreamsensestate().playing)then
currentposition#=currentposition#+ (eventtime#-m.cs_vrj.getclip().cs_vtd())
end if
cs_vvd["ns_st_po"]=comscore_tostr(currentposition#)
end if
if cs_vvk=csstreamsenseeventtype().heart_beat then
cs_vvd["ns_st_hc"]=comscore_tostr(m.cs_vom)
end if
return cs_vvd
end function
if dax<>invalid then
cs_vyf.cs_vrh=dax
else
cs_vyf.cs_vrh=cscomscore()
end if
cs_vyf.setpixelurl=cs_vyf.cs_vrh.setpixelurl
cs_vyf.pixelurl=cs_vyf.cs_vrh.pixelurl
cs_vyf.cs_vri=createobject("roAssociativeArray")
cs_vyf.cs_vrj=cs_vuf()
cs_vyf.reset()
return cs_vyf
end function
function cs_vrk()as object
cs_vyf=createobject("roAssociativeArray")
cs_vyf.cs_vxe=0
cs_vyf.cs_vwu=0
cs_vyf.cs_vwy=0#
cs_vyf.cs_vti=-1#
cs_vyf.cs_vwa=0#
cs_vyf.cs_vtf=-1#
cs_vyf.cs_vto="1"
cs_vyf.cs_vuo=createobject("roAssociativeArray")
cs_vyf.reset=function(keeplabels=invalid as object)as void
if keeplabels<>invalid and type(keeplabels)= "roArray" and keeplabels.count()>0 then
cs_vxt(m.cs_vuo,keeplabels)
else
m.cs_vuo.clear()
end if
if m.cs_vuo["ns_st_cl"]=invalid then
m.cs_vuo["ns_st_cl"]= "0"
end if
if m.cs_vuo["ns_st_pn"]=invalid then
m.cs_vuo["ns_st_pn"]= "1"
end if
if m.cs_vuo["ns_st_tp"]=invalid then
m.cs_vuo["ns_st_tp"]= "1"
end if
m.cs_vxe=0
m.cs_vwu=0
m.cs_vwy=0#
m.cs_vti=-1#
m.cs_vwa=0#
m.cs_vtf=-1#
end function
cs_vyf.setlabels=function(newlabels as object,state=invalid as object)as void
if newlabels<>invalid then
m.cs_vuo.append(newlabels)
end if
m.cs_vws(m.cs_vuo,state)
end function
cs_vyf.getlabels=function()as object
return m.cs_vuo
end function
cs_vyf.setlabel=function(label as string,cs_vxd as string)as void
cs_vuy=createobject("roAssociativeArray")
cs_vuy[label]=cs_vxd
m.setlabels(cs_vuy)
end function
cs_vyf.getlabel=function(label as string)as string
return m.cs_vuo[label]
end function
cs_vyf.cs_vuz=function(cs_vvk as object,cs_vva=invalid as object)as object
cs_vvd=cs_vva
if cs_vvd=invalid then
cs_vvd=createobject("roAssociativeArray")
end if
cs_vvd["ns_st_cn"]=m.cs_vto
cs_vvd["ns_st_bt"]=comscore_tostr(m.cs_vvv())
if cs_vvk=csstreamsenseeventtype().play or cs_vvk=invalid
cs_vvd["ns_st_sq"]=comscore_tostr(m.cs_vwu)
end if
if cs_vvk=csstreamsenseeventtype().pause or cs_vvk=csstreamsenseeventtype().end or cs_vvk=csstreamsenseeventtype().keep_alive or cs_vvk=csstreamsenseeventtype().heart_beat or cs_vvk=invalid
cs_vvd["ns_st_pt"]=comscore_tostr(m.cs_vvy())
cs_vvd["ns_st_pc"]=comscore_tostr(m.cs_vxe)
end if
cs_vvd.append(m.cs_vuo)
return cs_vvd
end function
cs_vyf.cs_vwb=function()as integer
return m.cs_vxe
end function
cs_vyf.cs_vwc=function(pauses as integer)as void
m.cs_vxe=pauses
end function
cs_vyf.cs_vwe=function()as void
m.cs_vxe=m.cs_vxe+1
end function
cs_vyf.cs_vvo=function()as integer
return m.cs_vwu
end function
cs_vyf.cs_vvp=function(starts as integer)as void
m.cs_vwu=starts
end function
cs_vyf.cs_vvr=function()as void
m.cs_vwu=m.cs_vwu+1
end function
cs_vyf.cs_vvv=function()as double
cs_vlk#=m.cs_vwy
if m.cs_vti>=0 then
cs_vlk#=cs_vlk#+ (comscore_unix_time()-m.cs_vti)
end if
return cs_vlk#
end function
cs_vyf.cs_vvw=function(bufferingtime as double)as void
m.cs_vwy=bufferingtime
end function
cs_vyf.cs_vvy=function()as double
cs_vlk#=m.cs_vwa
if m.cs_vtf>=0 then
cs_vlk#=cs_vlk#+ (comscore_unix_time()-m.cs_vtf)
end if
return cs_vlk#
end function
cs_vyf.cs_vvz=function(cs_vxc as double)as void
m.cs_vwa=cs_vxc
end function
cs_vyf.cs_vtd=function()as double
return m.cs_vtf
end function
cs_vyf.cs_vte=function(playbacktimestamp as double)as void
m.cs_vtf=playbacktimestamp
end function
cs_vyf.cs_vtg=function()as double
return m.cs_vti
end function
cs_vyf.cs_vth=function(bufferingtimestamp as double)as void
m.cs_vti=bufferingtimestamp
end function
cs_vyf.cs_vtj=function()as string
return m.cs_vto
end function
cs_vyf.cs_vtk=function(clipid as string)as void
m.cs_vto=clipid
end function
cs_vyf.cs_vws=function(labels as object,state as object)as void
cs_vxd=labels["ns_st_cn"]
if cs_vxd<>invalid
m.cs_vto=cs_vxd
labels.delete("ns_st_cn")
end if
cs_vxd=labels["ns_st_bt"]
if cs_vxd<>invalid
m.cs_vwy=comscore_stod(cs_vxd)
labels.delete("ns_st_bt")
end if
m.cs_vtx("ns_st_cl",labels)
m.cs_vtx("ns_st_pn",labels)
m.cs_vtx("ns_st_tp",labels)
m.cs_vtx("ns_st_ub",labels)
m.cs_vtx("ns_st_br",labels)
if state=csstreamsensestate().playing or state=invalid
cs_vxd=labels["ns_st_sq"]
if(cs_vxd<>invalid)
m.cs_vwu=comscore_stoi(cs_vxd)
labels.delete("ns_st_sq")
end if
end if
if state<>csstreamsensestate().buffering
cs_vxd=labels["ns_st_pt"]
if cs_vxd<>invalid
m.cs_vwa=comscore_stod(cs_vxd)
labels.delete("ns_st_pt")
end if
end if
if state=csstreamsensestate().paused or state=csstreamsensestate().idle or state=invalid
cs_vxd=labels["ns_st_pc"]
if cs_vxd<>invalid
m.cs_vxe=comscore_stoi(cs_vxd)
labels.delete("ns_st_pc")
end if
end if
end function
cs_vyf.cs_vtx=function(key as string,labels as object)as void
cs_vxd=labels[key]
if cs_vxd<>invalid then
m.cs_vuo[key]=cs_vxd
end if
end function
cs_vyf.reset()
return cs_vyf
end function
function csstreamsenseeventtype()
if m.cs_vua=invalid then m.cs_vua=cs_vub()
return m.cs_vua
end function
function cs_vub()as object
cs_vuc=createobject("roAssociativeArray")
cs_vuc.buffer="buffer"
cs_vuc.play="play"
cs_vuc.pause="pause"
cs_vuc.end="end"
cs_vuc.heart_beat="hb"
cs_vuc.custom="custom"
cs_vuc.keep_alive="keep-alive"
return cs_vuc
end function
function cs_vud(streamsense as object,dax as object,labels as object,pixelurl as string)as object
cs_vyf=csapplicationmeasurement(dax,cseventtype().hidden,pixelurl,labels)
if pixelurl<>invalid and pixelurl<>"" then cs_vyf.setpixelurl(pixelurl)
cs_vyf.labels["ns_st_sv"]=streamsense.getversion()
return cs_vyf
end function
function cs_vuf()as object
cs_vyf=createobject("roAssociativeArray")
cs_vyf.cs_vuh=cs_vrk()
cs_vyf.cs_vxa=""
cs_vyf.cs_vwu=0
cs_vyf.cs_vxe=0
cs_vyf.cs_vww=0
cs_vyf.cs_vwy=0#
cs_vyf.cs_vwa=0#
cs_vyf.cs_vuo=createobject("roAssociativeArray")
cs_vyf.cs_vwo=0
cs_vyf.cs_vwr=false
cs_vyf.reset=function(keeplabels=invalid as object)as void
if keeplabels<>invalid and type(keeplabels)= "roArray" and keeplabels.count()>0 then
cs_vxt(m.cs_vuo,keeplabels)
else
m.cs_vuo.clear()
end if
m.cs_vxa=comscore_tostr(comscore_unix_time())+ "_" +comscore_tostr(m.cs_vwo)
m.cs_vwy=0#
m.cs_vwa=0#
m.cs_vwu=0
m.cs_vxe=0
m.cs_vww=0
m.cs_vwr=false
end function
cs_vyf.setlabels=function(newlabels as object,state=invalid as object)as void
if newlabels<>invalid then
m.cs_vuo.append(newlabels)
end if
m.cs_vws(m.cs_vuo,state)
end function
cs_vyf.getlabels=function()as object
return m.cs_vuo
end function
cs_vyf.setlabel=function(label as string,cs_vxd as string)as void
cs_vuy=createobject("roAssociativeArray")
cs_vuy[label]=cs_vxd
m.setlabels(cs_vuy)
end function
cs_vyf.getlabel=function(label as string)as string
return m.cs_vuo[label]
end function
cs_vyf.cs_vuz=function(cs_vvk as object,cs_vva=invalid as object)as object
cs_vvd=cs_vva
if cs_vvd=invalid then
cs_vvd=createobject("roAssociativeArray")
end if
cs_vvd["ns_st_bp"]=comscore_tostr(m.cs_vvv())
cs_vvd["ns_st_sp"]=comscore_tostr(m.cs_vwu)
cs_vvd["ns_st_id"]=comscore_tostr(m.cs_vxa)
if m.cs_vww>0 then
cs_vvd["ns_st_bc"]=comscore_tostr(m.cs_vww)
end if
if cs_vvk=csstreamsenseeventtype().pause or cs_vvk=csstreamsenseeventtype().end or cs_vvk=csstreamsenseeventtype().keep_alive or cs_vvk=csstreamsenseeventtype().heart_beat or cs_vvk=invalid then
cs_vvd["ns_st_pa"]=comscore_tostr(m.cs_vvy())
cs_vvd["ns_st_pp"]=comscore_tostr(m.cs_vxe)
end if
if cs_vvk=csstreamsenseeventtype().play or cs_vvk=invalid then
if not m.cs_vwp()then
cs_vvd["ns_st_pb"]= "1"
m.cs_vwq(true)
end if
end if
cs_vvd.append(m.cs_vuo)
return cs_vvd
end function
cs_vyf.getclip=function()as object
return m.cs_vuh
end function
cs_vyf.cs_vvl=function()as string
return m.cs_vxa
end function
cs_vyf.cs_vvm=function(playlistid as string)as void
m.cs_vxa=playlistid
end function
cs_vyf.cs_vvo=function()as integer
return m.cs_vwu
end function
cs_vyf.cs_vvp=function(starts as integer)as void
m.cs_vwu=starts
end function
cs_vyf.cs_vvr=function()as void
m.cs_vwu=m.cs_vwu+1
end function
cs_vyf.cs_vvt=function(cs_vzr as double)as void
if m.cs_vuh.cs_vtd()>=0 then
diff#=cs_vzr-m.cs_vuh.cs_vtd()
m.cs_vuh.cs_vte(-1)
m.cs_vuh.cs_vvz(m.cs_vuh.cs_vvy()+diff#)
m.cs_vvz(m.cs_vvy()+diff#)
end if
end function
cs_vyf.cs_vvu=function(cs_vzr as double)as void
if m.cs_vuh.cs_vtg()>=0 then
diff#=cs_vzr-m.cs_vuh.cs_vtg()
m.cs_vuh.cs_vth(-1)
m.cs_vuh.cs_vvw(m.cs_vuh.cs_vvv()+diff#)
m.cs_vvw(m.cs_vvv()+diff#)
end if
end function
cs_vyf.cs_vvv=function()as double
cs_vlk#=m.cs_vwy
if m.cs_vuh.cs_vtg()>=0 then
cs_vlk#=cs_vlk#+ (comscore_unix_time()-m.cs_vuh.cs_vtg())
end if
return cs_vlk#
end function
cs_vyf.cs_vvw=function(bufferingtime as double)as void
m.cs_vwy=bufferingtime
end function
cs_vyf.cs_vvy=function()as double
cs_vlk#=m.cs_vwa
if m.cs_vuh.cs_vtd()>=0 then
cs_vlk#=cs_vlk#+ (comscore_unix_time()-m.cs_vuh.cs_vtd())
end if
return cs_vlk#
end function
cs_vyf.cs_vvz=function(cs_vxc as double)as void
m.cs_vwa=cs_vxc
end function
cs_vyf.cs_vwb=function()as integer
return m.cs_vxe
end function
cs_vyf.cs_vwc=function(pauses as integer)as void
cs_vyf.cs_vxe=pauses
end function
cs_vyf.cs_vwe=function()as void
m.cs_vxe=m.cs_vxe+1
m.cs_vuh.cs_vwe()
end function
cs_vyf.cs_vwg=function()as integer
return m.cs_vww
end function
cs_vyf.cs_vwh=function()as void
m.cs_vww=m.cs_vww+1
end function
cs_vyf.cs_vwj=function(rebuffercount as integer)
m.cs_vww=rebuffercount
end function
cs_vyf.cs_vwl=function(playlistcounter as integer)as void
m.cs_vwo=playlistcounter
end function
cs_vyf.cs_vwn=function()as void
m.cs_vwo=m.cs_vwo+1
end function
cs_vyf.cs_vwp=function()as boolean
return m.cs_vwr
end function
cs_vyf.cs_vwq=function(firstplayoccurred as boolean)as void
m.cs_vwr=firstplayoccurred
end function
cs_vyf.cs_vws=function(labels as object,state as object)as void
cs_vxd=labels["ns_st_sp"]
if cs_vxd<>invalid then
m.cs_vwu=comscore_stoi(cs_vxd)
labels.delete("ns_st_sp")
end if
cs_vxd=labels["ns_st_bc"]
if cs_vxd<>invalid then
m.cs_vww=comscore_stoi(cs_vxd)
labels.delete("ns_st_bc")
end if
cs_vxd=labels["ns_st_bp"]
if cs_vxd<>invalid then
m.cs_vwy=comscore_stod(cs_vxd)
labels.delete("ns_st_bp")
end if
cs_vxd=labels["ns_st_id"]
if cs_vxd<>invalid then
m.cs_vxa=cs_vxd
labels.delete("ns_st_id")
end if
if state<>csstreamsensestate().buffering then
cs_vxd=labels["ns_st_pa"]
if cs_vxd<>invalid then
cs_vxc=comscore_stod(cs_vxd)
labels.delete("ns_st_pa")
end if
end if
if state=csstreamsensestate().paused or state=csstreamsensestate().idle or state=invalid then
cs_vxd=labels["ns_st_pp"]
if cs_vxd<>invalid then
m.cs_vxe=comscore_stoi(cs_vxd)
labels.delete("ns_st_pp")
end if
end if
end function
cs_vyf.reset()
return cs_vyf
end function
function csstreamsensesgbridge(cs_vxl as object)as object
cs_vyf=createobject("roAssociativeArray")
cs_vyf.cs_vxl=cs_vxl
cs_vxm={}
cs_vxm["component"]= "sta"
cs_vxm["methodName"]= "init"
cs_vyf.cs_vxl["apiCall"]=cs_vxm
cs_vyf.comscoretask=function()as object
return m.cs_vxl
end function
cs_vyf.engageto=function(screen as object)as void
m.cs_vxn("EngageTo",[screen])
end function
cs_vyf.tick=function()as void
m.cs_vxn("Tick",invalid)
end function
cs_vyf.notify=function(cs_vvk as object,position=-1#as double,eventlabelmap=invalid as object)as void
m.cs_vxn("Notify",[cs_vvk,position,eventlabelmap])
end function
cs_vyf.sharesdkpersistentlabels=function(flag as boolean)
m.cs_vxn("ShareSDKPersistentLabels",[flag])
end function
cs_vyf.setpauseonbufferingenabled=function(pauseonbufferingenabled as boolean)
m.cs_vxn("SetPauseOnBufferingEnabled",[pauseonbufferingenabled])
end function
cs_vyf.setpauseplayswitchdelayenabled=function(pauseplayswitchdelayenabled as boolean)as void
m.cs_vxn("SetPausePlaySwitchDelayEnabled",[pauseplayswitchdelayenabled])
end function
cs_vyf.setclip=function(labels as object,loop=false as boolean)as boolean
m.cs_vxn("SetClip",[labels,loop])
end function
cs_vyf.setplaylist=function(labels as object)as boolean
m.cs_vxn("SetPlaylist",[labels])
end function
cs_vyf.addlistener=function(cs_vmo as object)as void
m.cs_vxn("AddListener",[cs_vmo])
end function
cs_vyf.removelistener=function(cs_vmo as object)as void
m.cs_vxn("RemoveListener",[cs_vmo])
end function
cs_vyf.setlabels=function(cs_vvd as object)as void
m.cs_vxn("SetLabels",[cs_vvd])
end function
cs_vyf.setlabel=function(name as string,cs_vxd as string)as void
m.cs_vxn("SetLabel",[name,cs_vxd])
end function
cs_vyf.reset=function(keeplabels=invalid as object)as void
m.cs_vxn("Reset",[keeplabels])
end function
cs_vyf.cs_vxn=function(name as string,args)
cs_vxo={}
cs_vxo["component"]= "sta"
cs_vxo["methodName"]=name
cs_vxo["args"]=args
m.cs_vxl["apiCall"]=cs_vxo
end function
return cs_vyf
end function
function csstreamingsgbridge(cs_vxl as object)as object
cs_vyf=createobject("roAssociativeArray")
cs_vyf.cs_vxl=cs_vxl
cs_vxm={}
cs_vxm["component"]= "ssw"
cs_vxm["methodName"]= "init"
cs_vyf.cs_vxl["apiCall"]=cs_vxm
cs_vyf.comscoretask=function()as object
return m.cs_vxl
end function
cs_vyf.playvideoadvertisement=function(metadata=invalid as object,mediatype=invalid as object)as void
m.cs_vxn("PlayVideoAdvertisement",[metadata,mediatype])
end function
cs_vyf.playaudioadvertisement=function(metadata=invalid as object,mediatype=invalid as object)as void
m.cs_vxn("PlayAudioAdvertisement",[metadata,mediatype])
end function
cs_vyf.playvideocontentpart=function(metadata=invalid as object,mediatype=invalid as object)as void
m.cs_vxn("PlayVideoContentPart",[metadata,mediatype])
end function
cs_vyf.playaudiocontentpart=function(metadata=invalid as object,mediatype=invalid as object)as void
m.cs_vxn("PlayAudioContentPart",[metadata,mediatype])
end function
cs_vyf.stop=function()as void
m.cs_vxn("Stop",invalid)
end function
cs_vyf.tick=function()as void
m.cs_vxn("Tick",invalid)
end function
cs_vyf.reset=function()as void
m.cs_vxn("Reset",invalid)
end function
cs_vyf.cs_vxn=function(name as string,args)
cs_vxo={}
cs_vxo["component"]= "ssw"
cs_vxo["methodName"]=name
cs_vxo["args"]=args
m.cs_vxl["apiCall"]=cs_vxo
end function
return cs_vyf
end function
function csstreamsensestate()
if m.cs_vxq=invalid then m.cs_vxq=cs_vxr()
return m.cs_vxq
end function
function cs_vxr()as object
cs_vxs=createobject("roAssociativeArray")
cs_vxs.buffering="buffering"
cs_vxs.playing="playing"
cs_vxs.paused="paused"
cs_vxs.idle="idle"
return cs_vxs
end function
function cs_vxt(cs_vuy as object,keepkeys as object)
cs_vxu=createobject("roAssociativeArray")
for each keyname in keepkeys
cs_vxu[keyname]=true
end for
cs_vxv=createobject("roArray",30,true)
for each keyname in cs_vuy
if not cs_vxu.doesexist(keyname)then
cs_vxv.push(keyname)
end if
end for
for each keyname in cs_vxv
cs_vuy.delete(keyname)
end for
end function
function cscontenttype()as object
cs_vyf=createobject("roAssociativeArray")
cs_vyf.long_form_on_demand="12"
cs_vyf.short_form_on_demand="11"
cs_vyf.live="13"
cs_vyf.user_generated_long_form_on_demand="22"
cs_vyf.user_generated_short_form_on_demand="21"
cs_vyf.user_generated_live="23"
cs_vyf.bumper="99"
cs_vyf.other="00"
return cs_vyf
end function
function csadtype()as object
cs_vyf=createobject("roAssociativeArray")
cs_vyf.linear_on_demand_pre_roll="11"
cs_vyf.linear_on_demand_mid_roll="12"
cs_vyf.linear_on_demand_post_roll="13"
cs_vyf.linear_live="21"
cs_vyf.branded_on_demand_pre_roll="31"
cs_vyf.branded_on_demand_mid_roll="32"
cs_vyf.branded_on_demand_post_roll="33"
cs_vyf.branded_on_demand_content="34"
cs_vyf.branded_on_demand_live="35"
cs_vyf.other="00"
return cs_vyf
end function
function csstreamingtag(dax=invalid as object)as object
cs_vyf=createobject("roAssociativeArray")
cs_vyf.cs_vyz=0
cs_vyf.cs_vyu=invalid
cs_vyf.cs_vyb=0
cs_vyf.cs_vzn=false
cs_vyf.cs_vyd=csstreamsense(dax)
cs_vyf.cs_vyd.setlabel("ns_st_it","r")
cs_vyf.cs_vye=function()as object
cs_vyf=createobject("roAssociativeArray")
cs_vyf.cs_vyg="0"
cs_vyf.cs_vyh="1"
cs_vyf.cs_vyi="2"
return cs_vyf
end function
cs_vyf.cs_vzo=cs_vyf.cs_vye().cs_vyg
cs_vyf.cs_vyk=["ns_st_st","ns_st_ci","ns_st_pr","ns_st_sn","ns_st_en","ns_st_ep","ns_st_ct","ns_st_pu","c3","c4","c6"]
cs_vyf.cs_vzm=0
cs_vyf.cs_vzf=0
cs_vyf.cs_vyn=function(metadata as object)as object
if metadata=invalid then
metadata={}
end if
for cs_vyq=0 to m.cs_vyk.count()-1 step 1
if m.cs_vyk[cs_vyq]= "ns_st_ci" and metadata["ns_st_ci"]=invalid then
metadata["ns_st_ci"]= "0"
else if metadata[m.cs_vyk[cs_vyq]]=invalid then
metadata[m.cs_vyk[cs_vyq]]= "*null"
end if
end for
return metadata
end function
cs_vyf.cs_vyp=function(metadata as object)as boolean
for cs_vyq=0 to m.cs_vyk.count()-1 step 1
if not m.cs_vyr(m.cs_vyk[cs_vyq],m.cs_vyu,metadata)then
return false
end if
end for
return true
end function
cs_vyf.cs_vyr=function(label as string,map1 as object,map2 as object)as boolean
if label<>invalid and map1<>invalid and map2<>invalid then
if map1[label]<>invalid and map2[label]<>invalid then
return map1[label]=map2[label]
end if
end if
return false
end function
cs_vyf.cs_vys=function(cs_vzr as double,metadata as object)as void
m.cs_vzq(cs_vzr)
m.cs_vyz=m.cs_vyz+1
labels={}
labels["ns_st_cn"]=comscore_tostr(m.cs_vyz)
labels["ns_st_pn"]= "1"
labels["ns_st_tp"]= "0"
comscore_extend(labels,metadata)
m.cs_vyd.setclip(labels)
m.cs_vyu=metadata
m.cs_vzm=cs_vzr
m.cs_vzf=0
m.cs_vyd.notify(csstreamsenseeventtype().play,m.cs_vzf)
end function
cs_vyf.cs_vyx=function(metadata as object)as void
cs_vzr=comscore_unix_time()
m.cs_vzq(cs_vzr)
m.cs_vyz=m.cs_vyz+1
metadata=m.cs_vyn(metadata)
labels={}
labels["ns_st_cn"]=comscore_tostr(m.cs_vyz)
labels["ns_st_pn"]= "1"
labels["ns_st_tp"]= "1"
labels["ns_st_ad"]= "1"
comscore_extend(labels,metadata)
m.cs_vyd.setclip(labels)
m.cs_vzf=0
m.cs_vyd.notify(csstreamsenseeventtype().play,m.cs_vzf)
m.cs_vzm=cs_vzr
m.cs_vzn=false
end function
cs_vyf.cs_vzd=function(timestamp as double)as double
if m.cs_vzm>0 and timestamp>=m.cs_vzm then
m.cs_vzf=m.cs_vzf+timestamp-m.cs_vzm
else
m.cs_vzf=0
end if
return m.cs_vzf
end function
cs_vyf.cs_vzg=function(metadata as object,contenttype as string)as void
cs_vzr=comscore_unix_time()
metadata=m.cs_vyn(metadata)
if m.cs_vzo=m.cs_vye().cs_vyg then
m.cs_vzo=contenttype
end if
if m.cs_vzn=true and m.cs_vzo=contenttype then
if not m.cs_vyp(metadata)then
m.cs_vys(cs_vzr,metadata)
else
m.cs_vyd.getclip().setlabels(metadata)
if m.cs_vyd.getstate()<>csstreamsensestate().playing then
m.cs_vzm=cs_vzr
m.cs_vyd.notify(csstreamsenseeventtype().play,m.cs_vzf)
end if
end if
else
m.cs_vys(cs_vzr,metadata)
end if
m.cs_vzn=true
m.cs_vzo=contenttype
end function
cs_vyf.playvideoadvertisement=function(metadata=invalid as object,mediatype=invalid as object)as void
labels={}
labels["ns_st_ct"]= "va"
if mediatype<>invalid then
labels["ns_st_ct"]= "va" +comscore_tostr(mediatype)
if mediatype=csadtype().linear_live or mediatype=csadtype().branded_on_demand_live then
labels["ns_st_li"]= "1"
end if
end if
if metadata<>invalid then
comscore_extend(labels,metadata)
end if
m.cs_vyx(labels)
end function
cs_vyf.playaudioadvertisement=function(metadata=invalid as object,mediatype=invalid as object)as void
labels={}
labels["ns_st_ct"]= "aa"
if mediatype<>invalid then
labels["ns_st_ct"]= "aa" +comscore_tostr(mediatype)
if mediatype=csadtype().linear_live or mediatype=csadtype().branded_on_demand_live then
labels["ns_st_li"]= "1"
end if
end if
if metadata<>invalid then
comscore_extend(labels,metadata)
end if
m.cs_vyx(labels)
end function
cs_vyf.playvideocontentpart=function(metadata=invalid as object,mediatype=invalid as object)as void
labels={}
labels["ns_st_ct"]= "vc"
if mediatype<>invalid then
labels["ns_st_ct"]= "vc" +comscore_tostr(mediatype)
if mediatype=cscontenttype().live or mediatype=cscontenttype().user_generated_live then
labels["ns_st_li"]= "1"
end if
end if
if metadata<>invalid then
comscore_extend(labels,metadata)
end if
m.cs_vzg(labels,m.cs_vye().cs_vyi)
end function
cs_vyf.playaudiocontentpart=function(metadata=invalid as object,mediatype=invalid as object)as void
labels={}
labels["ns_st_ct"]= "ac"
if mediatype<>invalid then
labels["ns_st_ct"]= "ac" +comscore_tostr(mediatype)
if mediatype=cscontenttype().live or mediatype=cscontenttype().user_generated_live then
labels["ns_st_li"]= "1"
end if
end if
if metadata<>invalid then
comscore_extend(labels,metadata)
end if
m.cs_vzg(labels,m.cs_vye().cs_vyh)
end function
cs_vyf.stop=function()as void
cs_vzr=comscore_unix_time()
m.cs_vyd.notify(csstreamsenseeventtype().pause,m.cs_vzd(cs_vzr))
end function
cs_vyf.cs_vzq=function(cs_vzr as double)as void
if m.cs_vyd.getstate()<>csstreamsensestate().idle and m.cs_vyd.getstate()<>csstreamsensestate().paused then
m.cs_vyd.notify(csstreamsenseeventtype().end,m.cs_vzd(cs_vzr))
else if m.cs_vyd.getstate()=csstreamsensestate().paused then
m.cs_vyd.notify(csstreamsenseeventtype().end,m.cs_vzf)
end if
end function
cs_vyf.tick=function()as void
m.cs_vyd.tick()
end function
cs_vyf.getstate=function()as object
return m.cs_vyd.getstate()
end function
cs_vyf.reset=function()as void
cs_vzr=comscore_unix_time()
m.cs_vzq(cs_vzr)
m.cs_vyd.setplaylist({})
end function
return cs_vyf
end function
