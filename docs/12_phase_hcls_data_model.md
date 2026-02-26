# Phase 12: HCLS Data Model

## Overview

Phase 12 creates the Healthcare and Life Sciences (HCLS) data model in the Bronze layer (RAW_DB). This phase establishes source tables for clinical, billing, and reference domains, then seeds them with synthetic development data for testing and validation.

**Directory:** `infrastructure/12_hcls-data/`  
**Version:** 1.0.0  
**Required Role:** MEDICORE_DATA_ENGINEER  
**Target Database:** MEDICORE_RAW_DB

## Prerequisites

- [ ] Phase 04 completed (RAW_DB with DEV schemas exists)
- [ ] Phase 02 completed (MEDICORE_DATA_ENGINEER role exists)
- [ ] Phase 03 completed (MEDICORE_ETL_WH warehouse operational)



```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         HCLS DATA MODEL - RAW_DB                                 │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│   ┌─────────────────────────────────────────────────────────────────────────┐   │
│   │                        DEV_REFERENCE (2 tables)                         │   │
│   │   ┌─────────────────┐         ┌─────────────────┐                       │   │
│   │   │ DIM_DEPARTMENTS │         │ DIM_ICD10_CODES │                       │   │
│   │   │                 │         │                 │                       │   │
│   │   │ • Department ID │         │ • ICD-10 Code   │                       │   │
│   │   │ • Name          │         │ • Description   │                       │   │
│   │   │ • Facility Code │         │ • Category      │                       │   │
│   │   │ • Is Active     │         │ • Is Chronic    │                       │   │
│   │   └────────┬────────┘         └────────┬────────┘                       │   │
│   └────────────┼───────────────────────────┼────────────────────────────────┘   │
│                │                           │                                     │
│   ┌────────────┼───────────────────────────┼────────────────────────────────┐   │
│   │            │   DEV_CLINICAL (4 tables) │                                │   │
│   │            ▼                           ▼                                │   │
│   │   ┌─────────────────┐         ┌─────────────────┐                       │   │
│   │   │    PATIENTS     │◄────────│   ENCOUNTERS    │──────►ICD10_CODES     │   │
│   │   │                 │         │                 │                       │   │
│   │   │ • Patient ID    │         │ • Encounter ID  │                       │   │
│   │   │ • MRN           │         │ • Patient ID    │                       │   │
│   │   │ • Name (PHI)    │         │ • Provider ID   │                       │   │
│   │   │ • DOB (PHI)     │         │ • Admit/Disch   │                       │   │
│   │   │ • Phone (PHI)   │         │ • Primary Dx    │                       │   │
│   │   └─────────────────┘         └────────┬────────┘                       │   │
│   │                                        │                                │   │
│   │   ┌─────────────────┐         ┌────────▼────────┐                       │   │
│   │   │    PROVIDERS    │─────────│   LAB_RESULTS   │                       │   │
│   │   │                 │         │                 │                       │   │
│   │   │ • Provider ID   │         │ • Lab Result ID │                       │   │
│   │   │ • Name          │         │ • Encounter ID  │                       │   │
│   │   │ • Specialty     │         │ • Test Name     │                       │   │
│   │   │ • Department ID │         │ • Result Value  │                       │   │
│   │   └─────────────────┘         └─────────────────┘                       │   │
│   └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
│   ┌─────────────────────────────────────────────────────────────────────────┐   │
│   │                        DEV_BILLING (2 tables)                           │   │
│   │   ┌─────────────────┐         ┌─────────────────┐                       │   │
│   │   │     CLAIMS      │─────────│CLAIM_LINE_ITEMS │                       │   │
│   │   │                 │         │                 │                       │   │
│   │   │ • Claim ID      │         │ • Line Item ID  │                       │   │
│   │   │ • Encounter ID  │         │ • Claim ID      │                       │   │
│   │   │ • Patient ID    │         │ • Procedure Code│                       │   │
│   │   │ • Total Amount  │         │ • Line Amount   │                       │   │
│   │   │ • Payer Type    │         │ • Quantity      │                       │   │
│   │   └─────────────────┘         └─────────────────┘                       │   │
│   └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
infrastructure/12_hcls-data/
├── 01_reference_tables.sql      # DIM_DEPARTMENTS, DIM_ICD10_CODES
├── 02_clinical_tables.sql       # PATIENTS, PROVIDERS, ENCOUNTERS, LAB_RESULTS
├── 03_billing_tables.sql        # CLAIMS, CLAIM_LINE_ITEMS
└── 04_seed_dev_data.sql         # Synthetic test data
```

