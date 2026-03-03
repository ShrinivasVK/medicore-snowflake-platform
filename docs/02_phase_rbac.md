# Phase 02: RBAC Setup

## Overview

Phase 02 establishes the complete Role-Based Access Control (RBAC) hierarchy for MediCore Health Systems. This phase creates 18 custom roles across 9 tiers, implements role inheritance, configures database and schema grants, and establishes future grants for automated permission management.

**Script:** `infrastructure/02_rbac/02_rbac_setup.sql`  
**Version:** 2.0.0  
**Required Roles:** ACCOUNTADMIN (initial), SECURITYADMIN (role grants)  
**Estimated Execution Time:** 5-8 minutes

## Prerequisites

- [ ] Phase 01 completed
- [ ] `MEDICORE_GOVERNANCE_DB` exists
- [ ] `MEDICORE_GOVERNANCE_DB.SECURITY` schema exists
- [ ] `MEDICORE_PASSWORD_POLICY` applied

## Role Hierarchy

### 9-Tier Role Architecture

```
                            ┌─────────────────┐
                            │   ACCOUNTADMIN  │
                            └────────┬────────┘
                                     │
                            ┌────────┴────────┐
                            │    SYSADMIN     │
                            └────────┬────────┘
                                     │
        ┌────────────────────────────┼────────────────────────────┐
        │                            │                            │
┌───────┴───────┐           ┌────────┴────────┐          ┌────────┴────────┐
│ PLATFORM_ADMIN│           │  DATA_ENGINEER  │          │ COMPLIANCE_     │
│   (Tier 1)    │           │    (Tier 2)     │          │ OFFICER (Tier 6)│
└───────────────┘           └────────┬────────┘          └────────┬────────┘
                                     │                            │
                            ┌────────┴────────┐          ┌────────┴────────┐
                            │   ANALYST_PHI   │◄─────────┤   ANALYST_PHI   │
                            │    (Tier 5)     │          │    (Tier 5)     │
                            └────────┬────────┘          └─────────────────┘
                                     │
                            ┌────────┴──────────┐
                            │ANALYST_RESTRICTED│
                            │    (Tier 5)     │
                            └────────┬──────────┘
                                     │
              ┌──────────────────────┼──────────────────────┐
              │                      │                      │
     ┌────────┴────────┐    ┌────────┴────────┐    ┌────────┴────────┐
     │REFERENCE_READER │    │REFERENCE_READER │    │REFERENCE_READER │
     │   (Tier 7)      │    │   (Tier 7)      │    │   (Tier 7)      │
     └────────┬────────┘    └────────┬────────┘    └────────┬────────┘
              │                      │                      │
     ┌────────┴────────┐    ┌────────┴────────┐    ┌────────┴────────┐
     │ CLINICAL_READER │    │ BILLING_READER  │    │   EXECUTIVE     │
     │   (Tier 3)      │    │   (Tier 4)      │    │   (Tier 7)      │
     └────────┬────────┘    └────────┬────────┘    └─────────────────┘
              │                      │
     ┌────────┴────────┐    ┌────────┴─────────┐
     │ CLINICAL_NURSE  │    │BILLING_SPECIALIST│
     │   (Tier 3)      │    │   (Tier 4)       │
     └────────┬────────┘    └──────────────────┘
              │
     ┌────────┴─────────┐
     │CLINICAL_PHYSICIAN│
     │   (Tier 3)       │
     └──────────────────┘
```

## Roles Created (18 Total)

### Tier 1: Administrative (1 role)

| Role | Description | Persona |
|------|-------------|---------|
| `MEDICORE_PLATFORM_ADMIN` | Platform administrator for account management. Manages warehouses, network policies, account settings. No direct PHI access. | Hospital IT Director, Cloud Infrastructure Team |

### Tier 2: Data Engineering (2 roles)

| Role | Description | Persona |
|------|-------------|---------|
| `MEDICORE_DATA_ENGINEER` | Full RAW_DB and TRANSFORM_DB access. Read access to ANALYTICS_DB and AI_READY_DB. | Data Engineers, ETL Developers |
| `MEDICORE_SVC_ETL_LOADER` | Service account for automated ETL pipelines. Write-only to designated schemas. | Airflow, dbt, Fivetran connections |

### Tier 3: Clinical (3 roles)

| Role | Description | Persona |
|------|-------------|---------|
| `MEDICORE_CLINICAL_PHYSICIAN` | Full clinical PHI access for patient care. HIPAA Treatment exception. | Attending Physicians, Medical Directors, CMO |
| `MEDICORE_CLINICAL_NURSE` | Unit-restricted clinical access. Financial identifiers masked. | RNs, LPNs, Nurse Practitioners |
| `MEDICORE_CLINICAL_READER` | Read-only clinical access. Limited to patient name and MRN only. | Medical Assistants, Unit Clerks, Schedulers |

### Tier 4: Revenue Cycle (2 roles)

