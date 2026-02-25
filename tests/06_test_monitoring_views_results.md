# Phase 06 - Monitoring Views: Test Results

**Project:** MediCore Health Systems  
**Phase:** 06 - Monitoring Views  
**Test File:** 06_test_monitoring_views.sql  
**Executed By:** Cortex Code  
**Execution Date:** 2026-02-25  
**Overall Status:** [x] PASS  [ ] FAIL  [ ] PARTIAL

---

## Results Summary

| Category | Total | Pass | Fail | Pass Rate |
|----------|-------|------|------|-----------|
| VIEW EXISTENCE | 8 | 8 | 0 | 100% |
| SCHEMA VALIDATION | 1 | 1 | 0 | 100% |
| VIEW DEFINITION | 3 | 3 | 0 | 100% |
| COLUMN VALIDATION | 8 | 8 | 0 | 100% |
| EXECUTION VALIDATION | 5 | 5 | 0 | 100% |
| SECURITY GRANTS | 4 | 4 | 0 | 100% |
| NEGATIVE TESTS | 4 | 4 | 0 | 100% |
| DRIFT DETECTION | 1 | 1 | 0 | 100% |
| OWNERSHIP | 1 | 1 | 0 | 100% |
| **TOTAL** | **35** | **35** | **0** | **100%** |

---

## Detailed Results

### Section 1: View Existence Tests (8/8 Passed)

| Test ID | Description | Expected | Actual | Result |
|---------|-------------|----------|--------|--------|
| TC_06_001 | V_WAREHOUSE_CREDIT_USAGE exists | EXISTS | EXISTS | ✅ PASS |
| TC_06_002 | V_QUERY_PERFORMANCE exists | EXISTS | EXISTS | ✅ PASS |
| TC_06_003 | V_LONG_RUNNING_QUERIES exists | EXISTS | EXISTS | ✅ PASS |
| TC_06_004 | V_FAILED_QUERIES exists | EXISTS | EXISTS | ✅ PASS |
| TC_06_005 | V_RESOURCE_MONITOR_STATUS exists | EXISTS | EXISTS | ✅ PASS |
| TC_06_006 | V_WAREHOUSE_UTILIZATION exists | EXISTS | EXISTS | ✅ PASS |
| TC_06_007 | V_ACTIVE_WAREHOUSE_LOAD exists | EXISTS | EXISTS | ✅ PASS |
| TC_06_008 | V_COST_BY_WAREHOUSE_MONTH exists | EXISTS | EXISTS | ✅ PASS |

### Section 2: Schema Validation (1/1 Passed)

| Test ID | Description | Expected | Actual | Result |
|---------|-------------|----------|--------|--------|
| TC_06_009 | All views in AUDIT schema | 8 | 8 | ✅ PASS |

### Section 3: View Definition Validation (3/3 Passed)

| Test ID | Description | Expected | Actual | Result |
|---------|-------------|----------|--------|--------|
| TC_06_010 | V_WAREHOUSE_CREDIT_USAGE references ACCOUNT_USAGE | CONTAINS | CONTAINS | ✅ PASS |
| TC_06_011 | V_QUERY_PERFORMANCE references ACCOUNT_USAGE | CONTAINS | CONTAINS | ✅ PASS |
| TC_06_012 | V_RESOURCE_MONITOR_STATUS references ACCOUNT_USAGE | CONTAINS | CONTAINS | ✅ PASS |

### Section 4: Column Validation (8/8 Passed)

| Test ID | View | Column | Result |
|---------|------|--------|--------|
| TC_06_013 | V_WAREHOUSE_CREDIT_USAGE | WAREHOUSE_NAME | ✅ PASS |
| TC_06_014 | V_WAREHOUSE_CREDIT_USAGE | TOTAL_CREDITS | ✅ PASS |
| TC_06_015 | V_WAREHOUSE_CREDIT_USAGE | CREATED_AT | ✅ PASS |
| TC_06_016 | V_QUERY_PERFORMANCE | QUERY_ID | ✅ PASS |
| TC_06_017 | V_QUERY_PERFORMANCE | EXECUTION_TIME_SECONDS | ✅ PASS |
| TC_06_018 | V_RESOURCE_MONITOR_STATUS | MONITOR_NAME | ✅ PASS |
| TC_06_019 | V_RESOURCE_MONITOR_STATUS | HEALTH_STATUS | ✅ PASS |
| TC_06_020 | V_COST_BY_WAREHOUSE_MONTH | ESTIMATED_COST_USD | ✅ PASS |

### Section 5: Execution Validation (5/5 Passed)

| Test ID | View | Result |
|---------|------|--------|
| TC_06_021 | V_WAREHOUSE_CREDIT_USAGE | ✅ PASS |
| TC_06_022 | V_QUERY_PERFORMANCE | ✅ PASS |
| TC_06_023 | V_RESOURCE_MONITOR_STATUS | ✅ PASS |
| TC_06_024 | V_WAREHOUSE_UTILIZATION | ✅ PASS |
| TC_06_025 | V_COST_BY_WAREHOUSE_MONTH | ✅ PASS |

