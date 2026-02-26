# Phase 07: Alerts

## Overview

Phase 07 implements automated Snowflake ALERT objects for proactive monitoring of credit usage, query performance, warehouse capacity, and cost governance. Alerts query Phase 06 monitoring views and send notifications via email using `SYSTEM$SEND_EMAIL`.

**Script:** `infrastructure/07_alerts/07_alerts.sql`  
**Version:** 2.0.0  
**Required Role:** ACCOUNTADMIN  
**Estimated Execution Time:** 1-2 minutes

## Prerequisites

- [ ] Phase 06 completed (all 8 monitoring views exist)
- [ ] Phase 03 completed (`MEDICORE_ADMIN_WH` exists)
- [ ] Phase 02 completed (`MEDICORE_PLATFORM_ADMIN` role exists)
- [ ] Email notification integration configured in Snowflake

## Alert Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           ALERT MONITORING FLOW                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────────────────┐     ┌─────────────────────┐     ┌───────────────┐│
│   │  SNOWFLAKE.         │     │  MONITORING VIEWS   │     │    ALERTS     ││
│   │  ACCOUNT_USAGE      │ ──► │  (Phase 06)         │ ──► │  (Phase 07)   ││
│   │                     │     │                     │     │               ││
│   │ • QUERY_HISTORY     │     │ • V_RESOURCE_MON... │     │ • RESOURCE_   ││
│   │ • WAREHOUSE_LOAD... │     │ • V_LONG_RUNNING... │     │   CRITICAL    ││
│   │ • RESOURCE_MONITORS │     │ • V_FAILED_QUERIES  │     │ • LONG_QUERY  ││
│   │ • METERING_HISTORY  │     │ • V_ACTIVE_WH_LOAD  │     │ • FAILED_SPIKE││
│   │                     │     │ • V_COST_BY_WH...   │     │ • HIGH_QUEUE  ││
│   └─────────────────────┘     └─────────────────────┘     │ • COST_SPIKE  ││
│                                                           └───────┬───────┘│
│                                                                   │        │
│                                                                   ▼        │
│                                                         ┌─────────────────┐│
│                                                         │ SYSTEM$SEND_    ││
│                                                         │ EMAIL           ││
│                                                         │                 ││
│                                                         │ platform-alerts@││
│                                                         │ medicore-health ││
│                                                         │ .com            ││
│                                                         └─────────────────┘│
└─────────────────────────────────────────────────────────────────────────────┘
```

## Alerts Created (5 Total)

### Section 1: Resource Monitor Alerts

#### ALERT_RESOURCE_MONITOR_CRITICAL

| Property | Value |
|----------|-------|
| **Purpose** | Detect resource monitors at ≥ 90% consumption |
| **Severity** | 🔴 CRITICAL |
| **Schedule** | Every 30 minutes (`0,30 * * * *`) |
| **Condition** | `PERCENTAGE_USED >= 90` |
| **Data Source** | `V_RESOURCE_MONITOR_STATUS` |
| **Action Required** | Immediate attention to prevent warehouse suspension |

**Notification Payload:**
- Monitor name and percentage used
- Credit quota and remaining credits
- Health status
- Recommended action

---

### Section 2: Query Alerts

#### ALERT_LONG_RUNNING_QUERY

| Property | Value |
|----------|-------|
| **Purpose** | Detect queries exceeding 5 minutes in last 15 min |
| **Severity** | 🟡 WARNING |
| **Schedule** | Every 15 minutes (`0,15,30,45 * * * *`) |
| **Condition** | Queries > 5 min in last 15 minutes |
| **Data Source** | `V_LONG_RUNNING_QUERIES` |
| **Action Required** | Review and optimize long-running queries |

**Notification Payload:**
- Count of long-running queries
- Sample of top 5 slowest queries (query_id, user, warehouse, execution time)
- Recommended action

---

#### ALERT_FAILED_QUERY_SPIKE

| Property | Value |
|----------|-------|
| **Purpose** | Detect > 10 failed queries in last 15 minutes |
| **Severity** | 🟡 WARNING |
| **Schedule** | Every 15 minutes (`0,15,30,45 * * * *`) |
| **Condition** | `failed_count > 10` |
| **Data Source** | `V_FAILED_QUERIES` |
| **Action Required** | Investigate error patterns |

**Notification Payload:**
- Total failed query count
- Error code summary with occurrence counts (top 5)
- Recommended action

---

### Section 3: Warehouse Capacity Alerts

#### ALERT_HIGH_WAREHOUSE_QUEUE

| Property | Value |
|----------|-------|
| **Purpose** | Detect warehouses with AVG_QUERIES_QUEUED > 5 |
| **Severity** | 🟡 WARNING |
| **Schedule** | Every 30 minutes (`0,30 * * * *`) |
| **Condition** | `AVG_QUERIES_QUEUED > 5` |
| **Data Source** | `V_ACTIVE_WAREHOUSE_LOAD` |
| **Action Required** | Consider scaling warehouse |

**Notification Payload:**
- Affected warehouse names
- Average and peak queued queries
- Average running queries
- Recommended action

---

### Section 4: Cost Governance Alerts

#### ALERT_MONTHLY_COST_SPIKE

| Property | Value |
|----------|-------|
| **Purpose** | Detect current month > 120% of previous month |
| **Severity** | 🔴 CRITICAL |
| **Schedule** | Daily at 08:00 UTC (`0 8 * * *`) |
| **Condition** | `current_month_credits > previous_month_credits * 1.2` |
| **Data Source** | `V_COST_BY_WAREHOUSE_MONTH` |
| **Action Required** | Review cost drivers immediately |

**Notification Payload:**
- Current month vs previous month credits
- Percentage increase
- Top 5 consuming warehouses
- Recommended action

---

## Alert Summary Table

| Alert | Severity | Schedule | Threshold |
|-------|----------|----------|-----------|
| `ALERT_RESOURCE_MONITOR_CRITICAL` | 🔴 CRITICAL | Every 30 min | ≥ 90% usage |
| `ALERT_LONG_RUNNING_QUERY` | 🟡 WARNING | Every 15 min | > 5 min queries |
| `ALERT_FAILED_QUERY_SPIKE` | 🟡 WARNING | Every 15 min | > 10 failures |
| `ALERT_HIGH_WAREHOUSE_QUEUE` | 🟡 WARNING | Every 30 min | > 5 queued avg |
| `ALERT_MONTHLY_COST_SPIKE` | 🔴 CRITICAL | Daily 08:00 UTC | > 120% MoM |

## Initial State

> **IMPORTANT:** All alerts are created in **SUSPENDED** state by default.

This allows you to:
1. Validate email notification configuration
2. Review alert conditions
3. Enable alerts individually or all at once

## Enabling Alerts

After validating configuration, enable alerts:

```sql
-- Enable all alerts
ALTER ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_RESOURCE_MONITOR_CRITICAL RESUME;
ALTER ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_LONG_RUNNING_QUERY RESUME;
ALTER ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_FAILED_QUERY_SPIKE RESUME;
ALTER ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_HIGH_WAREHOUSE_QUEUE RESUME;
ALTER ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_MONTHLY_COST_SPIKE RESUME;
```

Or enable selectively:

```sql
-- Enable only critical alerts first
ALTER ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_RESOURCE_MONITOR_CRITICAL RESUME;
ALTER ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_MONTHLY_COST_SPIKE RESUME;
```

## Disabling Alerts

To suspend an alert temporarily:

```sql
-- Suspend a specific alert
ALTER ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_LONG_RUNNING_QUERY SUSPEND;

