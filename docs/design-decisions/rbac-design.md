# MediCore Health Systems — Role Hierarchy Design
Version: 2.0.0
Date: February 2026
Status: Active — Implemented through Phase 04

> **Change Summary (v1.0 → v2.0.0)**
> - `MEDICORE_SECURITY_ADMIN` removed from Tier 1. Governance responsibilities redistributed to `MEDICORE_COMPLIANCE_OFFICER`. Security object management (masking policies, tags, row access policies) granted directly to `MEDICORE_COMPLIANCE_OFFICER` via schema-level privileges in `MEDICORE_GOVERNANCE_DB.POLICIES` and `MEDICORE_GOVERNANCE_DB.TAGS`.
> - `MEDICORE_SVC_GITHUB_ACTIONS` added to Tier 2 as the dedicated CI/CD service account for Schemachange deployments.
> - Warehouse names updated to full `MEDICORE_` prefix throughout.
> - Database names updated to full `MEDICORE_` prefix throughout.
> - Role count corrected from 17 to 18.
> - Logical hierarchy updated to remove SECURITY_ADMIN branch and add SVC_GITHUB_ACTIONS.

---

# PART 2 — ROLE HIERARCHY DESIGN

## Overview

MediCore's RBAC model implements least-privilege with role inheritance.
The hierarchy separates:

- Data access roles
- Administrative system roles
- CI/CD service accounts

PHI access is strictly controlled via hierarchy + masking policies + row access policies.
All schema ownership is retained by ACCOUNTADMIN — MEDICORE roles receive targeted USAGE and CREATE privileges only. This is intentional for CI/CD compatibility: Schemachange deployments run as `MEDICORE_SVC_GITHUB_ACTIONS` and require CREATE privileges, not ownership.

---

# 2.1 Role Naming Convention

## Standard Format

```
MEDICORE_<FUNCTION>_<ACCESS_LEVEL>
```

Examples:

```
MEDICORE_CLINICAL_PHYSICIAN
MEDICORE_ANALYST_RESTRICTED
```

---

## Special Prefixes

| Prefix | Purpose | Example |
|---|---|---|
| `MEDICORE_SVC_` | Service accounts (automated, non-interactive) | `MEDICORE_SVC_ETL_LOADER`, `MEDICORE_SVC_GITHUB_ACTIONS` |
| `MEDICORE_EXT_` | External temporary access | `MEDICORE_EXT_AUDITOR` |
| `MEDICORE_APP_` | Application roles | `MEDICORE_APP_STREAMLIT` |

---

# 2.2 Complete Role Index

## Tier 1 — Administrative (1 role)

- `MEDICORE_PLATFORM_ADMIN`

**Platform Admin responsibilities:**
- Account-level configuration and monitoring
- Warehouse management and resource monitor administration
- User and role provisioning (not policy authoring)
- Network policy and security settings management
- Cannot directly query PHI
- Cannot author or attach masking policies or row access policies

> **Design Note:** `MEDICORE_SECURITY_ADMIN` was removed in v2.0.0. In the original v1.0 design, a separate Security Admin role held governance object privileges. This was collapsed because in a HIPAA-regulated environment, separating "who can see the policies" from "who is accountable for compliance" adds complexity without meaningful security benefit when the compliance officer role already has full read access everywhere. Masking policy and row access policy authoring now lives with `MEDICORE_COMPLIANCE_OFFICER`, which is the role that understands the regulatory context for each policy decision.

---

## Tier 2 — Data Engineering (3 roles)

- `MEDICORE_DATA_ENGINEER`
- `MEDICORE_SVC_ETL_LOADER`
- `MEDICORE_SVC_GITHUB_ACTIONS`

**Data Engineer:**
- Full access to `MEDICORE_RAW_DB` and `MEDICORE_TRANSFORM_DB` (all PROD/QA/DEV schemas)
- CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE on all analytics schemas
- Read access to `MEDICORE_ANALYTICS_DB` PROD schemas
- Read + CREATE access to `MEDICORE_AI_READY_DB` PROD schemas
- Default warehouse: `MEDICORE_ETL_WH`
- Cannot author or attach masking policies or tags

