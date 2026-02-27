Snowflake Medicore Platform# MediCore Health Systems — Snowflake Data Platform

**An Enterprise Data Platform for Healthcare & Life Sciences**

---

## What is MediCore?

MediCore is a fictional healthcare company. This repository contains a **complete, production-ready Snowflake data platform** designed for HIPAA compliance, built using real-world enterprise patterns.

Think of it as a reference architecture — every script, role, tag, and dashboard is something you could deploy in an actual healthcare organization.

---

## The Big Picture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        MediCore Snowflake Platform                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   BRONZE              SILVER              GOLD               PLATINUM       │
│   ┌─────────┐        ┌─────────┐        ┌─────────┐        ┌─────────┐      │
│   │ RAW_DB  │   →    │TRANSFORM│   →    │ANALYTICS│   →    │AI_READY │      │
│   │         │        │   _DB   │        │   _DB   │        │   _DB   │      │
│   └─────────┘        └─────────┘        └─────────┘        └─────────┘      │
│   Source data        Cleansed &         Business-ready      ML Features     │
│   as-received        Conformed          Models & KPIs       & Embeddings    │
│                                                                             │
│   + GOVERNANCE_DB — Tags, Policies, Audit Logs                              │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│   18 Roles  │  4 Warehouses  │  13 Tags  │  3 Streamlit Dashboards          │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Implementation Phases

| Phase | Name | What It Does |
|-------|------|--------------|
| 01 | Account Admin | Network policies, account parameters, governance database |
| **02** | **RBAC** | **18 roles with least-privilege access (detailed below)** |
| 03 | Warehouses | 4 warehouses: Admin, ETL, Analytics, ML |
| **04** | **Database Structure** | **5 databases, 56 schemas, PROD/QA/DEV isolation** |
| 05 | Resource Monitors | Credit limits and alerts |
| 06 | Monitoring Views | Operational dashboards |
| 07 | Alerts | Cost and queue notifications |
| **08** | **Data Governance** | **Masking policies, row access policies, 13 tags** |
| 09 | Audit | Compliance audit trail |
| 10 | Verification | Test scripts for all phases |
| **11** | **Medallion Architecture** | **Transform → Analytics → AI-Ready pipeline** |
| 12 | HCLS Data Model | 8 tables across 3 domains |
| 13 | AI-Ready Layer | Features, embeddings, semantic models |
| 14 | GitHub CI/CD | Schemachange deployments |
| 15 | Azure DevOps | Alternative CI/CD option |

---

# Phase 02 — Role-Based Access Control (RBAC)

## The Problem We're Solving

In healthcare, **who can see what** isn't just a policy — it's the law (HIPAA). A physician needs full patient records. A billing clerk needs financial data but not clinical notes. An external auditor needs data, but absolutely no PHI.

## Our Solution: 18 Purpose-Built Roles

### How the Hierarchy Works

```
ACCOUNTADMIN
└── MEDICORE_PLATFORM_ADMIN (account management, no data access)

Data Access Tree:

MEDICORE_REFERENCE_READER (base — lookup tables only)
├── MEDICORE_ANALYST_RESTRICTED → MEDICORE_ANALYST_PHI → MEDICORE_DATA_ENGINEER
├── MEDICORE_CLINICAL_READER → MEDICORE_CLINICAL_NURSE → MEDICORE_CLINICAL_PHYSICIAN
└── MEDICORE_BILLING_READER → MEDICORE_BILLING_SPECIALIST

Standalone Roles (no inheritance):
  MEDICORE_SVC_ETL_LOADER        (automated data loading)
  MEDICORE_SVC_GITHUB_ACTIONS    (CI/CD deployments)
  MEDICORE_EXT_AUDITOR           (external audit access)
  MEDICORE_APP_STREAMLIT         (dashboard application)
  MEDICORE_DATA_SCIENTIST        (ML/AI development)
  MEDICORE_COMPLIANCE_OFFICER    (full audit + policy authoring)
  MEDICORE_EXECUTIVE             (aggregated KPIs only)
```

