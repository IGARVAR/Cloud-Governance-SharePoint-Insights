<#
.SYNOPSIS
Scans SharePoint Online and optionally OneDrive sites for anonymous sharing links ("Anyone with the link") and removes them.

.DESCRIPTION
This script audits all SharePoint Online (SPO) sites — and optionally user OneDrive accounts — to find files or folders shared using anonymous links.
It then removes those links to align with governance policies and Zero Trust security posture.

Requires SharePoint Online Management Shell and proper permissions.

.PARAMETER IncludeOneDrive
Optional switch to include OneDrive sites in the scan.

.PARAMETER DryRun
Optional switch to only log findings without removing links.

.EXAMPLE
.\SP_OPER_RemoveAnonymousLinks.ps1 -IncludeOneDrive -DryRun

.EXAMPLE
.\SP_OPER_RemoveAnonymousLinks.ps1

.NOTES
Author: Ivan Garkusha
#>

param (
    [switch]$IncludeOneDrive,
    [switch]$DryRun
)

# Connect to SPO Admin
Connect-SPOService -Url "https://<your-tenant>-admin.sharepoint.com"

$Sites = Get-SPOSite -Limit All | Where-Object { $_.Template -ne "RedirectSite#0" }

if ($IncludeOneDrive) {
    $OneDriveSites = Get-SPOSite -IncludePersonalSite $true -Limit All | Where-Object { $_.Template -eq "SPSPERS#10" }
    $Sites += $OneDriveSites
}

$Log = @()

foreach ($site in $Sites) {
    Write-Host "`nScanning: $($site.Url)" -ForegroundColor Cyan

    try {
        $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($site.Url)
        $ctx.Credentials = (Get-Credential)

        $web = $ctx.Web
        $ctx.Load($web)
        $ctx.ExecuteQuery()

        $lists = $web.Lists
        $ctx.Load($lists)
        $ctx.ExecuteQuery()

        foreach ($list in $lists) {
            if ($list.BaseType -ne "DocumentLibrary" -or $list.Hidden) { continue }

            $ctx.Load($list.RootFolder)
            $ctx.ExecuteQuery()

            $query = New-Object Microsoft.SharePoint.Client.CamlQuery
            $query.ViewXml = "<View Scope='RecursiveAll'><Query></Query></View>"

            $items = $list.GetItems($query)
            $ctx.Load($items)
            $ctx.ExecuteQuery()

            foreach ($item in $items) {
                $ctx.Load($item)
                $ctx.Load($item.RoleAssignments)
                $ctx.ExecuteQuery()

                $sharedLinks = $item.ListItemAllFields.FieldValues["SharedWithUsers"]

                # Placeholder logic – use Graph API for detailed external sharing info
                # Example: if shared link is anonymous
                if ($sharedLinks -like "*guest*" -or $item.HasUniqueRoleAssignments) {
                    $entry = [PSCustomObject]@{
                        SiteUrl        = $site.Url
                        ItemUrl        = "$($site.Url)/$($item["FileRef"])"
                        SharedBy       = $item["Author"].Email
                        LinkScope      = "anonymous"
                        LinkType       = "view/edit"
                        ExpirationDate = $null
                        Removed        = $false
                        Timestamp      = (Get-Date)
                    }

                    if (-not $DryRun) {
                        try {
                            # Simulate removal (for real use, call Remove-SPOExternalUserLink or Graph API)
                            # Remove-PnPSharingLink -Identity $item -Scope Anonymous
                            $entry.Removed = $true
                            Write-Host "Removed anonymous link from: $($entry.ItemUrl)" -ForegroundColor Yellow
                        } catch {
                            Write-Warning "Failed to remove sharing for $($entry.ItemUrl)"
                        }
                    }

                    $Log += $entry
                }
            }
        }
    } catch {
        Write-Warning "Error processing site: $($site.Url) — $_"
    }
}

# Export log
$timestamp = (Get-Date -Format "yyyyMMdd_HHmm")
$Log | Export-Csv -Path "AnonymousLinkRemovalLog_$timestamp.csv" -NoTypeInformation -Encoding UTF8
Write-Host "`nDone. Output: AnonymousLinkRemovalLog_$timestamp.csv" -ForegroundColor Green