**SVC ETL Loader:**
- Automated pipeline service account (non-interactive)
- INSERT and UPDATE on PROD tables in `MEDICORE_RAW_DB` only
- USAGE on PROD schemas in `MEDICORE_RAW_DB`
- No SELECT, no DDL, no QA/DEV schema access
- Default warehouse: `MEDICORE_ETL_WH`

**SVC GitHub Actions:**
- CI/CD deployment service account for Schemachange migrations
- USAGE on all schemas across all MEDICORE databases (PROD, QA, DEV)
- CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE on all schemas across all environments
- USAGE + OPERATE on `MEDICORE_ETL_WH` (needed to execute migration scripts)
- No SELECT on data tables — deployment only, never queries data
- No masking policy or tag authoring privileges
- Credentials stored as GitHub Actions secrets, never in source code
- Runs migrations in order: DEV → QA → PROD per environment promotion workflow

---

## Tier 3 — Clinical Roles (3 roles)

- `MEDICORE_CLINICAL_PHYSICIAN`
- `MEDICORE_CLINICAL_NURSE`
- `MEDICORE_CLINICAL_READER`

**Inheritance chain:** `CLINICAL_PHYSICIAN` inherits `CLINICAL_NURSE` inherits `CLINICAL_READER` inherits `REFERENCE_READER`

**Clinical Physician:**
- Full clinical PHI — no masking applied
- Access to `MEDICORE_ANALYTICS_DB.PROD_CLINICAL` only
- Default warehouse: `MEDICORE_ANALYTICS_WH`

**Clinical Nurse:**
- Unit-restricted access via row access policy (Phase 08)
- Financial identifiers masked
- Access to `MEDICORE_ANALYTICS_DB.PROD_CLINICAL` only
- Default warehouse: `MEDICORE_ANALYTICS_WH`

**Clinical Reader:**
- Name + MRN visible only — all other PHI masked
- Access to `MEDICORE_ANALYTICS_DB.PROD_CLINICAL` only
- Default warehouse: `MEDICORE_ANALYTICS_WH`

---

## Tier 4 — Revenue Cycle (2 roles)

- `MEDICORE_BILLING_SPECIALIST`
- `MEDICORE_BILLING_READER`

**Inheritance chain:** `BILLING_SPECIALIST` inherits `BILLING_READER` inherits `REFERENCE_READER`

**Billing Specialist:**
- Full billing and claims access
- Diagnosis codes visible, clinical notes masked
- Access to `MEDICORE_ANALYTICS_DB.PROD_BILLING` only
- Default warehouse: `MEDICORE_ANALYTICS_WH`

**Billing Reader:**
- Aggregated billing metrics only
- Access to `MEDICORE_ANALYTICS_DB.PROD_BILLING` only
- Default warehouse: `MEDICORE_ANALYTICS_WH`

---

## Tier 5 — Analytics & Data Science (3 roles)

- `MEDICORE_ANALYST_PHI`
- `MEDICORE_ANALYST_RESTRICTED`
- `MEDICORE_DATA_SCIENTIST`

**Analyst PHI:**
- Patient-level data access across all `MEDICORE_ANALYTICS_DB` PROD schemas
- Read access to `MEDICORE_AI_READY_DB.PROD_FEATURES` and `PROD_TRAINING`
- Default warehouse: `MEDICORE_ANALYTICS_WH`

**Analyst Restricted:**
- No PHI — de-identified and executive schemas only
- Access to `MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE` and `PROD_DEIDENTIFIED`
- Default warehouse: `MEDICORE_ANALYTICS_WH`

**Data Scientist:**
- Full access to all `MEDICORE_AI_READY_DB` PROD schemas (owns the ML layer)
- Read access to all `MEDICORE_TRANSFORM_DB` PROD schemas
- Read access to all `MEDICORE_ANALYTICS_DB` PROD schemas
- Default warehouse: `MEDICORE_ML_WH`

---

## Tier 6 — Compliance & Audit (2 roles)

- `MEDICORE_COMPLIANCE_OFFICER`
- `MEDICORE_EXT_AUDITOR`

