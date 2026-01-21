CREATE VIEW [bag2].[MSHIST_OPERATOR] AS



CREATE VIEW [bag2].[MSHIST_OPERATOR]
AS

SELECT 
    'BAG' AS SITE_CODE,
    CONCAT(RIGHT(SUBSTRING(REPORTING_DATE, 1, 8), 6), '00', 
        CASE 
            WHEN shifttype = 0 THEN 1
            WHEN shifttype = 1 THEN 2 
            ELSE NULL
        END) AS SHIFT_ID,
    P.PERSONNELID AS OPERATOR_ID,
    P.NAME AS OPERATOR_NAME,
    L.NAME AS LOC_NAME,
    CR.NAME AS CREW_NAME
FROM [ConnectedOperations].[bag2].[PERSON] P WITH (NOLOCK)
LEFT JOIN [ConnectedOperations].[bag2].[CYCLE] C WITH (NOLOCK)
    ON P.PERSON_OID = C.PRIMARYOPERATOR
LEFT JOIN [ConnectedOperations].[bag2].[LOCATION] L WITH (NOLOCK)
    ON C.SOURCELOCATION = L.LOCATION_OID 
LEFT JOIN [ConnectedOperations].[bag2].[PERSON_CREW] PC WITH (NOLOCK)
    ON P.PERSON_OID = PC.PERSON_OID
LEFT JOIN [ConnectedOperations].[bag2].[CREW] CR WITH (NOLOCK)
    ON CR.OID = PC.CREW_OID
LEFT JOIN [ConnectedOperations].[bag2].[SHIFT] S WITH (NOLOCK)
    ON C.ENDTIME_UTC >= S.STARTTIME_UTC
    AND C.ENDTIME_UTC <= S.ENDTIME_UTC;



