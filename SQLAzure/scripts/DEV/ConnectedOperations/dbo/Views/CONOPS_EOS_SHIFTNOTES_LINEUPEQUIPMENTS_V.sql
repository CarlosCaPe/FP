CREATE VIEW [dbo].[CONOPS_EOS_SHIFTNOTES_LINEUPEQUIPMENTS_V] AS










/******************************************************************  
* VIEW	    : dbo.CONOPS_EOS_SHIFTNOTES_LINEUPEQUIPMENTS_V
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 21 Jun 2023
* SAMPLE	: 
	1. SELECT * FROM dbo.CONOPS_EOS_SHIFTNOTES_LINEUPEQUIPMENTS_V
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {21 Jun 2023}		{sxavier}		{Initial Created}
*******************************************************************/ 


CREATE VIEW [dbo].[CONOPS_EOS_SHIFTNOTES_LINEUPEQUIPMENTS_V]
AS
	SELECT
		A.Equipment,
		A.SiteCode,
		A.[Shift],
		A.ShiftDate,
		A.EquipmentAvailableShiftStart,
		A.ShiftNotes,
		A.CreatedBy,
		A.UtcCreatedDate,
		A.ModifiedBy,
		A.UtcModifiedDate,
		CASE WHEN [Shift] = 'NIGHT SHIFT' THEN CONCAT(RIGHT(REPLACE(CAST(ShiftDate AS DATE), '-', ''), 6), '002')
		ELSE CONCAT(RIGHT(REPLACE(CAST(ShiftDate AS DATE), '-', ''), 6), '001') END AS ShiftId
	FROM [dbo].[ShiftNotesLineUpEquipments] A (NOLOCK)