### What Each Role Can Actually See

| Role | PHI Access | What They Access |
|------|-----------|------------------|
| **CLINICAL_PHYSICIAN** | Full clinical PHI | Complete patient records, lab results, diagnoses |
| **CLINICAL_NURSE** | PHI with financial masking | Patient care data, unit-restricted by row access policy |
| **CLINICAL_READER** | Name + MRN only | Basic patient lookup |
| **BILLING_SPECIALIST** | Billing PHI | Claims, charges, payments — clinical notes masked |
| **BILLING_READER** | Aggregates only | Revenue summaries, no patient-level data |
| **ANALYST_PHI** | Full patient-level | Cross-domain analysis with PHI |
| **ANALYST_RESTRICTED** | None | De-identified data and executive summaries only |
| **DATA_SCIENTIST** | Full | ML feature engineering across all layers |
| **EXECUTIVE** | None | KPI dashboards — counts and totals only |
| **EXT_AUDITOR** | None | Pre-staged de-identified extracts |

### Why Service Accounts Are Isolated

`MEDICORE_SVC_ETL_LOADER` and `MEDICORE_SVC_GITHUB_ACTIONS` inherit from nothing. If a credential is compromised, the blast radius is exactly what's granted to that account — nothing more.

---

# Phase 04 — Database Structure

## The Five Databases

| Database | Layer | Purpose |
|----------|-------|---------|
| `MEDICORE_GOVERNANCE_DB` | — | Tags, policies, audit logs |
| `MEDICORE_RAW_DB` | Bronze | Source data exactly as received |
| `MEDICORE_TRANSFORM_DB` | Silver | Cleansed, validated, conformed |
| `MEDICORE_ANALYTICS_DB` | Gold | Business-ready models |
| `MEDICORE_AI_READY_DB` | Platinum | ML features, embeddings, semantic models |

## Environment Isolation: PROD / QA / DEV

Every data database has three environments:

```
MEDICORE_RAW_DB
├── PROD_CLINICAL     ← Real PHI lives here
├── PROD_BILLING
├── PROD_REFERENCE
├── QA_CLINICAL       ← Synthetic data only
├── QA_BILLING
├── QA_REFERENCE
├── DEV_CLINICAL      ← Synthetic data only
├── DEV_BILLING
└── DEV_REFERENCE
```

**Critical Rule:** Real PHI only exists in `PROD_*` schemas. QA and DEV contain synthetic data. This is enforced by:
1. ETL pipelines target only PROD schemas
2. `MEDICORE_SVC_ETL_LOADER` has grants only on PROD schemas
3. Row access policies condition on the `ENVIRONMENT` tag

## Schema Count by Database

| Database | Schemas | Purpose |
|----------|---------|---------|
| GOVERNANCE_DB | 5 | SECURITY, POLICIES, TAGS, DATA_QUALITY, AUDIT |
| RAW_DB | 9 | 3 domains × 3 environments |
| TRANSFORM_DB | 9 | 3 domains × 3 environments |
| ANALYTICS_DB | 18 | 6 domains × 3 environments |
| AI_READY_DB | 15 | 5 domains × 3 environments |
| **Total** | **56** | |

---

# Phase 08 — Data Governance

## The Challenge

Healthcare data has layers of sensitivity:
- **Direct identifiers** (SSN, MRN, Name) — these identify a person directly
- **Quasi-identifiers** (DOB, ZIP) — these can re-identify when combined
- **Sensitive clinical** (diagnoses, medications) — sensitive but not directly identifying
- **De-identified** — safe for external sharing

Different roles need different views of the same data.

## Our Solution: Tag-Based Dynamic Masking

### The 13 Tags

