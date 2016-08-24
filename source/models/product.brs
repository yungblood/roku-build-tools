Function NewProduct(json = invalid As Object) As Object
    this                = {}
    this.ClassName      = "Product"

    this.Initialize     = Product_Initialize

    If json <> invalid Then
        this.Initialize(json)
    End If
    
    Return this
End Function

Sub Product_Initialize(json As Object)
    m.Json = json
    
    m.ID                    = AsString(json.id)
    m.ProductCode           = AsString(json.product_code)
    m.Name                  = AsString(json.title)
    m.Title                 = m.Name
    m.Description           = AsString(json.product_description)
    m.Vendor                = AsString(json.billing_vendor)
    m.VendorProductCode     = AsString(json.billing_vendor_product_code)

    m.LiveDate              = DateFromSeconds(AsDouble(json.live_date) / 1000)
    m.CreatedDate           = DateFromSeconds(AsDouble(json.created_date) / 1000)
    m.Expires               = DateFromSeconds(AsDouble(json.expires_on) / 1000)
End Sub
