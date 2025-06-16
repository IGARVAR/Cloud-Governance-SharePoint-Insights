<#
.SYNOPSIS
Generates a report on external and anonymous sharing settings across all SharePoint Online sites.

.DESCRIPTION
This script audits sharing configurations across all SharePoint sites in a Microsoft 365 tenant.
It identifies which sites allow external sharing, anonymous links, and includes site sensitivity labels if available.

.NOTES
Author: Ivan Garkusha  
Filename: SP_REPORT_Sites_SharingStatus.ps1  
Date: 2025-06-16  

.REQUIREMENTS
- PnP.PowerShell module
- SharePoint Online Admin permissions

.EXAMPLE
.\SP_REPORT_Sites_SharingStatus.ps1

CSV Columns:


# Connect to SharePoint Admin Center
Connect-PnPOnline -Url "https://yourtenant-admin.sharepoint.com" -Interactive

# Get all sites
$sites = Get-PnPTenantSite -IncludeOneDriveSites $false

$report = foreach ($site in $sites) {
    [PSCustomObject]@{
        SiteUrl             = $site.Url
        Template            = $site.Template
        Title               = $site.Title
        Owner               = $site.Owner
        SharingCapability   = $site.SharingCapability
        ExternalSharing     = switch ($site.SharingCapability) {
            0 { "Disabled" }
            1 { "External users only" }
            2 { "External and anonymous" }
            3 { "Anyone (most permissive)" }
            default { "Unknown" }
        }
        SensitivityLabel    = $site.SensitivityLabel
        LastContentModified = $site.LastContentModifiedDate
    }
}

# Export to CSV
$timestamp = Get-Date -Format "yyyyMMdd_HHmm"
$exportPath = "$env:USERPROFILE\Documents\SP_Site_Sharing_Status_$timestamp.csv"
$report | Export-Csv -Path $exportPath -NoTypeInformation -Encoding UTF8

Write-Host "`nReport saved to: $exportPath" -ForegroundColor Green 