| Category | Tags | What They Control |
|----------|------|-------------------|
| **PHI Classification** | PHI_CLASSIFICATION, PHI_ELEMENT_TYPE | Masking policy triggers |
| **Data Domain** | DATA_DOMAIN, DATA_SUBDOMAIN | Access routing by business area |
| **Data Quality** | DATA_QUALITY_STATUS, DQ_ISSUE_TYPE | Downstream consumption guidance |
| **Pipeline/Lineage** | MEDALLION_LAYER, ENVIRONMENT, SOURCE_SYSTEM, REFRESH_FREQUENCY | Tracking and SLA monitoring |
| **Regulatory** | REGULATORY_FRAMEWORK, CONSENT_REQUIRED, RETENTION_POLICY | Compliance enforcement |

### How Masking Works

When you query a table, masking policies check:

1. **What tag is on this column?** (PHI_CLASSIFICATION)
2. **What role is running this query?** (CURRENT_ROLE())
3. **What should this role see?**

```sql
-- Example: DATE_OF_BIRTH column tagged as QUASI_IDENTIFIER

-- MEDICORE_CLINICAL_PHYSICIAN sees:    1985-03-15
-- MEDICORE_CLINICAL_NURSE sees:        1985-03-15  (same — clinical role)
-- MEDICORE_BILLING_READER sees:        1985       (year only)
-- MEDICORE_EXT_AUDITOR sees:           35-49      (age bucket)
```

### PHI Classification Values

| Value | What It Means | Masking Behavior |
|-------|---------------|------------------|
| `DIRECT_IDENTIFIER` | The 18 HIPAA Safe Harbor identifiers | SHA256 hash or `***REDACTED***` |
| `QUASI_IDENTIFIER` | Can re-identify when combined | Generalize (DOB→year, ZIP→3 digits) |
| `SENSITIVE_CLINICAL` | Diagnoses, medications, lab results | Role-restricted visibility |
| `DE_IDENTIFIED` | Already safe for sharing | No masking needed |
| `NON_PHI` | Administrative data | No restrictions |

### Special Case: 42 CFR Part 2

Substance abuse records require explicit written consent even for treatment purposes. Any object tagged `DATA_SUBDOMAIN = SUBSTANCE_ABUSE` automatically inherits the most restrictive consent requirements.

---

# Phase 11 — Medallion Architecture

## The Data Flow

```
Source Systems (EPIC, Claims)
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│                        BRONZE (RAW_DB)                          │
│  Source data exactly as received. No transformations.           │
│  Tables: PATIENTS, ENCOUNTERS, CLAIMS, LAB_RESULTS, etc.        │
└─────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│                      SILVER (TRANSFORM_DB)                      │
│  Cleansed, validated, conformed. Business rules applied.        │
│  Added: Surrogate keys, data quality flags, standardized codes  │
└─────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│                       GOLD (ANALYTICS_DB)                       │
│  Business-ready models. Masking policies enforced.              │
│  Schemas: CLINICAL, BILLING, REFERENCE, EXECUTIVE, DEIDENTIFIED │
└─────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│                     PLATINUM (AI_READY_DB)                      │
│  ML features, training datasets, embeddings, semantic models    │
│  Schemas: FEATURES, TRAINING, EMBEDDINGS, SEMANTIC              │
└─────────────────────────────────────────────────────────────────┘
```

## The Data Model (8 Tables, 3 Domains)

### Reference Domain
| Table | Purpose | Row Count (Dev) |
|-------|---------|-----------------|
| DIM_DEPARTMENTS | Hospital departments | 15 |
| DIM_ICD10_CODES | Diagnosis codes | 500 |

### Clinical Domain
| Table | Purpose | Key Fields |
|-------|---------|------------|
| PATIENTS | Patient demographics | PATIENT_ID, MRN, DOB, GENDER |
| PROVIDERS | Physician/nurse master | PROVIDER_ID, SPECIALTY, DEPARTMENT_ID |
| ENCOUNTERS | Hospital visits | ENCOUNTER_ID, ADMISSION_DATE, DISCHARGE_DATE |
| LAB_RESULTS | Lab test results | LAB_RESULT_ID, TEST_NAME, RESULT_VALUE, IS_ABNORMAL |

