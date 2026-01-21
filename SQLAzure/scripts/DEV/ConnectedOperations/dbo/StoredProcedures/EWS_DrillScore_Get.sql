



/******************************************************************  
* PROCEDURE	: dbo.EWS_DrillScore_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 10 October 2023
* SAMPLE	: 
	1. EXEC dbo.EWS_DrillScore_Get 'PREV', 'BAG'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {10 Oct 2023}		{lwasini}		{Initial Created} 
* {01 Mar 2024}		{lwasini}		{Display 0 for Other Site} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EWS_DrillScore_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          
	
	IF @SITE NOT IN ('BAG','CVE','CHN','CMX','MOR','SAM','SIE','ABR','TYR')
	BEGIN

		SELECT
			0 currentDate,
			0 avgHoleTime,
			0 avgOverallScore,
			0 avgDepthScore,
			0 avgHorScore,
			0 avgPenRate
		

		SELECT
			0 TimeStampHour,
			0 countHoles


	END
	
	ELSE IF @SITE = 'BAG'
	BEGIN

		SELECT
			currentDate,
			avgHoleTime,
			avgOverallScore,
			avgDepthScore,
			avgHorScore,
			avgPenRate
		FROM [bag].[EWS_BAG_DRILL_SCORE_V]
		WHERE shiftflag = @SHIFT;

		SELECT
			TimeStampHour,
			countHoles
		FROM [bag].[EWS_BAG_DRILL_HOLE_V]
		WHERE shiftflag = @SHIFT
		ORDER BY TimeStampHour DESC;


	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT 
			currentDate,
			avgHoleTime,
			avgOverallScore,
			avgDepthScore,
			avgHorScore,
			avgPenRate
		FROM [cer].[EWS_CER_DRILL_SCORE_V]
		WHERE shiftflag = @SHIFT;

		SELECT
			TimeStampHour,
			countHoles
		FROM [cer].[EWS_CER_DRILL_HOLE_V]
		WHERE shiftflag = @SHIFT
		ORDER BY TimeStampHour DESC;

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT 
			currentDate,
			avgHoleTime,
			avgOverallScore,
			avgDepthScore,
			avgHorScore,
			avgPenRate
		FROM [chi].[EWS_CHI_DRILL_SCORE_V]
		WHERE shiftflag = @SHIFT;

		SELECT
			TimeStampHour,
			countHoles
		FROM [chi].[EWS_CHI_DRILL_HOLE_V]
		WHERE shiftflag = @SHIFT
		ORDER BY TimeStampHour DESC;

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT 
			currentDate,
			avgHoleTime,
			avgOverallScore,
			avgDepthScore,
			avgHorScore,
			avgPenRate
		FROM [cli].[EWS_CLI_DRILL_SCORE_V]
		WHERE shiftflag = @SHIFT;

		SELECT
			TimeStampHour,
			countHoles
		FROM [cli].[EWS_CLI_DRILL_HOLE_V]
		WHERE shiftflag = @SHIFT
		ORDER BY TimeStampHour DESC;

	END

	ELSE IF @SITE = 'MOR'
	BEGIN

		SELECT 
			currentDate,
			avgHoleTime,
			avgOverallScore,
			avgDepthScore,
			avgHorScore,
			avgPenRate
		FROM [mor].[EWS_MOR_DRILL_SCORE_V]
		WHERE shiftflag = @SHIFT;

		SELECT
			TimeStampHour,
			countHoles
		FROM [mor].[EWS_MOR_DRILL_HOLE_V]
		WHERE shiftflag = @SHIFT
		ORDER BY TimeStampHour DESC;

	END

	ELSE IF @SITE = 'SAM'
	BEGIN

		SELECT 
			currentDate,
			avgHoleTime,
			avgOverallScore,
			avgDepthScore,
			avgHorScore,
			avgPenRate
		FROM [saf].[EWS_SAF_DRILL_SCORE_V]
		WHERE shiftflag = @SHIFT;

		SELECT
			TimeStampHour,
			countHoles
		FROM [saf].[EWS_SAF_DRILL_HOLE_V]
		WHERE shiftflag = @SHIFT
		ORDER BY TimeStampHour DESC;

	END

	ELSE IF @SITE = 'SIE'
	BEGIN

		SELECT 
			currentDate,
			avgHoleTime,
			avgOverallScore,
			avgDepthScore,
			avgHorScore,
			avgPenRate
		FROM [sie].[EWS_SIE_DRILL_SCORE_V]
		WHERE shiftflag = @SHIFT;

		SELECT
			TimeStampHour,
			countHoles
		FROM [sie].[EWS_SIE_DRILL_HOLE_V]
		WHERE shiftflag = @SHIFT
		ORDER BY TimeStampHour DESC;

	END

END


