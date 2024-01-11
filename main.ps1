Import-Module -Name .\Utils.psm1
Import-Module -Name .\RuleSet.psm1

$ProxyList = New-Object System.Collections.Generic.List[System.Object]
if (!(Test-Path ".\proxylist.txt")) {
    Write-Error "proxylist.txt is not founded"
    return;
}
Write-Output "Parsing proxylist"
$ProxyListLine = $(Get-Content .\proxylist.txt -Raw).Split("`n")
for ($i = 0; $i -lt $ProxyListLine.Count; $i++) {
    $Line = $ProxyListLine[$i].Split(",")
    $ProxyList.Add(@($Line[0].Trim(), $Line[1].Trim()))
}
Write-Output "Building Config for web"
Build-ClashConfig $ProxyList $true > config-web.yaml
Write-Output "Building Config for local"
Build-ClashConfig $ProxyList $false > config.yaml
Write-Output "Updating RuleSet"
Update-RuleSet "./ruleset"