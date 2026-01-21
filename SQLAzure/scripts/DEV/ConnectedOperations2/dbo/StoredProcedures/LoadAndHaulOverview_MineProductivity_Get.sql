
/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_MineProductivity_Get
* PURPOSE	: To get CDC of table mor.ShiftInfo
* NOTES		: Using by job_conops_shoft_info
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_MineProductivity_Get 'CURR', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created}  
* {18 Nov 2022}		{sxavier}		{Add alias field name} 
* {18 Jan 2022}		{jrodulfa}		{Implement Safford data.} 
* {27 Jan 2023}		{jrodulfa}		{Change SAF sitecode to SAM.}
* {07 Feb 2023}		{jrodulfa}		{Implement Chino Data.}
* {10 Feb 2023}		{mbote}		    {Implement Cerro Verde Data.}
* {10 jan 2024}		{lwasini}		{Add TYR}
* {23 Jan 2024}		{lwasini}		{Add ABR} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_MineProductivity_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        

BEGIN      
BEGIN TRY	IF @SITE = 'BAG'
	BEGIN

		SELECT 
			ROUND(MineProductivity/1000,0) AS Actual, 
			ROUND([mineproductivitytarget]/1000,0) AS ShiftTarget
		FROM BAG.[CONOPS_BAG_MINE_PRODUCTIVITY_V] (NOLOCK)
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT 
			ROUND(MineProductivity/1000,0) AS Actual, 
			ROUND([mineproductivitytarget]/1000,0) AS ShiftTarget
		FROM CER.[CONOPS_CER_MINE_PRODUCTIVITY_V] (NOLOCK)
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT 
			ROUND(MineProductivity/1000,0) AS Actual, 
			ROUND([mineproductivitytarget]/1000,0) AS ShiftTarget
		FROM CHI.[CONOPS_CHI_MINE_PRODUCTIVITY_V] (NOLOCK)
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT 
			ROUND(MineProductivity/1000,0) AS Actual, 
			ROUND([mineproductivitytarget]/1000,0) AS ShiftTarget
		FROM CLI.[CONOPS_CLI_MINE_PRODUCTIVITY_V] (NOLOCK)
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'MOR'
	BEGIN

		SELECT 
			ROUND(MineProductivity/1000,0) AS Actual, 
			ROUND([mineproductivitytarget]/1000,0) AS ShiftTarget
		FROM MOR.[CONOPS_MOR_MINE_PRODUCTIVITY_V] (NOLOCK)
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'SAM'
	BEGIN

		SELECT 
			ROUND(MineProductivity/1000,0) AS Actual, 
			ROUND([mineproductivitytarget]/1000,0) AS ShiftTarget
		FROM SAF.[CONOPS_SAF_MINE_PRODUCTIVITY_V] (NOLOCK)
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'SIE'
	BEGIN

		SELECT 
			ROUND(MineProductivity/1000,0) AS Actual, 
			ROUND([mineproductivitytarget]/1000,0) AS ShiftTarget
		FROM SIE.[CONOPS_SIE_MINE_PRODUCTIVITY_V] (NOLOCK)
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'TYR'
	BEGIN

		SELECT 
			ROUND(MineProductivity/1000,0) AS Actual, 
			ROUND([mineproductivitytarget]/1000,0) AS ShiftTarget
		FROM TYR.[CONOPS_TYR_MINE_PRODUCTIVITY_V] (NOLOCK)
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'ABR'
	BEGIN

		SELECT 
			ROUND(MineProductivity/1000,0) AS Actual, 
			ROUND([mineproductivitytarget]/1000,0) AS ShiftTarget
		FROM [ABR].[CONOPS_ABR_MINE_PRODUCTIVITY_V] (NOLOCK)
		WHERE shiftflag = @SHIFT

	END

END TRYBEGIN CATCH	PRINT ERROR_MESSAGE();END CATCHEND




