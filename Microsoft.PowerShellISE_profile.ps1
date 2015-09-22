
$vcserver=""#vcenter server name. "[vcenterserver]"
Import-Module Pester
if ([System.Windows.Input.Keyboard]::IsKeyDown('Ctrl') -eq $false)
{
  Start-Steroids
}


#Exchange 
function get-mbdatabasepreference {
#Set-PSDebug -Step
get-mailboxdatabase |Sort Name |foreach {
$db=$_.Name
$xnow=$_.Server.Name
$xpref=$_.activationpreference |Where {$_.value -eq 1}
write-host $db "is now on" $xnow -NoNewline
if ($xnow -ne $xpref.key) {write-host "Wrong" -ForegroundColor Red}
Else {write-host " Ok" -ForegroundColor Green}
}
}
#requires -Version 2 
 
$script:last_memory_usage_byte = 0 
 
function Get-MemoryUsage 
{
$memusagebyte = [System.GC]::GetTotalMemory('forcefullcollection')
$memusageMB = $memusagebyte / 1MB 
$diffbytes = $memusagebyte - $script:last_memory_usage_byte 
$difftext = '' 
$sign = '' 
if ( $script:last_memory_usage_byte -ne 0 )
{
if ( $diffbytes -ge 0 )
{
$sign = '+' 
}
$difftext = ", $sign$diffbytes" 
}
Write-Host -Object ('Memory usage: {0:n1} MB ({1:n0} Bytes{2})' -f $memusageMB, $memusagebyte, $difftext)
 
# save last value in script global variable 
$script:last_memory_usage_byte = $memusagebyte 
}

if ([System.Windows.Input.Keyboard]::IsKeyDown('Alt') -eq $false)
{
(. 'C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1')

 # Add-PsSnapin VMware.VimAutomation.Core -ea "SilentlyContinue"
 Connect-VIServer $vcserver
}

# Load posh-git example profile
. 'C:\Program Files\WindowsPowerShell\Modules\posh-git\0.5.0.2015\profile.example.ps1'

Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

# Load posh-git module from current directory
Import-Module .\posh-git

# If module is installed in a default location ($env:PSModulePath),
# use this instead (see about_Modules for more information):
# Import-Module posh-git


# Set up a simple prompt, adding the git prompt parts inside git repos
function global:prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    Write-Host($pwd.ProviderPath) -nonewline

    Write-VcsStatus

    $global:LASTEXITCODE = $realLASTEXITCODE
    return "> "
}

Pop-Location

#Start-SshAgent -Quiet

Function global:ADD-PATH()
{
[Cmdletbinding()]
param
( 
[parameter(Mandatory=$True,
ValueFromPipeline=$True,
Position=0)]
[String[]]$AddedFolder
)

# Get the current search path from the environment keys in the registry.

$OldPath=(Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path

# See if a new folder has been supplied.

IF (!$AddedFolder)
{ Return ‘No Folder Supplied. $ENV:PATH Unchanged’}

# See if the new folder exists on the file system.

IF (!(TEST-PATH $AddedFolder))
{ Return ‘Folder Does not Exist, Cannot be added to $ENV:PATH’ }

# See if the new Folder is already in the path.

IF ($ENV:PATH | Select-String -SimpleMatch $AddedFolder)
{ Return ‘Folder already within $ENV:PATH' }

# Set the New Path

$NewPath=$OldPath+’;’+$AddedFolder

Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH –Value $newPath

# Show our results back to the world

Return $NewPath
}

Write-host "Profile Script"
