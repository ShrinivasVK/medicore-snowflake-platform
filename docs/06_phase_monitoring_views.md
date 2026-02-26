# Phase 06: Monitoring Views

## Overview

Phase 06 creates monitoring views to provide visibility into credit usage, warehouse utilization, query performance, resource monitor consumption, and cost attribution. All views are centralized in the `MEDICORE_GOVERNANCE_DB.AUDIT` schema.

**Script:** `infrastructure/06_monitoring/06_monitoring_views.sql`  
**Version:** 2.0.0  
**Required Role:** ACCOUNTADMIN  
**Estimated Execution Time:** 1-2 minutes

## Prerequisites

- [ ] Phase 01 completed (`MEDICORE_GOVERNANCE_DB` exists)
- [ ] Phase 04 completed (`AUDIT` schema exists)
- [ ] Phase 02 completed (PLATFORM_ADMIN and COMPLIANCE_OFFICER roles exist)

## Data Latency Notice

All views pull from `SNOWFLAKE.ACCOUNT_USAGE`, which has inherent latency:

| View Category | Data Latency |
|---------------|--------------|
| Query views | Up to 45 minutes |
| Warehouse/Resource views | Up to 3 hours |

> **Tip:** For real-time metrics, use `INFORMATION_SCHEMA` views instead.

## Views Created (8 Total)

### Section 1: Warehouse Credit Monitoring

#### V_WAREHOUSE_CREDIT_USAGE

**Purpose:** Detailed credit usage by warehouse with time windows

| Column | Description |
|--------|-------------|
| `WAREHOUSE_NAME` | Warehouse identifier |
| `START_TIME` / `END_TIME` | Metering window |
| `CREDITS_USED_COMPUTE` | Compute credits consumed |
| `CREDITS_USED_CLOUD_SERVICES` | Cloud services credits |
| `TOTAL_CREDITS` | Sum of compute + cloud services |
| `PERCENTAGE_OF_MONTH` | Warehouse share of monthly total |
| `USAGE_MONTH` | Month bucket for aggregation |

**Retention:** 90 days of history

---

### Section 2: Query Monitoring

#### V_QUERY_PERFORMANCE

**Purpose:** Query execution metrics for performance analysis

| Column | Description |
|--------|-------------|
| `QUERY_ID` | Unique query identifier |
| `QUERY_TEXT` | SQL statement (may be truncated) |
| `USER_NAME` / `ROLE_NAME` | Execution context |
| `WAREHOUSE_NAME` / `WAREHOUSE_SIZE` | Compute resource used |
| `EXECUTION_TIME_SECONDS` | Total elapsed time |
| `COMPILE_TIME_SECONDS` | Query compilation time |
| `QUEUED_TIME_SECONDS` | Time waiting in queue |
| `BYTES_SCANNED` / `ROWS_PRODUCED` | Data volume metrics |
| `PARTITIONS_SCANNED` / `PARTITIONS_TOTAL` | Partition pruning efficiency |
| `PARTITION_SCAN_PERCENTAGE` | % of partitions scanned (lower = better pruning) |
| `CREDITS_USED` | Cloud services credits |

**Retention:** 30 days of history

---

#### V_LONG_RUNNING_QUERIES

**Purpose:** Queries exceeding 5 minutes execution time

| Column | Description |
|--------|-------------|
| `QUERY_ID` | Unique query identifier |
| `QUERY_TEXT` | SQL statement |
| `EXECUTION_TIME_SECONDS` | Total elapsed time |
| `EXECUTION_TIME_MINUTES` | Elapsed time in minutes |
| `USER_NAME` / `ROLE_NAME` | Who ran the query |
| `PARTITIONS_SCANNED` / `PARTITIONS_TOTAL` | Pruning efficiency |

**Threshold:** > 300,000 ms (5 minutes)  
**Use Cases:**
- Optimization targeting
- Runaway query detection
- User training needs identification

---

#### V_FAILED_QUERIES

**Purpose:** Queries with errors for troubleshooting

| Column | Description |
|--------|-------------|
| `QUERY_ID` | Unique query identifier |
| `QUERY_TEXT` | SQL statement that failed |
| `ERROR_CODE` | Snowflake error code |
| `ERROR_MESSAGE` | Detailed error description |
| `USER_NAME` / `ROLE_NAME` | Who encountered the error |
| `EXECUTION_STATUS` | Failure status |

