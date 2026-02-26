# Phase 04: Database Structure

## Overview

Phase 04 creates the 4-tier medallion database architecture for MediCore Health Systems with schema-level environment isolation (DEV/QA/PROD). This phase implements the Bronze, Silver, Gold, and Platinum layers, completes the Governance database, and establishes comprehensive role-based grants.

**Script:** `infrastructure/04_databases/04_database_structure.sql`  
**Version:** 2.0.0  
**Required Role:** ACCOUNTADMIN  
**Estimated Execution Time:** 3-5 minutes

## Prerequisites

- [ ] Phase 01 completed (`MEDICORE_GOVERNANCE_DB` and `SECURITY` schema exist)
- [ ] Phase 02 Sections 1-5 completed (all 18 roles exist)
- [ ] Phase 03 completed (all 4 warehouses exist)

## Architecture Overview

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                         MEDALLION ARCHITECTURE                                │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐
│  │  MEDICORE_      │   │  MEDICORE_      │   │  MEDICORE_      │   │  MEDICORE_      │
│  │  RAW_DB         │ → │  TRANSFORM_DB   │ → │  ANALYTICS_DB   │ → │  AI_READY_DB    │
│  │  (Bronze)       │   │  (Silver)       │   │  (Gold)         │   │  (Platinum)     │
│  └─────────────────┘   └─────────────────┘   └─────────────────┘   └─────────────────┘
│       90-day                30-day                30-day                14-day         │
│     retention             retention             retention             retention        │
│                                                                                       │
└───────────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│                    MEDICORE_GOVERNANCE_DB (Cross-cutting)                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌─────────────┐ ┌──────────┐         │
│  │ SECURITY │ │ POLICIES │ │   TAGS   │ │ DATA_QUALITY│ │  AUDIT   │         │
│  │(Phase 01)│ │(Phase 04)│ │(Phase 04)│ │ (Phase 04)  │ │(Phase 04)│         │
│  └──────────┘ └──────────┘ └──────────┘ └─────────────┘ └──────────┘         │
└──────────────────────────────────────────────────────────────────────────────┘
```

## Environment Isolation Strategy

Each data domain has three schemas — one per environment:

| Prefix | Environment | Purpose | PHI Allowed |
|--------|-------------|---------|-------------|
| `PROD_` | Production | Live, governed, masking enforced | ✓ (real PHI) |
| `QA_` | Quality Assurance | Synthetic/anonymized test data | ✗ |
| `DEV_` | Development | Sandbox, schema evolution | ✗ |

> **WARNING:** Never load real PHI into DEV or QA schemas. Only PROD schemas should contain real PHI.

## Databases and Schemas

### MEDICORE_GOVERNANCE_DB (5 schemas)

| Schema | Purpose | Created In |
|--------|---------|------------|
| `SECURITY` | Network rules, password policy, session policy | Phase 01 |
| `POLICIES` | Masking policies, row access policies | Phase 04 |
| `TAGS` | Data classification tags | Phase 04 |
| `DATA_QUALITY` | Quality rules and metrics | Phase 04 |
| `AUDIT` | Governance audit logs | Phase 04 |

### MEDICORE_RAW_DB — Bronze Layer (12 schemas)

**Retention:** 90 days (HIPAA audit trail compliance)  
**Purpose:** Landing zone for source data exactly as received. No transformations.

| Domain | PROD | QA | DEV |
|--------|------|----|----|
| Clinical | `PROD_CLINICAL` | `QA_CLINICAL` | `DEV_CLINICAL` |
| Billing | `PROD_BILLING` | `QA_BILLING` | `DEV_BILLING` |
| Reference | `PROD_REFERENCE` | `QA_REFERENCE` | `DEV_REFERENCE` |
| Audit | `PROD_AUDIT`* | `QA_AUDIT`* | `DEV_AUDIT`* |

*Transient schemas (no Time Travel)

### MEDICORE_TRANSFORM_DB — Silver Layer (15 schemas)

**Retention:** 30 days (operational recovery)  
**Purpose:** Cleansed, conformed, validated data with business rules applied.

| Domain | PROD | QA | DEV |
|--------|------|----|----|
| Clinical | `PROD_CLINICAL` | `QA_CLINICAL` | `DEV_CLINICAL` |
| Billing | `PROD_BILLING` | `QA_BILLING` | `DEV_BILLING` |
| Reference | `PROD_REFERENCE` | `QA_REFERENCE` | `DEV_REFERENCE` |
| Audit | `PROD_AUDIT`* | `QA_AUDIT`* | `DEV_AUDIT`* |
| Common | `PROD_COMMON` | `QA_COMMON` | `DEV_COMMON` |

*Transient schemas

### MEDICORE_ANALYTICS_DB — Gold Layer (15 schemas)

**Retention:** 30 days (operational recovery)  
**Purpose:** Business-ready aggregated and dimensional models. Masking policies enforced.

| Domain | PROD | QA | DEV |
|--------|------|----|----|
| Clinical | `PROD_CLINICAL` | `QA_CLINICAL` | `DEV_CLINICAL` |
| Billing | `PROD_BILLING` | `QA_BILLING` | `DEV_BILLING` |
| Reference | `PROD_REFERENCE` | `QA_REFERENCE` | `DEV_REFERENCE` |
| Executive | `PROD_EXECUTIVE` | `QA_EXECUTIVE` | `DEV_EXECUTIVE` |
| Deidentified | `PROD_DEIDENTIFIED` | `QA_DEIDENTIFIED` | `DEV_DEIDENTIFIED` |

### MEDICORE_AI_READY_DB — Platinum Layer (12 schemas)

**Retention:** 14 days (ML iterations are frequent)  
**Purpose:** Feature store, ML training datasets, semantic models, embeddings.

| Domain | PROD | QA | DEV |
|--------|------|----|----|
| Features | `PROD_FEATURES` | `QA_FEATURES` | `DEV_FEATURES` |
| Training | `PROD_TRAINING` | `QA_TRAINING` | `DEV_TRAINING` |
| Semantic | `PROD_SEMANTIC` | `QA_SEMANTIC` | `DEV_SEMANTIC` |
| Embeddings | `PROD_EMBEDDINGS` | `QA_EMBEDDINGS` | `DEV_EMBEDDINGS` |

## Database Summary

| Database | Schemas | Retention | Collation |
|----------|---------|-----------|-----------|
| `MEDICORE_GOVERNANCE_DB` | 5 | Default | Default |
| `MEDICORE_RAW_DB` | 12 | 90 days | en-ci |
| `MEDICORE_TRANSFORM_DB` | 15 | 30 days | en-ci |
| `MEDICORE_ANALYTICS_DB` | 15 | 30 days | en-ci |
| `MEDICORE_AI_READY_DB` | 12 | 14 days | en-ci |
| **Total** | **59** | | |

## Role Access Matrix

### Database-Level USAGE Grants

| Database | Roles with USAGE |
|----------|------------------|
| `MEDICORE_GOVERNANCE_DB` | PLATFORM_ADMIN, DATA_ENGINEER, COMPLIANCE_OFFICER, SVC_GITHUB_ACTIONS |
| `MEDICORE_RAW_DB` | DATA_ENGINEER, SVC_ETL_LOADER, PLATFORM_ADMIN, COMPLIANCE_OFFICER, SVC_GITHUB_ACTIONS |
| `MEDICORE_TRANSFORM_DB` | DATA_ENGINEER, DATA_SCIENTIST, PLATFORM_ADMIN, COMPLIANCE_OFFICER, SVC_GITHUB_ACTIONS |
| `MEDICORE_ANALYTICS_DB` | All 16 operational roles |
| `MEDICORE_AI_READY_DB` | DATA_SCIENTIST, DATA_ENGINEER, ANALYST_PHI, COMPLIANCE_OFFICER, PLATFORM_ADMIN, SVC_GITHUB_ACTIONS |

### Schema-Level Access by Role (PROD)

| Schema Type | Clinical Roles | Billing Roles | Analysts | Engineering | Compliance |
|-------------|----------------|---------------|----------|-------------|------------|
| PROD_CLINICAL | ✓ | | PHI only | ✓ | ✓ |
| PROD_BILLING | | ✓ | PHI only | ✓ | ✓ |
| PROD_REFERENCE | ✓ | ✓ | ✓ | ✓ | ✓ |
| PROD_EXECUTIVE | | | ✓ | ✓ | ✓ |
| PROD_DEIDENTIFIED | | | ✓ | ✓ | ✓ |

## Grants Configuration

### CREATE Privileges

| Role | Databases | Objects |
|------|-----------|---------|
| `MEDICORE_DATA_ENGINEER` | All | TABLE, VIEW, DYNAMIC TABLE |
| `MEDICORE_SVC_GITHUB_ACTIONS` | All | TABLE, VIEW, DYNAMIC TABLE |
| `MEDICORE_COMPLIANCE_OFFICER` | GOVERNANCE_DB | MASKING POLICY, ROW ACCESS POLICY, TAG |

### Future Grants

- **SELECT** on future TABLES, VIEWS, DYNAMIC TABLES for consumer roles
- **INSERT, UPDATE** on future TABLES in RAW_DB for `SVC_ETL_LOADER`

## Execution Order

```
Phase 01 → Phase 00 → Phase 02 (Sections 1-5) → Phase 03 → Phase 04 → Phase 02 (Sections 6-12)
```

> **IMPORTANT:** After completing Phase 04, return to Phase 02 and execute Sections 6-12 (database/schema/future grants) for the complete grant matrix.

## Execution

```sql
-- Execute as ACCOUNTADMIN
USE ROLE ACCOUNTADMIN;

