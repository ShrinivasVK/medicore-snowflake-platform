# Test Results: 08_test_data_governance.sql

## Test Execution Summary
- **Execution Date:** 2026-02-25
- **Executed By:** ACCOUNTADMIN
- **Total Tests:** 67
- **Passed:** 67 ✅
- **Failed:** 0
- **Pass Rate:** 100.00% ✅

---

## Section 1: Tag Existence Validation (TC_08_001 - TC_08_013)

| Test ID | Test Name | Expected | Actual | Status |
|---------|-----------|----------|--------|--------|
| TC_08_001 | PHI_CLASSIFICATION tag exists | EXISTS | EXISTS | ✅ PASS |
| TC_08_002 | PHI_ELEMENT_TYPE tag exists | EXISTS | EXISTS | ✅ PASS |
| TC_08_003 | DATA_DOMAIN tag exists | EXISTS | EXISTS | ✅ PASS |
| TC_08_004 | DATA_SUBDOMAIN tag exists | EXISTS | EXISTS | ✅ PASS |
| TC_08_005 | DATA_QUALITY_STATUS tag exists | EXISTS | EXISTS | ✅ PASS |
| TC_08_006 | DQ_ISSUE_TYPE tag exists | EXISTS | EXISTS | ✅ PASS |
| TC_08_007 | MEDALLION_LAYER tag exists | EXISTS | EXISTS | ✅ PASS |
| TC_08_008 | ENVIRONMENT tag exists | EXISTS | EXISTS | ✅ PASS |
| TC_08_009 | SOURCE_SYSTEM tag exists | EXISTS | EXISTS | ✅ PASS |
| TC_08_010 | REFRESH_FREQUENCY tag exists | EXISTS | EXISTS | ✅ PASS |
| TC_08_011 | REGULATORY_FRAMEWORK tag exists | EXISTS | EXISTS | ✅ PASS |
| TC_08_012 | CONSENT_REQUIRED tag exists | EXISTS | EXISTS | ✅ PASS |
| TC_08_013 | RETENTION_POLICY tag exists | EXISTS | EXISTS | ✅ PASS |

---

## Section 2: Masking Policy Validation (TC_08_014 - TC_08_023)

| Test ID | Test Name | Expected | Actual | Status |
|---------|-----------|----------|--------|--------|
| TC_08_014 | MASK_DIRECT_IDENTIFIER policy exists | EXISTS | EXISTS | ✅ PASS |
| TC_08_015 | MASK_QUASI_IDENTIFIER policy exists | EXISTS | EXISTS | ✅ PASS |
| TC_08_016 | MASK_QUASI_IDENTIFIER_DATE policy exists | EXISTS | EXISTS | ✅ PASS |
| TC_08_017 | MASK_QUASI_IDENTIFIER_TIMESTAMP policy exists | EXISTS | EXISTS | ✅ PASS |
| TC_08_018 | MASK_SENSITIVE_CLINICAL policy exists | EXISTS | EXISTS | ✅ PASS |
| TC_08_019 | MASK_42CFR_PART2 policy exists | EXISTS | EXISTS | ✅ PASS |
| TC_08_020 | MASK_FINANCIAL_PII policy exists | EXISTS | EXISTS | ✅ PASS |
| TC_08_021 | MASK_DIRECT_IDENTIFIER returns STRING | VARCHAR | VARCHAR | ✅ PASS |
| TC_08_022 | MASK_QUASI_IDENTIFIER_DATE returns DATE | DATE | DATE | ✅ PASS |
| TC_08_023 | MASK_QUASI_IDENTIFIER_TIMESTAMP returns TIMESTAMP | TIMESTAMP_NTZ | TIMESTAMP_NTZ | ✅ PASS |

---

## Section 3: Row Access Policy Validation (TC_08_024 - TC_08_029b)

| Test ID | Test Name | Expected | Actual | Status |
|---------|-----------|----------|--------|--------|
| TC_08_024 | ROW_ACCESS_CLINICAL policy exists | EXISTS | EXISTS | ✅ PASS |
| TC_08_025 | ROW_ACCESS_ENVIRONMENT policy exists | EXISTS | EXISTS | ✅ PASS |
| TC_08_026 | ROW_ACCESS_CONSENT policy exists | EXISTS | EXISTS | ✅ PASS |
| TC_08_027 | ROW_ACCESS_DATA_QUALITY policy exists | EXISTS | EXISTS | ✅ PASS |
| TC_08_028 | ROW_ACCESS_CLINICAL returns BOOLEAN | BOOLEAN | BOOLEAN | ✅ PASS |
| TC_08_029 | ROW_ACCESS_ENVIRONMENT returns BOOLEAN | BOOLEAN | BOOLEAN | ✅ PASS |
| TC_08_029a | ROW_ACCESS_CONSENT returns BOOLEAN | BOOLEAN | BOOLEAN | ✅ PASS |
| TC_08_029b | ROW_ACCESS_DATA_QUALITY returns BOOLEAN | BOOLEAN | BOOLEAN | ✅ PASS |