| Role | Description | Persona |
|------|-------------|---------|
| `MEDICORE_BILLING_SPECIALIST` | Billing and coding with access to charges, claims, diagnosis codes. Clinical notes masked. | Medical Coders, Billing Representatives |
| `MEDICORE_BILLING_READER` | Read-only billing data for financial reporting. Aggregated views only. | Revenue Cycle Managers, Financial Analysts |

### Tier 5: Analytics (3 roles)

| Role | Description | Persona |
|------|-------------|---------|
| `MEDICORE_ANALYST_PHI` | Clinical data analysts with PHI access for quality and outcomes research. | Clinical Data Analysts, Quality Improvement Specialists |
| `MEDICORE_ANALYST_RESTRICTED` | Business analysts with de-identified data only. No PHI access. | BI Analysts, Report Developers |
| `MEDICORE_DATA_SCIENTIST` | ML/AI practitioners with full AI_READY_DB access. | Data Scientists, ML Engineers |

### Tier 6: Compliance & Audit (2 roles)

| Role | Description | Persona |
|------|-------------|---------|
| `MEDICORE_COMPLIANCE_OFFICER` | Full read access everywhere including audit logs. Manages masking policies and tags. | Compliance Officers, Privacy Officers |
| `MEDICORE_EXT_AUDITOR` | Time-limited, restricted access. Pre-staged extracts only, all PHI masked. | External CPA Firms, HITRUST Assessors |

### Tier 7: Executive & Base (2 roles)

| Role | Description | Persona |
|------|-------------|---------|
| `MEDICORE_EXECUTIVE` | Executive dashboards with aggregated KPIs only. No patient-level data. | CEO, CFO, COO, Board Members |
| `MEDICORE_REFERENCE_READER` | Base role with reference/lookup data only. Foundation role for all users. | All authenticated users |

### Tier 8: Application (1 role)

| Role | Description | Persona |
|------|-------------|---------|
| `MEDICORE_APP_STREAMLIT` | Service role for Streamlit applications. Uses CURRENT_ROLE() of invoking user. | Streamlit applications |

### Tier 9: CI/CD Service (1 role)

| Role | Description | Persona |
|------|-------------|---------|
| `MEDICORE_SVC_GITHUB_ACTIONS` | GitHub Actions CI/CD pipelines via Schemachange. Full DDL on DEV/QA/PROD schemas. | GitHub Actions automation |

## Role Hierarchy Grants

| Child Role | Parent Role | Inheritance Direction |
|------------|-------------|----------------------|
| `MEDICORE_REFERENCE_READER` | `MEDICORE_ANALYST_RESTRICTED` | Base → Restricted |
| `MEDICORE_REFERENCE_READER` | `MEDICORE_CLINICAL_READER` | Base → Clinical |
| `MEDICORE_REFERENCE_READER` | `MEDICORE_BILLING_READER` | Base → Billing |
| `MEDICORE_CLINICAL_READER` | `MEDICORE_CLINICAL_NURSE` | Reader → Nurse |
| `MEDICORE_CLINICAL_NURSE` | `MEDICORE_CLINICAL_PHYSICIAN` | Nurse → Physician |
| `MEDICORE_BILLING_READER` | `MEDICORE_BILLING_SPECIALIST` | Reader → Specialist |
| `MEDICORE_ANALYST_RESTRICTED` | `MEDICORE_ANALYST_PHI` | Restricted → PHI |
| `MEDICORE_ANALYST_PHI` | `MEDICORE_DATA_ENGINEER` | PHI → Engineer |
| `MEDICORE_ANALYST_PHI` | `MEDICORE_DATA_SCIENTIST` | PHI → Scientist |
| `MEDICORE_ANALYST_RESTRICTED` | `MEDICORE_EXECUTIVE` | Restricted → Executive |
| `MEDICORE_ANALYST_PHI` | `MEDICORE_COMPLIANCE_OFFICER` | PHI → Compliance |

### Standalone Roles (No Inheritance)

- `MEDICORE_SVC_ETL_LOADER` - Isolated service account
- `MEDICORE_EXT_AUDITOR` - Time-limited external access
- `MEDICORE_APP_STREAMLIT` - Runtime inheritance from invoking user
- `MEDICORE_SVC_GITHUB_ACTIONS` - CI/CD automation only

## Service Accounts

| User | Default Role | Default Warehouse | Status |
|------|--------------|-------------------|--------|
| `SVC_ETL_MEDICORE` | `MEDICORE_SVC_ETL_LOADER` | NULL | DISABLED |
| `SVC_GITHUB_ACTIONS_MEDICORE` | `MEDICORE_SVC_GITHUB_ACTIONS` | `MEDICORE_ETL_WH` | DISABLED |

> **Post-Deployment Steps:**
> 1. Configure RSA key-pair authentication for each service account
> 2. Enable the user: `ALTER USER <user_name> SET DISABLED = FALSE;`
> 3. Never enable with password authentication

