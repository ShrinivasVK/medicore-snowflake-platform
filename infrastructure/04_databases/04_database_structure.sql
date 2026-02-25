-- ============================================================
-- MEDICORE HEALTH SYSTEMS - SNOWFLAKE DATA PLATFORM
-- ============================================================
-- Phase 04: Database Structure
-- Script: 04_database_structure.sql
-- Version: 2.0.0
--
-- Change Reason: Complete rewrite to implement schema-level
--               environment isolation (DEV/QA/PROD) for
--               CI/CD pipeline compatibility. All database
--               names updated to MEDICORE_ prefix. Flat
--               schema design replaced with environment-
--               prefixed schemas (PROD_CLINICAL, QA_CLINICAL,
--               DEV_CLINICAL, etc). OWNERSHIP grants removed
--               in favour of ACCOUNTADMIN ownership with
--               targeted CREATE grants for CI/CD role.
--               GOVERNANCE_DB Phase 04 schemas added
--               (POLICIES, TAGS, DATA_QUALITY, AUDIT).
--               MEDICORE_SVC_GITHUB_ACTIONS CREATE grants
--               added across all schemas. Role count
--               reference updated from 17 to 18.
--
-- Description:
--   Creates the 4-tier medallion database architecture for
--   MediCore Health Systems with schema-level environment
--   isolation. Implements MEDICORE_RAW_DB (Bronze),
--   MEDICORE_TRANSFORM_DB (Silver), MEDICORE_ANALYTICS_DB
--   (Gold), and MEDICORE_AI_READY_DB (Platinum) with
--   DEV/QA/PROD schemas per domain. Also completes
--   MEDICORE_GOVERNANCE_DB by adding Phase 04 schemas.
--
-- Environment Isolation Strategy:
--   Each data domain has three schemas, one per environment:
--     PROD_<DOMAIN> : Production data — live, governed, masking enforced
--     QA_<DOMAIN>   : Quality assurance — synthetic/anonymized test data
--     DEV_<DOMAIN>  : Development — sandbox, schema evolution experiments
--
--   This allows GitHub Actions (Schemachange) to deploy migrations
--   to DEV and QA schemas without touching PROD schemas, and
--   promotes changes through environments using the same codebase.
--
-- Execution Requirements:
--   - Must be run as ACCOUNTADMIN
--   - Execute statements sequentially from top to bottom
--   - Estimated execution time: 3-5 minutes
--
-- Dependencies:
--   - Phase 01 must be completed
--     (MEDICORE_GOVERNANCE_DB and SECURITY schema exist)
--   - Phase 02 Sections 1-5 must be completed
--     (all 18 MEDICORE roles exist)
--   - Phase 03 must be completed
--     (all 4 warehouses exist)
--   - After this script completes, return to Phase 02 and
--     execute Sections 6-12 (database/schema/future grants)
--
-- Execution Order:
--   Phase 01 → Phase 00 → Phase 02 (Sections 1-5) →
--   Phase 03 → Phase 04 → Phase 02 (Sections 6-12)
--
-- !! WARNING !!
--   Schema-level isolation means DEV and QA schemas will hold
--   synthetic or anonymised data only. Never load real PHI
--   into DEV or QA schemas. Production schemas (PROD_*)
--   are the only schemas that should ever contain real PHI.
--   Incorrect retention settings affect Time Travel and
--   Fail-safe costs.
--
-- Author: [YOUR_NAME]
-- Date: [YYYY-MM-DD]
-- ============================================================


-- ============================================================
-- SECTION 1: EXECUTION CONTEXT
-- ============================================================

USE ROLE ACCOUNTADMIN;


-- ============================================================
-- SECTION 2: COMPLETE MEDICORE_GOVERNANCE_DB SETUP
-- ============================================================
-- Phase 01 created MEDICORE_GOVERNANCE_DB with only the
-- SECURITY schema. Phase 04 adds the remaining 4 schemas:
-- POLICIES, TAGS, DATA_QUALITY, and AUDIT.
-- These schemas house governance objects built in Phase 08.
-- ============================================================

USE DATABASE MEDICORE_GOVERNANCE_DB;

CREATE SCHEMA IF NOT EXISTS POLICIES
    COMMENT = 'Data masking policies and row access policies for PHI protection. Created in Phase 04. Policies defined and applied in Phase 08 (Data Governance). Objects: masking policies for SSN, DOB, MRN, phone; row access policies for department-level clinical filtering. No PHI stored here - only policy definitions.';

CREATE SCHEMA IF NOT EXISTS TAGS
    COMMENT = 'Snowflake object tags for data classification and governance. Created in Phase 04. Tags defined and applied in Phase 08 (Data Governance). Tag taxonomy: DATA_SENSITIVITY (PHI/PII/CONFIDENTIAL/INTERNAL/PUBLIC), MEDALLION_LAYER (RAW/TRANSFORM/ANALYTICS/AI_READY), DATA_DOMAIN (CLINICAL/BILLING/REFERENCE/AUDIT), ENVIRONMENT (PROD/QA/DEV).';

CREATE SCHEMA IF NOT EXISTS DATA_QUALITY
    COMMENT = 'Data quality rules, expectation definitions, and quality metric results. Created in Phase 04. Populated in Phase 11 (Medallion Architecture). Objects: quality check definitions, threshold configurations, data quality score tables, anomaly detection results. No source data stored here - only quality metadata.';

CREATE SCHEMA IF NOT EXISTS AUDIT
    COMMENT = 'Governance audit logs tracking policy changes, tag applications, grant modifications, and access review records. Created in Phase 04. Populated starting Phase 08. Distinct from pipeline audit logs (in each databases PROD/QA/DEV_AUDIT schemas). Objects: policy_change_log, tag_application_log, access_review_records, grant_audit_trail.';

-- VERIFICATION: All 5 GOVERNANCE schemas exist
SHOW SCHEMAS IN DATABASE MEDICORE_GOVERNANCE_DB;


-- ============================================================
-- SECTION 3: MEDICORE_RAW_DB — BRONZE LAYER
-- ============================================================
-- Landing zone for source data exactly as received from
-- upstream systems (EPIC, CERNER, MEDITECH, CLAIMS_CLEARINGHOUSE).
-- No transformations applied. Dirty data, duplicates, and
-- inconsistent formats are intentionally retained.
--
-- Retention: 90 days for HIPAA audit trail compliance.
-- Environment schemas: PROD/QA/DEV per domain.
-- Domains: CLINICAL, BILLING, REFERENCE, AUDIT
-- Total schemas: 12 (4 domains × 3 environments)
-- ============================================================

CREATE DATABASE IF NOT EXISTS MEDICORE_RAW_DB
    DATA_RETENTION_TIME_IN_DAYS = 90
    COMMENT = 'Bronze Layer: Landing zone for source data exactly as received. No transformations applied. PHI present in CLINICAL and BILLING domains. 90-day Time Travel for HIPAA audit trail compliance. Schema-level environment isolation: PROD/QA/DEV per domain. DEV and QA schemas contain synthetic data only. Writers: MEDICORE_DATA_ENGINEER, MEDICORE_SVC_ETL_LOADER. CI/CD: MEDICORE_SVC_GITHUB_ACTIONS.';

ALTER DATABASE MEDICORE_RAW_DB SET DEFAULT_DDL_COLLATION = 'en-ci';

USE DATABASE MEDICORE_RAW_DB;

-- ------------------------------------------------------------
-- PROD SCHEMAS — Production raw data (real PHI, governed)
-- ------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS PROD_CLINICAL
    COMMENT = 'PRODUCTION: Raw clinical data from EPIC, CERNER, MEDITECH. Real PHI present. Objects: STG_PATIENTS, STG_ENCOUNTERS, STG_LAB_RESULTS, STG_PROVIDERS. Data loaded as-is — no transformations. HIPAA Treatment exception applies for access. Masking policies applied in Phase 08.';

CREATE SCHEMA IF NOT EXISTS PROD_BILLING
    COMMENT = 'PRODUCTION: Raw billing and claims data from CLAIMS_CLEARINGHOUSE. Financial identifiers present. Objects: STG_CLAIMS, STG_CLAIM_LINE_ITEMS. Data loaded as-is — no transformations.';