## Tables Created (8 Total)

### Reference Domain

#### DIM_DEPARTMENTS

| Column | Type | Description | PHI |
|--------|------|-------------|-----|
| `DEPARTMENT_ID` | NUMBER | Unique department identifier | No |
| `DEPARTMENT_NAME` | VARCHAR(100) | Department display name | No |
| `FACILITY_CODE` | VARCHAR(20) | Facility location code | No |
| `IS_ACTIVE` | BOOLEAN | Department active status | No |
| `CREATED_AT` | TIMESTAMP_NTZ | Record creation timestamp | No |

---

#### DIM_ICD10_CODES

| Column | Type | Description | PHI |
|--------|------|-------------|-----|
| `ICD10_CODE` | VARCHAR(10) | Primary ICD-10 diagnosis code | No |
| `ICD10_DESCRIPTION` | VARCHAR(255) | Diagnosis description | No |
| `ICD10_CATEGORY` | VARCHAR(100) | Diagnosis category grouping | No |
| `IS_CHRONIC` | BOOLEAN | Flag for chronic conditions | No |
| `CREATED_AT` | TIMESTAMP_NTZ | Record creation timestamp | No |

---

### Clinical Domain

#### PATIENTS

| Column | Type | Description | PHI |
|--------|------|-------------|-----|
| `PATIENT_ID` | NUMBER | Unique patient surrogate ID | No |
| `MRN` | VARCHAR(50) | Medical Record Number | **DIRECT** |
| `FIRST_NAME` | VARCHAR(100) | Patient first name | **DIRECT** |
| `LAST_NAME` | VARCHAR(100) | Patient last name | **DIRECT** |
| `DATE_OF_BIRTH` | DATE | Date of birth | **QUASI** |
| `GENDER` | VARCHAR(10) | Gender value | No |
| `PHONE_NUMBER` | VARCHAR(20) | Contact phone number | **DIRECT** |
| `ZIP_CODE` | VARCHAR(10) | Postal code | **QUASI** |
| `CREATED_AT` | TIMESTAMP_NTZ | Record creation timestamp | No |

---

#### PROVIDERS

| Column | Type | Description | PHI |
|--------|------|-------------|-----|
| `PROVIDER_ID` | NUMBER | Unique provider ID | No |
| `PROVIDER_NAME` | VARCHAR(150) | Provider full name | No |
| `SPECIALTY` | VARCHAR(100) | Clinical specialty | No |
| `DEPARTMENT_ID` | NUMBER | Department reference (FK) | No |
| `CREATED_AT` | TIMESTAMP_NTZ | Record creation timestamp | No |

---

#### ENCOUNTERS

| Column | Type | Description | PHI |
|--------|------|-------------|-----|
| `ENCOUNTER_ID` | NUMBER | Unique encounter ID | No |
| `PATIENT_ID` | NUMBER | Patient reference (FK) | No |
| `PROVIDER_ID` | NUMBER | Provider reference (FK) | No |
| `DEPARTMENT_ID` | NUMBER | Department reference (FK) | No |
| `ADMISSION_DATE` | DATE | Admission date | **QUASI** |
| `DISCHARGE_DATE` | DATE | Discharge date | **QUASI** |
| `ENCOUNTER_TYPE` | VARCHAR(50) | Encounter classification | No |
| `PRIMARY_ICD10_CODE` | VARCHAR(10) | Primary diagnosis code (FK) | **SENSITIVE** |
| `CREATED_AT` | TIMESTAMP_NTZ | Record creation timestamp | No |

---

#### LAB_RESULTS

