'IMPORTS=utilities/device utilities/general utilities/types
' ******************************************************
' Copyright Steven Kean 2010-2015
' All Rights Reserved.
' ******************************************************
'=====================
' Rectangles
'=====================
Sub HDRectToSDRect(rect As Dynamic)
    If rect = invalid Then Return
    
    displayInfo = GetDisplayInfo()
    
    wMultiplier = 720 / 1280 * IIf(displayInfo.Aspect = "4x3", 720 / 640, 1)
    hMultiplier = 480 / 720
    
    If rect.x <> invalid Then
        rect.x = Int(rect.x * wMultiplier + .5) - IIf(displayInfo.Aspect = "4x3", 40, 0)
        'rect.x = IIf(rect.x < 1, 1, rect.x)
    End If
    If rect.y <> invalid Then
        rect.y = Int(rect.y * hMultiplier + .5)
        'rect.y = IIf(rect.y < 1, 1, rect.y)
    End If
    If rect.w <> invalid Then
        rect.w = Int(rect.w * wMultiplier + .5)
        rect.w = IIf(rect.w < 1, 1, rect.w)
    End If
    If rect.h <> invalid Then
        rect.h = Int(rect.h * hMultiplier + .5)
        rect.h = IIf(rect.h < 1, 1, rect.h)
    End If
End Sub

Sub HDSizeToSDSize(size As Object)
    HDRectToSDRect(size)
End Sub

Sub HDTargetRectToSDTargetRect(parent As Object, recursive = False As Boolean)
    If IsArray(parent) Then
        For Each item In parent
            HDTargetRectToSDTargetRect(item, recursive)
        Next
    Else If IsAssociativeArray(parent) Then
        If parent.TargetRect <> invalid Then
            HDRectToSDRect(parent.TargetRect)
        End If
        If recursive Then
            For Each key In parent
                If IsAssociativeArray(parent[key]) Then
                    HDTargetRectToSDTargetRect(parent[key], True)
                Else If IsArray(parent[key]) Then
                    For Each item In parent[key]
                        HDTargetRectToSDTargetRect(item, True)
                    Next
                End If
            Next
        End If
    End If
End Sub

Function EmptyRect() As Object
    Return { x: 0, y: 0, w: 0, h: 0 }
End Function

Function MakeRect(x As Integer, y As Integer, w As Integer, h As Integer) As Object
    Return { x: x, y: y, w: w, h: h }
End Function

Function CopyRect(rect As Object) As Object
    Return InflateRect(rect, 0, 0)
End Function

Sub CopyIntoRect(sourceRect As Object, destRect As Object)
    destRect.x = sourceRect.x
    destRect.y = sourceRect.y
    destRect.w = sourceRect.w
    destRect.h = sourceRect.h
End Sub

Function RectsMatch(rect1 As Object, rect2 As Object) As Boolean
    If rect1 = invalid Or rect2 = invalid Then
        Return rect1 = rect2
    End If
    If rect1.x <> rect2.x Then
        Return False
    End If
    If rect1.y <> rect2.y Then
        Return False
    End If
    If rect1.w <> rect2.w Then
        Return False
    End If
    If rect1.h <> rect2.h Then
        Return False
    End If
    Return True
End Function

Function InflateRect(rect As Object, inflateXBy As Integer, inflateYBy = inflateXBy As Integer) As Object
    Return {
        x: rect.x - inflateXBy,
        y: rect.y - inflateYBy,
        w: rect.w + inflateXBy * 2,
        h: rect.h + inflateYBy * 2
    }
End Function

Function DeflateRect(rect As Object, deflateXBy As Integer, deflateYBy = deflateXBy As Integer) As Object
    Return InflateRect(rect, -deflateXBy, -deflateYBy)
End Function

Sub MoveRect(rect As Object, delta As Object, bounds As Object)
    ' Make sure the rectangle is within the bounds before attempting to move it
    If rect.x + rect.w > bounds.x + bounds.w Then
        rect.x = bounds.x + bounds.w - rect.w
    End If
    If rect.y + rect.h > bounds.y + bounds.h Then
        rect.y = bounds.y + bounds.h - rect.h
    End If
    ' If we're at the edge of the bounds, then we need to reverse direction
    If rect.x + rect.w >= bounds.x + bounds.w Or rect.x <= bounds.x Then
        delta.x = -delta.x
    End If
    If rect.y + rect.h >= bounds.y + bounds.h Or rect.y <= bounds.y Then
        delta.y = -delta.y
    End If
    ' Move the rectangle
    rect.x = rect.x + delta.x
    rect.y = rect.y + delta.y
