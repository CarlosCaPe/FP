
/******************************************************************  
* PROCEDURE	: dbo.CrushAndConvey_Throughput_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: mbote, 10 Jul 2023
* SAMPLE	: 
	1. EXEC dbo.CrushAndConvey_Throughput_Get 'CURR', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {10 Jul 2023}		{mbote}		{Initial Created} 
* {23 Oct 2023}		{ggosal1}	{Add filter Hr & HOS} 
* {30 Jan 2024}		{lwasini}	{Add TYR & ABR} 
* {18 Nov 2025}		{ggosal1}	{Add Order By} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[CrushAndConvey_Throughput_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN
		SELECT ShiftFlag
			,SiteFlag
			,CrusherLoc AS Crusher
			,ROUND(SensorValue,0) SensorValue
			,Hr
			,Hos
		FROM [bag].[CONOPS_BAG_CM_HOURLY_CRUSHER_THROUGHPUT_V] WITH (NOLOCK)
		WHERE ShiftFlag = @SHIFT
			AND Hr IS NOT NULL
			AND Hos > 0
		ORDER BY CrusherLoc, Hr

		SELECT ShiftFlag
			,SiteFlag
			,CrusherLoc AS Crusher
			,ROUND(HrAvgThroughput,0) HrAvgThroughput
			,ROUND(ShfAvgThroughput,0) ShfAvgThroughput
		FROM [bag].[CONOPS_BAG_CM_AVG_THROUGHPUT_V] WITH (NOLOCK)
		WHERE ShiftFlag = @SHIFT

		SELECT
			Name,
			(sum(MillOreActual) + sum(LeachActual)) * 1000.0 AS CumulativeThroughput
		FROM [bag].[CONOPS_BAG_MATERIAL_DELIVERED_TO_CHRUSHER_V] [ca] WITH (NOLOCK)
		WHERE ShiftFlag = @SHIFT
		GROUP BY Name

		SELECT
			shiftflag
			,NULL AS RockBreakerUsage
			,NULL AS TonnageFines
		FROM [BAG].[CONOPS_BAG_SHIFT_INFO_V]
		WHERE ShiftFlag = @SHIFT
	END

	ELSE IF @SITE = 'CVE'
	BEGIN
		SELECT ShiftFlag
			,SiteFlag
			,CrusherLoc AS Crusher
			,ROUND(SensorValue,0) SensorValue
			,Hr
			,Hos
		FROM [cer].[CONOPS_CER_CM_HOURLY_CRUSHER_THROUGHPUT_V] WITH (NOLOCK)
		WHERE ShiftFlag = @SHIFT
			AND Hr IS NOT NULL
			AND Hos > 0
		ORDER BY CrusherLoc, Hr

		SELECT ShiftFlag
			,SiteFlag
			,CrusherLoc AS Crusher
			,ROUND(HrAvgThroughput,0) HrAvgThroughput
			,ROUND(ShfAvgThroughput,0) ShfAvgThroughput
		FROM [cer].[CONOPS_CER_CM_AVG_THROUGHPUT_V] WITH (NOLOCK)
		WHERE ShiftFlag = @SHIFT

		SELECT
			CASE WHEN Name = 'MILLCHAN' THEN 'C1 MillChan'
				WHEN Name = 'MILLCRUSH1' THEN 'MillCrush 1'
				WHEN Name = 'MILLCRUSH2' THEN 'MillCrush 2'
				WHEN Name = 'HIDROCHAN' THEN 'HidroChan'
			ELSE Name END AS Name,
			(sum(MillOreActual) + sum(LeachActual)) * 1000.0 AS CumulativeThroughput
		FROM [cer].[CONOPS_CER_MATERIAL_DELIVERED_TO_CHRUSHER_V] [ca] WITH (NOLOCK)
		WHERE ShiftFlag = @SHIFT
		GROUP BY Name

		SELECT
			shiftflag
			,NULL AS RockBreakerUsage
			,NULL AS TonnageFines
		FROM [CER].[CONOPS_CER_SHIFT_INFO_V]
		WHERE ShiftFlag = @SHIFT
	END

	ELSE IF @SITE = 'CHN'
	BEGIN
		SELECT ShiftFlag
			,SiteFlag
			,CrusherLoc AS Crusher
			,ROUND(SensorValue,0) SensorValue
			,Hr
			,Hos
		FROM [chi].[CONOPS_CHI_CM_HOURLY_CRUSHER_THROUGHPUT_V] WITH (NOLOCK)
		WHERE ShiftFlag = @SHIFT
			AND Hr IS NOT NULL
			AND Hos > 0
		ORDER BY CrusherLoc, Hr

		SELECT ShiftFlag
			,SiteFlag
			,CrusherLoc AS Crusher
			,ROUND(HrAvgThroughput,0) HrAvgThroughput
			,ROUND(ShfAvgThroughput,0) ShfAvgThroughput
		FROM [chi].[CONOPS_CHI_CM_AVG_THROUGHPUT_V] WITH (NOLOCK)
		WHERE ShiftFlag = @SHIFT

		SELECT
			Name,
			(sum(MillOreActual) + sum(LeachActual)) * 1000.0 AS CumulativeThroughput
		FROM [chi].[CONOPS_CHI_MATERIAL_DELIVERED_TO_CHRUSHER_V] [ca] WITH (NOLOCK)
		WHERE ShiftFlag = @SHIFT
		GROUP BY Name

		SELECT
			shiftflag
			,NULL AS RockBreakerUsage
			,NULL AS TonnageFines
		FROM [CHI].[CONOPS_CHI_SHIFT_INFO_V]
		WHERE ShiftFlag = @SHIFT
	END

	ELSE IF @SITE = 'CMX'
	BEGIN
		SELECT ShiftFlag
			,SiteFlag
			,CrusherLoc AS Crusher
			,ROUND(SensorValue,0) SensorValue
			,Hr
			,Hos
		FROM [cli].[CONOPS_CLI_CM_HOU