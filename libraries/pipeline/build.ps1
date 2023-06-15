$VsDevShellLaunched = $false
$launchVsDevShell = "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\Launch-VsDevShell.ps1"

<#
.SYNOPSIS
Build a C++ project.
.DESCRIPTION
Builds a C++ project previosly created by
New-CppProject, with given project Type and
Configuration.
EFFECTS
If it doesn't already exist, creates output
directories and files with 'x64' as a parent
directory directly located in the project's
root.
.PARAMETER Configuration
.PARAMETER Type
.PARAMETER Name
Name for the output file. By default
the name of the current working directory
is used.
.OUTPUTS
Output of CL command, and LIB command if
the project type is Library.
#>
function Build-CppProject {
  [OutputType([Object[]])]
  param (
    [ProjectConfig] $Configuration = 'Debug',
    [ProjectType]   $Type = 'App',
    [string]        $Name
  )

  #region Library
  #——————————————

    function NewOutputDir {
      [OutputType([void])]
      param(
        [ProjectConfig] $Configuration
      )

      $capitalizedConfig = (Get-Culture).TextInfo.ToTitleCase($Configuration)

      New-Item -ItemType Directory "x64\$capitalizedConfig\cl"   -Force | Out-Null
      New-Item -ItemType Directory "x64\$capitalizedConfig\link" -Force | Out-Null
    }

    function GetOption {
      param (
        [Parameter(ValueFromRemainingArguments)]
        [string[]] $Group
      )

      $options = &{
        foreach ($g in $Group) {
          switch ($g) {
All { @"
/permissive- /GS /W3 /I. /sdl /Zc:inline /fp:precise /Fdx64\$Configuration\cl\
/D_WINDOWS /D_UNICODE /DUNICODE /Gd /std:c++20 /FC /EHsc /nologo /Fox64\$Configuration\cl\
/Fpx64\$Configuration\cl\ /diagnostics:column src\*.cpp
"@
}
Debug {
"/JMC /ZI /Od /D_DEBUG /RTC1 /MDd"
}
Release {
"/GL /Gy /Zi /O2 /DNDEBUG /Oi /MD"
}
App { @"
/link /OUT:x64\$Configuration\link\$Name.exe /MANIFEST /NXCOMPAT /DYNAMICBASE user32.lib
/DEBUG /MACHINE:X64 /SUBSYSTEM:CONSOLE /MANIFESTUAC:""level='asInvoker' uiAccess='false'""
"@
}
LibraryCL {
"/c"
}
LibraryLIB {
"/MACHINE:X64 x64\$Configuration\cl\*.obj /OUT:x64\$Configuration\link\$Name.lib"
}
LibraryReleaseLIB {
"/LTCG"
}
Default {
throw "Unknown option group"
}
          }
        }
      }

      SplitOption $options
    }

    function SplitOption {
      [OutputType([string[]])]
      param (
        [string] $Value
      )

      $Value -split '(?<!MANIFESTUAC[^ ]*) |[\r\n]+'
    }

  #—————————
  #endregion

  if (-not $Name) {
    $Name = (Get-Location).Path | Split-Path -Leaf
  }

  if (-not $VsDevShellLaunched) {
    & $launchVsDevShell -SkipAutomaticLocation -Arch amd64
    $script:VsDevShellLaunched = $true
  }

  NewOutputDir $Configuration

  switch ($Configuration) {
    Debug {
      switch ($Type) {
        App {
          CL  (GetOption All Debug App)
        }
        Library {
          CL  (GetOption All Debug LibraryCL)
          LIB (GetOption LibraryLIB)
        }
      }
    }
    Release {
      switch ($Type) {
        App {
          CL  (GetOption All Release App)
        }
        Library {
          CL  (GetOption All Release LibraryCL)
          LIB (GetOption LibraryLIB LibraryReleaseLIB)
        }
      }
    }
  }
}