| Column | Type | Description | PHI |
|--------|------|-------------|-----|
| `LAB_RESULT_ID` | NUMBER | Unique lab result ID | No |
| `ENCOUNTER_ID` | NUMBER | Encounter reference (FK) | No |
| `TEST_NAME` | VARCHAR(100) | Lab test name | No |
| `RESULT_VALUE` | VARCHAR(100) | Measured value (raw format) | **SENSITIVE** |
| `RESULT_UNIT` | VARCHAR(20) | Measurement unit | No |
| `RESULT_DATE` | DATE | Test result date | **QUASI** |
| `IS_ABNORMAL` | BOOLEAN | Abnormal result flag | No |
| `CREATED_AT` | TIMESTAMP_NTZ | Record creation timestamp | No |

---

### Billing Domain

#### CLAIMS

| Column | Type | Description | PHI |
|--------|------|-------------|-----|
| `CLAIM_ID` | NUMBER(38,0) | Unique claim ID | No |
| `ENCOUNTER_ID` | NUMBER | Encounter reference (FK) | No |
| `PATIENT_ID` | NUMBER | Patient reference (FK) | No |
| `TOTAL_AMOUNT` | NUMBER(10,2) | Total billed amount | No |
| `CLAIM_STATUS` | VARCHAR(50) | Claim processing status | No |
| `PAYER_TYPE` | VARCHAR(50) | Insurance payer category | No |
| `SERVICE_DATE` | DATE | Service date | **QUASI** |
| `CREATED_AT` | TIMESTAMP_NTZ | Record creation timestamp | No |

---

#### CLAIM_LINE_ITEMS

| Column | Type | Description | PHI |
|--------|------|-------------|-----|
| `LINE_ITEM_ID` | NUMBER | Unique claim line item ID | No |
| `CLAIM_ID` | NUMBER | Claim reference (FK) | No |
| `PROCEDURE_CODE` | VARCHAR(20) | Procedure or CPT code | **SENSITIVE** |
| `LINE_AMOUNT` | NUMBER(10,2) | Line item billed amount | No |
| `QUANTITY` | NUMBER | Units billed | No |
| `CREATED_AT` | TIMESTAMP_NTZ | Record creation timestamp | No |

---

## PHI Classification Summary

| Classification | Columns | Masking Policy |
|----------------|---------|----------------|
| **DIRECT_IDENTIFIER** | MRN, FIRST_NAME, LAST_NAME, PHONE_NUMBER | MASK_DIRECT_IDENTIFIER |
| **QUASI_IDENTIFIER** | DATE_OF_BIRTH, ZIP_CODE, ADMISSION_DATE, DISCHARGE_DATE, SERVICE_DATE, RESULT_DATE | MASK_QUASI_IDENTIFIER |
| **SENSITIVE_CLINICAL** | PRIMARY_ICD10_CODE, RESULT_VALUE, PROCEDURE_CODE | MASK_SENSITIVE_CLINICAL |

---

## Synthetic Seed Data

### Data Volumes (DEV Environment)

| Table | Row Count | Notes |
|-------|-----------|-------|
| DIM_DEPARTMENTS | 10 | Hospital departments |
| DIM_ICD10_CODES | 50 | Common diagnosis codes |
| PATIENTS | 100 | Synthetic patients |
| PROVIDERS | 20 | Synthetic providers |
| ENCOUNTERS | 500 | ~5 per patient average |
| LAB_RESULTS | 1,000 | ~2 per encounter average |
| CLAIMS | 500 | 1 per encounter |
| CLAIM_LINE_ITEMS | 1,500 | ~3 per claim average |

### Seed Data Characteristics

| Attribute | Specification |
|-----------|---------------|
| Names | Randomly generated (not real) |
| MRNs | Sequential with prefix (MRN-XXXX) |
| DOB Range | 1940-2020 |
| ZIP Codes | Real US ZIP codes (structure only) |
| ICD-10 Codes | Real code format, common conditions |
| Amounts | Realistic healthcare billing ranges |

> **WARNING:** Seed data is for DEV environment only. NEVER copy seed data to QA or PROD schemas.

---

## Table Dependencies