**Retention:** 30 days of history

---

### Section 3: Resource Monitor Tracking

#### V_RESOURCE_MONITOR_STATUS

**Purpose:** Resource monitor consumption and thresholds

| Column | Description |
|--------|-------------|
| `MONITOR_NAME` | Resource monitor identifier |
| `CREDIT_QUOTA` | Monthly credit limit |
| `USED_CREDITS` | Credits consumed this period |
| `REMAINING_CREDITS` | Credits available |
| `PERCENTAGE_USED` | Current consumption % |
| `RESET_FREQUENCY` | MONTHLY |
| `PERIOD_START` / `PERIOD_END` | Current billing period |
| `SUSPEND_TRIGGER_PERCENT` | Threshold for SUSPEND action |
| `NOTIFY_TRIGGER_PERCENT` | Threshold for NOTIFY action |
| `HEALTH_STATUS` | HEALTHY / MODERATE / WARNING / CRITICAL |

**Health Status Thresholds:**

| Status | Percentage Used |
|--------|-----------------|
| HEALTHY | < 50% |
| MODERATE | 50% - 74% |
| WARNING | 75% - 89% |
| CRITICAL | ≥ 90% |

---

### Section 4: Capacity & Load Monitoring

#### V_WAREHOUSE_UTILIZATION

**Purpose:** Warehouse utilization metrics over time

| Column | Description |
|--------|-------------|
| `WAREHOUSE_NAME` | Warehouse identifier |
| `AVG_QUERIES_RUNNING` | Average concurrent queries |
| `AVG_QUERIES_QUEUED` | Average queries waiting |
| `AVG_QUERIES_PROVISIONING` | Queries waiting for cluster startup |
| `AVG_QUERIES_BLOCKED` | Blocked queries (locks, etc.) |
| `TOTAL_LOAD` | Sum of running + queued + provisioning |
| `LOAD_STATUS` | NORMAL / HIGH_LOAD / HIGH_QUEUE / BLOCKED |
| `HOUR_BUCKET` | Hourly aggregation for trending |

**Load Status Logic:**

| Status | Condition |
|--------|-----------|
| HIGH_QUEUE | AVG_QUEUED_LOAD > 5 |
| HIGH_LOAD | AVG_RUNNING > 10 |
| BLOCKED | AVG_BLOCKED > 0 |
| NORMAL | Otherwise |

**Retention:** 30 days of history

---

#### V_ACTIVE_WAREHOUSE_LOAD

**Purpose:** Current warehouse load snapshot (last 24 hours)

| Column | Description |
|--------|-------------|
| `WAREHOUSE_NAME` | Warehouse identifier |
| `SAMPLE_COUNT` | Number of data points |
| `AVG_QUERIES_RUNNING` | Average concurrent queries |
| `AVG_QUERIES_QUEUED` | Average queries waiting |
| `AVG_QUERIES_BLOCKED` | Average blocked queries |
| `PEAK_QUERIES_RUNNING` | Maximum concurrent queries |
| `PEAK_QUERIES_QUEUED` | Maximum queued queries |
| `PERIOD_START` / `PERIOD_END` | Observation window |

**Time Window:** Last 24 hours

---

### Section 5: Monthly Cost Aggregations

#### V_COST_BY_WAREHOUSE_MONTH

**Purpose:** Monthly credit costs by warehouse for budgeting

| Column | Description |
|--------|-------------|
| `WAREHOUSE_NAME` | Warehouse identifier |
| `USAGE_MONTH` | Month bucket |
| `CREDITS_USED_COMPUTE` | Compute credits |
| `CREDITS_USED_CLOUD_SERVICES` | Cloud services credits |
| `TOTAL_CREDITS` | Combined credits |
| `ACTIVE_DAYS` | Days with warehouse activity |
| `AVG_CREDITS_PER_DAY` | Average daily consumption |
| `ESTIMATED_COST_USD` | Estimated cost at $3.00/credit |

**Retention:** 12 months of history  
**Cost Assumption:** $3.00 per credit (Standard Edition)

> **Note:** Adjust `ESTIMATED_COST_USD` calculation if using Enterprise ($4.00) or Business Critical ($5.50) pricing.

