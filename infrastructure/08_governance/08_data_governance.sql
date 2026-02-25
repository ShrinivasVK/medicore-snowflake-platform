-- ============================================================
-- MEDICORE HEALTH SYSTEMS — PHASE 08: DATA GOVERNANCE
-- ============================================================
-- Script:      08_data_governance.sql
-- Version:     1.0.0
-- Environment: Enterprise Snowflake (HIPAA-regulated)
-- Purpose:     Implement comprehensive data governance layer
--              including tags, masking policies, row access
--              policies, and governance grants.
--
-- HIPAA COMPLIANCE CONTEXT:
-- -------------------------
-- MediCore operates under HIPAA Privacy Rule which mandates
-- protection of Protected Health Information (PHI). This script
-- implements technical safeguards through:
--   - Data classification via tags
--   - Dynamic data masking for PHI elements
--   - Row-level security for sensitive records
--   - Role-based access enforcement
--
-- HIPAA SAFE HARBOR METHOD:
-- -------------------------
-- Safe Harbor de-identification requires removal/masking of
-- 18 PHI identifiers. Our tag taxonomy maps to these elements:
--   - DIRECT_IDENTIFIER: Names, SSN, MRN, addresses, etc.
--   - QUASI_IDENTIFIER: Dates, ZIP codes, ages over 89
--   - SENSITIVE_CLINICAL: Diagnoses, medications, procedures
--
-- 42 CFR PART 2 COMPLIANCE:
-- -------------------------
-- Substance use disorder (SUD) records require stricter
-- protections under 42 CFR Part 2. These records:
--   - Cannot be re-disclosed without explicit consent
--   - Require separate consent from general HIPAA authorization
--   - Must be segregated from standard clinical data access
--   - Only MEDICORE_COMPLIANCE_OFFICER can access without consent
--
-- TAG-BASED MASKING ARCHITECTURE:
-- -------------------------------
-- Snowflake supports tag-based masking policies which:
--   1. Associate masking policies with tags (not tables)
--   2. Automatically apply masking when tag is set on column
--   3. Enable centralized governance without per-table DDL
--   4. Support dynamic policy evaluation at query time
--
-- ENVIRONMENT STRATEGY:
-- ---------------------
-- PROD: Full masking enforcement with role-based exceptions
-- QA:   Synthetic/anonymized data only (no real PHI)
-- DEV:  Synthetic/anonymized data only (no real PHI)
--
-- QA/DEV environments must NEVER contain real PHI. Row access
-- policies enforce this by blocking PHI access in non-PROD.
--
-- GOVERNANCE OWNERSHIP:
-- ---------------------
-- MEDICORE_COMPLIANCE_OFFICER owns governance logic because:
--   - Regulatory accountability requires compliance oversight
--   - Separation of duties from data engineering
--   - Audit trail for policy changes
--   - HIPAA requires designated privacy officer
--
-- Prerequisites:
--   - Phase 01: Databases created
--   - Phase 02: Warehouses created
--   - Phase 03: RBAC implemented
--   - Phase 04: Schemas created
--   - MEDICORE_GOVERNANCE_DB.TAGS schema exists
--   - MEDICORE_GOVERNANCE_DB.POLICIES schema exists
--
-- Execution: Run as ACCOUNTADMIN
-- ============================================================

-- ============================================================
-- ENVIRONMENT SETUP
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE MEDICORE_GOVERNANCE_DB;
USE WAREHOUSE COMPUTE_WH;

-- ============================================================
-- SECTION 1: TAG OBJECT CREATION
-- ============================================================
-- Tags provide semantic classification for data governance.
-- Each tag represents a dimension of data classification that
-- drives masking, access control, and compliance reporting.
--
-- Tags are created in MEDICORE_GOVERNANCE_DB.TAGS schema and
-- can be applied to databases, schemas, tables, and columns.
-- ============================================================

USE SCHEMA MEDICORE_GOVERNANCE_DB.TAGS;

-- ------------------------------------------------------------
-- TAG: PHI_CLASSIFICATION
-- ------------------------------------------------------------
-- Primary HIPAA classification tag mapping to Safe Harbor method.
-- Determines which masking policy applies to the column.
--
-- Allowed Values:
--   DIRECT_IDENTIFIER   - 18 HIPAA identifiers (names, SSN, MRN)
--   QUASI_IDENTIFIER    - Re-identification risk (dates, ZIP, age)
--   SENSITIVE_CLINICAL  - Clinical data requiring protection
--   NON_PHI             - Business data, no HIPAA restrictions
-- ------------------------------------------------------------
CREATE OR REPLACE TAG MEDICORE_GOVERNANCE_DB.TAGS.PHI_CLASSIFICATION
    COMMENT = 'HIPAA Safe Harbor classification. Values: DIRECT_IDENTIFIER (18 identifiers), QUASI_IDENTIFIER (re-identification risk), SENSITIVE_CLINICAL (clinical data), NON_PHI (non-protected)';

-- ------------------------------------------------------------
-- TAG: PHI_ELEMENT_TYPE
-- ------------------------------------------------------------
-- Granular PHI element type per HIPAA Safe Harbor 18 identifiers.
--
-- Allowed Values:
--   NAME, ADDRESS, DATES, PHONE, FAX, EMAIL, SSN, MRN,
--   HEALTH_PLAN_ID, ACCOUNT_NUMBER, LICENSE_NUMBER,
--   VEHICLE_ID, DEVICE_ID, URL, IP_ADDRESS, BIOMETRIC,
--   PHOTO, OTHER_UNIQUE_ID
-- ------------------------------------------------------------
CREATE OR REPLACE TAG MEDICORE_GOVERNANCE_DB.TAGS.PHI_ELEMENT_TYPE
    COMMENT = 'Specific PHI element per HIPAA Safe Harbor. Values: NAME, ADDRESS, DATES, PHONE, FAX, EMAIL, SSN, MRN, HEALTH_PLAN_ID, ACCOUNT_NUMBER, LICENSE_NUMBER, VEHICLE_ID, DEVICE_ID, URL, IP_ADDRESS, BIOMETRIC, PHOTO, OTHER_UNIQUE_ID';