-- Run the script
-- infrastructure/04_databases/04_database_structure.sql
```

## Verification Queries

```sql
-- Verify all 5 databases exist
SHOW DATABASES LIKE 'MEDICORE%';

-- Verify schema counts (expect: GOV=5, RAW=12, TRANSFORM=15, ANALYTICS=15, AI_READY=12)
SELECT 'MEDICORE_GOVERNANCE_DB' AS DATABASE_NAME, COUNT(*) AS SCHEMA_COUNT
FROM MEDICORE_GOVERNANCE_DB.INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC')
UNION ALL
SELECT 'MEDICORE_RAW_DB', COUNT(*)
FROM MEDICORE_RAW_DB.INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC')
UNION ALL
SELECT 'MEDICORE_TRANSFORM_DB', COUNT(*)
FROM MEDICORE_TRANSFORM_DB.INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC')
UNION ALL
SELECT 'MEDICORE_ANALYTICS_DB', COUNT(*)
FROM MEDICORE_ANALYTICS_DB.INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC')
UNION ALL
SELECT 'MEDICORE_AI_READY_DB', COUNT(*)
FROM MEDICORE_AI_READY_DB.INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC')
ORDER BY DATABASE_NAME;

-- Verify transient schemas
SELECT CATALOG_NAME, SCHEMA_NAME, IS_TRANSIENT
FROM MEDICORE_RAW_DB.INFORMATION_SCHEMA.SCHEMATA
WHERE IS_TRANSIENT = 'YES';