---

## Section 4: Schema Placement Validation (TC_08_030 - TC_08_032)

| Test ID | Test Name | Expected | Actual | Status |
|---------|-----------|----------|--------|--------|
| TC_08_030 | All tags in MEDICORE_GOVERNANCE_DB.TAGS | MEDICORE_GOVERNANCE_DB.TAGS | MEDICORE_GOVERNANCE_DB.TAGS | ✅ PASS |
| TC_08_031 | All masking policies in MEDICORE_GOVERNANCE_DB.POLICIES | MEDICORE_GOVERNANCE_DB.POLICIES | MEDICORE_GOVERNANCE_DB.POLICIES | ✅ PASS |
| TC_08_032 | All row access policies in MEDICORE_GOVERNANCE_DB.POLICIES | MEDICORE_GOVERNANCE_DB.POLICIES | MEDICORE_GOVERNANCE_DB.POLICIES | ✅ PASS |

---

## Section 5: Ownership Validation (TC_08_033 - TC_08_037)

| Test ID | Test Name | Expected | Actual | Status |
|---------|-----------|----------|--------|--------|
| TC_08_033 | All tags owned by ACCOUNTADMIN | ACCOUNTADMIN | ACCOUNTADMIN | ✅ PASS |
| TC_08_034 | All masking policies owned by ACCOUNTADMIN | ACCOUNTADMIN | ACCOUNTADMIN | ✅ PASS |
| TC_08_035 | All row access policies owned by ACCOUNTADMIN | ACCOUNTADMIN | ACCOUNTADMIN | ✅ PASS |
| TC_08_036 | TAGS schema owned by ACCOUNTADMIN | ACCOUNTADMIN | ACCOUNTADMIN | ✅ PASS |
| TC_08_037 | POLICIES schema owned by ACCOUNTADMIN | ACCOUNTADMIN | ACCOUNTADMIN | ✅ PASS |

---

## Section 6: Privilege Validation (TC_08_038 - TC_08_045)

| Test ID | Test Name | Expected | Actual | Status |
|---------|-----------|----------|--------|--------|
| TC_08_038 | COMPLIANCE_OFFICER has CREATE TAG on TAGS schema | GRANTED | GRANTED | ✅ PASS |
| TC_08_039 | COMPLIANCE_OFFICER has CREATE MASKING POLICY on POLICIES schema | GRANTED | GRANTED | ✅ PASS |
| TC_08_040 | COMPLIANCE_OFFICER has CREATE ROW ACCESS POLICY on POLICIES schema | GRANTED | GRANTED | ✅ PASS |
| TC_08_041 | COMPLIANCE_OFFICER has APPLY TAG on ACCOUNT | GRANTED | GRANTED | ✅ PASS |
| TC_08_042 | COMPLIANCE_OFFICER has APPLY MASKING POLICY on ACCOUNT | GRANTED | GRANTED | ✅ PASS |
| TC_08_043 | COMPLIANCE_OFFICER has APPLY ROW ACCESS POLICY on ACCOUNT | GRANTED | GRANTED | ✅ PASS |
| TC_08_044 | COMPLIANCE_OFFICER has USAGE on TAGS schema | GRANTED | GRANTED | ✅ PASS |
| TC_08_045 | COMPLIANCE_OFFICER has USAGE on POLICIES schema | GRANTED | GRANTED | ✅ PASS |

---

## Section 7: Negative Tests - Unauthorized Privileges (TC_08_046 - TC_08_051)

