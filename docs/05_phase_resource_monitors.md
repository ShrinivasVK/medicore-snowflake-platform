# Phase 05: Resource Monitors

## Overview

Phase 05 implements cost governance using Snowflake Resource Monitors. This phase creates one account-level monitor and three warehouse-level monitors to enforce credit consumption limits and prevent runaway costs.

**Script:** `infrastructure/05_resource-monitors/05_resource_monitors.sql`  
**Version:** 2.0.0  
**Required Role:** ACCOUNTADMIN  
**Estimated Execution Time:** 1-2 minutes

## Prerequisites

- [ ] Phase 02 completed (all 18 RBAC roles exist)
- [ ] Phase 03 completed (all 4 warehouses exist)

## Why Cost Controls Are Critical in HIPAA Environments

1. **Budget Predictability** — Essential for healthcare compliance
2. **Security Monitoring** — Runaway queries on PHI data can indicate security incidents
3. **Anomaly Detection** — Cost anomalies may signal unauthorized data access patterns
4. **Compliance Support** — Financial controls support SOC 2 and HITRUST requirements
5. **Operational Protection** — Prevents unexpected billing that could impact patient care IT budgets

## Layered Monitoring Strategy

```
┌─────────────────────────────────────────────────────────────────┐
│                  MEDICORE_ACCOUNT_MONITOR                       │
│                     500 credits/month                           │
│              (Hard cap on total platform spend)                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  ETL_MONITOR │  │ANALYTICS_MON │  │  ML_MONITOR  │          │
│  │ 200 credits  │  │ 150 credits  │  │ 100 credits  │          │
│  │     44%      │  │     33%      │  │     22%      │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
│         │                 │                 │                   │
│  ┌──────┴───────┐  ┌──────┴───────┐  ┌──────┴───────┐          │
│  │MEDICORE_ETL_WH│ │MEDICORE_     │  │MEDICORE_ML_WH│          │
│  │              │  │ANALYTICS_WH  │  │              │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                 │
│  ┌──────────────┐                                              │
│  │MEDICORE_     │  ← No monitor (emergency access)             │
│  │ADMIN_WH      │                                              │
│  └──────────────┘                                              │
└─────────────────────────────────────────────────────────────────┘
```

### Why Layered Monitoring?

| Layer | Purpose |
|-------|---------|
| **Account Monitor** | Financial safety net — hard cap on total platform spend |
| **Warehouse Monitors** | Granular control per workload type |

**Benefits:**
- One workload hitting quota does not affect others
- Enables workload-specific cost attribution and budgeting
- Provides early warning at both aggregate and granular levels

## Resource Monitors Created

### 1. MEDICORE_ACCOUNT_MONITOR (Account-Level)

| Setting | Value |
|---------|-------|
| Quota | 500 credits/month |
| Frequency | MONTHLY |
| Applied To | Entire Account |

**Triggers:**

| Threshold | Credits | Action |
|-----------|---------|--------|
| 50% | 250 | NOTIFY (early warning) |
| 75% | 375 | NOTIFY (warning) |
| 90% | 450 | NOTIFY (critical) |
| 100% | 500 | SUSPEND (block all warehouses) |

### 2. MEDICORE_ETL_MONITOR

| Setting | Value |
|---------|-------|
| Quota | 200 credits/month |
| Frequency | MONTHLY |
| Assigned To | `MEDICORE_ETL_WH` |

**Triggers:**

| Threshold | Credits | Action |
|-----------|---------|--------|
| 75% | 150 | NOTIFY |
| 90% | 180 | NOTIFY |
| 100% | 200 | SUSPEND |

**Rationale:** ETL pipelines are the highest sustained consumer. 200 credits sized for daily batch loads and Dynamic Table refreshes.

### 3. MEDICORE_ANALYTICS_MONITOR

| Setting | Value |
|---------|-------|
| Quota | 150 credits/month |
| Frequency | MONTHLY |
| Assigned To | `MEDICORE_ANALYTICS_WH` |

**Triggers:**

| Threshold | Credits | Action |
|-----------|---------|--------|
| 75% | 112.5 | NOTIFY |
| 90% | 135 | NOTIFY |
| 100% | 150 | SUSPEND |

**Rationale:** Serves clinical, billing, analysts, and executives. Query acceleration enabled reduces compute needs.

### 4. MEDICORE_ML_MONITOR

