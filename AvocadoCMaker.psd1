@{
  RootModule        = 'AvocadoCMaker.psm1'
  ModuleVersion     = '0.0.1'
  GUID              = '988defbe-5d1a-4e01-9fab-977db558f70c'
  Author            = 'Oleksa Plotnyckyj'
  Copyright         = '(c) 2023 Oleksa Plotnyckyj. All rights reserved.'
  Description       = 'Manage your C++ app development.'
  ScriptsToProcess  = @('libraries\class.ps1')
  FunctionsToExport = '*'
  CmdletsToExport   = @()
  VariablesToExport = '*'
  AliasesToExport   = @()
}