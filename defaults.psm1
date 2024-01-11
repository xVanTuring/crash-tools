function Get-ProxyProviderDefaults {
    return  @{
        UpdateInterval      = 3600
        HealthCheckEnable   = "true"
        HealthCheckInterval = 600
    }
}
function Get-BaseDefaults {
    return @{
        Port = 7890
    }
}
function Get-RuleUrlDefaults {
    param (
        $IsCloud
    )
    if ($IsCloud) {
        return @{
            Url_reject       = "url: https://crash.xvanturing.tech/ruleset/reject.txt"
            Url_icloud       = "url: https://crash.xvanturing.tech/ruleset/icloud.txt"
            Url_apple        = "url: https://crash.xvanturing.tech/ruleset/apple.txt"
            Url_google       = "url: https://crash.xvanturing.tech/ruleset/google.txt"
            Url_proxy        = "url: https://crash.xvanturing.tech/ruleset/proxy.txt"
            Url_direct       = "url: https://crash.xvanturing.tech/ruleset/direct.txt"
            Url_private      = "url: https://crash.xvanturing.tech/ruleset/private.txt"
            Url_gfw          = "url: https://crash.xvanturing.tech/ruleset/gfw.txt"
            Url_tld_not_cn   = "url: https://crash.xvanturing.tech/ruleset/tld-not-cn.txt"
            Url_telegramcidr = "url: https://crash.xvanturing.tech/ruleset/telegramcidr.txt"
            Url_cncidr       = "url: https://crash.xvanturing.tech/ruleset/cncidr.txt"
            Url_lancidr      = "url: https://crash.xvanturing.tech/ruleset/lancidr.txt"
            Url_applications = "url: https://crash.xvanturing.tech/ruleset/applications.txt"
        }
    }
    return @{
        Url_reject       = ""
        Url_icloud       = ""
        Url_apple        = ""
        Url_google       = ""
        Url_proxy        = ""
        Url_direct       = ""
        Url_private      = ""
        Url_gfw          = ""
        Url_tld_not_cn   = ""
        Url_telegramcidr = ""
        Url_cncidr       = ""
        Url_lancidr      = ""
        Url_applications = ""
    }
}