# Phase 03: Warehouse Management

## Overview

Phase 03 creates four workload-specific virtual warehouses with appropriate sizing, timeout configurations, and query acceleration settings. This phase also grants warehouse privileges to all 18 roles established in Phase 02.

**Script:** `infrastructure/03_warehouses/03_warehouse_management.sql`  
**Version:** 2.0.0  
**Required Role:** ACCOUNTADMIN  
**Estimated Execution Time:** 2-3 minutes

## Prerequisites

- [ ] Phase 01 completed
- [ ] Phase 02 Sections 1-5 completed (all 18 roles exist)

## Warehouses Created

| Warehouse | Size | Purpose | Primary Users |
|-----------|------|---------|---------------|
| `MEDICORE_ADMIN_WH` | X-Small | Administrative queries, metadata ops, audit | Platform Admin, Compliance Officer |
| `MEDICORE_ETL_WH` | Medium | Data ingestion, transformation, CI/CD | Data Engineer, ETL Loader, GitHub Actions |
| `MEDICORE_ANALYTICS_WH` | Small | Business analytics, dashboards, reporting | Clinical, Billing, Analyst, Executive roles |
| `MEDICORE_ML_WH` | Large | Machine learning, AI workloads, Cortex | Data Scientist, Data Engineer |

## Warehouse Configuration Details

### MEDICORE_ADMIN_WH

| Setting | Value | Rationale |
|---------|-------|-----------|
| Size | X-SMALL | Lightweight metadata queries |
| Auto-Suspend | 60 seconds | Minimize idle costs |
| Auto-Resume | TRUE | Automatic activation |
| Query Acceleration | OFF | Not needed for simple queries |
| Statement Timeout | 1800s (30 min) | Prevent runaway admin queries |
| Queue Timeout | 600s (10 min) | Quick failure for blocked queries |

### MEDICORE_ETL_WH

| Setting | Value | Rationale |
|---------|-------|-----------|
| Size | MEDIUM | Batch transformation workloads |
| Auto-Suspend | 300 seconds | Allow pipeline continuity |
| Auto-Resume | TRUE | Automatic activation |
| Query Acceleration | OFF | Predictable ETL patterns |
| Statement Timeout | 7200s (2 hours) | Long-running batch jobs |
| Queue Timeout | 1800s (30 min) | Patient queue for batches |

### MEDICORE_ANALYTICS_WH

| Setting | Value | Rationale |
|---------|-------|-----------|
| Size | SMALL | Interactive query workloads |
| Auto-Suspend | 120 seconds | Balance cost and UX |
| Auto-Resume | TRUE | Automatic activation |
| Query Acceleration | ON (4x) | Ad-hoc analytics acceleration |
| Statement Timeout | 3600s (1 hour) | Complex report generation |
| Queue Timeout | 900s (15 min) | Reasonable wait for users |

### MEDICORE_ML_WH

| Setting | Value | Rationale |
|---------|-------|-----------|
| Size | LARGE | Compute-intensive ML training |
| Auto-Suspend | 300 seconds | Iterative ML workflows |
| Auto-Resume | TRUE | Automatic activation |
| Query Acceleration | ON (8x) | Large dataset scans |
| Statement Timeout | 14400s (4 hours) | Model training jobs |
| Queue Timeout | 1800s (30 min) | Allow complex job queueing |

## Warehouse Grants Summary

### MEDICORE_ADMIN_WH (5 grants)

| Role | USAGE | OPERATE | MODIFY |
|------|:-----:|:-------:|:------:|
| `MEDICORE_PLATFORM_ADMIN` | ✓ | ✓ | ✓ |
| `MEDICORE_COMPLIANCE_OFFICER` | ✓ | ✓ | |

### MEDICORE_ETL_WH (10 grants)

| Role | USAGE | OPERATE | MODIFY |
|------|:-----:|:-------:|:------:|
| `MEDICORE_DATA_ENGINEER` | ✓ | ✓ | ✓ |
| `MEDICORE_PLATFORM_ADMIN` | ✓ | ✓ | ✓ |
| `MEDICORE_SVC_ETL_LOADER` | ✓ | ✓ | |
| `MEDICORE_SVC_GITHUB_ACTIONS` | ✓ | ✓ | |

### MEDICORE_ANALYTICS_WH (16 grants)

