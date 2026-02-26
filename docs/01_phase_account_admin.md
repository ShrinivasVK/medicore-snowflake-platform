# Phase 01: Account Administration

## Overview

Phase 01 establishes the foundational account-level security controls for MediCore Health Systems' HIPAA-compliant Snowflake platform. This phase must be executed first as it creates bootstrap objects required by all subsequent phases.

**Script:** `infrastructure/01_account-admin/01_account_administration.sql`  
**Version:** 2.0.0  
**Required Role:** ACCOUNTADMIN  
**Edition:** Snowflake Business Critical (with signed BAA)

## Prerequisites

- [ ] ACCOUNTADMIN role access
- [ ] Snowflake Business Critical Edition
- [ ] Signed Business Associate Agreement (BAA) with Snowflake
- [ ] Approved IP ranges documented for network policy

## Objects Created

### Database Bootstrap

| Object | Name | Purpose |
|--------|------|---------|
| Database | `MEDICORE_GOVERNANCE_DB` | Central governance database for security, policies, tags, and audit |
| Schema | `MEDICORE_GOVERNANCE_DB.SECURITY` | Houses account-level security policy objects |

> **Note:** Only the SECURITY schema is created in Phase 01. Remaining governance schemas (POLICIES, TAGS, DATA_QUALITY, AUDIT) are created in Phase 04.

### Security Policies

| Object Type | Name | HIPAA Reference |
|-------------|------|-----------------|
| Network Rule | `MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_ALLOWED_IPS` | 45 CFR 164.312(a)(1) - Access Control |
| Network Policy | `MEDICORE_NETWORK_POLICY` | 45 CFR 164.312(a)(1) - Access Control |
| Password Policy | `MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_PASSWORD_POLICY` | 45 CFR 164.308(a)(5)(ii)(D) - Password Management |
| Session Policy | `MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_SESSION_POLICY` | 45 CFR 164.312(a)(2)(iii) - Automatic Logoff |

### Account Parameters

| Parameter | Value | Purpose |
|-----------|-------|---------|
| `TIMEZONE` | America/Chicago | Hospital operations standard |
| `STATEMENT_TIMEOUT_IN_SECONDS` | 3600 | Prevent runaway queries (1 hour max) |
| `STATEMENT_QUEUED_TIMEOUT_IN_SECONDS` | 1800 | Queue timeout (30 minutes) |
| `DATA_RETENTION_TIME_IN_DAYS` | 14 | Default Time Travel retention |
| `MIN_DATA_RETENTION_TIME_IN_DAYS` | 7 | Minimum retention floor |
| `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION` | TRUE | Enforce governed external stages |
| `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_OPERATION` | TRUE | Enforce governed stage operations |
| `PERIODIC_DATA_REKEYING` | TRUE | HIPAA encryption compliance |
| `OAUTH_ADD_PRIVILEGED_ROLES_TO_BLOCKED_LIST` | TRUE | Prevent OAuth privilege escalation |
| `EXTERNAL_OAUTH_ADD_PRIVILEGED_ROLES_TO_BLOCKED_LIST` | TRUE | Prevent external OAuth escalation |
| `ENABLE_IDENTIFIER_FIRST_LOGIN` | TRUE | MFA-compatible login flow |

## Security Policy Details

### Password Policy

```
Minimum Length:        14 characters
Maximum Length:        128 characters
Uppercase Required:    1+
Lowercase Required:    1+
Numeric Required:      1+
Special Chars Required: 1+
Minimum Age:           1 day
Maximum Age:           90 days
Failed Attempts:       5 (before lockout)
Lockout Duration:      30 minutes
Password History:      12 passwords
```

### Session Policy

```
Idle Timeout:          240 minutes (4 hours)
UI Idle Timeout:       240 minutes (4 hours)
```

### Network Policy

```
Mode:                  INGRESS
Default Value:         0.0.0.0/0 (PLACEHOLDER - must be updated)
```

> **WARNING:** The network rule contains a placeholder value. Replace with production IP ranges before go-live:
> - Corporate office IPs
> - VPN gateway IPs
> - GitHub Actions runner IPs
> - Azure DevOps agent IPs

## Execution

```sql
-- Execute as ACCOUNTADMIN
USE ROLE ACCOUNTADMIN;

-- Run the script
-- infrastructure/01_account-admin/01_account_administration.sql
```

## Verification Queries

```sql
-- Verify governance database and schema
SHOW SCHEMAS IN DATABASE MEDICORE_GOVERNANCE_DB;

-- Verify network policy
SHOW NETWORK POLICIES LIKE 'MEDICORE%';

-- Verify password policy
DESCRIBE PASSWORD POLICY MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_PASSWORD_POLICY;

-- Verify session policy
DESCRIBE SESSION POLICY MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_SESSION_POLICY;

-- Verify account parameters
SHOW PARAMETERS LIKE 'TIMEZONE' IN ACCOUNT;
SHOW PARAMETERS LIKE 'STATEMENT_TIMEOUT%' IN ACCOUNT;
SHOW PARAMETERS LIKE 'DATA_RETENTION%' IN ACCOUNT;
SHOW PARAMETERS LIKE 'PERIODIC_DATA_REKEYING' IN ACCOUNT;
SHOW PARAMETERS LIKE 'REQUIRE_STORAGE_INTEGRATION%' IN ACCOUNT;
```

## Dependencies for Phase 02

Phase 02 (RBAC Setup) requires:
- `MEDICORE_GOVERNANCE_DB` exists
- `MEDICORE_GOVERNANCE_DB.SECURITY` schema exists
- `MEDICORE_PASSWORD_POLICY` applied
- Network policy allows CI/CD runner IPs (if automated deployment)

## Rollback Procedure

Execute only if Phase 01 must be reversed before proceeding to Phase 02:

```sql
-- Remove account-level policies
ALTER ACCOUNT UNSET NETWORK_POLICY;
DROP NETWORK POLICY MEDICORE_NETWORK_POLICY;

ALTER ACCOUNT UNSET PASSWORD POLICY;
DROP PASSWORD POLICY MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_PASSWORD_POLICY;

ALTER ACCOUNT UNSET SESSION POLICY;
DROP SESSION POLICY MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_SESSION_POLICY;

-- Remove bootstrap objects
DROP SCHEMA MEDICORE_GOVERNANCE_DB.SECURITY;
DROP DATABASE MEDICORE_GOVERNANCE_DB;
```

## HIPAA Compliance Mapping

| HIPAA Requirement | Implementation |
|-------------------|----------------|
| 45 CFR 164.312(a)(1) - Access Control | Network policy restricts access to approved IPs |
| 45 CFR 164.308(a)(5)(ii)(D) - Password Management | Password policy enforces complexity and rotation |
| 45 CFR 164.312(a)(2)(iii) - Automatic Logoff | Session policy terminates idle sessions |
| 45 CFR 164.312(a)(2)(iv) - Encryption | Periodic data rekeying enabled |

## Next Phase

Proceed to **[Phase 02: RBAC Setup](02_phase_rbac.md)** to configure roles and permissions.
