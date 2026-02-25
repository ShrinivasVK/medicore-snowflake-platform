# MediCore Health Systems — Data Platform Design Document  
## PART 1 — TAG TAXONOMY DESIGN  
Version: 1.0  
Date: February 2026  
Status: Draft — Pending Review  

---

## Overview

MediCore's tag taxonomy enables automated data classification, policy enforcement, and compliance tracking across all four medallion layers. Tags are organized into five categories, each serving distinct governance purposes.

---

# 1.1 PHI Classification Tags# MediCore Health Systems — Data Platform Design Document
## PART 1 — TAG TAXONOMY DESIGN
Version: 2.0.0
Date: February 2026
Status: Active — Implemented through Phase 04

> **Change Summary (v1.0 → v2.0.0)**
> - `ENVIRONMENT` tag added (Section 1.4) — required for schema-level environment isolation introduced in Phase 04 (PROD/QA/DEV schemas). This tag was referenced in `MEDICORE_GOVERNANCE_DB.TAGS` schema design but was absent from v1.0.
> - `MEDALLION_LAYER` table updated: all database names updated to `MEDICORE_` prefix. Time Travel retention values (Snowflake `DATA_RETENTION_TIME_IN_DAYS`) separated from logical retention (business archive policy) — these are different concepts and were conflated in v1.0.
> - Overview updated to reference all five MEDICORE databases (including `MEDICORE_GOVERNANCE_DB`).
> - Tag Taxonomy Summary updated: total tags increases from 12 to 13.
> - Masking-capable tag list unchanged (4 tags).

---

## Overview

MediCore's tag taxonomy enables automated data classification, policy enforcement, and compliance tracking across all five MEDICORE databases:

- `MEDICORE_GOVERNANCE_DB` — Policy definitions, tags, data quality rules, governance audit logs
- `MEDICORE_RAW_DB` — Bronze: source data as received
- `MEDICORE_TRANSFORM_DB` — Silver: cleansed and conformed data
- `MEDICORE_ANALYTICS_DB` — Gold: business-ready models and dashboards
- `MEDICORE_AI_READY_DB` — Platinum: ML features, training datasets, embeddings, semantic models

Tags are created in `MEDICORE_GOVERNANCE_DB.TAGS` and applied to objects across all databases. Tags are organized into six categories, each serving distinct governance purposes. Tags applied to PROD schemas carry regulatory weight; the same tag values applied to QA and DEV schemas serve documentation and lineage purposes only.

---

# 1.1 PHI Classification Tags

## Tag: PHI_CLASSIFICATION

**Purpose:** Classify protected health information by HIPAA identifier type to enable tag-based masking policies. This is the primary masking trigger tag — masking policies in Phase 08 will condition on this tag value.

**Schema location:** `MEDICORE_GOVERNANCE_DB.TAGS`
**Applied to:** Columns in `MEDICORE_ANALYTICS_DB.PROD_CLINICAL`, `PROD_BILLING`, and `MEDICORE_AI_READY_DB.PROD_FEATURES`, `PROD_TRAINING`, `PROD_EMBEDDINGS`

| Allowed Value | Definition | Masking Behavior | Example Columns |
|---|---|---|---|
| `DIRECT_IDENTIFIER` | The 18 HIPAA Safe Harbor identifiers that directly identify an individual | Full mask: SHA256 hash or `'***REDACTED***'` | SSN, MRN, PATIENT_NAME, EMAIL, PHONE, FAX, DRIVERS_LICENSE, PASSPORT_NUMBER, HEALTH_PLAN_ID, ACCOUNT_NUMBER, CERTIFICATE_NUMBER, VEHICLE_ID, DEVICE_ID, URL, IP_ADDRESS, BIOMETRIC_ID, FULL_FACE_PHOTO |
| `QUASI_IDENTIFIER` | Indirect identifiers that can re-identify a patient when combined with other fields | Partial mask or generalization: DOB → year only, ZIP → first 3 digits | DATE_OF_BIRTH, ZIP_CODE, ADMISSION_DATE, DISCHARGE_DATE, SERVICE_DATE, AGE |
| `SENSITIVE_CLINICAL` | Clinical data revealing medical conditions or treatments — does not directly identify but is sensitive | Role-restricted visibility, not masked at column level — controlled by row access policies | DIAGNOSIS_CODE, PROCEDURE_CODE, MEDICATION_NAME, LAB_RESULT, VITAL_SIGNS |
| `DE_IDENTIFIED` | Data properly de-identified per HIPAA Safe Harbor method. All 18 identifiers removed or generalized | No masking required — safe for `PROD_DEIDENTIFIED` schema and `MEDICORE_EXT_AUDITOR` | AGE_BUCKET, ZIP_3_DIGIT, YEAR_ONLY_DATE |
| `NON_PHI` | Administrative or operational data with no patient linkage whatsoever | No restrictions — no masking required | FACILITY_CODE, DEPARTMENT_ID, COST_CENTER |

