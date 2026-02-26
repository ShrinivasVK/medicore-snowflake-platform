# Phase 11: Medallion Architecture

## Overview

Phase 11 implements the data transformation layer using a 3-tier medallion architecture (Transform → Analytics → AI-Ready). This phase creates Dynamic Tables for automated data pipelines across clinical, billing, and reference domains, plus executive KPIs and de-identified datasets.

**Directory:** `infrastructure/11_medallion/`  
**Version:** 1.0.0  
**Required Role:** MEDICORE_DATA_ENGINEER  
**Primary Warehouse:** MEDICORE_ETL_WH

## Prerequisites

- [ ] Phases 01-10 completed
- [ ] Phase 12 completed (HCLS data model with source tables)
- [ ] `MEDICORE_DATA_ENGINEER` role has appropriate grants
- [ ] `MEDICORE_ETL_WH` warehouse operational

## Medallion Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         MEDALLION DATA FLOW                                      │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  ┌───────────────────┐                                                          │
│  │   RAW_DB          │                                                          │
│  │   (Bronze)        │                                                          │
│  │                   │                                                          │
│  │  • Raw source     │                                                          │
│  │    extracts       │                                                          │
│  │  • No transforms  │                                                          │
│  │  • 90-day retain  │                                                          │
│  └─────────┬─────────┘                                                          │
│            │                                                                     │
│            ▼                                                                     │
│  ┌───────────────────┐   ┌───────────────────┐   ┌───────────────────┐         │
│  │   TRANSFORM_DB    │   │   ANALYTICS_DB    │   │   AI_READY_DB     │         │
│  │   (Silver)        │──▶│   (Gold)          │──▶│   (Platinum)      │         │
│  │                   │   │                   │   │                   │         │
│  │  • Cleansed       │   │  • Business-ready │   │  • Features       │         │
│  │  • Conformed      │   │  • PHI protected  │   │  • Training sets  │         │
│  │  • Validated      │   │  • De-identified  │   │  • Embeddings     │         │
│  │  • Dynamic Tables │   │  • Executive KPIs │   │  • Semantic model │         │
│  └───────────────────┘   └───────────────────┘   └───────────────────┘         │
│                                                                                  │
│  TARGET_LAG: 5 min       TARGET_LAG: 5 min       TARGET_LAG: 15 min             │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
infrastructure/11_medallion/
├── 01_transform_layer/           # Silver Layer
│   ├── 01_reference/
│   │   ├── 01_dim_departments.sql
│   │   └── 02_dim_icd10_codes.sql
│   ├── 02_clinical/
│   │   ├── 01_patients.sql
│   │   ├── 02_providers.sql
│   │   ├── 03_encounters.sql
│   │   └── 04_lab_results.sql
│   ├── 03_billing/
│   │   ├── 01_claims.sql
│   │   └── 02_claim_line_items.sql
│   └── 99_transform_master.sql
│
├── 02_analytics_layer/           # Gold Layer
│   ├── 01_reference/
│   │   ├── 01_dim_departments_dynamic.sql
│   │   └── 02_dim_icd10_codes_dynamic.sql
│   ├── 02_clinical/
│   │   ├── 01_patients_dynamic.sql
│   │   ├── 02_providers_dynamic.sql
│   │   ├── 03_encounters_dynamic.sql
│   │   └── 04_lab_results_dynamic.sql
│   ├── 03_billing/
│   │   ├── 01_claims_dynamic.sql
│   │   └── 02_claim_line_items_dynamic.sql
│   ├── 04_executive/
│   │   ├── 01_kpi_patient_volume.sql
│   │   ├── 02_kpi_revenue_summary.sql
│   │   └── 03_kpi_clinical_outcomes.sql
│   ├── 05_deidentified/
│   │   ├── 01_patients_deidentified.sql
│   │   ├── 02_encounters_deidentified.sql
│   │   └── 03_lab_results_deidentified.sql
│   └── 99_analytics_master.sql
│
├── 03_ai_ready_layer/            # Platinum Layer
│   ├── 01_features/
│   │   ├── 01_patient_features.sql
│   │   └── 02_encounter_features.sql
│   ├── 02_training/
│   │   ├── 01_readmission_training_set.sql
│   │   └── 02_claims_training_set.sql
│   ├── 03_semantic/
│   │   └── 01_medicore_semantic_model.sql
│   ├── 04_embeddings/
│   │   ├── 01_clinical_note_embeddings.sql
│   │   └── 02_diagnosis_embeddings.sql
│   └── 99_ai_ready_master.sql
│
└── 99_master_run.sql             # Full deployment script
```

## Layer 1: Transform Layer (Silver)

### Purpose
Cleanse, conform, and validate data from RAW_DB. Apply business rules and standardization.

### Objects Created

| Domain | Object | Type | Source |
|--------|--------|------|--------|
| Reference | `DIM_DEPARTMENTS` | Dynamic Table | RAW_DB.PROD_REFERENCE |
| Reference | `DIM_ICD10_CODES` | Dynamic Table | RAW_DB.PROD_REFERENCE |
| Clinical | `PATIENTS` | Dynamic Table | RAW_DB.PROD_CLINICAL |
| Clinical | `PROVIDERS` | Dynamic Table | RAW_DB.PROD_CLINICAL |
| Clinical | `ENCOUNTERS` | Dynamic Table | RAW_DB.PROD_CLINICAL |
| Clinical | `LAB_RESULTS` | Dynamic Table | RAW_DB.PROD_CLINICAL |
| Billing | `CLAIMS` | Dynamic Table | RAW_DB.PROD_BILLING |
| Billing | `CLAIM_LINE_ITEMS` | Dynamic Table | RAW_DB.PROD_BILLING |

### Configuration

| Setting | Value |
|---------|-------|
| Target Lag | 5 minutes |
| Warehouse | MEDICORE_ETL_WH |
| Refresh Mode | AUTO |

---

## Layer 2: Analytics Layer (Gold)

### Purpose
Business-ready data with PHI protection, executive KPIs, and de-identified datasets for restricted access.

### 2.1 Clinical Domain (Dynamic Tables)

| Object | Grain | PHI Status |
|--------|-------|------------|
| `PATIENTS` | 1 patient | Contains PHI - masked |
| `PROVIDERS` | 1 provider | Minimal PHI |
| `ENCOUNTERS` | 1 encounter | Contains PHI - masked |
| `LAB_RESULTS` | 1 lab result | Contains PHI - masked |

### 2.2 Billing Domain (Dynamic Tables)

| Object | Grain | PHI Status |
|--------|-------|------------|
| `CLAIMS` | 1 claim | Contains PHI - masked |
| `CLAIM_LINE_ITEMS` | 1 line item | Contains PHI - masked |

### 2.3 Executive KPIs (Tables)

| Object | Grain | PHI Status | Consumers |
|--------|-------|------------|-----------|
| `KPI_PATIENT_VOLUME` | 1 month | No PHI | Executive dashboards |
| `KPI_REVENUE_SUMMARY` | 1 month | No PHI | CFO reporting |
| `KPI_CLINICAL_OUTCOMES` | 1 month | No PHI | CMO reporting |

**KPI Metrics:**

| KPI | Metrics Included |
|-----|------------------|
| Patient Volume | Total patients, New patients, Active patients, Encounters per patient |
| Revenue Summary | Total charges, Collections, AR aging, Payer mix |
| Clinical Outcomes | Length of stay, Readmission rates, Mortality rates |

### 2.4 De-identified Layer (Tables)

| Object | De-identification Method | Consumers |
|--------|-------------------------|-----------|
| `PATIENTS` | Age buckets, ZIP3, no names | ANALYST_RESTRICTED, EXT_AUDITOR |
| `ENCOUNTERS` | Year only, no patient names | ANALYST_RESTRICTED, EXT_AUDITOR |
| `LAB_RESULTS` | No patient identifiers | ANALYST_RESTRICTED, EXT_AUDITOR |

**HIPAA Safe Harbor Compliance:**

| Identifier | Treatment |
|------------|-----------|
| Names | Removed |
| Addresses | ZIP3 only |
| Dates | Year only or age bucket |
| Phone/Fax/Email | Removed |
| SSN/MRN | Removed |
| Account numbers | Removed |

---

## Layer 3: AI-Ready Layer (Platinum)

### Purpose
Feature engineering, ML training datasets, semantic models, and vector embeddings for AI/ML workloads.

### 3.1 Feature Store

| Object | Purpose | Refresh |
|--------|---------|---------|
| `PATIENT_FEATURES` | Patient-level features for ML | 15 min lag |
| `ENCOUNTER_FEATURES` | Encounter-level features | 15 min lag |

**Sample Features:**
- Age at encounter
- Days since last visit
- Total prior encounters
- Comorbidity count
- Lab value trends

### 3.2 Training Datasets

| Object | Use Case | Label Column |
|--------|----------|--------------|
| `READMISSION_TRAINING_SET` | 30-day readmission prediction | `READMITTED_30_DAY` |
| `CLAIMS_TRAINING_SET` | Claims denial prediction | `CLAIM_DENIED` |

### 3.3 Semantic Model

| Object | Purpose |
|--------|---------|
| `MEDICORE_SEMANTIC_MODEL` | Cortex Analyst natural language queries |

### 3.4 Embeddings

| Object | Model | Dimension |
|--------|-------|-----------|
| `CLINICAL_NOTE_EMBEDDINGS` | Cortex Embed | 1024 |
| `DIAGNOSIS_EMBEDDINGS` | Cortex Embed | 1024 |

---

## Dynamic Table Configuration

### Refresh Cascade

```
RAW_DB Tables (Source)
       │
       ▼ (5 min lag)