-- ------------------------------------------------------------
-- TAG: DATA_DOMAIN
-- ------------------------------------------------------------
-- High-level business domain classification for data organization.
--
-- Allowed Values:
--   CLINICAL    - Patient care and treatment data
--   FINANCIAL   - Billing, claims, revenue data
--   OPERATIONAL - Administrative and operational data
--   RESEARCH    - De-identified research datasets
--   REFERENCE   - Master data and code tables
-- ------------------------------------------------------------
CREATE OR REPLACE TAG MEDICORE_GOVERNANCE_DB.TAGS.DATA_DOMAIN
    COMMENT = 'Business domain classification. Values: CLINICAL (patient care), FINANCIAL (billing/claims), OPERATIONAL (admin), RESEARCH (de-identified), REFERENCE (master data)';

-- ------------------------------------------------------------
-- TAG: DATA_SUBDOMAIN
-- ------------------------------------------------------------
-- Granular subdomain for fine-grained access control.
-- Critical for 42 CFR Part 2 substance abuse segregation.
--
-- Allowed Values:
--   DEMOGRAPHICS, ENCOUNTERS, DIAGNOSES, PROCEDURES,
--   MEDICATIONS, LAB_RESULTS, VITAL_SIGNS, IMAGING,
--   SUBSTANCE_ABUSE, MENTAL_HEALTH, HIV_AIDS,
--   REPRODUCTIVE_HEALTH, GENETIC, BILLING, CLAIMS,
--   SCHEDULING, PROVIDERS, FACILITIES
-- ------------------------------------------------------------
CREATE OR REPLACE TAG MEDICORE_GOVERNANCE_DB.TAGS.DATA_SUBDOMAIN
    COMMENT = 'Granular subdomain. Values: DEMOGRAPHICS, ENCOUNTERS, DIAGNOSES, PROCEDURES, MEDICATIONS, LAB_RESULTS, VITAL_SIGNS, IMAGING, SUBSTANCE_ABUSE, MENTAL_HEALTH, HIV_AIDS, REPRODUCTIVE_HEALTH, GENETIC, BILLING, CLAIMS, SCHEDULING, PROVIDERS, FACILITIES';

-- ------------------------------------------------------------
-- TAG: DATA_QUALITY_STATUS
-- ------------------------------------------------------------
-- Data quality certification status for data stewardship.
--
-- Allowed Values:
--   CERTIFIED      - Passed all DQ checks, production-ready
--   UNDER_REVIEW   - Pending quality validation
--   QUARANTINED    - Failed DQ checks, do not use
--   DEPRECATED     - Scheduled for removal
-- ------------------------------------------------------------
CREATE OR REPLACE TAG MEDICORE_GOVERNANCE_DB.TAGS.DATA_QUALITY_STATUS
    COMMENT = 'Data quality certification. Values: CERTIFIED (production-ready), UNDER_REVIEW (pending validation), QUARANTINED (failed checks), DEPRECATED (scheduled removal)';

-- ------------------------------------------------------------
-- TAG: DQ_ISSUE_TYPE
-- ------------------------------------------------------------
-- Specific data quality issue classification.
--
-- Allowed Values:
--   COMPLETENESS   - Missing required values
--   ACCURACY       - Incorrect or invalid values
--   CONSISTENCY    - Cross-field or cross-table conflicts
--   TIMELINESS     - Stale or delayed data
--   UNIQUENESS     - Duplicate records
--   VALIDITY       - Format or constraint violations
-- ------------------------------------------------------------
CREATE OR REPLACE TAG MEDICORE_GOVERNANCE_DB.TAGS.DQ_ISSUE_TYPE
    COMMENT = 'Data quality issue type. Values: COMPLETENESS (missing), ACCURACY (incorrect), CONSISTENCY (conflicts), TIMELINESS (stale), UNIQUENESS (duplicates), VALIDITY (format violations)';

-- ------------------------------------------------------------
-- TAG: MEDALLION_LAYER
-- ------------------------------------------------------------
-- Data lakehouse medallion architecture layer classification.
--
-- Allowed Values:
--   BRONZE  - Raw ingested data, minimal transformation
--   SILVER  - Cleansed, conformed, validated data
--   GOLD    - Business-ready aggregates and metrics
-- ------------------------------------------------------------
CREATE OR REPLACE TAG MEDICORE_GOVERNANCE_DB.TAGS.MEDALLION_LAYER
    COMMENT = 'Medallion architecture layer. Values: BRONZE (raw), SILVER (cleansed), GOLD (business-ready)';

-- ------------------------------------------------------------
-- TAG: ENVIRONMENT
-- ------------------------------------------------------------
-- Deployment environment classification.
-- Critical for PHI access control in non-production.
--
-- Allowed Values:
--   PROD  - Production environment with real data
--   QA    - Quality assurance with synthetic data only
--   DEV   - Development with synthetic data only
-- ------------------------------------------------------------
CREATE OR REPLACE TAG MEDICORE_GOVERNANCE_DB.TAGS.ENVIRONMENT
    COMMENT = 'Deployment environment. Values: PROD (production), QA (synthetic only), DEV (synthetic only). QA/DEV must never contain real PHI.';

-- ------------------------------------------------------------
-- TAG: SOURCE_SYSTEM
-- ------------------------------------------------------------
-- Originating source system for data lineage tracking.
--
-- Allowed Values:
--   EPIC, CERNER, ALLSCRIPTS, MEDITECH, ATHENA,
--   CLAIMS_CLEARINGHOUSE, LAB_INTERFACE, PHARMACY_SYSTEM,
--   BILLING_SYSTEM, MANUAL_ENTRY, EXTERNAL_FEED
-- ------------------------------------------------------------
CREATE OR REPLACE TAG MEDICORE_GOVERNANCE_DB.TAGS.SOURCE_SYSTEM
    COMMENT = 'Source system for lineage. Values: EPIC, CERNER, ALLSCRIPTS, MEDITECH, ATHENA, CLAIMS_CLEARINGHOUSE, LAB_INTERFACE, PHARMACY_SYSTEM, BILLING_SYSTEM, MANUAL_ENTRY, EXTERNAL_FEED';