**Supports Tag-Based Masking:** ✅ Yes

### Masking Policy Strategy

Masking policies (Phase 08) will read the `PHI_CLASSIFICATION` tag value at query time and apply the following logic:

- `DIRECT_IDENTIFIER` → SHA256 hash or `'***REDACTED***'` for all roles except `MEDICORE_CLINICAL_PHYSICIAN` and `MEDICORE_COMPLIANCE_OFFICER`
- `QUASI_IDENTIFIER` → Generalization (DOB → year only, ZIP → first 3 digits) for roles below `MEDICORE_CLINICAL_NURSE` in the hierarchy
- `SENSITIVE_CLINICAL` → Pass-through for roles with clinical access; row access policy governs visibility
- `DE_IDENTIFIED` / `NON_PHI` → Always pass-through, no masking applied

---

## Tag: PHI_ELEMENT_TYPE

**Purpose:** Granular classification of the specific PHI element type for audit reporting, breach impact assessment, and targeted policy application. Works alongside `PHI_CLASSIFICATION` — a column tagged `PHI_CLASSIFICATION = DIRECT_IDENTIFIER` should also carry a `PHI_ELEMENT_TYPE` value for precise incident reporting.

**Schema location:** `MEDICORE_GOVERNANCE_DB.TAGS`

| Allowed Value | Definition | Example Columns |
|---|---|---|
| `NAME` | Patient or provider full names or components | PATIENT_FIRST_NAME, PATIENT_LAST_NAME, PROVIDER_NAME |
| `GEOGRAPHIC` | Address, city, state, ZIP (5-digit) | STREET_ADDRESS, CITY, STATE, ZIP_CODE |
| `DATE` | All dates except year alone | DATE_OF_BIRTH, ADMISSION_DATE, DEATH_DATE, DISCHARGE_DATE |
| `CONTACT` | Phone numbers, fax numbers, email addresses | PHONE_NUMBER, FAX_NUMBER, EMAIL_ADDRESS |
| `IDENTIFIER_GOVT` | Government-issued identification numbers | SSN, DRIVERS_LICENSE, PASSPORT_NUMBER |
| `IDENTIFIER_HEALTH` | Health system and payer identifiers | MRN, HEALTH_PLAN_ID, ACCOUNT_NUMBER, CERTIFICATE_NUMBER |
| `IDENTIFIER_DEVICE` | Device and vehicle serial numbers or identifiers | DEVICE_SERIAL_NUMBER, VEHICLE_VIN |
| `IDENTIFIER_DIGITAL` | Digital network identifiers | IP_ADDRESS, URL, MAC_ADDRESS |
| `BIOMETRIC` | Biometric data unique to an individual | FINGERPRINT_HASH, RETINA_SCAN, VOICE_PRINT |
| `PHOTOGRAPH` | Full-face photographic images | PATIENT_PHOTO |

**Supports Tag-Based Masking:** ✅ Yes (used in conjunction with `PHI_CLASSIFICATION` for fine-grained breach reporting)

---

# 1.2 Data Domain Tags

## Tag: DATA_DOMAIN

**Purpose:** Classify data by business domain for access control routing, data stewardship assignment, and cross-domain impact analysis. Drives the schema naming convention across all MEDICORE databases (`PROD_CLINICAL`, `PROD_BILLING`, `PROD_REFERENCE`, etc.).

**Schema location:** `MEDICORE_GOVERNANCE_DB.TAGS`
**Applied to:** Schemas and tables across all MEDICORE databases

| Allowed Value | Definition | Owner Team | Example Tables |
|---|---|---|---|
| `CLINICAL` | Patient care, medical records, clinical encounters | Clinical Informatics | ENCOUNTERS, DIAGNOSES, PROCEDURES, MEDICATIONS |
| `BILLING` | Charge capture, payments, revenue cycle | Revenue Cycle | CHARGES, PAYMENTS, ADJUSTMENTS |
| `CLAIMS` | Insurance claims processing and remittance | Claims Operations | CLAIMS, DENIALS, REMITTANCES |
| `SCHEDULING` | Appointment and resource scheduling | Operations | APPOINTMENTS, RESOURCE_SLOTS |
| `PROVIDER` | Provider demographics and credentialing | Medical Staff Office | PROVIDERS, PROVIDER_CREDENTIALS |
| `PATIENT` | Patient master demographics and identity | Health Information Management | PATIENTS, PATIENT_ALIASES |
| `REFERENCE` | Code sets, lookup tables, and master data | Governance | ICD10_CODES, CPT_CODES, DIM_DEPARTMENTS |
| `OPERATIONAL` | Non-clinical operational data | Operations | BED_CENSUS, FACILITY_CAPACITY |
| `FINANCIAL` | General ledger and accounting | Finance | GL_TRANSACTIONS, COST_ALLOCATIONS |
| `QUALITY` | Outcomes measurement and quality metrics | Compliance & Quality | QUALITY_MEASURES, CORE_MEASURES |
| `AUDIT` | Pipeline audit logs and governance audit trails | Platform Engineering | PIPELINE_RUN_LOG, GRANT_AUDIT_TRAIL |
| `ML_FEATURE` | Machine learning feature definitions and values | Data Science | PATIENT_RISK_FEATURES, READMISSION_FEATURES |

