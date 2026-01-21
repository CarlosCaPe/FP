CREATE VIEW [chi].[ZZZ_CONOPS_CHI_EOS_KPI_SUMMARY_V_OLD] AS








-- SELECT * FROM [chi].[CONOPS_CHI_EOS_KPI_SUMMARY_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [chi].[CONOPS_CHI_EOS_KPI_SUMMARY_V]  
AS  
  
WITH CteShiftInfo AS (
	SELECT [SiteFlag]
		,[ShifTFlag]
		,[ShiftId]
		,[ShiftIndex]
	FROM [chi].[CONOPS_CHI_SHIFT_INFO_V] WITH (NOLOCK)
),

GetHosQuery AS (
	SELECT TOP 1 
		(CASE 
			WHEN Hos > 10 THEN 10
			WHEN Hos < 1 THEN 1
		END) AS Hos
	FROM [dbo].[LH_DUMP] WITH (NOLOCK)
	WHERE site_code = 'CHI' and shiftindex = (SELECT ShiftIndex FROM CteShiftInfo WHERE ShiftFlag = 'CURR') 
	ORDER BY hos DESC
),

GetShiftChangeAvgDuration AS (
	SELECT ShiftIndex
		,CAST( COALESCE( AVG( Duration)/ 60, 0) AS DECIMAL(7,2)) AS [AvgDuration]
    FROM [dbo].status_event
    WHERE Site_Code = 'CHI'
    AND Status = 4
    AND Reason = 439
    AND Unit = 1
	GROUP BY ShiftIndex
),

CTEShiftChange AS (
	SELECT ShiftIndex
		,ShifTFlag
		,CAST(COALESCE(SUM(FirstHourTons), 0) AS DECIMAL(10, 2)) AS FirstHourTonsTotal
        ,CAST(COALESCE(SUM(LastHourTons), 0) AS DECIMAL(10, 2)) AS LastHourTonsTotal
        --,CAST(COALESCE(SUM(MiddleHourTons), 0) / 10 AS DECIMAL(10, 2)) AS MiddleHourTonsTotal // Don't Delete for future reference
		,COALESCE(AVG(MiddleHourTons), 0) AS MiddleHourTonsTotal
    FROM (
		SELECT [ld].ShiftIndex
			,[csi].ShiftFlag
			,CASE WHEN TimeDump < 3600 THEN sum(DumpTons) ELSE 0 END AS FirstHourTons
            ,CASE WHEN TimeDump BETWEEN 3601 and 39600 THEN sum(DumpTons) ELSE 0 END AS MiddleHourTons
            ,CASE WHEN TimeDump > 39600 THEN sum(DumpTons) ELSE 0 END AS LastHourTons
        FROM [dbo].LH_DUMP [ld]
		LEFT JOIN CteShiftInfo [csi]
			ON [ld].ShiftIndex = [csi].ShiftIndex
			AND [ld].Site_Code = [csi].SiteFlag
        WHERE Site_Code = 'CHI'
        AND Extraload = 0
        AND Loc NOT LIKE 'ROAD%' 
        AND Loc NOT LIKE '901%'
        AND Blast NOT LIKE 'K WASTE%' 
        AND Blast NOT LIKE 'SP309LDR'
        GROUP BY DumpTons, TimeDump, [ld].ShiftIndex, [csi].ShiftFlag
	) AS [iq]
	GROUP BY ShiftIndex, ShiftFlag
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
	,'CHI' AS SiteFlag
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
LEFT JOIN [chi].[CONOPS_CHI_EOS_KPI_SUMMARY_HAULAGE_V] [ksh] WITH (NOLOCK)
	ON [ssk].ShiftIndex = [ksh].ShiftIndex
	AND [ssk].ShiftFlag = [ksh].ShiftFlag
GROUP BY [ssk].ShiftIndex, [ssk].ShiftFlag, FirstHourTonsTotal, LastHourTonsTotal, MiddleHourTonsTotal, [scad].AvgDuration, [ksh].HaulageEfficiency

