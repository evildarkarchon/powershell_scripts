[CmdletBinding()]
param (
    [Alias("o","Out")]
    [string]$outname,
    [string]$format = "azw3",
    [switch]$remove,
    [Parameter(Position=0, Mandatory=$true, ValueFromRemainingArguments=$true)]
    [string[]]$paths
)

$files = Get-ChildItem $paths -ErrorAction Stop
if (-not [string]::IsNullOrEmpty($outname) -and (Test-Path $outname -PathType Container)) {
    $outname = (Resolve-Path $outname)
}

foreach ($file in $files) {
    if (-not [string]::IsNullOrEmpty($outname)) {
        if ((Test-Path $outname -PathType Container)) {
            ebook-convert $file.Name (Join-Path $outname "$($file.BaseName).$($format)") # "$($outname)\$($file.BaseName).$($format)" 
            if ($remove -and $?) { Remove-Item -Verbose $file.Name }
        }
        else {
            ebook-convert $file.Name $outname
            if ($remove -and $?) { Remove-Item -Verbose $file.Name }
        }
    }
    else {
        ebook-convert $file.Name "$($file.BaseName).$($format)"
        if ($remove -and $?) { Remove-Item -verbose $file.Name }
    }
}