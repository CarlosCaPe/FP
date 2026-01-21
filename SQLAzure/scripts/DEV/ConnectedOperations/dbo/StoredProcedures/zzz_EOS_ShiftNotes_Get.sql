



/******************************************************************  
* PROCEDURE	: dbo.EOS_ShiftNotes_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 21 Jun 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_ShiftNotes_Get 'CURR', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {21 Jun 2023}		{sxavier}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[zzz_EOS_ShiftNotes_Get] 
(	
	@Shift CHAR(4),
	@Site CHAR(3)
)
AS                        
BEGIN    


	IF @Site = 'BAG'
	BEGIN
		SELECT
			B.ShiftNotesId,
			B.Category,
			B.ShiftNotes,
			B.UtcModifiedDate,
			B.ModifiedByName
		FROM 
			[bag].[CONOPS_BAG_SHIFT_INFO_V] A
			INNER JOIN [dbo].[CONOPS_EOS_SHIFTNOTES_V] B ON A.ShiftId = B.ShiftId AND B.SiteCode = 'BAG'
		WHERE
			A.ShiftFlag = @Shift
		ORDER BY B.Category, B.UtcModifiedDate
	END

	ELSE IF @Site = 'CVE'
	BEGIN
		SELECT
			B.ShiftNotesId,
			B.Category,
			B.ShiftNotes,
			B.UtcModifiedDate,
			B.ModifiedByName
		FROM 
			[cer].[CONOPS_CER_SHIFT_INFO_V] A
			INNER JOIN [dbo].[CONOPS_EOS_SHIFTNOTES_V] B ON A.ShiftId = B.ShiftId AND B.SiteCode = 'CVE'
		WHERE
			A.ShiftFlag = @Shift
		ORDER BY B.Category, B.UtcModifiedDate
	END

	ELSE IF @Site = 'CHN'
	BEGIN
		SELECT
			B.ShiftNotesId,
			B.Category,
			B.ShiftNotes,
			B.UtcModifiedDate,
			B.ModifiedByName
		FROM 
			[chi].[CONOPS_CHI_SHIFT_INFO_V] A
			INNER JOIN [dbo].[CONOPS_EOS_SHIFTNOTES_V] B ON A.ShiftId = B.ShiftId AND B.SiteCode = 'CHN'
		WHERE
			A.ShiftFlag = @Shift
		ORDER BY B.Category, B.UtcModifiedDate
	END

	ELSE IF @Site = 'CMX'
	BEGIN
		SELECT
			B.ShiftNotesId,
			B.Category,
			B.ShiftNotes,
			B.UtcModifiedDate,
			B.ModifiedByName
		FROM 
			[cli].[CONOPS_CLI_SHIFT_INFO_V] A
			INNER JOIN [dbo].[CONOPS_EOS_SHIFTNOTES_V] B ON A.ShiftId = B.ShiftId AND B.SiteCode = 'CMX'
		WHERE
			A.ShiftFlag = @Shift
		ORDER BY B.Category, B.UtcModifiedDate
	END

	ELSE IF @Site = 'MOR'
	BEGIN
		SELECT
			B.ShiftNotesId,
			B.Category,
			B.ShiftNotes,
			B.UtcModifiedDate,
			B.ModifiedByName
		FROM 
			[mor].[CONOPS_MOR_SHIFT_INFO_V] A
			INNER JOIN [dbo].[CONOPS_EOS_SHIFTNOTES_V] B ON A.ShiftId = B.ShiftId AND B.SiteCode = 'MOR'
		WHERE
			A.ShiftFlag = @Shift
		ORDER BY B.Category, B.UtcModifiedDate
	END

	ELSE IF @Site = 'SAM'
	BEGIN
		SELECT
			B.ShiftNotesId,
			B.Category,
			B.ShiftNotes,
			B.UtcModifiedDate,
			B.ModifiedByName
		FROM 
			[saf].[CONOPS_SAF_SHIFT_INFO_V] A
			INNER JOIN [dbo].[CONOPS_EOS_SHIFTNOTES_V] B ON A.ShiftId = B.ShiftId AND B.SiteCode = 'SAM'
		WHERE
			A.ShiftFlag = @Shift
		ORDER BY B.Category, B.UtcModifiedDate
	END

	ELSE IF @Site = 'SIE'
	BEGIN
		SELECT
			B.ShiftNotesId,
			B.Category,
			B.ShiftNotes,
			B.UtcModifiedDate,
			B.ModifiedByName
		FROM 
			[sie].[CONOPS_SIE_SHIFT_INFO_V] A
			INNER JOIN [dbo].[CONOPS_EOS_SHIFTNOTES_V] B ON A.ShiftId = B.ShiftId AND B.SiteCode = 'SIE'
		WHERE
			A.ShiftFlag = @Shift
		ORDER BY B.Category, B.UtcModifiedDate
	END

END

