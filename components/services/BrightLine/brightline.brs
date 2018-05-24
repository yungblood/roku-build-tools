 
function BrightLine_APILoad() as Boolean

    ' Retrieve local storage segments; make Manifest call; and load BrightLineDirect.pkg
    print "Brightline_APILoad"
    config = m.global.config
        
    REM This is where the component library is loaded. 
    m.adlib = createObject("roSGNode", "ComponentLibrary")
    m.brightlineLoaded = false
    m.adlib.observeField("loadStatus", "BrightLineAPI_LoadStatus")
    m.adlib.setField("uri", m.global.config.brightLinePkg)
        
    return true
    
end function    
        
function BrightLine_ManifestLoad() as Object
    ' Get the configuration service object.    
    data = {}
    configurationServiceURL = m.global.config.brightLineUrl + m.global.config.brightLineID
    
    di = CreateObject("roDeviceInfo")
    displaySize = di.GetDisplaySize()
    
    deviceInfo = {
        "configId": m.global.config.brightLineID
        "os":"roku"
        "osVersion":di.GetVersion()
        "appSessionID":di.GetRandomUUID()
        "adSessionID":di.GetRandomUUID()
        "applicationName":"CBS" 
        "deviceUUID":di.GetDeviceUniqueId()
        "platformName":"roku"
        "mobileCarrier":"NA" 
        "manufacturer":"roku", 
        "advertisingIdentifier":di.GetAdvertisingId()
        "applicationIdentifier": m.global.config.registrySection
        "applicationVersion":"1" 
        "sdkVersion":"2.0.0" 
        "deviceModel":di.GetModel()
        "deviceName":di.GetModelDisplayName()
        "screenResolution": displaySize.w.ToStr() + ","+displaySize.h.ToStr()
        "deviceConnectionType":di.GetConnectionType()
        "trackFlag":0
        }

    'print deviceInfo

    data = PostUrlToJson(configurationServiceURL, FormatJson(deviceInfo))
    
    'print "BrightLine_ManifestLoad:", data    
    return data
end function


function GetBLData(key As String) As Object
     store = CreateObject("roRegistrySection", "BrightLine_Registry")
     if store.Exists(key)
         return store.Read(key)
     endif
     return invalid
end function
  
function SetBLData(key As String, value As String) As Void
    store = CreateObject("roRegistrySection", "BrightLine_Registry")
    store.Write(key, value)
    store.Flush()
end function
  
'The callback; to make an instance of the BLD available and on-screen (and invisible).
function BrightLineAPI_LoadStatus(msg) as void
    if (m.adlib.loadStatus = "ready")
        m.adlib.UnobserveField("loadStatus")
        ' Create the BrightLineDirect object, by instancing BL_init from the package that was loaded
        m.BrightLineDirect = CreateObject("roSGNode", "BrightLineDirect:BL_init")
        if m.BrightLineDirect <> invalid then
            
             ' Observe the "state" field of the library. This will let us know 
             ' to make it visible and focused (or not).                 
            m.BrightLineDirect.observeField("state", "onBrightLineDirectStateChange")
            
            ' Observe the "event" listener.
            m.BrightLineDirect.observeField("event", "onBrightLineAPI_event")
            m.BrightLineDirect.configJSON =  m.global.brightline.manifest

            m.brightlineLoaded = true
            'Add BrightLineDirect to a view (the view in scope, in this case)
            m.top.appendChild(m.BrightLineDirect)
            m.top.sdkLoaded = true
                            
        else if m.adlib.loadStatus = "failed" then
            print "BrightLineDirect _____ERROR LOADING PACKAGE:"
            m.brightlineLoaded = false
        end if
    end if
end function
  

function onBrightLineDirectStateChange(msg)
    'print "m.BrightLineDirect.state", m.BrightLineDirect.state
    
    if m.BrightLineDirect.state = "initialized" then
        m.top.BrightLineDirect = m.BrightLineDirect
    endif
    if m.BrightLineDirect.state = "showing" then
        m.BrightLineDirect.visible = false
    endif

    if m.BrightLineDirect.state = "exited" then
        m.BrightLineDirect.visible = false
        m.BrightLineDirect.setFocus(false)
        m.global.brightline.inAd = false
        m.global.brightline.adExited = true
    endif
endfunction


function onBrightLineAPI_event(msg)
    print "BL :: API event", msg.getData()
endfunction
  