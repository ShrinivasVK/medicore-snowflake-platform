/*
================================================================================
File:           infrastructure/11_medallion/01_transform_layer/02_clinical/03_encounters.sql
Purpose:        Silver/Transform layer - Encounters fact table with data 
                standardization, validation, and quarantine logic
Source Table:   MEDICORE_RAW_DB.DEV_CLINICAL.ENCOUNTERS
Target Table:   MEDICORE_TRANSFORM_DB.DEV_CLINICAL.ENCOUNTERS
Quarantine:     MEDICORE_TRANSFORM_DB.DEV_CLINICAL.ENCOUNTERS_QUARANTINE

Source Columns (RAW):
  - ENCOUNTER_ID (NUMBER)           -> encounter_id (NUMBER, primary key)
  - PATIENT_ID (NUMBER)             -> patient_id (NUMBER, logical FK)
  - PROVIDER_ID (NUMBER)            -> provider_id (NUMBER, logical FK)
  - DEPARTMENT_ID (NUMBER)          -> department_id (NUMBER, logical FK)
  - ADMISSION_DATE (DATE)           -> admission_date (DATE)
  - DISCHARGE_DATE (DATE)           -> discharge_date (DATE)
  - ENCOUNTER_TYPE (VARCHAR)        -> encounter_type (STRING, UPPER + TRIM)
  - PRIMARY_ICD10_CODE (VARCHAR)    -> primary_icd10_code (STRING, UPPER + TRIM)
  - CREATED_AT (TIMESTAMP)          -> created_at (TIMESTAMP)

Metadata Columns (Added):
  - load_timestamp                  DEFAULT CURRENT_TIMESTAMP()
  - record_source                   DEFAULT 'RAW_CLINICAL'
  - data_quality_status             DEFAULT 'VALIDATED'

STRICT COLUMN POLICY:
  - Only columns present in RAW
  - Explicitly derived columns with defined logic
  - Required metadata columns
  - NO placeholder or invented columns

Business Rules Applied:
  - TRIM all string fields
  - UPPERCASE encounter_type and primary_icd10_code
  - Quarantine records with NULL encounter_id or patient_id
  - Quarantine records where discharge_date < admission_date
  - Quarantine records where admission_date is in future

Referential Awareness:
  - patient_id, provider_id, department_id preserved as logical FKs
  - primary_icd10_code preserved for diagnosis joins
  - No hard FK constraints enforced in Silver

Environment:    DEV (CI/CD will deploy to QA/PROD with schema substitution)

Owner:          Data Engineering
Pillar:         Pillar 1 - Cost Visibility (revenue per encounter analytics)
                Pillar 2 - Clinical Insights (utilization & outcome analytics)
Layer:          TRANSFORM (Silver)
Domain:         CLINICAL

Change History:
  Date        Author              Description
  ----------  ------------------  -----------------------------------------------
  2026-02-26  Data Engineering    Initial creation
  2026-02-26  Data Engineering    Switched to direct references for simplicity
================================================================================
*/

-- ============================================================================
-- SESSION CONFIGURATION
-- ============================================================================
USE ROLE MEDICORE_DATA_ENGINEER;
USE WAREHOUSE MEDICORE_ETL_WH;

