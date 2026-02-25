-- ============================================================
-- MEDICORE HEALTH SYSTEMS - SNOWFLAKE DATA PLATFORM
-- ============================================================
-- Phase 01: Account Administration
-- Script: 01_account_administration.sql
-- Version: 2.0.0
--
-- Change Reason: Renamed GOVERNANCE_DB to MEDICORE_GOVERNANCE_DB
--               to align with refined database naming convention.
--               SECURITY schema retained as Phase 01 bootstrap
--               prerequisite for security policy objects.
--               All remaining governance schemas (POLICIES, TAGS,
--               DATA_QUALITY, AUDIT) are created in Phase 04.
--
-- Description:
--   Configures account-level security settings for a HIPAA-compliant
--   Business Critical Snowflake environment. Creates MEDICORE_GOVERNANCE_DB
--   and MEDICORE_GOVERNANCE_DB.SECURITY as a bootstrap step — these are
--   required by Phase 01 to house security policy objects before any
--   other phase runs. Phase 04 completes the full governance database
--   structure.
--
-- Scope: 8 tables across 3 domains (REFERENCE, CLINICAL, BILLING)
--
-- Prerequisites:
--   - Must be executed as ACCOUNTADMIN
--   - Snowflake Business Critical Edition
--   - Signed BAA with Snowflake
--
-- Execution Order:
--   Phase 01 (this file) → Phase 02 → Phase 03 → Phase 04 → Phase 05
--
-- !! WARNING !!
--   This script configures ACCOUNT-LEVEL settings affecting ALL users.
--   Network policy misconfiguration can lock out all users.
--   MEDICORE_GOVERNANCE_DB.SECURITY is created here as a bootstrap
--   prerequisite only. Do not add non-security objects to this schema.
--   All other governance schemas are managed exclusively by Phase 04.
--
-- Author: [YOUR_NAME]
-- Date: [YYYY-MM-DD]
-- ============================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================
-- SECTION 1: GOVERNANCE DATABASE BOOTSTRAP
-- ============================================================
-- MEDICORE_GOVERNANCE_DB and its SECURITY schema are created
-- here as a Phase 01 bootstrap prerequisite ONLY.
--
-- Reason: Password policies, session policies, and network rules
-- must live in a named schema. These objects are required by
-- Phase 01 and must exist before any other phase runs.
--
-- Phase 04 will create the remaining governance schemas:
--   MEDICORE_GOVERNANCE_DB.POLICIES
--   MEDICORE_GOVERNANCE_DB.TAGS
--   MEDICORE_GOVERNANCE_DB.DATA_QUALITY
--   MEDICORE_GOVERNANCE_DB.AUDIT
--
-- Do NOT create any non-security objects in this schema.
-- Do NOT create any other schemas in MEDICORE_GOVERNANCE_DB here.
-- ============================================================

CREATE DATABASE IF NOT EXISTS MEDICORE_GOVERNANCE_DB
    COMMENT = 'Central governance database for MediCore Health Systems. Houses security policies (Phase 01), data governance policies, tags, data quality rules, and audit views (Phase 04). Environment-agnostic — no DEV/QA/PROD schema split. Governance objects apply uniformly across all environments.';

CREATE SCHEMA IF NOT EXISTS MEDICORE_GOVERNANCE_DB.SECURITY
    COMMENT = 'Bootstrap schema created in Phase 01. Houses account-level security objects: network rules, password policies, session policies. Created before all other phases as a prerequisite for policy application. Managed by ACCOUNTADMIN and MEDICORE_PLATFORM_ADMIN.';

-- Verification
SHOW SCHEMAS IN DATABASE MEDICORE_GOVERNANCE_DB;

-- ============================================================
-- SECTION 2: NETWORK POLICY
-- ============================================================
-- HIPAA Reference: 45 CFR 164.312(a)(1) - Access Control
-- Restricts Snowflake access to approved IP ranges only.
-- All connections from outside approved ranges are rejected.
-- ============================================================

-- !! PLACEHOLDER IP - Replace before production !!
-- Production should include: corporate IPs, VPN endpoints, CI/CD runners
CREATE OR REPLACE NETWORK RULE MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_ALLOWED_IPS
    TYPE = IPV4
    VALUE_LIST = ('0.0.0.0/0')
    MODE = INGRESS
    COMMENT = 'PLACEHOLDER - Replace with production corporate IP ranges before go-live. Should include: corporate office IPs, VPN gateway IPs, GitHub Actions runner IPs, Azure DevOps agent IPs.';