-- ------------------------------------------------------------
-- TAG: REFRESH_FREQUENCY
-- ------------------------------------------------------------
-- Data refresh cadence for SLA and monitoring.
--
-- Allowed Values:
--   REAL_TIME   - Streaming or near-real-time (<1 min)
--   HOURLY      - Hourly batch refresh
--   DAILY       - Daily batch refresh
--   WEEKLY      - Weekly batch refresh
--   MONTHLY     - Monthly batch refresh
--   ON_DEMAND   - Manual or event-triggered refresh
-- ------------------------------------------------------------
CREATE OR REPLACE TAG MEDICORE_GOVERNANCE_DB.TAGS.REFRESH_FREQUENCY
    COMMENT = 'Data refresh cadence. Values: REAL_TIME (<1 min), HOURLY, DAILY, WEEKLY, MONTHLY, ON_DEMAND (manual/event-triggered)';

-- ------------------------------------------------------------
-- TAG: REGULATORY_FRAMEWORK
-- ------------------------------------------------------------
-- Applicable regulatory framework for compliance mapping.
-- Critical for 42 CFR Part 2 substance abuse data segregation.
--
-- Allowed Values:
--   HIPAA           - Standard HIPAA Privacy Rule
--   42CFR_PART2     - Substance use disorder (stricter)
--   HITECH          - Health IT for Economic and Clinical Health
--   STATE_PRIVACY   - State-specific privacy laws
--   GDPR            - EU General Data Protection Regulation
--   CCPA            - California Consumer Privacy Act
-- ------------------------------------------------------------
CREATE OR REPLACE TAG MEDICORE_GOVERNANCE_DB.TAGS.REGULATORY_FRAMEWORK
    COMMENT = 'Regulatory framework. Values: HIPAA (standard), 42CFR_PART2 (substance abuse - stricter), HITECH, STATE_PRIVACY, GDPR, CCPA';

-- ------------------------------------------------------------
-- TAG: CONSENT_REQUIRED
-- ------------------------------------------------------------
-- Consent requirement classification for data access.
-- 42 CFR Part 2 requires explicit written consent.
--
-- Allowed Values:
--   NONE             - No additional consent beyond HIPAA TPO
--   HIPAA_AUTH       - HIPAA authorization required
--   42CFR_CONSENT    - 42 CFR Part 2 written consent required
--   RESEARCH_CONSENT - IRB-approved research consent
--   MARKETING        - Marketing consent required
-- ------------------------------------------------------------
CREATE OR REPLACE TAG MEDICORE_GOVERNANCE_DB.TAGS.CONSENT_REQUIRED
    COMMENT = 'Consent requirements. Values: NONE (HIPAA TPO sufficient), HIPAA_AUTH (authorization required), 42CFR_CONSENT (written consent - substance abuse), RESEARCH_CONSENT (IRB), MARKETING';

-- ------------------------------------------------------------
-- TAG: RETENTION_POLICY
-- ------------------------------------------------------------
-- Data retention period for lifecycle management.
-- HIPAA requires minimum 6 years for medical records.
--
-- Allowed Values:
--   7_YEARS    - Standard medical records (HIPAA minimum + 1)
--   10_YEARS   - Extended retention (litigation hold, research)
--   PERMANENT  - Permanent retention (regulatory requirement)
--   1_YEAR     - Transient operational data
--   90_DAYS    - Short-term staging/temp data
-- ------------------------------------------------------------
CREATE OR REPLACE TAG MEDICORE_GOVERNANCE_DB.TAGS.RETENTION_POLICY
    COMMENT = 'Retention period. Values: 7_YEARS (HIPAA standard), 10_YEARS (extended), PERMANENT, 1_YEAR (operational), 90_DAYS (transient)';


-- ============================================================
-- SECTION 2: MASKING POLICIES
-- ============================================================
-- Masking policies implement dynamic data masking based on
-- the querying user's role. Policies evaluate at query time
-- and return masked values for unauthorized users.
--
-- Snowflake masking policies:
--   - Are schema-level objects
--   - Accept column value and optional arguments
--   - Return masked or original value based on conditions
--   - Can use CURRENT_ROLE() for role-based decisions
--   - Can use SYSTEM$GET_TAG_ON_CURRENT_COLUMN() for tag-based logic
--
-- These policies will be attached to tags for automatic
-- enforcement across all tagged columns.
-- ============================================================

USE SCHEMA MEDICORE_GOVERNANCE_DB.POLICIES;

-- ------------------------------------------------------------
-- MASKING POLICY: MASK_DIRECT_IDENTIFIER
-- ------------------------------------------------------------
-- Protects HIPAA Safe Harbor direct identifiers (18 elements).
-- Direct identifiers uniquely identify individuals and require
-- the strongest protection under HIPAA.
--
-- Access Rules:
--   - MEDICORE_CLINICAL_PHYSICIAN: Full access (treatment)
--   - MEDICORE_COMPLIANCE_OFFICER: Full access (audit/compliance)
--   - All other roles: Fully redacted
--
-- Use Cases:
--   - Patient names, SSN, MRN, addresses
--   - Phone numbers, email addresses
--   - Account numbers, device identifiers
-- ------------------------------------------------------------
CREATE OR REPLACE MASKING POLICY MEDICORE_GOVERNANCE_DB.POLICIES.MASK_DIRECT_IDENTIFIER
    AS (val STRING)
    RETURNS STRING
    COMMENT = 'Masks direct identifiers (HIPAA Safe Harbor 18). Full access: CLINICAL_PHYSICIAN, COMPLIANCE_OFFICER. Others: REDACTED.'
    ->
    CASE
        WHEN CURRENT_ROLE() IN (
            'MEDICORE_CLINICAL_PHYSICIAN',
            'MEDICORE_COMPLIANCE_OFFICER',
            'ACCOUNTADMIN'
        ) THEN val
        ELSE '***REDACTED***'
    END;

