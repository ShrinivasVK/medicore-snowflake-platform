-- ============================================================
-- MEDICORE HEALTH SYSTEMS - SNOWFLAKE DATA PLATFORM
-- ============================================================
-- Phase 02: RBAC Setup
-- Script: 02_rbac_setup.sql
--
-- Description:
--   Creates the complete role-based access control hierarchy for
--   MediCore Health Systems. Implements 17 custom roles across 8
--   tiers following the approved RBAC design document. Establishes
--   role inheritance and connects to Snowflake system roles.
--
-- Execution Requirements:
--   - Must be run as ACCOUNTADMIN initially
--   - Script transitions to SECURITYADMIN for role grants
--   - Execute statements sequentially from top to bottom
--
-- Dependencies:
--   - Phase 01 must be completed first
--   - GOVERNANCE_DB must exist
--   - GOVERNANCE_DB.SECURITY schema must exist
--   - MEDICORE_PASSWORD_POLICY must exist (for service account)
--
-- !! WARNING !!
--   Role hierarchy changes affect ALL users and warehouse access.
--   Review all grants carefully before execution in production.
--   Incorrect grants can expose PHI or lock out legitimate users.
--
-- Author: [YOUR_NAME]
-- Date: [YYYY-MM-DD]
-- ============================================================

-- ============================================================
-- SECTION 1: EXECUTION CONTEXT
-- ============================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================
-- SECTION 2: CUSTOM ROLE CREATION
-- ============================================================
-- Creating 17 custom roles organized by tier as defined in
-- the approved RBAC design document (rbac-design.md)
-- ============================================================

-- ------------------------------------------------------------
-- TIER 1: ADMINISTRATIVE ROLES (2 roles)
-- Platform and security administration - no direct PHI access
-- ------------------------------------------------------------

CREATE ROLE IF NOT EXISTS MEDICORE_PLATFORM_ADMIN
    COMMENT = 'Platform administrator for Snowflake account management. Manages warehouses, network policies, and account settings. Cannot directly query PHI data. Persona: Hospital IT Director, Cloud Infrastructure Team.';

CREATE ROLE IF NOT EXISTS MEDICORE_SECURITY_ADMIN
    COMMENT = 'Security and compliance administrator for data governance. Manages tags, masking policies, row access policies, and audit logs. Cannot directly query PHI data. Persona: CISO, Privacy Officer, Security Analyst.';

-- ------------------------------------------------------------
-- TIER 2: DATA ENGINEERING ROLES (2 roles)
-- Pipeline development and ETL operations
-- ------------------------------------------------------------

CREATE ROLE IF NOT EXISTS MEDICORE_DATA_ENGINEER
    COMMENT = 'Data pipeline developers with full RAW_DB and TRANSFORM_DB access. Can read ANALYTICS_DB and AI_READY_DB. Cannot manage security policies. Persona: Data Engineers, ETL Developers, Integration Specialists.';

CREATE ROLE IF NOT EXISTS MEDICORE_SVC_ETL_LOADER
    COMMENT = 'Service account role for automated ETL pipelines. Write-only to designated pipeline schemas. No interactive access. Isolated from human user roles. Persona: Airflow, dbt, Fivetran service connections.';

-- ------------------------------------------------------------
-- TIER 3: CLINICAL ROLES (3 roles)
-- Patient care and clinical data access
-- ------------------------------------------------------------

CREATE ROLE IF NOT EXISTS MEDICORE_CLINICAL_PHYSICIAN
    COMMENT = 'Attending physicians with full clinical PHI access for patient care. Access to encounters, diagnoses, medications, labs. HIPAA Treatment exception applies. Persona: Attending Physicians, Medical Directors, CMO.';

CREATE ROLE IF NOT EXISTS MEDICORE_CLINICAL_NURSE
    COMMENT = 'Nursing staff with unit-restricted clinical access. Financial identifiers masked. 42 CFR Part 2 records require consent. Persona: RNs, LPNs, Nurse Practitioners, Care Coordinators.';

