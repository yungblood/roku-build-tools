'IMPORTS=utilities/arrays utilities/debug
' ******************************************************
' Copyright Steven Kean 2010-2015
' All Rights Reserved.
' ******************************************************
Function ChannelStore() As Object
    If m.ChannelStore = invalid Then
        m.ChannelStore = NewChannelStore()
    End If
    Return m.ChannelStore
End Function

Function NewChannelStore() As Object
    this = {
        Store:              CreateObject("roChannelStore")
        EventPort:          CreateObject("roMessagePort")
        
        CurrentOrder:       []
        Purchases:          []
        Catalog:            []
        StoreCatalog:       []
        
        Init:               ChannelStore_Init
        
        GetPartialUserData: ChannelStore_GetPartialUserData
        GetChannelCred:     ChannelStore_GetChannelCred
        
        GetData:            ChannelStore_GetData
        
        AddToOrder:         ChannelStore_AddToOrder
        RemoveFromOrder:    ChannelStore_RemoveFromOrder
        
        GetCatalog:         ChannelStore_GetCatalog
        GetStoreCatalog:    ChannelStore_GetStoreCatalog
        GetProduct:         ChannelStore_GetProduct
        GetPurchases:       ChannelStore_GetPurchases
        GetOrder:           ChannelStore_GetOrder
        SetOrder:           ChannelStore_SetOrder
        ClearOrder:         ChannelStore_ClearOrder
        DoOrder:            ChannelStore_DoOrder
    }
    this.Init()
    Return this
End Function

Sub ChannelStore_Init()
    'm.Store.FakeServer(True)
    m.Store.SetMessagePort(m.EventPort)
End Sub

Function ChannelStore_GetPartialUserData(properties As String) As Object
    Return m.Store.GetPartialUserData(properties)
End Function

Function ChannelStore_GetChannelCred() As Object
    Return m.Store.GetChannelCred()
End Function

Function ChannelStore_GetData(method As String, timeout = 0 As Integer) As Dynamic
    DebugPrint(method, "ChannelStore.GetData", 1)
    If method = "getCatalog" Then
        m.Store.GetCatalog()
    Else If method = "getStoreCatalog" Then
        m.Store.GetStoreCatalog()
    Else If method = "getPurchases" Then
        m.Store.GetPurchases()
    Else If method = "doOrder" Then
        m.Store.DoOrder()
    Else
        Return invalid
    End If
    While True
        msg = Wait(timeout, m.EventPort)
        If msg <> invalid Then
            If Type(msg) = "roChannelStoreEvent" Then
                If msg.IsRequestSucceeded() Then
                    DebugPrint(msg.GetResponse(), "ChannelStore.GetData", 1)
                    Return msg.GetResponse()
                Else If msg.IsRequestFailed() Then
                    DebugPrint("Request failed (" + method + "): " + msg.GetStatusMessage(), "ChannelStore.GetData", 0)
                    Exit While
                Else If msg.IsRequestInterrupted() Then
                    DebugPrint("Request interrupted (" + method + "): " + msg.GetStatusMessage(), "ChannelStore.GetData", 0)
                    Exit While
                End If
            End If
        End If
    End While
    Return []
End Function

Function ChannelStore_AddToOrder(product As Object) As Dynamic
    If m.CurrentOrder = invalid Then
        m.CurrentOrder = []
    End If
    added = False
    productCode = ""
    If IsString(product) Then
        productCode = product
    Else
        productCode = product.Code
    End If
    For Each item In m.CurrentOrder
        If item.Code = productCode Then
            item.Qty = item.Qty + 1
            added = True
            Exit For
        End If
    Next
    If Not added Then
        item = {
            Code: productCode
            Qty:  1
        }
        m.CurrentOrder.Push(item)
    End If
    Return m.SetOrder(m.CurrentOrder)
End Function

Function ChannelStore_RemoveFromOrder(product As Object, removeAll = True As Boolean) As Dynamic
    If m.CurrentOrder = invalid Then
        m.CurrentOrder = []
    End If
    For Each item In m.CurrentOrder
        If item.Code = product.Code Then
            item.Qty = IIf(removeAll, 0, item.Qty - 1)
            Exit For
        End If
    Next
    Return m.SetOrder(m.CurrentOrder)
End Function

Function ChannelStore_GetCatalog(forceRefresh = False As Boolean) As Dynamic
    If forceRefresh Or m.Catalog = invalid Or m.Catalog.Count() = 0 Then
        m.Catalog = m.GetData("getCatalog")
    End If
    Return m.Catalog
End Function

Function ChannelStore_GetStoreCatalog(forceRefresh = False As Boolean) As Dynamic
    If forceRefresh Or m.StoreCatalog = invalid Or m.StoreCatalog.Count() = 0 Then
        m.StoreCatalog = m.GetData("getStoreCatalog")
    End If
    Return m.StoreCatalog
End Function

Function ChannelStore_GetProduct(productCode As String, forceRefresh = False As Boolean) As Dynamic
    products = m.GetCatalog(forceRefresh)
    Return FindElementInArray(products, productCode, "code")
End Function

Function ChannelStore_GetPurchases(forceRefresh = False As Boolean) As Dynamic
    If forceRefresh Or m.Purchases = invalid Or m.Purchases.Count() = 0 Then
        m.Purchases = m.GetData("getPurchases")
    End If
    Return AsArray(m.Purchases)
End Function

Function ChannelStore_GetOrder() As Dynamic
    Return m.Store.GetOrder()
End Function

Function ChannelStore_SetOrder(order As Object) As Dynamic
    m.Store.SetOrder(order)
    m.CurrentOrder = m.GetOrder()
    Return m.CurrentOrder
End Function

Sub ChannelStore_ClearOrder()
    m.CurrentOrder = []
    m.Store.ClearOrder()
End Sub

Function ChannelStore_DoOrder() As Dynamic
    Return m.GetData("doOrder")
End Function
