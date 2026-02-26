MEDICORE_TRANSFORM_DB.DEV_REFERENCE.DIM_ICD10_CODES

Key Findings:

- Single root cause — All 51 failures are missing descriptions
- Consistent rate (~25%) — Both categories have similar quarantine rates
- All codes start with 'A' — Suggests a specific batch/source issue
- Codes have valid structure — Format appears correct (e.g., A003, A020)

Recommendation

- The ~25% NULL description rate across categories suggests a systematic upstream data issue — likely incomplete data ingestion or a source system extraction problem for ICD-10 codes starting with 'A'. Recommend investigating the RAW layer ingestion pipeline.