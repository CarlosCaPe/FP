

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulTP_Spare_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulTP_Spare_Get 'CURR', 'CVE', NULL, NULL, NULL, 0
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created}  
* {06 Dec 2022}		{sxavier}		{Rename field}
* {15 Sep 2023}		{lwasini}		{Add Paramter EQMT,EQMTTYPE,STATUS}
* {03 Jan 2024}		{lwasini}		{Added TYR}
* {23 Jan 2024}     {lwasini}		{Add ABR}
* {09 May 2025}		{ggosal1}		{Add Autonomous Filter}
* {08 Aug 2025}		{dbonardo}		{Changed TimeInHours to TimeInMinutes}
* {11 Nov 2025}		{dbonardo}		{Split string using udt}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulTP_Spare_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX),
	@EQMTTYPE NVARCHAR(MAX),
	@AUTONOMOUS INT
)
AS                        
BEGIN          

	DECLARE @splitEqmt [dbo].[udTT_SplitValue];
	DECLARE @splitEStat [dbo].[udTT_SplitValue];
	DECLARE @splitEType [dbo].[udTT_SplitValue];

	INSERT INTO @splitEqmt ([Value]) SELECT TRIM([value]) FROM STRING_SPLIT(@EQMT, ',');
	INSERT INTO @splitEStat ([Value]) SELECT TRIM([value]) FROM STRING_SPLIT(@STATUS, ',');
	INSERT INTO @splitEType ([Value]) SELECT TRIM([value]) FROM STRING_SPLIT(@EQMTTYPE, ',');

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
		FROM BAG.[CONOPS_BAG_TP_SPARE_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
			AND (eqmt IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
			AND (eqmttype IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
			AND (eqmtcurrstatus IN (SELECT [Value] FROM @splitEStat) OR @STATUS IS NULL)
			AND (eqmt IN (SELECT TruckID FROM BAG.CONOPS_BAG_AUTONOMOUS_TRUCK_V WHERE Autonomous = @AUTONOMOUS) OR @AUTONOMOUS IS NULL)
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
		FROM CER.[CONOPS_CER_TP_SPARE_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
			AND (eqmt IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
			AND (eqmttype IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
			AND (eqmtcurrstatus IN (SELECT [Value] FROM @splitEStat) OR @STATUS IS NULL)
			AND (eqmt IN (SELECT TruckID FROM CER.CONOPS_CER_AUTONOMOUS_TRUCK_V WHERE Autonomous = @AUTONOMOUS) OR @AUTONOMOUS IS NULL)
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
		FROM CHI.[CONOPS_CHI_TP_SPARE_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
			AND (eqmt IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
			AND (eqmttype IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
			AND (eqmtcurrstatus IN (SELECT [Value] FROM @splitEStat) OR @STATUS IS NULL)
			AND (eqmt IN (SELECT TruckID FROM CHI.CONOPS_CHI_AUTONOMOUS_TRUCK_V WHERE Autonomous = @AUTONOMOUS) OR @AUTONOMOUS IS NULL)
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
	