-- Verify database grants
SHOW GRANTS ON DATABASE MEDICORE_ANALYTICS_DB;

-- Verify future grants
SHOW FUTURE GRANTS IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL;
```

## Transient Schemas

The following AUDIT schemas are transient (no Time Travel or Fail-safe) to reduce costs for high-volume write operations:

| Database | Transient Schemas |
|----------|-------------------|
| `MEDICORE_RAW_DB` | PROD_AUDIT, QA_AUDIT, DEV_AUDIT |
| `MEDICORE_TRANSFORM_DB` | PROD_AUDIT, QA_AUDIT, DEV_AUDIT |

## Dependencies

### Required By
- **Phase 05:** Resource monitors reference databases for cost allocation
- **Phase 08:** Governance tags and policies applied to schemas and tables
- **Phase 11:** Medallion architecture populates schemas with Dynamic Tables
- **Phase 12:** HCLS data model creates tables in these schemas

### Deferred Configuration
- **Phase 08:** Governance tag application
- **Phase 11:** Dynamic Table creation

## Summary

| Metric | Count |
|--------|-------|
| Databases | 5 |
| Total Schemas | 59 |
| PROD Schemas | 21 |
| QA Schemas | 19 |
| DEV Schemas | 19 |
| Transient Schemas | 6 |
| Database Grants | 50+ |
| Future Grants | 100+ |

## Next Phase

Proceed to **[Phase 05: Resource Monitors](05_phase_resource_monitors.md)** to configure cost controls and credit quotas.
