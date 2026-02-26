/*
================================================================================
File:           infrastructure/11_medallion/01_transform_layer/02_clinical/01_patients.sql
Purpose:        Silver/Transform layer - Patient dimension table with data 
                standardization, validation, PHI handling, and quarantine logic
Source Table:   MEDICORE_RAW_DB.<ENV>_CLINICAL.PATIENTS
Target Table:   MEDICORE_TRANSFORM_DB.<ENV>_CLINICAL.PATIENTS
Quarantine:     MEDICORE_TRANSFORM_DB.<ENV>_CLINICAL.PATIENTS_QUARANTINE

Source Columns (RAW):
  - PATIENT_ID (NUMBER)         -> patient_id (NUMBER, primary key)
  - MRN (VARCHAR)               -> mrn (STRING, TRIM)
  - FIRST_NAME (VARCHAR)        -> first_name (STRING, UPPER + TRIM)
  - LAST_NAME (VARCHAR)         -> last_name (STRING, UPPER + TRIM)
  - DATE_OF_BIRTH (DATE)        -> date_of_birth (DATE)
  - GENDER (VARCHAR)            -> gender (STRING, standardized: M/F/UNKNOWN)
  - PHONE_NUMBER (VARCHAR)      -> phone_number (STRING, TRIM)
  - ZIP_CODE (VARCHAR)          -> zip_code (STRING, TRIM)
  - CREATED_AT (TIMESTAMP)      -> created_at (TIMESTAMP)

Metadata Columns (Added):
  - load_timestamp              DEFAULT CURRENT_TIMESTAMP()
  - record_source               DEFAULT 'RAW_CLINICAL'
  - data_quality_status         DEFAULT 'VALIDATED'

PHI Columns (No masking in Silver - applied in Analytics layer):
  - mrn, first_name, last_name, date_of_birth, phone_number, zip_code

STRICT COLUMN POLICY:
  - Only columns present in RAW
  - Explicitly derived columns with defined logic
  - Required metadata columns
  - NO placeholder or invented columns

Business Rules Applied:
  - TRIM all string fields
  - UPPERCASE first_name and last_name
  - Standardize gender to M/F/UNKNOWN
  - Quarantine records with NULL patient_id, mrn, or names
  - Quarantine records with future date_of_birth
  - Quarantine records with age > 120 years

Parameterization:
  - Uses EXECUTE IMMEDIATE for dynamic SQL with $ENVIRONMENT variable
  - CI/CD (GitHub Actions) sets ENVIRONMENT = 'DEV' | 'QA' | 'PROD'

Owner:          Data Engineering
Pillar:         Pillar 1 - Cost Visibility (patient-level revenue attribution)
                Pillar 2 - Clinical Insights (cohort and outcome analysis)
Layer:          TRANSFORM (Silver)
Domain:         CLINICAL

Change History:
  Date        Author              Description
  ----------  ------------------  -----------------------------------------------
  2026-02-26  Data Engineering    Initial creation
  2026-02-26  Data Engineering    Replaced direct refs with EXECUTE IMMEDIATE
================================================================================
*/

-- ============================================================================
-- SESSION CONFIGURATION
-- ============================================================================
USE ROLE MEDICORE_DATA_ENGINEER;
USE WAREHOUSE MEDICORE_ETL_WH;

-- ============================================================================
-- STEP 1: CREATE TARGET SCHEMA (IF NOT EXISTS)
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS MEDICORE_TRANSFORM_DB.DEV_CLINICAL;

