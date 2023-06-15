Import-Module AvocadoUtils -Force -DisableNameChecking
Import-Module AvocadoCMaker

$PSModuleAutoLoadingPreference = 'none'
$WarningPreference = 'Continue'
$defaultErrorAction = 'Stop'
$ErrorActionPreference = $defaultErrorAction

Set-MockReadLog $true

try {
  #region Data
  #———————————

    $toolPath         = (Resolve-Path "$PSScriptRoot\..").Path
    $projectsPath     = "C:\Users\Public\C++ Projects"
    $projectName      = "AvocadoCppProject"
    $projectPath      = Join-Path $projectsPath $projectName
    $projectOutputDir = "$projectPath\x64"

    Assert { (Split-Path $toolPath -Leaf) -eq "AvocadoCMaker" }

  #—————————
  #endregion
  #region Library
  #——————————————

    <#
    .SYNOPSIS
    Clean up the state.
    .DESCRIPTION
    -Reimport AvocadoCMaker
    -Make the Location current, toolPath by default
    -Remove the project at the projectPath if exists
    -Clear the tool config
    #>
    function CleanUp {
      [OutputType([void])]
      param (
        [string] $Location = $toolPath
      )

      Import-Module AvocadoCMaker -Force
      Set-Location $Location
      if (Test-Path $projectPath) {
        Remove-Item $projectPath -Recurse
      }

      ExpectCleanState $Location
    }

    <#
    .SYNOPSIS
    Expect the clean state.
    .DESCRIPTION
    -Location is current, toolPath by default
    -No project at projectPath
    -The tool config is empty
    #>
    function ExpectCleanState {
      [OutputType([void])]
      param (
        [string] $Location = $toolPath
      )

      $toolConfig = Get-CMakerConfig
      $mockedRead = Pull-MockRead

      Expect-Location $Location
      Expect-NoItem   $projectPath
      Expect-Empty    $toolConfig
      Expect-Null     $mockedRead
    }

    <#
    .SYNOPSIS
    Expect the state for all pipeline stages.
    #>
    function ExpectResultingState {
      [OutputType([void])]
      param()

      Expect-Item     $projectPath
      Expect-Location $projectPath
    }

    <#
    .SYNOPSIS
    Format the resulting state for all pipeline stages.
    #>
    function FormatResultingState {
      [OutputType([Object[]])]
      param (
        [Object] $Output
      )

      Format-TestLabeled "Output"             $Output
      Format-TestLabeled "Prompt"             (Pull-MockRead)
      Format-TestLabeled "Projects directory" (Format-ChildItem (Get-ChildItem $projectsPath))
      Format-TestLabeled "Project"            (Format-ChildItem (Get-ChildItem $projectPath -Recurse))

      foreach ($item in (Get-ChildItem "$projectPath\src" -File -Recurse)) {
        Format-TestLabeled $item.Name (Get-Content $item)
      }
    }

    <#
    .SYNOPSIS
    Set up the initial state for New-CppProject call.
    .DESCRIPTION
    Same as the clean state but the current directory is
    the projects directory.
    #>
    function SetUpN {
      [OutputType([void])]
      param()

      CleanUp $projectsPath
    }

    <#
    .SYNOPSIS
    Expect and format the state.
    #>
    function TestResultingStateN {
      [OutputType([Object[]])]
      param (
        [Object] $Output
      )

      ExpectResultingState
      Expect-Null $Output

      FormatResultingState $Output
    }

  #—————————
  #endregion

  switch (0..3) {
  0 {
  New-Test -Group "New-CppProject" -First {
    #region Library
    #——————————————

      function NewTest {
        [OutputType([Object[]])]
        param (
          [string]      $Argument,
          [scriptblock] $Script,
          [string]      $Result,
          [switch]      $First
        )

        New-Test                `
            -Action  $Argument  `
            -Context "Projects directory and clean config" `
            -Result  $Result    `
            -First:  $First {
          #region Test
          #———————————

            SetUpN

          #—————————
          #endregion
          #region Code
          #———————————

            $o = &$Script

          #—————————
          #endregion
          #region Test
          #———————————

            TestResultingStateN $o

          #—————————
          #endregion
          #region CleanUp
          #——————————————

            CleanUp

          #—————————
          #endregion
        }
      }

    #—————————
    #endregion

    New-Test -Group "Path" -First {

      NewTest "Project name" -First {
        #region Code
        #———————————

          New-CppProject $projectName

        #—————————
        #endregion
      }

      NewTest "Project path" {
        #region Code
        #———————————

          New-CppProject $projectPath

        #—————————
        #endregion
      }

      NewTest "No arguments, prompted project name" {
        #region Code
        #———————————

          Push-Input $projectName

          New-CppProject

        #—————————
        #endregion
      }

      NewTest "No arguments, prompted project path" {
        #region Code
        #———————————

          Push-Input $projectPath

          New-CppProject

        #—————————
        #endregion
      }
    }

    New-Test -Group "Type" {

      NewTest "App" -R "Project providing starting code fit for an application" -First {
        #region Code
        #———————————

          New-CppProject $projectName App

        #—————————
        #endregion
      }

      NewTest "Library" -R "Project providing starting code fit for a library" {
        #region Code
        #———————————

          New-CppProject $projectName Library

        #—————————
        #endregion
      }
    }
  }
  } 1 {
  New-Test -Group "Build-CppProject" {
    #region Library
    #——————————————

      function TestInitialStateB {
        [OutputType([void])]
        param()

        Expect-NoItem $projectOutputDir
      }

      function TestResultingStateB {
        [OutputType([Object[]])]
        param (
          [Object] $Output
        )

        ExpectResultingState $Output

        Expect-NotNull $Output
        Expect-Item $projectOutputDir

        FormatResultingState $Output
      }

      function NewTest {
        param (
          [string]      $Action,
          [scriptblock] $Script,
          [switch]      $First
        )

        New-Test $Action -First:$First {
          #region SetUp
          #————————————

            SetUpN

            #region Code
            #———————————

              New-CppProject $projectName

            #—————————
            #endregion

            TestInitialStateB

          #—————————
          #endregion
          #region Code
          #———————————

            $o = &$Script

          #—————————
          #endregion
          #region Test
          #———————————

            TestResultingStateB $o

          #—————————
          #endregion
          #region CleanUp
          #——————————————

            CleanUp

          #—————————
          #endregion
        }
      }

    #—————————
    #endregion

    NewTest "Debug App" -First {
      #region Code
      #———————————

        Build-CppProject Debug App

      #—————————
      #endregion
    }

    NewTest "Release App" {
      #region Code
      #———————————

        Build-CppProject Release App

      #—————————
      #endregion
    }

    NewTest "Debug Library" {
      #region Code
      #———————————

        Build-CppProject Debug Library

      #—————————
      #endregion
    }

    NewTest "Release Library" {
      #region Code
      #———————————

        Build-CppProject Release Library

      #—————————
      #endregion
    }
  }
  } 2 {
  New-Test -Group "Invoke-CppProjectExe" {
    #region Library
    #——————————————

      function NewTest {
        param (
          [string]      $Action,
          [scriptblock] $Script,
          [string]      $Result,
          [string]      $ProjectType,
          [switch]      $First
        )

        New-Test $Action -Context "Project type is $ProjectType" -Result $Result -First:$First {
          #region SetUp
          #————————————

            SetUpN

            #region Code
            #———————————

              New-CppProject $projectName
              Build-CppProject $ProjectType App | Out-Null

            #—————————
            #endregion

          #—————————
          #endregion
          #region Code
          #———————————

            &$Script

          #—————————
          #endregion
          #region Test
          #———————————
          #—————————
          #endregion
          #region CleanUp
          #——————————————

            CleanUp

          #—————————
          #endregion
        }
      }

    #—————————
    #endregion

    NewTest "Debug" -ProjectType Debug -Result "Output of an executable" -First {
      #region Code
      #———————————

        Invoke-CppProjectExe Debug

      #—————————
      #endregion
    }

    NewTest "Release" -ProjectType Release -Result "Output of an executable" {
      #region Code
      #———————————

        Invoke-CppProjectExe Release

      #—————————
      #endregion
    }

    NewTest "No arguments" -ProjectType Debug -Result "Output of an executable" {
      #region Code
      #———————————

        Invoke-CppProjectExe

      #—————————
      #endregion
    }

    NewTest "No arguments" -ProjectType Release -Result "Output of an executable"  {
      #region Code
      #———————————

        Invoke-CppProjectExe

      #—————————
      #endregion
    }

    NewTest "Release" -ProjectType Debug -Result "Non-terminating error" {
      #region Test
      #———————————

        $global:ErrorActionPreference = 'SilentlyContinue'

        $Error.Clear()

      #—————————
      #endregion
      #region Code
      #———————————

        $o = Invoke-CppProjectExe Release

      #—————————
      #endregion
      #region Test
      #———————————

        Expect-Null $o

        Trim-EmptyLine ($Error | Out-String)

        $global:ErrorActionPreference = $defaultErrorAction

      #—————————
      #endregion
    }
  }
  } 3 {
  New-TestDocumentation -Detail Detailed @(
    'New-CppProject'
    'Build-CppProject'
    'Invoke-CppProjectExe'
  )
  }
  }
} catch {
  Format-Exception $_
}