TRANSFORM_DB Dynamic Tables
       │
       ▼ (5 min lag)
ANALYTICS_DB Dynamic Tables
       │
       ▼ (15 min lag)
AI_READY_DB Dynamic Tables
```

### Total Pipeline Latency

| Data Path | Maximum Latency |
|-----------|-----------------|
| RAW → TRANSFORM | 5 minutes |
| RAW → ANALYTICS | 10 minutes |
| RAW → AI_READY | 25 minutes |

---

## Execution Order

### Step 1: Transform Layer
```sql
USE ROLE MEDICORE_DATA_ENGINEER;

-- Reference domain first (no dependencies)
@infrastructure/11_medallion/01_transform_layer/01_reference/01_dim_departments.sql
@infrastructure/11_medallion/01_transform_layer/01_reference/02_dim_icd10_codes.sql

-- Clinical domain
@infrastructure/11_medallion/01_transform_layer/02_clinical/01_patients.sql
@infrastructure/11_medallion/01_transform_layer/02_clinical/02_providers.sql
@infrastructure/11_medallion/01_transform_layer/02_clinical/03_encounters.sql
@infrastructure/11_medallion/01_transform_layer/02_clinical/04_lab_results.sql

-- Billing domain
@infrastructure/11_medallion/01_transform_layer/03_billing/01_claims.sql
@infrastructure/11_medallion/01_transform_layer/03_billing/02_claim_line_items.sql
```

### Step 2: Analytics Layer
```sql
-- Clinical Dynamic Tables
@infrastructure/11_medallion/02_analytics_layer/02_clinical/*.sql

-- Billing Dynamic Tables
@infrastructure/11_medallion/02_analytics_layer/03_billing/*.sql

-- Executive KPIs
@infrastructure/11_medallion/02_analytics_layer/04_executive/*.sql

-- De-identified Tables
@infrastructure/11_medallion/02_analytics_layer/05_deidentified/*.sql
```

### Step 3: AI-Ready Layer
```sql
-- Features
@infrastructure/11_medallion/03_ai_ready_layer/01_features/*.sql

-- Training Sets
@infrastructure/11_medallion/03_ai_ready_layer/02_training/*.sql

-- Semantic Model
@infrastructure/11_medallion/03_ai_ready_layer/03_semantic/*.sql

-- Embeddings
@infrastructure/11_medallion/03_ai_ready_layer/04_embeddings/*.sql
```

### Full Deployment
```sql
-- Run master script for complete deployment
@infrastructure/11_medallion/99_master_run.sql
```

---

## Verification Queries

```sql
-- Verify Dynamic Tables in Transform layer
SHOW DYNAMIC TABLES IN DATABASE MEDICORE_TRANSFORM_DB;

-- Verify Dynamic Tables in Analytics layer
SHOW DYNAMIC TABLES IN DATABASE MEDICORE_ANALYTICS_DB;

-- Check Dynamic Table refresh status
SELECT 
    NAME,
    DATABASE_NAME,
    SCHEMA_NAME,
    TARGET_LAG,
    REFRESH_MODE,
    SCHEDULING_STATE
FROM TABLE(INFORMATION_SCHEMA.DYNAMIC_TABLES())
WHERE DATABASE_NAME LIKE 'MEDICORE%'
ORDER BY DATABASE_NAME, SCHEMA_NAME, NAME;

-- Verify Executive KPIs
SELECT * FROM MEDICORE_ANALYTICS_DB.DEV_EXECUTIVE.KPI_PATIENT_VOLUME LIMIT 5;

-- Verify De-identified data
SELECT * FROM MEDICORE_ANALYTICS_DB.DEV_DEIDENTIFIED.PATIENTS LIMIT 5;
```

---

## Object Counts

| Layer | Database | Dynamic Tables | Static Tables | Total |
|-------|----------|----------------|---------------|-------|
| Transform | TRANSFORM_DB | 8 | 0 | 8 |
| Analytics | ANALYTICS_DB | 8 | 6 | 14 |
| AI-Ready | AI_READY_DB | 4 | 5 | 9 |
| **Total** | | **20** | **11** | **31** |

---

## Data Quality Integration

All Dynamic Tables include:
- `DATA_QUALITY_STATUS` column (CERTIFIED, UNDER_REVIEW, QUARANTINED)
- `LOAD_TIMESTAMP` for lineage tracking
- `RECORD_SOURCE` for source system identification

---

## Governance Integration

### PHI Columns Tagged

After deployment, apply governance tags:

```sql
-- Example: Tag PHI columns
ALTER TABLE MEDICORE_ANALYTICS_DB.PROD_CLINICAL.PATIENTS
    MODIFY COLUMN FIRST_NAME
    SET TAG MEDICORE_GOVERNANCE_DB.TAGS.PHI_CLASSIFICATION = 'DIRECT_IDENTIFIER';

ALTER TABLE MEDICORE_ANALYTICS_DB.PROD_CLINICAL.PATIENTS
    MODIFY COLUMN DATE_OF_BIRTH
    SET TAG MEDICORE_GOVERNANCE_DB.TAGS.PHI_CLASSIFICATION = 'QUASI_IDENTIFIER';
```

---

## Summary

| Metric | Value |
|--------|-------|
| Total Objects Created | 31 |
| Dynamic Tables | 20 |
| Static Tables | 11 |
| Data Domains | 3 (Reference, Clinical, Billing) |
| Executive KPIs | 3 |
| De-identified Datasets | 3 |
| ML Training Sets | 2 |
| Embedding Tables | 2 |
| Maximum Pipeline Latency | 25 minutes |

## Next Phase

Proceed to **[Phase 12: HCLS Data Model](12_phase_hcls_data_model.md)** to create source tables in RAW_DB with seed data.