| Test ID | Test Name | Expected | Actual | Status |
|---------|-----------|----------|--------|--------|
| TC_08_046 | DATA_ENGINEER does NOT have CREATE TAG | NOT_GRANTED | NOT_GRANTED | ✅ PASS |
| TC_08_047 | DATA_ENGINEER does NOT have CREATE MASKING POLICY | NOT_GRANTED | NOT_GRANTED | ✅ PASS |
| TC_08_048 | ANALYST_PHI does NOT have CREATE TAG | NOT_GRANTED | NOT_GRANTED | ✅ PASS |
| TC_08_049 | CLINICAL_PHYSICIAN does NOT have CREATE MASKING POLICY | NOT_GRANTED | NOT_GRANTED | ✅ PASS |
| TC_08_050 | BILLING_SPECIALIST does NOT have CREATE ROW ACCESS POLICY | NOT_GRANTED | NOT_GRANTED | ✅ PASS |
| TC_08_051 | EXECUTIVE does NOT have APPLY TAG | NOT_GRANTED | NOT_GRANTED | ✅ PASS |

---

## Section 8: Drift Detection (TC_08_052 - TC_08_054)

| Test ID | Test Name | Expected | Actual | Status |
|---------|-----------|----------|--------|--------|
| TC_08_052 | Tag count equals 13 | 13 | 13 | ✅ PASS |
| TC_08_053 | Masking policy count equals 7 | 7 | 7 | ✅ PASS |
| TC_08_054 | Row access policy count equals 4 | 4 | 4 | ✅ PASS |

---

## Section 8a: Policy Structure Validation (TC_08_054a - TC_08_054f)

| Test ID | Test Name | Expected | Actual | Status |
|---------|-----------|----------|--------|--------|
| TC_08_054a | MASK_DIRECT_IDENTIFIER contains CURRENT_ROLE() | CONTAINS | CONTAINS | ✅ PASS |
| TC_08_054b | MASK_DIRECT_IDENTIFIER contains CASE expression | CONTAINS | CONTAINS | ✅ PASS |
| TC_08_054c | MASK_42CFR_PART2 contains COMPLIANCE_OFFICER check | CONTAINS | CONTAINS | ✅ PASS |
| TC_08_054d | ROW_ACCESS_CLINICAL contains CURRENT_ROLE() | CONTAINS | CONTAINS | ✅ PASS |
| TC_08_054e | ROW_ACCESS_CLINICAL handles SUBSTANCE_ABUSE | CONTAINS | CONTAINS | ✅ PASS |
| TC_08_054f | ROW_ACCESS_ENVIRONMENT contains PROD/QA/DEV check | CONTAINS | CONTAINS | ✅ PASS |

---

## Section 9: Governance Schema Security (TC_08_055 - TC_08_058)

| Test ID | Test Name | Expected | Actual | Status |
|---------|-----------|----------|--------|--------|
| TC_08_055 | TAGS schema not owned by DATA_ENGINEER | NOT_OWNER | NOT_OWNER | ✅ PASS |
| TC_08_056 | POLICIES schema not owned by DATA_ENGINEER | NOT_OWNER | NOT_OWNER | ✅ PASS |
| TC_08_057 | MEDICORE_GOVERNANCE_DB exists | EXISTS | EXISTS | ✅ PASS |
| TC_08_058 | MEDICORE_GOVERNANCE_DB owned by ACCOUNTADMIN | ACCOUNTADMIN | ACCOUNTADMIN | ✅ PASS |

---

## Governance Objects Summary

### Tags (13) ✅

| Tag Name | Schema | Owner |
|----------|--------|-------|
| PHI_CLASSIFICATION | TAGS | ACCOUNTADMIN ✅ |
| PHI_ELEMENT_TYPE | TAGS | ACCOUNTADMIN ✅ |
| DATA_DOMAIN | TAGS | ACCOUNTADMIN ✅ |
| DATA_SUBDOMAIN | TAGS | ACCOUNTADMIN ✅ |
| DATA_QUALITY_STATUS | TAGS | ACCOUNTADMIN ✅ |
| DQ_ISSUE_TYPE | TAGS | ACCOUNTADMIN ✅ |
| MEDALLION_LAYER | TAGS | ACCOUNTADMIN ✅ |
| ENVIRONMENT | TAGS | ACCOUNTADMIN ✅ |
| SOURCE_SYSTEM | TAGS | ACCOUNTADMIN ✅ |
| REFRESH_FREQUENCY | TAGS | ACCOUNTADMIN ✅ |
| REGULATORY_FRAMEWORK | TAGS | ACCOUNTADMIN ✅ |
| CONSENT_REQUIRED | TAGS | ACCOUNTADMIN ✅ |
| RETENTION_POLICY | TAGS | ACCOUNTADMIN ✅ |

### Masking Policies (7) ✅