CREATE SCHEMA IF NOT EXISTS PROD_REFERENCE
    COMMENT = 'PRODUCTION: Raw reference and lookup data. No PHI. Objects: STG_DEPARTMENTS, STG_ICD10_CODES, STG_CPT_CODES, STG_FACILITIES. Code sets and dimension tables loaded as-is from source systems.';

CREATE TRANSIENT SCHEMA IF NOT EXISTS PROD_AUDIT
    COMMENT = 'PRODUCTION: Pipeline audit logs and ETL metadata. Transient — no Time Travel or Fail-safe (high-volume continuous writes, individual records not recoverable). Objects: pipeline_run_log, row_count_audit, error_log, load_metadata. Writers: DATA_ENGINEER, SVC_ETL_LOADER.';

-- ------------------------------------------------------------
-- QA SCHEMAS — Quality assurance (synthetic/anonymised data)
-- ------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS QA_CLINICAL
    COMMENT = 'QA: Synthetic clinical data for pipeline testing and validation. No real PHI. Mirrors PROD_CLINICAL structure. Used by Schemachange for migration testing and data pipeline QA validation before PROD promotion.';

CREATE SCHEMA IF NOT EXISTS QA_BILLING
    COMMENT = 'QA: Synthetic billing data for pipeline testing and validation. No real financial identifiers. Mirrors PROD_BILLING structure. Used by Schemachange for migration testing before PROD promotion.';

CREATE SCHEMA IF NOT EXISTS QA_REFERENCE
    COMMENT = 'QA: Reference data copy for QA environment testing. May use real reference data (no PHI in reference). Mirrors PROD_REFERENCE structure. Used by Schemachange for migration testing before PROD promotion.';

CREATE TRANSIENT SCHEMA IF NOT EXISTS QA_AUDIT
    COMMENT = 'QA: Pipeline audit logs for QA environment runs. Transient schema. Mirrors PROD_AUDIT structure. Used to validate audit logging behaviour before PROD promotion.';

-- ------------------------------------------------------------
-- DEV SCHEMAS — Development (sandbox, schema evolution)
-- ------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS DEV_CLINICAL
    COMMENT = 'DEV: Development sandbox for clinical schema evolution and pipeline prototyping. No real PHI — synthetic data only. Engineers and Schemachange deploy new migrations here first before promoting to QA and PROD.';

CREATE SCHEMA IF NOT EXISTS DEV_BILLING
    COMMENT = 'DEV: Development sandbox for billing schema evolution and pipeline prototyping. No real financial identifiers — synthetic data only. Engineers and Schemachange deploy new migrations here first before promoting to QA and PROD.';

CREATE SCHEMA IF NOT EXISTS DEV_REFERENCE
    COMMENT = 'DEV: Development sandbox for reference data schema evolution. May use real reference data (no PHI). Engineers and Schemachange deploy new migrations here first before promoting to QA and PROD.';

CREATE TRANSIENT SCHEMA IF NOT EXISTS DEV_AUDIT
    COMMENT = 'DEV: Pipeline audit logs for DEV environment runs. Transient schema. Engineers use this to validate audit logging during development before promoting to QA and PROD.';

-- VERIFICATION: All 12 MEDICORE_RAW_DB schemas created
SHOW SCHEMAS IN DATABASE MEDICORE_RAW_DB;


-- ============================================================
-- SECTION 4: MEDICORE_TRANSFORM_DB — SILVER LAYER
-- ============================================================
-- Cleansed, conformed, validated, and deduplicated data with
-- business rules applied. PHI still present in CLINICAL and
-- BILLING domains. Source of truth for all downstream layers.
--
-- Retention: 30 days (operational recovery window).
-- Environment schemas: PROD/QA/DEV per domain.
-- Domains: CLINICAL, BILLING, REFERENCE, AUDIT, COMMON
-- Total schemas: 15 (5 domains × 3 environments)
-- ============================================================

CREATE DATABASE IF NOT EXISTS MEDICORE_TRANSFORM_DB
    DATA_RETENTION_TIME_IN_DAYS = 30
    COMMENT = 'Silver Layer: Cleansed, conformed, and deduplicated data with business rules applied. PHI present in CLINICAL and BILLING domains. 30-day Time Travel for operational recovery. Schema-level environment isolation: PROD/QA/DEV per domain. DEV and QA schemas contain synthetic data only. Writers: MEDICORE_DATA_ENGINEER. CI/CD: MEDICORE_SVC_GITHUB_ACTIONS.';

ALTER DATABASE MEDICORE_TRANSFORM_DB SET DEFAULT_DDL_COLLATION = 'en-ci';

USE DATABASE MEDICORE_TRANSFORM_DB;

-- ------------------------------------------------------------
-- PROD SCHEMAS
-- ------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS PROD_CLINICAL
    COMMENT = 'PRODUCTION: Cleansed clinical entities with validated formats and enforced referential integrity. Derived from MEDICORE_RAW_DB.PROD_CLINICAL. Real PHI present. Business rules applied. Objects: DIM_PATIENTS, FACT_ENCOUNTERS, FACT_LAB_RESULTS, DIM_PROVIDERS.';

CREATE SCHEMA IF NOT EXISTS PROD_BILLING
    COMMENT = 'PRODUCTION: Cleansed billing entities with validated formats and enforced referential integrity. Derived from MEDICORE_RAW_DB.PROD_BILLING. Financial identifiers present. Objects: FACT_CLAIMS, DIM_CLAIM_LINE_ITEMS, DIM_PAYERS.';

CREATE SCHEMA IF NOT EXISTS PROD_REFERENCE
    COMMENT = 'PRODUCTION: Validated reference data with enforced constraints. Derived from MEDICORE_RAW_DB.PROD_REFERENCE. No PHI. Objects: DIM_DEPARTMENTS, DIM_ICD10_CODES, DIM_CPT_CODES, DIM_FACILITIES, DIM_DATE.';

CREATE TRANSIENT SCHEMA IF NOT EXISTS PROD_AUDIT
    COMMENT = 'PRODUCTION: Transformation pipeline audit logs and lineage metadata. Transient schema. Objects: transformation_run_log, data_quality_results, lineage_metadata, row_count_comparison.';

CREATE SCHEMA IF NOT EXISTS PROD_COMMON
    COMMENT = 'PRODUCTION: Cross-domain shared objects, utility functions, and date spine. No PHI. Objects: DATE_SPINE, FISCAL_CALENDAR, utility UDFs, shared lookup mappings used across CLINICAL and BILLING domains.';

-- ------------------------------------------------------------
-- QA SCHEMAS
-- ------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS QA_CLINICAL
    COMMENT = 'QA: Synthetic cleansed clinical data for transformation testing. No real PHI. Mirrors PROD_CLINICAL structure. Used by Schemachange for migration testing before PROD promotion.';

CREATE SCHEMA IF NOT EXISTS QA_BILLING
    COMMENT = 'QA: Synthetic cleansed billing data for transformation testing. No real financial identifiers. Mirrors PROD_BILLING structure. Used by Schemachange for migration testing before PROD promotion.';

CREATE SCHEMA IF NOT EXISTS QA_REFERENCE
    COMMENT = 'QA: Reference data for QA environment. Mirrors PROD_REFERENCE structure. Used by Schemachange for migration testing before PROD promotion.';

CREATE TRANSIENT SCHEMA IF NOT EXISTS QA_AUDIT
    COMMENT = 'QA: Transformation audit logs for QA environment. Transient schema. Mirrors PROD_AUDIT structure.';

CREATE SCHEMA IF NOT EXISTS QA_COMMON
    COMMENT = 'QA: Cross-domain shared objects for QA environment testing. Mirrors PROD_COMMON structure. Used by Schemachange for migration testing before PROD promotion.';

-- ------------------------------------------------------------
-- DEV SCHEMAS
-- ------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS DEV_CLINICAL
    COMMENT = 'DEV: Development sandbox for cleansed clinical schema evolution. Synthetic data only. Engineers and Schemachange deploy new transformation migrations here first.';

CREATE SCHEMA IF NOT EXISTS DEV_BILLING
    COMMENT = 'DEV: Development sandbox for cleansed billing schema evolution. Synthetic data only. Engineers and Schemachange deploy new transformation migrations here first.';

CREATE SCHEMA IF NOT EXISTS DEV_REFERENCE
    COMMENT = 'DEV: Development sandbox for reference data schema evolution. Engineers and Schemachange deploy new migrations here first.';

