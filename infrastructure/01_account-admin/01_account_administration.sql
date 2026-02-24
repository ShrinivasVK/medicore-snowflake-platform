-- ============================================================
-- MEDICORE HEALTH SYSTEMS - SNOWFLAKE DATA PLATFORM
-- ============================================================
-- Phase 1: Account Administration
-- Script: 01_account_administration.sql
--
-- Description:
--   Configures account-level security settings for a HIPAA-compliant
--   Business Critical Snowflake environment.
--
-- Scope: 8 tables across 3 domains (REFERENCE, CLINICAL, BILLING)
--
-- Prerequisites:
--   - Must be executed as ACCOUNTADMIN
--   - Snowflake Business Critical Edition
--   - Signed BAA with Snowflake
--
-- !! WARNING !!
--   This script configures ACCOUNT-LEVEL settings affecting ALL users.
--   Network policy misconfiguration can lock out all users.
--
-- Author: [YOUR_NAME]
-- Date: [YYYY-MM-DD]
-- ============================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================
-- SECTION 1: GOVERNANCE DATABASE
-- ============================================================

CREATE DATABASE IF NOT EXISTS GOVERNANCE_DB
    COMMENT = 'Central repository for governance objects: tags, policies, audit configurations';

CREATE SCHEMA IF NOT EXISTS GOVERNANCE_DB.SECURITY
    COMMENT = 'Security objects: network rules, password policies, session policies';

-- ============================================================
-- SECTION 2: NETWORK POLICY
-- ============================================================
-- HIPAA Reference: 45 CFR 164.312(a)(1) - Access Control
-- ============================================================

-- !! PLACEHOLDER IP - Replace before production !!
-- Production should include: corporate IPs, VPN endpoints, CI/CD runners
CREATE OR REPLACE NETWORK RULE GOVERNANCE_DB.SECURITY.MEDICORE_ALLOWED_IPS
    TYPE = IPV4
    VALUE_LIST = ('103.167.184.41/32')
    MODE = INGRESS
    COMMENT = 'PLACEHOLDER - Replace with production corporate IP ranges';

CREATE OR REPLACE NETWORK POLICY MEDICORE_NETWORK_POLICY
    ALLOWED_NETWORK_RULE_LIST = ('GOVERNANCE_DB.SECURITY.MEDICORE_ALLOWED_IPS')
    COMMENT = 'Primary network policy per HIPAA 164.312(a)(1) Access Control';

ALTER ACCOUNT SET NETWORK_POLICY = MEDICORE_NETWORK_POLICY;

-- Verification
SHOW NETWORK POLICIES LIKE 'MEDICORE%';

-- ============================================================
-- SECTION 3: PASSWORD POLICY
-- ============================================================
-- HIPAA Reference: 45 CFR 164.308(a)(5)(ii)(D) - Password Management
-- ============================================================

CREATE OR REPLACE PASSWORD POLICY GOVERNANCE_DB.SECURITY.MEDICORE_PASSWORD_POLICY
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
    COMMENT = 'HIPAA/HITRUST compliant: 14+ chars, 90-day expiry, 12-password history';

ALTER ACCOUNT SET PASSWORD POLICY GOVERNANCE_DB.SECURITY.MEDICORE_PASSWORD_POLICY;

-- Verification
DESCRIBE PASSWORD POLICY GOVERNANCE_DB.SECURITY.MEDICORE_PASSWORD_POLICY;

-- ============================================================
-- SECTION 4: SESSION POLICY
-- ============================================================
-- HIPAA Reference: 45 CFR 164.312(a)(2)(iii) - Automatic Logoff
-- ============================================================

CREATE OR REPLACE SESSION POLICY GOVERNANCE_DB.SECURITY.MEDICORE_SESSION_POLICY
    SESSION_IDLE_TIMEOUT_MINS = 240
    SESSION_UI_IDLE_TIMEOUT_MINS = 240
    COMMENT = '4-hour idle timeout per HIPAA 164.312(a)(2)(iii)';

ALTER ACCOUNT SET SESSION POLICY GOVERNANCE_DB.SECURITY.MEDICORE_SESSION_POLICY;

-- Verification
DESCRIBE SESSION POLICY GOVERNANCE_DB.SECURITY.MEDICORE_SESSION_POLICY;

-- ============================================================
-- SECTION 5: ACCOUNT PARAMETERS
-- ============================================================

ALTER ACCOUNT SET TIMEZONE = 'America/Chicago';
ALTER ACCOUNT SET STATEMENT_TIMEOUT_IN_SECONDS = 3600;
ALTER ACCOUNT SET STATEMENT_QUEUED_TIMEOUT_IN_SECONDS = 1800;
ALTER ACCOUNT SET DATA_RETENTION_TIME_IN_DAYS = 14;
ALTER ACCOUNT SET MIN_DATA_RETENTION_TIME_IN_DAYS = 7;
ALTER ACCOUNT SET REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION = TRUE;
ALTER ACCOUNT SET REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_OPERATION = TRUE;
ALTER ACCOUNT SET PERIODIC_DATA_REKEYING = TRUE;
ALTER ACCOUNT SET OAUTH_ADD_PRIVILEGED_ROLES_TO_BLOCKED_LIST = TRUE;
ALTER ACCOUNT SET EXTERNAL_OAUTH_ADD_PRIVILEGED_ROLES_TO_BLOCKED_LIST = TRUE;
ALTER ACCOUNT SET ENABLE_IDENTIFIER_FIRST_LOGIN = TRUE;

-- Verification
SHOW PARAMETERS LIKE 'TIMEZONE' IN ACCOUNT;
SHOW PARAMETERS LIKE 'STATEMENT_TIMEOUT%' IN ACCOUNT;
SHOW PARAMETERS LIKE 'PERIODIC_DATA_REKEYING' IN ACCOUNT;

-- ============================================================
-- PHASE 1 SUMMARY
-- ============================================================
-- Created:
--   DATABASE: GOVERNANCE_DB
--   SCHEMA: GOVERNANCE_DB.SECURITY
--   NETWORK RULE: GOVERNANCE_DB.SECURITY.MEDICORE_ALLOWED_IPS
--   NETWORK POLICY: MEDICORE_NETWORK_POLICY (applied)
--   PASSWORD POLICY: GOVERNANCE_DB.SECURITY.MEDICORE_PASSWORD_POLICY (applied)
--   SESSION POLICY: GOVERNANCE_DB.SECURITY.MEDICORE_SESSION_POLICY (applied)
--   11 Account parameters configured
-- ============================================================

-- -- To drop/replace policies, first unset them from the account:
-- ALTER ACCOUNT UNSET PASSWORD POLICY;
-- DROP PASSWORD POLICY GOVERNANCE_DB.SECURITY.MEDICORE_PASSWORD_POLICY;

-- ALTER ACCOUNT UNSET SESSION POLICY;
-- DROP SESSION POLICY GOVERNANCE_DB.SECURITY.MEDICORE_SESSION_POLICY;

-- ALTER ACCOUNT UNSET NETWORK_POLICY;
-- DROP NETWORK POLICY MEDICORE_NETWORK_POLICY;