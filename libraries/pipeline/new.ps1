$projectName = $null

<#
.SYNOPSIS
Create a new C++ project.
.DESCRIPTION
EFFECTS
EXCEPTIONS
.PARAMETER Path
Relative or full path. The path leaf is the project name.
.OUTPUTS
No output.
#>
function New-CppProject {
  [OutputType([void])]
  param (
    [string] $Path = $(Read-Host "Provide a project path"),
    [ProjectType] $Type = 'App'
  )

  #region Library
  #——————————————

$startingCode = $Type -eq 'App' ? @"
#include <iostream>

int main()
{
  std::cout << "Hello, World!";

  return 0;
}
"@ : @"
#include <iostream>

void PrintGreeting()
{
  std::cout << "Hello, World!";
}
"@

  #—————————
  #endregion

  $script:projectName = Split-Path $Path -Leaf

  New-Item -ItemType Directory  $Path       | Out-Null
  New-Item -ItemType Directory "$Path\src"  | Out-Null
  New-Item -ItemType Directory "$Path\test" | Out-Null
  New-Item -ItemType File "$Path\src\$projectName.cpp" -Value $startingCode | Out-Null

  Set-Location $Path
  Copy-Item "$ToolPath\vs-config\*"
}