# MediCore Health Systems - CoCo Session Context

Use this as the opening context block for every new CoCo session.

## Project
End-to-end enterprise Snowflake data platform for a fictional 
Healthcare & Life Sciences company — MediCore Health Systems.
Business Critical Snowflake account. HIPAA compliance context.

## Data Model (8 tables, 3 domains)
REFERENCE:  DIM_DEPARTMENTS, DIM_ICD10_CODES
CLINICAL:   PATIENTS, ENCOUNTERS, LAB_RESULTS, PROVIDERS  
BILLING:    CLAIMS, CLAIM_LINE_ITEMS

## Architecture
4-database medallion: RAW_DB → TRANSFORM_DB → ANALYTICS_DB → AI_READY_DB

## Roles (17 total - see rbac-design.md)
## Tags (12 total - see tag-taxonomy.md)