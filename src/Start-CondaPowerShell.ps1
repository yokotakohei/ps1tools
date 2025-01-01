<#
.SYNOPSIS
    Activates a Conda environment and opens an Anaconda PowerShell session.

.DESCRIPTION
    This script activates a specified Conda environment and starts an Anaconda PowerShell session.
    If no environment name is provided, the "base" environment is activated.

.PARAMETER EnvName
    The name of the Conda environment to activate. Default is "base".

.PARAMETER CondaRoot
    The root directory of the Conda installation. Default is "$Env:USERPROFILE\miniconda3".

.EXAMPLE
    PS> .\Start-CondaPowerShell.ps1 -EnvName "myenv"
    Activates the "myenv" Conda environment and starts an Anaconda PowerShell session.
#>

param (
    # The name of the Conda environment to activate (default: "base").
    [string]$EnvName = "base",

    # The root directory of the Conda installation (default: "$Env:USERPROFILE\miniconda3").
    [string]$CondaRoot = "$Env:USERPROFILE\miniconda3"
)

# Validate that the Conda root directory exists.
if (-Not (Test-Path $CondaRoot)) {
    Write-Output "Error: Conda root directory not found at '$CondaRoot'."
    return
}

# Validate the environment name to avoid code injection.
if ($EnvName -notmatch "^[\w\.-]+$") {
    Write-Output "Error: Invalid environment name '$EnvName'. Only alphanumeric characters, '.', and '-' are allowed."
    return
}

# Function to get the list of available Conda environments.
function Get-CondaEnvList {
    param (
        # Full path to the Conda executable.
        [string]$CondaExecutable
    )

    # Validate that the Conda executable exists.
    if (-Not (Test-Path $CondaExecutable)) {
        Write-Output "Error: Conda executable not found at '$CondaExecutable'."
        return @()
    }

    # Retrieve the list of Conda environments.
    $envList = & $CondaExecutable info -e | ForEach-Object {
        ($_ -split '\s+')[0]
    } | Where-Object { $_ -ne "" -and $_ -notmatch "^(#|\s*$)" }

    return $envList
}

# Define the full path to the Conda executable.
$CondaExecutable = Join-Path -Path $CondaRoot -ChildPath "condabin\conda.bat"

# Get the list of Conda environments.
$EnvList = Get-CondaEnvList -CondaExecutable $CondaExecutable

# Check if the specified environment exists.
if ($EnvList -notcontains $EnvName) {
    Write-Output "Error: Environment '$EnvName' does not exist."
    Write-Output "Available environments:"
    Write-Output $EnvList
    return
}

# Define the activation command.
$ActivationCommand = "& conda activate $EnvName"

# Define the command to start the Anaconda PowerShell session.
$CondaHookPath = Join-Path -Path $CondaRoot -ChildPath "shell\condabin\conda-hook.ps1"
if (-Not (Test-Path $CondaHookPath)) {
    Write-Output "Error: Conda hook script not found at '$CondaHookPath'."
    return
}

# Start the Anaconda PowerShell session.
$CondaStartCommand = "& '$CondaHookPath'; $ActivationCommand"
powershell.exe -ExecutionPolicy ByPass -NoExit -Command $CondaStartCommand