**Supports Tag-Based Masking:** ❌ No (domain classification only; PHI masking triggered by `PHI_CLASSIFICATION`)

---

## Tag: DATA_SUBDOMAIN

**Purpose:** Secondary classification for granular access control within a domain. Critical for 42 CFR Part 2 compliance — substance abuse records require a separate, more restrictive consent policy than general clinical PHI and must be flagged at this level.

**Schema location:** `MEDICORE_GOVERNANCE_DB.TAGS`

| Allowed Value | Parent Domain | PHI Sensitivity | Example Tables |
|---|---|---|---|
| `INPATIENT` | `CLINICAL` | PHI | INPATIENT_ENCOUNTERS, INPATIENT_DIAGNOSES |
| `OUTPATIENT` | `CLINICAL` | PHI | OUTPATIENT_VISITS, AMBULATORY_ENCOUNTERS |
| `PHARMACY` | `CLINICAL` | PHI | MEDICATION_ORDERS, DISPENSING_RECORDS |
| `LABORATORY` | `CLINICAL` | PHI | LAB_RESULTS, SPECIMEN_RECORDS |
| `RADIOLOGY` | `CLINICAL` | PHI | RADIOLOGY_REPORTS, IMAGING_ORDERS |
| `BEHAVIORAL_HEALTH` | `CLINICAL` | PHI (heightened) | BH_ASSESSMENTS, PSYCH_NOTES |
| `SUBSTANCE_ABUSE` | `CLINICAL` | PHI (42 CFR Part 2) | 42CFR_RECORDS, SA_TREATMENT_EPISODES |
| `PROFESSIONAL` | `BILLING` | PII + Financial | PROFESSIONAL_CHARGES, PROVIDER_BILLING |
| `INSTITUTIONAL` | `BILLING` | PII + Financial | FACILITY_CHARGES, DRG_BILLING |
| `COMMERCIAL` | `CLAIMS` | PII + Financial | COMMERCIAL_CLAIMS, COMMERCIAL_EOB |
| `GOVERNMENT` | `CLAIMS` | PII + Financial | MEDICARE_CLAIMS, MEDICAID_CLAIMS |

> **Important:** Any object tagged `DATA_SUBDOMAIN = SUBSTANCE_ABUSE` is subject to 42 CFR Part 2, which prohibits disclosure without explicit written consent even for Treatment, Payment, and Operations purposes. The `CONSENT_REQUIRED` tag (Section 1.5) must always be co-applied with value `42CFR_CONSENT` on these objects.

---

# 1.3 Data Quality Tags

## Tag: DATA_QUALITY_STATUS

**Purpose:** Communicate the current quality validation state of a table or schema to downstream consumers. Populated by data quality check results stored in `MEDICORE_GOVERNANCE_DB.DATA_QUALITY`.

**Schema location:** `MEDICORE_GOVERNANCE_DB.TAGS`
**Applied to:** Tables in all MEDICORE databases

| Value | Meaning | Downstream Action |
|---|---|---|
| `VALIDATED` | Passed all data quality checks for the current load cycle | Safe for production use |
| `KNOWN_ISSUES` | One or more known quality issues exist; documented in DATA_QUALITY schema | Use with documented assumptions; check issue log before analysis |
| `QUARANTINED` | Failed critical data quality checks; do not use for analysis or reporting | Block from analytics consumption until resolved |
| `PENDING_VALIDATION` | Newly loaded data; quality checks not yet executed | Use cautiously; treat as provisional |
| `LEGACY_UNVALIDATED` | Historical data loaded before quality framework existed | Document all assumptions; flag findings for retroactive validation |

**Supports Tag-Based Masking:** ❌ No

---

## Tag: DQ_ISSUE_TYPE

