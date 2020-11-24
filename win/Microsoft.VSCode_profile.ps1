Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Set-Alias -Name roku-make -Value O:\Users\kevin\OneDrive\Documents\workspace\Yungblood\cbs-roku-builds-tools\roku-scripts\roku-make.ps1
Start-SshAgent
$env:ROKU_DEV = '192.168.0.246'
$env:ROKU_PASS = '1234'