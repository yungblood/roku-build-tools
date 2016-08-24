'IMPORTS=utilities/strings utilities/types
' ******************************************************
' Copyright Steven Kean 2010-2016
' All Rights Reserved.
' ******************************************************
'=====================
' XML
'=====================
Function GetChildXmlText(xmlParent As Object, elementName As String, defaultValue = "" As Dynamic, defaultOnEmptyString = False As Boolean) As Dynamic
    xmlElements = xmlParent.GetNamedElements(elementName)
    Return GetXmlText(xmlElements[0], defaultValue, defaultOnEmptyString)
End Function

Function GetXmlText(xmlElement As Dynamic, defaultValue = "" As Dynamic, defaultOnEmptyString = False As Boolean) As Dynamic
    If IsList(xmlElement) Then
        xmlElement = xmlElement[0]
    End If
    If xmlElement <> invalid And (Not defaultOnEmptyString Or Not IsNullOrEmpty(xmlElement.GetText())) Then
        Return xmlElement.GetText()
    Else
        Return defaultValue
    End If
End Function

Function GetChildXmlAttributeText(xmlParent As Object, elementName As String, attributeName As String, defaultValue = "" As Dynamic, defaultOnEmptyString = False As Boolean) As Dynamic
    xmlElements = xmlParent.GetNamedElements(elementName)
    Return GetXmlAttributeText(xmlElements[0], attributeName, defaultValue, defaultOnEmptyString)
End Function

Function GetXmlAttributeText(xmlElement As Dynamic, attributeName As String, defaultValue = "" As Dynamic, defaultOnEmptyString = False As Boolean) As Dynamic
    If IsList(xmlElement) Then
        xmlElement = xmlElement[0]
    End If
    If xmlElement <> invalid And xmlElement.HasAttribute(attributeName) Then
        attributes = xmlElement.GetAttributes()
        value = attributes[attributeName] 
        If Not IsNullOrEmpty(value) Or Not defaultOnEmptyString Then
            Return value
        End If
    End If
    Return defaultValue
End Function

Function ParseXmlNode2(node As Object, stripNamespaces = False As Boolean) As Object
    parsed = {}
    nodeName = node.GetName()
    If stripNamespaces And nodeName.InStr(":") > -1 Then
        nodeName = nodeName.Mid(nodeName.InStr(":") + 1)
    End If
    attribs = node.GetAttributes()
    For Each attrib In attribs
        If Not stripNamespaces Or Not StartsWith(attrib, "xmlns") Then
            attribName = attrib
            If stripNamespaces And attrib.InStr(":") > -1 Then
                attribName = attrib.Mid(attrib.InStr(":") + 1)
            End If
            parsed[nodeName + "@" + attribName] = attribs[attrib]
        End If
    Next
    If node.GetChildElements() <> invalid Then
        parsed[nodeName] = {}
        For Each child In node.GetChildElements()
            parsedChild = ParseXmlNode2(child, stripNamespaces)
            For Each element In parsedChild
                ' There are multiple nodes with the same name,
                ' so convert this value to an array
                If parsed[nodeName][element] <> invalid Then
                    If Not IsArray(parsed[nodeName][element]) Then
                        parsed[nodeName][element] = [parsed[nodeName][element]]
                    End If
                    parsed[nodeName][element].Push(parsedChild[element])
                Else
                    parsed[nodeName][element] = parsedChild[element]
                End If
            Next
        Next
    Else
        parsed[nodeName] = node.GetText()
    End If
    Return parsed
End Function

Function ParseXmlNode(nodeOrXmlString As Object, stripNamespaces = False As Boolean) As Object
    parsed = {}
    node = nodeOrXmlString
    If IsString(nodeOrXmlString) Then
        node = CreateObject("roXmlElement")
        If Not node.Parse(nodeOrXmlString) Then
            node = invalid
        End If
    End If
    If node <> invalid Then
        attribs = node.GetAttributes()
        For Each attrib In attribs
            If Not stripNamespaces Or Not StartsWith(attrib, "xmlns") Then
                attribName = attrib
                If stripNamespaces And attrib.InStr(":") > -1 Then
                    attribName = attrib.Mid(attrib.InStr(":") + 1)
                End If
                parsed[attribName] = attribs[attrib]
            End If
        Next
        If node.GetChildElements() <> invalid Then
            For Each child In node.GetChildElements()
                childName = child.GetName()
                If stripNamespaces And childName.InStr(":") > -1 Then
                    childName = childName.Mid(childName.InStr(":") + 1)
                End If
                parsedChild = ParseXmlNode(child, stripNamespaces)
                If parsed[childName] <> invalid Then
                    If Not IsArray(parsed[childName]) Then
                        parsed[childName] = [parsed[childName]]
                    End If
                    parsed[childName].Push(parsedChild)
                Else
                    parsed[childName] = parsedChild
                End If
            Next
        Else
            If parsed.IsEmpty() Then
                parsed = node.GetText()
            Else
                parsed["#text"] = node.GetText()
            End If
        End If
    End If
    Return parsed
End Function

Function ParseXmlAsJson(xml As Object, stripNamespaces = False As Boolean, attributePrefix = "-" As String) As Object
    node = xml
    If IsString(xml) Then
        node = CreateObject("roXmlElement")
        If Not node.Parse(xml) Then
            node = invalid
        End If
    End If
    parsed = {}
    If node <> invalid Then
        current = {}
        attribs = node.GetAttributes()
        For Each attrib In attribs
            current[attributePrefix + attrib] = attribs[attrib]
        Next

        body = node.GetBody()
        If IsString(body) Then
            If current.IsEmpty() Then
                current = body
            Else
                current["#text"] = body
            End If
        Else If IsList(body) Then
            children = body
            For Each child In children
                name = child.GetName()
                If stripNamespaces And name.InStr(":") > -1 Then
                    name = name.Mid(name.InStr(":") + 1)
                End If
                parsedChild = ParseXmlAsJson(child, stripNamespaces, attributePrefix)[name]
                If current[name] = invalid Then
                    current[name] = parsedChild
                Else
                    current[name] = AsArray(current[name])
                    current[name].Push(parsedChild)
                End If
            Next
        Else If body = invalid And current.IsEmpty() Then
            current = invalid
        End If
        nodeName = node.GetName()
        If stripNamespaces And nodeName.InStr(":") > -1 Then
            nodeName = nodeName.Mid(nodeName.InStr(":") + 1)
        End If
        parsed[nodeName] = current
    End If
    Return parsed
End Function