sub sendRemoteKey(key as string)
    m.sendRemoteKeyTask = createObject("roSGNode", "SendKeyTask")
    m.sendRemoteKeyTask.observeField("sent", "onRemoteKeySent")
    m.sendRemoteKeyTask.key = key
    m.sendRemoteKeyTask.control = "run"
end sub

sub onRemoteKeySent(nodeEvent as object)
    m.sendRemoteKeyTask = invalid
end sub