-- ------------------------------------------------------------
-- MASKING POLICY: MASK_QUASI_IDENTIFIER
-- ------------------------------------------------------------
-- Protects quasi-identifiers that pose re-identification risk.
-- Quasi-identifiers are generalized rather than fully masked
-- to preserve analytical utility while reducing risk.
--
-- Access Rules:
--   - MEDICORE_CLINICAL_PHYSICIAN: Full access (treatment)
--   - MEDICORE_COMPLIANCE_OFFICER: Full access (audit)
--   - All other roles: Generalized values
--
-- Generalization Rules:
--   - Dates: Truncated to year only
--   - ZIP codes: First 3 digits only (ZIP3)
--   - Ages over 89: Shown as 90+
--
-- Note: This policy handles STRING values. Date/numeric
-- quasi-identifiers require separate typed policies.
-- ------------------------------------------------------------
CREATE OR REPLACE MASKING POLICY MEDICORE_GOVERNANCE_DB.POLICIES.MASK_QUASI_IDENTIFIER
    AS (val STRING)
    RETURNS STRING
    COMMENT = 'Generalizes quasi-identifiers. Full access: CLINICAL_PHYSICIAN, COMPLIANCE_OFFICER. Others: generalized (dates->year, ZIP->3 digits).'
    ->
    CASE
        WHEN CURRENT_ROLE() IN (
            'MEDICORE_CLINICAL_PHYSICIAN',
            'MEDICORE_COMPLIANCE_OFFICER',
            'ACCOUNTADMIN'
        ) THEN val
        WHEN TRY_TO_DATE(val) IS NOT NULL THEN
            YEAR(TRY_TO_DATE(val))::STRING
        WHEN REGEXP_LIKE(val, '^[0-9]{5}(-[0-9]{4})?$') THEN
            LEFT(val, 3) || 'XX'
        ELSE
            '***GENERALIZED***'
    END;

-- ------------------------------------------------------------
-- MASKING POLICY: MASK_QUASI_IDENTIFIER_DATE
-- ------------------------------------------------------------
-- Specialized quasi-identifier masking for DATE columns.
-- Truncates to year for non-privileged users.
-- ------------------------------------------------------------
CREATE OR REPLACE MASKING POLICY MEDICORE_GOVERNANCE_DB.POLICIES.MASK_QUASI_IDENTIFIER_DATE
    AS (val DATE)
    RETURNS DATE
    COMMENT = 'Generalizes date quasi-identifiers to year. Full access: CLINICAL_PHYSICIAN, COMPLIANCE_OFFICER.'
    ->
    CASE
        WHEN CURRENT_ROLE() IN (
            'MEDICORE_CLINICAL_PHYSICIAN',
            'MEDICORE_COMPLIANCE_OFFICER',
            'ACCOUNTADMIN'
        ) THEN val
        ELSE
            DATE_TRUNC('YEAR', val)::DATE
    END;

-- ------------------------------------------------------------
-- MASKING POLICY: MASK_QUASI_IDENTIFIER_TIMESTAMP
-- ------------------------------------------------------------
-- Specialized quasi-identifier masking for TIMESTAMP columns.
-- Truncates to year for non-privileged users.
-- ------------------------------------------------------------
CREATE OR REPLACE MASKING POLICY MEDICORE_GOVERNANCE_DB.POLICIES.MASK_QUASI_IDENTIFIER_TIMESTAMP
    AS (val TIMESTAMP_NTZ)
    RETURNS TIMESTAMP_NTZ
    COMMENT = 'Generalizes timestamp quasi-identifiers to year. Full access: CLINICAL_PHYSICIAN, COMPLIANCE_OFFICER.'
    ->
    CASE
        WHEN CURRENT_ROLE() IN (
            'MEDICORE_CLINICAL_PHYSICIAN',
            'MEDICORE_COMPLIANCE_OFFICER',
            'ACCOUNTADMIN'
        ) THEN val
        ELSE
            DATE_TRUNC('YEAR', val)::TIMESTAMP_NTZ
    END;

-- ------------------------------------------------------------
-- MASKING POLICY: MASK_SENSITIVE_CLINICAL
-- ------------------------------------------------------------
-- Protects sensitive clinical data that requires care team
-- membership for access. This includes diagnoses, procedures,
-- medications, and clinical notes.
--
-- Access Rules:
--   - MEDICORE_CLINICAL_PHYSICIAN: Full access (primary care)
--   - MEDICORE_CLINICAL_NURSE: Full access (care coordination)
--   - MEDICORE_COMPLIANCE_OFFICER: Full access (audit)
--   - All other roles: NULL (no access)
--
-- Rationale: NULL rather than redacted string because:
--   - Clinical data should not appear in non-clinical contexts
--   - Prevents inference from redaction patterns
--   - Cleaner for downstream analytics exclusion
-- ------------------------------------------------------------
CREATE OR REPLACE MASKING POLICY MEDICORE_GOVERNANCE_DB.POLICIES.MASK_SENSITIVE_CLINICAL
    AS (val STRING)
    RETURNS STRING
    COMMENT = 'Masks sensitive clinical data. Access: CLINICAL_PHYSICIAN, CLINICAL_NURSE, COMPLIANCE_OFFICER. Others: NULL.'
    ->
    CASE
        WHEN CURRENT_ROLE() IN (
            'MEDICORE_CLINICAL_PHYSICIAN',
            'MEDICORE_CLINICAL_NURSE',
            'MEDICORE_COMPLIANCE_OFFICER',
            'ACCOUNTADMIN'
        ) THEN val
        ELSE NULL
    END;

