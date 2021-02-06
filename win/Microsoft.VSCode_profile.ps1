Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Set-Alias -Name roku-make -Value V:\workspace\cbs-ci\cbs-roku-build-tools\roku-scripts\roku-make.ps1
Start-SshAgent
ssh-add V:\.ssh\kevin.hoos-cbsinteractive.ppk
$env:ROKU_DEV = '192.168.0.246'
$env:ROKU_PASS = '1234'
$env:COUNTRY = 'us'
$env:BUILD_TYPE = 'qa'
