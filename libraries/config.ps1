<#
.SYNOPSIS
Set the AvocadoCMaker configuration.
.DESCRIPTION
AvocadoCMaker configuration has the
following properties:
-ProjectsPath
EFFECT
TODO
-Documentation
-Test
.PARAMETER Value
.OUTPUTS
No output.
#>
function Set-CMakerConfig {
  [OutputType([void])]
  param (
    [Object] $Value
  )

  Set-Config $ToolPath $Value
}

<#
.SYNOPSIS
Get the AvocadoCMaker configuration.
.DESCRIPTION
EFFECT
TODO
-Documentation
-Test
.OUTPUTS
hashtable
#>
function Get-CMakerConfig {
  [OutputType([hashtable])]
  param()

  Get-Config $ToolPath
}

<#
.SYNOPSIS
.DESCRIPTION
EFFECT
TODO
-Documentation
-Test
.PARAMETER
.OUTPUTS
#>
function Get-CMakerProperty {
  [OutputType([Object])]
  param (
    [string]      $Property,
    [scriptblock] $NewValue
  )

  Get-ConfigProperty $ToolPath $Property $NewValue
}

Export-ModuleMember @(
  'Set-CMakerConfig'
  'Get-CMakerConfig'
  'Get-CMakerProperty'
)