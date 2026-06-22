# Windows Stale Profile Cleanup

> **Testing note:** This was tested by me to be working. User experience may vary.

Included: `Remove-StaleWindowsProfiles.ps1`

```powershell
.\Remove-StaleWindowsProfiles.ps1
.\Remove-StaleWindowsProfiles.ps1 -OlderThanDays 180 -Remove
```

The default mode creates a candidate report. The removal option requires administrator rights, explicit confirmation and supports `-WhatIf`.

Logs: `C:\ProgramData\WindowsStaleProfileCleanup\Logs`

Exit codes: `0` success, `1` fatal error, `2` failed items.

Review the candidate report and maintain backups before use. MIT License.
