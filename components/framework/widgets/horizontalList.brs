sub init()
    m.top.numRows = 1
    m.top.observeField("numRows", "resetNumRows")
end sub

sub resetNumRows()
    ?"resetting numRows"
    m.top.numRows = 1
end sub

