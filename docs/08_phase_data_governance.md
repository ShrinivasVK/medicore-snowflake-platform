# Phase 08: Data Governance

## Overview

Phase 08 implements comprehensive data governance for MediCore Health Systems including data classification tags, dynamic masking policies, and row access policies. This phase establishes HIPAA-compliant PHI protection with special handling for 42 CFR Part 2 substance use disorder records.

**Script:** `infrastructure/08_governance/08_data_governance.sql`  
**Version:** 1.0.0  
**Required Role:** ACCOUNTADMIN  
**Estimated Execution Time:** 2-3 minutes

## Prerequisites

- [ ] Phase 01 completed (`MEDICORE_GOVERNANCE_DB` exists)
- [ ] Phase 04 completed (`TAGS` and `POLICIES` schemas exist)
- [ ] Phase 02 completed (`MEDICORE_COMPLIANCE_OFFICER` role exists)

## Compliance Framework

### HIPAA Safe Harbor Method

The HIPAA Safe Harbor method requires removal or masking of 18 PHI identifiers. Our tag taxonomy maps to these elements:

| Tag Value | PHI Elements |
|-----------|--------------|
| `DIRECT_IDENTIFIER` | Names, SSN, MRN, addresses, phone, fax, email, account numbers, device IDs, etc. |
| `QUASI_IDENTIFIER` | Dates (DOB, admission), ZIP codes, ages over 89 |
| `SENSITIVE_CLINICAL` | Diagnoses, medications, procedures, clinical notes |

### 42 CFR Part 2 Compliance

Substance use disorder (SUD) records require stricter protections:

| Requirement | Implementation |
|-------------|----------------|
| Cannot be re-disclosed without explicit consent | `MASK_42CFR_PART2` policy |
| Separate consent from general HIPAA authorization | `ROW_ACCESS_CONSENT` policy |
| Must be segregated from standard clinical access | Row-level filtering by subdomain |
| Only Compliance Officer can access without consent | Role-based masking enforcement |

### Environment Strategy

| Environment | PHI Allowed | Purpose |
|-------------|-------------|---------|
| **PROD** | ✓ Real PHI | Production with full masking enforcement |
| **QA** | ✗ Synthetic only | Testing with anonymized data |
| **DEV** | ✗ Synthetic only | Development with anonymized data |

> **WARNING:** QA/DEV environments must NEVER contain real PHI. Row access policies provide defense-in-depth protection.

## Tags Created (13 Total)

### PHI Classification Tags

| Tag | Purpose | Allowed Values |
|-----|---------|----------------|
| `PHI_CLASSIFICATION` | HIPAA Safe Harbor classification | DIRECT_IDENTIFIER, QUASI_IDENTIFIER, SENSITIVE_CLINICAL, NON_PHI |
| `PHI_ELEMENT_TYPE` | Specific PHI element type | NAME, ADDRESS, DATES, PHONE, FAX, EMAIL, SSN, MRN, etc. (18 values) |

### Domain Tags

| Tag | Purpose | Allowed Values |
|-----|---------|----------------|
| `DATA_DOMAIN` | Business domain | CLINICAL, FINANCIAL, OPERATIONAL, RESEARCH, REFERENCE |
| `DATA_SUBDOMAIN` | Granular subdomain | DEMOGRAPHICS, ENCOUNTERS, DIAGNOSES, MEDICATIONS, SUBSTANCE_ABUSE, etc. |

### Data Quality Tags

| Tag | Purpose | Allowed Values |
|-----|---------|----------------|
| `DATA_QUALITY_STATUS` | DQ certification | CERTIFIED, UNDER_REVIEW, QUARANTINED, DEPRECATED |
| `DQ_ISSUE_TYPE` | Issue classification | COMPLETENESS, ACCURACY, CONSISTENCY, TIMELINESS, UNIQUENESS, VALIDITY |

### Architecture Tags

| Tag | Purpose | Allowed Values |
|-----|---------|----------------|
| `MEDALLION_LAYER` | Data lakehouse layer | BRONZE, SILVER, GOLD |
| `ENVIRONMENT` | Deployment environment | PROD, QA, DEV |
| `SOURCE_SYSTEM` | Data lineage | EPIC, CERNER, ALLSCRIPTS, etc. |
| `REFRESH_FREQUENCY` | Data refresh cadence | REAL_TIME, HOURLY, DAILY, WEEKLY, MONTHLY, ON_DEMAND |

### Regulatory Tags

| Tag | Purpose | Allowed Values |
|-----|---------|----------------|
| `REGULATORY_FRAMEWORK` | Compliance mapping | HIPAA, 42CFR_PART2, HITECH, STATE_PRIVACY, GDPR, CCPA |
| `CONSENT_REQUIRED` | Consent classification | NONE, HIPAA_AUTH, 42CFR_CONSENT, RESEARCH_CONSENT, MARKETING |
| `RETENTION_POLICY` | Retention period | 7_YEARS, 10_YEARS, PERMANENT, 1_YEAR, 90_DAYS |

