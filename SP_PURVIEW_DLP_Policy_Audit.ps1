<#
.SYNOPSIS
Audits Microsoft Purview Data Loss Prevention (DLP) policies related to SharePoint Online and Teams.

.DESCRIPTION
Connects to Microsoft Purview and retrieves all DLP policies targeting SharePoint and Teams.  
Outputs detailed metadata including policy name, status, mode, target locations, and rule severity.

Used for compliance auditing, visibility of enforcement coverage, and reporting.

.REQUIREMENTS
- Microsoft Purview compliance PowerShell module (e.g., `ExchangeOnlineManagement`)
- Appropriate permissions to read DLP policies

.OUTPUT
CSV file with DLP policy metadata (timestamped)

.AUTHOR
Ivan Garkusha
#>

# Connect to Purview (via EXO PowerShell for compliance center)
Connect-IPPSSession

# Get DLP policies targeting SPO/Teams
$dls = Get-DlpCompliancePolicy | Where-Object { $_.ContentContainsSharePoint -or $_.ContentContainsTeams }

# Flatten policies into exportable format
$report = foreach ($dlp in $dls) {
    [PSCustomObject]@{
        PolicyName      = $dlp.Name
        Enabled         = $dlp.Enabled
        Mode            = $dlp.Mode
        LastModified    = $dlp.WhenChangedUTC
        TargetLocations = ($dlp.ContentContainsSharePoint, $dlp.ContentContainsTeams -join ", ")
        RulesCount      = ($dlp.Rules | Measure-Object).Count
    }
}

# Export results
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$report | Export-Csv -Path "DLP_Policies_Audit_$timestamp.csv" -NoTypeInformation -Encoding UTF8
Write-Host "Export complete: DLP_Policies_Audit_$timestamp.csv"
