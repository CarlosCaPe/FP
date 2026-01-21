

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulTP_TruckUtilization_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 29 August 2023
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulTP_WorstTruckUtilization_Get 'CURR', 'MOR', NULL, NULL, NULL, 0
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {29 Aug 2023}		{lwasini}		{Initial Created} 
* {03 Jan 2024}		{lwasini}		{Added TYR} 
* {23 Jan 2024}     {lwasini}		{Add ABR}
* {25 Nov 2024}     {ggosal1}		{Handling Zero, Fixing CVE Truck --> Camion}
* {09 May 2025}		{ggosal1}		{Add Autonomous Filter}
* {10 Nov 2025}     {dbonardo}      {Split String using udt}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulTP_WorstTruckUtilization_Get] 
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
			b.eqmt AS Equipment,
			reasons,
			ROUND(SUM(duration/3600.0),2) duration
		INTO #BAGUtilizationTempTable
		FROM [bag].CONOPS_BAG_SHIFT_INFO_V a
		LEFT JOIN [bag].[asset_efficiency] b WITH (NOLOCK)
		ON a.shiftid = b.shiftid 
		LEFT JOIN (
		select 
			shiftid,
			eqmt,
			[status],
			ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
			from [bag].[asset_efficiency] (NOLOCK)
			where unittype = 'truck') c
		ON a.shiftid = c.shiftid AND b.eqmt = c.eqmt AND c.num = 1
		LEFT JOIN [bag].[CONOPS_BAG_TRUCK_DETAIL_V] t
		ON a.shiftid = t.shiftid AND b.eqmt = t.TruckID
		LEFT JOIN BAG.CONOPS_BAG_AUTONOMOUS_TRUCK_V d
		ON b.eqmt = d.TruckID
		WHERE unittype = 'truck'
			AND reasonidx <> 200
			AND a.shiftflag = @SHIFT
			AND (b.EQMT IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
			AND (t.EQMTTYPE IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
			AND (c.[status] IN (SELECT [Value] FROM @splitEStat) OR @STATUS IS NULL)
			AND (d.Autonomous = @AUTONOMOUS OR @AUTONOMOUS IS NULL)
		GROUP BY reasons,b.eqmt;
		/*
		--TOP 5 Worst
		SELECT TOP 5
			reasons,
			duration
		FROM (
		SELECT
			reasons,
			SUM(duration) duration
		FROM #BAGUtilizationTempTable
		GROUP BY reasons) c
		ORDER BY duration DESC;*/

		--Under 80% AVGUtilization
		SELECT
			Equipment,
			CASE WHEN TotalAVGDuration = 0 
				THEN NULL
				ELSE ((AVG(duration)/TotalAVGDuration) * 100) END AS AVGDuration --AvgDurationPerEquipment
		INTO #BAGTotalUtilizationTempTable
		FROM #BAGUtilizationTempTable a
		CROSS JOIN (
		SELECT
			AVG(duration) TotalAVGDuration --TotalAvgDuration
		FROM #BAGUtilizationTempTable) b
		GROUP BY Equipment,TotalAVGDuration;

		SELECT
			Equipment,
			ROUND(AVGDuration,0) AVGDuration
		FROM #BAGTotalUtilizationTempTable a
		WHERE AVGDuration < 80
		ORDER BY AVGDuration DESC;

		DROP TABLE #BAGUtilizationTempTable;
		DROP TABLE #BAGTotalUtilizationTempTable;


	END


	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT
			b.eqmt AS Equipment,
			reasons,
			ROUND(SUM(duration/3600.0),2) duration
		INTO #CVEUtilizationTempTable
		FROM [cer].CONOPS_CER_SHIFT_INFO_V a
		LEFT JOIN [cer].[asset_efficiency] b WITH (NOLOCK) 
		ON a.shiftid = b.shiftid 
		LEFT JOIN (
		select 
			shiftid,
			eqmt,
			[status],
			ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
			from [cer].[asset_efficiency] (NOLOCK)
			where