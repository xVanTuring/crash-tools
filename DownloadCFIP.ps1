$URL = "https://www.cloudflare.com/ips-v4/#"
$IPS = Invoke-WebRequest $URL

$Lines = $IPS.Content -split "`n"

$Text = "payload:`r"
for ($i = 0; $i -lt $Lines.Count; $i++) {
    $Text += "  - {0}`r" -f $Lines[$i]
}
Write-Output $Text > cloudflare.txt
Copy-Item -Force cloudflare.txt ./ruleset/cfcidr.txt