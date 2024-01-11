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
    $Str = ""
    for ($i = 0; $i -lt $LineArray.Count; $i++) {
        $Str += "{0}{1}`n" -f $(" " * $Padding), $LineArray[$i]
    }
    $Str
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
        $IsCloud
    )
    $BaseTemplate = Get-Content template/base.yaml -Raw
    $BaseConfig = Get-BaseDefaults


    $BaseConfig["RulesProviders"] = Add-Padding $(Build-ClashRuleProviders $IsCloud) 0
    $BaseConfig["ProxyProviderNameList"] = Add-Padding $(Build-ClashProxyNameList $ProviderList) 6
    $BaseConfig["ProxyProviderItems"] = Add-Padding $(Build-ProxyProviderItems $ProviderList) 2
    
    Build-ConfigString $BaseTemplate $BaseConfig
}
function Build-ProxyProviderItems {
    param (
        $ProviderList
    )
    $ListStr = ""
    for ($i = 0; $i -lt $ProviderList.Count; $i++) {
        $ListStr += "{0}`n" -f $(Build-ClashProviderConfig $ProviderList[$i][0] $ProviderList[$i][1])
    }
    $ListStr
}
function Build-ClashProxyNameList {
    param (
        $ProviderList
    )
    $ListStr = ""
    for ($i = 0; $i -lt $ProviderList.Count; $i++) {
        $ListStr += "- {0}`n" -f $ProviderList[$i][0]
    }
    $ListStr
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
