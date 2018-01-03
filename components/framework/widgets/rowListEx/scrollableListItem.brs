sub onComponentChanged()
    if m.component = invalid or not m.component.isSameNode(m.top.itemComponent) then
        if m.component <> invalid then
            m.component.unobserveField("itemSelected")
            m.component.unobserveField("buttonSelected")
        end if
        m.component = m.top.itemComponent
        m.component.observeField("itemSelected", "onItemSelected")
        m.component.observeField("buttonSelected", "onButtonSelected")
    end if
end sub

sub onItemSelected()
    m.top.itemSelected = m.component.itemSelected
end sub

sub onButtonSelected()
    m.top.buttonSelected = m.component.buttonSelected
end sub