-- ============================================================================
-- STEP 1: CREATE SILVER TABLE (IF NOT EXISTS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS MEDICORE_TRANSFORM_DB.DEV_CLINICAL.ENCOUNTERS (
    encounter_id            NUMBER          NOT NULL    COMMENT 'Unique encounter ID (primary key)',
    patient_id              NUMBER          NOT NULL    COMMENT 'Patient reference (logical FK)',
    provider_id             NUMBER                      COMMENT 'Provider reference (logical FK)',
    department_id           NUMBER                      COMMENT 'Department reference (logical FK)',
    admission_date          DATE                        COMMENT 'Admission date',
    discharge_date          DATE                        COMMENT 'Discharge date',
    encounter_type          STRING                      COMMENT 'Encounter classification - uppercase',
    primary_icd10_code      STRING                      COMMENT 'Primary diagnosis code (logical FK) - uppercase',
    created_at              TIMESTAMP_NTZ               COMMENT 'Original record creation timestamp',
    load_timestamp          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP() COMMENT 'ETL load timestamp',
    record_source           STRING          DEFAULT 'RAW_CLINICAL' COMMENT 'Source system identifier',
    data_quality_status     STRING          DEFAULT 'VALIDATED' COMMENT 'Data quality validation status',
    CONSTRAINT pk_encounters PRIMARY KEY (encounter_id)
)
COMMENT = 'Silver/Transform layer - Cleaned and validated encounters fact table';

-- ============================================================================
-- STEP 2: CREATE QUARANTINE TABLE (IF NOT EXISTS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS MEDICORE_TRANSFORM_DB.DEV_CLINICAL.ENCOUNTERS_QUARANTINE (
    quarantine_id           STRING          DEFAULT UUID_STRING() COMMENT 'Unique quarantine record identifier',
    encounter_id            NUMBER                      COMMENT 'Original encounter_id (may be NULL)',
    patient_id              NUMBER                      COMMENT 'Original patient_id (may be NULL)',
    provider_id             NUMBER                      COMMENT 'Original provider_id',
    department_id           NUMBER                      COMMENT 'Original department_id',
    admission_date          DATE                        COMMENT 'Original admission_date',
    discharge_date          DATE                        COMMENT 'Original discharge_date',
    encounter_type          STRING                      COMMENT 'Original encounter_type',
    primary_icd10_code      STRING                      COMMENT 'Original primary_icd10_code',
    created_at              TIMESTAMP_NTZ               COMMENT 'Original created_at timestamp',
    failure_reason          STRING          NOT NULL    COMMENT 'Reason for quarantine',
    load_timestamp          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP() COMMENT 'Quarantine load timestamp'
)
COMMENT = 'Quarantine table for ENCOUNTERS records failing validation';

-- ============================================================================
-- STEP 3: MERGE QUARANTINED RECORDS
-- ============================================================================
MERGE INTO MEDICORE_TRANSFORM_DB.DEV_CLINICAL.ENCOUNTERS_QUARANTINE AS tgt
USING (
    SELECT
        src.encounter_id,
        src.patient_id,
        src.provider_id,
        src.department_id,
        src.admission_date,
        src.discharge_date,
        src.encounter_type,
        src.primary_icd10_code,
        src.created_at,
        CASE
            WHEN src.encounter_id IS NULL 
                THEN 'FAILED: encounter_id IS NULL'
            WHEN src.patient_id IS NULL 
                THEN 'FAILED: patient_id IS NULL'
            WHEN src.admission_date > CURRENT_DATE() 
                THEN 'FAILED: admission_date is in future (' || src.admission_date::STRING || ')'
            WHEN src.discharge_date IS NOT NULL AND src.admission_date IS NOT NULL 
                 AND src.discharge_date < src.admission_date 
                THEN 'FAILED: discharge_date (' || src.discharge_date::STRING || ') < admission_date (' || src.admission_date::STRING || ')'
            ELSE 'FAILED: Unknown validation error'
        END AS failure_reason,
        CURRENT_TIMESTAMP() AS load_timestamp
    FROM MEDICORE_RAW_DB.DEV_CLINICAL.ENCOUNTERS src
    WHERE 
        src.encounter_id IS NULL
        OR src.patient_id IS NULL
        OR src.admission_date > CURRENT_DATE()
        OR (src.discharge_date IS NOT NULL AND src.admission_date IS NOT NULL 
            AND src.discharge_date < src.admission_date)
) AS src
ON tgt.encounter_id = src.encounter_id AND src.encounter_id IS NOT NULL
WHEN MATCHED AND (
    tgt.failure_reason != src.failure_reason
    OR COALESCE(tgt.patient_id, -1) != COALESCE(src.patient_id, -1)
    OR COALESCE(tgt.admission_date::STRING, '') != COALESCE(src.admission_date::STRING, '')
    OR COALESCE(tgt.discharge_date::STRING, '') != COALESCE(src.discharge_date::STRING, '')
) THEN UPDATE SET
    tgt.patient_id          = src.patient_id,
    tgt.provider_id         = src.provider_id,
    tgt.department_id       = src.department_id,
    tgt.admission_date      = src.admission_date,
    tgt.discharge_date      = src.discharge_date,
    tgt.encounter_type      = src.encounter_type,
    tgt.primary_icd10_code  = src.primary_icd10_code,
    tgt.created_at          = src.created_at,
    tgt.failure_reason      = src.failure_reason,
    tgt.load_timestamp      = src.load_timestamp
WHEN NOT MATCHED THEN INSERT (
    encounter_id, patient_id, provider_id, department_id, admission_date, discharge_date,
    encounter_type, primary_icd10_code, created_at, failure_reason, load_timestamp
) VALUES (
    src.encounter_id, src.patient_id, src.provider_id, src.department_id, src.admission_date, src.discharge_date,
    src.encounter_type, src.primary_icd10_code, src.created_at, src.failure_reason, src.load_timestamp
);

-- ============================================================================
-- STEP 4: MERGE VALIDATED RECORDS INTO SILVER TABLE
-- ============================================================================
MERGE INTO MEDICORE_TRANSFORM_DB.DEV_CLINICAL.ENCOUNTERS AS tgt
USING (
    SELECT
        src.encounter_id                        AS encounter_id,
        src.patient_id                          AS patient_id,
        src.provider_id                         AS provider_id,
        src.department_id                       AS department_id,
        src.admission_date                      AS admission_date,
        src.discharge_date                      AS discharge_date,
        UPPER(TRIM(src.encounter_type))         AS encounter_type,
        UPPER(TRIM(src.primary_icd10_code))     AS primary_icd10_code,
        src.created_at                          AS created_at,
        CURRENT_TIMESTAMP()                     AS load_timestamp,
        'RAW_CLINICAL'                          AS record_source,
        'VALIDATED'                             AS data_quality_status
    FROM MEDICORE_RAW_DB.DEV_CLINICAL.ENCOUNTERS src
    WHERE 
        src.encounter_id IS NOT NULL
        AND src.patient_id IS NOT NULL
        AND (src.admission_date IS NULL OR src.admission_date <= CURRENT_DATE())
        AND (src.discharge_date IS NULL OR src.admission_date IS NULL 
             OR src.discharge_date >= src.admission_date)
) AS src
ON tgt.encounter_id = src.encounter_id
WHEN MATCHED AND (
    tgt.patient_id != src.patient_id
    OR COALESCE(tgt.provider_id, -1) != COALESCE(src.provider_id, -1)
    OR COALESCE(tgt.department_id, -1) != COALESCE(src.department_id, -1)
    OR COALESCE(tgt.admission_date::STRING, '') != COALESCE(src.admission_date::STRING, '')
    OR COALESCE(tgt.discharge_date::STRING, '') != COALESCE(src.discharge_date::STRING, '')
    OR COALESCE(tgt.encounter_type, '') != COALESCE(src.encounter_type, '')
    OR COALESCE(tgt.primary_icd10_code, '') != COALESCE(src.primary_icd10_code, '')
    OR COALESCE(tgt.created_at::STRING, '') != COALESCE(src.created_at::STRING, '')
) THEN UPDATE SET
    tgt.patient_id          = src.patient_id,
    tgt.provider_id         = src.provider_id,
    tgt.department_id       = src.department_id,
    tgt.admission_date      = src.admission_date,
    tgt.discharge_date      = src.discharge_date,
    tgt.encounter_type      = src.encounter_type,
    tgt.primary_icd10_code  = src.primary_icd10_code,
    tgt.created_at          = src.created_at,
    tgt.load_timestamp      = src.load_timestamp,
    tgt.record_source       = src.record_source,
    tgt.data_quality_status = src.data_quality_status
WHEN NOT MATCHED THEN INSERT (
    encounter_id, patient_id, provider_id, department_id, admission_date, discharge_date,
    encounter_type, primary_icd10_code, created_at, load_timestamp, record_source, data_quality_status
) VALUES (
    src.encounter_id, src.patient_id, src.provider_id, src.department_id, src.admission_date, src.discharge_date,
    src.encounter_type, src.primary_icd10_code, src.created_at, src.load_timestamp, src.record_source, src.data_quality_status
);

-- ============================================================================
-- STEP 5: APPLY GOVERNANCE TAGS
-- ============================================================================
ALTER TABLE MEDICORE_TRANSFORM_DB.DEV_CLINICAL.ENCOUNTERS
    SET TAG 
        MEDICORE_GOVERNANCE_DB.TAGS.MEDALLION_LAYER = 'TRANSFORM',
        MEDICORE_GOVERNANCE_DB.TAGS.DATA_DOMAIN = 'CLINICAL',
        MEDICORE_GOVERNANCE_DB.TAGS.ENVIRONMENT = 'DEV';

ALTER TABLE MEDICORE_TRANSFORM_DB.DEV_CLINICAL.ENCOUNTERS_QUARANTINE
    SET TAG 
        MEDICORE_GOVERNANCE_DB.TAGS.MEDALLION_LAYER = 'TRANSFORM',
        MEDICORE_GOVERNANCE_DB.TAGS.DATA_DOMAIN = 'CLINICAL',
        MEDICORE_GOVERNANCE_DB.TAGS.ENVIRONMENT = 'DEV';

-- ============================================================================
-- STEP 6: EXECUTION SUMMARY
-- ============================================================================
SELECT 
    'ENCOUNTERS Transform Load Complete' AS status,
    'DEV' AS environment,
    CURRENT_TIMESTAMP() AS execution_timestamp,
    (SELECT COUNT(*) FROM MEDICORE_TRANSFORM_DB.DEV_CLINICAL.ENCOUNTERS) AS validated_record_count,
    (SELECT COUNT(*) FROM MEDICORE_TRANSFORM_DB.DEV_CLINICAL.ENCOUNTERS_QUARANTINE 
     WHERE load_timestamp >= DATEADD('hour', -1, CURRENT_TIMESTAMP())) AS quarantined_record_count_last_hour;
