<#
.SYNOPSIS
Reports and optionally removes old, unloaded Windows user profiles.
#>
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
param(
    [ValidateRange(30,3650)][int]$OlderThanDays=90,
    [switch]$Remove,
    [string[]]$ExcludeUser=@(),
    [string]$LogRoot="$env:ProgramData\WindowsStaleProfileCleanup\Logs"
)

Set-StrictMode -Version 2.0
$ErrorActionPreference='Stop'
$runPath=Join-Path $LogRoot (Get-Date -Format 'yyyyMMdd_HHmmss')
$cutoff=(Get-Date).AddDays(-$OlderThanDays)
$removed=New-Object System.Collections.Generic.List[object]
$failed=New-Object System.Collections.Generic.List[object]

function Test-Admin{
    $id=[Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal($id)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

try{
    if($env:OS -ne 'Windows_NT'){throw 'Windows is required.'}
    if($Remove -and -not(Test-Admin)){throw 'Run PowerShell as Administrator for removal.'}
    New-Item $runPath -ItemType Directory -Force|Out-Null

    $currentPath=[Environment]::GetFolderPath('UserProfile')
    $profiles=Get-CimInstance Win32_UserProfile|Where-Object{
        -not $_.Special -and
        -not $_.Loaded -and
        $_.LocalPath -ne $currentPath -and
        $_.LastUseTime -and
        $_.LastUseTime -lt $cutoff
    }

    $candidates=$profiles|Where-Object{
        $leaf=Split-Path $_.LocalPath -Leaf
        $leaf -notin $ExcludeUser -and $leaf -notin @('Public','Default','Default User','All Users')
    }

    $candidates|Select-Object SID,LocalPath,Loaded,Special,LastUseTime,Status|
        Export-Csv (Join-Path $runPath 'StaleProfileCandidates.csv') -NoTypeInformation

    if($Remove){
        foreach($profile in $candidates){
            if($PSCmdlet.ShouldProcess($profile.LocalPath,'Remove stale Windows profile')){
                try{
                    $snapshot=[pscustomobject]@{SID=$profile.SID;LocalPath=$profile.LocalPath;LastUseTime=$profile.LastUseTime;RemovedAt=Get-Date}
                    Remove-CimInstance -InputObject $profile -ErrorAction Stop
                    $removed.Add($snapshot)
                }catch{
                    $failed.Add([pscustomobject]@{SID=$profile.SID;LocalPath=$profile.LocalPath;Error=$_.Exception.Message})
                }
            }
        }
    }

    $removed|Export-Csv (Join-Path $runPath 'RemovedProfiles.csv') -NoTypeInformation
    $failed|Export-Csv (Join-Path $runPath 'FailedProfiles.csv') -NoTypeInformation
    Write-Host "[OK] Candidates=$(@($candidates).Count) Removed=$($removed.Count) Logs=$runPath" -ForegroundColor Green
    if($failed.Count -gt 0){exit 2}else{exit 0}
}catch{Write-Error $_.Exception.Message;exit 1}
