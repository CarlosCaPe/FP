CREATE VIEW [cer].[ZZZ_CONOPS_CER_EOS_KPI_SUMMARY_HAULAGE_V_OLD] AS



-- SELECT * FROM [cer].[CONOPS_CER_EOS_KPI_SUMMARY_HAULAGE_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [cer].[CONOPS_CER_EOS_KPI_SUMMARY_HAULAGE_V]  
AS  
  
WITH CteShiftInfo AS (
	SELECT [SiteFlag]
		,[ShifTFlag]
		,[ShiftId]
		,[ShiftIndex]
		,[ShiftStartDate]
	FROM [cer].[CONOPS_CER_SHIFT_INFO_V] WITH (NOLOCK)
),

OVERVIEW AS (
	SELECT ShiftIndex
		,ShiftFlag
		,SiteFlag
		,COALESCE(SUM(TotalMaterialMined), 0) AS TotalMined
	FROM [cer].[CONOPS_CER_OVERVIEW_V] WITH (NOLOCK)
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
		FROM [cer].[CONOPS_CER_EFH_V]
	) AS efhc
	WHERE rn = 1
),

FORECAST AS (
	SELECT [pvps].SiteFlag
		,Right(
			[Year], 2) + FORMAT(CAST([Month] AS numeric), '00') AS [ShiftDate]
		,TotalMined
		,EFH
	FROM (
		SELECT SiteFlag
			,REVERSE(PARSENAME(REPLACE(REVERSE(CAST(TITLE AS DATE)), '-', '.'), 1)) AS [Year]
			,REVERSE(PARSENAME(REPLACE(REVERSE(CAST(TITLE AS DATE)), '-', '.'), 2)) AS [Month]
			,TotalMaterialMined AS TotalMined
			,EQUIVFLATHAULHAULPROF AS EFH
		FROM [cer].[PLAN_VALUES] WITH (NOLOCK) 
	) AS [pvps]
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
			ON SUBSTRING(REPLACE(CAST([ShiftStartDate] AS datetime2 ),'-',''),3,4) = ShiftDate
)

SELECT SiteFlag
	,ShifTFlag
	,ShiftIndex
	,COALESCE((Total * EFH) * 100, 0) AS HaulageEfficiency
FROM HAULAGE 

