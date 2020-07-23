[CmdletBinding()]
param (
    [Alias("out","OutName","Out")]
    [string]$outname,
    [string]$format = "kfx",
    [Parameter(Position=0, Mandatory=$true, ValueFromRemainingArguments=$true)]
    [string[]]$paths
)

$files = Get-ChildItem $paths
if ($files.Length -gt 1) {
    foreach ($file in $files) {
        if (-not [string]::IsNullOrEmpty($outname)) {
            ebook-convert "$($file.Name)" "$($outname)"
        }
        else {
            ebook-convert "$($file.Name)" "$($file.BaseName).$($format)"
        }
    }
}
else {
    if (-not [string]::IsNullOrEmpty($outname)) {
        ebook-convert "$($file.Name)" "$($outname)"
    }
    else {
        ebook-convert "$($file.Name)" "$($file.BaseName).$($format)"
    }
}