CREATE TRANSIENT SCHEMA IF NOT EXISTS DEV_AUDIT
    COMMENT = 'DEV: Transformation audit logs for DEV environment. Transient schema. Engineers use this to validate audit logging during development.';

CREATE SCHEMA IF NOT EXISTS DEV_COMMON
    COMMENT = 'DEV: Development sandbox for cross-domain shared objects. Engineers develop and test new utility functions and date spine variations here first.';

-- VERIFICATION: All 15 MEDICORE_TRANSFORM_DB schemas created
SHOW SCHEMAS IN DATABASE MEDICORE_TRANSFORM_DB;


-- ============================================================
-- SECTION 5: MEDICORE_ANALYTICS_DB — GOLD LAYER
-- ============================================================
-- Business-ready aggregated and dimensional models powering
-- dashboards, reports, and clinical analytics. Masking and
-- row access policies enforced (Phase 08). Dynamic Tables
-- populate this layer from TRANSFORM_DB (Phase 11).
--
-- Retention: 30 days (operational recovery window).
-- Environment schemas: PROD/QA/DEV per domain.
-- Domains: CLINICAL, BILLING, REFERENCE, EXECUTIVE, DEIDENTIFIED
-- Total schemas: 15 (5 domains × 3 environments)
-- ============================================================

CREATE DATABASE IF NOT EXISTS MEDICORE_ANALYTICS_DB
    DATA_RETENTION_TIME_IN_DAYS = 30
    COMMENT = 'Gold Layer: Business-ready aggregated and dimensional models. Masking policies and row access policies enforced (Phase 08). Dynamic Tables populate schemas from MEDICORE_TRANSFORM_DB (Phase 11). 30-day Time Travel for operational recovery. Schema-level environment isolation: PROD/QA/DEV per domain. PROD schemas contain real data with masking enforced. DEV and QA contain synthetic data.';

ALTER DATABASE MEDICORE_ANALYTICS_DB SET DEFAULT_DDL_COLLATION = 'en-ci';

USE DATABASE MEDICORE_ANALYTICS_DB;

-- ------------------------------------------------------------
-- PROD SCHEMAS
-- ------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS PROD_CLINICAL
    COMMENT = 'PRODUCTION: Dimensional models and Dynamic Tables for patient care analytics. Real PHI present — masking policies enforced in Phase 08. Dynamic Tables sourced from MEDICORE_TRANSFORM_DB.PROD_CLINICAL (Phase 11). Readers: CLINICAL_PHYSICIAN, CLINICAL_NURSE, CLINICAL_READER, ANALYST_PHI, COMPLIANCE_OFFICER, DATA_SCIENTIST, APP_STREAMLIT.';

CREATE SCHEMA IF NOT EXISTS PROD_BILLING
    COMMENT = 'PRODUCTION: Revenue cycle analytics and billing dimensional models. Financial identifiers present — masking policies enforced in Phase 08. Dynamic Tables sourced from MEDICORE_TRANSFORM_DB.PROD_BILLING (Phase 11). Readers: BILLING_SPECIALIST, BILLING_READER, ANALYST_PHI, COMPLIANCE_OFFICER, DATA_SCIENTIST, APP_STREAMLIT.';

CREATE SCHEMA IF NOT EXISTS PROD_REFERENCE
    COMMENT = 'PRODUCTION: Governed reference data for all downstream consumers. ICD-10 codes, CPT codes, department master, facility master. No PHI. Available to all roles via REFERENCE_READER inheritance.';

CREATE SCHEMA IF NOT EXISTS PROD_EXECUTIVE
    COMMENT = 'PRODUCTION: Aggregated KPI views and executive dashboards. NO PHI — aggregated metrics and counts only. Safe for EXECUTIVE role and ANALYST_RESTRICTED. Dynamic Tables sourced from MEDICORE_TRANSFORM_DB.PROD_CLINICAL and PROD_BILLING (Phase 11). Readers: EXECUTIVE, ANALYST_RESTRICTED, ANALYST_PHI, COMPLIANCE_OFFICER, APP_STREAMLIT.';

CREATE SCHEMA IF NOT EXISTS PROD_DEIDENTIFIED
    COMMENT = 'PRODUCTION: Safe Harbor de-identified datasets. All 18 HIPAA identifiers removed or generalised. Safe for MEDICORE_EXT_AUDITOR and MEDICORE_ANALYST_RESTRICTED. Suitable for external sharing and research. Readers: EXT_AUDITOR, ANALYST_RESTRICTED, ANALYST_PHI, COMPLIANCE_OFFICER, DATA_SCIENTIST.';

-- ------------------------------------------------------------
-- QA SCHEMAS
-- ------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS QA_CLINICAL
    COMMENT = 'QA: Synthetic clinical analytics objects for pipeline and query testing. No real PHI. Mirrors PROD_CLINICAL structure. Used by Schemachange for migration testing before PROD promotion.';

CREATE SCHEMA IF NOT EXISTS QA_BILLING
    COMMENT = 'QA: Synthetic billing analytics objects for pipeline and query testing. No real financial identifiers. Mirrors PROD_BILLING structure. Used by Schemachange for migration testing before PROD promotion.';

CREATE SCHEMA IF NOT EXISTS QA_REFERENCE
    COMMENT = 'QA: Reference data for QA analytics environment. Mirrors PROD_REFERENCE structure. Used by Schemachange for migration testing before PROD promotion.';

CREATE SCHEMA IF NOT EXISTS QA_EXECUTIVE
    COMMENT = 'QA: Synthetic executive KPI objects for dashboard testing. No PHI. Mirrors PROD_EXECUTIVE structure. Used by Schemachange for migration testing before PROD promotion.';

CREATE SCHEMA IF NOT EXISTS QA_DEIDENTIFIED
    COMMENT = 'QA: Synthetic de-identified datasets for external sharing pipeline testing. Mirrors PROD_DEIDENTIFIED structure. Used by Schemachange for migration testing before PROD promotion.';

-- ------------------------------------------------------------
-- DEV SCHEMAS
-- ------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS DEV_CLINICAL
    COMMENT = 'DEV: Development sandbox for clinical analytics schema evolution. Synthetic data only. Engineers and Schemachange deploy new analytics migrations here first.';

CREATE SCHEMA IF NOT EXISTS DEV_BILLING
    COMMENT = 'DEV: Development sandbox for billing analytics schema evolution. Synthetic data only. Engineers and Schemachange deploy new analytics migrations here first.';

CREATE SCHEMA IF NOT EXISTS DEV_REFERENCE
    COMMENT = 'DEV: Development sandbox for reference analytics schema evolution. Engineers and Schemachange deploy new migrations here first.';

CREATE SCHEMA IF NOT EXISTS DEV_EXECUTIVE
    COMMENT = 'DEV: Development sandbox for executive KPI and dashboard schema evolution. No PHI. Engineers and Schemachange deploy new migrations here first.';

CREATE SCHEMA IF NOT EXISTS DEV_DEIDENTIFIED
    COMMENT = 'DEV: Development sandbox for de-identification pipeline testing. Synthetic data only. Engineers and Schemachange deploy new migrations here first.';

-- VERIFICATION: All 15 MEDICORE_ANALYTICS_DB schemas created
SHOW SCHEMAS IN DATABASE MEDICORE_ANALYTICS_DB;


-- ============================================================
-- SECTION 6: MEDICORE_AI_READY_DB — PLATINUM LAYER
-- ============================================================
-- Feature store and ML-optimised datasets for model training
-- and inference. Embeddings and semantic models for Cortex
-- Analyst and Cortex Vector Search.
--
-- Retention: 14 days (ML iterations are frequent; lower
-- retention is acceptable and reduces cost).
-- Environment schemas: PROD/QA/DEV per domain.
-- Domains: FEATURES, TRAINING, SEMANTIC, EMBEDDINGS
-- Total schemas: 12 (4 domains × 3 environments)
-- ============================================================

CREATE DATABASE IF NOT EXISTS MEDICORE_AI_READY_DB
    DATA_RETENTION_TIME_IN_DAYS = 14
    COMMENT = 'Platinum Layer: Feature store and ML-optimised datasets for model training and inference. Embeddings for Cortex Vector Search, semantic models for Cortex Analyst. 14-day Time Travel (ML iterations are frequent, lower retention acceptable). Schema-level environment isolation: PROD/QA/DEV per domain. DEV and QA schemas contain synthetic feature data only.';