---

## Security Model

### Access Grants

| View | PLATFORM_ADMIN | COMPLIANCE_OFFICER | Other Roles |
|------|:--------------:|:------------------:|:-----------:|
| V_WAREHOUSE_CREDIT_USAGE | ✓ | ✓ | ✗ |
| V_QUERY_PERFORMANCE | ✓ | ✓ | ✗ |
| V_LONG_RUNNING_QUERIES | ✓ | ✓ | ✗ |
| V_FAILED_QUERIES | ✓ | ✓ | ✗ |
| V_RESOURCE_MONITOR_STATUS | ✓ | ✓ | ✗ |
| V_WAREHOUSE_UTILIZATION | ✓ | ✓ | ✗ |
| V_ACTIVE_WAREHOUSE_LOAD | ✓ | ✓ | ✗ |
| V_COST_BY_WAREHOUSE_MONTH | ✓ | ✓ | ✗ |

> **Security Note:** These views expose operational metadata only. They are **not accessible** to clinical, billing, analyst, or executive roles.

---

## Execution

```sql
-- Execute as ACCOUNTADMIN
USE ROLE ACCOUNTADMIN;
USE DATABASE MEDICORE_GOVERNANCE_DB;
USE SCHEMA MEDICORE_GOVERNANCE_DB.AUDIT;

-- Run the script
-- infrastructure/06_monitoring/06_monitoring_views.sql
```

## Verification Queries

```sql
-- List all monitoring views (expect 8)
SHOW VIEWS IN SCHEMA MEDICORE_GOVERNANCE_DB.AUDIT;

-- Verify credit usage view
SELECT * FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_WAREHOUSE_CREDIT_USAGE
LIMIT 10;

-- Check resource monitor health
SELECT 
    MONITOR_NAME,
    CREDIT_QUOTA,
    USED_CREDITS,
    PERCENTAGE_USED,
    HEALTH_STATUS
FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_RESOURCE_MONITOR_STATUS;

-- Review long-running queries
SELECT 
    QUERY_ID,
    USER_NAME,
    WAREHOUSE_NAME,
    EXECUTION_TIME_MINUTES,
    PARTITION_SCAN_PERCENTAGE
FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_LONG_RUNNING_QUERIES
ORDER BY EXECUTION_TIME_MINUTES DESC
LIMIT 10;

-- Monthly cost summary
SELECT * FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_COST_BY_WAREHOUSE_MONTH
WHERE USAGE_MONTH >= DATE_TRUNC('MONTH', CURRENT_DATE());

-- Verify grants
SHOW GRANTS ON VIEW MEDICORE_GOVERNANCE_DB.AUDIT.V_WAREHOUSE_CREDIT_USAGE;
```

## Sample Use Cases

### 1. Identify Optimization Candidates

```sql
SELECT 
    USER_NAME,
    COUNT(*) AS LONG_QUERY_COUNT,
    ROUND(AVG(EXECUTION_TIME_MINUTES), 2) AS AVG_MINUTES
FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_LONG_RUNNING_QUERIES
GROUP BY USER_NAME
ORDER BY LONG_QUERY_COUNT DESC;
```

### 2. Monitor Cost Trends

```sql
SELECT 
    USAGE_MONTH,
    SUM(TOTAL_CREDITS) AS MONTHLY_CREDITS,
    SUM(ESTIMATED_COST_USD) AS MONTHLY_COST_USD
FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_COST_BY_WAREHOUSE_MONTH
GROUP BY USAGE_MONTH
ORDER BY USAGE_MONTH DESC;
```

### 3. Detect Capacity Issues

```sql
SELECT *
FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_WAREHOUSE_UTILIZATION
WHERE LOAD_STATUS != 'NORMAL'
ORDER BY START_TIME DESC
LIMIT 20;
```

---

## Summary

| Metric | Count |
|--------|-------|
| Views Created | 8 |
| SELECT Grants Issued | 16 |
| Roles with Access | 2 |
| Data Retention (Query) | 30 days |
| Data Retention (Credit) | 90 days |
| Data Retention (Cost) | 12 months |

## Next Phase

Proceed to **[Phase 07: Alerts](07_phase_alerts.md)** to configure automated alerting for cost and performance thresholds.