| Setting | Value |
|---------|-------|
| Quota | 100 credits/month |
| Frequency | MONTHLY |
| Assigned To | `MEDICORE_ML_WH` |

**Triggers:**

| Threshold | Credits | Action |
|-----------|---------|--------|
| 75% | 75 | NOTIFY |
| 90% | 90 | NOTIFY |
| 100% | 100 | SUSPEND |

**Rationale:** ML training is compute-intensive but infrequent. 100 credits provides headroom for model training cycles.

## ADMIN Warehouse Exclusion

`MEDICORE_ADMIN_WH` is **intentionally excluded** from resource monitoring.

**Reasons:**
- Must remain operational at all times for emergency access
- Platform administrators need to diagnose issues, adjust quotas, and perform emergency fixes
- Suspending the admin warehouse could prevent recovery from cost incidents
- Admin workloads are metadata-only and consume minimal credits

## Credit Allocation Summary

| Monitor | Credits | Percentage |
|---------|---------|------------|
| ETL | 200 | 44% |
| Analytics | 150 | 33% |
| ML | 100 | 22% |
| **Total Warehouse** | **450** | **100%** |
| **Account Cap** | **500** | — |

> **Note:** The 50-credit buffer between warehouse total (450) and account cap (500) provides headroom for the unmonitored ADMIN_WH and any temporary warehouse scaling.

## Notification Actions

When a NOTIFY trigger fires:
1. Notification sent to account administrators
2. Visible in Snowsight Resource Monitors dashboard
3. Can be integrated with email/webhook via notification integrations (Phase 07)

When a SUSPEND trigger fires:
1. No new queries can start on affected warehouse(s)
2. Currently running queries complete
3. Warehouse remains in SUSPENDED state until quota reset or manual override

## Execution

```sql
-- Execute as ACCOUNTADMIN
USE ROLE ACCOUNTADMIN;

-- Run the script
-- infrastructure/05_resource-monitors/05_resource_monitors.sql
```

## Verification Queries

```sql
-- List all resource monitors
SHOW RESOURCE MONITORS;

-- Verify warehouse assignments
SHOW WAREHOUSES LIKE 'MEDICORE_%';

-- Check current credit usage
SELECT 
    NAME,
    CREDIT_QUOTA,
    USED_CREDITS,
    REMAINING_CREDITS,
    LEVEL,
    FREQUENCY,
    START_TIME,
    END_TIME
FROM TABLE(INFORMATION_SCHEMA.RESOURCE_MONITORS());

-- Verify account-level monitor assignment
SHOW PARAMETERS LIKE 'RESOURCE_MONITOR' IN ACCOUNT;
```

## Adjusting Quotas

To modify a quota after initial deployment:

```sql
-- Increase ETL quota to 300 credits
ALTER RESOURCE MONITOR MEDICORE_ETL_MONITOR SET CREDIT_QUOTA = 300;

-- Increase account quota to 750 credits
ALTER RESOURCE MONITOR MEDICORE_ACCOUNT_MONITOR SET CREDIT_QUOTA = 750;

-- Resume a suspended warehouse (after quota adjustment)
ALTER WAREHOUSE MEDICORE_ETL_WH RESUME;
```

## Emergency Override

If a critical warehouse is suspended and operations must continue:

```sql
-- Option 1: Increase quota
ALTER RESOURCE MONITOR MEDICORE_ETL_MONITOR SET CREDIT_QUOTA = 300;
ALTER WAREHOUSE MEDICORE_ETL_WH RESUME;

-- Option 2: Remove monitor temporarily (use with caution)
ALTER WAREHOUSE MEDICORE_ETL_WH UNSET RESOURCE_MONITOR;
ALTER WAREHOUSE MEDICORE_ETL_WH RESUME;

-- Option 3: Use ADMIN_WH for emergency queries (always available)
USE WAREHOUSE MEDICORE_ADMIN_WH;
```

## Summary

| Metric | Count/Value |
|--------|-------------|
| Resource Monitors Created | 4 |
| Account-Level Monitor | 1 (500 credits) |
| Warehouse-Level Monitors | 3 (450 credits total) |
| Warehouses Monitored | 3 of 4 |
| Warehouse Excluded | MEDICORE_ADMIN_WH |
| Notify Triggers | 10 |
| Suspend Triggers | 4 |

## Next Phase

Proceed to **[Phase 06: Monitoring Views](06_phase_monitoring_views.md)** to create operational monitoring views.