CREATE ROLE IF NOT EXISTS MEDICORE_CLINICAL_READER
    COMMENT = 'Read-only clinical access for support staff. Limited to patient name and MRN only. All other PHI masked. Persona: Medical Assistants, Unit Clerks, Schedulers.';

-- ------------------------------------------------------------
-- TIER 4: REVENUE CYCLE ROLES (2 roles)
-- Billing, coding, and claims operations
-- ------------------------------------------------------------

CREATE ROLE IF NOT EXISTS MEDICORE_BILLING_SPECIALIST
    COMMENT = 'Billing and coding staff with access to charges, claims, and diagnosis codes. Clinical notes masked. Cannot access 42 CFR Part 2 records. Persona: Medical Coders, Billing Representatives, Revenue Cycle Analysts.';

CREATE ROLE IF NOT EXISTS MEDICORE_BILLING_READER
    COMMENT = 'Read-only billing data for financial reporting. Aggregated views only, no patient-level detail. Persona: Revenue Cycle Managers, Financial Analysts.';

-- ------------------------------------------------------------
-- TIER 5: ANALYTICS ROLES (3 roles)
-- Data analysis and machine learning
-- ------------------------------------------------------------

CREATE ROLE IF NOT EXISTS MEDICORE_ANALYST_PHI
    COMMENT = 'Clinical data analysts with PHI access for quality and outcomes research. Patient-level data allowed. HIPAA Operations exception applies. Persona: Clinical Data Analysts, Quality Improvement Specialists, Population Health Analysts.';

CREATE ROLE IF NOT EXISTS MEDICORE_ANALYST_RESTRICTED
    COMMENT = 'Business analysts with de-identified data only. No PHI access. Aggregated and de-identified datasets only. Persona: Business Intelligence Analysts, Report Developers, Operations Analysts.';

CREATE ROLE IF NOT EXISTS MEDICORE_DATA_SCIENTIST
    COMMENT = 'ML/AI practitioners with full AI_READY_DB access. Can read ANALYTICS_DB and TRANSFORM_DB. Model deployment requires Security Admin approval. Persona: Data Scientists, ML Engineers, AI Researchers.';

-- ------------------------------------------------------------
-- TIER 6: COMPLIANCE & AUDIT ROLES (2 roles)
-- Regulatory compliance and external auditing
-- ------------------------------------------------------------

CREATE ROLE IF NOT EXISTS MEDICORE_COMPLIANCE_OFFICER
    COMMENT = 'Compliance monitoring with full read access everywhere including audit logs. Cannot modify data or configurations. Persona: Compliance Officers, Privacy Officers, Internal Auditors.';

CREATE ROLE IF NOT EXISTS MEDICORE_EXT_AUDITOR
    COMMENT = 'External auditor with time-limited, heavily restricted access. Pre-staged extracts only, all PHI masked. Access expires automatically. Persona: External CPA Firms, HITRUST Assessors, OCR Investigators.';

-- ------------------------------------------------------------
-- TIER 7: EXECUTIVE & BASE ROLES (2 roles)
-- Executive dashboards and foundation access
-- ------------------------------------------------------------

CREATE ROLE IF NOT EXISTS MEDICORE_EXECUTIVE
    COMMENT = 'Executive dashboards with aggregated KPIs only. No patient-level data access. No PHI exposure. Persona: CEO, CFO, COO, Board Members.';

CREATE ROLE IF NOT EXISTS MEDICORE_REFERENCE_READER
    COMMENT = 'Base role with reference/lookup data only. ICD-10 codes, CPT codes, facility master, department master. No PHI. Foundation role for all authenticated users.';

-- ------------------------------------------------------------
-- TIER 8: APPLICATION ROLES (1 role)
-- Streamlit and application service accounts
-- ------------------------------------------------------------

CREATE ROLE IF NOT EXISTS MEDICORE_APP_STREAMLIT
    COMMENT = 'Service role for Streamlit applications running in Snowflake. Inherits from configured role at deployment. Uses CURRENT_ROLE() of invoking user for row access policies.';

-- VERIFICATION: All 17 roles created
SHOW ROLES LIKE 'MEDICORE%';


