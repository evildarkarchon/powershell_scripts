[CmdletBinding()]
param (
    [Alias("o","Out")]
    [string]$outname,
    [string]$format = "kfx",
    [Parameter(Position=0, Mandatory=$true, ValueFromRemainingArguments=$true)]
    [string[]]$paths
)

$files = Get-ChildItem $paths

if ($files.Length -gt 1) {
    foreach ($file in $files) {
        if (-not [string]::IsNullOrEmpty($outname) -and (Test-Path $outname -PathType Container)) {
            ebook-convert "$($file.Name)" "$($outname)\$($file.BaseName).$($format)"
        }
        elseif (-not (Test-Path $outname -PathType Any) -and -not [string]::IsNullOrEmpty($outname)) {
            ebook-convert "$($file.Name)" "$($outname)"
        }
        else {
            ebook-convert "$($file.Name)" "$($file.BaseName).$($format)"
        }
    }
}
else {
    throw "Please Specify At Least 1 file"
}