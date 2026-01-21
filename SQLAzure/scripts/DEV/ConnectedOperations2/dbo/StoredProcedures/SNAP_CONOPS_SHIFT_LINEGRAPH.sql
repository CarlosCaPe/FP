


/******************************************************************
* PROCEDURE	: DBO.[SNAP_CONOPS_SHIFT_LINEGRAPH]
* PURPOSE	: SNAP [SNAP_CONOPS_SHIFT_LINEGRAPH]
* NOTES		: 
* CREATED	: GGOSAL1
* SAMPLE	: EXEC DBO.[SNAP_CONOPS_SHIFT_LINEGRAPH] 
* MODIFIED DATE		AUTHOR		DESCRIPTION
*------------------------------------------------------------------
* {23 JUN 2025}		{GGOSAL1}	{INITIAL CREATED}
*******************************************************************/

CREATE  PROCEDURE [dbo].[SNAP_CONOPS_SHIFT_LINEGRAPH]
AS
BEGIN

INSERT INTO [dbo].[Shift_Line_Graph]
SELECT
	siteflag,
	shiftid,
	shovelid,
	TotalMaterialMined,
	TotalMaterialMoved,
	Mill,
	Waste,
	CrushLeach,
	ROM,
	GETUTCDATE() AS UTC_CREATED_DATE
FROM [dbo].[CONOPS_SHIFT_LINEGRAPH_SNAPSHOT_V]
WHERE shovelid IS NOT NULL
	AND shiftid IS NOT NULL;

INSERT INTO [dbo].[Material_Delivered]
SELECT
	siteflag,
	shiftid,
	TruckId,
	TotalMaterialDelivered,
	GETUTCDATE() AS UTC_CREATED_DATE
FROM [dbo].[CONOPS_MATERIAL_DELIVERED_V]
WHERE shiftid IS NOT NULL;

INSERT INTO [dbo].[Material_Mined]
SELECT
	siteflag,
	shiftid,
	shovelid,
	TotalMaterialMined,
	TotalMaterialMoved,
	GETUTCDATE() AS UTC_CREATED_DATE
FROM [dbo].[CONOPS_MATERIAL_MINED_V]
WHERE shiftid IS NOT NULL;


--Update Table Monitoring
UPDATE [dbo].[DI_JOB_CONTROL_ENTRY_TS_BASE]
SET dw_load_ts = GETUTCDATE()
WHERE job_name = 'job_conops_shift_linegraph_snapshot'

END

