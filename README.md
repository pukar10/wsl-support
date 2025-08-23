# wsl-support
Making your WSL life easier one automation at a time

## wsl-port-proxy.ps1

forwards Windows port 2222 to WSL port 22 and re-creates the rule every reboot.

1. Save script
2. Run script on boot (Fill in ScriptPath and execute in PowerShell as Admin)
```
$ScriptPath = "C:\Users\subed\scripts\wsl\wsl-portproxy.ps1"
$Action    = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""
$Trigger   = New-ScheduledTaskTrigger -AtStartup
$Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest -LogonType ServiceAccount

Register-ScheduledTask -TaskName "WSL Portproxy" -Action $Action -Trigger $Trigger -Principal $Principal -Description "WSL portproxy on boot" | Out-Null
```

3. Allow pings to Host
```
New-NetFirewallRule -DisplayName "Allow ICMPv4-In" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow -Profile Any
```

4. Verify
```
Ping Host
ping <host_IP>

Ping WSL
ping -p 2222 <host_IP>
```

Your WSL VM should now be accessible
