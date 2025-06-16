<#
.SYNOPSIS
Audits and exports all sharing links in SharePoint Online and Microsoft Teams.

.DESCRIPTION
This script connects to Microsoft 365 and retrieves sharing link details across all modern SharePoint sites.
It classifies links by type (anonymous, organization, direct), shows expiration dates, and highlights potential risks.

.NOTES
Author: Ivan Garkusha
Filename: SP_REPORT_Sharing_Links_Report.ps1
Date: 2025-06-16

.REQUIREMENTS
- PnP PowerShell module
- SharePoint Online administrator privileges
- Connect-PnPOnline (App or delegated auth)

.EXAMPLE
.\SP_REPORT_Sharing_Links_Report.ps1

 CSV Columns:
SiteUrl – Full URL of the site
ListTitle – Name of the document library
ItemName – File or folder shared
LinkType – Anonymous, Direct, Internal
LinkScope – Scope of link (Organization, Anyone, etc.)
Expiration – Expiry date if set
Url – Full sharing URL
HasPassword – Whether the link is protected
IsEditLink – Whether the link allows editing
#>

# Connect to tenant (interactive or app-based as needed)
Connect-PnPOnline -Url "https://yourtenant-admin.sharepoint.com" -Interactive

# Get all modern sites (Group-connected, Team sites, Communication)
$sites = Get-PnPTenantSite -Filter "Template -ne 'STS#0'" | Where-Object { $_.Url -like "*sharepoint.com/sites/*" }

$allLinks = @()

foreach ($site in $sites) {
    Write-Host "Processing: $($site.Url)" -ForegroundColor Cyan
    try {
        Connect-PnPOnline -Url $site.Url -Interactive

        $lists = Get-PnPList | Where-Object { $_.BaseTemplate -eq 101 }  # Document Libraries
        foreach ($list in $lists) {
            $items = Get-PnPListItem -List $list -PageSize 100
            foreach ($item in $items) {
                $sharedLinks = Get-PnPSharingLink -List $list -Identity $item.Id -ErrorAction SilentlyContinue
                foreach ($link in $sharedLinks) {
                    $allLinks += [PSCustomObject]@{
                        SiteUrl         = $site.Url
                        ListTitle       = $list.Title
                        ItemName        = $item.FieldValues["FileLeafRef"]
                        LinkType        = $link.LinkKind
                        LinkScope       = $link.Scope
                        Expiration      = $link.Expiration
                        Url             = $link.Url
                        HasPassword     = $link.HasPassword
                        IsEditLink      = $link.IsEditLink
                    }
                }
            }
        }
    }
    catch {
        Write-Warning "Could not access site: $($site.Url)"
    }
}

# Export results
$timestamp = Get-Date -Format "yyyyMMdd_HHmm"
$outputPath = "$env:USERPROFILE\Documents\SP_SharingLinks_Report_$timestamp.csv"
$allLinks | Export-Csv -Path $outputPath -NoTypeInformation -Encoding UTF8

Write-Host "`nReport saved to: $outputPath" -ForegroundColor Green
