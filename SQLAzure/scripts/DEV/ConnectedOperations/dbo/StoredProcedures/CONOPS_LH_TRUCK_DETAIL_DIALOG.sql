

/******************************************************************  
* PROCEDURE	: dbo.CONOPS_LH_TRUCK_DETAIL_DIALOG
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 06 Dec 2022
* SAMPLE	: 
	1. EXEC dbo.CONOPS_LH_TRUCK_DETAIL_DIALOG 'CURR', 'MOR', 'T501'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {06 Dec 2022}		{jrodulfa}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[CONOPS_LH_TRUCK_DETAIL_DIALOG] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@TRUCKID VARCHAR(10)
)
AS                        
BEGIN          
	
	SELECT [t].shiftflag,
		   [t].siteflag,
		   [t].[TruckID],
		   [t].[Location],
		   [t].[Operator],
		   [t].[StatusDesc],
		   COALESCE([t].EFH, 0) [EFH]
	FROM [dbo].[CONOPS_TRUCK_DETAIL_V] [t] WITH (NOLOCK)
	WHERE shiftflag = @SHIFT
		  AND siteflag = @SITE
		  AND [t].[TruckID] = @TRUCKID;

	SELECT 'Total Material Delivered' [KPI],
		   COALESCE([AVG_Payload], 0) [Actual],
		   COALESCE(Target, 0) [Target]
	FROM [CONOPS_TP_AVG_PAYLOAD_V] WITH (NOLOCK)
	WHERE shiftflag = @SHIFT AND TRUCK = @TRUCKID
	UNION ALL
	SELECT 'Delta C' [KPI],
		   COALESCE(AVG([Delta_C]), 0) [Actual],
		   COALESCE(AVG([Delta_c_target]), 0) [Target]
	FROM [dbo].[CONOPS_LH_DELTA_C_V] WITH (NOLOCK)
	WHERE shiftflag = @SHIFT AND [truck] = @TRUCKID
	UNION ALL
	SELECT 'Idle Time' [KPI],
		   COALESCE(AVG([truck_idledelta]), 0) [Actual],
		   1.1 [Target]
	FROM [dbo].[CONOPS_LH_OVERVIEW_DELTA_C_V] WITH (NOLOCK)
	WHERE shiftflag = @SHIFT AND [truck] = @TRUCKID
	UNION ALL
	SELECT 'Spotting' [KPI],
		   COALESCE(AVG([spotdelta]), 0) [Actual],
		   (SELECT TOP 1 Spoting FROM [mor].[plan_values_prod_sum] WITH (NOLOCK) ORDER BY DateEffective desc) [Target]
	FROM [dbo].[CONOPS_LH_OVERVIEW_DELTA_C_V] WITH (NOLOCK)
	WHERE shiftflag = @SHIFT AND [truck] = @TRUCKID
	UNION ALL
	SELECT 'Loading' [KPI],
		   COALESCE(AVG([loaddelta]), 0) [Actual],
		   (SELECT TOP 1 Loading FROM [mor].[plan_values_prod_sum] WITH (NOLOCK) ORDER BY DateEffective desc) [Target]
	FROM [dbo].[CONOPS_LH_OVERVIEW_DELTA_C_V] WITH (NOLOCK)
	WHERE shiftflag = @SHIFT AND [truck] = @TRUCKID
	UNION ALL
	SELECT 'Dumping' [KPI],
		   COALESCE(AVG([dumpdelta]), 0) [Actual],
		   (SELECT TOP 1 [DumpingAtCrusher] + [DumpingatStockpile] [Dumping] FROM [mor].[plan_values_prod_sum] WITH (NOLOCK) ORDER BY DateEffective desc) [Target]
	FROM [dbo].[CONOPS_LH_OVERVIEW_DELTA_C_V] WITH (NOLOCK)
	WHERE shiftflag = @SHIFT AND [truck] = @TRUCKID
	UNION ALL
	SELECT 'EFH' [KPI],
		   COALESCE([EFH], 0) [Actual],
		   (SELECT TOP 1 [EquivalentFlatHaul] FROM [mor].[plan_values_prod_sum] WITH (NOLOCK) ORDER BY DateEffective desc) [Target]
	FROM [dbo].[CONOPS_TRUCK_DETAIL_V] WITH (NOLOCK)
	WHERE shiftflag = @SHIFT AND [truckID] = @TRUCKID
	UNION ALL
	SELECT 'Dumping at Stockpile' [KPI],
		   COALESCE(AVG([dumpdelta]), 0) [Actual],
		   (SELECT TOP 1 [DumpingatStockpile] FROM [mor].[plan_values_prod_sum] WITH (NOLOCK) ORDER BY DateEffective desc) [Target]
	FROM [dbo].[CONOPS_LH_OVERVIEW_DELTA_C_V] WITH (NOLOCK)
	WHERE shiftflag = @SHIFT AND [Truck] = @TRUCKID
		  AND unit = 'Stockpile'
	UNION ALL
	SELECT 'Dumping at Crusher' [KPI],
		   COALESCE(AVG([dumpdelta]), 0) [Actual],
		   (SELECT TOP 1 [DumpingAtCrusher] FROM [mor].[plan_values_prod_sum] WITH (NOLOCK) ORDER BY DateEffective desc) [Target]
	FROM [dbo].[CONOPS_LH_OVERVIEW_DELTA_C_V] WITH (NOLOCK)
	WHERE shiftflag = @SHIFT AND [Truck] = @TRUCKID
		  AND unit = 'Crusher'
	--SELECT 'Dumping at Crusher' [KPI],
	--	   [totalDump] [Actual],
	--	   (SELECT TOP 1 [CrusherMFLtpd] + [CrusherMilltpd] FROM [mor].[plan_values_prod_sum] WITH (NOLOCK) ORDER BY DateEffective desc) [Target]
	--FROM [dbo].[CONOPS_TRUCK_DUMPING_TO_CRUSHER_V] WITH (NOLOCK)
	--WHERE shiftflag = @SHIFT AND [Truck] = @TRUCKID
	UNION ALL
	SELECT 'Avg Use of Availab