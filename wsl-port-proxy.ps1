$Distro      = "Ubuntu"
$Listen      = "0.0.0.0"   # use "127.0.0.1" if local-only
$ListenPort  = 2222        # Windows port you'll connect to
$ConnectPort = 22          # Port inside WSL (e.g., SSH=22)

# Get current WSL IP (eth0)
$ip = (wsl -d $Distro -e sh -lc "ip -4 -o addr show eth0 | awk '{print `$4}' | cut -d/ -f1 | head -n1").Trim()
if (-not $ip) { exit 1 }

# IP Helper needed by portproxy
Start-Service iphlpsvc -ErrorAction SilentlyContinue | Out-Null

# Rebuild mapping (idempotent)
netsh interface portproxy delete v4tov4 listenaddress=$Listen    listenport=$ListenPort   | Out-Null
netsh interface portproxy delete v4tov4 listenaddress=127.0.0.1  listenport=$ListenPort   | Out-Null
netsh interface portproxy add    v4tov4 listenaddress=$Listen    listenport=$ListenPort   connectaddress=$ip connectport=$ConnectPort | Out-Null

# Open firewall once (idempotent)
if (-not (Get-NetFirewallRule -DisplayName "WSL Portproxy $ListenPort" -ErrorAction SilentlyContinue)) {
  New-NetFirewallRule -DisplayName "WSL Portproxy $ListenPort" -Direction Inbound -Action Allow -Protocol TCP -LocalPort $ListenPort -Profile Any | Out-Null
}
