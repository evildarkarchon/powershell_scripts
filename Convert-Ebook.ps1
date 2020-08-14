[CmdletBinding()]
param (
    [Alias("o","Out")]
    [string]$outname,
    [string]$format = "kfx",
    [Parameter(Position=0, Mandatory=$true, ValueFromRemainingArguments=$true)]
    [string[]]$paths
)

$files = Get-ChildItem $paths -ErrorAction Stop
if (-not [string]::IsNullOrEmpty($outname) -and $outname -eq "..") {
    $outname = (get-item (get-location)).Parent.FullName
}

foreach ($file in $files) {
    if (-not [string]::IsNullOrEmpty($outname)) {
        if ((Test-Path $outname -PathType Container)) {
            ebook-convert $file.Name "$($outname)\$($file.BaseName).$($format)"
        }
        else {
            ebook-convert $file.Name $outname
        }
    }
    else {
        ebook-convert $file.Name "$($file.BaseName).$($format)"
    }
}