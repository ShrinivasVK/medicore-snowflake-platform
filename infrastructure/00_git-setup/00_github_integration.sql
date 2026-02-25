-- ============================================================
-- MEDICORE HEALTH SYSTEMS - SNOWFLAKE DATA PLATFORM
-- ============================================================
-- Phase 00: GitHub Integration
-- Script: 00_github_integration.sql
-- Version: 2.0.0
--
-- Change Reason: Updated all references from GOVERNANCE_DB to
--               MEDICORE_GOVERNANCE_DB to align with refined
--               database naming convention established in
--               Phase 01 v2.0.0.
--
-- Description:
--   Configures GitHub integration for the MediCore Snowflake
--   platform repository. Creates a secret for GitHub PAT
--   authentication, an API integration for GitHub HTTPS access,
--   and a Git repository object pointing to the platform repo.
--
--   This script must be run AFTER Phase 01 because it depends
--   on MEDICORE_GOVERNANCE_DB.SECURITY existing as a bootstrap
--   object created in Phase 01.
--
-- Prerequisites:
--   - Phase 01 must be completed (MEDICORE_GOVERNANCE_DB and
--     MEDICORE_GOVERNANCE_DB.SECURITY must exist)
--   - Must be executed as ACCOUNTADMIN
--   - A valid GitHub Personal Access Token (PAT) must be
--     generated with repo scope before running this script
--   - Replace <<GITHUB_PAT_TOKEN_REPLACE_BEFORE_RUNNING>>
--     with your actual PAT before execution
--   - Replace YOUR_USERNAME with your actual GitHub username
--     in the ORIGIN URL
--
-- Execution Order:
--   Phase 01 → Phase 00 (this file) → Phase 02 → Phase 03
--            → Phase 04 → Phase 05
--
-- !! WARNING !!
--   Never commit this file to Git with a real PAT token in it.
--   Always replace the token value with the placeholder before
--   committing. Store real credentials in a secrets manager.
--
-- Author: [YOUR_NAME]
-- Date: [YYYY-MM-DD]
-- ============================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================
-- SECTION 1: GITHUB PAT SECRET
-- ============================================================
-- Stores the GitHub Personal Access Token as a Snowflake
-- secret object inside MEDICORE_GOVERNANCE_DB.SECURITY.
-- This schema was bootstrapped in Phase 01 specifically to
-- house account-level security and credential objects.
--
-- PAT Requirements:
--   - Scope: repo (full repository access)
--   - Expiry: set according to your org rotation policy
--   - Owner: the GitHub account that owns the repository
-- ============================================================

CREATE SECRET IF NOT EXISTS MEDICORE_GOVERNANCE_DB.SECURITY.GITHUB_TOKEN
    TYPE = PASSWORD
    USERNAME = 'ShrinivasVK'
    PASSWORD = '<<GITHUB_PAT_TOKEN>>'
    COMMENT = 'GitHub PAT for medicore-snowflake-platform repository integration. Stored in MEDICORE_GOVERNANCE_DB.SECURITY. Rotate every 90 days aligned with password policy. Never commit real token value to Git.';

-- Verification
SHOW SECRETS LIKE 'GITHUB_TOKEN' IN SCHEMA MEDICORE_GOVERNANCE_DB.SECURITY;

-- ============================================================
-- SECTION 2: API INTEGRATION
-- ============================================================
-- Creates the API integration that allows Snowflake to
-- communicate with GitHub HTTPS endpoints. Scoped to the
-- ShrinivasVK GitHub organisation prefix so only repos
-- under that account can be integrated.
-- ============================================================

CREATE OR REPLACE API INTEGRATION MEDICORE_GITHUB_INTEGRATION
    API_PROVIDER = GIT_HTTPS_API
    API_ALLOWED_PREFIXES = ('https://github.com/ShrinivasVK/')
    ALLOWED_AUTHENTICATION_SECRETS = (MEDICORE_GOVERNANCE_DB.SECURITY.GITHUB_TOKEN)
    ENABLED = TRUE
    COMMENT = 'GitHub API integration for MediCore Health Systems platform repository. Scoped to ShrinivasVK GitHub account. Authentication via PAT stored in MEDICORE_GOVERNANCE_DB.SECURITY.GITHUB_TOKEN.';

-- Verification
SHOW API INTEGRATIONS LIKE 'MEDICORE_GITHUB_INTEGRATION';

-- ============================================================
-- SECTION 3: GIT REPOSITORY OBJECT
-- ============================================================
-- Creates the Snowflake Git repository object that points to
-- the remote GitHub repository. This allows Snowflake to
-- fetch files directly from the repo for use in tasks,
-- procedures, and Cortex pipelines.
-- ============================================================

CREATE OR REPLACE GIT REPOSITORY MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_PLATFORM_REPO
    API_INTEGRATION = MEDICORE_GITHUB_INTEGRATION
    GIT_CREDENTIALS = MEDICORE_GOVERNANCE_DB.SECURITY.GITHUB_TOKEN
    ORIGIN = 'https://github.com/ShrinivasVK/medicore-snowflake-platform.git'
    COMMENT = 'MediCore Health Systems Snowflake platform repository. Contains all phase scripts, migration files, test cases, and documentation. Integrated via MEDICORE_GITHUB_INTEGRATION using PAT in MEDICORE_GOVERNANCE_DB.SECURITY.';

-- Verification
SHOW GIT REPOSITORIES LIKE 'MEDICORE_PLATFORM_REPO';

-- Fetch latest branches and tags from remote
ALTER GIT REPOSITORY MEDICORE_GOVERNANCE_DB.SECURITY.MEDICORE_PLATFORM_REPO FETCH;

-- ============================================================
-- SECTION 4: PHASE 00 SUMMARY
-- ============================================================
--
-- OBJECTS CREATED:
--   SECRET     : MEDICORE_GOVERNANCE_DB.SECURITY.GITHUB_TOKEN
--   INTEGRATION: MEDICORE_GITHUB_INTEGRATION
--   REPOSITORY : MEDICORE_PLATFORM_REPO
--
-- DEPENDENCIES:
--   - MEDICORE_GOVERNANCE_DB         (created in Phase 01)
--   - MEDICORE_GOVERNANCE_DB.SECURITY (created in Phase 01)
--
-- POST-EXECUTION STEPS:
--   1. Verify SHOW GIT REPOSITORIES returns MEDICORE_PLATFORM_REPO
--   2. Verify ALTER GIT REPOSITORY FETCH completes without error
--   3. Confirm repo branches are visible in Snowsight under
--      Data > Databases > MEDICORE_GOVERNANCE_DB > SECURITY
--   4. Rotate PAT token every 90 days and update secret:
--      ALTER SECRET MEDICORE_GOVERNANCE_DB.SECURITY.GITHUB_TOKEN
--          SET PASSWORD = '<<NEW_PAT_TOKEN>>';
--
-- !! REMINDER !!
--   Replace <<GITHUB_PAT_TOKEN_REPLACE_BEFORE_RUNNING>> with
--   your real PAT before executing. Reset to placeholder before
--   committing this file back to Git.
--
-- ============================================================
-- ROLLBACK COMMANDS (run only if needed)
-- ============================================================
-- DROP GIT REPOSITORY IF EXISTS MEDICORE_PLATFORM_REPO;
-- DROP API INTEGRATION IF EXISTS MEDICORE_GITHUB_INTEGRATION;
-- DROP SECRET IF EXISTS MEDICORE_GOVERNANCE_DB.SECURITY.GITHUB_TOKEN;
-- ============================================================
-- END OF PHASE 00: GITHUB INTEGRATION
-- ============================================================