ALTER DATABASE MEDICORE_AI_READY_DB SET DEFAULT_DDL_COLLATION = 'en-ci';

USE DATABASE MEDICORE_AI_READY_DB;

-- ------------------------------------------------------------
-- PROD SCHEMAS
-- ------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS PROD_FEATURES
    COMMENT = 'PRODUCTION: Patient and encounter feature store for ML model inputs. Pre-computed features, normalised values, one-hot encodings. PHI may be present in raw features. Writers: DATA_SCIENTIST, DATA_ENGINEER. Readers: DATA_SCIENTIST, ANALYST_PHI, COMPLIANCE_OFFICER.';

CREATE SCHEMA IF NOT EXISTS PROD_TRAINING
    COMMENT = 'PRODUCTION: Curated ML training datasets with labels and stratified samples. Versioned datasets for model reproducibility. PHI may be present. Writers: DATA_SCIENTIST, DATA_ENGINEER. Readers: DATA_SCIENTIST, ANALYST_PHI, COMPLIANCE_OFFICER.';

CREATE SCHEMA IF NOT EXISTS PROD_SEMANTIC
    COMMENT = 'PRODUCTION: Semantic models for Cortex Analyst natural language queries. YAML definitions, verified queries, and semantic layer metadata. No direct PHI — references governed views in MEDICORE_ANALYTICS_DB. Writers: DATA_SCIENTIST, DATA_ENGINEER. Readers: DATA_SCIENTIST, COMPLIANCE_OFFICER.';

CREATE SCHEMA IF NOT EXISTS PROD_EMBEDDINGS
    COMMENT = 'PRODUCTION: Vector embeddings for clinical NLP and similarity search. Clinical note embeddings, diagnosis embeddings, procedure embeddings. Used with Cortex Vector Search. PHI may be encoded in embeddings. Writers: DATA_SCIENTIST, DATA_ENGINEER. Readers: DATA_SCIENTIST, ANALYST_PHI, COMPLIANCE_OFFICER.';

-- ------------------------------------------------------------
-- QA SCHEMAS
-- ------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS QA_FEATURES
    COMMENT = 'QA: Synthetic feature data for ML pipeline testing. No real PHI. Mirrors PROD_FEATURES structure. Used by Schemachange for migration testing before PROD promotion.';

CREATE SCHEMA IF NOT EXISTS QA_TRAINING
    COMMENT = 'QA: Synthetic training datasets for ML pipeline testing. No real PHI. Mirrors PROD_TRAINING structure. Used by Schemachange for migration testing before PROD promotion.';

CREATE SCHEMA IF NOT EXISTS QA_SEMANTIC
    COMMENT = 'QA: Semantic model definitions for QA testing. Mirrors PROD_SEMANTIC structure. Used to validate Cortex Analyst semantic layer before PROD promotion.';

CREATE SCHEMA IF NOT EXISTS QA_EMBEDDINGS
    COMMENT = 'QA: Synthetic embeddings for vector search pipeline testing. No real PHI encoded. Mirrors PROD_EMBEDDINGS structure. Used by Schemachange for migration testing before PROD promotion.';

-- ------------------------------------------------------------
-- DEV SCHEMAS
-- ------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS DEV_FEATURES
    COMMENT = 'DEV: Development sandbox for feature engineering schema evolution. Synthetic feature data only. Engineers and data scientists experiment with new feature definitions here first.';

CREATE SCHEMA IF NOT EXISTS DEV_TRAINING
    COMMENT = 'DEV: Development sandbox for training dataset schema evolution. Synthetic data only. Data scientists prototype new training dataset structures here first.';

CREATE SCHEMA IF NOT EXISTS DEV_SEMANTIC
    COMMENT = 'DEV: Development sandbox for semantic model prototyping. Data scientists and engineers develop new Cortex Analyst semantic definitions here before promoting to QA and PROD.';

CREATE SCHEMA IF NOT EXISTS DEV_EMBEDDINGS
    COMMENT = 'DEV: Development sandbox for embedding pipeline schema evolution. Synthetic embeddings only. Data scientists prototype new embedding strategies here first.';

-- VERIFICATION: All 12 MEDICORE_AI_READY_DB schemas created
SHOW SCHEMAS IN DATABASE MEDICORE_AI_READY_DB;


-- ============================================================
-- SECTION 7: ROLE-SPECIFIC DATABASE AND SCHEMA GRANTS
-- ============================================================
-- Grants are structured around the principle of least privilege.
-- ACCOUNTADMIN retains ownership of all schemas — this is
-- intentional for a CI/CD environment where Schemachange runs
-- as SVC_GITHUB_ACTIONS and needs CREATE but not OWNERSHIP.
--
-- IMPORTANT: Phase 02 Sections 6-12 must be re-run after
-- this section completes. Those sections contain the complete
-- and authoritative grant matrix for all 18 roles across
-- all databases and schemas. What follows here provides the
-- minimum grants needed to unblock Phase 05 execution.
-- ============================================================

USE ROLE ACCOUNTADMIN;

-- ------------------------------------------------------------
-- MEDICORE_GOVERNANCE_DB — New schema grants
-- (SECURITY schema grants were set in Phase 01)
-- ------------------------------------------------------------

GRANT USAGE ON SCHEMA MEDICORE_GOVERNANCE_DB.POLICIES    TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT USAGE ON SCHEMA MEDICORE_GOVERNANCE_DB.POLICIES    TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT USAGE ON SCHEMA MEDICORE_GOVERNANCE_DB.POLICIES    TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_GOVERNANCE_DB.POLICIES    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;

GRANT USAGE ON SCHEMA MEDICORE_GOVERNANCE_DB.TAGS        TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT USAGE ON SCHEMA MEDICORE_GOVERNANCE_DB.TAGS        TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT USAGE ON SCHEMA MEDICORE_GOVERNANCE_DB.TAGS        TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_GOVERNANCE_DB.TAGS        TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;

GRANT USAGE ON SCHEMA MEDICORE_GOVERNANCE_DB.DATA_QUALITY TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT USAGE ON SCHEMA MEDICORE_GOVERNANCE_DB.DATA_QUALITY TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT USAGE ON SCHEMA MEDICORE_GOVERNANCE_DB.DATA_QUALITY TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_GOVERNANCE_DB.DATA_QUALITY TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;

GRANT USAGE ON SCHEMA MEDICORE_GOVERNANCE_DB.AUDIT       TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT USAGE ON SCHEMA MEDICORE_GOVERNANCE_DB.AUDIT       TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT USAGE ON SCHEMA MEDICORE_GOVERNANCE_DB.AUDIT       TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_GOVERNANCE_DB.AUDIT       TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;

-- CREATE privileges on governance schemas for engineering and CI/CD
GRANT CREATE TABLE, CREATE VIEW
    ON SCHEMA MEDICORE_GOVERNANCE_DB.DATA_QUALITY
    TO ROLE MEDICORE_DATA_ENGINEER;

GRANT CREATE TABLE, CREATE VIEW
    ON SCHEMA MEDICORE_GOVERNANCE_DB.DATA_QUALITY
    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;

GRANT CREATE TABLE, CREATE VIEW
    ON SCHEMA MEDICORE_GOVERNANCE_DB.AUDIT
    TO ROLE MEDICORE_DATA_ENGINEER;

GRANT CREATE TABLE, CREATE VIEW
    ON SCHEMA MEDICORE_GOVERNANCE_DB.AUDIT
    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;

-- CREATE MASKING POLICY and CREATE ROW ACCESS POLICY for
-- COMPLIANCE_OFFICER on POLICIES schema (used in Phase 08)
GRANT CREATE MASKING POLICY
    ON SCHEMA MEDICORE_GOVERNANCE_DB.POLICIES
    TO ROLE MEDICORE_COMPLIANCE_OFFICER;

GRANT CREATE ROW ACCESS POLICY
    ON SCHEMA MEDICORE_GOVERNANCE_DB.POLICIES
    TO ROLE MEDICORE_COMPLIANCE_OFFICER;

-- CREATE TAG for COMPLIANCE_OFFICER on TAGS schema (used in Phase 08)
GRANT CREATE TAG
    ON SCHEMA MEDICORE_GOVERNANCE_DB.TAGS
    TO ROLE MEDICORE_COMPLIANCE_OFFICER;

