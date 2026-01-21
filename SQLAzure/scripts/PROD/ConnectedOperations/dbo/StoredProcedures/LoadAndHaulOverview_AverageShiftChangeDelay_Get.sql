



/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_AverageShiftChangeDelay_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 30 Nov 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_AverageShiftChangeDelay_Get 'PREV', 'TYR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {30 Nov 2022}		{jrodulfa}		{Initial Created} 
* {02 Dec 2022}		{sxavier}		{Dispaly only needed data} 
* {11 Jan 2022}		{jrodulfa}		{Implement Bagdad data} 
* {18 Jan 2022}		{jrodulfa}		{Implement Safford data} 
* {27 Jan 2023}		{jrodulfa}		{Change SAF sitecode to SAM.}
* {03 Feb 2023}		{jrodulfa}		{Implement Chino Data.}
* {02 Jan 2024}		{lwasini}		{Implement Tyrone Data.}
* {23 Jan 2024}		{lwasini}		{Add ABR} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_AverageShiftChangeDelay_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN 

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		SELECT COALESCE(Actual, 0) [Actual], [Target] AS ShiftTarget
		FROM BAG.[CONOPS_BAG_AVG_SHIFT_CHANGE_DELAY_V]
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT COALESCE(Actual, 0) [Actual], [Target] AS ShiftTarget
		FROM CER.[CONOPS_CER_AVG_SHIFT_CHANGE_DELAY_V]
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT COALESCE(Actual, 0) [Actual], [Target] AS ShiftTarget
		FROM CHI.[CONOPS_CHI_AVG_SHIFT_CHANGE_DELAY_V]
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT COALESCE(Actual, 0) [Actual], [Target] AS ShiftTarget
		FROM CLI.[CONOPS_CLI_AVG_SHIFT_CHANGE_DELAY_V]
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'MOR'
	BEGIN

		SELECT COALESCE(Actual, 0) [Actual], [Target] AS ShiftTarget
		FROM MOR.[CONOPS_MOR_AVG_SHIFT_CHANGE_DELAY_V]
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'SAM'
	BEGIN

		SELECT COALESCE(Actual, 0) [Actual], [Target] AS ShiftTarget
		FROM SAF.[CONOPS_SAF_AVG_SHIFT_CHANGE_DELAY_V]
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'SIE'
	BEGIN

		SELECT COALESCE(Actual, 0) [Actual], [Target] AS ShiftTarget
		FROM SIE.[CONOPS_SIE_AVG_SHIFT_CHANGE_DELAY_V]
		WHERE shiftflag = @SHIFT

	END


	ELSE IF @SITE = 'TYR'
	BEGIN

		SELECT COALESCE(Actual, 0) [Actual], [Target] AS ShiftTarget
		FROM TYR.[CONOPS_TYR_AVG_SHIFT_CHANGE_DELAY_V]
		WHERE shiftflag = @SHIFT

	END


	ELSE IF @SITE = 'ABR'
	BEGIN

		SELECT COALESCE(Actual, 0) [Actual], [Target] AS ShiftTarget
		FROM ABR.[CONOPS_ABR_AVG_SHIFT_CHANGE_DELAY_V]
		WHERE shiftflag = @SHIFT

	END


END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE();
END CATCH

END