-- ------------------------------------------------------------
-- MASKING POLICY: MASK_42CFR_PART2
-- ------------------------------------------------------------
-- Implements 42 CFR Part 2 protections for substance use
-- disorder (SUD) treatment records.
--
-- 42 CFR Part 2 Requirements:
--   - Stricter than HIPAA for SUD records
--   - Cannot be re-disclosed without written patient consent
--   - Separate from general medical record access
--   - Requires specific consent form (not general HIPAA auth)
--
-- Access Rules:
--   - MEDICORE_COMPLIANCE_OFFICER: Full access (regulatory oversight)
--   - All other roles including clinical: NULL
--
-- IMPORTANT: Even physicians cannot access 42 CFR Part 2 data
-- without explicit patient consent. This policy enforces the
-- baseline protection; consent-based access requires additional
-- integration with consent management system.
--
-- Future Enhancement: Integrate with CONSENT_REGISTRY table
-- to allow access when valid 42CFR consent exists.
-- ------------------------------------------------------------
CREATE OR REPLACE MASKING POLICY MEDICORE_GOVERNANCE_DB.POLICIES.MASK_42CFR_PART2
    AS (val STRING)
    RETURNS STRING
    COMMENT = '42 CFR Part 2 protection for substance abuse data. ONLY COMPLIANCE_OFFICER has access. Clinical roles require explicit patient consent (future integration).'
    ->
    CASE
        WHEN CURRENT_ROLE() IN (
            'MEDICORE_COMPLIANCE_OFFICER',
            'ACCOUNTADMIN'
        ) THEN val
        ELSE NULL
    END;

-- ------------------------------------------------------------
-- MASKING POLICY: MASK_FINANCIAL_PII
-- ------------------------------------------------------------
-- Protects financial personally identifiable information
-- such as account numbers, credit card numbers, bank details.
--
-- Access Rules:
--   - MEDICORE_BILLING_SPECIALIST: Full access (billing ops)
--   - MEDICORE_COMPLIANCE_OFFICER: Full access (audit)
--   - All other roles: Partially masked (last 4 digits)
-- ------------------------------------------------------------
CREATE OR REPLACE MASKING POLICY MEDICORE_GOVERNANCE_DB.POLICIES.MASK_FINANCIAL_PII
    AS (val STRING)
    RETURNS STRING
    COMMENT = 'Masks financial PII. Full access: BILLING_SPECIALIST, COMPLIANCE_OFFICER. Others: last 4 digits only.'
    ->
    CASE
        WHEN CURRENT_ROLE() IN (
            'MEDICORE_BILLING_SPECIALIST',
            'MEDICORE_COMPLIANCE_OFFICER',
            'ACCOUNTADMIN'
        ) THEN val
        WHEN LENGTH(val) > 4 THEN
            REPEAT('*', LENGTH(val) - 4) || RIGHT(val, 4)
        ELSE
            '****'
    END;


-- ============================================================
-- SECTION 3: ROW ACCESS POLICIES
-- ============================================================
-- Row access policies filter rows at query time based on
-- user context. Unlike masking (which hides column values),
-- row access completely excludes rows from result sets.
--
-- Row access policies:
--   - Return BOOLEAN (true = include row, false = exclude)
--   - Are attached to tables, not tags
--   - Can reference session context (role, user, etc.)
--   - Can join to mapping tables for complex logic
--
-- These policies implement:
--   - 42 CFR Part 2 row-level segregation
--   - Environment-based PHI protection
--   - Consent-based access framework
-- ============================================================

-- ------------------------------------------------------------
-- ROW ACCESS POLICY: ROW_ACCESS_CLINICAL
-- ------------------------------------------------------------
-- Controls row-level access based on clinical data subdomain.
-- Implements 42 CFR Part 2 segregation for substance abuse
-- records at the row level.
--
-- Access Rules:
--   - SUBSTANCE_ABUSE subdomain: COMPLIANCE_OFFICER only
--   - MENTAL_HEALTH subdomain: Clinical roles + COMPLIANCE
--   - Other clinical data: Standard clinical role access
--
-- Parameters:
--   - data_subdomain: The DATA_SUBDOMAIN tag value for the row
--
-- Usage: Attach to tables with DATA_SUBDOMAIN column or
-- use with SYSTEM$GET_TAG_ON_CURRENT_TABLE().
-- ------------------------------------------------------------
CREATE OR REPLACE ROW ACCESS POLICY MEDICORE_GOVERNANCE_DB.POLICIES.ROW_ACCESS_CLINICAL
    AS (data_subdomain STRING)
    RETURNS BOOLEAN
    COMMENT = 'Row-level clinical access. SUBSTANCE_ABUSE: COMPLIANCE only. MENTAL_HEALTH: Clinical+COMPLIANCE. Others: standard clinical access.'
    ->
    CASE
        WHEN data_subdomain = 'SUBSTANCE_ABUSE' THEN
            CURRENT_ROLE() IN (
                'MEDICORE_COMPLIANCE_OFFICER',
                'ACCOUNTADMIN'
            )
        WHEN data_subdomain = 'MENTAL_HEALTH' THEN
            CURRENT_ROLE() IN (
                'MEDICORE_CLINICAL_PHYSICIAN',
                'MEDICORE_CLINICAL_NURSE',
                'MEDICORE_COMPLIANCE_OFFICER',
                'ACCOUNTADMIN'
            )
        WHEN data_subdomain IN ('HIV_AIDS', 'REPRODUCTIVE_HEALTH', 'GENETIC') THEN
            CURRENT_ROLE() IN (
                'MEDICORE_CLINICAL_PHYSICIAN',
                'MEDICORE_COMPLIANCE_OFFICER',
                'ACCOUNTADMIN'
            )
        ELSE
            CURRENT_ROLE() IN (
                'MEDICORE_CLINICAL_PHYSICIAN',
                'MEDICORE_CLINICAL_NURSE',
                'MEDICORE_CLINICAL_ANALYST',
                'MEDICORE_BILLING_SPECIALIST',
                'MEDICORE_COMPLIANCE_OFFICER',
                'ACCOUNTADMIN'
            )
    END;

