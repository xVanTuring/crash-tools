function Update-RuleSet {
    param (
        $Folder
    )
    if (!$(Test-Path $Folder)) {
        git clone -b release --depth=1 https://github.com/Loyalsoldier/clash-rules.git $Folder 
    }
    $OldLocation = $PWD
    Set-Location $Folder
    git pull
    Set-Location $OldLocation
}