### Billing Domain
| Table | Purpose | Key Fields |
|-------|---------|------------|
| CLAIMS | Insurance claims | CLAIM_ID, ENCOUNTER_ID, BILLED_AMOUNT, STATUS |
| CLAIM_LINE_ITEMS | Claim details | LINE_ITEM_ID, CLAIM_ID, CPT_CODE, AMOUNT |

## Analytics Layer Outputs

### Executive KPIs (No PHI)

**Patient Volume KPIs:**
- Total distinct patients by month
- New patient acquisition
- Active patients (last 30 days)
- Average encounters per patient

**Revenue KPIs:**
- Total billed amount
- Net revenue
- Denial rate percentage
- Revenue per encounter

**Clinical Outcomes KPIs:**
- Readmission rates
- Average length of stay
- Abnormal lab result rates

### De-identified Datasets

HIPAA Safe Harbor compliant:
- DOB → Birth Year + Age Bucket (0-17, 18-34, 35-49, 50-64, 65-79, 80+)
- ZIP → First 3 digits only
- Names, MRN, SSN → Removed entirely

## AI-Ready Layer

### Feature Engineering
- **Patient Features:** Demographics, visit history, risk scores
- **Encounter Features:** Length of stay patterns, department utilization

### Training Datasets
- **Readmission Prediction:** 30-day readmission labels with clinical features
- **Claims Denial Prediction:** Denial flags with claim characteristics

### Embeddings
- **Clinical Notes:** Vector embeddings for semantic search
- **Diagnoses:** ICD-10 code embeddings for similarity analysis

### Semantic Models
- Natural language query interfaces via Cortex Analyst

---

# Streamlit Dashboards

## Three Purpose-Built Dashboards

### 1. Clinical Operations Dashboard
**Role:** MEDICORE_CLINICAL_* roles  
**Data Source:** MEDICORE_ANALYTICS_DB.DEV_CLINICAL

| Metric | What It Shows |
|--------|---------------|
| Total Encounters | Volume by date range |
| Inpatient vs Outpatient | Care setting breakdown |
| Average Length of Stay | Days per encounter |
| Department Workload | Top 10 departments by volume |
| Abnormal Lab Rate | Lab monitoring trend |

**Filters:** Date range, Department, Encounter type

### 2. Revenue & Claims Dashboard
**Role:** MEDICORE_BILLING_* roles  
**Data Source:** MEDICORE_ANALYTICS_DB.DEV_BILLING

| Metric | What It Shows |
|--------|---------------|
| Total Claims | Volume by month |
| Billed Amount | Revenue in dollars |
| Denial Rate | Percentage of denied claims |
| Revenue by Payer | Commercial vs Government vs Self-Pay |
| Claim Status | Paid vs Pending vs Denied breakdown |

**Filters:** Date range, Payer type, Claim status

### 3. Executive KPI Dashboard
**Role:** MEDICORE_EXECUTIVE, MEDICORE_ANALYST_RESTRICTED  
**Data Source:** MEDICORE_ANALYTICS_DB.DEV_EXECUTIVE

| Metric | What It Shows |
|--------|---------------|
| Patient Volume | Monthly trend with new patient acquisition |
| Revenue Summary | Net revenue trend with denial rates |
| Clinical Outcomes | Readmission and length of stay trends |

**Key Point:** This dashboard contains NO PHI. Executives see aggregated counts and totals only.

---

# Repository Structure

