

/******************************************************************  
* PROCEDURE	: dbo.CONOPS_LH_DELTA_C
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_DeltaC_Get 'PREV', 'CVE'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created}  
* {25 Jan 2023}		{lwasini}		{Implement Safford data.}  
* {27 Jan 2023}		{jrodulfa}		{Change SAF sitecode to SAM.}  
* {03 Feb 2023}		{sxavier}		{Add Alias fro DeltaCTarget.}  
* {03 Feb 2023}		{jrodulfa}		{Implement Chino Data.}
* {10 Feb 2023}		{mbote}		    {Implement Cerro Verde Data.}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_DeltaC_Get_OLD] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN    

	SET @SITE = CASE @SITE
					WHEN 'SAM' THEN 'SAF'
					WHEN 'CVE' THEN 'CER'
					WHEN 'CHN' THEN 'CHI'
					ELSE @SITE
				END;
	
	-- Delta C Overview
	SELECT
		ROUND(AVG(delta_c),1) as ShiftAverage,
		DeltaCTarget AS [Target]
	FROM 
		[dbo].[CONOPS_LH_OVERALL_DELTA_C_V] (NOLOCK)
	WHERE 
		shiftflag = @SHIFT
		AND siteflag = @SITE
	GROUP BY DeltaCTarget;

	--List top 5 worst shovel for overview
	SELECT TOP 5 
		excav AS [Name], 
		ROUND(AVG(delta_c),1) as [Actual], 
		deltac_ts AS [DateTime]
		
	INTO
		#TempTableShovels
	FROM 
		[dbo].[CONOPS_LH_DELTA_C_WORST_SHOVEL_V] (NOLOCK)
	WHERE 
		shiftflag = @SHIFT
		AND siteflag = @SITE
	GROUP BY excav, siteflag, shiftflag,deltac_ts
	ORDER BY Actual DESC;

	--List top 5 worst truck for overview
	SELECT TOP 5 
		truck AS [Name],
		ROUND(AVG(delta_c),1) as [Actual],
		deltac_ts AS [DateTime]
		
	INTO 
		#TempTableTrucks
	FROM 
		[dbo].[CONOPS_LH_DELTA_C_WORST_TRUCK_V] (NOLOCK)
	WHERE 
		shiftflag = @SHIFT
		AND siteflag = @SITE
	GROUP BY truck, siteflag, shiftflag,deltac_ts
	ORDER BY Actual DESC;

	SELECT * FROM #TempTableShovels
	SELECT * FROM #TempTableTrucks

	--List Shovel Detail 
	SELECT 
		A.excav AS [Name], 
		ROUND(AVG(A.Delta_C),1) AS Actual, 
		A.deltac_ts AS [DateTime]
	FROM 
		#TempTableShovels B
		LEFT JOIN [dbo].[CONOPS_LH_DELTA_C_WORST_SHOVEL_V] A ON A.excav = B.[Name]
		
		--[dbo].[CONOPS_LH_DELTA_C_WORST_SHOVEL_V] A (NOLOCK)
		--INNER JOIN #TempTableShovels B ON A.excav = B.[Name]
	WHERE 
		A.shiftflag = @SHIFT
		AND A.siteflag = @SITE
	GROUP BY A.excav, A.deltac_ts
	ORDER BY A.excav, A.deltac_ts ASC;

	--List Truck Detail
	SELECT 
		A.truck AS [Name], 
		ROUND(AVG(A.Delta_C),1) AS Actual, 
		A.deltac_ts AS [DateTime]
	FROM 
		#TempTableTrucks B
		LEFT JOIN [dbo].[CONOPS_LH_DELTA_C_WORST_TRUCK_V] A ON A.truck = B.[Name]
		--[dbo].[CONOPS_LH_DELTA_C_WORST_TRUCK_V] A (NOLOCK)
		--INNER JOIN #TempTableTrucks B ON A.truck = B.[Name]
	WHERE 
		A.shiftflag = @SHIFT
		AND A.siteflag = @SITE
	GROUP BY A.truck, A.deltac_ts
	ORDER BY A.truck, A.deltac_ts ASC;

	--list of deltac for overview
	SELECT 
		'Average Times' AS [Name],
		ROUND(a.delta_c,1) AS Actual, 
		a.deltac_ts AS [DateTime],
		a.shiftstartdatetime AS [ShiftStartDateTime],
		b.OEE as [OeeActual]
		
	FROM 
		[dbo].[CONOPS_LH_DELTA_C_OVERVIEW_V] a (NOLOCK)
	LEFT JOIN
		[dbo].[CONOPS_LH_OEE_V] b (NOLOCK)
		ON a.shiftid = b.shiftid
		AND a.siteflag = b.siteflag
	WHERE 
		a.shiftflag = @SHIFT
		AND a.siteflag = @SITE
	ORDER BY a.deltac_ts ASC;

	DROP TABLE #TempTableShovels
	DROP TABLE #TempTableTrucks

SET NOCOUNT OFF
END

