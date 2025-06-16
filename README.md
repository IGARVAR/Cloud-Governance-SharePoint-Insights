# Cloud-Governance-SP-DLP

**Microsoft 365 Cloud Governance & DLP Automation**  
Scripts for managing external sharing, sensitivity, and Purview policy audits across SharePoint and Microsoft Teams environments.

## Overview

This repository provides automation and reporting tools to support governance and compliance strategies in Microsoft 365. It focuses on SharePoint Online settings, DLP enforcement, anonymous access auditing, and tenant-level policy visibility — essential for organizations adopting Zero Trust, external collaboration, and Purview-based data protection.

### Key Areas Covered

- SharePoint external sharing audits and configuration cleanup
- Removal of anonymous links and open sharing
- DLP policy insights via Microsoft Purview
- Monitoring tenant settings impacting collaboration and compliance
- Baseline readiness for Microsoft Copilot & modern features

## File Index

| Script                                   | Description                                                                 |
|------------------------------------------|-----------------------------------------------------------------------------|
| `SP_REPORT_Sharing_Links_Report.ps1`     | Exports all active SharePoint sharing links with type, target, and source. |
| `SP_REPORT_Sites_SharingStatus.ps1`      | Audits site-level sharing capability and visibility (e.g., anonymous, guest). |
| `SP_OPER_RemoveAnonymousLinks.ps1`       | Removes existing anonymous links from SharePoint files and libraries.       |
| `SP_PURVIEW_DLP_Policy_Audit.ps1`        | Lists all Purview DLP policies, their scopes, and last modification date.   |
| `SP_SETTINGS_FeatureD.ps1`               | Audits key SharePoint tenant settings (e.g., Copilot, AIP, SensitivityLabels). |

## Use Cases

- **Security Baseline Validation** — Assess sharing posture before enabling external collaboration.
- **Policy-Driven Cleanup** — Identify and remove anonymous links or risky configurations.
- **Copilot Readiness** — Evaluate whether tenant settings meet Copilot security prerequisites.
- **Compliance Reviews** — Track DLP policies and tenant feature toggles to support audits.
- **Zero Trust Operations** — Highlight visibility gaps in tenant sharing and external access.

## Requirements

- PowerShell 7.x (or 5.1 with compatibility)
- `PnP.PowerShell` module for SharePoint access
- Microsoft Purview permissions (for DLP audit script)
- Admin rights to SharePoint tenant (for feature queries and link removals)

## Author

**Ivan Garkusha**  
Cloud Automation Engineer | Microsoft 365 Governance | Identity & Security  

