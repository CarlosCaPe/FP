

/******************************************************************  
* PROCEDURE	: dbo.EOS_ShiftNotes_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 21 Jun 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_ShiftNotes_Get 'PREV', 'TYR', null, null,1
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {21 Jun 2023}		{sxavier}		{Initial Created} 
* {07 Dec 2023}		{lwasini}		{Add Daily Summary} 
* {30 Jan 2024}		{lwasini}		{Add TYR & ABR}
* {11 Oct 2024}		{sxavier}		{Remove join to GER}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_ShiftNotes_Get] 
(	
	@SHIFT CHAR(4),
	@SITE CHAR(3),
	@SHIFTNAME VARCHAR(16),
	@SHIFTDATE DATETIME,
	@DAILY INT
)
AS                        
BEGIN    

BEGIN TRY

	DECLARE @ShiftId VARCHAR(16)
	SET @ShiftId = CASE WHEN @SHIFTNAME = 'NIGHT SHIFT' THEN CONCAT(RIGHT(REPLACE(CAST(@SHIFTDATE AS DATE), '-', ''), 6), '002')
		ELSE CONCAT(RIGHT(REPLACE(CAST(@SHIFTDATE AS DATE), '-', ''), 6), '001') END
		
	IF @SITE = 'BAG' 
	BEGIN
		
		IF @DAILY = 0
		BEGIN
		IF @SHIFT IS NULL
			BEGIN
				SELECT
					B.ShiftNotesId,
					B.Category,
					B.ShiftNotes,
					B.UtcModifiedDate,
					B.ModifiedBy,
					0 AS IsFromLogbook
				FROM 
					[dbo].[CONOPS_EOS_SHIFTNOTES_V] B
				WHERE
					B.ShiftId = @ShiftId AND
					B.SiteCode = 'BAG'

				UNION

				SELECT
					'00000000-0000-0000-0000-000000000000' AS ShiftNotesId,
					CASE 
						WHEN A.AreaCode = '0' THEN 'OTHER' 
						WHEN A.AreaCode = '1' THEN 'STOCKPILES' 
						WHEN A.AreaCode = '2' THEN 'HR' 
						WHEN A.AreaCode = '3' THEN 'SAFETY' 
						WHEN A.AreaCode = '4' THEN 'ENVIRONMENTAL' 
						WHEN A.AreaCode = '5' THEN 'CRUSHER' 
					END AS Category,
					A.[Description],
					A.UtcModifiedDate,
					A.ModifiedBy,
					1 AS IsFromLogbook
				FROM
					dbo.CONOPS_LOGBOOK_V A
				WHERE
					A.SiteCode =  @SITE AND
					A.ShiftId = @ShiftId AND
					A.LogbookTypeCode = 'CO' AND
					A.ExtendedProperty3 = 1
				ORDER BY Category, UtcModifiedDate
			END
		ELSE
			BEGIN
				SELECT
					B.ShiftNotesId,
					B.Category,
					B.ShiftNotes,
					B.UtcModifiedDate,
					B.ModifiedBy,
					0 AS IsFromLogbook
				FROM 
					[bag].[CONOPS_BAG_SHIFT_INFO_V] A
					INNER JOIN [dbo].[CONOPS_EOS_SHIFTNOTES_V] B ON A.ShiftId = B.ShiftId AND B.SiteCode = 'BAG'
				WHERE
					A.ShiftFlag = @SHIFT

				UNION

				SELECT
					'00000000-0000-0000-0000-000000000000' AS ShiftNotesId,
					CASE 
						WHEN A.AreaCode = '0' THEN 'OTHER' 
						WHEN A.AreaCode = '1' THEN 'STOCKPILES' 
						WHEN A.AreaCode = '2' THEN 'HR' 
						WHEN A.AreaCode = '3' THEN 'SAFETY' 
						WHEN A.AreaCode = '4' THEN 'ENVIRONMENTAL' 
						WHEN A.AreaCode = '5' THEN 'CRUSHER' 
					END AS Category,
					A.[Description],
					A.UtcModifiedDate,
					A.ModifiedBy,
					1 AS IsFromLogbook
				FROM
					dbo.CONOPS_LOGBOOK_V A
					INNER JOIN [bag].[CONOPS_BAG_SHIFT_INFO_V] B ON A.ShiftId  = B.ShiftId
				WHERE
					A.SiteCode =  @SITE AND
					B.ShiftFlag = @SHIFT AND
					A.LogbookTypeCode = 'CO' AND
					A.ExtendedProperty3 = 1
				ORDER BY Category, UtcModifiedDate
			END
			END

			ELSE IF @DAILY = 1
		BEGIN
		IF @SHIFT IS NULL
			BEGIN
				SELECT
					B.ShiftNotesId,
					B.Category,
					B.ShiftNotes,
					B.UtcModifiedDate,
					B.ModifiedBy,
					0 AS IsFromLogbook
				FROM 
					[dbo].[CONOPS_EOS_SHIFTNOTES_V] B
				WHERE
					B.ShiftId = @ShiftId AND
					B.SiteCode = 'BAG'

				UNION

				SELECT
					'00000000-0000-0000-0000-000000000000' AS ShiftNotesId,
					CASE 
						WHEN A.AreaCode = '0' THEN 'OTHER' 
						WHEN A.AreaCode = '1' THEN 'STOCKPILES' 
						WHEN A.AreaCode = '2' THEN 'HR' 
						WHEN A.AreaCode = '3' THEN 'SAFETY' 
						WHEN A.AreaCode = '4' THEN 'ENVIRONMENTAL' 
						WHEN A.AreaCode = '5' THEN 'CRUSHER' 
					END AS Category,