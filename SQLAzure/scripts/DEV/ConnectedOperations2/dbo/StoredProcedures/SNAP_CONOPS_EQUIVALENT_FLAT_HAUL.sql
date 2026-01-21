

   
/******************************************************************
* PROCEDURE	: DBO.[SNAP_CONOPS_EQUIVALENT_FLAT_HAUL]
* PURPOSE	: SNAP [SNAP_CONOPS_EQUIVALENT_FLAT_HAUL]
* NOTES		: 
* CREATED	: GGOSAL1
* SAMPLE	: EXEC DBO.[SNAP_CONOPS_EQUIVALENT_FLAT_HAUL] 
* MODIFIED DATE		AUTHOR		DESCRIPTION
*------------------------------------------------------------------
* {23 JUN 2025}		{GGOSAL1}	{INITIAL CREATED}
*******************************************************************/

CREATE  PROCEDURE [dbo].[SNAP_CONOPS_EQUIVALENT_FLAT_HAUL]   
AS  
BEGIN  

INSERT INTO [dbo].[Shovel_Equivalent_Flat_Haul] 
SELECT
	a.siteflag,
	a.shiftindex,
	b.excav,
	b.EFH,
	GETUTCDATE() AS [UTC_CREATED_DATE]
FROM(
	SELECT
		site_code as siteflag,
		max(shiftindex) shiftindex
	FROM dbo.delta_c 
	group by site_code
	) a
LEFT JOIN (
	SELECT 
		site_code,
		shiftindex,
		excav,
		avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) AS EFH
	FROM dbo.delta_c with (nolock)
	group by shiftindex,site_code,excav
	) b
	ON a.siteflag = b.SITE_CODE 
		AND a.shiftindex = b.SHIFTINDEX
WHERE excav IS NOT NULL;

INSERT INTO [dbo].[Equivalent_Flat_Haul] 

SELECT
	a.siteflag,
	a.shiftindex,
	b.EFH,
	GETUTCDATE() AS [UTC_CREATED_DATE]
FROM (
	SELECT
		site_code as siteflag,
		max(shiftindex) shiftindex
	FROM dbo.delta_c 
	group by site_code
	) a
LEFT JOIN (
	SELECT 
		site_code,
		shiftindex,
		avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) AS EFH
	FROM dbo.delta_c with (nolock)
	group by shiftindex,site_code
	) b
	ON a.siteflag = b.SITE_CODE 
		AND a.shiftindex = b.SHIFTINDEX;

--Update Table Monitoring
UPDATE [dbo].[DI_JOB_CONTROL_ENTRY_TS_BASE]
SET dw_load_ts = GETUTCDATE()
WHERE job_name = 'job_conops_equivalent_flat_haul';


END
  


