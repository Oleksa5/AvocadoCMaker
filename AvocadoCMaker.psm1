Import-Module AvocadoUtils -DisableNameChecking

$ToolPath = $PSScriptRoot

Get-ChildItem "$ToolPath\libraries\*.ps1" -Recurse |
  ForEach-Object {
    if (($_.Name -notmatch "copy") -and
        ($_.Name -ne "class.ps1" )) {
      . $_
    }
  }

New-Alias create New-CppProject
New-Alias build  Build-CppProject
New-Alias run    Invoke-CppProjectExe

Export-ModuleMember @(
  'New-CppProject'
  'Build-CppProject'
  'Invoke-CppProjectExe'
)