CREATE OR REPLACE NETWORK POLICY MEDICORE_NETWORK_POLICY
    ALLOWED_NETWORK_RULE_LIST = ('MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_ALLOWED_IPS')
    COMMENT = 'Primary account-level network policy per HIPAA 164.312(a)(1) Access Control. Applied at account level — affects all users and service accounts.';

ALTER ACCOUNT SET NETWORK_POLICY = MEDICORE_NETWORK_POLICY;

-- Verification
SHOW NETWORK POLICIES LIKE 'MEDICORE%';

-- ============================================================
-- SECTION 3: PASSWORD POLICY
-- ============================================================
-- HIPAA Reference: 45 CFR 164.308(a)(5)(ii)(D) - Password Management
-- Enforces strong password requirements for all human users.
-- Note: Service accounts (SVC_ETL_MEDICORE, SVC_GITHUB_ACTIONS)
-- use key-pair authentication and bypass password policy.
-- ============================================================

CREATE OR REPLACE PASSWORD POLICY MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_PASSWORD_POLICY
    PASSWORD_MIN_LENGTH = 14
    PASSWORD_MAX_LENGTH = 128
    PASSWORD_MIN_UPPER_CASE_CHARS = 1
    PASSWORD_MIN_LOWER_CASE_CHARS = 1
    PASSWORD_MIN_NUMERIC_CHARS = 1
    PASSWORD_MIN_SPECIAL_CHARS = 1
    PASSWORD_MIN_AGE_DAYS = 1
    PASSWORD_MAX_AGE_DAYS = 90
    PASSWORD_MAX_RETRIES = 5
    PASSWORD_LOCKOUT_TIME_MINS = 30
    PASSWORD_HISTORY = 12
    COMMENT = 'HIPAA/HITRUST compliant password policy: 14+ chars, mixed case, numeric and special chars required, 90-day expiry, 12-password history, 30-min lockout after 5 failed attempts. Applied at account level.';

ALTER ACCOUNT SET PASSWORD POLICY MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_PASSWORD_POLICY;

-- Verification
DESCRIBE PASSWORD POLICY MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_PASSWORD_POLICY;

-- ============================================================
-- SECTION 4: SESSION POLICY
-- ============================================================
-- HIPAA Reference: 45 CFR 164.312(a)(2)(iii) - Automatic Logoff
-- Forces session termination after period of inactivity.
-- Prevents unauthorized access from unattended workstations.
-- ============================================================

CREATE OR REPLACE SESSION POLICY MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_SESSION_POLICY
    SESSION_IDLE_TIMEOUT_MINS = 240
    SESSION_UI_IDLE_TIMEOUT_MINS = 240
    COMMENT = '4-hour idle timeout per HIPAA 164.312(a)(2)(iii) Automatic Logoff requirement. Applies to all interactive sessions including Snowsight UI and programmatic connections.';

ALTER ACCOUNT SET SESSION POLICY MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_SESSION_POLICY;

-- Verification
DESCRIBE SESSION POLICY MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_SESSION_POLICY;

-- ============================================================
-- SECTION 5: ACCOUNT PARAMETERS
-- ============================================================
-- Account-level configuration for performance, security,
-- and compliance. These settings apply to all users,
-- warehouses, and workloads across the entire account.
-- ============================================================

-- Timezone: Central Time (hospital operations standard)
ALTER ACCOUNT SET TIMEZONE = 'America/Chicago';

-- Query execution limits: prevent runaway queries
ALTER ACCOUNT SET STATEMENT_TIMEOUT_IN_SECONDS = 3600;
ALTER ACCOUNT SET STATEMENT_QUEUED_TIMEOUT_IN_SECONDS = 1800;

-- Data retention defaults: 14-day account default, 7-day minimum
-- Note: Individual databases override this in Phase 04
-- RAW_DB: 90 days | TRANSFORM_DB: 30 days | ANALYTICS_DB: 30 days
-- AI_READY_DB: 14 days | GOVERNANCE_DB: inherits account default
ALTER ACCOUNT SET DATA_RETENTION_TIME_IN_DAYS = 14;
ALTER ACCOUNT SET MIN_DATA_RETENTION_TIME_IN_DAYS = 7;

-- Storage integration requirement: prevents ad-hoc external stage creation
-- All external stages must use a governed storage integration object
ALTER ACCOUNT SET REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION = TRUE;
ALTER ACCOUNT SET REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_OPERATION = TRUE;

