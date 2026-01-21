







/******************************************************************  
* PROCEDURE	: dbo.CrushAndConvey_CrusherMatrix_DispatchSummary_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 07 Jul 2023
* SAMPLE	: 
	1. EXEC dbo.CrushAndConvey_CrusherMatrix_DispatchSummary_Get 'CURR', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {07 Jul 2023}		{jrodulfa}		{Initial Created} 
* {13 Sep 2023}		{lwasini}		{Update AvgIntraArrivalTime to 0} 
* {18 Dec 2023}		{lwasini}		{MVP 9} 
* {30 Jan 2024}		{lwasini}		{Add TYR & ABR} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[CrushAndConvey_CrusherMatrix_DispatchSummary_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          
	
	IF @SITE = 'BAG'
	BEGIN

		SELECT [CrusherLoc]
			  ,ROUND(AVG([AvgTimeAtCrusher]),1) [AvgTimeAtCrusher]
			  --,ROUND(AVG([AvgIntraArrivalTime]),1) [AvgIntraArrivalTime]
			  ,0 [AvgIntraArrivalTime]
			  ,AVG([AvgTrafficIntensity]) [AvgTrafficIntensity]
			  ,SUM([NrofLoad]) [NrofLoad]
			  ,ROUND(AVG([AvgMinIdle]),1) [AvgMinIdle]
			  ,ROUND(AVG([AvgDumpTime]),1) [AvgDumpTime]
			  ,SUM([Tons]) [Tons]
			  ,SUM([NrofDump]) [NrofDump]
		FROM [bag].[CONOPS_BAG_CM_DISPATCH_SUMMARY_V]
		WHERE [SHIFTFLAG] = @SHIFT
		GROUP BY [CrusherLoc]

		UNION ALL

		SELECT 'Overall' [CrusherLoc]
			  ,ROUND(AVG([AvgTimeAtCrusher]),1) [AvgTimeAtCrusher]
			  --,ROUND(AVG([AvgIntraArrivalTime]),1) [AvgIntraArrivalTime]
			  ,0 [AvgIntraArrivalTime]
			  ,AVG([AvgTrafficIntensity]) [AvgTrafficIntensity]
			  ,SUM([NrofLoad]) [NrofLoad]
			  ,ROUND(AVG([AvgMinIdle]),1) [AvgMinIdle]
			  ,ROUND(AVG([AvgDumpTime]),1) [AvgDumpTime]
			  ,SUM([Tons]) [Tons]
			  ,SUM([NrofDump]) [NrofDump]
		FROM [bag].[CONOPS_BAG_CM_DISPATCH_SUMMARY_V]
		WHERE [SHIFTFLAG] = @SHIFT;

		SELECT [CrusherLoc]
			  ,ROUND(AVG([AvgTimeAtCrusher]),1) [AvgTimeAtCrusher]
			  --,ROUND(AVG([AvgIntraArrivalTime]),1) [AvgIntraArrivalTime]
			  ,0 [AvgIntraArrivalTime]
			  ,AVG([AvgTrafficIntensity]) [AvgTrafficIntensity]
			  ,SUM([NrofLoad]) [NrofLoad]
			  ,ROUND(AVG([AvgMinIdle]),1) [AvgMinIdle]
			  ,ROUND(AVG([AvgDumpTime]),1) [AvgDumpTime]
			  ,SUM([Tons]) [Tons]
			  ,SUM([NrofDump]) [NrofDump]
		FROM [bag].[CONOPS_BAG_CM_DISPATCH_SUMMARY_V]
		WHERE [SHIFTFLAG] = @SHIFT
		GROUP BY [CrusherLoc]
		ORDER BY [CrusherLoc];

		SELECT [Hr]
			  ,[CrusherLoc]
			  ,ROUND(AVG([AvgTimeAtCrusher]),1) [AvgTimeAtCrusher]
			  --,ROUND(AVG([AvgIntraArrivalTime]),1) [AvgIntraArrivalTime]
			  , 0 AvgIntraArrivalTime
			  ,AVG([AvgTrafficIntensity]) [AvgTrafficIntensity]
			  ,SUM([NrofLoad]) [NrofLoad]
			  ,ROUND(AVG([AvgMinIdle]),1) [AvgMinIdle]
			  ,ROUND(AVG([AvgDumpTime]),1) [AvgDumpTime]
			  ,SUM([Tons]) [Tons]
			  ,SUM([NrofDump]) [NrofDump]
		FROM [bag].[CONOPS_BAG_CM_DISPATCH_SUMMARY_V]
		WHERE [SHIFTFLAG] = @SHIFT
		GROUP BY [Hr],[CrusherLoc]
		--ORDER BY [Hr],[CrusherLoc]

		UNION ALL

		SELECT [Hr]
			  ,'Overall' [CrusherLoc]
			  ,ROUND(AVG([AvgTimeAtCrusher]),1) [AvgTimeAtCrusher]
			  --,ROUND(AVG([AvgIntraArrivalTime]),1) [AvgIntraArrivalTime]
			  , 0 AvgIntraArrivalTime
			  ,AVG([AvgTrafficIntensity]) [AvgTrafficIntensity]
			  ,SUM([NrofLoad]) [NrofLoad]
			  ,ROUND(AVG([AvgMinIdle]),1) [AvgMinIdle]
			  ,ROUND(AVG([AvgDumpTime]),1) [AvgDumpTime]
			  ,SUM([Tons]) [Tons]
			  ,SUM([NrofDump]) [NrofDump]
		FROM [bag].[CONOPS_BAG_CM_DISPATCH_SUMMARY_V]
		WHERE [SHIFTFLAG] = @SHIFT
		GROUP BY [Hr]--,[CrusherLoc]
		ORDER BY [Hr],[CrusherLoc];

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT [CrusherLoc]
			  ,ROUND(AVG([AvgTimeAtCrusher]),1) [AvgTimeAtCrusher]
			  --,ROUND(AVG([AvgIntraArrivalTime]),1) [AvgIntraArrivalTime]
			  ,0 [AvgIntraArrivalTime]
			  ,AVG([AvgTrafficIntensity]) [AvgTrafficIntensity]
			  ,SUM([NrofLoad]