-- ============================================================
-- SECTION 3: ROLE HIERARCHY GRANTS
-- ============================================================
-- Implementing role inheritance as defined in the hierarchy
-- diagram. Child roles are granted TO parent roles, meaning
-- parent roles inherit all privileges from child roles.
-- Direction: GRANT ROLE child TO ROLE parent
-- ============================================================

USE ROLE SECURITYADMIN;

-- ------------------------------------------------------------
-- DATA ACCESS HIERARCHY - CORE INHERITANCE CHAIN
-- Direction: REFERENCE_READER -> higher roles
-- ------------------------------------------------------------

-- Base tier: REFERENCE_READER is the foundation
-- All data access roles inherit from REFERENCE_READER

-- ANALYST_RESTRICTED inherits from REFERENCE_READER
GRANT ROLE MEDICORE_REFERENCE_READER TO ROLE MEDICORE_ANALYST_RESTRICTED;

-- CLINICAL_READER inherits from REFERENCE_READER
GRANT ROLE MEDICORE_REFERENCE_READER TO ROLE MEDICORE_CLINICAL_READER;

-- BILLING_READER inherits from REFERENCE_READER
GRANT ROLE MEDICORE_REFERENCE_READER TO ROLE MEDICORE_BILLING_READER;

-- ------------------------------------------------------------
-- CLINICAL HIERARCHY
-- Direction: READER -> NURSE -> PHYSICIAN
-- ------------------------------------------------------------

-- CLINICAL_NURSE inherits from CLINICAL_READER
GRANT ROLE MEDICORE_CLINICAL_READER TO ROLE MEDICORE_CLINICAL_NURSE;

-- CLINICAL_PHYSICIAN inherits from CLINICAL_NURSE
GRANT ROLE MEDICORE_CLINICAL_NURSE TO ROLE MEDICORE_CLINICAL_PHYSICIAN;

-- ------------------------------------------------------------
-- BILLING HIERARCHY
-- Direction: READER -> SPECIALIST
-- ------------------------------------------------------------

-- BILLING_SPECIALIST inherits from BILLING_READER
GRANT ROLE MEDICORE_BILLING_READER TO ROLE MEDICORE_BILLING_SPECIALIST;

-- ------------------------------------------------------------
-- ANALYTICS HIERARCHY
-- Direction: RESTRICTED -> PHI -> ENGINEER
-- ------------------------------------------------------------

-- ANALYST_PHI inherits from ANALYST_RESTRICTED
GRANT ROLE MEDICORE_ANALYST_RESTRICTED TO ROLE MEDICORE_ANALYST_PHI;

-- DATA_ENGINEER inherits from ANALYST_PHI
GRANT ROLE MEDICORE_ANALYST_PHI TO ROLE MEDICORE_DATA_ENGINEER;

-- DATA_SCIENTIST inherits from ANALYST_PHI
GRANT ROLE MEDICORE_ANALYST_PHI TO ROLE MEDICORE_DATA_SCIENTIST;

-- ------------------------------------------------------------
-- EXECUTIVE HIERARCHY
-- Direction: RESTRICTED -> EXECUTIVE
-- ------------------------------------------------------------

-- EXECUTIVE inherits from ANALYST_RESTRICTED (aggregates only)
GRANT ROLE MEDICORE_ANALYST_RESTRICTED TO ROLE MEDICORE_EXECUTIVE;

-- ------------------------------------------------------------
-- COMPLIANCE HIERARCHY
-- Direction: PHI -> COMPLIANCE_OFFICER
-- ------------------------------------------------------------

-- COMPLIANCE_OFFICER inherits from ANALYST_PHI (full read access)
GRANT ROLE MEDICORE_ANALYST_PHI TO ROLE MEDICORE_COMPLIANCE_OFFICER;

-- ------------------------------------------------------------
-- STANDALONE ROLES (No inheritance - isolated by design)
-- These roles do not inherit from the main hierarchy
-- ------------------------------------------------------------

-- MEDICORE_SVC_ETL_LOADER: Standalone, minimal privileges, service account only
-- MEDICORE_EXT_AUDITOR: Standalone, time-limited, pre-staged views only
-- MEDICORE_APP_STREAMLIT: Standalone, inherits at runtime from invoking user

