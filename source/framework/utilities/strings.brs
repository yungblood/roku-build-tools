'IMPORTS=utilities/types utilities/device
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
'=====================
' Strings
'=====================
Function IsNullOrEmpty(value As Dynamic) As Boolean
    If IsString(value) Then
        Return (value = invalid Or value = "")
    Else
        Return Not IsValid(value)
    End If
End Function

Function StartsWith(stringToCheck As Dynamic, valueToCheck As String) As Boolean
    If IsString(stringToCheck) And Not IsNullOrEmpty(stringToCheck) And Not IsNullOrEmpty(valueToCheck) Then
        Return stringToCheck.InStr(valueToCheck) = 0
    End If
    Return False 
End Function 

Function EndsWith(stringToCheck As Dynamic, valueToCheck As String) As Boolean
    If IsString(stringToCheck) And Not IsNullOrEmpty(stringToCheck) And Not IsNullOrEmpty(valueToCheck) Then
        Return stringToCheck.Mid(stringToCheck.Len() - valueToCheck.Len()) = valueToCheck
    End If
    Return False 
End Function 

Function PadLeft(value As String, padChar As String, totalLength As Integer) As String
    While value.Len() < totalLength
        value = padChar + value
    End While
    Return value
End Function

Function WrapText(value As Dynamic, maxCharLength As Integer) As Dynamic
    If IsNullOrEmpty(value) Then Return value
    lines = []
    If value.Len() > maxCharLength Then
        textArray = Split(value, " ")
        currentLine = ""
        For Each text In textArray
            tempLine = (currentLine + " " + text)
            tempLine = tempLine.Trim()
            If tempLine.Len() <= maxCharLength Then 
                currentLine = tempLine
            Else
                If Not IsNullOrEmpty(currentLine) Then
                    lines.Push(currentLine)
                End If
                currentLine = text
            End If
        Next
        If Not IsNullOrEmpty(currentLine) Then
            lines.Push(currentLine)
        End If
    Else
        lines.Push(value)
    End If
    Return Join(lines, Chr(10))
End Function

'=====================
' Replacement
'=====================
Function IsRegexSafe(text As String) As Boolean
    regexSpecials = ["\", "[", "]", "^", "$", ".", "|", "?", "*", "+", "(", ")"]
    For Each special In regexSpecials
        If text.InStr(special) > -1 Then
            Return False
        End If
    Next
    Return True
End Function

Function RegexEscape(text As Dynamic) As Dynamic
    If Not IsString(text) Or IsNullOrEmpty(text) Then Return text
    
    regexSpecials = ["\", "[", "]", "^", "$", ".", "|", "?", "*", "+", "(", ")", "{", "}"]
    For Each special In regexSpecials
        text = Join(Split(text, special), "\" + special)
    Next
    Return text
End Function

Function RegexReplace(text As Dynamic, toReplace As Dynamic, replaceWith As Dynamic, options = "" As String) As Dynamic
    If Not IsString(text) Or IsNullOrEmpty(text) Then Return text
    If Not IsString(toReplace) Or IsNullOrEmpty(toReplace) Then Return text
    If Not IsString(replaceWith) Then Return text

    regex = CreateObject("roRegex", toReplace, options)
    result = regex.ReplaceAll(text, replaceWith)
    Return result
End Function

Function Replace(text As Dynamic, toReplace As Dynamic, replaceWith As Dynamic) As Dynamic
    If Not IsString(text) Or IsNullOrEmpty(text) Then Return text
    If Not IsString(toReplace) Or IsNullOrEmpty(toReplace) Then Return text
    If Not IsString(replaceWith) Then Return text
    If text.InStr(toReplace) = -1 Then Return text
    
    toReplace = RegexEscape(toReplace)
    replaceWith = RegexEscape(replaceWith)
    Return RegexReplace(text, toReplace, replaceWith)
End Function

Function Split(toSplit As String, delim As String) As Object
    result = []
    If Not IsNullOrEmpty(toSplit) Then
        char = 0
        While char <= toSplit.Len()
            match = toSplit.Instr(char, delim)
            If match = -1 Then
                result.Push(toSplit.Mid(char))
                Exit While
            End If
            If match >= char Then
                result.Push(toSplit.Mid(char, match - char))
                char = match
            End If
            char = char + delim.Len()
        End While
    End If
    Return result
End Function

Function Join(array As Object, delim = "" As String) As String
    result = ""
    If IsArray(array) Then
        For i = 0 To array.Count() - 1
            item = AsString(array[i])
            If i > 0 Then
                result = result + delim
            End If
            result = result + item
        Next
    End If
    Return result
End Function

Function ISO8859ToUTF8(input As String) As Dynamic
    output = ""
    If Not IsNullOrEmpty(input) Then
        For i = 0 To input.Len() - 1
            char = input.Mid(i, 1)
            ascii = Asc(char)
            If ascii < 0 Then
                ascii = ascii + 256
            End If
            newChar = ""
            If ascii < 160 Then
                newChar = char
            Else If ascii < 192 Then
                newChar = Chr(194) + Chr(ascii)
            Else
                newChar = Chr(195) + Chr(ascii - 64)
            End If
            output = output + newChar
        Next
    End If
    Return output
End Function

Function ReplaceUCodes(text) As String
    If IsNullOrEmpty(text) Then
        Return ""
    End If

    regex = CreateObject("roRegex", "\\u([a-fA-F0-9]{4})", "i")
    matches = regex.Match(text)
    
    iCount = 0
    While matches.Count() > 1
        iCount = iCount + 1
        text = regex.Replace(text, Chr(HexToInt(matches[1])))
        matches = regex.Match(text)
        
        If iCount > 5000 Then
            Exit While
        End If
    End While
    Return text
End Function