## Masking Policies Created (7 Total)

### MASK_DIRECT_IDENTIFIER

**Purpose:** Protects HIPAA Safe Harbor direct identifiers (18 elements)

| Role | Access Level |
|------|--------------|
| `MEDICORE_CLINICAL_PHYSICIAN` | Full access |
| `MEDICORE_COMPLIANCE_OFFICER` | Full access |
| `ACCOUNTADMIN` | Full access |
| All other roles | `***REDACTED***` |

---

### MASK_QUASI_IDENTIFIER (STRING)

**Purpose:** Generalizes quasi-identifiers to reduce re-identification risk

| Role | Access Level |
|------|--------------|
| Privileged roles | Full access |
| Other roles | Dates → Year only, ZIP → First 3 digits |

---

### MASK_QUASI_IDENTIFIER_DATE

**Purpose:** Date-specific quasi-identifier masking

| Role | Access Level |
|------|--------------|
| Privileged roles | Full date |
| Other roles | Truncated to January 1 of year |

---

### MASK_QUASI_IDENTIFIER_TIMESTAMP

**Purpose:** Timestamp-specific quasi-identifier masking

| Role | Access Level |
|------|--------------|
| Privileged roles | Full timestamp |
| Other roles | Truncated to year |

---

### MASK_SENSITIVE_CLINICAL

**Purpose:** Protects clinical data (diagnoses, procedures, medications)

| Role | Access Level |
|------|--------------|
| `MEDICORE_CLINICAL_PHYSICIAN` | Full access |
| `MEDICORE_CLINICAL_NURSE` | Full access |
| `MEDICORE_COMPLIANCE_OFFICER` | Full access |
| All other roles | `NULL` |

---

### MASK_42CFR_PART2

**Purpose:** Maximum protection for substance use disorder records

| Role | Access Level |
|------|--------------|
| `MEDICORE_COMPLIANCE_OFFICER` | Full access |
| `ACCOUNTADMIN` | Full access |
| **All other roles including clinical** | `NULL` |

> **Important:** Even physicians cannot access 42 CFR Part 2 data without explicit patient consent. This policy enforces baseline protection.

---

### MASK_FINANCIAL_PII

**Purpose:** Protects financial account numbers

| Role | Access Level |
|------|--------------|
| `MEDICORE_BILLING_SPECIALIST` | Full access |
| `MEDICORE_COMPLIANCE_OFFICER` | Full access |
| Other roles | Last 4 digits only (`****1234`) |

## Row Access Policies Created (4 Total)

### ROW_ACCESS_CLINICAL

**Purpose:** Row-level access based on clinical data subdomain

| Data Subdomain | Accessible Roles |
|----------------|------------------|
| `SUBSTANCE_ABUSE` | COMPLIANCE_OFFICER only |
| `MENTAL_HEALTH` | Clinical roles + COMPLIANCE |
| `HIV_AIDS`, `REPRODUCTIVE_HEALTH`, `GENETIC` | PHYSICIAN + COMPLIANCE |
| All others | Standard clinical roles |

---

### ROW_ACCESS_ENVIRONMENT

**Purpose:** PHI protection in non-production environments

| Environment | PHI Present | Access |
|-------------|-------------|--------|
| PROD | Any | Normal role-based access |
| QA/DEV | TRUE | Engineers + Compliance only |
| QA/DEV | FALSE | All authorized roles |

---

### ROW_ACCESS_CONSENT

**Purpose:** Consent-based access framework

| Consent Type | Accessible Roles |
|--------------|------------------|
| `42CFR_CONSENT` | COMPLIANCE_OFFICER only |
| `HIPAA_AUTH` | Clinical + COMPLIANCE |
| `RESEARCH_CONSENT` | DATA_SCIENTIST + COMPLIANCE |
| `NONE` | All authorized roles |

---

### ROW_ACCESS_DATA_QUALITY

**Purpose:** Data quality-based access control

| DQ Status | Accessible Roles |
|-----------|------------------|
| `CERTIFIED` | All authorized roles |
| `UNDER_REVIEW` | Engineers + COMPLIANCE |
| `QUARANTINED` | Engineers only |
| `DEPRECATED` | Engineers only |

## Governance Grants

| Privilege | Role | Scope |
|-----------|------|-------|
| CREATE TAG | `MEDICORE_COMPLIANCE_OFFICER` | TAGS schema |
| CREATE MASKING POLICY | `MEDICORE_COMPLIANCE_OFFICER` | POLICIES schema |
| CREATE ROW ACCESS POLICY | `MEDICORE_COMPLIANCE_OFFICER` | POLICIES schema |
| APPLY TAG | `MEDICORE_COMPLIANCE_OFFICER` | Account-wide |
| APPLY MASKING POLICY | `MEDICORE_COMPLIANCE_OFFICER` | Account-wide |
| APPLY ROW ACCESS POLICY | `MEDICORE_COMPLIANCE_OFFICER` | Account-wide |

