# Phase 10: Verification

## Overview

Phase 10 provides comprehensive verification of the entire MediCore platform deployment. This phase validates all infrastructure components created in Phases 01-09 and provides a deployment health scorecard for go-live readiness.

**Script:** `infrastructure/10_verification/10_verification.sql`  
**Version:** 1.0.0  
**Required Role:** ACCOUNTADMIN  
**Estimated Execution Time:** 3-5 minutes

## Prerequisites

- [ ] Phases 01-09 completed
- [ ] Access to ACCOUNTADMIN role
- [ ] All warehouses accessible

## Verification Categories

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PLATFORM VERIFICATION FRAMEWORK                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐             │
│  │   SECTION 1     │  │   SECTION 2     │  │   SECTION 3     │             │
│  │   Account &     │  │      RBAC       │  │   Warehouses    │             │
│  │   Security      │  │   Validation    │  │   & Resources   │             │
│  │  (Phase 01)     │  │  (Phase 02)     │  │  (Phase 03-05)  │             │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘             │
│           │                    │                    │                       │
│  ┌────────┴────────┐  ┌────────┴────────┐  ┌────────┴────────┐             │
│  │   SECTION 4     │  │   SECTION 5     │  │   SECTION 6     │             │
│  │   Database &    │  │   Monitoring    │  │   Governance    │             │
│  │   Schemas       │  │   & Alerting    │  │   & Audit       │             │
│  │  (Phase 04)     │  │  (Phase 06-07)  │  │  (Phase 08-09)  │             │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘             │
│           │                    │                    │                       │
│           └────────────────────┼────────────────────┘                       │
│                                │                                            │
│                       ┌────────┴────────┐                                   │
│                       │   SECTION 7     │                                   │
│                       │   DEPLOYMENT    │                                   │
│                       │   SCORECARD     │                                   │
│                       └─────────────────┘                                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Section 1: Account & Security Verification

### 1.1 Account Parameters

| Parameter | Expected Value | HIPAA Requirement |
|-----------|----------------|-------------------|
| `TIMEZONE` | America/Chicago | Consistent audit timestamps |
| `STATEMENT_TIMEOUT_IN_SECONDS` | 3600 | Query runaway prevention |
| `DATA_RETENTION_TIME_IN_DAYS` | 14 | Time Travel for recovery |
| `PERIODIC_DATA_REKEYING` | TRUE | §164.312(a)(2)(iv) Encryption |
| `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION` | TRUE | External stage governance |

```sql
-- Verify account parameters
SHOW PARAMETERS LIKE 'TIMEZONE' IN ACCOUNT;
SHOW PARAMETERS LIKE 'STATEMENT_TIMEOUT%' IN ACCOUNT;
SHOW PARAMETERS LIKE 'DATA_RETENTION%' IN ACCOUNT;
SHOW PARAMETERS LIKE 'PERIODIC_DATA_REKEYING' IN ACCOUNT;
```

### 1.2 Security Policies

| Policy Type | Name | Status |
|-------------|------|--------|
| Network Policy | `MEDICORE_NETWORK_POLICY` | Applied to account |
| Password Policy | `MEDICORE_PASSWORD_POLICY` | Applied to account |
| Session Policy | `MEDICORE_SESSION_POLICY` | Applied to account |

```sql
-- Verify network policy
SHOW NETWORK POLICIES LIKE 'MEDICORE%';
SHOW PARAMETERS LIKE 'NETWORK_POLICY' IN ACCOUNT;

-- Verify password policy
DESCRIBE PASSWORD POLICY MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_PASSWORD_POLICY;

-- Verify session policy  
DESCRIBE SESSION POLICY MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_SESSION_POLICY;
```

---

## Section 2: RBAC Verification

### 2.1 Role Count

| Category | Expected | Query |
|----------|----------|-------|
| Total MEDICORE roles | 18 | `SHOW ROLES LIKE 'MEDICORE%'` |
| Administrative | 1 | PLATFORM_ADMIN |
| Data Engineering | 2 | DATA_ENGINEER, SVC_ETL_LOADER |
| Clinical | 3 | PHYSICIAN, NURSE, READER |
| Revenue Cycle | 2 | BILLING_SPECIALIST, BILLING_READER |
| Analytics | 3 | ANALYST_PHI, ANALYST_RESTRICTED, DATA_SCIENTIST |
| Compliance | 2 | COMPLIANCE_OFFICER, EXT_AUDITOR |
| Executive/Base | 2 | EXECUTIVE, REFERENCE_READER |
| Application | 1 | APP_STREAMLIT |
| CI/CD | 1 | SVC_GITHUB_ACTIONS |

