function csstreamsense(dax=invalid as object)as object
cs_vln=createobject("roAssociativeArray")
onstatechange=invalid
labels=invalid
cs_vln.cs_vb="roku"
cs_vln.cs_vc="4.1408.25"
cs_vln.cs_vd=500#
cs_vln.cs_ve=10#*1000#
cs_vln.cs_vf=60#*1000#
cs_vln.cs_vg=6
cs_vln.cs_vh=1200000#
cs_vln.cs_vi=500#
cs_vln.cs_vj=1500
cs_vln.cs_vhi=invalid
cs_vln.cs_vhj=invalid
cs_vln.p_pixelurl=""
cs_vln.cs_vgt=0#
cs_vln.cs_vgc=0#
cs_vln.cs_vgs=invalid
cs_vln.cs_vfc=0
cs_vln.cs_vhk=invalid
cs_vln.cs_vcb=true
cs_vln.cs_vgg=true
cs_vln.cs_vfe=-1#
cs_vln.cs_ven=0
cs_vln.cs_veo=-1#
cs_vln.cs_vek=-1#
cs_vln.cs_vev=-1#
cs_vln.cs_vgn=invalid
cs_vln.cs_vfi=invalid
cs_vln.cs_vdg=invalid
cs_vln.cs_vbm=invalid
cs_vln.cs_vbj=invalid
cs_vln.cs_vdx=""
cs_vln.cs_vdz=""
cs_vln.cs_vcd=false
cs_vln.cs_vds=-1#
cs_vln.cs_vdt=invalid
cs_vln.cs_vdu=invalid
cs_vln.engageto=function(screen as object)as void
m.reset()
m.cs_vbj=screen
screen.cs_vdh=m
cs_vbl={}
cs_vbl["ns_st_cu"]=screen.videoclip.streamurls[0]
if screen.videoclip.title<>invalid then cs_vbl["ns_st_ep"]=screen.videoclip.title
m.setclip(cs_vbl)
m.cs_vbm=createobject("roTimespan")
end function
cs_vln.onplayerevent=function(cs_vbo as object)as boolean
cs_vbp=false
m.cs_vhi.tick()
if cs_vbo=invalid then
if m.getstate()=csstreamsensestate().playing and m.cs_vbm.totalmilliseconds()>m.cs_vj then
m.notify(csstreamsenseeventtype().pause)
else
m.tick()
end if
else if comscore_is26()and cs_vbo.ispaused()then
m.notify(csstreamsenseeventtype().pause)
else if comscore_is26()and cs_vbo.isstreamstarted()then
m.notify(csstreamsenseeventtype().buffer)
else if cs_vbo.isplaybackposition()then
m.notify(csstreamsenseeventtype().play,cs_vbo.getindex()*1000)
m.cs_vbm.mark()
else if cs_vbo.isscreenclosed()or cs_vbo.isfullresult()or cs_vbo.ispartialresult()or cs_vbo.isrequestfailed()then
m.notify(csstreamsenseeventtype().end)
cs_vbp=true
end if
return cs_vbp
end function
cs_vln.tick=function()as void
cs_vil=comscore_unix_time()
if m.cs_vek>=0 and m.cs_vek<=cs_vil then
m.cs_vem()
end if
if m.cs_vev>=0 and m.cs_vev<=cs_vil then
m.cs_vet()
end if
if m.cs_vfe>=0 and m.cs_vfe<=cs_vil then
m.cs_vfa()
end if
if m.cs_vds>=0 and m.cs_vds<=cs_vil then
m.cs_vdi(m.cs_vdt,m.cs_vdu)
end if
end function
cs_vln.isidle=function()as boolean
return m.getstate()=csstreamsensestate().idle
end function
cs_vln.setpixelurl=invalid
cs_vln.pixelurl=invalid
cs_vln.notify=function(cs_vmr as object,position=-1#as double,eventlabelmap=invalid as object)as void
cs_vgh=m.cs_vfm(cs_vmr)
cs_vdo=createobject("roAssociativeArray")
if eventlabelmap<>invalid then cs_vdo.append(eventlabelmap)
m.cs_vff(cs_vdo)
if not cs_vdo.doesexist("ns_st_po")then
cs_vdo["ns_st_po"]=comscore_tostr(position)
end if
if cs_vmr=csstreamsenseeventtype().play or cs_vmr=csstreamsenseeventtype().pause or cs_vmr=csstreamsenseeventtype().buffer or cs_vmr=csstreamsenseeventtype().end then
if m.ispauseplayswitchdelayenabled()and m.cs_vfj(m.cs_vgs)and m.cs_vfj(cs_vgh)and not(m.cs_vgs=csstreamsensestate().playing and cs_vgh=csstreamsensestate().paused and m.cs_vdu=invalid)then
m.cs_vdi(cs_vgh,cs_vdo,m.cs_vd)
else
m.cs_vdi(cs_vgh,cs_vdo)
end if
else
if m.cs_vgo(cs_vdo)<0 then
cs_vdo["ns_st_po"]=comscore_tostr(m.cs_vgi(m.cs_vgp(cs_vdo)))
end if
labels=m.cs_vgu(cs_vmr,cs_vdo)
labels.append(cs_vdo)
m.dispatch(labels,false)
m.cs_vfc=m.cs_vfc+1
end if
end function
cs_vln.getlabels=function()as object
return m.cs_vhj
end function
cs_vln.sharingsdkpersistentlabels=function()as boolean
return m.cs_vcb
end function
cs_vln.sharesdkpersistentlabels=function(flag as boolean)
m.cs_vcb=flag
end function
cs_vln.ispauseonbufferingenabled=function()as boolean
return m.cs_vgg
end function
cs_vln.setpauseonbufferingenabled=function(pauseonbufferingenabled as boolean)
m.cs_vgg=pauseonbufferingenabled
end function
cs_vln.ispauseplayswitchdelayenabled=function()as boolean
return m.cs_vcd
end function
cs_vln.setpauseplayswitchdelayenabled=function(pauseplayswitchdelayenabled as boolean)as void
m.cs_vcd=pauseplayswitchdelayenabled
end function
cs_vln.setclip=function(labels as object,loop=false as boolean)as boolean
cs_vcj=false
if m.cs_vgs=csstreamsensestate().idle then
m.cs_vhk.getclip().reset()
m.cs_vhk.getclip().setlabels(labels,invalid)
if loop=true then
m.cs_vhk.cs_vmy()
end if
cs_vcj=true
end if
return cs_vcj
end function
cs_vln.setplaylist=function(labels as object)as boolean
cs_vcj=false
if m.cs_vgs=csstreamsensestate().idle then
m.cs_vhk.cs_vnu()
m.cs_vhk.reset()
m.cs_vhk.getclip().reset()
m.cs_vhk.setlabels(labels,invalid)
cs_vcj=true
end if
return cs_vcj
end function
cs_vln.importstate=function(labels as object)as void
m.reset()
cs_vck=createobject("roAssociativeArray")
cs_vck.append(labels)
m.cs_vhk.cs_vnz(cs_vck,invalid)
m.cs_vhk.getclip().cs_vnz(cs_vck,invalid)
m.cs_vnz(cs_vck)
m.cs_vfc=m.cs_vfc+1
end function
cs_vln.exportstate=function()as object
return m.cs_vfi
end function
cs_vln.getversion=function()as string
return m.cs_vc
end function
cs_vln.addlistener=function(cs_vcn as object)as void
if cs_vcn=invalid or cs_vcn.onstatechange=invalid then return
m.cs_vdg.push(cs_vcn)
end function
cs_vln.removelistener=function(cs_vcn as object)as void
if cs_vcn=invalid or cs_vcn.onstatechange=invalid then return
if m.cs_vdg.count()>0 then
cs_vcp=0
while cs_vcp<m.cs_vdg.count()
if cs_vcn.onstatechange=m.cs_vdg[cs_vcp].onstatechange then exit while
cs_vcp=cs_vcp+1
end while
if cs_vcp<m.cs_vdg.count()then m.cs_vdg.delete(cs_vcp)
end if
end function
cs_vln.getclip=function()as object
return m.cs_vhk.getclip()
end function
cs_vln.getplaylist=function()as object
return m.cs_vhk
end function
cs_vln.setlabels=function(cs_vmk as object)as void
if cs_vmk<>invalid then
if m.cs_vhj=invalid then
m.cs_vhj=cs_vmk
else
m.cs_vhj.append(cs_vmk)
end if
end if
end function
cs_vln.getlabel=function(name as string)as string
return m.cs_vhj[name]
end function
cs_vln.setlabel=function(name as string,cs_vok as string)as void
if cs_vok=invalid then
m.cs_vhj.delete(name)
else
m.cs_vhj[name]=cs_vok
end if
end function
cs_vln.reset=function(keeplabels=invalid as object)as void
m.cs_vhk.reset(keeplabels)
m.cs_vhk.cs_vns(0)
m.cs_vhk.cs_vmt(comscore_tostr(comscore_unix_time())+ "_1")
m.cs_vhk.getclip().reset(keeplabels)
if keeplabels<>invalid and type(keeplabels)= "roArray" and keeplabels.count()>0 then
cs_voq(m.cs_vhj,keeplabels)
else
m.cs_vhj.clear()
end if
m.cs_vfc=1
m.cs_ven=0
m.cs_vef()
m.cs_vei()
m.cs_vfe=-1#
m.cs_vek=-1#
m.cs_veo=-1#
m.cs_vev=-1#
m.cs_vgs=csstreamsensestate().idle
m.cs_vgt=-1#
m.cs_vgn=invalid
m.cs_vdx=m.cs_vb
m.cs_vdz=m.cs_vc
m.cs_vfi=invalid
m.cs_vgc=0#
m.cs_vdg=createobject("roArray",1,true)
m.cs_vdr()
if m.cs_vbj<>invalid then m.cs_vbj.cs_vdh=invalid
end function
cs_vln.getstate=function()as object
return m.cs_vgs
end function
cs_vln.cs_vdi=function(cs_vgh as object,eventlabelmap as object,cs_vdj=-1#as double)as void
m.cs_vdr()
if cs_vdj>=0 then
m.cs_vds=comscore_unix_time()+cs_vdj
m.cs_vdt=cs_vgh
m.cs_vdu=eventlabelmap
else if m.cs_vgq(cs_vgh)=true then
cs_vfz=m.getstate()
previousstatechangetimestamp#=m.cs_vgt
eventtime#=m.cs_vgp(eventlabelmap)
delta#=0
if previousstatechangetimestamp#>=0 then
delta#=eventtime#-previousstatechangetimestamp#
end if
m.cs_vfw(m.getstate(),eventlabelmap)
m.cs_vgb(cs_vgh,eventlabelmap)
m.cs_vgr(cs_vgh)
for each cs_vcn in m.cs_vdg
if cs_vcn.onstatechange<>invalid then cs_vcn.onstatechange(cs_vfz,cs_vgh,eventlabelmap,delta#)
end for
m.cs_vnz(eventlabelmap)
m.cs_vhk.cs_vnz(eventlabelmap,cs_vgh)
m.cs_vhk.getclip().cs_vnz(eventlabelmap,cs_vgh)
cs_vdo=m.cs_vgu(m.cs_vfr(cs_vgh),eventlabelmap)
cs_vdo.append(eventlabelmap)
if m.cs_vgk(m.cs_vgs)=true then
m.dispatch(cs_vdo)
m.cs_vgn=m.cs_vgs
m.cs_vfc=m.cs_vfc+1
end if
end if
end function
cs_vln.cs_vdr=function()as void
m.cs_vds=-1#
m.cs_vdt=invalid
m.cs_vdu=invalid
end function
cs_vln.cs_vnz=function(labels as object)as void
cs_vok=labels["ns_st_mp"]
if cs_vok<>invalid then
m.cs_vdx=cs_vok
labels.delete("ns_st_mp")
end if
cs_vok=labels["ns_st_mv"]
if cs_vok<>invalid then
m.cs_vdz=cs_vok
labels.delete("ns_st_mv")
end if
cs_vok=labels["ns_st_ec"]
if cs_vok<>invalid then
m.cs_vfc=comscore_stoi(cs_vok)
labels.delete("ns_st_ec")
end if
end function
cs_vln.dispatch=function(eventlabelmap as object,snapshot=true as boolean)as void
if snapshot=true then m.cs_vfh(eventlabelmap)
if not m.cs_vfg()then
cs_vec=cs_vlk(m,m.cs_vhi,eventlabelmap,m.pixelurl())
m.cs_vhi.dispatch(cs_vec)
end if
end function
cs_vln.cs_ved=function()as void
if m.cs_veo>=0 then
interval#=m.cs_veo
else
interval#=m.cs_vf
if m.cs_ven<m.cs_vg then interval#=m.cs_ve
end if
m.cs_vek=comscore_unix_time()+interval#
end function
cs_vln.cs_vef=function()as void
m.cs_veo=m.cs_vek-comscore_unix_time()
m.cs_vek=-1#
end function
cs_vln.cs_vei=function()as void
m.cs_veo=-1#
m.cs_vek=-1#
m.cs_ven=0
end function
cs_vln.cs_vem=function()as void
m.cs_ven=m.cs_ven+1
eventlabelmap=m.cs_vgu(csstreamsenseeventtype().heart_beat,invalid)
m.dispatch(eventlabelmap)
m.cs_veo=-1
m.cs_ved()
end function
cs_vln.cs_vep=function()as void
m.cs_ver()
m.cs_vev=comscore_unix_time()+m.cs_vh
end function
cs_vln.cs_ver=function()as void
m.cs_vev=-1#
end function
cs_vln.cs_vet=function()as void
eventlabelmap=m.cs_vgu(csstreamsenseeventtype().keep_alive,invalid)
m.dispatch(eventlabelmap)
m.cs_vfc=m.cs_vfc+1
m.cs_vev=comscore_unix_time()+m.cs_vh
end function
cs_vln.cs_vew=function()as void
m.cs_vfe=comscore_unix_time()+m.cs_vi
end function
cs_vln.cs_vey=function()as void
m.cs_vfe=-1#
end function
cs_vln.cs_vfa=function()as void
if m.cs_vgn=csstreamsensestate().playing then
m.cs_vhk.cs_vno()
m.cs_vhk.cs_vnl()
labels=m.cs_vgu(csstreamsenseeventtype().pause,invalid)
m.dispatch(labels)
m.cs_vfc=m.cs_vfc+1
m.cs_vgn=csstreamsensestate().paused
end if
m.cs_vfe=-1#
end function
cs_vln.cs_vff=function(eventlabelmap as object)as void
time#=m.cs_vgp(eventlabelmap)
if time#<0 then
eventlabelmap["ns_ts"]=comscore_tostr(comscore_unix_time())
end if
end function
cs_vln.cs_vfg=function()as boolean
if m.cs_vhi.publishersecret()= "" or m.cs_vhi.customerc2()=invalid then return true
return false
end function
cs_vln.cs_vfh=function(labels as object)as void
m.cs_vfi=m.cs_vgu(m.cs_vfr(m.cs_vgs),invalid)
m.cs_vfi.append(labels)
end function
cs_vln.cs_vfj=function(state as object)as boolean
if state=csstreamsensestate().playing or state=csstreamsensestate().paused then return true
return false
end function
cs_vln.cs_vfm=function(cs_vfq as object)as object
if cs_vfq=csstreamsenseeventtype().play then return csstreamsensestate().playing
if cs_vfq=csstreamsenseeventtype().pause then return csstreamsensestate().paused
if cs_vfq=csstreamsenseeventtype().buffer then return csstreamsensestate().buffering
if cs_vfq=csstreamsenseeventtype().end then return csstreamsensestate().idle
return invalid
end function
cs_vln.cs_vfr=function(state as object)as object
if state=csstreamsensestate().playing then return csstreamsenseeventtype().play
if state=csstreamsensestate().paused then return csstreamsenseeventtype().pause
if state=csstreamsensestate().buffering then return csstreamsenseeventtype().buffer
if state=csstreamsensestate().idle then return csstreamsenseeventtype().end
return invalid
end function
cs_vln.cs_vfw=function(cs_vfz as object,eventlabelmap as object)as void
eventtime#=m.cs_vgp(eventlabelmap)
if cs_vfz=csstreamsensestate().playing then
m.cs_vhk.cs_vna(eventtime#)
m.cs_vef()
m.cs_ver()
else if cs_vfz=csstreamsensestate().buffering then
m.cs_vhk.cs_vnb(eventtime#)
m.cs_vey()
else if cs_vfz=csstreamsensestate().idle then
keeplabels=createobject("roArray",1,true)
cs_vga=m.cs_vhk.getclip().getlabels()
if cs_vga<>invalid then
for each key in cs_vga
keeplabels.push(key)
end for
end if
m.cs_vhk.getclip().reset(keeplabels)
end if
end function
cs_vln.cs_vgb=function(cs_vgh as object,eventlabelmap as object)as void
eventtime#=m.cs_vgp(eventlabelmap)
if m.cs_vgo(eventlabelmap)<0 then
eventlabelmap["ns_st_po"]=comscore_tostr(m.cs_vgi(eventtime#))
end if
playerposition#=m.cs_vgo(eventlabelmap)
m.cs_vgc=playerposition#
if cs_vgh=csstreamsensestate().playing then
m.cs_ved()
m.cs_vep()
m.cs_vhk.getclip().cs_vkl(eventtime#)
if m.cs_vgk(cs_vgh)=true then
m.cs_vhk.getclip().cs_vmy()
if m.cs_vhk.cs_vmv()<1 then
m.cs_vhk.cs_vmw(1)
end if
end if
else if cs_vgh=csstreamsensestate().paused then
if m.cs_vgk(cs_vgh)then
m.cs_vhk.cs_vnl()
end if
else if cs_vgh=csstreamsensestate().buffering then
m.cs_vhk.getclip().cs_vko(eventtime#)
if m.cs_vgg=true then
m.cs_vew()
end if
else if cs_vgh=csstreamsensestate().idle then
m.cs_vei()
end if
end function
cs_vln.cs_vgi=function(eventtime as double)as double
cs_vbp#=m.cs_vgc
if m.cs_vgs=csstreamsensestate().playing then
cs_vbp#=cs_vbp#+ (eventtime-m.cs_vgt)
end if
return cs_vbp#
end function
cs_vln.cs_vgk=function(state as object)as boolean
if state=csstreamsensestate().paused and(m.cs_vgn=csstreamsensestate().idle or m.cs_vgn=invalid)then
return false
else
return state<>csstreamsensestate().buffering and m.cs_vgn<>state
end if
end function
cs_vln.cs_vgo=function(cs_vmk as object)as double
playerposition#= -1#
if cs_vmk.doesexist("ns_st_po")then
playerposition#=comscore_stod(cs_vmk["ns_st_po"])
end if
return playerposition#
end function
cs_vln.cs_vgp=function(cs_vmk as object)as double
time#= -1#
if cs_vmk.doesexist("ns_ts")then
time#=comscore_stod(cs_vmk["ns_ts"])
end if
return time#
end function
cs_vln.cs_vgq=function(cs_vgh as object)as boolean
if cs_vgh<>invalid and m.getstate()<>cs_vgh then return true
return false
end function
cs_vln.cs_vgr=function(cs_vgh as object)as void
m.cs_vgs=cs_vgh
m.cs_vgt=comscore_unix_time()
end function
cs_vln.cs_vgu=function(cs_vmr as object,cs_vmh as object)as object
cs_vmk=createobject("roAssociativeArray")
if cs_vmh<>invalid then
cs_vmk.append(cs_vmh)
end if
if not cs_vmk.doesexist("ns_ts")then
cs_vmk["ns_ts"]=comscore_tostr(comscore_unix_time())
end if
if cs_vmr<>invalid and not cs_vmk.doesexist("ns_st_ev")then
cs_vmk["ns_st_ev"]=cs_vmr
end if
if m.sharingsdkpersistentlabels()then
cs_vmk.append(m.cs_vhi.getlabels())
end if
cs_vmk.append(m.getlabels())
m.cs_vmg(cs_vmr,cs_vmk)
m.cs_vhk.cs_vmg(cs_vmr,cs_vmk)
m.cs_vhk.getclip().cs_vmg(cs_vmr,cs_vmk)
cs_vgw=createobject("roAssociativeArray")
cs_vgw["ns_st_mp"]=m.cs_vdx
cs_vgw["ns_st_mv"]=m.cs_vdz
cs_vgw["ns_st_ub"]= "0"
cs_vgw["ns_st_br"]= "0"
cs_vgw["ns_st_pn"]= "1"
cs_vgw["ns_st_tp"]= "1"
for each key in cs_vgw
if not cs_vmk.doesexist(key)then cs_vmk[key]=cs_vgw[key]
end for
return cs_vmk
end function
cs_vln.cs_vmg=function(cs_vmr as object,cs_vmh as object)as object
cs_vmk=cs_vmh
if cs_vmk=invalid then
cs_vmk=createobject("roAssociativeArray")
end if
cs_vmk["ns_st_ec"]=comscore_tostr(m.cs_vfc)
if not cs_vmk.doesexist("ns_st_po")then
currentposition#=m.cs_vgc
eventtime#=m.cs_vgp(cs_vmk)
if cs_vmr=csstreamsenseeventtype().play or cs_vmr=csstreamsenseeventtype().keep_alive or cs_vmr=csstreamsenseeventtype().heart_beat or(cs_vmr=invalid and cs_vhf=csstreamsensestate().playing)then
currentposition#=currentposition#+ (eventtime#-m.cs_vhk.getclip().cs_vkk())
end if
cs_vmk["ns_st_po"]=comscore_tostr(currentposition#)
end if
if cs_vmr=csstreamsenseeventtype().heart_beat then
cs_vmk["ns_st_hc"]=comscore_tostr(m.cs_ven)
end if
return cs_vmk
end function
if dax<>invalid then
cs_vln.cs_vhi=dax
else
cs_vln.cs_vhi=cscomscore()
end if
cs_vln.setpixelurl=cs_vln.cs_vhi.setpixelurl
cs_vln.pixelurl=cs_vln.cs_vhi.pixelurl
cs_vln.cs_vhj=createobject("roAssociativeArray")
cs_vln.cs_vhk=cs_vlm()
cs_vln.reset()
return cs_vln
end function
function csstreamingtag(dax=invalid as object)as object
cs_vln=createobject("roAssociativeArray")
cs_vln.cs_vic=0
cs_vln.cs_vij=0
cs_vln.cs_vio=0
cs_vln.cs_vid=invalid
cs_vln.cs_vik=false
cs_vln.cs_vhr=csstreamsense(dax)
cs_vln.cs_vhr.setlabel("ns_st_it","r")
cs_vln.cs_vhs=function(cs_vih as object)as object
if cs_vih=invalid then
cs_vih={}
end if
if cs_vih["ns_st_ci"]=invalid then
cs_vih["ns_st_ci"]= "0"
end if
if cs_vih["c3"]=invalid then
cs_vih["c3"]= "*null"
end if
if cs_vih["c4"]=invalid then
cs_vih["c4"]= "*null"
end if
if cs_vih["c6"]=invalid then
cs_vih["c6"]= "*null"
end if
return cs_vih
end function
cs_vln.cs_vhv=function(cs_vil as double)as void
if m.cs_vhr.getstate()<>csstreamsensestate().idle and m.cs_vhr.getstate()<>csstreamsensestate().paused then
m.cs_vhr.notify(csstreamsenseeventtype().end,m.cs_vim(cs_vil))
else if m.cs_vhr.getstate()=csstreamsensestate().paused then
m.cs_vhr.notify(csstreamsenseeventtype().end,m.cs_vio)
end if
end function
cs_vln.playadvertisement=function()as void
cs_vil=comscore_unix_time()
m.cs_vhv(cs_vil)
m.cs_vic=m.cs_vic+1
labels=m.cs_vhs(invalid)
labels["ns_st_cn"]=comscore_tostr(m.cs_vic)
labels["ns_st_pn"]= "1"
labels["ns_st_ct"]= "va"
labels["ns_st_tp"]= "1"
labels["ns_st_ad"]= "1"
m.cs_vhr.setclip(labels)
m.cs_vio=0
m.cs_vhr.notify(csstreamsenseeventtype().play,m.cs_vio)
m.cs_vij=cs_vil
m.cs_vik=false
end function
cs_vln.cs_vib=function(cs_vil as double,cs_vih as object)as void
m.cs_vhv(cs_vil)
m.cs_vic=m.cs_vic+1
labels={}
labels["ns_st_cn"]=comscore_tostr(m.cs_vic)
labels["ns_st_pn"]= "1"
labels["ns_st_ct"]= "vc"
labels["ns_st_tp"]= "0"
m.cs_vhr.setclip(labels)
m.cs_vhr.getclip().setlabels(cs_vih)
m.cs_vid=cs_vih
m.cs_vij=cs_vil
m.cs_vio=0
m.cs_vhr.notify(csstreamsenseeventtype().play,m.cs_vio)
end function
cs_vln.playcontentpart=function(cs_vih as object)as void
cs_vil=comscore_unix_time()
cs_vih=m.cs_vhs(cs_vih)
if m.cs_vik=true then
if not m.cs_vip(cs_vih)then
m.cs_vib(cs_vil,cs_vih)
else
m.cs_vhr.getclip().setlabels(cs_vih)
if m.cs_vhr.getstate()<>csstreamsensestate().playing then
m.cs_vij=cs_vil
m.cs_vhr.notify(csstreamsenseeventtype().play,m.cs_vio)
end if
end if
else
m.cs_vib(cs_vil,cs_vih)
end if
m.cs_vik=true
end function
cs_vln.stop=function()as void
cs_vil=comscore_unix_time()
m.cs_vhr.notify(csstreamsenseeventtype().pause,m.cs_vim(cs_vil))
end function
cs_vln.cs_vim=function(timestamp as double)as double
if m.cs_vij>0 and timestamp>=m.cs_vij then
m.cs_vio=m.cs_vio+timestamp-m.cs_vij
else
m.cs_vio=0
end if
return m.cs_vio
end function
cs_vln.cs_vip=function(cs_vih as object)as boolean
return m.cs_viq("ns_st_ci",m.cs_vid,cs_vih)and m.cs_viq("c3",m.cs_vid,cs_vih)and m.cs_viq("c4",m.cs_vid,cs_vih)and m.cs_viq("c6",m.cs_vid,cs_vih)
end function
cs_vln.cs_viq=function(label as string,map1 as object,map2 as object)as boolean
if label<>invalid and map1<>invalid and map2<>invalid then
if map1[label]<>invalid and map2[label]<>invalid then
return map1[label]=map2[label]
end if
end if
return false
end function
cs_vln.tick=function()as void
m.cs_vhr.tick()
end function
cs_vln.getstate=function()as object
return m.cs_vhr.getstate()
end function
return cs_vln
end function
function cs_vir()as object
cs_vln=createobject("roAssociativeArray")
cs_vln.cs_vol=0
cs_vln.cs_vob=0
cs_vln.cs_vof=0#
cs_vln.cs_vkp=-1#
cs_vln.cs_vnh=0#
cs_vln.cs_vkm=-1#
cs_vln.cs_vkv="1"
cs_vln.cs_vlv=createobject("roAssociativeArray")
cs_vln.reset=function(keeplabels=invalid as object)as void
if keeplabels<>invalid and type(keeplabels)= "roArray" and keeplabels.count()>0 then
cs_voq(m.cs_vlv,keeplabels)
else
m.cs_vlv.clear()
end if
if m.cs_vlv["ns_st_cl"]=invalid then
m.cs_vlv["ns_st_cl"]= "0"
end if
if m.cs_vlv["ns_st_pn"]=invalid then
m.cs_vlv["ns_st_pn"]= "1"
end if
if m.cs_vlv["ns_st_tp"]=invalid then
m.cs_vlv["ns_st_tp"]= "1"
end if
m.cs_vol=0
m.cs_vob=0
m.cs_vof=0#
m.cs_vkp=-1#
m.cs_vnh=0#
m.cs_vkm=-1#
end function
cs_vln.setlabels=function(newlabels as object,state=invalid as object)as void
if newlabels<>invalid then
m.cs_vlv.append(newlabels)
end if
m.cs_vnz(m.cs_vlv,state)
end function
cs_vln.getlabels=function()as object
return m.cs_vlv
end function
cs_vln.setlabel=function(label as string,cs_vok as string)as void
cs_vmf=createobject("roAssociativeArray")
cs_vmf[label]=cs_vok
m.setlabels(cs_vmf)
end function
cs_vln.getlabel=function(label as string)as string
return m.cs_vlv[label]
end function
cs_vln.cs_vmg=function(cs_vmr as object,cs_vmh=invalid as object)as object
cs_vmk=cs_vmh
if cs_vmk=invalid then
cs_vmk=createobject("roAssociativeArray")
end if
cs_vmk["ns_st_cn"]=m.cs_vkv
cs_vmk["ns_st_bt"]=comscore_tostr(m.cs_vnc())
if cs_vmr=csstreamsenseeventtype().play or cs_vmr=invalid
cs_vmk["ns_st_sq"]=comscore_tostr(m.cs_vob)
end if
if cs_vmr=csstreamsenseeventtype().pause or cs_vmr=csstreamsenseeventtype().end or cs_vmr=csstreamsenseeventtype().keep_alive or cs_vmr=csstreamsenseeventtype().heart_beat or cs_vmr=invalid
cs_vmk["ns_st_pt"]=comscore_tostr(m.cs_vnf())
cs_vmk["ns_st_pc"]=comscore_tostr(m.cs_vol)
end if
cs_vmk.append(m.cs_vlv)
return cs_vmk
end function
cs_vln.cs_vni=function()as integer
return m.cs_vol
end function
cs_vln.cs_vnj=function(pauses as integer)as void
m.cs_vol=pauses
end function
cs_vln.cs_vnl=function()as void
m.cs_vol=m.cs_vol+1
end function
cs_vln.cs_vmv=function()as integer
return m.cs_vob
end function
cs_vln.cs_vmw=function(starts as integer)as void
m.cs_vob=starts
end function
cs_vln.cs_vmy=function()as void
m.cs_vob=m.cs_vob+1
end function
cs_vln.cs_vnc=function()as double
cs_vbp#=m.cs_vof
if m.cs_vkp>=0 then
cs_vbp#=cs_vbp#+ (comscore_unix_time()-m.cs_vkp)
end if
return cs_vbp#
end function
cs_vln.cs_vnd=function(bufferingtime as double)as void
m.cs_vof=bufferingtime
end function
cs_vln.cs_vnf=function()as double
cs_vbp#=m.cs_vnh
if m.cs_vkm>=0 then
cs_vbp#=cs_vbp#+ (comscore_unix_time()-m.cs_vkm)
end if
return cs_vbp#
end function
cs_vln.cs_vng=function(cs_voj as double)as void
m.cs_vnh=cs_voj
end function
cs_vln.cs_vkk=function()as double
return m.cs_vkm
end function
cs_vln.cs_vkl=function(playbacktimestamp as double)as void
m.cs_vkm=playbacktimestamp
end function
cs_vln.cs_vkn=function()as double
return m.cs_vkp
end function
cs_vln.cs_vko=function(bufferingtimestamp as double)as void
m.cs_vkp=bufferingtimestamp
end function
cs_vln.cs_vkq=function()as string
return m.cs_vkv
end function
cs_vln.cs_vkr=function(clipid as string)as void
m.cs_vkv=clipid
end function
cs_vln.cs_vnz=function(labels as object,state as object)as void
cs_vok=labels["ns_st_cn"]
if cs_vok<>invalid
m.cs_vkv=cs_vok
labels.delete("ns_st_cn")
end if
cs_vok=labels["ns_st_bt"]
if cs_vok<>invalid
m.cs_vof=comscore_stod(cs_vok)
labels.delete("ns_st_bt")
end if
m.cs_vle("ns_st_cl",labels)
m.cs_vle("ns_st_pn",labels)
m.cs_vle("ns_st_tp",labels)
m.cs_vle("ns_st_ub",labels)
m.cs_vle("ns_st_br",labels)
if state=csstreamsensestate().playing or state=invalid
cs_vok=labels["ns_st_sq"]
if(cs_vok<>invalid)
m.cs_vob=comscore_stoi(cs_vok)
labels.delete("ns_st_sq")
end if
end if
if state<>csstreamsensestate().buffering
cs_vok=labels["ns_st_pt"]
if cs_vok<>invalid
m.cs_vnh=comscore_stod(cs_vok)
labels.delete("ns_st_pt")
end if
end if
if state=csstreamsensestate().paused or state=csstreamsensestate().idle or state=invalid
cs_vok=labels["ns_st_pc"]
if cs_vok<>invalid
m.cs_vol=comscore_stoi(cs_vok)
labels.delete("ns_st_pc")
end if
end if
end function
cs_vln.cs_vle=function(key as string,labels as object)as void
cs_vok=labels[key]
if cs_vok<>invalid then
m.cs_vlv[key]=cs_vok
end if
end function
cs_vln.reset()
return cs_vln
end function
function csstreamsenseeventtype()
if m.cs_vlh=invalid then m.cs_vlh=cs_vli()
return m.cs_vlh
end function
function cs_vli()as object
cs_vlj=createobject("roAssociativeArray")
cs_vlj.buffer="buffer"
cs_vlj.play="play"
cs_vlj.pause="pause"
cs_vlj.end="end"
cs_vlj.heart_beat="hb"
cs_vlj.custom="custom"
cs_vlj.keep_alive="keep-alive"
return cs_vlj
end function
function cs_vlk(streamsense as object,dax as object,labels as object,pixelurl as string)as object
cs_vln=csapplicationmeasurement(dax,cseventtype().hidden,pixelurl,labels)
if pixelurl<>invalid and pixelurl<>"" then cs_vln.setpixelurl(pixelurl)
cs_vln.labels["ns_st_sv"]=streamsense.getversion()
return cs_vln
end function
function cs_vlm()as object
cs_vln=createobject("roAssociativeArray")
cs_vln.cs_vlo=cs_vir()
cs_vln.cs_voh=""
cs_vln.cs_vob=0
cs_vln.cs_vol=0
cs_vln.cs_vod=0
cs_vln.cs_vof=0#
cs_vln.cs_vnh=0#
cs_vln.cs_vlv=createobject("roAssociativeArray")
cs_vln.cs_vnv=0
cs_vln.cs_vny=false
cs_vln.reset=function(keeplabels=invalid as object)as void
if keeplabels<>invalid and type(keeplabels)= "roArray" and keeplabels.count()>0 then
cs_voq(m.cs_vlv,keeplabels)
else
m.cs_vlv.clear()
end if
m.cs_voh=comscore_tostr(comscore_unix_time())+ "_" +comscore_tostr(m.cs_vnv)
m.cs_vof=0#
m.cs_vnh=0#
m.cs_vob=0
m.cs_vol=0
m.cs_vod=0
m.cs_vny=false
end function
cs_vln.setlabels=function(newlabels as object,state=invalid as object)as void
if newlabels<>invalid then
m.cs_vlv.append(newlabels)
end if
m.cs_vnz(m.cs_vlv,state)
end function
cs_vln.getlabels=function()as object
return m.cs_vlv
end function
cs_vln.setlabel=function(label as string,cs_vok as string)as void
cs_vmf=createobject("roAssociativeArray")
cs_vmf[label]=cs_vok
m.setlabels(cs_vmf)
end function
cs_vln.getlabel=function(label as string)as string
return m.cs_vlv[label]
end function
cs_vln.cs_vmg=function(cs_vmr as object,cs_vmh=invalid as object)as object
cs_vmk=cs_vmh
if cs_vmk=invalid then
cs_vmk=createobject("roAssociativeArray")
end if
cs_vmk["ns_st_bp"]=comscore_tostr(m.cs_vnc())
cs_vmk["ns_st_sp"]=comscore_tostr(m.cs_vob)
cs_vmk["ns_st_id"]=comscore_tostr(m.cs_voh)
if m.cs_vod>0 then
cs_vmk["ns_st_bc"]=comscore_tostr(m.cs_vod)
end if
if cs_vmr=csstreamsenseeventtype().pause or cs_vmr=csstreamsenseeventtype().end or cs_vmr=csstreamsenseeventtype().keep_alive or cs_vmr=csstreamsenseeventtype().heart_beat or cs_vmr=invalid then
cs_vmk["ns_st_pa"]=comscore_tostr(m.cs_vnf())
cs_vmk["ns_st_pp"]=comscore_tostr(m.cs_vol)
end if
if cs_vmr=csstreamsenseeventtype().play or cs_vmr=invalid then
if not m.cs_vnw()then
cs_vmk["ns_st_pb"]= "1"
m.cs_vnx(true)
end if
end if
cs_vmk.append(m.cs_vlv)
return cs_vmk
end function
cs_vln.getclip=function()as object
return m.cs_vlo
end function
cs_vln.cs_vms=function()as string
return m.cs_voh
end function
cs_vln.cs_vmt=function(playlistid as string)as void
m.cs_voh=playlistid
end function
cs_vln.cs_vmv=function()as integer
return m.cs_vob
end function
cs_vln.cs_vmw=function(starts as integer)as void
m.cs_vob=starts
end function
cs_vln.cs_vmy=function()as void
m.cs_vob=m.cs_vob+1
end function
cs_vln.cs_vna=function(cs_vil as double)as void
if m.cs_vlo.cs_vkk()>=0 then
diff#=cs_vil-m.cs_vlo.cs_vkk()
m.cs_vlo.cs_vkl(-1)
m.cs_vlo.cs_vng(m.cs_vlo.cs_vnf()+diff#)
m.cs_vng(m.cs_vnf()+diff#)
end if
end function
cs_vln.cs_vnb=function(cs_vil as double)as void
if m.cs_vlo.cs_vkn()>=0 then
diff#=cs_vil-m.cs_vlo.cs_vkn()
m.cs_vlo.cs_vko(-1)
m.cs_vlo.cs_vnd(m.cs_vlo.cs_vnc()+diff#)
m.cs_vnd(m.cs_vnc()+diff#)
end if
end function
cs_vln.cs_vnc=function()as double
cs_vbp#=m.cs_vof
if m.cs_vlo.cs_vkn()>=0 then
cs_vbp#=cs_vbp#+ (comscore_unix_time()-m.cs_vlo.cs_vkn())
end if
return cs_vbp#
end function
cs_vln.cs_vnd=function(bufferingtime as double)as void
m.cs_vof=bufferingtime
end function
cs_vln.cs_vnf=function()as double
cs_vbp#=m.cs_vnh
if m.cs_vlo.cs_vkk()>=0 then
cs_vbp#=cs_vbp#+ (comscore_unix_time()-m.cs_vlo.cs_vkk())
end if
return cs_vbp#
end function
cs_vln.cs_vng=function(cs_voj as double)as void
m.cs_vnh=cs_voj
end function
cs_vln.cs_vni=function()as integer
return m.cs_vol
end function
cs_vln.cs_vnj=function(pauses as integer)as void
cs_vln.cs_vol=pauses
end function
cs_vln.cs_vnl=function()as void
m.cs_vol=m.cs_vol+1
m.cs_vlo.cs_vnl()
end function
cs_vln.cs_vnn=function()as integer
return m.cs_vod
end function
cs_vln.cs_vno=function()as void
m.cs_vod=m.cs_vod+1
end function
cs_vln.cs_vnq=function(rebuffercount as integer)
m.cs_vod=rebuffercount
end function
cs_vln.cs_vns=function(playlistcounter as integer)as void
m.cs_vnv=playlistcounter
end function
cs_vln.cs_vnu=function()as void
m.cs_vnv=m.cs_vnv+1
end function
cs_vln.cs_vnw=function()as boolean
return m.cs_vny
end function
cs_vln.cs_vnx=function(firstplayoccurred as boolean)as void
m.cs_vny=firstplayoccurred
end function
cs_vln.cs_vnz=function(labels as object,state as object)as void
cs_vok=labels["ns_st_sp"]
if cs_vok<>invalid then
m.cs_vob=comscore_stoi(cs_vok)
labels.delete("ns_st_sp")
end if
cs_vok=labels["ns_st_bc"]
if cs_vok<>invalid then
m.cs_vod=comscore_stoi(cs_vok)
labels.delete("ns_st_bc")
end if
cs_vok=labels["ns_st_bp"]
if cs_vok<>invalid then
m.cs_vof=comscore_stod(cs_vok)
labels.delete("ns_st_bp")
end if
cs_vok=labels["ns_st_id"]
if cs_vok<>invalid then
m.cs_voh=cs_vok
labels.delete("ns_st_id")
end if
if state<>csstreamsensestate().buffering then
cs_vok=labels["ns_st_pa"]
if cs_vok<>invalid then
cs_voj=comscore_stod(cs_vok)
labels.delete("ns_st_pa")
end if
end if
if state=csstreamsensestate().paused or state=csstreamsensestate().idle or state=invalid then
cs_vok=labels["ns_st_pp"]
if cs_vok<>invalid then
m.cs_vol=comscore_stoi(cs_vok)
labels.delete("ns_st_pp")
end if
end if
end function
cs_vln.reset()
return cs_vln
end function
function csstreamsensestate()
if m.cs_von=invalid then m.cs_von=cs_voo()
return m.cs_von
end function
function cs_voo()as object
cs_vop=createobject("roAssociativeArray")
cs_vop.buffering="buffering"
cs_vop.playing="playing"
cs_vop.paused="paused"
cs_vop.idle="idle"
return cs_vop
end function
function cs_voq(cs_vmf as object,keepkeys as object)
cs_vor=createobject("roAssociativeArray")
for each keyname in keepkeys
cs_vor[keyname]=true
end for
cs_vos=createobject("roArray",30,true)
for each keyname in cs_vmf
if not cs_vor.doesexist(keyname)then
cs_vos.push(keyname)
end if
end for
for each keyname in cs_vos
cs_vmf.delete(keyname)
end for
end function
