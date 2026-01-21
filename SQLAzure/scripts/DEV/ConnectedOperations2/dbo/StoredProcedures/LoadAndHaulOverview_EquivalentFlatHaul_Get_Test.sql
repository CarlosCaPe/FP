

CREATE PROCEDURE [dbo].[LoadAndHaulOverview_EquivalentFlatHaul_Get_Test] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS  
/*
USE ConnectedOperations2
SELECT * FROM saf.shift_info
SELECT * FROM saf.shift_info_backup


DROP TABLE saf.shift_info

SELECT * INTO saf.shift_info FROM saf.shift_info_backup

EXEC [dbo].[LoadAndHaulOverview_EquivalentFlatHaul_Get_Test] 'PREV', 'SAM'
EXEC [dbo].[LoadAndHaulOverview_EquivalentFlatHaul_Get_Test] 'PREV', 'MOR'


SELECT name, database_id, state_desc
FROM master.sys.databases
order by name

SELECT * FROM [SAF].[CONOPS_SAF_EFH_V]
EXEC [dbo].[LoadAndHaulOverview_EquivalentFlatHaul_Get_Test_Config] 'PREV', 'SAM'

EXEC [dbo].[LoadAndHaulOverview_EquivalentFlatHaul_Get_Test_Config] 'PREV', 'MOR'


EXEC [dbo].[LoadAndHaulOverview_EquivalentFlatHaul_Get] 'PREV', 'MOR'


*/
BEGIN

BEGIN TRY

	IF @SITE = 'MOR' AND EXISTS (SELECT * FROM MOROperational.INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'SHIFTShiftdump')
	BEGIN

		SELECT
			AVG(EFHShiftTarget) AS ShiftTarget,
			FIRST_VALUE(ShiftStartDateTime) OVER (ORDER BY ShiftStartDateTime ASC) AS StartDate,
			FIRST_VALUE(ShiftEndDateTime) OVER (ORDER BY ShiftEndDateTime ASC) AS EndDate,
			AVG(ShiftEFH) AS OverallEfh
		FROM [MOR].[CONOPS_MOR_EFH_V]
		WHERE shiftflag = @SHIFT
		--AND EFH <> 0
		GROUP BY ShiftStartDateTime, ShiftEndDateTime
 
		SELECT
			EFH AS [Value], 
			BreakByHour AS DateTime
		FROM [MOR].[CONOPS_MOR_EFH_V]
		WHERE shiftflag = @SHIFT
		ORDER BY BreakByHour DESC

	END

	ELSE IF @SITE = 'SAM' AND EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'SAF' AND TABLE_NAME = 'SHIFT_INFO')
	BEGIN

		SELECT
			AVG(EFHShiftTarget) AS ShiftTarget,
			FIRST_VALUE(ShiftStartDateTime) OVER (ORDER BY ShiftStartDateTime ASC) AS StartDate,
			FIRST_VALUE(ShiftEndDateTime) OVER (ORDER BY ShiftEndDateTime ASC) AS EndDate,
			AVG(ShiftEFH) AS OverallEfh
		FROM [SAF].[CONOPS_SAF_EFH_V]
		WHERE shiftflag = @SHIFT
		--AND EFH <> 0
		GROUP BY ShiftStartDateTime, ShiftEndDateTime
 
		SELECT
			EFH AS [Value], 
			BreakByHour AS DateTime
		FROM [SAF].[CONOPS_SAF_EFH_V]
		WHERE shiftflag = @SHIFT
		ORDER BY BreakByHour DESC

	END

	ELSE IF @SITE = 'SIE' AND EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'SIE' AND TABLE_NAME = 'SHIFT_INFO')
	BEGIN

		SELECT
			AVG(EFHShiftTarget) AS ShiftTarget,
			FIRST_VALUE(ShiftStartDateTime) OVER (ORDER BY ShiftStartDateTime ASC) AS StartDate,
			FIRST_VALUE(ShiftEndDateTime) OVER (ORDER BY ShiftEndDateTime ASC) AS EndDate,
			AVG(ShiftEFH) AS OverallEfh
		FROM [SIE].[CONOPS_SIE_EFH_V]
		WHERE shiftflag = @SHIFT
		--AND EFH <> 0
		GROUP BY ShiftStartDateTime, ShiftEndDateTime
 
		SELECT
			EFH AS [Value], 
			BreakByHour AS DateTime
		FROM [SIE].[CONOPS_SIE_EFH_V]
		WHERE shiftflag = @SHIFT
		ORDER BY BreakByHour DESC

	END

END TRY
BEGIN CATCH
-- Handle the error gracefully
--PRINT 'Table does not exist or another error occurred.';

-- Optional: log error details
PRINT ERROR_MESSAGE();
END CATCH

END