-- ------------------------------------------------------------
-- MEDICORE_RAW_DB — Engineering and CI/CD grants
-- (Full role matrix added in Phase 02 Sections 6-12)
-- ------------------------------------------------------------

-- Database-level access for engineering and CI/CD roles
GRANT USAGE ON DATABASE MEDICORE_RAW_DB TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON DATABASE MEDICORE_RAW_DB TO ROLE MEDICORE_SVC_ETL_LOADER;
GRANT USAGE ON DATABASE MEDICORE_RAW_DB TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT USAGE ON DATABASE MEDICORE_RAW_DB TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT USAGE ON DATABASE MEDICORE_RAW_DB TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;

-- PROD schema access for DATA_ENGINEER and SVC_ETL_LOADER
GRANT USAGE ON SCHEMA MEDICORE_RAW_DB.PROD_CLINICAL   TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_RAW_DB.PROD_BILLING    TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_RAW_DB.PROD_REFERENCE  TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_RAW_DB.PROD_AUDIT      TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_RAW_DB.PROD_CLINICAL   TO ROLE MEDICORE_SVC_ETL_LOADER;
GRANT USAGE ON SCHEMA MEDICORE_RAW_DB.PROD_BILLING    TO ROLE MEDICORE_SVC_ETL_LOADER;
GRANT USAGE ON SCHEMA MEDICORE_RAW_DB.PROD_REFERENCE  TO ROLE MEDICORE_SVC_ETL_LOADER;
GRANT USAGE ON SCHEMA MEDICORE_RAW_DB.PROD_AUDIT      TO ROLE MEDICORE_SVC_ETL_LOADER;

-- All schemas access for SVC_GITHUB_ACTIONS (CI/CD deploys to all environments)
GRANT USAGE ON SCHEMA MEDICORE_RAW_DB.PROD_CLINICAL   TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_RAW_DB.PROD_BILLING    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_RAW_DB.PROD_REFERENCE  TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_RAW_DB.PROD_AUDIT      TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_RAW_DB.QA_CLINICAL     TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_RAW_DB.QA_BILLING      TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_RAW_DB.QA_REFERENCE    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_RAW_DB.QA_AUDIT        TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_RAW_DB.DEV_CLINICAL    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_RAW_DB.DEV_BILLING     TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_RAW_DB.DEV_REFERENCE   TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_RAW_DB.DEV_AUDIT       TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;

-- CREATE privileges for DATA_ENGINEER and SVC_GITHUB_ACTIONS
GRANT CREATE TABLE, CREATE VIEW
    ON SCHEMA MEDICORE_RAW_DB.PROD_CLINICAL  TO ROLE MEDICORE_DATA_ENGINEER;
GRANT CREATE TABLE, CREATE VIEW
    ON SCHEMA MEDICORE_RAW_DB.PROD_BILLING   TO ROLE MEDICORE_DATA_ENGINEER;
GRANT CREATE TABLE, CREATE VIEW
    ON SCHEMA MEDICORE_RAW_DB.PROD_REFERENCE TO ROLE MEDICORE_DATA_ENGINEER;
GRANT CREATE TABLE, CREATE VIEW
    ON SCHEMA MEDICORE_RAW_DB.PROD_AUDIT     TO ROLE MEDICORE_DATA_ENGINEER;

GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_RAW_DB.PROD_CLINICAL   TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_RAW_DB.PROD_BILLING    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_RAW_DB.PROD_REFERENCE  TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_RAW_DB.PROD_AUDIT      TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_RAW_DB.QA_CLINICAL     TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_RAW_DB.QA_BILLING      TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_RAW_DB.QA_REFERENCE    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_RAW_DB.QA_AUDIT        TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_RAW_DB.DEV_CLINICAL    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_RAW_DB.DEV_BILLING     TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_RAW_DB.DEV_REFERENCE   TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_RAW_DB.DEV_AUDIT       TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;

-- Future grants for SVC_ETL_LOADER (INSERT/UPDATE on production tables)
GRANT INSERT, UPDATE ON FUTURE TABLES IN SCHEMA MEDICORE_RAW_DB.PROD_CLINICAL  TO ROLE MEDICORE_SVC_ETL_LOADER;
GRANT INSERT, UPDATE ON FUTURE TABLES IN SCHEMA MEDICORE_RAW_DB.PROD_BILLING   TO ROLE MEDICORE_SVC_ETL_LOADER;
GRANT INSERT, UPDATE ON FUTURE TABLES IN SCHEMA MEDICORE_RAW_DB.PROD_REFERENCE TO ROLE MEDICORE_SVC_ETL_LOADER;
GRANT INSERT, UPDATE ON FUTURE TABLES IN SCHEMA MEDICORE_RAW_DB.PROD_AUDIT     TO ROLE MEDICORE_SVC_ETL_LOADER;

-- Future grants for COMPLIANCE_OFFICER (SELECT on all production schemas)
GRANT SELECT ON FUTURE TABLES IN SCHEMA MEDICORE_RAW_DB.PROD_CLINICAL  TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT SELECT ON FUTURE TABLES IN SCHEMA MEDICORE_RAW_DB.PROD_BILLING   TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT SELECT ON FUTURE TABLES IN SCHEMA MEDICORE_RAW_DB.PROD_REFERENCE TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT SELECT ON FUTURE TABLES IN SCHEMA MEDICORE_RAW_DB.PROD_AUDIT     TO ROLE MEDICORE_COMPLIANCE_OFFICER;

-- ------------------------------------------------------------
-- MEDICORE_TRANSFORM_DB — Engineering and CI/CD grants
-- ------------------------------------------------------------

GRANT USAGE ON DATABASE MEDICORE_TRANSFORM_DB TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON DATABASE MEDICORE_TRANSFORM_DB TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT USAGE ON DATABASE MEDICORE_TRANSFORM_DB TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT USAGE ON DATABASE MEDICORE_TRANSFORM_DB TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT USAGE ON DATABASE MEDICORE_TRANSFORM_DB TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;

-- PROD schema access
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_CLINICAL  TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_BILLING   TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_REFERENCE TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_AUDIT     TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_COMMON    TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_CLINICAL  TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_BILLING   TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_REFERENCE TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_COMMON    TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_CLINICAL  TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_BILLING   TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_REFERENCE TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_AUDIT     TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_COMMON    TO ROLE MEDICORE_COMPLIANCE_OFFICER;

-- All schemas access for SVC_GITHUB_ACTIONS
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_CLINICAL  TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_BILLING   TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_REFERENCE TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_AUDIT     TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_COMMON    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.QA_CLINICAL    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.QA_BILLING     TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.QA_REFERENCE   TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.QA_AUDIT       TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.QA_COMMON      TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.DEV_CLINICAL   TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.DEV_BILLING    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.DEV_REFERENCE  TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.DEV_AUDIT      TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_TRANSFORM_DB.DEV_COMMON     TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;

-- CREATE privileges for DATA_ENGINEER
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE
    ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_CLINICAL  TO ROLE MEDICORE_DATA_ENGINEER;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE
    ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_BILLING   TO ROLE MEDICORE_DATA_ENGINEER;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE
    ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_REFERENCE TO ROLE MEDICORE_DATA_ENGINEER;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE
    ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_AUDIT     TO ROLE MEDICORE_DATA_ENGINEER;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE
    ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_COMMON    TO ROLE MEDICORE_DATA_ENGINEER;

-- CREATE privileges for SVC_GITHUB_ACTIONS across all environments
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_CLINICAL  TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_BILLING   TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_REFERENCE TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_AUDIT     TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_TRANSFORM_DB.PROD_COMMON    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_TRANSFORM_DB.QA_CLINICAL    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_TRANSFORM_DB.QA_BILLING     TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_TRANSFORM_DB.QA_REFERENCE   TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_TRANSFORM_DB.QA_AUDIT       TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_TRANSFORM_DB.QA_COMMON      TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_TRANSFORM_DB.DEV_CLINICAL   TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_TRANSFORM_DB.DEV_BILLING    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_TRANSFORM_DB.DEV_REFERENCE  TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_TRANSFORM_DB.DEV_AUDIT      TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_TRANSFORM_DB.DEV_COMMON     TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;

