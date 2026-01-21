CREATE VIEW [saf].[ZZZ_CONOPS_SAF_EOS_KPI_SUMMARY_HAULAGE_V_OLD] AS




-- SELECT * FROM [saf].[CONOPS_SAF_EOS_KPI_SUMMARY_HAULAGE_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [saf].[CONOPS_SAF_EOS_KPI_SUMMARY_HAULAGE_V]  
AS  
  
WITH CteShiftInfo AS (
	SELECT [SiteFlag]
		,[ShifTFlag]
		,[ShiftId]
		,[ShiftIndex]
		,[ShiftStartDate]
	FROM [saf].[CONOPS_SAF_SHIFT_INFO_V] WITH (NOLOCK)
),

OVERVIEW AS (
	SELECT ShiftIndex
		,ShiftFlag
		,SiteFlag
		,COALESCE(SUM(TotalMaterialMined), 0) AS TotalMined
	FROM [saf].[CONOPS_SAF_OVERVIEW_V] WITH (NOLOCK)
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
		FROM [saf].[CONOPS_SAF_EFH_V]
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
			,SUBSTRING(CAST(DateEffective AS VARCHAR(8)), 3, 2) + REPLACE(RIGHT(DateEffective, 5), '-', '') as Datepv
			,'00' + ShiftIndex AS Shiftpv
			,TotalMineTpd AS TotalMined
			,TotalEFH AS EFH
		FROM [saf].[plan_values] AS [pv] WITH (NOLOCK)
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