-- ============================================================================
-- STEP 2: CREATE SILVER TABLE (IF NOT EXISTS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PATIENTS (
    patient_id              NUMBER          NOT NULL    COMMENT 'Unique patient surrogate ID (primary key)',
    mrn                     STRING          NOT NULL    COMMENT 'Medical Record Number (PHI)',
    first_name              STRING          NOT NULL    COMMENT 'Patient first name - uppercase (PHI)',
    last_name               STRING          NOT NULL    COMMENT 'Patient last name - uppercase (PHI)',
    date_of_birth           DATE                        COMMENT 'Date of birth (PHI)',
    gender                  STRING                      COMMENT 'Standardized gender (M/F/UNKNOWN)',
    phone_number            STRING                      COMMENT 'Contact phone number (PHI)',
    zip_code                STRING                      COMMENT 'Postal code (PHI)',
    created_at              TIMESTAMP_NTZ               COMMENT 'Original record creation timestamp',
    load_timestamp          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP() COMMENT 'ETL load timestamp',
    record_source           STRING          DEFAULT 'RAW_CLINICAL' COMMENT 'Source system identifier',
    data_quality_status     STRING          DEFAULT 'VALIDATED' COMMENT 'Data quality validation status',
    CONSTRAINT pk_patients PRIMARY KEY (patient_id)
)
COMMENT = 'Silver/Transform layer - Cleaned and validated patient dimension (contains PHI)';

-- ============================================================================
-- STEP 3: CREATE QUARANTINE TABLE (IF NOT EXISTS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PATIENTS_QUARANTINE (
    quarantine_id           STRING          DEFAULT UUID_STRING() COMMENT 'Unique quarantine record identifier',
    patient_id              NUMBER                      COMMENT 'Original patient_id (may be NULL)',
    mrn                     STRING                      COMMENT 'Original MRN (may be NULL)',
    first_name              STRING                      COMMENT 'Original first_name (may be NULL)',
    last_name               STRING                      COMMENT 'Original last_name (may be NULL)',
    date_of_birth           DATE                        COMMENT 'Original date_of_birth',
    gender                  STRING                      COMMENT 'Original gender',
    phone_number            STRING                      COMMENT 'Original phone_number',
    zip_code                STRING                      COMMENT 'Original zip_code',
    created_at              TIMESTAMP_NTZ               COMMENT 'Original created_at timestamp',
    failure_reason          STRING          NOT NULL    COMMENT 'Reason for quarantine',
    load_timestamp          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP() COMMENT 'Quarantine load timestamp'
)
COMMENT = 'Quarantine table for PATIENTS records failing validation (contains PHI)';

-- ============================================================================
-- STEP 4: MERGE QUARANTINED RECORDS
-- ============================================================================
MERGE INTO MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PATIENTS_QUARANTINE tgt
USING (
    SELECT
        src.*,
        CASE
            WHEN src.patient_id IS NULL THEN 'FAILED: patient_id IS NULL'
            WHEN src.mrn IS NULL OR TRIM(src.mrn) = '' THEN 'FAILED: mrn invalid'
            WHEN src.first_name IS NULL OR TRIM(src.first_name) = '' THEN 'FAILED: first_name invalid'
            WHEN src.last_name IS NULL OR TRIM(src.last_name) = '' THEN 'FAILED: last_name invalid'
            WHEN src.date_of_birth > CURRENT_DATE() THEN 'FAILED: date_of_birth in future'
            WHEN src.date_of_birth < DATEADD(year, -120, CURRENT_DATE()) THEN 'FAILED: age > 120'
            ELSE 'FAILED: Unknown validation error'
        END AS failure_reason,
        CURRENT_TIMESTAMP() AS load_timestamp
    FROM MEDICORE_RAW_DB.DEV_CLINICAL.PATIENTS src
    WHERE 
        src.patient_id IS NULL
        OR src.mrn IS NULL OR TRIM(src.mrn) = ''
        OR src.first_name IS NULL OR TRIM(src.first_name) = ''
        OR src.last_name IS NULL OR TRIM(src.last_name) = ''
        OR src.date_of_birth > CURRENT_DATE()
        OR src.date_of_birth < DATEADD(year, -120, CURRENT_DATE())
) src
ON tgt.patient_id = src.patient_id
WHEN MATCHED THEN UPDATE SET
    mrn = src.mrn,
    first_name = src.first_name,
    last_name = src.last_name,
    date_of_birth = src.date_of_birth,
    gender = src.gender,
    phone_number = src.phone_number,
    zip_code = src.zip_code,
    created_at = src.created_at,
    failure_reason = src.failure_reason,
    load_timestamp = src.load_timestamp
WHEN NOT MATCHED THEN INSERT (
    patient_id, mrn, first_name, last_name, date_of_birth, gender,
    phone_number, zip_code, created_at, failure_reason, load_timestamp
) VALUES (
    src.patient_id, src.mrn, src.first_name, src.last_name, src.date_of_birth,
    src.gender, src.phone_number, src.zip_code, src.created_at,
    src.failure_reason, src.load_timestamp
);

-- ============================================================================
-- STEP 5: MERGE VALIDATED RECORDS INTO SILVER TABLE
-- ============================================================================
MERGE INTO MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PATIENTS tgt
USING (
    SELECT
        patient_id,
        TRIM(mrn) AS mrn,
        UPPER(TRIM(first_name)) AS first_name,
        UPPER(TRIM(last_name)) AS last_name,
        date_of_birth,
        CASE UPPER(TRIM(gender))
            WHEN 'M' THEN 'M'
            WHEN 'MALE' THEN 'M'
            WHEN 'F' THEN 'F'
            WHEN 'FEMALE' THEN 'F'
            ELSE 'UNKNOWN'
        END AS gender,
        TRIM(phone_number) AS phone_number,
        TRIM(zip_code) AS zip_code,
        created_at,
        CURRENT_TIMESTAMP() AS load_timestamp,
        'RAW_CLINICAL' AS record_source,
        'VALIDATED' AS data_quality_status
    FROM MEDICORE_RAW_DB.DEV_CLINICAL.PATIENTS
    WHERE 
        patient_id IS NOT NULL
        AND mrn IS NOT NULL AND TRIM(mrn) != ''
        AND first_name IS NOT NULL AND TRIM(first_name) != ''
        AND last_name IS NOT NULL AND TRIM(last_name) != ''
        AND (date_of_birth IS NULL OR date_of_birth <= CURRENT_DATE())
        AND (date_of_birth IS NULL OR date_of_birth >= DATEADD(year, -120, CURRENT_DATE()))
) src
ON tgt.patient_id = src.patient_id
WHEN MATCHED THEN UPDATE SET
    mrn = src.mrn,
    first_name = src.first_name,
    last_name = src.last_name,
    date_of_birth = src.date_of_birth,
    gender = src.gender,
    phone_number = src.phone_number,
    zip_code = src.zip_code,
    created_at = src.created_at,
    load_timestamp = src.load_timestamp,
    record_source = src.record_source,
    data_quality_status = src.data_quality_status
WHEN NOT MATCHED THEN INSERT (
    patient_id, mrn, first_name, last_name, date_of_birth, gender,
    phone_number, zip_code, created_at, load_timestamp,
    record_source, data_quality_status
) VALUES (
    src.patient_id, src.mrn, src.first_name, src.last_name,
    src.date_of_birth, src.gender, src.phone_number,
    src.zip_code, src.created_at, src.load_timestamp,
    src.record_source, src.data_quality_status
);

-- ============================================================================
-- STEP 6: APPLY GOVERNANCE TAGS
-- ============================================================================
ALTER TABLE MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PATIENTS
SET TAG 
    MEDICORE_GOVERNANCE_DB.TAGS.MEDALLION_LAYER = 'TRANSFORM',
    MEDICORE_GOVERNANCE_DB.TAGS.DATA_DOMAIN = 'CLINICAL',
    MEDICORE_GOVERNANCE_DB.TAGS.ENVIRONMENT = 'DEV';

ALTER TABLE MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PATIENTS_QUARANTINE
SET TAG 
    MEDICORE_GOVERNANCE_DB.TAGS.MEDALLION_LAYER = 'TRANSFORM',
    MEDICORE_GOVERNANCE_DB.TAGS.DATA_DOMAIN = 'CLINICAL',
    MEDICORE_GOVERNANCE_DB.TAGS.ENVIRONMENT = 'DEV';

-- ============================================================================
-- STEP 7: EXECUTION SUMMARY
-- ============================================================================
SELECT 
    'PATIENTS Transform Load Complete' AS status,
    'DEV' AS environment,
    CURRENT_TIMESTAMP() AS execution_timestamp,
    (SELECT COUNT(*) FROM MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PATIENTS) AS validated_record_count,
    (SELECT COUNT(*) 
       FROM MEDICORE_TRANSFORM_DB.DEV_CLINICAL.PATIENTS_QUARANTINE 
       WHERE load_timestamp >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
    ) AS quarantined_record_count_last_hour;