-- Future grants for DATA_SCIENTIST (SELECT on all PROD transform schemas)
GRANT SELECT ON FUTURE TABLES IN SCHEMA MEDICORE_TRANSFORM_DB.PROD_CLINICAL  TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT SELECT ON FUTURE TABLES IN SCHEMA MEDICORE_TRANSFORM_DB.PROD_BILLING   TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT SELECT ON FUTURE TABLES IN SCHEMA MEDICORE_TRANSFORM_DB.PROD_REFERENCE TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT SELECT ON FUTURE TABLES IN SCHEMA MEDICORE_TRANSFORM_DB.PROD_COMMON    TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT SELECT ON FUTURE VIEWS  IN SCHEMA MEDICORE_TRANSFORM_DB.PROD_CLINICAL  TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT SELECT ON FUTURE VIEWS  IN SCHEMA MEDICORE_TRANSFORM_DB.PROD_BILLING   TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT SELECT ON FUTURE VIEWS  IN SCHEMA MEDICORE_TRANSFORM_DB.PROD_REFERENCE TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT SELECT ON FUTURE VIEWS  IN SCHEMA MEDICORE_TRANSFORM_DB.PROD_COMMON    TO ROLE MEDICORE_DATA_SCIENTIST;

-- Future grants for COMPLIANCE_OFFICER
GRANT SELECT ON FUTURE TABLES IN SCHEMA MEDICORE_TRANSFORM_DB.PROD_CLINICAL  TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT SELECT ON FUTURE TABLES IN SCHEMA MEDICORE_TRANSFORM_DB.PROD_BILLING   TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT SELECT ON FUTURE TABLES IN SCHEMA MEDICORE_TRANSFORM_DB.PROD_REFERENCE TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT SELECT ON FUTURE TABLES IN SCHEMA MEDICORE_TRANSFORM_DB.PROD_AUDIT     TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT SELECT ON FUTURE TABLES IN SCHEMA MEDICORE_TRANSFORM_DB.PROD_COMMON    TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT SELECT ON FUTURE VIEWS  IN SCHEMA MEDICORE_TRANSFORM_DB.PROD_CLINICAL  TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT SELECT ON FUTURE VIEWS  IN SCHEMA MEDICORE_TRANSFORM_DB.PROD_BILLING   TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT SELECT ON FUTURE VIEWS  IN SCHEMA MEDICORE_TRANSFORM_DB.PROD_REFERENCE TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT SELECT ON FUTURE VIEWS  IN SCHEMA MEDICORE_TRANSFORM_DB.PROD_COMMON    TO ROLE MEDICORE_COMPLIANCE_OFFICER;

-- ------------------------------------------------------------
-- MEDICORE_ANALYTICS_DB — Role grants
-- ------------------------------------------------------------

GRANT USAGE ON DATABASE MEDICORE_ANALYTICS_DB TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON DATABASE MEDICORE_ANALYTICS_DB TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT USAGE ON DATABASE MEDICORE_ANALYTICS_DB TO ROLE MEDICORE_CLINICAL_PHYSICIAN;
GRANT USAGE ON DATABASE MEDICORE_ANALYTICS_DB TO ROLE MEDICORE_CLINICAL_NURSE;
GRANT USAGE ON DATABASE MEDICORE_ANALYTICS_DB TO ROLE MEDICORE_CLINICAL_READER;
GRANT USAGE ON DATABASE MEDICORE_ANALYTICS_DB TO ROLE MEDICORE_BILLING_SPECIALIST;
GRANT USAGE ON DATABASE MEDICORE_ANALYTICS_DB TO ROLE MEDICORE_BILLING_READER;
GRANT USAGE ON DATABASE MEDICORE_ANALYTICS_DB TO ROLE MEDICORE_ANALYST_PHI;
GRANT USAGE ON DATABASE MEDICORE_ANALYTICS_DB TO ROLE MEDICORE_ANALYST_RESTRICTED;
GRANT USAGE ON DATABASE MEDICORE_ANALYTICS_DB TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT USAGE ON DATABASE MEDICORE_ANALYTICS_DB TO ROLE MEDICORE_EXECUTIVE;
GRANT USAGE ON DATABASE MEDICORE_ANALYTICS_DB TO ROLE MEDICORE_EXT_AUDITOR;
GRANT USAGE ON DATABASE MEDICORE_ANALYTICS_DB TO ROLE MEDICORE_APP_STREAMLIT;
GRANT USAGE ON DATABASE MEDICORE_ANALYTICS_DB TO ROLE MEDICORE_REFERENCE_READER;
GRANT USAGE ON DATABASE MEDICORE_ANALYTICS_DB TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT USAGE ON DATABASE MEDICORE_ANALYTICS_DB TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;

-- PROD schema USAGE grants per role (following least privilege)
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_CLINICAL_PHYSICIAN;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_CLINICAL_NURSE;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_CLINICAL_READER;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_ANALYST_PHI;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_APP_STREAMLIT;

GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING TO ROLE MEDICORE_BILLING_SPECIALIST;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING TO ROLE MEDICORE_BILLING_READER;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING TO ROLE MEDICORE_ANALYST_PHI;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING TO ROLE MEDICORE_APP_STREAMLIT;

GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_REFERENCE TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_REFERENCE TO ROLE MEDICORE_REFERENCE_READER;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_REFERENCE TO ROLE MEDICORE_ANALYST_PHI;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_REFERENCE TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_REFERENCE TO ROLE MEDICORE_DATA_SCIENTIST;

GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE TO ROLE MEDICORE_EXECUTIVE;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE TO ROLE MEDICORE_ANALYST_RESTRICTED;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE TO ROLE MEDICORE_ANALYST_PHI;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE TO ROLE MEDICORE_APP_STREAMLIT;

GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_DEIDENTIFIED TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_DEIDENTIFIED TO ROLE MEDICORE_EXT_AUDITOR;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_DEIDENTIFIED TO ROLE MEDICORE_ANALYST_RESTRICTED;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_DEIDENTIFIED TO ROLE MEDICORE_ANALYST_PHI;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_DEIDENTIFIED TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_DEIDENTIFIED TO ROLE MEDICORE_DATA_SCIENTIST;

-- QA and DEV schema USAGE for engineering and CI/CD
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.QA_CLINICAL    TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.QA_BILLING     TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.QA_REFERENCE   TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.QA_EXECUTIVE   TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.QA_DEIDENTIFIED TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.DEV_CLINICAL   TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.DEV_BILLING    TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.DEV_REFERENCE  TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.DEV_EXECUTIVE  TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.DEV_DEIDENTIFIED TO ROLE MEDICORE_DATA_ENGINEER;

GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.QA_CLINICAL    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.QA_BILLING     TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.QA_REFERENCE   TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.QA_EXECUTIVE   TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.QA_DEIDENTIFIED TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.DEV_CLINICAL   TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.DEV_BILLING    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.DEV_REFERENCE  TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.DEV_EXECUTIVE  TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.DEV_DEIDENTIFIED TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;

-- PROD USAGE for SVC_GITHUB_ACTIONS (needed for PROD deployments)
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL   TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_REFERENCE  TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE  TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_DEIDENTIFIED TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;

-- CREATE privileges for DATA_ENGINEER and SVC_GITHUB_ACTIONS
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL    TO ROLE MEDICORE_DATA_ENGINEER;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING     TO ROLE MEDICORE_DATA_ENGINEER;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_REFERENCE   TO ROLE MEDICORE_DATA_ENGINEER;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE   TO ROLE MEDICORE_DATA_ENGINEER;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_DEIDENTIFIED TO ROLE MEDICORE_DATA_ENGINEER;

GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING     TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_REFERENCE   TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE   TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_ANALYTICS_DB.PROD_DEIDENTIFIED TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_ANALYTICS_DB.QA_CLINICAL      TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_ANALYTICS_DB.QA_BILLING       TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_ANALYTICS_DB.QA_REFERENCE     TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_ANALYTICS_DB.QA_EXECUTIVE     TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_ANALYTICS_DB.QA_DEIDENTIFIED  TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_ANALYTICS_DB.DEV_CLINICAL     TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_ANALYTICS_DB.DEV_BILLING      TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_ANALYTICS_DB.DEV_REFERENCE    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_ANALYTICS_DB.DEV_EXECUTIVE    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA MEDICORE_ANALYTICS_DB.DEV_DEIDENTIFIED TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;

