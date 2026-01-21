		
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
CREATE PROCEDURE [dbo].[TEST_D_SP] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS

BEGIN TRY

	IF @SITE = 'CVE'
	BEGIN

		SELECT
			AVG(EFHShiftTarget) AS ShiftTarget,
			FIRST_VALUE(ShiftStartDateTime) OVER (ORDER BY ShiftStartDateTime ASC) AS StartDate,
			FIRST_VALUE(ShiftEndDateTime) OVER (ORDER BY ShiftEndDateTime ASC) AS EndDate,
			AVG(ShiftEFH) AS OverallEfh
		FROM [CER].[CONOPS_CER_EFH_V]
		WHERE shiftflag = 'CURR'
		--AND EFH <> 0
		GROUP BY ShiftStartDateTime, ShiftEndDateTime
 


	END
	
	ELSE IF @SITE = 'BAG'
	BEGIN

			SELECT * FROM bag.TEST_D_V;

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


	END



END TRY

BEGIN CATCH
	THROW
	--SELECT ERROR_NUMBER() AS ErrorNumber ,ERROR_MESSAGE() AS ErrorMessage;
END CATCH;


