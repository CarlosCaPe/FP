CREATE VIEW [cli].[ZZZ_CONOPS_CLI_EOS_KPI_SUMMARY_HAULAGE_V_OLD] AS





-- SELECT * FROM [cli].[CONOPS_CLI_EOS_KPI_SUMMARY_HAULAGE_V_OLD] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [cli].[CONOPS_CLI_EOS_KPI_SUMMARY_HAULAGE_V_OLD]  
AS  
  
WITH CteShiftInfo AS (
	SELECT [SiteFlag]
		,[ShifTFlag]
		,[ShiftId]
		,[ShiftIndex]
		,[ShiftStartDate]
	FROM [cli].[CONOPS_CLI_SHIFT_INFO_V] WITH (NOLOCK)
),

OVERVIEW AS (
	SELECT ShiftIndex
		,ShiftFlag
		,SiteFlag
		,COALESCE(SUM(TotalMaterialMined), 0) AS TotalMined
	FROM [cli].[CONOPS_CLI_OVERVIEW_V] WITH (NOLOCK)
	GROUP BY ShiftIndex, ShiftFlag, SiteFlag
),

EFHCTE AS (
	SELECT ShiftFlag
		, ShiftId
		,SiteFlag
		,rn
		,EFH
	FROM (
		SELECT ShiftFlag
			, ShiftId
			,SiteFlag
			,ROW_NUMBER() OVER (PARTITION BY ShiftId ORDER BY breakbyhour DESC) AS rn
			,EFH
		FROM [cli].[CONOPS_CLI_EFH_V]
	) AS efhc
	WHERE rn = 1
),

FORECAST AS (
	SELECT SiteFlag
		,(Datepv + Shiftpv) AS ShiftId
		,TotalMined
		,EFH
	FROM (
		SELECT [pv].SiteFlag
			,SUBSTRING(ShiftId, 9, 2) + REPLACE(LEFT(ShiftId, 6), '/', '') as Datepv
			,'00' + RIGHT(ShiftId, 1) AS Shiftpv
			,TotalTonsMined AS TotalMined
			,EFH
		FROM [cli].[plan_values] AS [pv] WITH (NOLOCK)
	) AS f
),

HAULAGE AS (
	SELECT [si].SiteFlag
		,[si].ShiftFlag
		,[si].ShiftIndex
		,[ov].TotalMined / [fc].TotalMined AS Total
		,[ef].EFH / [fc].EFH AS EFH
	FROM CteShiftInfo [si]
	LEFT JOIN OVERVIEW [ov]
		ON [si].SHIFTINDEX = [ov].shiftindex
		AND [si].ShiftFlag = [ov].ShiftFlag
	LEFT JOIN EFHCTE [ef]
		ON [si].ShiftId = [ef].ShiftId
		AND [si].ShiftFlag = [ef].ShiftFlag
	LEFT JOIN FORECAST AS [fc]
		ON [si].ShiftId = [fc].ShiftId
)

SELECT SiteFlag
	,ShifTFlag
	,ShiftIndex
	,COALESCE((Total * EFH) * 100, 0) AS HaulageEfficiency
FROM HAULAGE 