```
                    ┌─────────────────┐
                    │ DIM_DEPARTMENTS │
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
         ▼                   ▼                   │
┌─────────────────┐  ┌─────────────────┐         │
│    PROVIDERS    │  │   DIM_ICD10_    │         │
│                 │  │   CODES         │         │
└────────┬────────┘  └────────┬────────┘         │
         │                    │                  │
         │     ┌──────────────┘                  │
         │     │                                 │
         ▼     ▼                                 ▼
┌─────────────────┐                    ┌─────────────────┐
│    PATIENTS     │◄──────────────────►│   ENCOUNTERS    │
└────────┬────────┘                    └────────┬────────┘
         │                                      │
         │                    ┌─────────────────┼─────────────────┐
         │                    │                 │                 │
         │                    ▼                 ▼                 │
         │           ┌─────────────────┐ ┌─────────────────┐      │
         │           │   LAB_RESULTS   │ │     CLAIMS      │◄─────┘
         │           └─────────────────┘ └────────┬────────┘
         │                                        │
         │                                        ▼
         │                               ┌─────────────────┐
         └──────────────────────────────►│CLAIM_LINE_ITEMS │
                                         └─────────────────┘
```

### Execution Order

1. **Reference Tables** (no dependencies)
   - DIM_DEPARTMENTS
   - DIM_ICD10_CODES

2. **Clinical Tables** (depend on Reference)
   - PATIENTS
   - PROVIDERS
   - ENCOUNTERS
   - LAB_RESULTS

3. **Billing Tables** (depend on Clinical)
   - CLAIMS
   - CLAIM_LINE_ITEMS

4. **Seed Data** (all tables must exist)
   - Insert synthetic data

---

## Execution

```sql
-- Execute as MEDICORE_DATA_ENGINEER
USE ROLE MEDICORE_DATA_ENGINEER;
USE WAREHOUSE MEDICORE_ETL_WH;

-- Step 1: Reference Tables
@infrastructure/12_hcls-data/01_reference_tables.sql

-- Step 2: Clinical Tables
@infrastructure/12_hcls-data/02_clinical_tables.sql

-- Step 3: Billing Tables
@infrastructure/12_hcls-data/03_billing_tables.sql

-- Step 4: Seed DEV Data
@infrastructure/12_hcls-data/04_seed_dev_data.sql
```

---

## Verification Queries

```sql
-- Verify all tables created
SHOW TABLES IN SCHEMA MEDICORE_RAW_DB.DEV_REFERENCE;
SHOW TABLES IN SCHEMA MEDICORE_RAW_DB.DEV_CLINICAL;
SHOW TABLES IN SCHEMA MEDICORE_RAW_DB.DEV_BILLING;

-- Verify row counts after seeding
SELECT 'DIM_DEPARTMENTS' AS TABLE_NAME, COUNT(*) AS ROW_COUNT 
FROM MEDICORE_RAW_DB.DEV_REFERENCE.DIM_DEPARTMENTS
UNION ALL
SELECT 'DIM_ICD10_CODES', COUNT(*) FROM MEDICORE_RAW_DB.DEV_REFERENCE.DIM_ICD10_CODES
UNION ALL
SELECT 'PATIENTS', COUNT(*) FROM MEDICORE_RAW_DB.DEV_CLINICAL.PATIENTS
UNION ALL
SELECT 'PROVIDERS', COUNT(*) FROM MEDICORE_RAW_DB.DEV_CLINICAL.PROVIDERS
UNION ALL
SELECT 'ENCOUNTERS', COUNT(*) FROM MEDICORE_RAW_DB.DEV_CLINICAL.ENCOUNTERS
UNION ALL
SELECT 'LAB_RESULTS', COUNT(*) FROM MEDICORE_RAW_DB.DEV_CLINICAL.LAB_RESULTS
UNION ALL
SELECT 'CLAIMS', COUNT(*) FROM MEDICORE_RAW_DB.DEV_BILLING.CLAIMS
UNION ALL
SELECT 'CLAIM_LINE_ITEMS', COUNT(*) FROM MEDICORE_RAW_DB.DEV_BILLING.CLAIM_LINE_ITEMS;

-- Sample patient data (verify synthetic)
SELECT * FROM MEDICORE_RAW_DB.DEV_CLINICAL.PATIENTS LIMIT 5;

-- Verify referential integrity
SELECT 
    'Orphan Encounters' AS CHECK_NAME,
    COUNT(*) AS ORPHAN_COUNT
FROM MEDICORE_RAW_DB.DEV_CLINICAL.ENCOUNTERS e
LEFT JOIN MEDICORE_RAW_DB.DEV_CLINICAL.PATIENTS p ON e.PATIENT_ID = p.PATIENT_ID
WHERE p.PATIENT_ID IS NULL;
```