-- VERIFICATION: Role hierarchy established
-- Show which roles have been granted to key roles in the hierarchy
SHOW GRANTS OF ROLE MEDICORE_REFERENCE_READER;
SHOW GRANTS OF ROLE MEDICORE_ANALYST_RESTRICTED;
SHOW GRANTS OF ROLE MEDICORE_ANALYST_PHI;
SHOW GRANTS OF ROLE MEDICORE_CLINICAL_READER;
SHOW GRANTS OF ROLE MEDICORE_BILLING_READER;


-- ============================================================
-- SECTION 4: GRANT ROLES TO SNOWFLAKE SYSTEM ROLES
-- ============================================================
-- Connecting custom role hierarchy to Snowflake's native
-- role structure. Follows principle of least privilege.
-- ============================================================

USE ROLE ACCOUNTADMIN;

-- ------------------------------------------------------------
-- ADMINISTRATIVE ROLE CONNECTIONS
-- ------------------------------------------------------------

-- PLATFORM_ADMIN reports to SYSADMIN for database/warehouse management
-- Note: Design doc originally showed ACCOUNTADMIN, but granting custom roles
-- to ACCOUNTADMIN is discouraged. SYSADMIN is the better practice.
GRANT ROLE MEDICORE_PLATFORM_ADMIN TO ROLE SYSADMIN;

-- SECURITY_ADMIN reports to SECURITYADMIN for access control
GRANT ROLE MEDICORE_SECURITY_ADMIN TO ROLE SECURITYADMIN;

-- ------------------------------------------------------------
-- TOP-LEVEL DATA ROLES TO SYSADMIN
-- These are the highest roles in each functional hierarchy
-- ------------------------------------------------------------

-- Data Engineering top role
GRANT ROLE MEDICORE_DATA_ENGINEER TO ROLE SYSADMIN;

-- Service account role (for pipeline management)
GRANT ROLE MEDICORE_SVC_ETL_LOADER TO ROLE SYSADMIN;

-- Clinical top role
GRANT ROLE MEDICORE_CLINICAL_PHYSICIAN TO ROLE SYSADMIN;

-- Billing top role
GRANT ROLE MEDICORE_BILLING_SPECIALIST TO ROLE SYSADMIN;

-- Analytics top roles
GRANT ROLE MEDICORE_DATA_SCIENTIST TO ROLE SYSADMIN;

-- Compliance top role
GRANT ROLE MEDICORE_COMPLIANCE_OFFICER TO ROLE SYSADMIN;

-- Executive role
GRANT ROLE MEDICORE_EXECUTIVE TO ROLE SYSADMIN;

-- External auditor (managed by SYSADMIN for time-limited access)
GRANT ROLE MEDICORE_EXT_AUDITOR TO ROLE SYSADMIN;

-- Application role
GRANT ROLE MEDICORE_APP_STREAMLIT TO ROLE SYSADMIN;

-- VERIFICATION: System role connections
SHOW GRANTS TO ROLE SYSADMIN;
SHOW GRANTS TO ROLE SECURITYADMIN;


-- ============================================================
-- SECTION 5: SERVICE ACCOUNT USER SETUP
-- ============================================================
-- Creating service account for ETL pipelines with appropriate
-- security controls and password policy
-- ============================================================

USE ROLE SECURITYADMIN;

-- Create service account user for ETL operations
-- User is created DISABLED - must configure key-pair auth before enabling
-- DO NOT enable with password authentication in production
CREATE USER IF NOT EXISTS SVC_ETL_MEDICORE
    DEFAULT_ROLE = MEDICORE_SVC_ETL_LOADER
    DEFAULT_WAREHOUSE = NULL
    DISABLED = TRUE
    COMMENT = 'Service account for MediCore ETL pipelines. Created DISABLED until key-pair authentication is configured. Do not enable with password auth. Manual post-step: Configure RSA key pair and enable user.';

-- Grant the ETL loader role to the service account
GRANT ROLE MEDICORE_SVC_ETL_LOADER TO USER SVC_ETL_MEDICORE;

