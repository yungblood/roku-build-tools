'IMPORTS=
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
'====================================
' Bit Shifting
'====================================
Function BitShiftLeft(value As Integer, shift As Integer) As Integer
    Return value * (2 ^ shift)
End Function

Function BitShiftRight(value As Integer, shift As Integer) as Integer
    If value >= 0 Then
        Return Int(value / (2 ^ shift))
    Else
        summand = 1
        result = 0
        For i = shift To 31
            If value And (summand * (2 ^ shift)) Then
                result = result + summand
            End If
            summand = summand * 2
        Next
        Return result
    End If
End Function

Function Xor(a As Integer, b As Integer) As Integer
    If a = 0 Then Return b
    If b = 0 Then Return a
    Return ((a And Not b) Or (Not a And b))
End Function