End Sub

Function GetBorderRect(rect As Object, borderWidth = 1 As Integer, Color = "#FFFFFF" As String) As Object
    top = {
        Color: Color,
        TargetRect: {
            x: rect.x,
            y: rect.y,
            w: rect.w,
            h: borderWidth
        },
        CompositionMode: "Source"
    }
    left = {
        Color: Color,
        TargetRect: {
            x: rect.x,
            y: rect.y,
            w: borderWidth,
            h: rect.h
        },
        CompositionMode: "Source"
    }
    right = {
        Color: Color,
        TargetRect: {
            x: rect.x + rect.w - borderWidth,
            y: rect.y,
            w: borderWidth,
            h: rect.h
        },
        CompositionMode: "Source"
    }
    bottom = {
        Color: Color,
        TargetRect: {
            x: rect.x,
            y: rect.y + rect.h - borderWidth,
            w: rect.w,
            h: borderWidth
        },
        CompositionMode: "Source"
    }
    Return [
        top,
        left,
        right,
        bottom
    ]
End Function

Function GetShadowRect(rect As Object, shadowSize = 5 As Integer) As Object
    shadowSize = Abs(shadowSize)
    shadowLayers = []
    shadowStep = Int(180 / shadowSize)
    For i = shadowSize To 0 Step -1
        shadow = {
            Color: "#" + ByteToHex(shadowStep) + "000000"
            TargetRect: InflateRect(rect, i)
        }
        shadowLayers.Push(shadow)
    Next
    Return shadowLayers
End Function

Function UnionRects(rect1 As Object, rect2 As Object) As Object
    If rect1.w = 0 Or rect1.h = 0 Then
        Return CopyRect(rect2)
    Else If rect2.w = 0 Or rect2.h = 0 Then
        Return CopyRect(rect1)
    End If
    rect = EmptyRect()
    rect.x = Min(rect1.x, rect2.x)
    rect.y = Min(rect1.y, rect2.y)
    rect.w = Max(rect1.x + rect1.w, rect2.x + rect2.w) - rect.x
    rect.h = Max(rect1.y + rect1.h, rect2.y + rect2.h) - rect.y
    Return rect
End Function

Function IntersectsRect(rect1 As Object, rect2 As Object) As Boolean
    If rect1.x > rect2.x + rect2.w Then
        Return False
    Else If rect2.x > rect1.x + rect1.w Then
        Return False
    Else If rect1.y > rect2.y + rect2.h Then
        Return False
    Else If rect2.y > rect1.y + rect1.h Then
        Return False
    End If
    Return True
End Function

Function ContainsRect(rect1 As Object, rect2 As Object) As Boolean
    If rect1.x > rect2.x Then
        Return False
    Else If rect1.y > rect2.y Then
        Return False
    Else If rect1.x + rect1.w < rect2.x + rect2.w Then
        Return False
    Else If rect1.y + rect1.h < rect2.y + rect2.h Then
        Return False
    End If
    Return True
End Function

Function MakeIntersectRect(rect1 As Object, rect2 As Object, verify = True As Boolean) As Object
    If Not verify Or IntersectRect(rect1, rect2) Then
        rect = {
            x: Max(rect1.x, rect2.x)
            y: Max(rect1.y, rect2.y)
            w: Min(rect1.x + rect1.w, rect2.x + rect2.w)
            h: Min(rect1.y + rect1.h, rect2.y + rect2.h)
        }
        rect.w = rect.w - rect.x
        rect.h = rect.h - rect.y
        Return rect
    Else
        Return EmptyRect()
    End If
End Function

Function GetRectFromRegion(region As Object) As Object
    Return MakeRect(region.GetX(), region.GetY(), region.GetPretranslationX() + region.GetWidth(), region.GetPretranslationY() + region.GetHeight())
End Function