**Compliance Officer:**
- Full read access to PROD schemas across all five MEDICORE databases
- Audit log access (`MEDICORE_GOVERNANCE_DB.AUDIT` and all `*_AUDIT` schemas)
- **Governance object authoring** (inherited from removed SECURITY_ADMIN):
  - `CREATE MASKING POLICY` on `MEDICORE_GOVERNANCE_DB.POLICIES`
  - `CREATE ROW ACCESS POLICY` on `MEDICORE_GOVERNANCE_DB.POLICIES`
  - `CREATE TAG` on `MEDICORE_GOVERNANCE_DB.TAGS`
- Default warehouse: `MEDICORE_ANALYTICS_WH`

**External Auditor:**
- Pre-staged, Safe Harbor de-identified extracts only
- Access to `MEDICORE_ANALYTICS_DB.PROD_DEIDENTIFIED` only
- All PHI masked at source — masking policies enforced before data reaches this schema
- Time-limited access — provisioned per engagement
- Default warehouse: `MEDICORE_ANALYTICS_WH`

---

## Tier 7 — Executive & Base (2 roles)

- `MEDICORE_EXECUTIVE`
- `MEDICORE_REFERENCE_READER`

**Executive:**
- Aggregated KPI dashboards only — no PHI, no patient-level data
- Access to `MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE` only
- Default warehouse: `MEDICORE_ANALYTICS_WH`

**Reference Reader:**
- Base role for lookup and code set data
- Access to `MEDICORE_ANALYTICS_DB.PROD_REFERENCE` only
- All clinical and billing roles inherit from this role

---

## Tier 8 — Application Roles (1 role)

- `MEDICORE_APP_STREAMLIT`

Streamlit application access to `MEDICORE_ANALYTICS_DB` clinical, billing, and executive PROD schemas.
Uses invoking user context OR fixed deployment role depending on application architecture.
Row access policies applied at query time based on the invoking user's role.
Default warehouse: `MEDICORE_ANALYTICS_WH`

---

# 2.3 Logical Hierarchy

```
ACCOUNTADMIN
└── MEDICORE_PLATFORM_ADMIN

DATA_ACCESS_TREE:

MEDICORE_REFERENCE_READER
├── MEDICORE_ANALYST_RESTRICTED
│   └── MEDICORE_ANALYST_PHI
│       └── MEDICORE_DATA_ENGINEER
├── MEDICORE_CLINICAL_READER
│   └── MEDICORE_CLINICAL_NURSE
│       └── MEDICORE_CLINICAL_PHYSICIAN
└── MEDICORE_BILLING_READER
    └── MEDICORE_BILLING_SPECIALIST

Standalone (no inheritance chain):
  MEDICORE_SVC_ETL_LOADER
  MEDICORE_SVC_GITHUB_ACTIONS
  MEDICORE_EXT_AUDITOR
  MEDICORE_APP_STREAMLIT
  MEDICORE_DATA_SCIENTIST
  MEDICORE_COMPLIANCE_OFFICER
  MEDICORE_EXECUTIVE
```

> **Note:** `MEDICORE_SECURITY_ADMIN` has been fully removed. The `SECURITYADMIN → SECURITY_ADMIN` branch from v1.0 no longer exists. Governance object creation is handled by `MEDICORE_COMPLIANCE_OFFICER` via explicit schema-level `CREATE MASKING POLICY`, `CREATE ROW ACCESS POLICY`, and `CREATE TAG` grants on `MEDICORE_GOVERNANCE_DB`.

---

# 2.4 Role → Warehouse Mapping