-- ------------------------------------------------------------
-- ROW ACCESS POLICY: ROW_ACCESS_ENVIRONMENT
-- ------------------------------------------------------------
-- Enforces PHI protection in non-production environments.
-- QA and DEV environments must NEVER contain real PHI.
--
-- This policy provides defense-in-depth by blocking PHI
-- access even if real data accidentally reaches non-PROD.
--
-- Access Rules:
--   - PROD environment: Normal role-based access applies
--   - QA/DEV environment + PHI data: Engineering roles only
--   - QA/DEV environment + non-PHI: All authorized roles
--
-- Parameters:
--   - environment: PROD, QA, or DEV
--   - contains_phi: Boolean flag indicating PHI presence
--
-- IMPORTANT: This is a safety net. The primary control is
-- ensuring QA/DEV only receive synthetic/anonymized data.
-- ------------------------------------------------------------
CREATE OR REPLACE ROW ACCESS POLICY MEDICORE_GOVERNANCE_DB.POLICIES.ROW_ACCESS_ENVIRONMENT
    AS (environment STRING, contains_phi BOOLEAN)
    RETURNS BOOLEAN
    COMMENT = 'Environment-based PHI protection. QA/DEV with PHI: engineering only (safety net). Primary control: synthetic data in non-PROD.'
    ->
    CASE
        WHEN environment = 'PROD' THEN
            TRUE
        WHEN environment IN ('QA', 'DEV') AND contains_phi = TRUE THEN
            CURRENT_ROLE() IN (
                'MEDICORE_DATA_ENGINEER',
                'MEDICORE_PLATFORM_ADMIN',
                'MEDICORE_COMPLIANCE_OFFICER',
                'ACCOUNTADMIN'
            )
        ELSE
            TRUE
    END;

-- ------------------------------------------------------------
-- ROW ACCESS POLICY: ROW_ACCESS_CONSENT
-- ------------------------------------------------------------
-- Framework for consent-based row access control.
-- Implements placeholder logic for future consent registry
-- integration per 42 CFR Part 2 requirements.
--
-- 42 CFR Part 2 Consent Requirements:
--   - Written consent must specify recipient and purpose
--   - Consent has expiration date
--   - Patient can revoke at any time
--   - Re-disclosure requires new consent
--
-- Current Implementation:
--   - 42CFR_CONSENT required: COMPLIANCE_OFFICER only
--   - HIPAA_AUTH required: Clinical + Compliance
--   - NONE/other: Standard access
--
-- Future Enhancement:
--   - Join to CONSENT_REGISTRY table
--   - Check consent validity (not expired, not revoked)
--   - Match consent recipient to current user/role
--
-- Parameters:
--   - consent_type: Required consent classification
--   - patient_id: Patient identifier for consent lookup (future)
-- ------------------------------------------------------------
CREATE OR REPLACE ROW ACCESS POLICY MEDICORE_GOVERNANCE_DB.POLICIES.ROW_ACCESS_CONSENT
    AS (consent_type STRING, patient_id STRING)
    RETURNS BOOLEAN
    COMMENT = 'Consent-based access framework. 42CFR_CONSENT: COMPLIANCE only. HIPAA_AUTH: Clinical+COMPLIANCE. Future: consent registry integration.'
    ->
    CASE
        WHEN consent_type = '42CFR_CONSENT' THEN
            CURRENT_ROLE() IN (
                'MEDICORE_COMPLIANCE_OFFICER',
                'ACCOUNTADMIN'
            )
        WHEN consent_type = 'HIPAA_AUTH' THEN
            CURRENT_ROLE() IN (
                'MEDICORE_CLINICAL_PHYSICIAN',
                'MEDICORE_CLINICAL_NURSE',
                'MEDICORE_COMPLIANCE_OFFICER',
                'ACCOUNTADMIN'
            )
        WHEN consent_type = 'RESEARCH_CONSENT' THEN
            CURRENT_ROLE() IN (
                'MEDICORE_DATA_SCIENTIST',
                'MEDICORE_COMPLIANCE_OFFICER',
                'ACCOUNTADMIN'
            )
        ELSE
            TRUE
    END;

-- ------------------------------------------------------------
-- ROW ACCESS POLICY: ROW_ACCESS_DATA_QUALITY
-- ------------------------------------------------------------
-- Controls access based on data quality certification status.
-- Prevents use of quarantined or deprecated data in production
-- analytics while allowing data engineers to remediate.
--
-- Access Rules:
--   - CERTIFIED: All authorized roles
--   - UNDER_REVIEW: Data engineers + Compliance
--   - QUARANTINED: Data engineers only (remediation)
--   - DEPRECATED: Data engineers only (cleanup)
-- ------------------------------------------------------------
CREATE OR REPLACE ROW ACCESS POLICY MEDICORE_GOVERNANCE_DB.POLICIES.ROW_ACCESS_DATA_QUALITY
    AS (dq_status STRING)
    RETURNS BOOLEAN
    COMMENT = 'Data quality-based access. CERTIFIED: all. UNDER_REVIEW: engineers+compliance. QUARANTINED/DEPRECATED: engineers only.'
    ->
    CASE
        WHEN dq_status = 'CERTIFIED' THEN
            TRUE
        WHEN dq_status = 'UNDER_REVIEW' THEN
            CURRENT_ROLE() IN (
                'MEDICORE_DATA_ENGINEER',
                'MEDICORE_COMPLIANCE_OFFICER',
                'MEDICORE_PLATFORM_ADMIN',
                'ACCOUNTADMIN'
            )
        WHEN dq_status IN ('QUARANTINED', 'DEPRECATED') THEN
            CURRENT_ROLE() IN (
                'MEDICORE_DATA_ENGINEER',
                'MEDICORE_PLATFORM_ADMIN',
                'ACCOUNTADMIN'
            )
        ELSE
            TRUE
    END;


-- ============================================================
-- SECTION 4: POLICY ATTACHMENT FRAMEWORK
-- ============================================================
-- This section documents how to attach masking policies to
-- tags for automatic enforcement. Tag-based masking provides
-- centralized governance without per-table DDL maintenance.
--
-- TAG-BASED MASKING WORKFLOW:
-- 1. Create masking policy (done in Section 2)
-- 2. Attach policy to tag using ALTER TAG
-- 3. Apply tag to columns requiring protection
-- 4. Masking automatically enforces at query time
--
-- IMPORTANT: Actual tag-to-policy bindings and column tagging
-- should be performed after data model is finalized. The
-- examples below show the pattern but are commented to avoid
-- premature binding.
-- ============================================================