```sql
-- Count all MediCore roles
SELECT COUNT(*) AS role_count
FROM (SELECT * FROM TABLE(RESULT_SCAN(LAST_QUERY_ID())))
WHERE "name" LIKE 'MEDICORE%';

-- Verify role hierarchy
SHOW GRANTS OF ROLE MEDICORE_REFERENCE_READER;
SHOW GRANTS OF ROLE MEDICORE_ANALYST_PHI;
SHOW GRANTS OF ROLE MEDICORE_DATA_ENGINEER;
```

### 2.2 Service Accounts

| User | Default Role | Expected State |
|------|--------------|----------------|
| `SVC_ETL_MEDICORE` | MEDICORE_SVC_ETL_LOADER | DISABLED |
| `SVC_GITHUB_ACTIONS_MEDICORE` | MEDICORE_SVC_GITHUB_ACTIONS | DISABLED |

```sql
SHOW USERS LIKE 'SVC_%MEDICORE';
```

---

## Section 3: Warehouse & Resource Monitor Verification

### 3.1 Warehouses

| Warehouse | Size | Auto-Suspend | Query Acceleration |
|-----------|------|--------------|-------------------|
| `MEDICORE_ADMIN_WH` | X-SMALL | 60s | OFF |
| `MEDICORE_ETL_WH` | MEDIUM | 300s | OFF |
| `MEDICORE_ANALYTICS_WH` | SMALL | 120s | ON (4x) |
| `MEDICORE_ML_WH` | LARGE | 300s | ON (8x) |

```sql
SHOW WAREHOUSES LIKE 'MEDICORE%';

SELECT 
    NAME,
    SIZE,
    AUTO_SUSPEND,
    AUTO_RESUME,
    ENABLE_QUERY_ACCELERATION,
    QUERY_ACCELERATION_MAX_SCALE_FACTOR
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));
```

### 3.2 Resource Monitors

| Monitor | Quota | Assigned To |
|---------|-------|-------------|
| `MEDICORE_ACCOUNT_MONITOR` | 500 | Account |
| `MEDICORE_ETL_MONITOR` | 200 | MEDICORE_ETL_WH |
| `MEDICORE_ANALYTICS_MONITOR` | 150 | MEDICORE_ANALYTICS_WH |
| `MEDICORE_ML_MONITOR` | 100 | MEDICORE_ML_WH |

```sql
SHOW RESOURCE MONITORS;

SELECT 
    NAME,
    CREDIT_QUOTA,
    USED_CREDITS,
    REMAINING_CREDITS
FROM TABLE(INFORMATION_SCHEMA.RESOURCE_MONITORS());
```

---

## Section 4: Database & Schema Verification

### 4.1 Databases

| Database | Schema Count | Retention |
|----------|--------------|-----------|
| `MEDICORE_GOVERNANCE_DB` | 5 | Default |
| `MEDICORE_RAW_DB` | 12 | 90 days |
| `MEDICORE_TRANSFORM_DB` | 15 | 30 days |
| `MEDICORE_ANALYTICS_DB` | 15 | 30 days |
| `MEDICORE_AI_READY_DB` | 12 | 14 days |
| **Total** | **59** | |

```sql
SHOW DATABASES LIKE 'MEDICORE%';

-- Verify schema counts per database
SELECT 
    CATALOG_NAME AS DATABASE_NAME,
    COUNT(*) AS SCHEMA_COUNT
FROM SNOWFLAKE.INFORMATION_SCHEMA.SCHEMATA
WHERE CATALOG_NAME LIKE 'MEDICORE%'
AND SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC')
GROUP BY CATALOG_NAME
ORDER BY CATALOG_NAME;
```

### 4.2 Environment Schemas

Each data database should have DEV, QA, and PROD schemas per domain:

