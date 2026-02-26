# Phase 09: Audit & Compliance

## Overview

Phase 09 implements a comprehensive enterprise audit and compliance monitoring framework. This phase creates 13 audit views covering security events, PHI data access, governance changes, compliance monitoring, session activity, and user risk scoring.

**Script:** `infrastructure/09_audit/09_audit.sql`  
**Version:** 1.0.0  
**Required Role:** ACCOUNTADMIN  
**Estimated Execution Time:** 2-3 minutes

## Prerequisites

- [ ] Phase 01-08 completed
- [ ] `MEDICORE_GOVERNANCE_DB.AUDIT` schema exists
- [ ] Tags and policies deployed (Phase 08)
- [ ] `MEDICORE_COMPLIANCE_OFFICER` and `MEDICORE_PLATFORM_ADMIN` roles exist

## HIPAA Compliance Mapping

| HIPAA Requirement | Implementation |
|-------------------|----------------|
| §164.312(b) - Access Logging | V_PHI_DATA_ACCESS, V_42CFR_ACCESS_ATTEMPTS |
| §164.312(b) - Audit Controls | V_ADMIN_ACTIVITY, V_TAG_CHANGE_HISTORY |
| §164.312(d) - Authentication | V_LOGIN_HISTORY, V_SESSION_HISTORY |

## Data Source Latency

All views source from `SNOWFLAKE.ACCOUNT_USAGE`:

| View Category | Latency | Retention |
|---------------|---------|-----------|
| Login/Session | Up to 2-3 hours | 90 days |
| Query History | Up to 45 minutes | 365 days |
| Grants/Roles | Up to 3 hours | 365 days |
| Tag References | Up to 3 hours | 365 days |

## Audit Views Created (13 Total)

### Section 1: Security Event Views (3)

#### V_LOGIN_HISTORY

**Purpose:** Tracks all authentication attempts including successes and failures

| Column | Description |
|--------|-------------|
| `LOGIN_TIMESTAMP` | When login occurred |
| `USER_NAME` | Authenticating user |
| `CLIENT_IP` | Source IP address |
| `AUTH_METHOD` | Primary authentication factor |
| `MFA_METHOD` | Secondary factor (if used) |
| `LOGIN_STATUS` | SUCCESS, SUCCESS_MFA, or FAILED |
| `RISK_LEVEL` | HIGH (failed), MEDIUM (external IP), LOW |

**Retention:** 90 days

---

#### V_ROLE_GRANT_HISTORY

**Purpose:** Tracks role grants to users and role-to-role inheritance

| Column | Description |
|--------|-------------|
| `GRANT_TIMESTAMP` | When grant occurred |
| `GRANT_TYPE` | USER_GRANT or ROLE_GRANT |
| `GRANTED_ROLE` | Role being granted |
| `GRANTEE_NAME` | Recipient of grant |
| `GRANTED_BY` | Who performed the grant |
| `SENSITIVITY_LEVEL` | CRITICAL (system admin), HIGH, NORMAL |

**Retention:** 180 days

---

#### V_PRIVILEGE_ESCALATION_EVENTS

**Purpose:** Detects high-risk privilege grants that could indicate attacks

| Monitored Events | Severity |
|------------------|----------|
| ACCOUNTADMIN/ORGADMIN grants | CRITICAL |
| OWNERSHIP transfers | CRITICAL |
| SECURITYADMIN grants | HIGH |
| APPLY MASKING/ROW ACCESS/TAG grants | HIGH |

**Retention:** 180 days

---

### Section 2: Data Access Views (3)

#### V_PHI_DATA_ACCESS

**Purpose:** Tracks queries accessing PHI-tagged columns

| Column | Description |
|--------|-------------|
| `ACCESS_TIMESTAMP` | When query executed |
| `USER_NAME` / `ROLE_NAME` | Who accessed data |
| `TABLE_ACCESSED` / `COLUMN_ACCESSED` | What was accessed |
| `PHI_CLASSIFICATION` | DIRECT_IDENTIFIER, QUASI_IDENTIFIER, 42CFR_PART2 |
| `SENSITIVITY_LEVEL` | CRITICAL, HIGH, MEDIUM, LOW |
| `ACCESS_ASSESSMENT` | AUTHORIZED or POTENTIAL_VIOLATION |

**Retention:** 90 days

---

#### V_MASKING_POLICY_USAGE

**Purpose:** Shows which columns are protected by masking policies

| Column | Description |
|--------|-------------|
| `MASKING_POLICY_NAME` | Applied policy |
| `PROTECTED_DATABASE` / `PROTECTED_SCHEMA` / `PROTECTED_TABLE` | Object hierarchy |
| `PROTECTED_COLUMN` | Column with masking |
| `PROTECTION_LEVEL` | CRITICAL (42CFR), HIGH (direct/sensitive), STANDARD |

---

