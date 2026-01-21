CREATE VIEW [dbo].[ZZZ_CONOPS_EOS_SHIFTNOTES_V_NEW] AS



/******************************************************************  
* VIEW	    : dbo.CONOPS_EOS_SHIFTNOTES_V
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 21 Jun 2023
* SAMPLE	: 
	1. SELECT * FROM dbo.CONOPS_EOS_SHIFTNOTES_V
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {21 Jun 2023}		{sxavier}		{Initial Created}
*******************************************************************/ 


CREATE VIEW [dbo].[CONOPS_EOS_SHIFTNOTES_V_NEW]
AS
	SELECT
		A.ShiftNotesId,
		A.SiteCode,
		A.[Shift],
		A.ShiftDate,
		A.[Key],
		A.ShiftNotes,
		A.CreatedBy,
		B.FULL_NAME AS CreatedByName,
		A.UtcCreatedDate,
		A.ModifiedBy,
		B.FULL_NAME AS ModifiedByName,
		A.UtcModifiedDate,
		CASE WHEN [Shift] = 'NIGHT SHIFT' THEN CONCAT(RIGHT(REPLACE(CAST(ShiftDate AS DATE), '-', ''), 6), '002')
		ELSE CONCAT(RIGHT(REPLACE(CAST(ShiftDate AS DATE), '-', ''), 6), '001') END AS ShiftId
	FROM [dbo].[ShiftNotes] A
	LEFT JOIN [GlobalEntityRepository].[dbo].[vw_public_employee_data] B
	ON A.CreatedBy = B.employee_id
	LEFT JOIN [GlobalEntityRepository].[dbo].[vw_public_employee_data] C
	ON A.ModifiedBy = C.employee_id