| Role | USAGE | OPERATE | MODIFY |
|------|:-----:|:-------:|:------:|
| `MEDICORE_PLATFORM_ADMIN` | ✓ | ✓ | ✓ |
| `MEDICORE_DATA_ENGINEER` | ✓ | | |
| `MEDICORE_CLINICAL_PHYSICIAN` | ✓ | | |
| `MEDICORE_CLINICAL_NURSE` | ✓ | | |
| `MEDICORE_CLINICAL_READER` | ✓ | | |
| `MEDICORE_BILLING_SPECIALIST` | ✓ | | |
| `MEDICORE_BILLING_READER` | ✓ | | |
| `MEDICORE_ANALYST_PHI` | ✓ | | |
| `MEDICORE_ANALYST_RESTRICTED` | ✓ | | |
| `MEDICORE_COMPLIANCE_OFFICER` | ✓ | | |
| `MEDICORE_EXT_AUDITOR` | ✓ | | |
| `MEDICORE_EXECUTIVE` | ✓ | | |
| `MEDICORE_APP_STREAMLIT` | ✓ | | |
| `MEDICORE_REFERENCE_READER` | ✓ | | |

### MEDICORE_ML_WH (5 grants)

| Role | USAGE | OPERATE | MODIFY |
|------|:-----:|:-------:|:------:|
| `MEDICORE_PLATFORM_ADMIN` | ✓ | ✓ | ✓ |
| `MEDICORE_DATA_SCIENTIST` | ✓ | ✓ | |
| `MEDICORE_DATA_ENGINEER` | ✓ | | |

## Privilege Definitions

| Privilege | Description |
|-----------|-------------|
| **USAGE** | Execute queries using the warehouse |
| **OPERATE** | Start, stop, suspend, and resume the warehouse |
| **MODIFY** | Change warehouse size and configuration |

## Execution

```sql
-- Execute as ACCOUNTADMIN
USE ROLE ACCOUNTADMIN;

-- Run the script
-- infrastructure/03_warehouses/03_warehouse_management.sql
```

## Verification Queries

```sql
-- Verify all 4 warehouses exist
SHOW WAREHOUSES LIKE 'MEDICORE%';

-- Verify warehouse configurations
SELECT 
    name,
    size,
    auto_suspend,
    auto_resume,
    enable_query_acceleration,
    query_acceleration_max_scale_factor
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

-- Verify grants per warehouse
SHOW GRANTS ON WAREHOUSE MEDICORE_ADMIN_WH;
SHOW GRANTS ON WAREHOUSE MEDICORE_ETL_WH;
SHOW GRANTS ON WAREHOUSE MEDICORE_ANALYTICS_WH;
SHOW GRANTS ON WAREHOUSE MEDICORE_ML_WH;

-- Count total grants (expect 36)
SELECT COUNT(*) AS total_grants
FROM (
    SELECT * FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
);
```

## Edition Compatibility

| Feature | Standard | Enterprise | Business Critical |
|---------|:--------:|:----------:|:-----------------:|
| Single-cluster warehouses | ✓ | ✓ | ✓ |
| Multi-cluster warehouses | | ✓ | ✓ |
| Query Acceleration | ✓ | ✓ | ✓ |

> **Note:** This script uses single-cluster warehouses for Standard Edition compatibility. Multi-cluster warehouses (MIN/MAX_CLUSTER_COUNT > 1) require Enterprise Edition or higher.

## Cost Optimization Features

| Feature | Warehouse | Setting |
|---------|-----------|---------|
| Aggressive auto-suspend | ADMIN_WH | 60 seconds |
| Query acceleration | ANALYTICS_WH, ML_WH | Reduces scan time |
| Initially suspended | All | No startup costs |
| Right-sized | All | Matched to workload |

## Deferred Configuration

### Phase 05: Resource Monitors
- `MEDICORE_ACCOUNT_MONITOR` (account-level)
- `MEDICORE_ADMIN_WH_MONITOR`
- `MEDICORE_ETL_WH_MONITOR`
- `MEDICORE_ANALYTICS_WH_MONITOR`
- `MEDICORE_ML_WH_MONITOR`

> **WARNING:** Warehouses operate without credit quotas until Phase 05 is executed.

### Phase 08: Data Governance
- Governance tags applied to all warehouses
- `ALTER WAREHOUSE SET TAG` statements

## Summary

| Metric | Count |
|--------|-------|
| Warehouses Created | 4 |
| Total Privilege Grants | 36 |
| Roles with USAGE | 16 |
| Roles with OPERATE | 6 |
| Roles with MODIFY | 3 |

## Next Phase

Proceed to **[Phase 04: Database Structure](04_phase_database_structure.md)** to create databases and schemas.
