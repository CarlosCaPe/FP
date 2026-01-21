
/******************************************************************
* PROCEDURE	: DBO.[SNAP_CONOPS_FLEET_PIT_MACHINE_C]
* PURPOSE	: SNAP [SNAP_CONOPS_FLEET_PIT_MACHINE_C]
* NOTES		: 
* CREATED	: GGOSAL1
* SAMPLE	: EXEC DBO.[SNAP_CONOPS_FLEET_PIT_MACHINE_C] 
* MODIFIED DATE		AUTHOR		DESCRIPTION
*------------------------------------------------------------------
* {23 JUN 2025}		{GGOSAL1}	{INITIAL CREATED}
*******************************************************************/

CREATE  PROCEDURE [dbo].[SNAP_CONOPS_FLEET_PIT_MACHINE_C]
AS
BEGIN

-- Delete current shift data for BAG site
DELETE FROM BAG.FLEET_PIT_MACHINE_C
WHERE SHIFTINDEX = (
	SELECT SHIFTINDEX
	FROM [DBO].[SHIFT_INFO_V]
	WHERE SITEFLAG = 'BAG' AND SHIFTFLAG = 'CURR'
);
	
-- Insert new data into BAG.FLEET_PIT_MACHINE_C
INSERT INTO BAG.FLEET_PIT_MACHINE_C
SELECT 
	siteflag,
	SHIFTID,
	SHIFTINDEX,
	EquipmentID,
	EquipmentCategory,
	EQMTTYPE,
	StatusCode,
	StatusStart,
	TimeInState,
	CrewName,
	Location,
	Region,
	Operator,
	OperatorId,
	AssignedShovel,
	FieldX,
	FieldY,
	FieldZ,
	FieldVelocity
FROM BAG.FLEET_PIT_MACHINE_V
WHERE EquipmentID IS NOT NULL;

-- Delete old shift data (older than 3 shifts)
DELETE FROM BAG.FLEET_PIT_MACHINE_C
WHERE SHIFTINDEX < (
	SELECT SHIFTINDEX - 3
	FROM [DBO].[SHIFT_INFO_V]
	WHERE SITEFLAG = 'BAG' AND SHIFTFLAG = 'CURR'
);

--Update Table Monitoring
UPDATE [dbo].[DI_JOB_CONTROL_ENTRY_TS_BASE]
SET dw_load_ts = GETUTCDATE()
WHERE job_name = 'job_conops_fleet_pit_machine_c'


END