-- Future grants on PROD schemas (SELECT for analytics consumers)
GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_CLINICAL_PHYSICIAN;
GRANT SELECT ON FUTURE VIEWS          IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_CLINICAL_PHYSICIAN;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_CLINICAL_PHYSICIAN;
GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_CLINICAL_NURSE;
GRANT SELECT ON FUTURE VIEWS          IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_CLINICAL_NURSE;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_CLINICAL_NURSE;
GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_CLINICAL_READER;
GRANT SELECT ON FUTURE VIEWS          IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_CLINICAL_READER;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_CLINICAL_READER;
GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_ANALYST_PHI;
GRANT SELECT ON FUTURE VIEWS          IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_ANALYST_PHI;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_ANALYST_PHI;
GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT SELECT ON FUTURE VIEWS          IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_APP_STREAMLIT;
GRANT SELECT ON FUTURE VIEWS          IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_APP_STREAMLIT;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL TO ROLE MEDICORE_APP_STREAMLIT;

GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING TO ROLE MEDICORE_BILLING_SPECIALIST;
GRANT SELECT ON FUTURE VIEWS          IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING TO ROLE MEDICORE_BILLING_SPECIALIST;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING TO ROLE MEDICORE_BILLING_SPECIALIST;
GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING TO ROLE MEDICORE_BILLING_READER;
GRANT SELECT ON FUTURE VIEWS          IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING TO ROLE MEDICORE_BILLING_READER;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING TO ROLE MEDICORE_BILLING_READER;
GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING TO ROLE MEDICORE_ANALYST_PHI;
GRANT SELECT ON FUTURE VIEWS          IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING TO ROLE MEDICORE_ANALYST_PHI;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING TO ROLE MEDICORE_ANALYST_PHI;
GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT SELECT ON FUTURE VIEWS          IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING TO ROLE MEDICORE_APP_STREAMLIT;
GRANT SELECT ON FUTURE VIEWS          IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING TO ROLE MEDICORE_APP_STREAMLIT;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_BILLING TO ROLE MEDICORE_APP_STREAMLIT;

GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_REFERENCE TO ROLE MEDICORE_REFERENCE_READER;
GRANT SELECT ON FUTURE VIEWS          IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_REFERENCE TO ROLE MEDICORE_REFERENCE_READER;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_REFERENCE TO ROLE MEDICORE_REFERENCE_READER;
GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_REFERENCE TO ROLE MEDICORE_ANALYST_PHI;
GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_REFERENCE TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_REFERENCE TO ROLE MEDICORE_DATA_SCIENTIST;

GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE TO ROLE MEDICORE_EXECUTIVE;
GRANT SELECT ON FUTURE VIEWS          IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE TO ROLE MEDICORE_EXECUTIVE;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE TO ROLE MEDICORE_EXECUTIVE;
GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE TO ROLE MEDICORE_ANALYST_RESTRICTED;
GRANT SELECT ON FUTURE VIEWS          IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE TO ROLE MEDICORE_ANALYST_RESTRICTED;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE TO ROLE MEDICORE_ANALYST_RESTRICTED;
GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE TO ROLE MEDICORE_ANALYST_PHI;
GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE TO ROLE MEDICORE_APP_STREAMLIT;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_EXECUTIVE TO ROLE MEDICORE_APP_STREAMLIT;

GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_DEIDENTIFIED TO ROLE MEDICORE_EXT_AUDITOR;
GRANT SELECT ON FUTURE VIEWS          IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_DEIDENTIFIED TO ROLE MEDICORE_EXT_AUDITOR;
GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_DEIDENTIFIED TO ROLE MEDICORE_ANALYST_RESTRICTED;
GRANT SELECT ON FUTURE VIEWS          IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_DEIDENTIFIED TO ROLE MEDICORE_ANALYST_RESTRICTED;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_DEIDENTIFIED TO ROLE MEDICORE_ANALYST_RESTRICTED;
GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_DEIDENTIFIED TO ROLE MEDICORE_ANALYST_PHI;
GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_DEIDENTIFIED TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT SELECT ON FUTURE TABLES         IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_DEIDENTIFIED TO ROLE MEDICORE_DATA_SCIENTIST;

-- ------------------------------------------------------------
-- MEDICORE_AI_READY_DB — Role grants
-- ------------------------------------------------------------

GRANT USAGE ON DATABASE MEDICORE_AI_READY_DB TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT USAGE ON DATABASE MEDICORE_AI_READY_DB TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON DATABASE MEDICORE_AI_READY_DB TO ROLE MEDICORE_ANALYST_PHI;
GRANT USAGE ON DATABASE MEDICORE_AI_READY_DB TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT USAGE ON DATABASE MEDICORE_AI_READY_DB TO ROLE MEDICORE_PLATFORM_ADMIN;
GRANT USAGE ON DATABASE MEDICORE_AI_READY_DB TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;

-- PROD schema USAGE
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.PROD_FEATURES   TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.PROD_FEATURES   TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.PROD_FEATURES   TO ROLE MEDICORE_ANALYST_PHI;
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.PROD_FEATURES   TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.PROD_TRAINING   TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.PROD_TRAINING   TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.PROD_TRAINING   TO ROLE MEDICORE_ANALYST_PHI;
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.PROD_TRAINING   TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.PROD_SEMANTIC   TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.PROD_SEMANTIC   TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.PROD_SEMANTIC   TO ROLE MEDICORE_COMPLIANCE_OFFICER;
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.PROD_EMBEDDINGS TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.PROD_EMBEDDINGS TO ROLE MEDICORE_DATA_ENGINEER;
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.PROD_EMBEDDINGS TO ROLE MEDICORE_ANALYST_PHI;
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.PROD_EMBEDDINGS TO ROLE MEDICORE_COMPLIANCE_OFFICER;

-- QA and DEV USAGE for SVC_GITHUB_ACTIONS
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.QA_FEATURES     TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.QA_TRAINING     TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.QA_SEMANTIC     TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.QA_EMBEDDINGS   TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.DEV_FEATURES    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.DEV_TRAINING    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.DEV_SEMANTIC    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.DEV_EMBEDDINGS  TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;

-- PROD USAGE for SVC_GITHUB_ACTIONS
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.PROD_FEATURES   TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.PROD_TRAINING   TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.PROD_SEMANTIC   TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT USAGE ON SCHEMA MEDICORE_AI_READY_DB.PROD_EMBEDDINGS TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;

-- CREATE privileges for DATA_ENGINEER and SVC_GITHUB_ACTIONS
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_AI_READY_DB.PROD_FEATURES   TO ROLE MEDICORE_DATA_ENGINEER;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_AI_READY_DB.PROD_TRAINING   TO ROLE MEDICORE_DATA_ENGINEER;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_AI_READY_DB.PROD_SEMANTIC   TO ROLE MEDICORE_DATA_ENGINEER;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_AI_READY_DB.PROD_EMBEDDINGS TO ROLE MEDICORE_DATA_ENGINEER;

GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_AI_READY_DB.PROD_FEATURES   TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_AI_READY_DB.PROD_TRAINING   TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_AI_READY_DB.PROD_SEMANTIC   TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_AI_READY_DB.PROD_EMBEDDINGS TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_AI_READY_DB.QA_FEATURES     TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_AI_READY_DB.QA_TRAINING     TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_AI_READY_DB.QA_SEMANTIC     TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_AI_READY_DB.QA_EMBEDDINGS   TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_AI_READY_DB.DEV_FEATURES    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_AI_READY_DB.DEV_TRAINING    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_AI_READY_DB.DEV_SEMANTIC    TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA MEDICORE_AI_READY_DB.DEV_EMBEDDINGS  TO ROLE MEDICORE_SVC_GITHUB_ACTIONS;

-- Future grants for DATA_SCIENTIST (SELECT on PROD schemas)
GRANT SELECT ON FUTURE TABLES IN SCHEMA MEDICORE_AI_READY_DB.PROD_FEATURES   TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT SELECT ON FUTURE TABLES IN SCHEMA MEDICORE_AI_READY_DB.PROD_TRAINING   TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT SELECT ON FUTURE TABLES IN SCHEMA MEDICORE_AI_READY_DB.PROD_SEMANTIC   TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT SELECT ON FUTURE TABLES IN SCHEMA MEDICORE_AI_READY_DB.PROD_EMBEDDINGS TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT SELECT ON FUTURE VIEWS  IN SCHEMA MEDICORE_AI_READY_DB.PROD_FEATURES   TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT SELECT ON FUTURE VIEWS  IN SCHEMA MEDICORE_AI_READY_DB.PROD_TRAINING   TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT SELECT ON FUTURE VIEWS  IN SCHEMA MEDICORE_AI_READY_DB.PROD_SEMANTIC   TO ROLE MEDICORE_DATA_SCIENTIST;
GRANT SELECT ON FUTURE VIEWS  IN SCHEMA MEDICORE_AI_READY_DB.PROD_EMBEDDINGS TO ROLE MEDICORE_DATA_SCIENTIST;

