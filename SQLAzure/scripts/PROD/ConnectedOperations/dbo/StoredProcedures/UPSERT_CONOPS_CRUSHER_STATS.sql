






/******************************************************************    
* PROCEDURE : [DBO].[UPSERT_CONOPS_CRUSHER_STATS]   
* PURPOSE : Upsert [UPSERT_CONOPS_CRUSHER_STATS]  
* NOTES     :   
* CREATED : mfahmi  
* SAMPLE    : EXEC DBO.[UPSERT_CONOPS_CRUSHER_STATS]  
* MODIFIED DATE  AUTHOR    DESCRIPTION    
*------------------------------------------------------------------    
* {05 Jun 2023}  {mfahmi}   {Initial Created}  
* {05 DEC 2023}  {GGOSAL1}  {Add: update table monitoring}
*******************************************************************/    
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_CRUSHER_STATS]   
AS  
BEGIN 
 
INSERT INTO [dbo].[CRUSHER_STATS]

SELECT siteflag,
SHIFTINDEX,
CrusherLoc,
NoOfTruckWaiting,
GeneratedUTCDate
FROM [bag].[crusher_stats_v] 

UNION ALL

SELECT siteflag,
SHIFTINDEX,
CrusherLoc,
NoOfTruckWaiting,
GeneratedUTCDate
FROM [cer].[crusher_stats_v]

UNION ALL

SELECT siteflag,
SHIFTINDEX,
CrusherLoc,
NoOfTruckWaiting,
GeneratedUTCDate
FROM [chi].[crusher_stats_v]

UNION ALL

SELECT siteflag,
SHIFTINDEX,
CrusherLoc,
NoOfTruckWaiting,
GeneratedUTCDate
FROM [cli].[crusher_stats_v]

UNION ALL

SELECT siteflag,
SHIFTINDEX,
CrusherLoc,
NoOfTruckWaiting,
GeneratedUTCDate
FROM [mor].[crusher_stats_v]

UNION ALL

SELECT siteflag,
SHIFTINDEX,
CrusherLoc,
NoOfTruckWaiting,
GeneratedUTCDate
FROM [saf].[crusher_stats_v]

UNION ALL

SELECT siteflag,
SHIFTINDEX,
CrusherLoc,
NoOfTruckWaiting,
GeneratedUTCDate
FROM [sie].[crusher_stats_v]

UNION ALL

SELECT siteflag,
SHIFTINDEX,
CrusherLoc,
NoOfTruckWaiting,
GeneratedUTCDate
FROM [abr].[crusher_stats_v];

--Update Table Monitoring
UPDATE [dbo].[DI_JOB_CONTROL_ENTRY_TS_BASE]
SET dw_load_ts = GETUTCDATE()
WHERE job_name = 'job_conops_crusher_stats'

END