```sql
-- Verify environment schema pattern
SELECT 
    CATALOG_NAME,
    SUM(CASE WHEN SCHEMA_NAME LIKE 'DEV_%' THEN 1 ELSE 0 END) AS DEV_SCHEMAS,
    SUM(CASE WHEN SCHEMA_NAME LIKE 'QA_%' THEN 1 ELSE 0 END) AS QA_SCHEMAS,
    SUM(CASE WHEN SCHEMA_NAME LIKE 'PROD_%' THEN 1 ELSE 0 END) AS PROD_SCHEMAS
FROM SNOWFLAKE.INFORMATION_SCHEMA.SCHEMATA
WHERE CATALOG_NAME LIKE 'MEDICORE%'
AND CATALOG_NAME != 'MEDICORE_GOVERNANCE_DB'
GROUP BY CATALOG_NAME;
```

---

## Section 5: Monitoring & Alerting Verification

### 5.1 Monitoring Views

| Schema | Expected View Count |
|--------|---------------------|
| `MEDICORE_GOVERNANCE_DB.AUDIT` | 21 (8 monitoring + 13 audit) |

```sql
SHOW VIEWS IN SCHEMA MEDICORE_GOVERNANCE_DB.AUDIT;

SELECT COUNT(*) AS view_count
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_CATALOG = 'MEDICORE_GOVERNANCE_DB'
AND TABLE_SCHEMA = 'AUDIT';
```

### 5.2 Alerts

| Alert | Severity | Initial State |
|-------|----------|---------------|
| `ALERT_RESOURCE_MONITOR_CRITICAL` | CRITICAL | SUSPENDED |
| `ALERT_LONG_RUNNING_QUERY` | WARNING | SUSPENDED |
| `ALERT_FAILED_QUERY_SPIKE` | WARNING | SUSPENDED |
| `ALERT_HIGH_WAREHOUSE_QUEUE` | WARNING | SUSPENDED |
| `ALERT_MONTHLY_COST_SPIKE` | CRITICAL | SUSPENDED |

```sql
SHOW ALERTS IN SCHEMA MEDICORE_GOVERNANCE_DB.AUDIT;

SELECT NAME, STATE, SCHEDULE
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));
```

---

## Section 6: Governance & Audit Verification

### 6.1 Tags

| Category | Expected Count |
|----------|----------------|
| Total Tags | 13 |

```sql
SHOW TAGS IN SCHEMA MEDICORE_GOVERNANCE_DB.TAGS;

SELECT COUNT(*) AS tag_count
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));
```

### 6.2 Masking Policies

| Policy | Protection Level |
|--------|------------------|
| `MASK_DIRECT_IDENTIFIER` | HIPAA Safe Harbor |
| `MASK_QUASI_IDENTIFIER` | Re-identification prevention |
| `MASK_QUASI_IDENTIFIER_DATE` | Date generalization |
| `MASK_QUASI_IDENTIFIER_TIMESTAMP` | Timestamp generalization |
| `MASK_SENSITIVE_CLINICAL` | Clinical data protection |
| `MASK_42CFR_PART2` | Substance abuse records |
| `MASK_FINANCIAL_PII` | Financial account protection |

```sql
SHOW MASKING POLICIES IN SCHEMA MEDICORE_GOVERNANCE_DB.POLICIES;
```

### 6.3 Row Access Policies

| Policy | Purpose |
|--------|---------|
| `ROW_ACCESS_CLINICAL` | Clinical subdomain access |
| `ROW_ACCESS_ENVIRONMENT` | Environment-based PHI protection |
| `ROW_ACCESS_CONSENT` | Consent-based access |
| `ROW_ACCESS_DATA_QUALITY` | Data quality status filtering |

```sql
SHOW ROW ACCESS POLICIES IN SCHEMA MEDICORE_GOVERNANCE_DB.POLICIES;
```

---

## Section 7: Deployment Scorecard

### Automated Health Check Query

