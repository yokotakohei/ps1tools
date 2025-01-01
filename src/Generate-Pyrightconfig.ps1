<#
.SYNOPSIS
    Creates a pyrightconfig.json file.

.DESCRIPTION
    This script creates a pyrightconfig.json file in the current directory.

.PARAMETER venvPath
    The path to the root directory of the virtual environment. The default is "./".

.PARAMETER venv
    The name of the virtual environment. The default is "venv".

.EXAMPLE
    PS> .\Make-Pyrightconfig.ps1
    Creates pyrightconfig.json in the current directory.

.EXAMPLE
    PS> .\Make-Pyrightconfig.ps1 -venvPath "C:\MyProject" -venv "myenv"
    Creates pyrightconfig.json in the current directory, with "venvPath" set to "C:\MyProject" 
    and "venv" set to "myenv".
#>

param (
    [string]$venvPath = "./",
    [string]$venv = "venv"
)

# Define the JSON contents.
$configJson = @{
    "executionEnvironments" = @(
        @{
            "root" = "./"
            "extraPaths" = @("./")
        }
    )
    "venvPath" = $venvPath
    "venv" = $venv
}

$jsonDepth = 4
$fileName = "pyrightconfig.json"

# Creates the file.
try {
    $configJson | ConvertTo-Json -Depth $jsonDepth | Set-Content -Path $fileName
    Write-Output "Successfully created $fileName in the current directory."
} catch {
    Write-Error "Failed to create $fileName : $_"
}
