CREATE VIEW [SIE].[CONOPS_SIE_EOS_KPI_SUMMARY_HAULAGE_V] AS


-- SELECT * FROM [sie].[CONOPS_SIE_EOS_KPI_SUMMARY_HAULAGE_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [sie].[CONOPS_SIE_EOS_KPI_SUMMARY_HAULAGE_V]  
AS  
  
WITH CteShiftInfo AS (
	SELECT [SiteFlag]
		,[ShifTFlag]
		,[ShiftId]
		,[ShiftIndex]
		,[ShiftStartDate]
	FROM [sie].[CONOPS_SIE_SHIFT_INFO_V] WITH (NOLOCK)
),

OVERVIEW AS (
	SELECT ShiftIndex
		,ShiftFlag
		,SiteFlag
		,COALESCE(SUM(TotalMaterialMined), 0) AS TotalMined
	FROM [sie].[CONOPS_SIE_OVERVIEW_V] WITH (NOLOCK)
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
		FROM [sie].[CONOPS_SIE_EFH_V]
	) AS efhc
	WHERE rn = 1
),

FORECAST AS (
	SELECT TOP 1 TotalExPitTPD AS TotalMined
		,EquivalentFlatHaul AS EFH
	FROM [sie].[plan_values_prod_sum] AS [pvps] WITH (NOLOCK)
	ORDER BY dateeffective DESC
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
	CROSS JOIN FORECAST AS [fc]
)

SELECT SiteFlag
	,ShifTFlag
	,ShiftIndex
	,COALESCE((Total * EFH) * 100, 0) AS HaulageEfficiency
FROM HAULAGE 