---

## Post-Deployment: Apply Governance Tags

After table creation, apply PHI tags from Phase 08:

```sql
USE ROLE MEDICORE_COMPLIANCE_OFFICER;

-- Tag DIRECT identifiers
ALTER TABLE MEDICORE_RAW_DB.DEV_CLINICAL.PATIENTS
    MODIFY COLUMN MRN SET TAG MEDICORE_GOVERNANCE_DB.TAGS.PHI_CLASSIFICATION = 'DIRECT_IDENTIFIER';
ALTER TABLE MEDICORE_RAW_DB.DEV_CLINICAL.PATIENTS
    MODIFY COLUMN FIRST_NAME SET TAG MEDICORE_GOVERNANCE_DB.TAGS.PHI_CLASSIFICATION = 'DIRECT_IDENTIFIER';
ALTER TABLE MEDICORE_RAW_DB.DEV_CLINICAL.PATIENTS
    MODIFY COLUMN LAST_NAME SET TAG MEDICORE_GOVERNANCE_DB.TAGS.PHI_CLASSIFICATION = 'DIRECT_IDENTIFIER';
ALTER TABLE MEDICORE_RAW_DB.DEV_CLINICAL.PATIENTS
    MODIFY COLUMN PHONE_NUMBER SET TAG MEDICORE_GOVERNANCE_DB.TAGS.PHI_CLASSIFICATION = 'DIRECT_IDENTIFIER';

-- Tag QUASI identifiers
ALTER TABLE MEDICORE_RAW_DB.DEV_CLINICAL.PATIENTS
    MODIFY COLUMN DATE_OF_BIRTH SET TAG MEDICORE_GOVERNANCE_DB.TAGS.PHI_CLASSIFICATION = 'QUASI_IDENTIFIER';
ALTER TABLE MEDICORE_RAW_DB.DEV_CLINICAL.PATIENTS
    MODIFY COLUMN ZIP_CODE SET TAG MEDICORE_GOVERNANCE_DB.TAGS.PHI_CLASSIFICATION = 'QUASI_IDENTIFIER';

-- Tag SENSITIVE clinical data
ALTER TABLE MEDICORE_RAW_DB.DEV_CLINICAL.ENCOUNTERS
    MODIFY COLUMN PRIMARY_ICD10_CODE SET TAG MEDICORE_GOVERNANCE_DB.TAGS.PHI_CLASSIFICATION = 'SENSITIVE_CLINICAL';
```

---

## Summary

| Metric | Value |
|--------|-------|
| Tables Created | 8 |
| Reference Tables | 2 |
| Clinical Tables | 4 |
| Billing Tables | 2 |
| PHI Columns | 12 |
| Direct Identifiers | 4 |
| Quasi-Identifiers | 6 |
| Sensitive Clinical | 3 |
| Seed Data Rows | ~3,680 |

---

## Environment Promotion

To promote the data model to QA and PROD:

```sql
-- Clone structure to QA (no data)
CREATE OR REPLACE TABLE MEDICORE_RAW_DB.QA_CLINICAL.PATIENTS 
    LIKE MEDICORE_RAW_DB.DEV_CLINICAL.PATIENTS;

-- Clone structure to PROD (no data)
CREATE OR REPLACE TABLE MEDICORE_RAW_DB.PROD_CLINICAL.PATIENTS 
    LIKE MEDICORE_RAW_DB.DEV_CLINICAL.PATIENTS;
```

> **Note:** PROD data comes from actual source system extracts via ETL pipelines, not from seed data.

## Next Phase

Proceed to **[Phase 13: AI-Ready Layer](13_phase_ai_ready_layer.md)** to configure Cortex AI features and semantic models.
