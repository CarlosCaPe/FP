CREATE VIEW [bag].[ZZZ_CONOPS_BAG_EOS_KPI_SUMMARY_V_OLD] AS









-- SELECT * FROM [bag].[CONOPS_BAG_EOS_KPI_SUMMARY_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [bag].[CONOPS_BAG_EOS_KPI_SUMMARY_V]  
AS  
  
WITH CteShiftInfo AS (
	SELECT [SiteFlag]
		,[ShifTFlag]
		,[ShiftId]
		,[ShiftIndex]
	FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] WITH (NOLOCK)
),

GetHosQuery AS (
	SELECT TOP 1 
		(CASE 
			WHEN Hos > 10 THEN 10
			WHEN Hos < 1 THEN 1
		END) AS Hos
	FROM [dbo].[LH_DUMP] WITH (NOLOCK)
	WHERE site_code = 'BAG' and shiftindex = (SELECT ShiftIndex FROM CteShiftInfo WHERE ShiftFlag = 'CURR') 
	ORDER BY hos DESC
),

GetShiftChangeAvgDuration AS (
	SELECT ShiftIndex
		,CAST( COALESCE( AVG( Duration)/ 60, 0) AS DECIMAL(7,2)) AS [AvgDuration]
    FROM [dbo].status_event
    WHERE Site_Code = 'BAG'
    AND Status = 4
    AND Reason = 439
    AND Unit = 1
	GROUP BY ShiftIndex
),

CTEShiftChange AS (
	SELECT [hd].ShiftIndex
		,[csi].ShiftFlag
		,SUM(CASE [hd].hos WHEN 0 THEN [hd].dumptons ELSE 0 END) AS FirstHourTonsTotal 
        ,AVG(CASE [hd].hos 
            WHEN 1 THEN [hd].dumptons
            WHEN 2 THEN [hd].dumptons 
            WHEN 3 THEN [hd].dumptons 
            WHEN 4 THEN [hd].dumptons 
            WHEN 5 THEN [hd].dumptons 
            WHEN 6 THEN [hd].dumptons 
            WHEN 7 THEN [hd].dumptons 
            WHEN 8 THEN [hd].dumptons 
            WHEN 9 THEN [hd].dumptons 
            WHEN 10 THEN [hd].dumptons
            ELSE 0 END) AS MiddleHourTonsTotal
        ,SUM(CASE [hd].hos WHEN 11 THEN [hd].dumptons ELSE 0 END) AS LastHourTonsTotal 
    FROM [dbo].LH_DUMP as [hd] 
	LEFT JOIN CteShiftInfo [csi]
		ON [hd].ShiftIndex = [csi].ShiftIndex
		AND [hd].Site_Code = [csi].SiteFlag
    WHERE [hd].site_code = 'BAG'
	GROUP BY [hd].ShiftIndex, [csi].ShiftFlag
),

ShiftSummaryKpi AS (
	SELECT ShiftIndex
		,ShiftFlag
		,NULLIF(SUM(FirstHourTonsTotal), 0)as FirstHourTonsTotal
		,NULLIF(SUM(LastHourTonsTotal), 0) as LastHourTonsTotal
		,NULLIF(SUM(MiddleHourTonsTotal), 0) as MiddleHourTonsTotal
	FROM CTEShiftChange
	GROUP BY ShiftIndex, ShiftFlag
)

SELECT [ssk].ShiftIndex
	,'BAG' AS SiteFlag
	,[ssk].ShiftFlag
	,[ksh].HaulageEfficiency AS HaulageEfficiency
	,COALESCE([FirstHourTonsTotal], 0) AS FirstHourTonsTotal
	,COALESCE([LastHourTonsTotal], 0) AS LastHourTonsTotal
	,COALESCE([MiddleHourTonsTotal], 0) AS MiddleHourTonsTotal
	,COALESCE(CASE WHEN [MiddleHourTonsTotal] > 0 THEN ((([FirstHourTonsTotal] + [LastHourTonsTotal]) / 2) / [MiddleHourTonsTotal]) * 100
		ELSE 0 
	END, 0) AS ShiftChangeEfficiency
	,COALESCE([scad].AvgDuration, 0) AS AvgShiftChgDuration
FROM ShiftSummaryKpi [ssk]
LEFT JOIN GetShiftChangeAvgDuration [scad]
	ON [ssk].ShiftIndex = [scad].ShiftIndex
LEFT JOIN [bag].[CONOPS_BAG_EOS_KPI_SUMMARY_HAULAGE_V] [ksh] WITH (NOLOCK)
	ON [ssk].ShiftIndex = [ksh].ShiftIndex
	AND [ssk].ShiftFlag = [ksh].ShiftFlag
GROUP BY [ssk].ShiftIndex, [ssk].ShiftFlag, FirstHourTonsTotal, LastHourTonsTotal, MiddleHourTonsTotal, [scad].AvgDuration, [ksh].HaulageEfficiency

