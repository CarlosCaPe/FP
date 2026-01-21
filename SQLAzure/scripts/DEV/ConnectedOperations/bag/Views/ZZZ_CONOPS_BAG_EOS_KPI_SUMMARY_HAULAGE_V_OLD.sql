CREATE VIEW [bag].[ZZZ_CONOPS_BAG_EOS_KPI_SUMMARY_HAULAGE_V_OLD] AS



-- SELECT * FROM [bag].[CONOPS_BAG_EOS_KPI_SUMMARY_HAULAGE_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [bag].[CONOPS_BAG_EOS_KPI_SUMMARY_HAULAGE_V]  
AS  
  
WITH CteShiftInfo AS (
	SELECT [SiteFlag]
		,[ShifTFlag]
		,[ShiftId]
		,[ShiftIndex]
		,[ShiftStartDate]
	FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] WITH (NOLOCK)
),

OVERVIEW AS (
	SELECT ShiftIndex
		,ShiftFlag
		,SiteFlag
		,COALESCE(SUM(TotalMaterialMined), 0) AS TotalMined
	FROM [bag].[CONOPS_BAG_OVERVIEW_V] WITH (NOLOCK)
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
		FROM [bag].[CONOPS_BAG_EFH_V]
	) AS efhc
	WHERE rn = 1
),

FORECAST AS (
	SELECT [pvps].SiteFlag
		,SUBSTRING(REPLACE(EffectiveDate,'-',''),3,4) as ShiftDate
		,TotalTpd AS TotalMined
		,EFH
	FROM [bag].[plan_values_prod_sum] AS [pvps] WITH (NOLOCK)
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
			ON SUBSTRING(REPLACE([si].ShiftStartDate,'-',''),3,4) = ShiftDate
)

SELECT SiteFlag
	,ShifTFlag
	,ShiftIndex
	,COALESCE((Total * EFH) * 100, 0) AS HaulageEfficiency
FROM HAULAGE 