-- Suspend all alerts (e.g., during maintenance)
ALTER ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_RESOURCE_MONITOR_CRITICAL SUSPEND;
ALTER ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_LONG_RUNNING_QUERY SUSPEND;
ALTER ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_FAILED_QUERY_SPIKE SUSPEND;
ALTER ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_HIGH_WAREHOUSE_QUEUE SUSPEND;
ALTER ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_MONTHLY_COST_SPIKE SUSPEND;
```

## Security Model

### Ownership

| Alert | Owner |
|-------|-------|
| All 5 alerts | ACCOUNTADMIN |

### Grants

| Role | Privilege | Can Do |
|------|-----------|--------|
| `MEDICORE_PLATFORM_ADMIN` | OPERATE | Resume, Suspend, Execute |

> **Note:** Clinical, billing, analyst, and executive roles have **no access** to alerts.

## Notification Configuration

**Target Email:** `platform-alerts@medicore-health.com`

### Notification Format

All alerts send JSON-structured payloads containing:
- `severity` — CRITICAL or WARNING
- `alert_name` — Alert identifier
- `event_timestamp` — When the alert fired
- `description` — Human-readable summary
- `affected_items` — Array of affected resources
- `recommended_action` — Suggested remediation

### Changing Notification Target

To update the email recipient, recreate the alert with the new email address in the `SYSTEM$SEND_EMAIL` call.

## Execution

```sql
-- Execute as ACCOUNTADMIN
USE ROLE ACCOUNTADMIN;
USE DATABASE MEDICORE_GOVERNANCE_DB;
USE SCHEMA MEDICORE_GOVERNANCE_DB.AUDIT;

-- Run the script
-- infrastructure/07_alerts/07_alerts.sql
```

## Verification Queries

```sql
-- List all alerts (expect 5)
SHOW ALERTS IN SCHEMA MEDICORE_GOVERNANCE_DB.AUDIT;

-- Check alert states
SELECT 
    NAME AS ALERT_NAME,
    STATE AS CURRENT_STATE,
    SCHEDULE AS SCHEDULE_CRON,
    OWNER AS OWNER_ROLE
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
ORDER BY NAME;

-- Verify grants to PLATFORM_ADMIN
SHOW GRANTS ON ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_RESOURCE_MONITOR_CRITICAL;

-- View alert execution history (after enabling)
SELECT *
FROM TABLE(INFORMATION_SCHEMA.ALERT_HISTORY(
    SCHEDULED_TIME_RANGE_START => DATEADD('DAY', -1, CURRENT_TIMESTAMP()),
    SCHEDULED_TIME_RANGE_END => CURRENT_TIMESTAMP()
))
WHERE NAME LIKE 'ALERT_%'
ORDER BY SCHEDULED_TIME DESC;
```

## Manually Triggering Alerts

For testing purposes, you can manually execute an alert:

```sql
-- Execute alert immediately (requires OPERATE privilege)
EXECUTE ALERT MEDICORE_GOVERNANCE_DB.AUDIT.ALERT_RESOURCE_MONITOR_CRITICAL;
```

## Warehouse Usage

All alerts use `MEDICORE_ADMIN_WH` to ensure:
- Alerts execute even during cost-related warehouse suspensions
- Minimal credit consumption for monitoring overhead
- Consistent execution context

## Summary

| Metric | Count/Value |
|--------|-------------|
| Alerts Created | 5 |
| CRITICAL Severity | 2 |
| WARNING Severity | 3 |
| OPERATE Grants | 5 |
| Initial State | SUSPENDED |
| Warehouse | MEDICORE_ADMIN_WH |
| Notification Target | platform-alerts@medicore-health.com |

## Next Phase

Proceed to **[Phase 08: Data Governance](08_phase_data_governance.md)** to configure tags, masking policies, and row access policies.