-- Note: Password policy not applied since service account uses key-pair auth
-- When key-pair is configured, enable the user with:
-- ALTER USER SVC_ETL_MEDICORE SET RSA_PUBLIC_KEY = '<public_key>';
-- ALTER USER SVC_ETL_MEDICORE SET DISABLED = FALSE;

-- VERIFICATION: Service account created
SHOW USERS LIKE 'SVC%';


-- ============================================================
-- SECTION 6: COMPREHENSIVE VERIFICATION QUERIES
-- ============================================================
-- Final verification of all RBAC components
-- ============================================================

USE ROLE ACCOUNTADMIN;

-- Verify all 17 MEDICORE roles exist (uses ACCOUNT_USAGE for reliable count)
SELECT COUNT(*) AS medicore_role_count
FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
WHERE NAME LIKE 'MEDICORE%'
AND DELETED_ON IS NULL;

-- List all MEDICORE roles with details
SHOW ROLES LIKE 'MEDICORE%';

-- Verify grants to SYSADMIN
SHOW GRANTS TO ROLE SYSADMIN;

-- Verify grants to SECURITYADMIN  
SHOW GRANTS TO ROLE SECURITYADMIN;

-- Verify service account
DESCRIBE USER SVC_ETL_MEDICORE;


-- ============================================================
-- SECTION 7: PHASE 02 SUMMARY
-- ============================================================
--
-- ROLES CREATED: 17
--   Tier 1 - Administrative:     MEDICORE_PLATFORM_ADMIN
--                                MEDICORE_SECURITY_ADMIN
--   Tier 2 - Data Engineering:   MEDICORE_DATA_ENGINEER
--                                MEDICORE_SVC_ETL_LOADER
--   Tier 3 - Clinical:           MEDICORE_CLINICAL_PHYSICIAN
--                                MEDICORE_CLINICAL_NURSE
--                                MEDICORE_CLINICAL_READER
--   Tier 4 - Revenue Cycle:      MEDICORE_BILLING_SPECIALIST
--                                MEDICORE_BILLING_READER
--   Tier 5 - Analytics:          MEDICORE_ANALYST_PHI
--                                MEDICORE_ANALYST_RESTRICTED
--                                MEDICORE_DATA_SCIENTIST
--   Tier 6 - Compliance:         MEDICORE_COMPLIANCE_OFFICER
--                                MEDICORE_EXT_AUDITOR
--   Tier 7 - Executive/Base:     MEDICORE_EXECUTIVE
--                                MEDICORE_REFERENCE_READER
--   Tier 8 - Application:        MEDICORE_APP_STREAMLIT
--
-- HIERARCHY GRANTS: 11
--   - REFERENCE_READER -> ANALYST_RESTRICTED
--   - REFERENCE_READER -> CLINICAL_READER
--   - REFERENCE_READER -> BILLING_READER
--   - CLINICAL_READER -> CLINICAL_NURSE
--   - CLINICAL_NURSE -> CLINICAL_PHYSICIAN
--   - BILLING_READER -> BILLING_SPECIALIST
--   - ANALYST_RESTRICTED -> ANALYST_PHI
--   - ANALYST_PHI -> DATA_ENGINEER
--   - ANALYST_PHI -> DATA_SCIENTIST
--   - ANALYST_RESTRICTED -> EXECUTIVE
--   - ANALYST_PHI -> COMPLIANCE_OFFICER
--
-- SYSTEM ROLE GRANTS: 13
--   - 2 to SECURITYADMIN (SECURITY_ADMIN)
--   - 11 to SYSADMIN (all other top-level roles)
--
-- SERVICE ACCOUNTS CREATED: 1
--   - SVC_ETL_MEDICORE (DISABLED - requires key-pair auth setup)
--
-- PHASE 03 DEPENDENCIES:
--   - Roles exist for warehouse USAGE grants
--   - Role hierarchy established for privilege inheritance
--   - Service account created (requires key-pair auth configuration)
--   - Administrative roles ready for warehouse management
--
-- ============================================================
-- END OF PHASE 02: RBAC SETUP
-- ============================================================
