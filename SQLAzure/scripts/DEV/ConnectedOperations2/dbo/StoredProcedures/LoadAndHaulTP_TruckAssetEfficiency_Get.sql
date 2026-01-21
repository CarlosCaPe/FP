

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulTP_TruckAssetEfficiency_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 22 Dec 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulTP_TruckAssetEfficiency_Get 'PREV', 'MOR', NULL, NULL, NULL, 0
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {22 Dec 2022}		{jrodulfa}		{Initial Created} 
* {23 Dec 2022}		{sxavier}		{Rename field} 
* {18 Sep 2023}		{lwasini}		{Add Paramter EQMT,EQMTTYPE,STATUS}
* {10 Jan 2024}		{lwasini}		{Add TYR} 
* {23 Jan 2024}     {lwasini}		{Add ABR}
* {09 May 2025}		{ggosal1}		{Add Autonomous Filter}
* {10 Nov 2025}		{dbonardo}		{Split string using udt}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulTP_TruckAssetEfficiency_Get] 
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

	INSERT INTO @splitEqmt ([Value])
	SELECT TRIM([value]) FROM STRING_SPLIT(@EQMT, ',');

	INSERT INTO @splitEStat ([Value])
	SELECT TRIM([value]) FROM STRING_SPLIT(@STATUS, ',');

	INSERT INTO @splitEType ([Value])
	SELECT TRIM([value]) FROM STRING_SPLIT(@EQMTTYPE, ',');
	
	IF @SITE = 'BAG'
	BEGIN

		SELECT
			ROUND(AVG([AE]),0) AS Efficiency,
			ROUND(AVG([Avail]),0) AS [Availability],
			CASE WHEN AVG(Avail) IS NULL OR AVG(Avail) = 0
				THEN 0
				ELSE ROUND((AVG([AE])/AVG([Avail])) * 100,0)
				END  AS Utilization
		FROM BAG.[CONOPS_BAG_TP_TRUCK_ASSET_EFFICIENCY_V] a WITH (NOLOCK)
		LEFT JOIN BAG.CONOPS_BAG_AUTONOMOUS_TRUCK_V d
			ON a.Equipment = d.TruckID
		WHERE shiftflag = @SHIFT 
			AND (Equipment IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
			AND (eqmttype IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
			AND (StatusName IN (SELECT [Value] FROM @splitEStat) OR @STATUS IS NULL)
			AND (d.Autonomous = @AUTONOMOUS OR @AUTONOMOUS IS NULL)
 
		SELECT
			[Hr] AS [DateTime],
			AVG([AE]) AS Efficiency,
			AVG([Avail]) AS [Availability],
			CASE WHEN AVG(Avail) IS NULL OR AVG(Avail) = 0
				THEN 0
				ELSE ROUND((AVG([AE])/AVG([Avail])) * 100,0)
				END  AS Utilization
		FROM BAG.[CONOPS_BAG_TP_TRUCK_ASSET_EFFICIENCY_V] a WITH (NOLOCK)
		LEFT JOIN BAG.CONOPS_BAG_AUTONOMOUS_TRUCK_V d
			ON a.Equipment = d.TruckID
		WHERE shiftflag = @SHIFT
			AND (Equipment IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
			AND (eqmttype IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
			AND (StatusName IN (SELECT [Value] FROM @splitEStat) OR @STATUS IS NULL)
			AND (d.Autonomous = @AUTONOMOUS OR @AUTONOMOUS IS NULL)
		GROUP BY [Hr],[HOS]
		ORDER BY [HOS]

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT
			ROUND(AVG([AE]),0) AS Efficiency,
			ROUND(AVG([Avail]),0) AS [Availability],
			CASE WHEN AVG(Avail) IS NULL OR AVG(Avail) = 0
				THEN 0
				ELSE ROUND((AVG([AE])/AVG([Avail])) * 100,0)
				END  AS Utilization
		FROM CER.[CONOPS_CER_TP_TRUCK_ASSET_EFFICIENCY_V] a WITH (NOLOCK)
		LEFT JOIN CER.CONOPS_CER_AUTONOMOUS_TRUCK_V d
			ON a.Equipment = d.TruckID
		WHERE shiftflag = @SHIFT
			AND (Equipment IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
			AND (eqmttype IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
			AND (StatusName IN (SELECT [Value] FROM @splitEStat) OR @STATUS IS NULL)
			AND (d.Autonomous = @AUTONOMOUS OR @AUTONOMOUS IS NULL)
 
		SELECT
			[Hr] AS [DateTime],
			AVG([AE]) AS Efficiency,
			AVG([Avail]) AS [Availability],
			CASE WHEN AVG(Avail) IS NULL OR AVG(Avail) = 0
				THEN 0
				ELSE ROUND((AVG([AE])/AVG([Avail])) * 100,0)
				END  AS Utilization
		FROM CER.[CONOPS_CER_TP_TRUCK_ASSET_E