**Purpose:** Categorize the type of data quality issue when `DATA_QUALITY_STATUS` is `KNOWN_ISSUES` or `QUARANTINED`. Enables issue-type filtering in the data quality dashboard.

**Schema location:** `MEDICORE_GOVERNANCE_DB.TAGS`

| Value | Description |
|---|---|
| `MISSING_VALUES` | Required fields contain NULL or empty values above threshold |
| `INVALID_FORMAT` | Values do not conform to expected format (e.g., dates, codes) |
| `OUT_OF_RANGE` | Numeric or date values fall outside clinically or operationally valid ranges |
| `DUPLICATE_RECORDS` | Duplicate keys or near-duplicate patient records detected |
| `REFERENTIAL_ORPHAN` | Foreign key values with no matching parent record |
| `STALE_DATA` | Data not refreshed within the expected frequency window |
| `ENCODING_ERROR` | Character encoding issues causing garbled or misrepresented values |
| `BUSINESS_RULE_VIOLATION` | Values that are individually valid but violate a cross-field or cross-table business rule |

**Supports Tag-Based Masking:** ❌ No

---

# 1.4 Pipeline / Lineage Tags

## Tag: MEDALLION_LAYER

**Purpose:** Identify which tier of the medallion architecture an object belongs to. Enables layer-aware lineage tracking, cost attribution by layer, and layer-specific governance rules.

**Schema location:** `MEDICORE_GOVERNANCE_DB.TAGS`
**Applied to:** All schemas and tables across all MEDICORE databases

| Value | Database | Schema Pattern | Snowflake Time Travel Retention | Logical Retention (Archive Policy) | Characteristics |
|---|---|---|---|---|---|
| `RAW` | `MEDICORE_RAW_DB` | `PROD_*`, `QA_*`, `DEV_*` | 90 days (PROD), standard (QA/DEV) | 7 years | Source copy — no transformations. PHI present in CLINICAL and BILLING. |
| `TRANSFORM` | `MEDICORE_TRANSFORM_DB` | `PROD_*`, `QA_*`, `DEV_*` | 30 days (PROD), standard (QA/DEV) | 3 years | Cleansed and conformed. PHI present. Business rules applied. |
| `ANALYTICS` | `MEDICORE_ANALYTICS_DB` | `PROD_*`, `QA_*`, `DEV_*` | 30 days (PROD), standard (QA/DEV) | 3 years | Business-ready dimensional models. Masking policies enforced on PROD. |
| `AI_READY` | `MEDICORE_AI_READY_DB` | `PROD_*`, `QA_*`, `DEV_*` | 14 days (PROD), standard (QA/DEV) | 2 years | ML features, embeddings, semantic models. Frequent iteration drives lower Time Travel retention. |
| `GOVERNANCE` | `MEDICORE_GOVERNANCE_DB` | `SECURITY`, `POLICIES`, `TAGS`, `DATA_QUALITY`, `AUDIT` | Standard | Indefinite | Policy definitions, tag catalog, governance audit trail. No source data. |

> **Clarification on retention values:** The *Snowflake Time Travel Retention* column reflects the `DATA_RETENTION_TIME_IN_DAYS` setting on the database as implemented in Phase 04. This controls how far back you can use `AT (TIMESTAMP => ...)` or `BEFORE (STATEMENT => ...)` to recover data. The *Logical Retention* column reflects the business archive policy — how long data must be preserved in some form (Time Travel, Fail-safe, or external archive) per HIPAA and operational requirements. These are distinct and must not be confused: a 90-day Time Travel window does not mean data is deleted after 90 days.

**Supports Tag-Based Masking:** ❌ No

---

## Tag: ENVIRONMENT

**Purpose:** Identify which deployment environment a schema belongs to. Introduced in Phase 04 with schema-level environment isolation. Critical for CI/CD governance — objects in `DEV` and `QA` environments must never contain real PHI. Tag enables environment-aware monitoring, alerting, and access policy enforcement.

**Schema location:** `MEDICORE_GOVERNANCE_DB.TAGS`
**Applied to:** All schemas across `MEDICORE_RAW_DB`, `MEDICORE_TRANSFORM_DB`, `MEDICORE_ANALYTICS_DB`, and `MEDICORE_AI_READY_DB`

| Value | Schema Prefix | PHI Permitted | Purpose | Deployment Trigger |
|---|---|---|---|---|
| `PROD` | `PROD_*` | ✅ Yes (governed) | Live production data — masking and row access policies enforced | Manual promotion approval or tagged release in GitHub Actions |
| `QA` | `QA_*` | ❌ No — synthetic data only | Quality assurance — Schemachange migration testing and data pipeline validation | Merge to `main` branch or QA promotion PR |
| `DEV` | `DEV_*` | ❌ No — synthetic data only | Development sandbox — schema evolution, pipeline prototyping, migration authoring | Push to feature branch |

