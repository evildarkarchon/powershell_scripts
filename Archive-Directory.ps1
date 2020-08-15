using namespace System.Text
[CmdletBinding()]
param (
    [Parameter(Position=0, Mandatory=$true)]
    [string]$DatabaseLocation,
    [Parameter(Position=1, Mandatory=$true)]
    [string]$Directory
)
foreach ($i in get-childitem $Directory) {
    $tablenameSB = [StringBuilder]::new()
    [void]$tablenameSB.Append($i.Name)
    [void]$tablenameSB.Replace(".", "_").Replace(" ", "_").Replace("'", "_").Replace(",", "").Replace("/", "_").Replace("\", "_").Replace("-", "_").Replace("#", "").Replace("&", "and")
    $tablename = $tablenameSB.ToString().ToLower()
    #write-host $i.FullName
    sqlite_archive $DatabaseLocation add -t $tablename $i.FullName 
}