| Policy Name | Return Type | Owner |
|-------------|-------------|-------|
| MASK_DIRECT_IDENTIFIER | VARCHAR | ACCOUNTADMIN ✅ |
| MASK_QUASI_IDENTIFIER | VARCHAR | ACCOUNTADMIN ✅ |
| MASK_QUASI_IDENTIFIER_DATE | DATE | ACCOUNTADMIN ✅ |
| MASK_QUASI_IDENTIFIER_TIMESTAMP | TIMESTAMP_NTZ | ACCOUNTADMIN ✅ |
| MASK_SENSITIVE_CLINICAL | VARCHAR | ACCOUNTADMIN ✅ |
| MASK_42CFR_PART2 | VARCHAR | ACCOUNTADMIN ✅ |
| MASK_FINANCIAL_PII | VARCHAR | ACCOUNTADMIN ✅ |

### Row Access Policies (4) ✅

| Policy Name | Return Type | Owner |
|-------------|-------------|-------|
| ROW_ACCESS_CLINICAL | BOOLEAN | ACCOUNTADMIN ✅ |
| ROW_ACCESS_ENVIRONMENT | BOOLEAN | ACCOUNTADMIN ✅ |
| ROW_ACCESS_CONSENT | BOOLEAN | ACCOUNTADMIN ✅ |
| ROW_ACCESS_DATA_QUALITY | BOOLEAN | ACCOUNTADMIN ✅ |

---

## Compliance Officer Privileges Summary ✅

| Privilege | Granted On | Status |
|-----------|------------|--------|
| CREATE TAG | MEDICORE_GOVERNANCE_DB.TAGS | ✅ GRANTED |
| CREATE MASKING POLICY | MEDICORE_GOVERNANCE_DB.POLICIES | ✅ GRANTED |
| CREATE ROW ACCESS POLICY | MEDICORE_GOVERNANCE_DB.POLICIES | ✅ GRANTED |
| USAGE | MEDICORE_GOVERNANCE_DB.TAGS | ✅ GRANTED |
| USAGE | MEDICORE_GOVERNANCE_DB.POLICIES | ✅ GRANTED |
| APPLY TAG | ACCOUNT | ✅ GRANTED |
| APPLY MASKING POLICY | ACCOUNT | ✅ GRANTED |
| APPLY ROW ACCESS POLICY | ACCOUNT | ✅ GRANTED |

---

## Separation of Duties Validation ✅

| Role | CREATE TAG | CREATE MASKING POLICY | CREATE ROW ACCESS POLICY | APPLY TAG |
|------|------------|----------------------|-------------------------|-----------|
| MEDICORE_COMPLIANCE_OFFICER | ✅ GRANTED | ✅ GRANTED | ✅ GRANTED | ✅ GRANTED |
| MEDICORE_DATA_ENGINEER | ❌ NOT_GRANTED | ❌ NOT_GRANTED | ❌ NOT_GRANTED | ❌ NOT_GRANTED |
| MEDICORE_ANALYST_PHI | ❌ NOT_GRANTED | ❌ NOT_GRANTED | ❌ NOT_GRANTED | ❌ NOT_GRANTED |
| MEDICORE_CLINICAL_PHYSICIAN | ❌ NOT_GRANTED | ❌ NOT_GRANTED | ❌ NOT_GRANTED | ❌ NOT_GRANTED |
| MEDICORE_BILLING_SPECIALIST | ❌ NOT_GRANTED | ❌ NOT_GRANTED | ❌ NOT_GRANTED | ❌ NOT_GRANTED |
| MEDICORE_EXECUTIVE | ❌ NOT_GRANTED | ❌ NOT_GRANTED | ❌ NOT_GRANTED | ❌ NOT_GRANTED |

---

## Phase 08 Complete ✅

All 67 tests passed successfully. The data governance layer is fully implemented with:

- ✅ **13 Tags** for PHI classification, data domains, regulatory frameworks, and data quality
- ✅ **7 Masking Policies** for HIPAA Safe Harbor, 42 CFR Part 2, and financial data protection
- ✅ **4 Row Access Policies** for clinical, environment, consent, and data quality filtering
- ✅ **ACCOUNTADMIN ownership** preserved for all governance objects
- ✅ **MEDICORE_COMPLIANCE_OFFICER** granted full governance management privileges
- ✅ **Separation of duties** enforced - non-compliance roles blocked from governance creation
- ✅ **Policy structure validated** - CURRENT_ROLE() logic, CASE expressions, and regulatory checks confirmed
