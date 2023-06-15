<#
.SYNOPSIS
Run a generated executable.
.DESCRIPTION
Runs a generated executable if it exists.
A project built as a library usually doesn't
have one.
.PARAMETER Configuration
.OUTPUTS
string
Output of the executable. No output if the
executable doesn't have it.
#>
function Invoke-CppProjectExe {
  [OutputType([string])]
  param(
    [ProjectConfig] $Configuration
  )

  #region Library
  #——————————————

    <#
    .DESCRIPTION
    Returns a path if an executable for a
    Configuration exists. Otherwise, there is
    no output.
    #>
    function GetExePath {
      [OutputType([string])]
      param(
        [ProjectConfig] $Configuration
      )

      $name = Split-Path (Get-Location) -Leaf
      $path = "x64\$Configuration\link\$name.exe"

      if (Test-Path $path) {
        $path
      }
    }

  #—————————
  #endregion

  if ($null -eq $Configuration) {
    foreach ($Configuration in 'Debug', 'Release') {
      $path = GetExePath $Configuration

      if ($path) {
        break
      }
    }
  } else {
    $path = GetExePath $Configuration
  }

  if ($path) {
    & $path
  } else {
    Write-Error "No executable has been found. You may need to build your project first."
  }
}