-- Encryption: automatic periodic re-keying of all data at rest
-- HIPAA Reference: 45 CFR 164.312(a)(2)(iv) - Encryption and Decryption
ALTER ACCOUNT SET PERIODIC_DATA_REKEYING = TRUE;

-- OAuth security: blocks privileged roles from OAuth token escalation
ALTER ACCOUNT SET OAUTH_ADD_PRIVILEGED_ROLES_TO_BLOCKED_LIST = TRUE;
ALTER ACCOUNT SET EXTERNAL_OAUTH_ADD_PRIVILEGED_ROLES_TO_BLOCKED_LIST = TRUE;

-- Login: enables username-first login flow for MFA compatibility
ALTER ACCOUNT SET ENABLE_IDENTIFIER_FIRST_LOGIN = TRUE;

-- Verification
SHOW PARAMETERS LIKE 'TIMEZONE' IN ACCOUNT;
SHOW PARAMETERS LIKE 'STATEMENT_TIMEOUT%' IN ACCOUNT;
SHOW PARAMETERS LIKE 'DATA_RETENTION%' IN ACCOUNT;
SHOW PARAMETERS LIKE 'PERIODIC_DATA_REKEYING' IN ACCOUNT;
SHOW PARAMETERS LIKE 'REQUIRE_STORAGE_INTEGRATION%' IN ACCOUNT;

-- ============================================================
-- SECTION 6: PHASE 01 SUMMARY
-- ============================================================
--
-- BOOTSTRAP OBJECTS CREATED:
--   DATABASE : MEDICORE_GOVERNANCE_DB
--   SCHEMA   : MEDICORE_GOVERNANCE_DB.SECURITY
--
-- NOTE: Remaining MEDICORE_GOVERNANCE_DB schemas are created
--       in Phase 04 (POLICIES, TAGS, DATA_QUALITY, AUDIT).
--
-- SECURITY OBJECTS CREATED:
--   NETWORK RULE   : MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_ALLOWED_IPS
--   NETWORK POLICY : MEDICORE_NETWORK_POLICY (applied at account level)
--   PASSWORD POLICY: MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_PASSWORD_POLICY (applied)
--   SESSION POLICY : MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_SESSION_POLICY (applied)
--
-- ACCOUNT PARAMETERS CONFIGURED: 11
--   TIMEZONE                                    = America/Chicago
--   STATEMENT_TIMEOUT_IN_SECONDS                = 3600
--   STATEMENT_QUEUED_TIMEOUT_IN_SECONDS         = 1800
--   DATA_RETENTION_TIME_IN_DAYS                 = 14
--   MIN_DATA_RETENTION_TIME_IN_DAYS             = 7
--   REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION  = TRUE
--   REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_OPERATION = TRUE
--   PERIODIC_DATA_REKEYING                      = TRUE
--   OAUTH_ADD_PRIVILEGED_ROLES_TO_BLOCKED_LIST  = TRUE
--   EXTERNAL_OAUTH_ADD_PRIVILEGED_ROLES_TO_BLOCKED_LIST = TRUE
--   ENABLE_IDENTIFIER_FIRST_LOGIN               = TRUE
--
-- PHASE 02 DEPENDENCIES:
--   - MEDICORE_GOVERNANCE_DB exists for role grant references
--   - MEDICORE_GOVERNANCE_DB.SECURITY exists for policy references
--   - MEDICORE_PASSWORD_POLICY exists for service account setup
--   - Network policy applied — ensure CI/CD runner IPs are whitelisted
--     before executing Phase 02 and beyond
--
-- ============================================================
-- ROLLBACK COMMANDS (run only if needed before Phase 02)
-- ============================================================
-- ALTER ACCOUNT UNSET NETWORK_POLICY;
-- DROP NETWORK POLICY MEDICORE_NETWORK_POLICY;
--
-- ALTER ACCOUNT UNSET PASSWORD POLICY;
-- DROP PASSWORD POLICY MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_PASSWORD_POLICY;
--
-- ALTER ACCOUNT UNSET SESSION POLICY;
-- DROP SESSION POLICY MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_SESSION_POLICY;
--
-- DROP SCHEMA MEDICORE_GOVERNANCE_DB.SECURITY;
-- DROP DATABASE MEDICORE_GOVERNANCE_DB;
-- ============================================================
-- END OF PHASE 01: ACCOUNT ADMINISTRATION
-- ============================================================