-- ------------------------------------------------------------
-- TAG-BASED MASKING POLICY ATTACHMENTS
-- ------------------------------------------------------------
-- The following statements attach masking policies to tags.
-- Once attached, any column tagged with that tag value will
-- automatically have the masking policy applied.
--
-- NOTE: These are provided as reference examples. Uncomment
-- and execute when ready to enforce masking across all tagged
-- columns. Test thoroughly in non-production first.
-- ------------------------------------------------------------

-- Attach MASK_DIRECT_IDENTIFIER to PHI_CLASSIFICATION tag
-- When PHI_CLASSIFICATION = 'DIRECT_IDENTIFIER' is set on a column,
-- the MASK_DIRECT_IDENTIFIER policy automatically applies.
--
-- ALTER TAG MEDICORE_GOVERNANCE_DB.TAGS.PHI_CLASSIFICATION
--     SET MASKING POLICY MEDICORE_GOVERNANCE_DB.POLICIES.MASK_DIRECT_IDENTIFIER;

-- Attach MASK_QUASI_IDENTIFIER to PHI_CLASSIFICATION for STRING columns
-- Note: Separate policies needed for DATE/TIMESTAMP columns
--
-- ALTER TAG MEDICORE_GOVERNANCE_DB.TAGS.PHI_CLASSIFICATION
--     SET MASKING POLICY MEDICORE_GOVERNANCE_DB.POLICIES.MASK_QUASI_IDENTIFIER;

-- Attach MASK_SENSITIVE_CLINICAL for clinical data protection
--
-- ALTER TAG MEDICORE_GOVERNANCE_DB.TAGS.DATA_SUBDOMAIN
--     SET MASKING POLICY MEDICORE_GOVERNANCE_DB.POLICIES.MASK_SENSITIVE_CLINICAL;

-- Attach MASK_42CFR_PART2 for substance abuse data
--
-- ALTER TAG MEDICORE_GOVERNANCE_DB.TAGS.REGULATORY_FRAMEWORK
--     SET MASKING POLICY MEDICORE_GOVERNANCE_DB.POLICIES.MASK_42CFR_PART2;

-- ------------------------------------------------------------
-- COLUMN-LEVEL TAG APPLICATION EXAMPLES
-- ------------------------------------------------------------
-- After tag-policy binding, apply tags to columns to activate
-- masking. These examples show the pattern for common PHI columns.
--
-- NOTE: Replace with actual table/column names from data model.
-- Execute after data model is finalized.
-- ------------------------------------------------------------

-- Example: Tag patient name as direct identifier
-- ALTER TABLE MEDICORE_ANALYTICS_DB.CLINICAL.DIM_PATIENT
--     MODIFY COLUMN PATIENT_NAME
--     SET TAG MEDICORE_GOVERNANCE_DB.TAGS.PHI_CLASSIFICATION = 'DIRECT_IDENTIFIER';

-- Example: Tag SSN as direct identifier
-- ALTER TABLE MEDICORE_ANALYTICS_DB.CLINICAL.DIM_PATIENT
--     MODIFY COLUMN SSN
--     SET TAG MEDICORE_GOVERNANCE_DB.TAGS.PHI_CLASSIFICATION = 'DIRECT_IDENTIFIER';

-- Example: Tag date of birth as quasi-identifier
-- ALTER TABLE MEDICORE_ANALYTICS_DB.CLINICAL.DIM_PATIENT
--     MODIFY COLUMN DATE_OF_BIRTH
--     SET TAG MEDICORE_GOVERNANCE_DB.TAGS.PHI_CLASSIFICATION = 'QUASI_IDENTIFIER';

-- Example: Tag ZIP code as quasi-identifier
-- ALTER TABLE MEDICORE_ANALYTICS_DB.CLINICAL.DIM_PATIENT
--     MODIFY COLUMN ZIP_CODE
--     SET TAG MEDICORE_GOVERNANCE_DB.TAGS.PHI_CLASSIFICATION = 'QUASI_IDENTIFIER';

-- Example: Tag diagnosis as sensitive clinical
-- ALTER TABLE MEDICORE_ANALYTICS_DB.CLINICAL.FCT_ENCOUNTER
--     MODIFY COLUMN PRIMARY_DIAGNOSIS
--     SET TAG MEDICORE_GOVERNANCE_DB.TAGS.DATA_SUBDOMAIN = 'DIAGNOSES';

-- Example: Tag substance abuse treatment as 42 CFR Part 2
-- ALTER TABLE MEDICORE_ANALYTICS_DB.CLINICAL.FCT_TREATMENT
--     MODIFY COLUMN TREATMENT_NOTES
--     SET TAG MEDICORE_GOVERNANCE_DB.TAGS.REGULATORY_FRAMEWORK = '42CFR_PART2';

-- ------------------------------------------------------------
-- ROW ACCESS POLICY ATTACHMENT EXAMPLES
-- ------------------------------------------------------------
-- Row access policies are attached directly to tables (not tags).
-- They reference columns that contain classification values.
--
-- NOTE: Execute after data model includes required columns.
-- ------------------------------------------------------------

-- Example: Attach clinical row access policy
-- ALTER TABLE MEDICORE_ANALYTICS_DB.CLINICAL.FCT_ENCOUNTER
--     ADD ROW ACCESS POLICY MEDICORE_GOVERNANCE_DB.POLICIES.ROW_ACCESS_CLINICAL
--     ON (DATA_SUBDOMAIN);

-- Example: Attach environment-based row access policy
-- ALTER TABLE MEDICORE_RAW_DB.INGESTION.STG_PATIENT
--     ADD ROW ACCESS POLICY MEDICORE_GOVERNANCE_DB.POLICIES.ROW_ACCESS_ENVIRONMENT
--     ON (ENVIRONMENT, CONTAINS_PHI);

-- Example: Attach consent-based row access policy
-- ALTER TABLE MEDICORE_ANALYTICS_DB.CLINICAL.FCT_TREATMENT
--     ADD ROW ACCESS POLICY MEDICORE_GOVERNANCE_DB.POLICIES.ROW_ACCESS_CONSENT
--     ON (CONSENT_TYPE, PATIENT_ID);


