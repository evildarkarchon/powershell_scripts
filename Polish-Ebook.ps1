[CmdletBinding()]
param (
    [Alias("o","OutName","Out")]
    [string]$outname,
    [Parameter(Position=0, Mandatory=$true, ValueFromRemainingArguments=$true)]
    [string[]]$paths
)

$files = Get-ChildItem $paths
if ($files.Length -gt 1) {
    foreach ($file in $files) {
        if (-not [string]::IsNullOrEmpty($outname)) {
            ebook-polish -Hup "$($file.Name)" "$($outname)"
        }
        else {
            ebook-polish -Hup "$($file.Name)"
        }
    }
}
else {
    if (-not [string]::IsNullOrEmpty($outname)) {
        ebook-polish -Hup "$($file.Name)" "$($outname)"
    }
    else {
        ebook-polish -Hup "$($file.Name)"
    }
}