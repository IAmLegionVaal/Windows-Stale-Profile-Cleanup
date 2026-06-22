# Windows Stale Profile Cleanup

> **Testing note:** This was tested by me to be working. User experience may vary.

## One-click use

1. Download and extract the repository.
2. Double-click `Run-OneClick.bat`.
3. Approve the Windows administrator prompt.
4. Review every profile shown by the confirmation prompt before accepting an action.
5. Review the exit code and logs in `C:\ProgramData\WindowsStaleProfileCleanup\Logs`.

The launcher runs the guarded cleanup workflow directly. There is no menu.

Included: `Remove-StaleWindowsProfiles.ps1`

## PowerShell usage

```powershell
.\Remove-StaleWindowsProfiles.ps1
.\Remove-StaleWindowsProfiles.ps1 -OlderThanDays 180 -Remove
.\Remove-StaleWindowsProfiles.ps1 -OlderThanDays 180 -Remove -WhatIf
```

The default mode creates a candidate report. Action mode requires administrator rights and PowerShell confirmation. Loaded, current, special and standard system profiles are excluded.

Exit codes: `0` success, `1` fatal error, `2` failed items.

Review the candidate report and maintain backups before use. MIT License.
