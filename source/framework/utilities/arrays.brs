'IMPORTS=utilities/types
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
'=====================
' Arrays
'=====================
Sub SortArray(array As Object, sortMethod = invalid As Dynamic)
    For i = array.Count() - 2 To 0 Step -1
        for j = 0 to i
            swap = False
            If sortMethod = invalid Then
                swap = array[j] > array[j + 1]
            Else If IsFunction(sortMethod) Then
                swap = sortMethod(array[j], array[j + 1])
            Else If IsString(sortMethod) Then
                swap = AsAssociativeArray(array[j])[sortMethod] > AsAssociativeArray(array[j + 1])[sortMethod]
            End If
            If swap Then
                temp = array[j + 1]
                array[j + 1] = array[j]
                array[j] = temp
            End If
        Next
    Next
End Sub

Function ReverseArray(array As Object) As Object
    ' Copy the original, so we don't alter it
    original = []
    original.Append(array)
    reversed = []
    While original.Count() > 0
        reversed.Push(original.Pop())
    End While
    Return reversed
End Function

Sub MoveElementInArray(array As Object, curIndex As Integer, newIndex As Integer)
    If curIndex <> newIndex And curIndex >= 0 And curIndex < array.Count() And newIndex >= 0 Or newIndex < array.Count() Then
        item = array[curIndex]
        array.Delete(curIndex)
        newArray = []
        For index = 0 To array.Count()
            If index = newIndex Then
                newArray.Push(item)
            Else
                newArray.Push(array.Shift())
            End If
        Next
        array.Append(newArray)
    End If
End Sub

Function ShallowCopy(array As Dynamic, depth = 0 As Integer, copyInvalids = True As Boolean) As Dynamic
    If IsArray(array) Then
        copy = []
        For Each item In array
            childCopy = ShallowCopy(item, depth, copyInvalids)
            If copyInvalids Or childCopy <> invalid Then
                copy.Push(childCopy)
            End If
        Next
        Return copy
    Else If IsAssociativeArray(array) Then
        copy = {}
        For Each key In array
            If depth > 0 Then
                copy[key] = ShallowCopy(array[key], depth - 1, copyInvalids)
            Else
                copy[key] = array[key]
            End If
        Next
        Return copy
    Else
        Return array
    End If
    Return invalid
End Function

Function RandomizeArray(srcArray As Object) As Object
    rndArray = []
    indexes = []
    For index = 0 To srcArray.Count() - 1
        indexes.Push(index)
    Next
    While indexes.Count() > 0
        index = Rnd(indexes.Count()) - 1
        rndArray.Push(srcArray[indexes[index]])
        indexes.Delete(index)
    End While
    Return rndArray
End Function

Function RandomizeAndTrimArray(array As Object, maxEntries As Integer) As Object
    randomized = RandomizeArray(array)
    TrimArray(randomized, maxEntries)
    Return randomized
End Function

Sub TrimArray(array As Object, maxEntries As Integer)
    For i = array.Count() - 1 To maxEntries Step -1
        array.Delete(i)
    Next
End Sub

Function RemoveDuplicatesFromArray(array As Object) As Object
    newArray = []
    If IsArray(array) Then
        For Each item In array
            If Not ArrayContains(newArray, item) Then
                newArray.Push(item)
            End If
        Next
    End If
    Return newArray
End Function

Function PickRandomArrayEntry(array As Object, removeEntry = False As Boolean) As Dynamic
    index = Rnd(array.Count()) - 1
    value = array[index]
    If removeEntry Then
        array.Delete(index)
    End If
    Return value
End Function

Function FindElementInArray(array As Object, value As Object, compareAttribute = invalid As Dynamic, caseSensitive = False As Boolean) As Dynamic
    index = FindElementIndexInArray(array, value, compareAttribute, caseSensitive)
    If index > -1 Then
        Return array[index]
    End If
    Return invalid
End Function

Function FindElementIndexInArray(array As Object, value As Object, compareAttribute = invalid As Dynamic, caseSensitive = False As Boolean) As Integer
    If IsArray(array) Then
        For i = 0 To AsArray(array).Count() - 1
            compareValue = array[i]
            If compareAttribute <> invalid And IsAssociativeArray(compareValue) Then
                compareValue = compareValue[compareAttribute]
            End If
            If IsString(compareValue) And IsString(value) And Not caseSensitive Then
                If LCase(compareValue) = LCase(value) Then
                    Return i
                End If
            Else If compareValue = value Then
                Return i
            End If
            item = array[i]
        Next
    End If
    Return -1
End Function

Function ArrayContains(array As Object, value As Object, compareAttribute = invalid As Dynamic) As Boolean
    If value = invalid Then
        Return False
    Else If IsArray(value) Then
        For Each item In value
            If FindElementIndexInArray(array, item, compareAttribute) = -1 Then
                Return False
            End If
        Next
        Return True
    Else
        Return (FindElementIndexInArray(array, value, compareAttribute) > -1)
    End If
End Function

Function ArraysMatch(array1 As Object, array2 As Object, compareAttribute = invalid As Dynamic, matchOrder = True As Boolean) As Boolean
    If Not IsArray(array1) Or Not IsArray(array2) Then
        Return False
    Else If array1 = invalid And array2 = invalid Then
        Return True
    Else If array1 = invalid Then
        Return False
    Else If array2 = invalid Then
        Return False
    Else If array1.Count() <> array2.Count() Then
        Return False
    Else If matchOrder Then
        For i = 0 To array1.Count() - 1
            compareValue1 = array1[i]
            compareValue2 = array2[i]
            If compareAttribute <> invalid Then
                If IsAssociativeArray(compareValue1) Then
                    compareValue1 = compareValue1[compareAttribute]
                End If
                If IsAssociativeArray(compareValue2) Then
                    compareValue2 = compareValue2[compareAttribute]
                End If
            End If
            If compareValue1 <> compareValue2 Then
                Return False
            End If
        Next
    Else
        For i = 0 To array1.Count() - 1
            compareValue = array1[i]
            If compareAttribute <> invalid Then
                If IsAssociativeArray(compareValue1) Then
                    compareValue = compareValue1[compareAttribute]
                End If
            End If
            If Not ArrayContains(array2, compareValue, compareAttribute) Then
                Return False
            End If
        Next
    End If
    Return True
End Function
 
