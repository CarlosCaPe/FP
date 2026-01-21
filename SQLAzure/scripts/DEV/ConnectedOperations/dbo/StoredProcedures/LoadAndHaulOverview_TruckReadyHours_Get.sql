

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_TruckReadyHours_Get
* PURPOSE	: display number of truck drivers in the bottom 25% of ready hours through current time in the shift
* NOTES		: 
* CREATED	: jrodulfa, 02 Dec 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_TruckReadyHours_Get 'CURR', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {12 Mar 2025}		{ggosal1}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_TruckReadyHours_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		SELECT 
			ISNULL(CAST(COUNT(*) * 0.25 AS INT), 0) AS Bottom25TruckDriver
		FROM BAG.CONOPS_BAG_OPERATOR_TRUCK_V
		WHERE TruckID <> 'NONE'
			AND SHIFTFLAG = @SHIFT

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT 
			ISNULL(CAST(COUNT(*) * 0.25 AS INT), 0) AS Bottom25TruckDriver
		FROM CER.CONOPS_CER_OPERATOR_TRUCK_V
		WHERE TruckID <> 'NONE'
			AND SHIFTFLAG = @SHIFT

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT 
			ISNULL(CAST(COUNT(*) * 0.25 AS INT), 0) AS Bottom25TruckDriver
		FROM CHI.CONOPS_CHI_OPERATOR_TRUCK_V
		WHERE TruckID <> 'NONE'
			AND SHIFTFLAG = @SHIFT

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT
			ISNULL(CAST(COUNT(*) * 0.25 AS INT), 0) AS Bottom25TruckDriver
		FROM CLI.CONOPS_CLI_OPERATOR_TRUCK_V
		WHERE TruckID <> 'NONE'
			AND SHIFTFLAG = @SHIFT

	END

	ELSE IF @SITE = 'MOR'
	BEGIN

		SELECT
			ISNULL(CAST(COUNT(*) * 0.25 AS INT), 0) AS Bottom25TruckDriver
		FROM MOR.CONOPS_MOR_OPERATOR_TRUCK_V
		WHERE TruckID <> 'NONE'
			AND SHIFTFLAG = @SHIFT

	END

	ELSE IF @SITE = 'SAM'
	BEGIN

		SELECT
			ISNULL(CAST(COUNT(*) * 0.25 AS INT), 0) AS Bottom25TruckDriver
		FROM SAF.CONOPS_SAF_OPERATOR_TRUCK_V
		WHERE TruckID <> 'NONE'
			AND SHIFTFLAG = @SHIFT

	END

	ELSE IF @SITE = 'SIE'
	BEGIN

		SELECT
			ISNULL(CAST(COUNT(*) * 0.25 AS INT), 0) AS Bottom25TruckDriver
		FROM SIE.CONOPS_SIE_OPERATOR_TRUCK_V
		WHERE TruckID <> 'NONE'
			AND SHIFTFLAG = @SHIFT

	END

	ELSE IF @SITE = 'TYR'
	BEGIN

		SELECT
			ISNULL(CAST(COUNT(*) * 0.25 AS INT), 0) AS Bottom25TruckDriver
		FROM TYR.CONOPS_TYR_OPERATOR_TRUCK_V
		WHERE TruckID <> 'NONE'
			AND SHIFTFLAG = @SHIFT

	END


	ELSE IF @SITE = 'ABR'
	BEGIN

		SELECT 
			ISNULL(CAST(COUNT(*) * 0.25 AS INT), 0) AS Bottom25TruckDriver
		FROM ABR.CONOPS_ABR_OPERATOR_TRUCK_V
		WHERE TruckID <> 'NONE'
			AND SHIFTFLAG = @SHIFT

	END


END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE();
END CATCH

END








