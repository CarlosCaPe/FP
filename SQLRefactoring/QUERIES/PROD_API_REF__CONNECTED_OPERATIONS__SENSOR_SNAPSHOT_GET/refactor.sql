-- Refactor (initially same as baseline)
SELECT *
FROM TABLE(SANDBOX_DATA_ENGINEER.CCARRILL2.SENSOR_SNAPSHOT_GET(
  'MOR',
  FALSE,
  ARRAY_CONSTRUCT(''),
  ARRAY_CONSTRUCT(
    'CR03_CRUSH_OUT_TIME',
    'PE_MOR_CC_MflPileTonnage',
    'PE_MOR_CC_MillPileTonnage'
  )
));
