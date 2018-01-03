sub init()
    ?"RowListWithVisibility.init"
end sub

sub onManagedContentChanged()
    updateContent()
end sub

sub onHiddenRowsChanged()
   updateContent()
end sub

sub updateContent()
    cloned = cloneNode(m.top.managedContent)
    if m.top.hiddenRows <> invalid and m.top.hiddenRows.count() > 0 then
        hiddenRows = []
        hiddenRows.append(m.top.hiddenRows)
        hiddenRows.sort("r")
        for each rowIndex in hiddenRows
            cloned.removeChildIndex(rowIndex)
        next
    end if
    m.top.content = cloned
end sub