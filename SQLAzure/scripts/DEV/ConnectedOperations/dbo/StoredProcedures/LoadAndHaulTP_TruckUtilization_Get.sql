

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulTP_TruckUtilization_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 28 April 2023
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulTP_TruckUtilization_Get 'PREV', 'SIE', NULL, NULL, NULL, 0
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {28 Apr 2023}		{lwasini}		{Initial Created} 
* {01 Sep 2023}		{lwasini}		{Add Parameter Equipment Type} 
* {03 Jan 2024}		{lwasini}		{Added TYR}
* {23 Jan 2024}     {lwasini}		{Add ABR}
* {21 Mar 2024}     {lwasini}		{Hourly Categorized}
* {09 May 2025}		{ggosal1}		{Add Autonomous Filter}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulTP_TruckUtilization_Get] 
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

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		SELECT
			CONCAT(CAST(b.StartDateTime AS DATE),' ',CONVERT(VARCHAR(2),b.StartDateTime,108),':00:00.000') AS TimeinHour,
			CASE WHEN reasons LIKE 'M_%' THEN 'M_ITEMS' ELSE reasons END AS reasons,
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
		LEFT JOIN [bag].[CONOPS_BAG_TRUCK_DETAIL_V] d
		ON a.shiftid = d.shiftid AND b.eqmt = d.TruckID
		WHERE unittype = 'truck'
			AND reasonidx <> 200
			AND a.shiftflag = @SHIFT
			AND (b.EQMT IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND (d.EQMTTYPE IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
			AND (c.[status] IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
			AND (b.eqmt IN (SELECT TruckID FROM BAG.CONOPS_BAG_AUTONOMOUS_TRUCK_V WHERE Autonomous = @AUTONOMOUS) OR ISNULL(@AUTONOMOUS, '') = '')
		GROUP BY reasons,b.StartDateTime

		
		---GET HOURLY BASIC ORDER
		SELECT 
			TimeinHour,
			reasons,
			duration,
			ROW_NUMBER() OVER (PARTITION BY TimeinHour ORDER BY duration DESC) rn
		INTO #BAGBasicOrderTempTable
		FROM (
		SELECT
			TimeinHour,
			reasons,
			SUM(duration) duration
		FROM #BAGUtilizationTempTable
		GROUP BY reasons,TimeinHour) c
		ORDER BY TimeinHour;

		-- GET TOP 4
		SELECT
		TimeinHour,
		reasons,
		duration
		INTO #BAGTopFourTempTable
		FROM #BAGBasicOrderTempTable
		WHERE rn IN (1,2,3,4)

		--GET OTHER
		SELECT
		TimeinHour,
		reasons,
		duration
		INTO #BAGOtherTempTable
		FROM #BAGBasicOrderTempTable
		WHERE rn NOT IN (1,2,3,4)

		--OverallCategory
		SELECT TOP 4
		reasons,
		duration
		FROM (
		SELECT 
		reasons,
		SUM(duration) duration
		FROM #BAGUtilizationTempTable
		GROUP BY reasons) d
		ORDER BY duration DESC
		
		
		--TOP 4 & OTHER
		SELECT
		TimeinHour,
		reasons,
		duration
		FROM (
		SELECT
		TimeinHour,
		reasons,
		duration
		FROM #BAGTopFourTempTable

		UNION ALL

		SELECT
		TimeinHour,
		'OTHER' reasons,
		SUM(duration) AS duration
		FROM #BAGOtherTempTable
		GROUP BY TimeinHour) e
		ORDER BY TimeinHour


		DROP TABLE #BAGUtilizationTempTable;
		DROP TABLE #BAGBasicOrderTempTable;
		DROP TABLE #BAGTopFourTempTable;
		DROP TABLE #BAGOtherTempTable;


	END


	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT
			CONCAT(CAST(b.StartDateTime AS DATE),' ',CONVERT(VARCHAR(2),b.StartDateTime,108),':00:00.000') AS TimeinHour,
			reasons,
			ROUND(SUM(duration/3600.0),2) 