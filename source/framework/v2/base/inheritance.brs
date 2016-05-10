'IMPORTS=utilities/strings utilities/types
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
Sub InheritObject(this As Object, inherited As Object)
    If this.InheritanceLevels = invalid Then
        this.InheritanceLevels = 1
    End If
    If inherited.InheritanceLevels <> invalid Then
        this.InheritanceLevels = this.InheritanceLevels + inherited.InheritanceLevels
    End If

    this.InheritanceLevel   = {}
    this.CallBase           = Inheritance_CallBase
    For Each key In inherited
        If LCase(key) <> "callbase" And key.Mid(0, 1) <> "_" And IsFunction(inherited[key]) And IsFunction(this[key]) Then
            For i = this.InheritanceLevels To 0 Step -1
                baseName = String(i, "_") + key
                If inherited.DoesExist(baseName) Then
                    this["_" + baseName] = inherited[baseName]
                End If
            Next
        Else If Not this.DoesExist(key) Then
            this[key] = inherited[key]
        End If
    Next
End Sub

Function InheritsObject(base As Object) As Object
    this = {}
    this.Append(base)
    If this.InheritanceParents = invalid Then
        this.InheritanceParents = []
    End If
    this.InheritanceParents.Push(base)
    
    this.InheritanceLevel   = {}
    this.CallBase           = Inheritance_CallBase
    Return this
End Function

Function PreserveBase(this As Object, functionName As String, func As Function) As Function
    If this.DoesExist(functionName) Then
        If Not this.DoesExist("CallBase") Then
            this.InheritanceLevel = {}
            this.CallBase = Inheritance_CallBase
        End If

        depth = -1
        baseName = functionName
        While this.DoesExist(baseName)
            baseName = "_" + baseName
            depth = depth + 1
        End While

        For i = depth To 0 Step -1
            baseName = String(i, "_") + functionName
            If this.DoesExist(baseName) Then
                this["_" + baseName] = this[baseName]
            End If
        Next
    End If
    Return func
End Function

Function Inheritance_CallBase2(functionName As String, params = [] As Object) As Dynamic
    returnValue = invalid
    ' Capture the current inheritence level for this function
    currentLevel = AsInteger(m.InheritanceLevel[functionName])

    ' Increment the inheritence level to get the base function name
    m.InheritanceLevel[functionName] = currentLevel + 1
    baseName = String(m.InheritanceLevel[functionName], "_") + functionName
    
    If m[baseName] = invalid Then
        ' We haven't referenced the parent function, yet, so find it
        parentIndex = m.InheritanceParents.Count() - m.InheritanceLevel[functionName]
        For i = parentIndex To 0 Step -1
            parent = m.InheritanceParents[i]
            If parent[functionName] <> invalid And parent[functionName] <> m[functionName] Then
                m[baseName] = parent[functionName]
                Exit For
            End If
        Next
    End If

    If IsFunction(m[baseName]) Then
        If params.Count() = 0 Then
            returnValue = m[baseName]()
        Else If params.Count() = 1 Then
            returnValue = m[baseName](params[0])
        Else If params.Count() = 2 Then
            returnValue = m[baseName](params[0], params[1])
        Else If params.Count() = 3 Then
            returnValue = m[baseName](params[0], params[1], params[2])
        Else If params.Count() = 4 Then
            returnValue = m[baseName](params[0], params[1], params[2], params[3])
        Else If params.Count() = 5 Then
            returnValue = m[baseName](params[0], params[1], params[2], params[3], params[4])
        Else If params.Count() = 6 Then
            returnValue = m[baseName](params[0], params[1], params[2], params[3], params[4], params[5])
        Else If params.Count() = 7 Then
            returnValue = m[baseName](params[0], params[1], params[2], params[3], params[4], params[5], params[6])
        Else If params.Count() = 8 Then
            returnValue = m[baseName](params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7])
        Else If params.Count() = 9 Then
            returnValue = m[baseName](params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8])
        Else If params.Count() = 10 Then
            returnValue = m[baseName](params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8], params[9])
        End If  
    End If
    
    ' Reset the current inheritence level
    m.InheritanceLevel[functionName] = currentLevel

    Return returnValue
End Function

Function Inheritance_CallBase(functionName As String, params = [] As Object) As Dynamic
    returnValue = invalid
    ' Capture the current inheritence level for this function
    currentLevel = AsInteger(m.InheritanceLevel[functionName])

    ' Increment the inheritence level to get the base function name
    m.InheritanceLevel[functionName] = AsInteger(m.InheritanceLevel[functionName]) + 1
    baseName = String(m.InheritanceLevel[functionName], "_") + functionName

    If IsFunction(m[baseName]) Then
        If params.Count() = 0 Then
            returnValue = m[baseName]()
        Else If params.Count() = 1 Then
            returnValue = m[baseName](params[0])
        Else If params.Count() = 2 Then
            returnValue = m[baseName](params[0], params[1])
        Else If params.Count() = 3 Then
            returnValue = m[baseName](params[0], params[1], params[2])
        Else If params.Count() = 4 Then
            returnValue = m[baseName](params[0], params[1], params[2], params[3])
        Else If params.Count() = 5 Then
            returnValue = m[baseName](params[0], params[1], params[2], params[3], params[4])
        Else If params.Count() = 6 Then
            returnValue = m[baseName](params[0], params[1], params[2], params[3], params[4], params[5])
        Else If params.Count() = 7 Then
            returnValue = m[baseName](params[0], params[1], params[2], params[3], params[4], params[5], params[6])
        Else If params.Count() = 8 Then
            returnValue = m[baseName](params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7])
        Else If params.Count() = 9 Then
            returnValue = m[baseName](params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8])
        Else If params.Count() = 10 Then
            returnValue = m[baseName](params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8], params[9])
        End If  
    End If
    
    ' Reset the current inheritence level
    m.InheritanceLevel[functionName] = currentLevel

    Return returnValue
End Function
