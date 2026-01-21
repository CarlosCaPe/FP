


   
/******************************************************************
* PROCEDURE	: DBO.[SNAP_CONOPS_TRUCK_POPUP]
* PURPOSE	: SNAP [SNAP_CONOPS_TRUCK_POPUP]
* NOTES		: 
* CREATED	: GGOSAL1
* SAMPLE	: EXEC DBO.[SNAP_CONOPS_TRUCK_POPUP] 
* MODIFIED DATE		AUTHOR		DESCRIPTION
*------------------------------------------------------------------
* {23 JUN 2025}		{GGOSAL1}	{INITIAL CREATED}
*******************************************************************/

CREATE  PROCEDURE [dbo].[SNAP_CONOPS_TRUCK_POPUP]   
AS  
BEGIN  

--Truck Popup
EXEC DBO.[UPSERT_CONOPS_TRUCK_POPUP] 'BAG';
EXEC DBO.[UPSERT_CONOPS_TRUCK_POPUP] 'CER';
EXEC DBO.[UPSERT_CONOPS_TRUCK_POPUP] 'CHI';
EXEC DBO.[UPSERT_CONOPS_TRUCK_POPUP] 'CLI';
EXEC DBO.[UPSERT_CONOPS_TRUCK_POPUP] 'MOR';
EXEC DBO.[UPSERT_CONOPS_TRUCK_POPUP] 'SAF';
EXEC DBO.[UPSERT_CONOPS_TRUCK_POPUP] 'SIE';
EXEC DBO.[UPSERT_CONOPS_TRUCK_POPUP] 'ABR';
EXEC DBO.[UPSERT_CONOPS_TRUCK_POPUP] 'TYR';

--Update Table Monitoring Truck Popup
UPDATE [dbo].[DI_JOB_CONTROL_ENTRY_TS_BASE]
SET dw_load_ts = GETUTCDATE()
WHERE job_name = 'job_conops_truck_popup';


END
  