#### V_ROW_ACCESS_POLICY_USAGE

**Purpose:** Shows which tables have row-level security

| Column | Description |
|--------|-------------|
| `ROW_ACCESS_POLICY_NAME` | Applied policy |
| `PROTECTED_DATABASE` / `PROTECTED_SCHEMA` / `PROTECTED_TABLE` | Object hierarchy |
| `PROTECTION_LEVEL` | CRITICAL (consent), HIGH (clinical), MEDIUM, STANDARD |

---

### Section 3: Governance Change Views (2)

#### V_TAG_CHANGE_HISTORY

**Purpose:** Tracks all tag-related DDL operations

| Operation | Severity |
|-----------|----------|
| DROP TAG | CRITICAL |
| UNSET TAG | HIGH |
| ALTER TAG | MEDIUM |
| SET TAG | MEDIUM |
| CREATE TAG | LOW |

**Retention:** 180 days

---

#### V_POLICY_CHANGE_HISTORY

**Purpose:** Tracks masking and row access policy DDL

| Operation | Severity |
|-----------|----------|
| DROP MASKING POLICY / DROP ROW ACCESS POLICY | CRITICAL |
| ALTER MASKING POLICY / ALTER ROW ACCESS POLICY | HIGH |
| CREATE MASKING POLICY / CREATE ROW ACCESS POLICY | MEDIUM |

**Retention:** 180 days

---

### Section 4: Compliance Monitoring Views (2)

#### V_QUARANTINED_DATA_ACCESS_ATTEMPTS

**Purpose:** Detects access to data tagged as QUARANTINED

| Column | Description |
|--------|-------------|
| `ACCESS_TIMESTAMP` | When access occurred |
| `USER_NAME` / `ROLE_NAME` | Who accessed |
| `TABLE_ACCESSED` | Quarantined object |
| `ACCESS_ASSESSMENT` | REMEDIATION_ACCESS (engineers) or POTENTIAL_VIOLATION |

**Severity:** HIGH for all access  
**Retention:** 90 days

---

#### V_42CFR_ACCESS_ATTEMPTS

**Purpose:** Monitors all access to 42 CFR Part 2 protected data

| Column | Description |
|--------|-------------|
| `ACCESS_TIMESTAMP` | When access occurred |
| `USER_NAME` / `ROLE_NAME` | Who accessed |
| `TABLE_ACCESSED` / `COLUMN_ACCESSED` | What was accessed |
| `ACCESS_AUTHORIZATION` | AUTHORIZED (Compliance Officer) or REQUIRES_REVIEW |
| `COMPLIANCE_NOTE` | Guidance for compliance review |

**Critical Note:** Flags ALL non-Compliance Officer access for consent verification  
**Retention:** 90 days

---

### Section 5: Session & Admin Views (2)

#### V_SESSION_HISTORY

**Purpose:** Comprehensive session tracking

| Column | Description |
|--------|-------------|
| `SESSION_ID` | Unique session identifier |
| `LOGIN_TIME` / `LOGOUT_TIME` | Session bounds |
| `SESSION_DURATION_MINUTES` | How long session lasted |
| `CLIENT_APPLICATION` | What client connected |
| `AUTH_METHOD` | Authentication method used |
| `SESSION_FLAG` | EXTENDED_SESSION (>8 hrs), NO_MFA, NORMAL |

**Retention:** 90 days

---

#### V_ADMIN_ACTIVITY

**Purpose:** Tracks all operations using admin roles

| Tracked Roles | Privilege Level |
|---------------|-----------------|
| ACCOUNTADMIN | CRITICAL |
| SECURITYADMIN | HIGH |
| SYSADMIN | MEDIUM |

| Activity Category | Operations |
|-------------------|------------|
| PRIVILEGE_CHANGE | GRANT, REVOKE |
| USER_MANAGEMENT | CREATE_USER, ALTER_USER, DROP_USER |
| ROLE_MANAGEMENT | CREATE_ROLE, DROP_ROLE |
| DDL_OPERATION | CREATE*, DROP* |

**Retention:** 90 days

---

### Section 6: Risk Scoring View (1)

#### V_SECURITY_RISK_SCORE

**Purpose:** Computes per-user security risk score

| Risk Factor | Points |
|-------------|--------|
| ACCOUNTADMIN usage | +50 |
| 42 CFR Part 2 access (non-authorized) | +40 |
| Privilege escalation grants | +30 |
| DIRECT_IDENTIFIER access | +25 |
| Multiple failed logins (≥3) | +20 |

| Risk Level | Score Range |
|------------|-------------|
| LOW | 0-25 |
| MEDIUM | 26-50 |
| HIGH | 51-100 |
| CRITICAL | 101+ |

**Columns:**

