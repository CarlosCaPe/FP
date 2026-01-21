




/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulTP_TruckUtilization_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 28 April 2023
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulTP_TruckUtilization_Get 'CURR', 'BAG',NULL,NULL,NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {28 Apr 2023}		{lwasini}		{Initial Created} 
* {01 Sep 2023}		{lwasini}		{Add Parameter Equipment Type} 
* {03 Jan 2024}		{lwasini}		{Added TYR}
* {23 Jan 2024}     {lwasini}		{Add ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[zzz_backup_LoadAndHaulTP_TruckUtilization_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX),
	@EQMTTYPE NVARCHAR(MAX)
	
)
AS                        
BEGIN          
	
	IF @SITE = 'BAG'
	BEGIN

		SELECT
			CONCAT(CAST(b.StartDateTime AS DATE),' ',CONVERT(VARCHAR(2),b.StartDateTime,108),':00:00.000') AS TimeinHour,
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
		LEFT JOIN [bag].[CONOPS_BAG_TRUCK_DETAIL_V] d
		ON a.shiftid = d.shiftid AND b.eqmt = d.TruckID
		WHERE unittype = 'truck'
		AND reasonidx <> 200
		AND a.shiftflag = @SHIFT
		AND (b.EQMT IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
		AND (d.EQMTTYPE IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
		AND (c.[status] IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
		GROUP BY reasons,b.StartDateTime

		SELECT TOP 4
			reasons,
			duration
		INTO #BAGTopFourTempTable
		FROM (
		SELECT
			reasons,
			SUM(duration) duration
		FROM #BAGUtilizationTempTable
		GROUP BY reasons) c
		ORDER BY duration DESC;


		SELECT
			reasons,
			SUM(duration) duration
		INTO #BAGOtherTempTable
		FROM (
		SELECT
			reasons,
			duration
		FROM #BAGUtilizationTempTable
		EXCEPT
		SELECT
			reasons,
			duration
		FROM #BAGTopFourTempTable) d
		GROUP BY reasons

		--ReasonCategory
		SELECT
			reasons,
			duration
		INTO #BAGUnionTempTable
		FROM (
		SELECT
			'OTHER' reasons,
			duration
		FROM #BAGOtherTempTable
		UNION ALL
		SELECT
			reasons,
			duration
		FROM #BAGTopFourTempTable) e
		
		-- Top 4 & Other
		SELECT
			reasons,
			SUM(duration) durations
		FROM #BAGUnionTempTable
		GROUP BY reasons;

		--Detail
		
		SELECT
		TimeInHour,
		reasons,
		SUM(duration) duration
		FROM (
		SELECT
			TimeInHour,
			f.reasons,
			SUM(f.duration) duration
		FROM #BAGUtilizationTempTable f
		INNER JOIN #BAGTopFourTempTable g on f.reasons = g.reasons
		GROUP BY TimeInHour,f.reasons

		UNION ALL

		SELECT
			TimeInHour,
			'OTHER' reasons,
			SUM(h.duration) duration
		FROM #BAGUtilizationTempTable h
		INNER JOIN #BAGOtherTempTable i on h.reasons = i.reasons
		GROUP BY TimeInHour,i.reasons) Final
		GROUP BY TimeInHour,reasons
		ORDER BY TimeInHour

		DROP TABLE #BAGUtilizationTempTable;
		DROP TABLE #BAGTopFourTempTable;
		DROP TABLE #BAGOtherTempTable;
		DROP TABLE #BAGUnionTempTable;


	END


	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT
			CONCAT(CAST(b.StartDateTime AS DATE),' ',CONVERT(VARCHAR(2),b.StartDateTime,108),':00:00.000') AS TimeinHour,
			reasons,
			ROUND(SUM(duration/3600.0),2) duration
		INTO #CVEUtilizationTempTable
		FROM [cer].CONOPS_CER_SHIFT_INFO_V a
		LEFT JOIN [cer].[asset_efficiency] b WIT