### Section 6: Security Grant Validation (4/4 Passed)

| Test ID | Description | Expected | Actual | Result |
|---------|-------------|----------|--------|--------|
| TC_06_026 | V_WAREHOUSE_CREDIT_USAGE SELECT to PLATFORM_ADMIN | GRANTED | GRANTED | ✅ PASS |
| TC_06_027 | V_WAREHOUSE_CREDIT_USAGE SELECT to COMPLIANCE_OFFICER | GRANTED | GRANTED | ✅ PASS |
| TC_06_028 | V_RESOURCE_MONITOR_STATUS SELECT to PLATFORM_ADMIN | GRANTED | GRANTED | ✅ PASS |
| TC_06_029 | V_COST_BY_WAREHOUSE_MONTH SELECT to COMPLIANCE_OFFICER | GRANTED | GRANTED | ✅ PASS |

### Section 7: Negative Tests - Unauthorized Access (4/4 Passed)

| Test ID | Description | Expected | Actual | Result |
|---------|-------------|----------|--------|--------|
| TC_06_030 | V_WAREHOUSE_CREDIT_USAGE NOT granted to ANALYST_PHI | NOT_GRANTED | NOT_GRANTED | ✅ PASS |
| TC_06_031 | V_WAREHOUSE_CREDIT_USAGE NOT granted to EXECUTIVE | NOT_GRANTED | NOT_GRANTED | ✅ PASS |
| TC_06_032 | V_WAREHOUSE_CREDIT_USAGE NOT granted to CLINICAL_PHYSICIAN | NOT_GRANTED | NOT_GRANTED | ✅ PASS |
| TC_06_033 | V_WAREHOUSE_CREDIT_USAGE NOT granted to BILLING_SPECIALIST | NOT_GRANTED | NOT_GRANTED | ✅ PASS |

### Section 8: Object Count Drift Detection (1/1 Passed)

| Test ID | Description | Expected | Actual | Result |
|---------|-------------|----------|--------|--------|
| TC_06_034 | Exactly 8 monitoring views exist | 8 | 8 | ✅ PASS |

### Section 9: Ownership Validation (1/1 Passed)

| Test ID | Description | Expected | Actual | Result |
|---------|-------------|----------|--------|--------|
| TC_06_035 | All views owned by ACCOUNTADMIN | 8 | 8 | ✅ PASS |

---

## Objects Verified

### Views Created (8 total)

| View | Purpose | Source | Status |
|------|---------|--------|--------|
| V_WAREHOUSE_CREDIT_USAGE | Credit consumption | WAREHOUSE_METERING_HISTORY | ✅ |
| V_QUERY_PERFORMANCE | Query metrics | QUERY_HISTORY | ✅ |
| V_LONG_RUNNING_QUERIES | Queries > 5 min | QUERY_HISTORY | ✅ |
| V_FAILED_QUERIES | Error tracking | QUERY_HISTORY | ✅ |
| V_RESOURCE_MONITOR_STATUS | Monitor consumption | RESOURCE_MONITORS | ✅ |
| V_WAREHOUSE_UTILIZATION | Load patterns | WAREHOUSE_LOAD_HISTORY | ✅ |
| V_ACTIVE_WAREHOUSE_LOAD | 24-hour snapshot | WAREHOUSE_LOAD_HISTORY | ✅ |
| V_COST_BY_WAREHOUSE_MONTH | Monthly costs | WAREHOUSE_METERING_HISTORY | ✅ |

### Security Grants Summary

| Role | SELECT Access | Status |
|------|---------------|--------|
| MEDICORE_PLATFORM_ADMIN | All 8 views | ✅ Granted |
| MEDICORE_COMPLIANCE_OFFICER | All 8 views | ✅ Granted |
| MEDICORE_ANALYST_PHI | None | ✅ Denied |
| MEDICORE_EXECUTIVE | None | ✅ Denied |
| MEDICORE_CLINICAL_PHYSICIAN | None | ✅ Denied |
| MEDICORE_BILLING_SPECIALIST | None | ✅ Denied |

---

## Data Latency Notes

| Source View | Latency |
|-------------|---------|
| QUERY_HISTORY | Up to 45 minutes |
| WAREHOUSE_METERING_HISTORY | Up to 3 hours |
| WAREHOUSE_LOAD_HISTORY | Up to 3 hours |
| RESOURCE_MONITORS | Up to 3 hours |

---

## Sign-off

| Item | Detail |
|------|--------|
| Phase | 06 - Monitoring Views |
| Total Tests Run | 35 |
| Total Passed | 35 |
| Total Failed | 0 |
| Issues Raised | 0 |
| Phase Status | ✅ COMPLETE |
| Signed Off By | Cortex Code |
| Sign-off Date | 2026-02-25 |
| Next Phase | 07 - Alerts |

---

*Test execution completed: 2026-02-25 by Cortex Code*
