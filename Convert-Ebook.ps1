[CmdletBinding()]
param (
    [Alias("o","Out")]
    [string]$outname,
    [string]$format = "kfx",
    [Parameter(Position=0, Mandatory=$true, ValueFromRemainingArguments=$true)]
    [string[]]$paths
)

$files = Get-ChildItem $paths -ErrorAction Stop


foreach ($file in $files) {
    if (-not [string]::IsNullOrEmpty($outname) -and (Test-Path $outname -PathType Container)) {
        ebook-convert "$($file.Name)" "$($outname)\$($file.BaseName).$($format)"
    }
    elseif (-not [string]::IsNullOrEmpty($outname) -and -not (Test-Path $outname -PathType Any)) {
        ebook-convert "$($file.Name)" "$($outname)"
    }
    else {
        ebook-convert "$($file.Name)" "$($file.BaseName).$($format)"
    }
}