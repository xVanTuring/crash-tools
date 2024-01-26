Import-Module -Name .\defaults.psm1
function Get-StringHash {
    param (
        $InputString
    )
    $mystream = [IO.MemoryStream]::new([byte[]][char[]]$InputString)
    return $(Get-FileHash -InputStream $mystream -Algorithm SHA1).Hash
}

function Add-Padding {
    param (
        $Lines,
        $Padding
    )
    if ($Padding -eq 0) {
        return $Lines
    }
    $LineArray = $Lines.Split("`n")
    $StrList = @()
    for ($i = 0; $i -lt $LineArray.Count; $i++) {
        $StrList += "{0}{1}" -f $(" " * $Padding), $LineArray[$i]
    }
    $StrList -join "`n"
}
function Build-ConfigString {
    param (
        $Content,
        $Config
    )
    foreach ( $token in $Config.GetEnumerator() ) {
        $pattern = '_{0}_' -f $token.key
        $Content = $Content -replace $pattern, $token.Value
    }
    $Content
}

function Build-ClashProviderConfig {
    param (
        $ProxyName,
        $Url
    )
    $ProxyProviderUrlTemplate = Get-Content template/proxy-providers-url.yaml -Raw
    $Config = @{
        ProviderName  = $ProxyName
        LocalFileName = $(Get-StringHash $Url)
        Url           = $Url
    }
    $Config = Merge-HashTables $(Get-ProxyProviderDefaults) $Config
    Build-ConfigString $ProxyProviderUrlTemplate $Config
}

function Build-ClashConfig {
    param (
        $ProviderList,
        $IsCloud,
        $WorkerConfig
    )
    $BaseTemplate = Get-Content template/base.yaml -Raw
    $BaseConfig = Get-BaseDefaults


    $BaseConfig["RulesProviders"] = Add-Padding $(Build-ClashRuleProviders $IsCloud) 0
    $BaseConfig["ProxyProviderNameList"] = Add-Padding $(Build-ClashProxyNameList $ProviderList) 6
    $BaseConfig["ProxyProviderItems"] = Add-Padding $(Build-ProxyProviderItems $ProviderList) 2
    if ($WorkerConfig.Length -eq 0) {
        $BaseConfig["CFWorkerProxyItems"] = ""
        $BaseConfig["Cloudflare"] = ""
    }
    else {
        $CFWorkerProxyItems = ""
        $CloudflareList = @()
        for ($i = 0; $i -lt $WorkerConfig.Count; $i++) {
            $Item = $WorkerConfig[$i]
            $ProxyItem = Build-Proxies $Item[0] $Item[1] $Item[2] $Item[3]
            $CFWorkerProxyItems += $ProxyItem
            $CloudflareList += "- {0}" -f $Item[0]
        }
        $CloudflareNames = $CloudflareList -join "`n"
        $BaseConfig["CFWorkerProxyItems"] = Add-Padding $CFWorkerProxyItems 2
        $BaseConfig["Cloudflare"] = Add-Padding $CloudflareNames 6
    }
    
    Build-ConfigString $BaseTemplate $BaseConfig
}

function Build-Proxies {
    param (
        $ProxyName,
        $ServerIP,
        $UUID,
        $HeaderHost
    )

    $Config = @{
        ProxyName  = $ProxyName
        ServerIP   = $ServerIP
        UUID       = $UUID
        HeaderHost = $HeaderHost
    }

    $ProxiesTemplate = Get-Content template/custom-proxies-cf-worker.yaml -Raw

    Build-ConfigString $ProxiesTemplate $Config
}
function Build-ProxyProviderItems {
    param (
        $ProviderList
    )
    $ConfigList = @()
    for ($i = 0; $i -lt $ProviderList.Count; $i++) {
        $ConfigList += $(Build-ClashProviderConfig $ProviderList[$i][0] $ProviderList[$i][1])
    }
    $ConfigList -join "`n"
}
function Build-ClashProxyNameList {
    param (
        $ProviderList
    )
    $List = @()
    for ($i = 0; $i -lt $ProviderList.Count; $i++) {
        $List += "- {0}" -f $ProviderList[$i][0]
    }
    $List -join "`n"
}

function Build-ClashRuleProviders {
    param (
        $IsCloud
    )
    $Config = Get-RuleUrlDefaults $IsCloud
    
    if ($IsCloud) {
        $Config["RuleType"] = "http"
    }
    else {
        $Config["RuleType"] = "file"
    }
    $RuleProviderUrlTemplate = Get-Content template/rule-providers.yaml -Raw
    Build-ConfigString $RuleProviderUrlTemplate $Config
}

function Merge-HashTables($htold, $htnew) {
    # https://stackoverflow.com/questions/8800375/merging-hashtables-in-powershell-how
    $keys = $htold.getenumerator() | foreach-object { $_.key }
    $keys | foreach-object {
        $key = $_
        if ($htnew.containskey($key)) {
            $htold.remove($key)
        }
    }
    $htnew = $htold + $htnew
    return $htnew
}
