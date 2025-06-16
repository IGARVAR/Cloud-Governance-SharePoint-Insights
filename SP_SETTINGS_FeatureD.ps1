<#
.SYNOPSIS
Audits the enabled/disabled status of specific modern SharePoint Online tenant settings.

.DESCRIPTION
This script connects to SharePoint Online Admin Center and retrieves the status of selected tenant-level features.  
These features are typically tied to modern collaboration, sharing behavior, and security preferences.

Used for governance baseline reviews or environment readiness assessments (e.g., Copilot, external sharing, modern experiences).

.REQUIREMENTS
- PnP.PowerShell module
- SharePoint Admin privileges

.AUTHOR
Ivan Garkusha
#>

# Connect to SharePoint Online Admin Center
Connect-PnPOnline -Url "https://<your-tenant>-admin.sharepoint.com" -Interactive

# Retrieve tenant settings
$tenantSettings = Get-PnPTenant

# Output key features for review
$report = [PSCustomObject]@{
    SharingCapability            = $tenantSettings.SharingCapability
    AllowSelfServiceSiteCreation = $tenantSettings.AllowSelfServiceSiteCreation
    AllowGuestUserSignIn         = $tenantSettings.AllowGuestUserSignIn
    CommentsOnSitePagesDisabled  = $tenantSettings.CommentsOnSitePagesDisabled
    EnableAIPIntegration         = $tenantSettings.EnableAIPIntegration
    EnableSensitivityLabels      = $tenantSettings.EnableSensitivityLabelsForSites
    IsCopilotEnabled             = $tenantSettings.IsCopilotEnabled
    RequireAcceptingAccountMatch = $tenantSettings.RequireAcceptingAccountMatch
}

# Display and export
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$report | Tee-Object -Variable output | Export-Csv -Path "SP_Feature_Settings_Audit_$timestamp.csv" -NoTypeInformation -Encoding UTF8

Write-Host "`nExported: SP_Feature_Settings_Audit_$timestamp.csv"
$output
