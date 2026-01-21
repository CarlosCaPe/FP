


/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_DeltaC_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_DeltaC_Get 'PREV', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created}  
* {25 Jan 2023}		{lwasini}		{Implement Safford data.}  
* {27 Jan 2023}		{jrodulfa}		{Change SAF sitecode to SAM.}  
* {03 Feb 2023}		{sxavier}		{Add Alias fro DeltaCTarget.}  
* {03 Feb 2023}		{jrodulfa}		{Implement Chino Data.}
* {10 Feb 2023}		{mbote}		    {Implement Cerro Verde Data.}
* {02 Jan 2024}		{lwasini}		{Implement Tyrone Data.}
* {23 Jan 2024}		{lwasini}		{Add ABR}
* {18 Feb 2025}     {ggosal1}		{Change Overall DeltaC Rounding}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_DeltaC_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN    
BEGIN TRY	IF @SITE = 'BAG'
	BEGIN

		-- Delta C Overview
		SELECT
			ROUND(AVG(delta_c),1) as ShiftAverage,
			DeltaCTarget AS [Target]
		FROM BAG.[CONOPS_BAG_OVERALL_DELTA_C_V] 
		WHERE shiftflag = @SHIFT
		GROUP BY DeltaCTarget;

		--List top 5 worst shovel for overview
		SELECT TOP 5 
			excav AS [Name], 
			ROUND(AVG(delta_c),1) as [Actual], 
			deltac_ts AS [DateTime]
		INTO #TempTableShovelsBAG
		FROM BAG.[CONOPS_BAG_DELTA_C_WORST_SHOVEL_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		GROUP BY excav, siteflag, shiftflag,deltac_ts
		ORDER BY Actual DESC;

		--List top 5 worst truck for overview
		SELECT TOP 5 
			truck AS [Name],
			ROUND(AVG(delta_c),1) as [Actual],
			deltac_ts AS [DateTime]	
		INTO #TempTableTrucksBAG
		FROM BAG.[CONOPS_BAG_DELTA_C_WORST_TRUCK_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		GROUP BY truck, siteflag, shiftflag,deltac_ts
		ORDER BY Actual DESC;

		SELECT * FROM #TempTableShovelsBAG
		SELECT * FROM #TempTableTrucksBAG

		--List Shovel Detail 
		SELECT 
			A.excav AS [Name], 
			ROUND(AVG(A.Delta_C),1) AS Actual, 
			A.deltac_ts AS [DateTime]
		FROM 
		#TempTableShovelsBAG B
		LEFT JOIN BAG.[CONOPS_BAG_DELTA_C_WORST_SHOVEL_V] A ON A.excav = B.[Name]
		WHERE A.shiftflag = @SHIFT
		GROUP BY A.excav, A.deltac_ts
		ORDER BY A.excav, A.deltac_ts ASC;

		--List Truck Detail
		SELECT 
			A.truck AS [Name], 
			ROUND(AVG(A.Delta_C),1) AS Actual, 
			A.deltac_ts AS [DateTime]
		FROM #TempTableTrucksBAG B
		LEFT JOIN BAG.[CONOPS_BAG_DELTA_C_WORST_TRUCK_V] A ON A.truck = B.[Name]
		WHERE A.shiftflag = @SHIFT
		GROUP BY A.truck, A.deltac_ts
		ORDER BY A.truck, A.deltac_ts ASC;

		--list of deltac for overview
		SELECT 
			'Average Times' AS [Name],
			ROUND(a.delta_c,1) AS Actual, 
			a.deltac_ts AS [DateTime],
			a.shiftstartdatetime AS [ShiftStartDateTime],
			b.OEE * 100 as [OeeActual],
			0 AS OeeTarget
		FROM BAG.[CONOPS_BAG_DELTA_C_V] a (NOLOCK)
		LEFT JOIN BAG.[CONOPS_BAG_OEE_V] b (NOLOCK)
		ON a.shiftid = b.shiftid AND a.siteflag = b.siteflag
		WHERE a.shiftflag = @SHIFT
		ORDER BY a.deltac_ts ASC;

		DROP TABLE #TempTableShovelsBAG
		DROP TABLE #TempTableTrucksBAG

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		-- Delta C Overview
		SELECT
			ROUND(AVG(delta_c),1) as ShiftAverage,
			DeltaCTarget AS [Target]
		FROM CER.[CONOPS_CER_OVERALL_DELTA_C_V] 
		WHERE shiftflag = @SHIFT
		GROUP BY DeltaCTarget;

		--List top 5 worst shovel for overview
		SELECT TOP 5 
			excav AS [Name], 
			ROUND(AVG(delta_c),1) as [Actual], 
			deltac_ts AS [DateTime]
		INTO #TempTableShovelsCER
		FROM CER.[CONOPS_CER_DELTA_C_WORST_SHOVEL_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		GROUP BY excav, siteflag, shiftflag,deltac_ts
		ORDER BY Actual DESC;

		--List top 5 worst truck for overview
		SELECT TOP 5 
			truck AS [Name],
			ROUND(AVG(delta_c),1) as [Actual],