```sql
-- Generate deployment scorecard
WITH checks AS (
    -- Check 1: Databases
    SELECT 'Databases' AS category, 
           COUNT(*) AS actual, 
           5 AS expected
    FROM SNOWFLAKE.INFORMATION_SCHEMA.DATABASES
    WHERE DATABASE_NAME LIKE 'MEDICORE%'
    
    UNION ALL
    
    -- Check 2: Roles
    SELECT 'Roles', COUNT(*), 18
    FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
    WHERE NAME LIKE 'MEDICORE%' AND DELETED_ON IS NULL
    
    UNION ALL
    
    -- Check 3: Warehouses
    SELECT 'Warehouses', COUNT(*), 4
    FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES
    WHERE WAREHOUSE_NAME LIKE 'MEDICORE%' AND DELETED IS NULL
    
    UNION ALL
    
    -- Check 4: Resource Monitors
    SELECT 'Resource Monitors', COUNT(*), 4
    FROM TABLE(INFORMATION_SCHEMA.RESOURCE_MONITORS())
    WHERE NAME LIKE 'MEDICORE%'
    
    UNION ALL
    
    -- Check 5: Tags
    SELECT 'Tags', COUNT(*), 13
    FROM SNOWFLAKE.ACCOUNT_USAGE.TAGS
    WHERE TAG_DATABASE = 'MEDICORE_GOVERNANCE_DB' AND DELETED IS NULL
    
    UNION ALL
    
    -- Check 6: Masking Policies
    SELECT 'Masking Policies', COUNT(*), 7
    FROM SNOWFLAKE.ACCOUNT_USAGE.MASKING_POLICIES
    WHERE POLICY_CATALOG = 'MEDICORE_GOVERNANCE_DB' AND DELETED IS NULL
    
    UNION ALL
    
    -- Check 7: Row Access Policies
    SELECT 'Row Access Policies', COUNT(*), 4
    FROM SNOWFLAKE.ACCOUNT_USAGE.ROW_ACCESS_POLICIES
    WHERE POLICY_CATALOG = 'MEDICORE_GOVERNANCE_DB' AND DELETED IS NULL
)
SELECT 
    category,
    actual,
    expected,
    CASE WHEN actual >= expected THEN '✓ PASS' ELSE '✗ FAIL' END AS status,
    ROUND(actual * 100.0 / NULLIF(expected, 0), 1) AS completion_pct
FROM checks
ORDER BY category;
```

### Scorecard Interpretation

| Completion % | Status | Action |
|--------------|--------|--------|
| 100% | ✅ Ready | Proceed to Phase 11+ |
| 90-99% | ⚠️ Review | Identify missing components |
| < 90% | ❌ Incomplete | Re-run failed phases |

---

## Go-Live Readiness Checklist

### Infrastructure ✓

- [ ] All 5 databases created
- [ ] All 59 schemas created
- [ ] All 4 warehouses operational
- [ ] All 4 resource monitors configured
- [ ] Account-level policies applied

### Security ✓

- [ ] All 18 roles created
- [ ] Role hierarchy validated
- [ ] Service accounts created (disabled)
- [ ] Network policy applied
- [ ] Password policy applied
- [ ] Session policy applied

### Governance ✓

- [ ] All 13 tags created
- [ ] All 7 masking policies created
- [ ] All 4 row access policies created
- [ ] Compliance Officer has governance privileges

### Monitoring ✓

- [ ] All 8 monitoring views created
- [ ] All 13 audit views created
- [ ] All 5 alerts created (suspended)

### Documentation ✓

- [ ] All phase documentation complete
- [ ] RBAC design documented
- [ ] Tag taxonomy documented

---

## Post-Verification Actions

### If All Checks Pass

1. Proceed to **Phase 11** (Medallion Architecture)
2. Enable alerts as needed
3. Configure service account authentication
4. Update network policy with production IPs

### If Checks Fail

1. Review failed phase documentation
2. Re-execute failed phase script
3. Check for dependency issues
4. Verify role permissions

---

## Summary

| Verification Area | Checks |
|-------------------|--------|
| Account & Security | 8 |
| RBAC | 4 |
| Warehouses & Resources | 4 |
| Databases & Schemas | 3 |
| Monitoring & Alerts | 3 |
| Governance & Audit | 4 |
| **Total** | **26** |

## Next Phase

Upon successful verification, proceed to **[Phase 11: Medallion Architecture](11_phase_medallion_architecture.md)** to create the data transformation layer.
