






/******************************************************************  
* PROCEDURE	: dbo.DrillAndBlast_Delay_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 14 Feb 2023
* SAMPLE	: 
	1. EXEC dbo.DrillAndBlast_Delay_Get 'CURR', 'MOR', NULL, NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {14 Feb 2023}		{jrodulfa}		{Initial Created}
* {07 Sep 2023}		{ggosal1}		{Add Parameter Equipment, Status & Type} 
* {03 Jan 2024}		{lwasini}		{Added TYR}
* {09 Jan 2024}		{lwasini}		{Added ABR}
* {08 Aug 2025}		{dbonardo}		{Changed TimeInHours to TimeInMinutes}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[DrillAndBlast_Delay_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX),
	@EQMTTYPE NVARCHAR(MAX)
)
AS                        
BEGIN  

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		SELECT TOP 5
			shiftflag,
			reason AS ReasonName,
			CAST(reasonidx AS VARCHAR(10)) AS ReasonId,
			SUM(duration) As TimeInMinutes
		FROM [BAG].[CONOPS_BAG_DB_DELAY_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
			AND (eqmt IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS ), ',')) OR ISNULL(@STATUS, '') = '')
			AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
		GROUP BY shiftflag, reason, reasonidx
		ORDER BY SUM(duration) DESC

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT TOP 5
			shiftflag,
			reason AS ReasonName,
			CAST(reasonidx AS VARCHAR(10)) AS ReasonId,
			SUM(duration) As TimeInMinutes
		FROM [CER].[CONOPS_CER_DB_DELAY_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
			AND (eqmt IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS ), ',')) OR ISNULL(@STATUS, '') = '')
			AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
		GROUP BY shiftflag, reason, reasonidx
		ORDER BY SUM(duration) DESC

	END
		
	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT TOP 5
			shiftflag,
			reason AS ReasonName,
			CAST(reasonidx AS VARCHAR(10)) AS ReasonId,
			SUM(duration) As TimeInMinutes
		FROM [CHI].[CONOPS_CHI_DB_DELAY_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
			AND (eqmt IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS ), ',')) OR ISNULL(@STATUS, '') = '')
			AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
		GROUP BY shiftflag, reason, reasonidx
		ORDER BY SUM(duration) DESC

	END
		
	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT TOP 5
			shiftflag,
			reason AS ReasonName,
			CAST(reasonidx AS VARCHAR(10)) AS ReasonId,
			SUM(duration) As TimeInMinutes
		FROM [CLI].[CONOPS_CLI_DB_DELAY_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
			AND (eqmt IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS ), ',')) OR ISNULL(@STATUS, '') = '')
			AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
		GROUP BY shiftflag, reason, reasonidx
		ORDER BY SUM(duration) DESC

	END
		
	ELSE IF @SITE = 'MOR'
	BEGIN

		SELECT TOP 5
			shiftflag,
			reason AS ReasonName,
			CAST(reasonidx AS VARCHAR(10)) AS ReasonId,
			SUM(duration) As TimeInMinutes
		FROM [MOR].[CONOPS_MOR_DB_DELAY_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
			AND (eqmt IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS ), ',')) OR ISNULL(@