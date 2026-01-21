




/******************************************************************  
* PROCEDURE	: dbo.EOS_DrillOperatorStartSummary_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 15 Jun 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_DrillOperatorStartSummary_Get 'CURR', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {15 Jun 2023}		{lwasini}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_DrillOperatorStartSummary_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		SELECT Drill_ID,
			   Average_First_Drill AS FirstTimeHoleDrilled,
			   Holes_Drilled AS HolesDrilled
		FROM [bag].[CONOPS_BAG_DB_DRILL_SCORE_V]
		WHERE shiftflag = @SHIFT;

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT Drill_ID,
			   Average_First_Drill AS FirstTimeHoleDrilled,
			   Holes_Drilled AS HolesDrilled
		FROM [cer].[CONOPS_CER_DB_DRILL_SCORE_V]
		WHERE shiftflag = @SHIFT;

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT Drill_ID,
			   Average_First_Drill AS FirstTimeHoleDrilled,
			   Holes_Drilled AS HolesDrilled
		FROM [chi].[CONOPS_CHI_DB_DRILL_SCORE_V]
		WHERE shiftflag = @SHIFT;

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT Drill_ID,
			   Average_First_Drill AS FirstTimeHoleDrilled,
			   Holes_Drilled AS HolesDrilled
		FROM [cli].[CONOPS_CLI_DB_DRILL_SCORE_V]
		WHERE shiftflag = @SHIFT;

	END

	ELSE IF @SITE = 'MOR'
	BEGIN

		SELECT Drill_ID,
			   Average_First_Drill AS FirstTimeHoleDrilled,
			   Holes_Drilled AS HolesDrilled
		FROM [mor].[CONOPS_MOR_DB_DRILL_SCORE_V]
		WHERE shiftflag = @SHIFT;

	END

	ELSE IF @SITE = 'SAM'
	BEGIN

		SELECT Drill_ID,
			   Average_First_Drill AS FirstTimeHoleDrilled,
			   Holes_Drilled AS HolesDrilled
		FROM [saf].[CONOPS_SAF_DB_DRILL_SCORE_V]
		WHERE shiftflag = @SHIFT;

	END

	ELSE IF @SITE = 'SIE'
	BEGIN

		SELECT Drill_ID,
			   Average_First_Drill AS FirstTimeHoleDrilled,
			   Holes_Drilled AS HolesDrilled
		FROM [sie].[CONOPS_SIE_DB_DRILL_SCORE_V]
		WHERE shiftflag = @SHIFT;

	END


END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE();
END CATCH

END