-- ============================================================
-- SECTION 5: GOVERNANCE GRANTS
-- ============================================================
-- Grant privileges to create and manage governance objects.
-- MEDICORE_COMPLIANCE_OFFICER is the designated governance
-- administrator per HIPAA requirements.
--
-- GRANT HIERARCHY:
--   - ACCOUNTADMIN: Full ownership (schema owner)
--   - COMPLIANCE_OFFICER: Create policies and tags
--   - Other roles: No governance object creation
--
-- IMPORTANT: Do not grant governance privileges to:
--   - Data engineers (separation of duties)
--   - Analysts (consumers, not governors)
--   - Clinical roles (data consumers)
-- ============================================================

-- Grant CREATE TAG privilege on TAGS schema
GRANT CREATE TAG ON SCHEMA MEDICORE_GOVERNANCE_DB.TAGS
    TO ROLE MEDICORE_COMPLIANCE_OFFICER;

-- Grant CREATE MASKING POLICY privilege on POLICIES schema
GRANT CREATE MASKING POLICY ON SCHEMA MEDICORE_GOVERNANCE_DB.POLICIES
    TO ROLE MEDICORE_COMPLIANCE_OFFICER;

-- Grant CREATE ROW ACCESS POLICY privilege on POLICIES schema
GRANT CREATE ROW ACCESS POLICY ON SCHEMA MEDICORE_GOVERNANCE_DB.POLICIES
    TO ROLE MEDICORE_COMPLIANCE_OFFICER;

-- Grant USAGE on governance schemas to allow policy management
GRANT USAGE ON SCHEMA MEDICORE_GOVERNANCE_DB.TAGS
    TO ROLE MEDICORE_COMPLIANCE_OFFICER;

GRANT USAGE ON SCHEMA MEDICORE_GOVERNANCE_DB.POLICIES
    TO ROLE MEDICORE_COMPLIANCE_OFFICER;

-- Grant APPLY TAG privilege for applying tags to objects
-- This allows COMPLIANCE_OFFICER to tag columns across databases
GRANT APPLY TAG ON ACCOUNT
    TO ROLE MEDICORE_COMPLIANCE_OFFICER;

-- Grant APPLY MASKING POLICY for binding policies to columns
GRANT APPLY MASKING POLICY ON ACCOUNT
    TO ROLE MEDICORE_COMPLIANCE_OFFICER;

-- Grant APPLY ROW ACCESS POLICY for binding policies to tables
GRANT APPLY ROW ACCESS POLICY ON ACCOUNT
    TO ROLE MEDICORE_COMPLIANCE_OFFICER;

-- ------------------------------------------------------------
-- NOTE: Tags and policies do not require USAGE grants.
-- - Tags: Roles can read tag values via INFORMATION_SCHEMA
--         or ACCOUNT_USAGE views with appropriate privileges
-- - Masking/Row Access Policies: Applied automatically when
--         attached to columns/tables; no USAGE privilege needed
-- 
-- The APPLY privileges granted above allow COMPLIANCE_OFFICER
-- to attach policies to objects across the account.
-- ------------------------------------------------------------


-- ============================================================
-- SECTION 6: VERIFICATION QUERIES
-- ============================================================
-- Verification queries to confirm successful deployment of
-- governance objects. Run after script execution to validate.
-- ============================================================

-- Verify all tags created in TAGS schema
SHOW TAGS IN SCHEMA MEDICORE_GOVERNANCE_DB.TAGS;

-- Verify all masking policies created in POLICIES schema
SHOW MASKING POLICIES IN SCHEMA MEDICORE_GOVERNANCE_DB.POLICIES;

-- Verify all row access policies created in POLICIES schema
SHOW ROW ACCESS POLICIES IN SCHEMA MEDICORE_GOVERNANCE_DB.POLICIES;

-- Verify grants to COMPLIANCE_OFFICER on TAGS schema
SHOW GRANTS TO ROLE MEDICORE_COMPLIANCE_OFFICER;

-- List tag references (shows where tags are applied)
-- Note: Will be empty until tags are applied to objects
-- SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES
-- WHERE TAG_DATABASE = 'MEDICORE_GOVERNANCE_DB'
-- ORDER BY OBJECT_DATABASE, OBJECT_SCHEMA, OBJECT_NAME;


-- ============================================================
-- PHASE 08 COMPLETE
-- ============================================================
-- Data governance layer has been implemented with:
--
-- TAGS CREATED (13):
--   - PHI_CLASSIFICATION
--   - PHI_ELEMENT_TYPE
--   - DATA_DOMAIN
--   - DATA_SUBDOMAIN
--   - DATA_QUALITY_STATUS
--   - DQ_ISSUE_TYPE
--   - MEDALLION_LAYER
--   - ENVIRONMENT
--   - SOURCE_SYSTEM
--   - REFRESH_FREQUENCY
--   - REGULATORY_FRAMEWORK
--   - CONSENT_REQUIRED
--   - RETENTION_POLICY
--
-- MASKING POLICIES CREATED (6):
--   - MASK_DIRECT_IDENTIFIER (HIPAA Safe Harbor 18)
--   - MASK_QUASI_IDENTIFIER (generalization)
--   - MASK_QUASI_IDENTIFIER_DATE (date truncation)
--   - MASK_QUASI_IDENTIFIER_TIMESTAMP (timestamp truncation)
--   - MASK_SENSITIVE_CLINICAL (clinical data)
--   - MASK_42CFR_PART2 (substance abuse)
--   - MASK_FINANCIAL_PII (financial data)
--
-- ROW ACCESS POLICIES CREATED (4):
--   - ROW_ACCESS_CLINICAL (subdomain-based)
--   - ROW_ACCESS_ENVIRONMENT (PROD/QA/DEV)
--   - ROW_ACCESS_CONSENT (consent framework)
--   - ROW_ACCESS_DATA_QUALITY (DQ status)
--
-- NEXT STEPS:
--   1. Finalize data model with PHI column identification
--   2. Apply tags to columns per data classification
--   3. Bind masking policies to tags
--   4. Attach row access policies to tables
--   5. Test masking behavior with each role
--   6. Validate 42 CFR Part 2 segregation
--   7. Document governance in data catalog
-- ============================================================
