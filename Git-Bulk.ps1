<#
.SYNOPSIS
    This script runs defined command in a defined parent directory of multiple git repositories recursively.
.DESCRIPTION
    The user can either apply selected git command in present working directory, or can provide a custom path for running git command.
.PARAMETER -tragetpath 
	The path of selected parent directory, otherwise it is the current working directory
.PARAMETER -command 
	Sepcifies the git command the user is about to run for each target repository. 
#>

param
(
	[String]$targetpath=$pwd,
	[String]$command="",
	[Bool]$verbose=$false,
	[Bool]$forcedexecution=$false
)

	[String]$gitfolder="\.git"

# Get all directories and hidden directories recursively within the given directory
Get-ChildItem -Recurse -Attributes Directory,Directory+Hidden -Path $targetpath | % {
	[String]$fullFolderName = $_.FullName
	[String]$fullGitFolderPath = "$fullFolderName$gitfolder"
	
	# If the current folder contains the .git folder, then it is a git repository
	if (Test-Path($fullGitFolderPath))
	{
		# If we are in a git repository, and we've got a command available we should run the given command
		if ($command -ne "")
		{
			#Save current path
			Push-Location $targetpath

			#Change location to the git repositories folder
			Set-Location -Path $fullFolderName

			#If forced execution has been set, run command
			if($forcedexecution -eq $true)
			{
				#If verbose mode have been set, log info
				if($verbose -eq $true)
				{
					Write-Host("Running command ({0}) in {1}" -f $command, $fullFolderName) -ForegroundColor Cyan
				}
				Invoke-Expression($command)
			}
			#If forced execution hasn't been set, ask user if he/she wants to run the command for the current repository
			else
			{
				[String]$runCommand = Read-Host -Prompt "Would you like to run $command command for on $fullFolderName repository? (Yes (y), No (n), Cancel (c))"
			}
			
			#Get back to the original location
			Pop-Location
		}
		else 
		{
			Write-Host("No command provided to run in {0}" -f $fullFolderName) -ForegroundColor Magenta 
		}
	}
}