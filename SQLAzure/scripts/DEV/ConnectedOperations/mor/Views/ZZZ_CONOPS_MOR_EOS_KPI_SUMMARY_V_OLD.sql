CREATE VIEW [mor].[ZZZ_CONOPS_MOR_EOS_KPI_SUMMARY_V_OLD] AS



-- SELECT * FROM [mor].[CONOPS_MOR_EOS_KPI_SUMMARY_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [mor].[CONOPS_MOR_EOS_KPI_SUMMARY_V]  
AS  
  
WITH CteShiftInfo AS (
	SELECT [SiteFlag]
		,[ShifTFlag]
		,[ShiftId]
		,[ShiftIndex]
	FROM [mor].[CONOPS_MOR_SHIFT_INFO_V] WITH (NOLOCK)
),

GetHosQuery AS (
	SELECT TOP 1 
		(CASE 
			WHEN Hos > 10 THEN 10
			WHEN Hos < 1 THEN 1
		END) AS Hos
	FROM [dbo].[LH_DUMP] WITH (NOLOCK)
	WHERE site_code = 'MOR' and shiftindex = (SELECT ShiftIndex FROM CteShiftInfo WHERE ShiftFlag = 'CURR') 
	ORDER BY hos DESC
),

GetShiftChangeAvgDuration AS (
	SELECT ShiftIndex
		,CAST( COALESCE( AVG( Duration)/ 60, 0) AS DECIMAL(7,2)) AS [AvgDuration]
    FROM [dbo].status_event
    WHERE Site_Code = 'MOR'
    AND Status = 4
    AND Reason = 401
    AND Unit = 1
	GROUP BY ShiftIndex
),

CTEShiftChange AS (
	SELECT ShiftIndex
		,ShiftFlag
		,COALESCE(SUM(FirstHourTons), 0) AS FirstHourTonsTotal
		,COALESCE(SUM(LastHourTons), 0) AS LastHourTonsTotal
		,COALESCE(SUM(MiddleHourTons), 0) AS MiddleHourTonsTotal
	FROM (
		SELECT ShiftIndex
			,'PREV' AS ShiftFlag
			,SUM(CASE WHEN timedump >= 43200 THEN (dumptons) ELSE 0 END) AS FirstHourTons
			,CAST(0.00 AS REAL) AS MiddleHourTons
			,CAST(0.00 AS REAL) AS LastHourTons
			,Hos
		FROM [dbo].[LH_DUMP] WITH (NOLOCK)
		WHERE site_code = 'MOR'
			AND ShiftIndex = (SELECT ShiftIndex FROM CteShiftInfo WHERE ShiftFlag = 'PREV')
			AND Hos = 0
		GROUP BY ShiftIndex, Hos, Dumptons, Timedump
	) AS iq
	GROUP BY ShiftIndex, ShiftFlag
	UNION ALL
	SELECT ShiftIndex
		,ShiftFlag
		,COALESCE(SUM(FirstHourTons), 0) as FirstHourTonsTotal
		,COALESCE(SUM(LastHourTons), 0) as LastHourTonsTotal
		,COALESCE(AVG(MiddleHourTons), 0)/ (
										SELECT Hos
										FROM GetHosQuery
									) AS MiddleHourTonsTotal
	FROM ( 
		SELECT ShiftIndex
			,'CURR' AS ShiftFlag
			,CASE WHEN timedump < 3600 then SUM(dumptons) else 0 end as FirstHourTons
			,CASE WHEN timedump between 3601 and 39600 then SUM(dumptons) else 0 end as MiddleHourTons
			,CASE WHEN timedump > 39600 then SUM(dumptons) else 0 end as LastHourTons
			,hos
		FROM [dbo].[LH_DUMP] WITH (NOLOCK)
		WHERE site_code = 'MOR'
			and shiftindex = (SELECT ShiftIndex FROM CteShiftInfo WHERE ShiftFlag = 'CURR')
			and extraload = 0
		GROUP BY ShiftIndex, hos, dumptons, timedump
	) AS iq2
	GROUP BY ShiftIndex, ShiftFlag
),

ShiftSummaryKpi AS (
	SELECT ShiftIndex
		,ShiftFlag
		,COALESCE(SUM(FirstHourTonsTotal), 0)as FirstHourTonsTotal
		,COALESCE(SUM(LastHourTonsTotal), 0) as LastHourTonsTotal
		,COALESCE(SUM(MiddleHourTonsTotal), 0) as MiddleHourTonsTotal
	FROM CTEShiftChange
	GROUP BY ShiftIndex, ShiftFlag
)

SELECT [ssk].ShiftIndex
	,'MOR' AS SiteFlag
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
LEFT JOIN [mor].[CONOPS_MOR_EOS_KPI_SUMMARY_HAULAGE_V] [ksh] WITH (NOLOCK)
	ON [ssk].ShiftIndex = [ksh].ShiftIndex
	AND [ssk].ShiftFlag = [ksh].ShiftFlag
GROUP BY [ssk].ShiftIndex, [ssk].ShiftFlag, FirstHourTonsTotal, LastHourTonsTotal, MiddleHourTonsTotal, [scad].AvgDuration, [ksh].HaulageEfficiency