> **Enforcement note:** The `ENVIRONMENT` tag is a documentation and monitoring control, not a security enforcement mechanism by itself. The guarantee that PHI never reaches QA or DEV schemas must be enforced by:
> 1. Data loading policies — ETL pipelines target only `PROD_*` schemas
> 2. `MEDICORE_SVC_ETL_LOADER` USAGE grants exist only on `PROD_*` schemas
> 3. Row access policies (Phase 08) will condition on this tag value to add a secondary enforcement layer

**Supports Tag-Based Masking:** ✅ Yes (secondary enforcement — policies condition on `ENVIRONMENT = PROD` before applying PHI masking logic)

---

## Tag: SOURCE_SYSTEM

**Purpose:** Track the originating upstream system for lineage, incident response, and data quality root cause analysis. When a data quality issue is found, this tag identifies which source system feed to investigate.

**Schema location:** `MEDICORE_GOVERNANCE_DB.TAGS`
**Applied to:** Tables in `MEDICORE_RAW_DB` and `MEDICORE_TRANSFORM_DB`

| Value | System Type | Interface Protocol |
|---|---|---|
| `EPIC` | EMR / Clinical | HL7 FHIR or direct extract |
| `CERNER` | EMR / Clinical | HL7 FHIR or direct extract |
| `MEDITECH` | EMR / Clinical | Direct extract |
| `CLAIMS_CLEARINGHOUSE` | Claims / Revenue | EDI 837 / 835 |
| `ELIGIBILITY_270_271` | Payer eligibility | EDI 270 / 271 |
| `LAB_INTERFACE` | Laboratory systems | HL7 v2 ORU |
| `PHARMACY_INTERFACE` | Pharmacy systems | NCPDP / HL7 |
| `MANUAL_ENTRY` | Manual data entry | Snowflake UI / CSV |
| `DERIVED` | Derived from other MEDICORE tables | Internal transformation |

**Supports Tag-Based Masking:** ❌ No

---

## Tag: REFRESH_FREQUENCY

**Purpose:** Document the expected data refresh cadence for SLA monitoring, freshness alerting, and consumer expectation management. Mismatches between the declared frequency and actual load timestamps trigger data quality alerts.

**Schema location:** `MEDICORE_GOVERNANCE_DB.TAGS`

| Value | Description |
|---|---|
| `REAL_TIME` | Continuous streaming; latency < 1 minute |
| `NEAR_REAL_TIME` | Micro-batch; latency 1–15 minutes |
| `HOURLY` | Once per hour |
| `DAILY` | Once per day (typically overnight) |
| `WEEKLY` | Once per week |
| `MONTHLY` | Once per month |
| `ON_DEMAND` | Triggered manually or by event |
| `STATIC` | Reference data; changes infrequently and only by deliberate update |

**Supports Tag-Based Masking:** ❌ No

---

# 1.5 Regulatory Compliance Tags

## Tag: REGULATORY_FRAMEWORK

**Purpose:** Identify which regulatory framework governs an object's data handling, retention, and disclosure requirements. Multiple frameworks may apply to a single table (e.g., a clinical record may be subject to both HIPAA and 42 CFR Part 2). When multiple values apply, apply the tag multiple times or use the most restrictive framework.

**Schema location:** `MEDICORE_GOVERNANCE_DB.TAGS`

| Value | Full Name | Applicability |
|---|---|---|
| `HIPAA` | Health Insurance Portability and Accountability Act | All PHI in all MEDICORE databases |
| `HITRUST` | Health Information Trust Alliance CSF | Platform-wide control framework |
| `42CFR_PART2` | Substance Abuse Confidentiality Regulations | Behavioral health and SA records specifically |
| `STATE_PRIVACY` | State-specific health privacy laws | State-specific data (CA CMIA, NY SHIELD, etc.) |
| `MEDICARE_COPs` | Medicare Conditions of Participation | Clinical quality and medical record requirements |
| `STARK_AKS` | Stark Law / Anti-Kickback Statute | Provider financial relationship data |
| `EMTALA` | Emergency Medical Treatment and Labor Act | Emergency encounter records |
| `CLIA` | Clinical Laboratory Improvement Amendments | Laboratory result records |
| `FDA_21CFR11` | FDA Electronic Records and Signatures | Clinical trial and research data |
| `GDPR` | General Data Protection Regulation | Any data involving EU residents |

**Supports Tag-Based Masking:** ✅ Yes — masking policies in Phase 08 will condition on `REGULATORY_FRAMEWORK = 42CFR_PART2` to enforce the most restrictive consent requirements

---

