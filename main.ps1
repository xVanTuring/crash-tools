Import-Module -Name .\Utils.psm1
Import-Module -Name .\RuleSet.psm1

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
if ((Test-Path ".\worker.txt")) {
    $ProxiesLine = $(Get-Content .\worker.txt -Raw).Split("`n")
    if($ProxiesLine.Length -ge 1){
        $ProxyConfig = $ProxiesLine[0].Split(",")
    }
}


Write-Output "Building Config for web"
Build-ClashConfig $ProxyList $true $ProxyConfig > config-web.yaml
Write-Output "Building Config for local"
Build-ClashConfig $ProxyList $false $ProxyConfig > config.yaml
Write-Output "Updating RuleSet"
Update-RuleSet "./ruleset"