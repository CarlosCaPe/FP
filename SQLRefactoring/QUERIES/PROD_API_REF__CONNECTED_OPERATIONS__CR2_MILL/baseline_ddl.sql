create or replace view CR2_MILL(
	SHIFTINDEX,
	SITEFLAG,
	COMPONENT,
	SENSOR_VALUE,
	UTC_CREATED_DATE
) as
SELECT (SELECT MAX(ShiftIndex) FROM CONNECTED_OPERATIONS.lh_shift_date WHERE site_code = 'MOR') ShiftIndex,
       'MOR' siteflag,
       CASE TAG_NAME
            WHEN 'CR03_CRUSH_OUT_TIME' THEN 'CrusherCR2ToMill'
            WHEN 'PE_MOR_CC_MflPileTonnage' THEN 'CrusherMFLIOS'
            WHEN 'PE_MOR_CC_MillPileTonnage' THEN 'CrusherMillIOS'
       END AS Component,
       SENSOR_VALUE,
	   CAST(CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP) AS TIMESTAMP_NTZ) AS UTC_CREATED_DATE
FROM TABLE(PROD_API_REF.CONNECTED_OPERATIONS.SENSOR_SNAPSHOT_GET('MOR', False,
                                            array_construct(''),
                                            array_construct('CR03_CRUSH_OUT_TIME',
                                                            'PE_MOR_CC_MflPileTonnage',
                                                            'PE_MOR_CC_MillPileTonnage')));
