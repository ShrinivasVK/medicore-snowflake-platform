# MediCore Health Systems — Data Platform Design Document  
## PART 1 — TAG TAXONOMY DESIGN  
Version: 1.0  
Date: February 2026  
Status: Draft — Pending Review  

---

## Overview

MediCore's tag taxonomy enables automated data classification, policy enforcement, and compliance tracking across all four medallion layers. Tags are organized into five categories, each serving distinct governance purposes.

---

# 1.1 PHI Classification Tags

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