## Tag: CONSENT_REQUIRED

**Purpose:** Specify the type of patient consent required before data in this object can be disclosed or used. Drives the row access policy logic in Phase 08 — rows without an active consent record matching the required type will be filtered from query results for non-Treatment access.

**Schema location:** `MEDICORE_GOVERNANCE_DB.TAGS`

| Value | Consent Type | Regulatory Basis |
|---|---|---|
| `STANDARD_TPO` | Standard Treatment, Payment, Operations authorization | HIPAA Privacy Rule §164.506 |
| `EXPLICIT_WRITTEN` | Signed Authorization beyond TPO | HIPAA §164.508 |
| `42CFR_CONSENT` | Written consent specific to substance abuse records | 42 CFR Part 2 §2.31 |
| `RESEARCH_IRB` | IRB-approved research authorization | 45 CFR Part 46 (Common Rule) |
| `PSYCHOTHERAPY_NOTES` | Separate authorization for psychotherapy notes | HIPAA §164.508(a)(2) |
| `HIV_SPECIFIC` | State-specific HIV status disclosure consent | Varies by state |
| `GENETIC_GINA` | Genetic information consent | GINA Title II |

**Supports Tag-Based Masking:** ✅ Yes

---

## Tag: RETENTION_POLICY

**Purpose:** Specify the governing retention schedule for records in this object. Used by the data archival pipeline and compliance reporting to flag records approaching or exceeding their required retention period.

**Schema location:** `MEDICORE_GOVERNANCE_DB.TAGS`

| Value | Typical Minimum Retention | Regulatory Basis |
|---|---|---|
| `ADULT_MEDICAL_RECORD` | 10 years from last service date (varies by state) | State medical records laws + HIPAA |
| `MINOR_MEDICAL_RECORD` | Until age of majority + standard adult period | State law |
| `BILLING_RECORD` | 7 years | Medicare / Medicaid billing regulations |
| `MEDICARE_RECORD` | 10 years | Medicare Conditions of Participation |
| `MAMMOGRAPHY` | 5–10 years | MQSA (21 CFR Part 900) |
| `CLINICAL_TRIAL` | 15 years from study completion | FDA 21 CFR Part 312 |
| `EMPLOYEE_HEALTH` | Duration of employment + 30 years | OSHA 1910.1020 |
| `OPERATIONAL` | 3–7 years | General business record retention |

**Supports Tag-Based Masking:** ❌ No

---

# 1.6 Tag Taxonomy Summary

**Total Tags: 13**

| # | Tag Name | Category | Masking Support | Schema Location |
|---|---|---|---|---|
| 1 | `PHI_CLASSIFICATION` | PHI Classification | ✅ Yes | `MEDICORE_GOVERNANCE_DB.TAGS` |
| 2 | `PHI_ELEMENT_TYPE` | PHI Classification | ✅ Yes | `MEDICORE_GOVERNANCE_DB.TAGS` |
| 3 | `DATA_DOMAIN` | Data Domain | ❌ No | `MEDICORE_GOVERNANCE_DB.TAGS` |
| 4 | `DATA_SUBDOMAIN` | Data Domain | ❌ No | `MEDICORE_GOVERNANCE_DB.TAGS` |
| 5 | `DATA_QUALITY_STATUS` | Data Quality | ❌ No | `MEDICORE_GOVERNANCE_DB.TAGS` |
| 6 | `DQ_ISSUE_TYPE` | Data Quality | ❌ No | `MEDICORE_GOVERNANCE_DB.TAGS` |
| 7 | `MEDALLION_LAYER` | Pipeline / Lineage | ❌ No | `MEDICORE_GOVERNANCE_DB.TAGS` |
| 8 | `ENVIRONMENT` | Pipeline / Lineage | ✅ Yes (secondary) | `MEDICORE_GOVERNANCE_DB.TAGS` |
| 9 | `SOURCE_SYSTEM` | Pipeline / Lineage | ❌ No | `MEDICORE_GOVERNANCE_DB.TAGS` |
| 10 | `REFRESH_FREQUENCY` | Pipeline / Lineage | ❌ No | `MEDICORE_GOVERNANCE_DB.TAGS` |
| 11 | `REGULATORY_FRAMEWORK` | Regulatory Compliance | ✅ Yes | `MEDICORE_GOVERNANCE_DB.TAGS` |
| 12 | `CONSENT_REQUIRED` | Regulatory Compliance | ✅ Yes | `MEDICORE_GOVERNANCE_DB.TAGS` |
| 13 | `RETENTION_POLICY` | Regulatory Compliance | ❌ No | `MEDICORE_GOVERNANCE_DB.TAGS` |

**Tags Supporting Masking: 4 primary + 1 secondary = 5**

