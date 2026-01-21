




/******************************************************************  
* PROCEDURE	: dbo.CrushAndConvey_TrafficMatrix_HaulStatus_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 12 Jun 2023
* SAMPLE	: 
	1. EXEC dbo.CrushAndConvey_TrafficMatrix_HaulStatus_Get 'CURR', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {12 Jun 2023}		{jrodulfa}		{Initial Created} 
* {14 Jun 2023}		{jrodulfa}		{Add DeltaC Target} 
* {19 Jun 2023}		{sxavier}		{Remove Total_Min_Over_Expected and add AvgDeltaC and AvgDeltaCTarget} 
* {30 Jan 2024}		{lwasini}		{Add TYR & ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[CrushAndConvey_TrafficMatrix_HaulStatus_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          
	
	IF @SITE = 'BAG'
	BEGIN

		SELECT TOP 5 [SITEFLAG]
			  ,[SHIFTFLAG]
			  ,[DUMPNAME]
			  --,[TOTAL_MIN_OVER_EXPECTED]
			  ,ROUND([deltac],1) AS AvgDeltaC
			  ,ROUND([DeltaCTarget],1) AS AvgDeltaCTarget
		FROM [bag].[CONOPS_BAG_TM_HAUL_STATUS_V] WITH (NOLOCK)
		WHERE [SHIFTFLAG] = @SHIFT
		ORDER BY [TOTAL_MIN_OVER_EXPECTED] desc;

		SELECT TOP 5 [SITEFLAG]
			  ,[SHIFTFLAG]
			  ,[DUMPNAME]
			  ,ROUND([deltac],1)
			  ,ROUND([DeltaCTarget],1)
			  ,ROUND([idletime],1) [idletime]
			  ,ROUND([idletimetarget],1) [idletimetarget]
			  ,ROUND([spotting],1) [spotting]
			  ,ROUND([SpottingTarget],1) [SpottingTarget]
			  ,ROUND([loading],1) [loading]
			  ,ROUND([LoadingTarget],1) [LoadingTarget]
			  ,ROUND([LoadedTravel],1) [LoadedTravel]
			  ,ROUND([loadedtraveltarget],1) [loadedtraveltarget]
			  ,ROUND([Dumping],1) [Dumping]
			  ,ROUND([DumpingTarget],1) [DumpingTarget]
			  ,ROUND([DumpingAtStockpile],1) [DumpingAtStockpile]
			  ,ROUND([DumpingAtStockpileTarget],1) [DumpingAtStockpileTarget]
			  ,ROUND([DumpingAtCrusher],1) [DumpingAtCrusher]
			  ,ROUND([DumpingAtCrusherTarget],1) [DumpingAtCrusherTarget]
			  ,ROUND([EmptyTravel],1) [EmptyTravel]
			  ,ROUND([emptytraveltarget],1) [emptytraveltarget]
		FROM [bag].[CONOPS_BAG_TM_HAUL_STATUS_V] WITH (NOLOCK)
		WHERE [SHIFTFLAG] = @SHIFT
		ORDER BY [TOTAL_MIN_OVER_EXPECTED] desc;

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT TOP 5 [SITEFLAG]
			  ,[SHIFTFLAG]
			  ,[DUMPNAME]
			  --,[TOTAL_MIN_OVER_EXPECTED]
			  ,ROUND([deltac],1) AS AvgDeltaC
			  ,ROUND([DeltaCTarget],1) AS AvgDeltaCTarget
		FROM [cer].[CONOPS_CER_TM_HAUL_STATUS_V] WITH (NOLOCK)
		WHERE [SHIFTFLAG] = @SHIFT
		ORDER BY [TOTAL_MIN_OVER_EXPECTED] desc;

		SELECT TOP 5 [SITEFLAG]
			  ,[SHIFTFLAG]
			  ,[DUMPNAME]
			  ,ROUND([deltac],1)
			  ,ROUND([DeltaCTarget],1)
			  ,ROUND([idletime],1) [idletime]
			  ,ROUND([idletimetarget],1) [idletimetarget]
			  ,ROUND([spotting],1) [spotting]
			  ,ROUND([SpottingTarget],1) [SpottingTarget]
			  ,ROUND([loading],1) [loading]
			  ,ROUND([LoadingTarget],1) [LoadingTarget]
			  ,ROUND([LoadedTravel],1) [LoadedTravel]
			  ,ROUND([loadedtraveltarget],1) [loadedtraveltarget]
			  ,ROUND([Dumping],1) [Dumping]
			  ,ROUND([DumpingTarget],1) [DumpingTarget]
			  ,ROUND([DumpingAtStockpile],1) [DumpingAtStockpile]
			  ,ROUND([DumpingAtStockpileTarget],1) [DumpingAtStockpileTarget]
			  ,ROUND([DumpingAtCrusher],1) [DumpingAtCrusher]
			  ,ROUND([DumpingAtCrusherTarget],1) [DumpingAtCrusherTarget]
			  ,ROUND([EmptyTravel],1) [EmptyTravel]
			  ,ROUND([emptytraveltarget],1) [emptytraveltarget]
		FROM [cer].[CONOPS_CER_TM_HAUL_STATUS_V] WITH (NOLOCK)
		WHERE [SHIFTFLAG] = @SHIFT
		ORDER BY [TOTAL_MIN_OVER_EXPECTED] desc;

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT TOP 5 [SITEFLAG]
			  ,[SHIFTFLAG]
			  ,[DUMPNAME]
			  --,[TOTAL_MIN_OVER_EXPECTED]
			  ,ROUND([deltac],1) AS AvgDeltaC
			  ,ROUND([DeltaCTarget],1) AS AvgDeltaCTarget
		FROM [chi].[CONOPS_CHI_TM_HAUL_STATUS_V] WITH (NOLOCK)
		WHERE 