| Role | Default Warehouse | Privileges on Warehouse |
|---|---|---|
| `MEDICORE_PLATFORM_ADMIN` | `MEDICORE_ADMIN_WH` | USAGE, OPERATE, MODIFY |
| `MEDICORE_COMPLIANCE_OFFICER` | `MEDICORE_ADMIN_WH` | USAGE, OPERATE |
| `MEDICORE_DATA_ENGINEER` | `MEDICORE_ETL_WH` | USAGE, OPERATE, MODIFY |
| `MEDICORE_SVC_ETL_LOADER` | `MEDICORE_ETL_WH` | USAGE, OPERATE |
| `MEDICORE_SVC_GITHUB_ACTIONS` | `MEDICORE_ETL_WH` | USAGE, OPERATE |
| `MEDICORE_CLINICAL_PHYSICIAN` | `MEDICORE_ANALYTICS_WH` | USAGE |
| `MEDICORE_CLINICAL_NURSE` | `MEDICORE_ANALYTICS_WH` | USAGE |
| `MEDICORE_CLINICAL_READER` | `MEDICORE_ANALYTICS_WH` | USAGE |
| `MEDICORE_BILLING_SPECIALIST` | `MEDICORE_ANALYTICS_WH` | USAGE |
| `MEDICORE_BILLING_READER` | `MEDICORE_ANALYTICS_WH` | USAGE |
| `MEDICORE_ANALYST_PHI` | `MEDICORE_ANALYTICS_WH` | USAGE |
| `MEDICORE_ANALYST_RESTRICTED` | `MEDICORE_ANALYTICS_WH` | USAGE |
| `MEDICORE_EXECUTIVE` | `MEDICORE_ANALYTICS_WH` | USAGE |
| `MEDICORE_EXT_AUDITOR` | `MEDICORE_ANALYTICS_WH` | USAGE |
| `MEDICORE_APP_STREAMLIT` | `MEDICORE_ANALYTICS_WH` | USAGE |
| `MEDICORE_REFERENCE_READER` | `MEDICORE_ANALYTICS_WH` | USAGE |
| `MEDICORE_DATA_SCIENTIST` | `MEDICORE_ML_WH` | USAGE, OPERATE |

> `MEDICORE_SVC_GITHUB_ACTIONS` uses `MEDICORE_ETL_WH` because Schemachange migration scripts execute DDL statements (CREATE TABLE, CREATE VIEW, ALTER TABLE) which require an active warehouse context to run.

---

# 2.5 Role Access Summary

| Role | PHI Access | `MEDICORE_RAW_DB` | `MEDICORE_TRANSFORM_DB` | `MEDICORE_ANALYTICS_DB` | `MEDICORE_AI_READY_DB` | `MEDICORE_GOVERNANCE_DB` |
|---|---|---|---|---|---|---|
| `MEDICORE_DATA_ENGINEER` | Full | PROD + QA + DEV | PROD + QA + DEV | All schemas (CREATE) | PROD (CREATE) | POLICIES, TAGS, DQ, AUDIT |
| `MEDICORE_SVC_ETL_LOADER` | Write-only | PROD (INSERT/UPDATE) | No | No | No | No |
| `MEDICORE_SVC_GITHUB_ACTIONS` | No data access | All schemas (DDL) | All schemas (DDL) | All schemas (DDL) | All schemas (DDL) | DQ, AUDIT (DDL) |
| `MEDICORE_CLINICAL_PHYSICIAN` | Full clinical PHI | No | No | PROD_CLINICAL | No | No |
| `MEDICORE_CLINICAL_NURSE` | PHI (masked financial) | No | No | PROD_CLINICAL | No | No |
| `MEDICORE_CLINICAL_READER` | Name + MRN only | No | No | PROD_CLINICAL | No | No |
| `MEDICORE_BILLING_SPECIALIST` | Billing PHI | No | No | PROD_BILLING | No | No |
| `MEDICORE_BILLING_READER` | Aggregates only | No | No | PROD_BILLING | No | No |
| `MEDICORE_ANALYST_PHI` | Full patient-level | No | No | All PROD schemas | PROD_FEATURES, PROD_TRAINING | No |
| `MEDICORE_ANALYST_RESTRICTED` | None | No | No | PROD_EXECUTIVE, PROD_DEIDENTIFIED | No | No |
| `MEDICORE_DATA_SCIENTIST` | Full | No | PROD (read) | All PROD (read) | All PROD (full) | No |
| `MEDICORE_COMPLIANCE_OFFICER` | Full (audit) | PROD (read) | PROD (read) | All PROD (read) | PROD (read) | All schemas |
| `MEDICORE_EXECUTIVE` | None | No | No | PROD_EXECUTIVE | No | No |
| `MEDICORE_EXT_AUDITOR` | None (de-identified) | No | No | PROD_DEIDENTIFIED | No | No |
| `MEDICORE_PLATFORM_ADMIN` | No | DB-level USAGE | DB-level USAGE | DB-level USAGE | DB-level USAGE | DB-level USAGE |