Primary masking tags (trigger masking policy conditions directly):
- `PHI_CLASSIFICATION` — primary PHI masking trigger
- `PHI_ELEMENT_TYPE` — element-level masking for breach reporting granularity
- `REGULATORY_FRAMEWORK` — triggers 42 CFR Part 2 special handling
- `CONSENT_REQUIRED` — drives consent-based row filtering

Secondary masking tag (conditional enforcement):
- `ENVIRONMENT` — masking policies only fully enforce on `ENVIRONMENT = PROD`; QA and DEV schemas apply relaxed masking since they contain synthetic data only

---

## Tag: PHI_CLASSIFICATION

**Purpose:** Classify protected health information by HIPAA identifier type to enable tag-based masking policies.

| Allowed Value | Definition | Masking Behavior | Example Columns |
|---|---|---|---|
| DIRECT_IDENTIFIER | 18 HIPAA identifiers that directly identify an individual | Full mask (hash or redact) | SSN, MRN, PATIENT_NAME, EMAIL, PHONE, FAX, DRIVERS_LICENSE, PASSPORT_NUMBER, HEALTH_PLAN_ID, ACCOUNT_NUMBER, CERTIFICATE_NUMBER, VEHICLE_ID, DEVICE_ID, URL, IP_ADDRESS, BIOMETRIC_ID, FULL_FACE_PHOTO |
| QUASI_IDENTIFIER | Indirect identifiers that can re-identify when combined | Partial mask or generalize | DATE_OF_BIRTH, ZIP_CODE, ADMISSION_DATE, DISCHARGE_DATE, SERVICE_DATE, AGE |
| SENSITIVE_CLINICAL | Clinical data revealing conditions/treatments | Role-restricted, not masked | DIAGNOSIS_CODE, PROCEDURE_CODE, MEDICATION_NAME, LAB_RESULT, VITAL_SIGNS |
| DE_IDENTIFIED | Data properly de-identified per HIPAA Safe Harbor | No masking required | AGE_BUCKET, ZIP_3_DIGIT, YEAR_ONLY_DATE |
| NON_PHI | Administrative data with no patient linkage | No restrictions | FACILITY_CODE, DEPARTMENT_ID, COST_CENTER |

**Supports Tag-Based Masking:** ✅ Yes

### Masking Policy Strategy

- DIRECT_IDENTIFIER → SHA256 hash or `'***REDACTED***'`
- QUASI_IDENTIFIER → Generalization (DOB → year only, ZIP → first 3 digits)
- Others → Pass-through based on role

---

## Tag: PHI_ELEMENT_TYPE

**Purpose:** Granular classification of specific PHI element types for audit reporting and targeted policy application.

| Allowed Value | Definition | Example Columns |
|---|---|---|
| NAME | Patient or provider names | PATIENT_FIRST_NAME, PATIENT_LAST_NAME, PROVIDER_NAME |
| GEOGRAPHIC | Address, city, state, ZIP | STREET_ADDRESS, CITY, STATE, ZIP_CODE |
| DATE | All dates except year | DATE_OF_BIRTH, ADMISSION_DATE, DEATH_DATE |
| CONTACT | Phone, fax, email | PHONE_NUMBER, FAX_NUMBER, EMAIL_ADDRESS |
| IDENTIFIER_GOVT | Government IDs | SSN, DRIVERS_LICENSE, PASSPORT_NUMBER |
| IDENTIFIER_HEALTH | Health identifiers | MRN, HEALTH_PLAN_ID, ACCOUNT_NUMBER |
| IDENTIFIER_DEVICE | Device/vehicle serials | DEVICE_SERIAL_NUMBER, VEHICLE_VIN |
| IDENTIFIER_DIGITAL | Digital identifiers | IP_ADDRESS, URL, MAC_ADDRESS |
| BIOMETRIC | Biometric data | FINGERPRINT_HASH, RETINA_SCAN |
| PHOTOGRAPH | Full-face images | PATIENT_PHOTO |

Supports Tag-Based Masking: ✅ Yes (inherits PHI_CLASSIFICATION)

---

# 1.2 Data Domain Tags

## Tag: DATA_DOMAIN

**Purpose:** Classify data by business domain for access control, stewardship assignment, and impact analysis.

