

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulSP_Spare_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulSP_Spare_Get 'PREV', 'TYR',NULL,NULL,NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created} 
* {06 Dec 2022}		{sxavier}		{Rename field}
* {15 Sep 2023}		{lwasini}		{Add Paramter EQMT,EQMTTYPE,STATUS}
* {03 Jan 2024}		{lwasini}		{Added TYR}
* {23 Jan 2024}		{lwasini}		{Add ABR}
* {08 Aug 2025}		{dbonardo}		{Changed TimeInHours to TimeInMinutes}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulSP_Spare_Get] 
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
		ReasonName,
		ReasonId,
		TimeInMinutes
		FROM (
		SELECT 
			reasons AS ReasonName,
			CAST(reasonidx AS VARCHAR(10)) AS ReasonId,
			CAST(SUM(duration) AS FLOAT) As TimeInMinutes
		FROM BAG.[CONOPS_BAG_SP_SPARE_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		AND (eqmt IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
		AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
		AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
		GROUP BY reasons,reasonidx) a
		ORDER BY TimeInMinutes DESC

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT TOP 5
		ReasonName,
		ReasonId,
		TimeInMinutes
		FROM (
		SELECT 
			reasons AS ReasonName,
			CAST(reasonidx AS VARCHAR(10)) AS ReasonId,
			CAST(SUM(duration) AS FLOAT) As TimeInMinutes
		FROM CER.[CONOPS_CER_SP_SPARE_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		AND (eqmt IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
		AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
		AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
		GROUP BY reasons,reasonidx) a
		ORDER BY TimeInMinutes DESC

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT TOP 5
		ReasonName,
		ReasonId,
		TimeInMinutes
		FROM (
		SELECT
			reasons AS ReasonName,
			CAST(reasonidx AS VARCHAR(10)) AS ReasonId,
			CAST(SUM(duration) AS FLOAT) As TimeInMinutes
		FROM CHI.[CONOPS_CHI_SP_SPARE_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		AND (eqmt IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
		AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
		AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
		GROUP BY reasons,reasonidx) a
		ORDER BY TimeInMinutes DESC

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT TOP 5
		ReasonName,
		ReasonId,
		TimeInMinutes
		FROM (
		SELECT
			reasons AS ReasonName,
			CAST(reasonidx AS VARCHAR(10)) AS ReasonId,
			CAST(SUM(duration) AS FLOAT) As TimeInMinutes
		FROM CLI.[CONOPS_CLI_SP_SPARE_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		AND (eqmt IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
		AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
		AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
		GROUP BY reasons,reasonidx) a
		ORDER BY TimeInMinutes DESC

	END

	ELSE IF @SITE = 'MOR'
	BEGIN

		SELECT TOP 5
		ReasonName,
		ReasonId,
		TimeInMinutes
		FROM (
		SELECT
			reasons AS ReasonName,
			CAST(reasonidx AS VARCHAR(10)) AS ReasonId,
			CAST(SUM(durati