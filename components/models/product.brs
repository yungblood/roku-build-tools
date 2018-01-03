sub init()
end sub

sub onJsonChanged()
    json = m.top.json
    if json <> invalid then
        m.top.id = json.id
        m.top.productCode = json.product_code
        m.top.title = json.title
        m.top.description = json.product_description
        m.top.vendor = json.billing_vendor
        m.top.vendorProductCode = json.billing_vendor_product_code
        
        m.top.liveDate = dateFromSeconds(asDouble(json.live_date) / 1000)
        m.top.createdDate = dateFromSeconds(asDouble(json.created_date) / 1000)
        m.top.expires = dateFromSeconds(asDouble(json.expires_on) / 1000)
    end if
end sub