```
medicore-snowflake-platform/
├── .github/workflows/
│   └── 01-snowflake_deploy.yml      # GitHub Actions CI/CD
│
├── docs/
│   ├── 01_phase_account_admin.md    # Phase documentation
│   ├── 02_phase_rbac.md
│   ├── ...
│   └── design-decisions/
│       ├── rbac-design.md           # 18 roles explained
│       └── tag-taxonomy.md          # 13 tags explained
│
├── infrastructure/
│   ├── 01_account-admin/
│   ├── 02_rbac/
│   │   └── 02_rbac_setup.sql        # All 18 roles
│   ├── 03_warehouses/
│   ├── 04_databases/
│   │   └── 04_database_structure.sql # 5 DBs, 56 schemas
│   ├── 05_resource-monitors/
│   ├── 06_monitoring/
│   ├── 07_alerts/
│   ├── 08_governance/
│   │   └── 08_data_governance.sql   # Tags, masking, RAP
│   ├── 09_audit/
│   ├── 10_verification/
│   ├── 11_medallion/
│   │   ├── 01_transform_layer/      # Silver transformations
│   │   ├── 02_analytics_layer/      # Gold models + KPIs
│   │   │   ├── 04_executive/        # KPI aggregations
│   │   │   └── 05_deidentified/     # Safe Harbor datasets
│   │   └── 03_ai_ready_layer/       # Platinum ML features
│   ├── 12_hcls-data/                # Raw table definitions
│   └── 14_cicd/
│
├── migrations/                       # Schemachange versioned migrations
│
├── streamlit/
│   ├── 01_clinical_operations_dashboard.py
│   ├── 02_revenue_and_claims_dashboard.py
│   └── 03_executive_kpi_dashboard.py
│
└── tests/                           # Phase verification scripts
```

---

# Deployment

## Prerequisites

1. Snowflake Business Critical account (for masking policies)
2. ACCOUNTADMIN role access
3. GitHub repository with Actions enabled

## Deployment Order

Execute phases in numerical order:

```bash
# Phase 01 — Account setup
snowsql -f infrastructure/01_account-admin/01_account_administration.sql

# Phase 02 — Create all 18 roles
snowsql -f infrastructure/02_rbac/02_rbac_setup.sql

# Phase 03 — Create warehouses
snowsql -f infrastructure/03_warehouses/03_warehouse_management.sql

# Phase 04 — Create databases and schemas
snowsql -f infrastructure/04_databases/04_database_structure.sql

# ... continue through Phase 14
```

## CI/CD with Schemachange

Once GitHub Actions is configured:

1. Push to feature branch → deploys to DEV schemas
2. Merge to main → deploys to QA schemas
3. Tagged release → deploys to PROD schemas (manual approval)

---

# Key Design Decisions

| Decision | Why We Made It |
|----------|----------------|
| **ACCOUNTADMIN owns all schemas** | CI/CD compatibility — Schemachange can deploy to any schema |
| **18 roles, not fewer** | Least privilege — each function gets exactly what it needs |
| **Service accounts have no inheritance** | Blast radius containment — compromised credential = limited damage |
| **PHI only in PROD schemas** | Defense in depth — QA/DEV never see real patient data |
| **Tags drive masking policies** | Maintainability — change the tag, change the behavior everywhere |
| **Executive dashboards use pre-aggregated tables** | Performance + security — no PHI exposure risk |

---

# Quick Reference

## Role → Database Access

| Role | RAW | TRANSFORM | ANALYTICS | AI_READY | GOVERNANCE |
|------|-----|-----------|-----------|----------|------------|
| DATA_ENGINEER | Full | Full | Full | Full | DQ, Audit |
| CLINICAL_PHYSICIAN | — | — | PROD_CLINICAL | — | — |
| BILLING_SPECIALIST | — | — | PROD_BILLING | — | — |
| ANALYST_PHI | — | — | All PROD | Features, Training | — |
| ANALYST_RESTRICTED | — | — | Executive, Deidentified | — | — |
| EXECUTIVE | — | — | Executive only | — | — |
| EXT_AUDITOR | — | — | Deidentified only | — | — |

## Tag → Masking Behavior

| Tag Value | What Happens |
|-----------|--------------|
| DIRECT_IDENTIFIER | Hash or redact for most roles |
| QUASI_IDENTIFIER | Generalize (DOB→year, ZIP→3 digits) |
| SENSITIVE_CLINICAL | Pass-through for clinical roles |
| DE_IDENTIFIED | No masking needed |
| NON_PHI | No restrictions |

---

## Questions?

This repository is a reference architecture. Review the design decision documents in `docs/design-decisions/` for detailed rationale on every choice.
