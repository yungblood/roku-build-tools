function getTopMostParent(node as object)
    parent = node.getParent()
    while parent <> invalid
        if parent.getParent() <> invalid then
            parent = parent.getParent()
        else
            exit while
        end if
    end while
    return parent
end function

function cloneNode(node as object, deepClone = false as boolean) as object
    if node <> invalid then
        clone = CreateObject("roSGNode", node.subType())
        fields = node.getFields()
        if fields <> invalid then
            fields.Delete("change")
            fields.Delete("focusedChild")
            fields.Delete("metadata")
            
            if deepClone then
                for each key in fields
                    field = fields[key]
                    if type(field) = "roSGNode" then
                        ?"deep cloning: ";field.subType()
                        fields[key] = cloneNode(field, true)
                    end if
                next
            end if
                
            clone.setFields(fields)
        end if
        for i = 0 to node.getChildCount() - 1
            child = cloneNode(node.getChild(i), deepClone)
            clone.AppendChild(child)
        next
        return clone
    end if
    return invalid
end function

sub cloneChildren(parent as object, newParent as object, clearExistingChildren = false as boolean, deepClone = false as boolean)
    if clearExistingChildren then
        clearChildNodes(newParent)
    end if
    for i = 0 to parent.getChildCount() - 1
        cloned = cloneNode(parent.getChild(i), deepClone)
        newParent.AppendChild(cloned)
    next
end sub

sub clearChildNodes(parent as object)
    for i = parent.getChildCount() - 1 to 0 step -1
        parent.removeChildIndex(i)
    next
end sub
      
sub initializeFieldOnNode(node as object, fieldName as string, fieldType as string, alwaysNotify as boolean, value = invalid as object)
    node.addField(fieldName, fieldType, alwaysNotify)
    if value <> invalid then
        node.setField(fieldName, value)
    end if
end sub

sub addToNodeArray(parentNode as object, arrayField as string, node as object)
    ' Copy the exiting array into a sizeable array
    temp = []
    temp.Append(parentNode.getField(arrayField))
    ' Add the new node
    temp.Push(node)
    ' Reset the field to the new array
    parentNode.setField(arrayField, temp)
end sub

function getChildOfNode(parentNode as object, id as string, idField = "id" as string) as object
    for i = 0 to parentNode.getChildCount() - 1
        child = parentNode.getChild(i)
        if child.hasField(idField) then
            if child.getField(idField) = id then
                return child
            end if
        end if
    next
    return invalid
end function

function isChildOfNode(parentNode as object, potentialChildNode as object, comparisonField = "" as string) as boolean
    if isNullOrEmpty(comparisonField) then
        return parentNode.isSameNode(potentialChildNode.getParent())
    else
        for i = 0 to parentNode.getChildCount() - 1
            child = parentNode.getChild(i)
            if not isNullOrEmpty(comparisonField) then
                if child.hasField(comparisonField) and potentialChildNode.hasField(comparisonField) then
                    if child.getField(comparisonField) = potentialChildNode.getField(comparisonField) then
                        return true
                    end if
                end if
            end if
        next
    end if
    return false
end function

function isNodeVisible(node as object) as boolean
    if node.visible then
        parent = node.getParent()
        while parent <> invalid
            if not parent.visible then
                return false
            end if
            parent = parent.getParent()
        end while
        return true
    end if
    return false
end function

function safeGetField(node as object, field as string, retryAttempts = 50 as integer) as object
    value = node.getField(field)
    retries = 0
    while value = invalid and retries <= retryAttempts
        retries++
        print "safeGetField("; field; ") timed out or not set #"; retries
        value = node.getField(field)
    end while
    return value
end function

function safeSetField(node as object, field as string, value as dynamic, retryAttempts = 50 as integer) as boolean
    result = false
    retries = 0
    while not result and retries <= retryAttempts
        result = node.setField(field, value)
        retries++
        if not result then
            print "safeSetField("; field; ") timed out or not set #"; retries
        end if
    end while
end function

function deserializeFieldValue(fieldType as string, fieldValue as string) as dynamic
    tempFieldName = "serialized"
    node = createObject("roSGNode", "Node")
    node.addField(tempFieldName, fieldType, false)
    node.setField(tempFieldName, fieldValue)
    return node.getField(tempFieldName)
end function