## Database Access Matrix

| Database | Roles with Access |
|----------|-------------------|
| `MEDICORE_GOVERNANCE_DB` | PLATFORM_ADMIN, DATA_ENGINEER, COMPLIANCE_OFFICER, SVC_GITHUB_ACTIONS |
| `MEDICORE_RAW_DB` | PLATFORM_ADMIN, DATA_ENGINEER, SVC_ETL_LOADER, COMPLIANCE_OFFICER, SVC_GITHUB_ACTIONS |
| `MEDICORE_TRANSFORM_DB` | PLATFORM_ADMIN, DATA_ENGINEER, DATA_SCIENTIST, COMPLIANCE_OFFICER, SVC_GITHUB_ACTIONS, SVC_ETL_LOADER |
| `MEDICORE_ANALYTICS_DB` | All 16 roles (access controlled by schema-level grants) |
| `MEDICORE_AI_READY_DB` | PLATFORM_ADMIN, DATA_ENGINEER, DATA_SCIENTIST, ANALYST_PHI, COMPLIANCE_OFFICER, SVC_GITHUB_ACTIONS |

## Schema Access by Environment

### PROD Schemas
- Read-only for most roles
- Write access only via controlled CI/CD pipelines
- Masking and row access policies enforced

### QA Schemas
- DATA_ENGINEER: Full DDL and DML
- SVC_GITHUB_ACTIONS: Full DDL and DML for CI/CD testing
- Other roles: Read-only access

### DEV Schemas
- DATA_ENGINEER: Full DDL and DML
- SVC_ETL_LOADER: Full DML for pipeline testing
- SVC_GITHUB_ACTIONS: Full DDL and DML for CI/CD
- Other roles: Read-only access

## Future Grants Configured

| Object Type | Schemas | Roles |
|-------------|---------|-------|
| TABLES | All DEV/QA/PROD | Per role based on access level |
| VIEWS | TRANSFORM, ANALYTICS, AI_READY | DATA_ENGINEER, DATA_SCIENTIST, etc. |
| DYNAMIC TABLES | TRANSFORM, ANALYTICS | Clinical roles, Analysts, Compliance |

## Tag Grants

The following roles have `APPLY TAG` privileges:

| Role | Tags |
|------|------|
| `MEDICORE_DATA_ENGINEER` | All 8 governance tags |
| `MEDICORE_SVC_ETL_LOADER` | MEDALLION_LAYER, DATA_DOMAIN, ENVIRONMENT, DATA_QUALITY_STATUS |
| `MEDICORE_SVC_GITHUB_ACTIONS` | All 8 governance tags |

## Execution

```sql
-- Start as ACCOUNTADMIN
USE ROLE ACCOUNTADMIN;

-- Execute Sections 1-5 (Role creation, hierarchy, service accounts)

-- Switch to SECURITYADMIN for role grants
USE ROLE SECURITYADMIN;

-- Execute Sections 6-12 after Phase 04 creates databases

-- Verification
SHOW ROLES LIKE 'MEDICORE%';
```

## Verification Queries

```sql
-- Count all MediCore roles (expect 18)
SELECT COUNT(*) AS medicore_role_count
FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
WHERE NAME LIKE 'MEDICORE%'
AND DELETED_ON IS NULL;

-- List all roles with details
SHOW ROLES LIKE 'MEDICORE%';

-- Verify role hierarchy
SHOW GRANTS OF ROLE MEDICORE_REFERENCE_READER;
SHOW GRANTS OF ROLE MEDICORE_ANALYST_PHI;

-- Verify system role connections
SHOW GRANTS TO ROLE SYSADMIN;

-- Verify service accounts
SHOW USERS LIKE 'SVC%';

-- Verify database grants for key roles
SHOW GRANTS TO ROLE MEDICORE_DATA_ENGINEER;
SHOW GRANTS TO ROLE MEDICORE_CLINICAL_PHYSICIAN;
```

## Dependencies

### Requires (Phase 01)
- `MEDICORE_GOVERNANCE_DB`
- `MEDICORE_GOVERNANCE_DB.SECURITY`

### Required By
- **Phase 03:** Roles needed for warehouse USAGE grants
- **Phase 04:** Roles needed for schema-level grants

> **Note:** Sections 6-11 (database and schema grants) will return errors if run before Phase 04. Run Phase 03 and Phase 04 first, then re-run Sections 6-11 or execute the full script after Phase 04.

## Summary

| Category | Count |
|----------|-------|
| Roles Created | 18 |
| Hierarchy Grants | 11 |
| System Role Grants | 12 (to SYSADMIN) |
| Service Accounts | 2 |
| Databases Configured | 5 |
| Environment Schemas | DEV, QA, PROD (per database) |

## Next Phase

Proceed to **[Phase 03: Warehouse Management](03_phase_warehouse_management.md)** to configure compute resources.
