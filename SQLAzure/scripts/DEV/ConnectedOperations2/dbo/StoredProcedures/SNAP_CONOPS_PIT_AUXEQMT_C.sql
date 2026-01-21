


   
/******************************************************************
* PROCEDURE	: DBO.[SNAP_CONOPS_PIT_AUXEQMT_C]
* PURPOSE	: SNAP [SNAP_CONOPS_PIT_AUXEQMT_C]
* NOTES		: 
* CREATED	: GGOSAL1
* SAMPLE	: EXEC DBO.[SNAP_CONOPS_PIT_AUXEQMT_C] 
* MODIFIED DATE		AUTHOR		DESCRIPTION
*------------------------------------------------------------------
* {23 JUN 2025}		{GGOSAL1}	{INITIAL CREATED}
*******************************************************************/

CREATE  PROCEDURE [dbo].[SNAP_CONOPS_PIT_AUXEQMT_C]   
AS  
BEGIN  

--Exec SP for each site
EXEC DBO.[UPSERT_CONOPS_PIT_AUXEQMT_C] 'CER';
EXEC DBO.[UPSERT_CONOPS_PIT_AUXEQMT_C] 'CHI';
EXEC DBO.[UPSERT_CONOPS_PIT_AUXEQMT_C] 'CLI';
EXEC DBO.[UPSERT_CONOPS_PIT_AUXEQMT_C] 'MOR';
EXEC DBO.[UPSERT_CONOPS_PIT_AUXEQMT_C] 'SAF';
EXEC DBO.[UPSERT_CONOPS_PIT_AUXEQMT_C] 'SIE';
EXEC DBO.[UPSERT_CONOPS_PIT_AUXEQMT_C] 'ABR';
EXEC DBO.[UPSERT_CONOPS_PIT_AUXEQMT_C] 'TYR';

--Update Table Monitoring
UPDATE [dbo].[DI_JOB_CONTROL_ENTRY_TS_BASE]
SET dw_load_ts = GETUTCDATE()
WHERE job_name = 'job_conops_pit_auxeqmt_c';


END
  



