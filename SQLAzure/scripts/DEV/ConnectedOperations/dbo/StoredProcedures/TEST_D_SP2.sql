		
--USE [ConnectedOperations]
--GO

--DROP PROCEDURE IF EXISTS dbo.LoadAndHaulOverview_EquivalentFlatHaul_Get
--GO

--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO







/******************************************************************  

EXEC TEST_D_SP 'CURR', 'BAG'
EXEC TEST_D_SP 'CURR', 'MOR'
EXEC TEST_D_SP 'CURR', 'CVE'

*******************************************************************/ 
CREATE PROCEDURE [dbo].[TEST_D_SP2] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN 
SET XACT_ABORT ON;

	IF @SITE = 'CVE'
	BEGIN

		SELECT
			AVG(EFHShiftTarget) AS ShiftTarget,
			FIRST_VALUE(ShiftStartDateTime) OVER (ORDER BY ShiftStartDateTime ASC) AS StartDate,
			FIRST_VALUE(ShiftEndDateTime) OVER (ORDER BY ShiftEndDateTime ASC) AS EndDate,
			AVG(ShiftEFH) AS OverallEfh
		FROM [CER].[CONOPS_CER_EFH_V]
		WHERE shiftflag = @SHIFT
		--AND EFH <> 0
		GROUP BY ShiftStartDateTime, ShiftEndDateTime
 
		SELECT
			EFH AS [Value], 
			BreakByHour AS DateTime
		FROM [CER].[CONOPS_CER_EFH_V]
		WHERE shiftflag = @SHIFT
		ORDER BY BreakByHour DESC

	END
	
	ELSE IF @SITE = 'BAG'
	BEGIN

		BEGIN TRY 
			SELECT * FROM bag.TEST_D_V;
		END TRY

		BEGIN CATCH
		   SELECT 0
		END CATCH;

	END

	ELSE IF @SITE = 'MOR'
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

SET XACT_ABORT OFF;

END