| Column | Description |
|--------|-------------|
| `USER_NAME` | User being scored |
| `ACCOUNTADMIN_QUERIES` | Count of admin queries |
| `PRIVILEGE_ESCALATIONS` | Count of escalation grants |
| `PHI_ACCESS_COUNT` | Count of PHI accesses |
| `CFR42_ACCESS_COUNT` | Count of 42 CFR Part 2 accesses |
| `FAILED_LOGINS` | Count of failed login attempts |
| `RISK_SCORE` | Computed score |
| `RISK_LEVEL` | LOW, MEDIUM, HIGH, CRITICAL |

---

## Security Model

### Access Grants

| Role | Access Level |
|------|--------------|
| `MEDICORE_COMPLIANCE_OFFICER` | SELECT on all audit views |
| `MEDICORE_PLATFORM_ADMIN` | SELECT on all audit views |
| All other roles | No access |

### Future Grants

Future views created in the AUDIT schema will automatically grant SELECT to:
- `MEDICORE_COMPLIANCE_OFFICER`
- `MEDICORE_PLATFORM_ADMIN`

---

## Execution

```sql
-- Execute as ACCOUNTADMIN
USE ROLE ACCOUNTADMIN;
USE DATABASE MEDICORE_GOVERNANCE_DB;
USE SCHEMA AUDIT;

-- Run the script
-- infrastructure/09_audit/09_audit.sql
```

## Verification Queries

```sql
-- List all audit views (expect 13)
SHOW VIEWS IN SCHEMA MEDICORE_GOVERNANCE_DB.AUDIT;

-- Verify view count
SELECT COUNT(*) AS audit_view_count
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'AUDIT'
AND TABLE_CATALOG = 'MEDICORE_GOVERNANCE_DB';

-- Test login history
SELECT LOGIN_STATUS, COUNT(*) AS count
FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_LOGIN_HISTORY
GROUP BY LOGIN_STATUS;

-- Check high-risk users
SELECT USER_NAME, RISK_SCORE, RISK_LEVEL
FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_SECURITY_RISK_SCORE
WHERE RISK_LEVEL IN ('HIGH', 'CRITICAL')
ORDER BY RISK_SCORE DESC;

-- Review 42 CFR Part 2 access
SELECT ACCESS_AUTHORIZATION, COUNT(*) AS access_count
FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_42CFR_ACCESS_ATTEMPTS
GROUP BY ACCESS_AUTHORIZATION;

-- Verify grants to compliance officer
SHOW GRANTS TO ROLE MEDICORE_COMPLIANCE_OFFICER;
```

## Sample Compliance Reports

### Weekly Security Summary

```sql
SELECT 
    'Failed Logins' AS metric,
    COUNT(*) AS count
FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_LOGIN_HISTORY
WHERE LOGIN_STATUS = 'FAILED'
AND LOGIN_TIMESTAMP >= DATEADD(DAY, -7, CURRENT_TIMESTAMP())

UNION ALL

SELECT 
    'Privilege Escalations',
    COUNT(*)
FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_PRIVILEGE_ESCALATION_EVENTS
WHERE EVENT_TIMESTAMP >= DATEADD(DAY, -7, CURRENT_TIMESTAMP())

UNION ALL

SELECT
    '42 CFR Access Reviews Needed',
    COUNT(*)
FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_42CFR_ACCESS_ATTEMPTS
WHERE ACCESS_AUTHORIZATION = 'REQUIRES_REVIEW'
AND ACCESS_TIMESTAMP >= DATEADD(DAY, -7, CURRENT_TIMESTAMP());
```

### High-Risk User Report

```sql
SELECT 
    USER_NAME,
    RISK_SCORE,
    RISK_LEVEL,
    ACCOUNTADMIN_QUERIES,
    CFR42_ACCESS_COUNT,
    FAILED_LOGINS
FROM MEDICORE_GOVERNANCE_DB.AUDIT.V_SECURITY_RISK_SCORE
WHERE RISK_LEVEL IN ('HIGH', 'CRITICAL')
ORDER BY RISK_SCORE DESC
LIMIT 10;
```

---

## Summary

| Category | Views |
|----------|-------|
| Security Events | 3 |
| Data Access | 3 |
| Governance Changes | 2 |
| Compliance Monitoring | 2 |
| Session & Admin | 2 |
| Risk Scoring | 1 |
| **Total** | **13** |

| Metric | Value |
|--------|-------|
| SELECT Grants | 4 (current + future × 2 roles) |
| Roles with Access | 2 |
| Max Data Latency | 3 hours |
| Default Retention | 90-180 days |

## Next Steps

1. Configure alerting on high-risk events (integrate with Phase 07 alerts)
2. Set up scheduled reports for compliance review
3. Integrate with SIEM if applicable
4. Create dashboards for security monitoring
5. Establish review cadence for 42 CFR Part 2 access

## Next Phase

Proceed to **[Phase 10: Verification](10_phase_verification.md)** to validate the complete platform deployment.
