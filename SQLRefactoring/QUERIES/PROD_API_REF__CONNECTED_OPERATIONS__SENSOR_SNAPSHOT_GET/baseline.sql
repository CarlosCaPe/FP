-- Baseline example call for this table function
SELECT *
FROM TABLE(PROD_API_REF.CONNECTED_OPERATIONS.SENSOR_SNAPSHOT_GET(
  'MOR',
  FALSE,
  ARRAY_CONSTRUCT(''),
  ARRAY_CONSTRUCT(
    'CR03_CRUSH_OUT_TIME',
    'PE_MOR_CC_MflPileTonnage',
    'PE_MOR_CC_MillPileTonnage'
  )
));