-- Future grants for ANALYST_PHI (SELECT on FEATURES and TRAINING)
GRANT SELECT ON FUTURE TABLES IN SCHEMA MEDICORE_AI_READY_DB.PROD_FEATURES TO ROLE MEDICORE_ANALYST_PHI;
GRANT SELECT ON FUTURE TABLES IN SCHEMA MEDICORE_AI_READY_DB.PROD_TRAINING TO ROLE MEDICORE_ANALYST_PHI;
GRANT SELECT ON FUTURE VIEWS  IN SCHEMA MEDICORE_AI_READY_DB.PROD_FEATURES TO ROLE MEDICORE_ANALYST_PHI;
GRANT SELECT ON FUTURE VIEWS  IN SCHEMA MEDICORE_AI_READY_DB.PROD_TRAINING TO ROLE MEDICORE_ANALYST_PHI;


-- ============================================================
-- SECTION 8: COMPREHENSIVE VERIFICATION
-- ============================================================

USE ROLE ACCOUNTADMIN;

-- Verify all 5 databases exist with correct retention settings
SHOW DATABASES LIKE 'MEDICORE%';

-- Verify GOVERNANCE_DB now has all 5 schemas
SHOW SCHEMAS IN DATABASE MEDICORE_GOVERNANCE_DB;

-- Verify schema counts per database
-- Expected: GOVERNANCE=5, RAW=12, TRANSFORM=15, ANALYTICS=15, AI_READY=12
SELECT 'MEDICORE_GOVERNANCE_DB' AS DATABASE_NAME, COUNT(*) AS SCHEMA_COUNT
FROM MEDICORE_GOVERNANCE_DB.INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC')
UNION ALL
SELECT 'MEDICORE_RAW_DB', COUNT(*)
FROM MEDICORE_RAW_DB.INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC')
UNION ALL
SELECT 'MEDICORE_TRANSFORM_DB', COUNT(*)
FROM MEDICORE_TRANSFORM_DB.INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC')
UNION ALL
SELECT 'MEDICORE_ANALYTICS_DB', COUNT(*)
FROM MEDICORE_ANALYTICS_DB.INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC')
UNION ALL
SELECT 'MEDICORE_AI_READY_DB', COUNT(*)
FROM MEDICORE_AI_READY_DB.INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC')
ORDER BY DATABASE_NAME;

-- Verify environment-prefixed schemas in RAW_DB
SHOW SCHEMAS IN DATABASE MEDICORE_RAW_DB;

-- Verify environment-prefixed schemas in TRANSFORM_DB
SHOW SCHEMAS IN DATABASE MEDICORE_TRANSFORM_DB;

-- Verify environment-prefixed schemas in ANALYTICS_DB
SHOW SCHEMAS IN DATABASE MEDICORE_ANALYTICS_DB;

-- Verify environment-prefixed schemas in AI_READY_DB
SHOW SCHEMAS IN DATABASE MEDICORE_AI_READY_DB;

-- Verify TRANSIENT schemas are correctly created (no Time Travel)
SELECT SCHEMA_NAME, IS_TRANSIENT
FROM MEDICORE_RAW_DB.INFORMATION_SCHEMA.SCHEMATA
WHERE IS_TRANSIENT = 'YES'
ORDER BY SCHEMA_NAME;

SELECT SCHEMA_NAME, IS_TRANSIENT
FROM MEDICORE_TRANSFORM_DB.INFORMATION_SCHEMA.SCHEMATA
WHERE IS_TRANSIENT = 'YES'
ORDER BY SCHEMA_NAME;

-- Verify key grants (spot check)
SHOW GRANTS ON DATABASE MEDICORE_RAW_DB;
SHOW GRANTS ON DATABASE MEDICORE_ANALYTICS_DB;
SHOW FUTURE GRANTS IN SCHEMA MEDICORE_ANALYTICS_DB.PROD_CLINICAL;
SHOW FUTURE GRANTS IN SCHEMA MEDICORE_AI_READY_DB.PROD_FEATURES;


-- ============================================================
-- SECTION 9: PHASE 04 SUMMARY
-- ============================================================
--
-- DATABASES CREATED: 4 (plus GOVERNANCE_DB completed)
--
--   MEDICORE_GOVERNANCE_DB  : Phase 01 created SECURITY schema.
--                             Phase 04 adds POLICIES, TAGS,
--                             DATA_QUALITY, AUDIT schemas.
--                             Total: 5 schemas.
--
--   MEDICORE_RAW_DB         : Bronze. 90-day retention.
--                             12 schemas (4 domains × 3 envs)
--                             PROD/QA/DEV × CLINICAL/BILLING/
--                             REFERENCE/AUDIT
--
--   MEDICORE_TRANSFORM_DB   : Silver. 30-day retention.
--                             15 schemas (5 domains × 3 envs)
--                             PROD/QA/DEV × CLINICAL/BILLING/
--                             REFERENCE/AUDIT/COMMON
--
--   MEDICORE_ANALYTICS_DB   : Gold. 30-day retention.
--                             15 schemas (5 domains × 3 envs)
--                             PROD/QA/DEV × CLINICAL/BILLING/
--                             REFERENCE/EXECUTIVE/DEIDENTIFIED
--
--   MEDICORE_AI_READY_DB    : Platinum. 14-day retention.
--                             12 schemas (4 domains × 3 envs)
--                             PROD/QA/DEV × FEATURES/TRAINING/
--                             SEMANTIC/EMBEDDINGS
--
-- TOTAL SCHEMAS CREATED: 59
--   (5 + 12 + 15 + 15 + 12)
--
-- TRANSIENT SCHEMAS (no Time Travel / Fail-safe):
--   MEDICORE_RAW_DB:       PROD_AUDIT, QA_AUDIT, DEV_AUDIT
--   MEDICORE_TRANSFORM_DB: PROD_AUDIT, QA_AUDIT, DEV_AUDIT
--
-- SCHEMA OWNERSHIP:
--   ACCOUNTADMIN retains ownership of all schemas.
--   This is intentional — Schemachange CI/CD uses CREATE
--   privileges on MEDICORE_SVC_GITHUB_ACTIONS, not ownership.
--
-- DATABASE AND SCHEMA GRANTS: Minimum grants for unblocking
--   Phase 05. Full grant matrix completed in Phase 02
--   Sections 6-12 (to be re-run after Phase 04).
--
-- NEXT STEPS:
--   1. Run Phase 05 (Resource Monitors)
--   2. Return to Phase 02 and execute Sections 6-12 in full
--      — all database USAGE, schema USAGE, and future grants
--        for the complete 18-role matrix
--   3. Proceed to Phase 06 (Monitoring)
--
-- PHASE 05 DEPENDENCIES:
--   - All 4 databases exist for warehouse monitoring
--
-- PHASE 08 DEPENDENCIES:
--   - Masking policies will target PROD_* schemas only
--   - Row access policies applied to PROD_CLINICAL and
--     PROD_BILLING in MEDICORE_ANALYTICS_DB
--   - Tags will classify all 59 schemas
--
-- PHASE 11 DEPENDENCIES:
--   - Dynamic Tables will be built in MEDICORE_ANALYTICS_DB
--     PROD/QA/DEV schemas sourcing from MEDICORE_TRANSFORM_DB
--   - CREATE DYNAMIC TABLE grants already in place for
--     DATA_ENGINEER and SVC_GITHUB_ACTIONS
--
-- !! REMINDER !!
--   DEV and QA schemas must NEVER contain real PHI.
--   Only PROD_* schemas in any database should hold real
--   patient data. Enforce this through data loading policies
--   and Snowflake row access policies (Phase 08).
--
-- ============================================================
-- END OF PHASE 04: DATABASE STRUCTURE
-- ============================================================