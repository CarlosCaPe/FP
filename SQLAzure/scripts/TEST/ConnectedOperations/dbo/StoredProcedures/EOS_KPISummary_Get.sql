



/******************************************************************  
* PROCEDURE	: dbo.EOS_KPISummary_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: mbote, 22 June 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_KPISummary_Get 'PREV', 'BAG',0
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {22 Jun 2023}		{mbote}		{Initial Created} 
* {27 Jun 2023}		{mbote}		{Add remaining sites}
* {04 Jul 2023}		{jrodulfa}	{Add Haulage Hourly Data}
* {20 Jul 2023}		{jrodulfa}	{Add MaterialMined, MaterialMoved, DeliveredToCrusher}
* {06 Oct 2023}		{lwasini}	{Change SOurce of Haulage Efficiency to Delta J view} 
* {07 Dec 2023}		{lwasini}	{Add Daily Summary} 
* {30 Jan 2024}		{lwasini}	{Add TYR & ABR} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_KPISummary_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@DAILY INT
)
AS                        
BEGIN  

	SET @SITE = CASE @SITE
					WHEN 'SAM' THEN 'SAF'
					WHEN 'CVE' THEN 'CER'
					WHEN 'CHN' THEN 'CHI'
					ELSE @SITE
				END;
	
	IF @SITE = 'BAG'
	BEGIN

		IF @DAILY = 0
		BEGIN
		SELECT [HaulageEfficiency]
			,0 AS [HaulageEfficiencyTarget]
			,[FirstHourTonsTotal]
			,0 AS [FirstHourTonsTotalTarget]
			,[LastHourTonsTotal]
			,0 AS [LastHourTonsTotalTarget]
			,[MiddleHourTonsTotal]
			,0 AS [MiddleHourTonsTotalTarget]
			,[ShiftChangeEfficiency]
			,0 AS [ShiftChangeEfficiencyTarget]
			,[AvgShiftChgDuration]
			,0 AS [AvgShiftChgDurationTarget]
		FROM [bag].[CONOPS_BAG_EOS_KPI_SUMMARY_V] (NOLOCK)
		WHERE shiftflag = @SHIFT;

		SELECT DeltaJ AS [Haulage]
			,TimeinHour AS [Hr]
			--,Shiftseq AS [Hos]
		--FROM [bag].[CONOPS_BAG_EOS_KPI_SUMMARY_HOURLY_HAULAGE_V] AS haulage
		FROM [bag].[CONOPS_BAG_DELTA_J_V] AS haulage
		WHERE shiftflag = @SHIFT;

		SELECT [AvgDuration]
			,[Hr]
			,[Hos]
		FROM [bag].[CONOPS_BAG_EOS_KPI_SUMMARY_HOURLY_AVG_DURATION_V] AS AvgShiftChgDuration
		WHERE shiftflag = @SHIFT;

		SELECT 
			TotalMaterialMined
		FROM [bag].[CONOPS_BAG_EOS_TOTAL_MATERIAL_V]
		WHERE shiftflag = @SHIFT;
		
		SELECT 
			TotalMaterialMoved
		FROM [bag].[CONOPS_BAG_EOS_TOTAL_MATERIAL_V]
		WHERE shiftflag = @SHIFT;
		
		SELECT 
			TotalMaterialDeliveredToCrusher
		FROM [bag].[CONOPS_BAG_EOS_TOTAL_MATERIAL_V]
		WHERE shiftflag = @SHIFT;
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT 
			AVG([HaulageEfficiency]) [HaulageEfficiency]
			,0 AS [HaulageEfficiencyTarget]
			,SUM([FirstHourTonsTotal]) [FirstHourTonsTotal]
			,0 AS [FirstHourTonsTotalTarget]
			,SUM([LastHourTonsTotal]) [LastHourTonsTotal]
			,0 AS [LastHourTonsTotalTarget]
			,SUM([MiddleHourTonsTotal]) [MiddleHourTonsTotal]
			,0 AS [MiddleHourTonsTotalTarget]
			,AVG([ShiftChangeEfficiency]) [ShiftChangeEfficiency]
			,0 AS [ShiftChangeEfficiencyTarget]
			,AVG([AvgShiftChgDuration])[AvgShiftChgDuration]
			,0 AS [AvgShiftChgDurationTarget]
		FROM [bag].[CONOPS_BAG_DAILY_EOS_KPI_SUMMARY_V] (NOLOCK)
		WHERE shiftflag = @SHIFT;

		SELECT DeltaJ AS [Haulage]
			,TimeinHour AS [Hr]
		FROM [bag].[CONOPS_BAG_DAILY_DELTA_J_V]
		WHERE shiftflag = @SHIFT;

		SELECT [AvgDuration]
			,[Hr]
			,[Hos]
		FROM [bag].[CONOPS_BAG_DAILY_EOS_KPI_SUMMARY_HOURLY_AVG_DURATION_V]
		WHERE shiftflag = @SHIFT;

		SELECT 
			SUM(TotalMaterialMined) TotalMaterialMined
		FROM [bag].[CONOPS_BAG_DAILY_EOS_TOTAL_MATERIAL_V]
		WHERE shiftflag = @SHIFT;
		
		SELECT 
			SUM(TotalMaterialMoved) TotalMaterialMoved
		FROM [bag].[CONOPS_BAG_DAILY_EOS_TOTAL_MATERIAL_V]
		WHERE shiftflag = @SHIFT;
		
		SELECT 
			SUM(TotalMaterialDeliveredToCrusher) TotalMaterialDeliveredToCrusher
		FROM [bag].[CONOPS_BAG_DAILY_EOS_TOTAL_MATERIAL_V]
		WHERE shiftflag = @SHIFT;
		END


	END

	ELSE IF @SITE = 'CER'
	BEGIN

		IF @DAILY = 0
		BEGIN
		SELECT [HaulageEfficiency]
			,0 AS [HaulageEfficiencyTarget]
			,[FirstHourTonsTotal]
			,0 AS [Fi