> **Separation of Duties:** Data engineers cannot create or modify governance policies. Only COMPLIANCE_OFFICER has governance privileges.

## Tag-Based Masking Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        TAG-BASED MASKING FLOW                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐      │
│   │    TAG          │     │ MASKING POLICY  │     │    COLUMN       │      │
│   │ PHI_CLASSIFI... │ ──► │ MASK_DIRECT_    │ ──► │ PATIENT_NAME    │      │
│   │ = 'DIRECT_ID...'│     │ IDENTIFIER      │     │ (automatic)     │      │
│   └─────────────────┘     └─────────────────┘     └─────────────────┘      │
│                                                                             │
│   1. Compliance Officer   2. Policy evaluates    3. Masking applied        │
│      applies tag to          CURRENT_ROLE()        automatically at        │
│      column                  at query time         query time               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Policy Attachment (Post-Data Model)

Policies are created but **not attached** in Phase 08. Attachment occurs after the data model is finalized:

### Step 1: Bind Masking Policy to Tag

```sql
ALTER TAG MEDICORE_GOVERNANCE_DB.TAGS.PHI_CLASSIFICATION
    SET MASKING POLICY MEDICORE_GOVERNANCE_DB.POLICIES.MASK_DIRECT_IDENTIFIER;
```

### Step 2: Apply Tag to Column

```sql
ALTER TABLE MEDICORE_ANALYTICS_DB.PROD_CLINICAL.DIM_PATIENT
    MODIFY COLUMN PATIENT_NAME
    SET TAG MEDICORE_GOVERNANCE_DB.TAGS.PHI_CLASSIFICATION = 'DIRECT_IDENTIFIER';
```

### Step 3: Attach Row Access Policy to Table

```sql
ALTER TABLE MEDICORE_ANALYTICS_DB.PROD_CLINICAL.FCT_ENCOUNTER
    ADD ROW ACCESS POLICY MEDICORE_GOVERNANCE_DB.POLICIES.ROW_ACCESS_CLINICAL
    ON (DATA_SUBDOMAIN);
```

## Execution

```sql
-- Execute as ACCOUNTADMIN
USE ROLE ACCOUNTADMIN;
USE DATABASE MEDICORE_GOVERNANCE_DB;

-- Run the script
-- infrastructure/08_governance/08_data_governance.sql
```

## Verification Queries

```sql
-- Verify all 13 tags created
SHOW TAGS IN SCHEMA MEDICORE_GOVERNANCE_DB.TAGS;

-- Verify all 7 masking policies created
SHOW MASKING POLICIES IN SCHEMA MEDICORE_GOVERNANCE_DB.POLICIES;

-- Verify all 4 row access policies created
SHOW ROW ACCESS POLICIES IN SCHEMA MEDICORE_GOVERNANCE_DB.POLICIES;

-- Verify COMPLIANCE_OFFICER grants
SHOW GRANTS TO ROLE MEDICORE_COMPLIANCE_OFFICER;

-- Check tag references (after applying tags to objects)
SELECT * 
FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES
WHERE TAG_DATABASE = 'MEDICORE_GOVERNANCE_DB'
ORDER BY OBJECT_DATABASE, OBJECT_SCHEMA, OBJECT_NAME;
```

## Testing Masking Behavior

```sql
-- Test as different roles
USE ROLE MEDICORE_CLINICAL_PHYSICIAN;
SELECT PATIENT_NAME, SSN, DATE_OF_BIRTH FROM MEDICORE_ANALYTICS_DB.PROD_CLINICAL.DIM_PATIENT LIMIT 5;
-- Expected: Full values visible

USE ROLE MEDICORE_BILLING_SPECIALIST;
SELECT PATIENT_NAME, SSN, DATE_OF_BIRTH FROM MEDICORE_ANALYTICS_DB.PROD_CLINICAL.DIM_PATIENT LIMIT 5;
-- Expected: ***REDACTED*** for name/SSN, year-only for DOB

USE ROLE MEDICORE_ANALYST_RESTRICTED;
SELECT PATIENT_NAME, SSN, DATE_OF_BIRTH FROM MEDICORE_ANALYTICS_DB.PROD_CLINICAL.DIM_PATIENT LIMIT 5;
-- Expected: ***REDACTED*** for all
```

## Summary

| Category | Count |
|----------|-------|
| Tags Created | 13 |
| Masking Policies Created | 7 |
| Row Access Policies Created | 4 |
| Governance Grants | 8 |
| HIPAA Identifiers Covered | 18 |
| Regulatory Frameworks Supported | 6 |

## Next Steps

1. Finalize data model with PHI column identification
2. Apply tags to columns per data classification
3. Bind masking policies to tags
4. Attach row access policies to tables
5. Test masking behavior with each role
6. Validate 42 CFR Part 2 segregation
7. Document governance in data catalog

## Next Phase

Proceed to **[Phase 09: Audit](09_phase_audit.md)** to configure audit logging and compliance reporting.