| Allowed Value | Definition | Owner Team | Example Tables |
|---|---|---|---|
| CLINICAL | Patient care and medical records | Clinical Informatics | ENCOUNTERS, DIAGNOSES, PROCEDURES, MEDICATIONS |
| BILLING | Charge capture and billing | Revenue Cycle | CHARGES, PAYMENTS |
| CLAIMS | Insurance claims/remittance | Claims Ops | CLAIMS, DENIALS |
| SCHEDULING | Appointments/resource scheduling | Operations | APPOINTMENTS |
| PROVIDER | Provider demographics | Medical Staff | PROVIDERS |
| PATIENT | Patient master demographics | HIM | PATIENTS |
| REFERENCE | Code sets/lookups | Governance | ICD10_CODES |
| OPERATIONAL | Non-clinical operations | Operations | BED_CENSUS |
| FINANCIAL | GL and accounting | Finance | GL_TRANSACTIONS |
| QUALITY | Outcomes/quality measures | Compliance | QUALITY_MEASURES |

Supports Tag-Based Masking: ❌ No

---

## Tag: DATA_SUBDOMAIN

Secondary classification for granular access control.

| Allowed Value | Parent Domain | Example Tables |
|---|---|---|
| INPATIENT | CLINICAL | INPATIENT_ENCOUNTERS |
| OUTPATIENT | CLINICAL | OUTPATIENT_VISITS |
| PHARMACY | CLINICAL | MEDICATION_ORDERS |
| LABORATORY | CLINICAL | LAB_RESULTS |
| RADIOLOGY | CLINICAL | RADIOLOGY_REPORTS |
| BEHAVIORAL_HEALTH | CLINICAL | BH_ASSESSMENTS |
| SUBSTANCE_ABUSE | CLINICAL | 42CFR_RECORDS |
| PROFESSIONAL | BILLING | PROFESSIONAL_CHARGES |
| INSTITUTIONAL | BILLING | FACILITY_CHARGES |
| COMMERCIAL | CLAIMS | COMMERCIAL_CLAIMS |
| GOVERNMENT | CLAIMS | MEDICARE_CLAIMS |

---

# 1.3 Data Quality Tags

## Tag: DATA_QUALITY_STATUS

| Value | Meaning | Action |
|---|---|---|
| VALIDATED | Passed DQ checks | Safe |
| KNOWN_ISSUES | Known issues exist | Review |
| QUARANTINED | Failed checks | Do not use |
| PENDING_VALIDATION | New data | Use cautiously |
| LEGACY_UNVALIDATED | Historical | Document assumptions |

---

## Tag: DQ_ISSUE_TYPE

Values:

- MISSING_VALUES  
- INVALID_FORMAT  
- OUT_OF_RANGE  
- DUPLICATE_RECORDS  
- REFERENTIAL_ORPHAN  
- STALE_DATA  
- ENCODING_ERROR  
- BUSINESS_RULE_VIOLATION  

---

# 1.4 Pipeline / Lineage Tags

## MEDALLION_LAYER

| Value | Database | Characteristics | Retention |
|---|---|---|---|
| RAW | RAW_DB | Source copy | 7 years |
| TRANSFORM | TRANSFORM_DB | Cleansed | 3 years |
| ANALYTICS | ANALYTICS_DB | Business models | 3 years |
| AI_READY | AI_READY_DB | ML features | 2 years |

---

## SOURCE_SYSTEM

EPIC, CERNER, MEDITECH, CLAIMS_CLEARINGHOUSE,  
ELIGIBILITY_270_271, LAB_INTERFACE, PHARMACY_INTERFACE,  
MANUAL_ENTRY_toggle, DERIVED

---

## REFRESH_FREQUENCY

REAL_TIME, NEAR_REAL_TIME, HOURLY, DAILY, WEEKLY, MONTHLY, ON_DEMAND, STATIC

---

# 1.5 Regulatory Compliance Tags

## REGULATORY_FRAMEWORK

HIPAA, HITRUST, 42CFR_PART2, STATE_PRIVACY, MEDICARE_COPs,  
STARK_AKS, EMTALA, CLIA, FDA_21CFR11, GDPR

Supports masking: ✅ Yes

---

## CONSENT_REQUIRED

STANDARD_TPO, EXPLICIT_WRITTEN, 42CFR_CONSENT, RESEARCH_IRB,  
PSYCHOTHERAPY_NOTES, HIV_SPECIFIC, GENETIC_GINA

Supports masking: ✅ Yes

---

## RETENTION_POLICY

ADULT_MEDICAL_RECORD, MINOR_MEDICAL_RECORD, BILLING_RECORD,  
MEDICARE_RECORD, MAMMOGRAPHY, CLINICAL_TRIAL, EMPLOYEE_HEALTH, OPERATIONAL

---

# 1.6 Tag Taxonomy Summary

**Total Tags:** 12  
**Tags Supporting Masking:** 4  

Primary masking tags:

- PHI_CLASSIFICATION  
- PHI_ELEMENT_TYPE  
- REGULATORY_FRAMEWORK  
- CONSENT_REQUIRED  

---