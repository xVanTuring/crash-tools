$OldLocation = Get-Location
Set-Location "/web/cloudflare-speed"
chmod +x ./CloudflareST
Write-Output "Starting Bench, Please wait"
./CloudflareST
Write-Output "Completed!"

$([int64](Get-Date -UFormat %s)) > benchtime
$WorkConfigPath = "$OldLocation/worker.csv"
function Use-Result {
    if (!$(Test-Path -Path result.csv)) {
        return
    }
    $IPResults = Import-Csv result.csv
    if ($IPResults.Length -eq 0) {
        return
    }   
    Remove-Item -Force $WorkConfigPath
    $BaseConfigs = Import-Csv "$OldLocation/worker-base.csv"
    for ($i = 0; $i -lt $IPResults.Count; $i++) {
        $IPAddress = $IPResults[$i]."IP 地址"
        for ($j = 0; $j -lt $BaseConfigs.Count; $j++) {
            $Config = $BaseConfigs[$j]
            $Row = New-Object PsObject -Property @{ ip = $IPAddress ; uuid = $Config.uuid; url = $Config.url }
            $Row | Export-Csv $WorkConfigPath -Append
        }
    }

}
Use-Result

Set-Location $OldLocation