[CmdletBinding()]
param (
    [Alias("o", "Out")]
    [string]$outname,
    [string]$format = "kfx",
    [switch]$remove,
    [Parameter(Position = 0, Mandatory = $true, ValueFromRemainingArguments = $true)]
    [string[]]$paths
)

$files = Get-ChildItem $paths -ErrorAction Stop
if (-not [string]::IsNullOrEmpty($outname) -and (Test-Path $outname -PathType Container)) {
    $outname = (Resolve-Path $outname)
}

foreach ($file in $files) {
    if (-not [string]::IsNullOrEmpty($outname)) {
        if ((Test-Path $outname -PathType Container)) {
            ebook-convert $file.FullName (Join-Path $outname "$($file.BaseName).$($format)") # "$($outname)\$($file.BaseName).$($format)" 
            if ($remove -and $?) { Remove-Item -Verbose $file.FullName }
        }
        else {
            ebook-convert $file.FullName $outname
            if ($remove -and $?) { Remove-Item -Verbose $file.FullName }
        }
    }
    else {
        ebook-convert $file.FullName (Join-Path $file.Directory.FullName "$($file.BaseName).$($format)")
        if ($remove -and $?) { Remove-Item -verbose $file.FullName }
    }
}