---

# 2.6 Role Count

| Category | Count | Roles |
|---|---|---|
| Administrative | 1 | PLATFORM_ADMIN |
| Data Engineering | 3 | DATA_ENGINEER, SVC_ETL_LOADER, SVC_GITHUB_ACTIONS |
| Clinical | 3 | CLINICAL_PHYSICIAN, CLINICAL_NURSE, CLINICAL_READER |
| Revenue Cycle | 2 | BILLING_SPECIALIST, BILLING_READER |
| Analytics | 3 | ANALYST_PHI, ANALYST_RESTRICTED, DATA_SCIENTIST |
| Compliance & Audit | 2 | COMPLIANCE_OFFICER, EXT_AUDITOR |
| Executive & Base | 2 | EXECUTIVE, REFERENCE_READER |
| Application | 1 | APP_STREAMLIT |

**Total Roles: 18**

> **Change from v1.0:** Administrative count decreased from 2 to 1 (`MEDICORE_SECURITY_ADMIN` removed). Engineering count increased from 2 to 3 (`MEDICORE_SVC_GITHUB_ACTIONS` added). Net change: +0 to total, but role responsibilities redistributed.

---

# Appendix A — Design Decisions

| Decision | Rationale |
|---|---|
| All roles use `MEDICORE_` prefix | Prevents naming conflicts in shared Snowflake accounts; makes all MediCore roles easily identifiable in audit logs |
| ACCOUNTADMIN retains schema ownership | CI/CD compatibility — Schemachange runs as `MEDICORE_SVC_GITHUB_ACTIONS` with CREATE privileges, not ownership. If a MEDICORE role owned schemas, Schemachange could not deploy migrations to schemas owned by a different role |
| `MEDICORE_SECURITY_ADMIN` removed | Collapsed into `MEDICORE_COMPLIANCE_OFFICER`. Separating policy authoring from compliance accountability added complexity without security benefit. Compliance officers understand the regulatory context for each policy decision |
| `MEDICORE_SVC_GITHUB_ACTIONS` is a dedicated CI/CD role | Separates human engineering access from automated deployment access. Credentials are stored only as GitHub Actions secrets. Audit logs can distinguish human DDL from deployment DDL |
| Service accounts are standalone (no inheritance) | `SVC_ETL_LOADER` and `SVC_GITHUB_ACTIONS` inherit from nothing. This ensures the blast radius of a compromised service account credential is precisely bounded to the privileges explicitly granted to that account |
| 42 CFR Part 2 substance abuse records handled via subdomain tagging | `DATA_SUBDOMAIN = SUBSTANCE_ABUSE` triggers the most restrictive consent policy. Managed separately from general clinical PHI |
| Executives restricted to aggregated schemas | `MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE` contains only aggregated KPIs and counts — no patient-level data. Executives never need raw or transformed data |
| PHI schemas exist only in PROD environment | QA and DEV schemas contain synthetic data only. This is enforced by policy and documented in schema comments. Real PHI is never loaded into `QA_*` or `DEV_*` schemas |

---

# Appendix B — Implementation Status

| Phase | Component | Status |
|---|---|---|
| Phase 01 | Account administration, GOVERNANCE_DB creation | ✅ Complete |
| Phase 02 | All 18 roles created with hierarchy and grants | ✅ Complete |
| Phase 03 | 4 warehouses with role grants | ✅ Complete |
| Phase 04 | 5 databases, 59 schemas, environment isolation | ✅ Complete |
| Phase 05 | Resource monitors | 🔲 Pending |
| Phase 06 | Monitoring views | 🔲 Pending |
| Phase 07 | Cost and queue alerts | 🔲 Pending |
| Phase 08 | Masking policies, row access policies, tags | 🔲 Pending |
| Phase 09 | Audit views | 🔲 Pending |
| Phase 10 | Verification and test scripts | 🔲 Ongoing |
| Phase 11 | Medallion architecture (Dynamic Tables) | 🔲 Pending |
| Phase 14 | GitHub CI/CD with Schemachange | 🔲 Pending |
| Phase 15 | Azure DevOps project structure | 🔲 Pending |

---