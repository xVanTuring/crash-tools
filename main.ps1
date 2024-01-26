Import-Module -Name .\Utils.psm1 -Force
Import-Module -Name .\RuleSet.psm1 -Force

$ProxyList = @()
if (!(Test-Path ".\proxylist.csv")) {
    Write-Error "proxylist.csv is not founded"
    return
}
Write-Output "Parsing proxylist"
$ProxyCsv = Import-Csv .\proxylist.csv
for ($i = 0; $i -lt $ProxyCsv.Count; $i++) {

    $Line = $ProxyCsv[$i]
    $ProxyList += @(, @($Line.name.Trim(), $Line.url.Trim()))
}

$ProxyConfig = @()
if ((Test-Path ".\worker.csv")) {
    $WorkerTable = Import-Csv .\worker.csv
    for ($i = 0; $i -lt $WorkerTable.Count; $i++) {
        $Item = $WorkerTable[$i]
        $ProxyConfig += @(, @($("cloudflare {0}" -f $i), $Item.ip, $Item.uuid, $Item.url))
    }
}

Write-Output "Building Config for web"
Build-ClashConfig $ProxyList $true $ProxyConfig > config-web.yaml
Write-Output "Building Config for local"
Build-ClashConfig $ProxyList $false $ProxyConfig > config.yaml
Write-Output "Updating RuleSet"
Update-RuleSet "./ruleset"