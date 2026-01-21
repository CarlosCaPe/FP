CREATE VIEW [mor].[CONOPS_MOR_EOS_KPI_SUMMARY_HAULAGE_V] AS






-- SELECT * FROM [mor].[CONOPS_MOR_EOS_KPI_SUMMARY_HAULAGE_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'PREV'  
CREATE VIEW [mor].[CONOPS_MOR_EOS_KPI_SUMMARY_HAULAGE_V]  
AS  
  
WITH CteShiftInfo AS (
	SELECT [SiteFlag]
		,[ShifTFlag]
		,[ShiftId]
		,[ShiftIndex]
		,([ShiftDuration]) AS [Duration]
		,[ShiftStartDate]
	FROM [mor].[CONOPS_MOR_SHIFT_INFO_V] WITH (NOLOCK)
),

FORECAST AS (
	SELECT [si].SiteFlag
		,[si].ShiftFlag
		,[si].ShiftIndex
		,[si].Duration
		--,FLOOR((CAST(([si].Duration / 3600) AS DECIMAL(7, 2)) / 12) * [st].ShiftTarget) AS [TotalMined]
		--,FLOOR((CAST(([si].Duration / 3600) AS DECIMAL(7, 2)) / 12) * [st].EFHShiftTarget) AS [EFH]
		,[st].ShiftTarget AS [TotalMined]
		,[st].EFHShiftTarget AS [EFH]
	FROM CteShiftInfo [si]
	LEFT JOIN [mor].[CONOPS_MOR_SHIFT_TARGET_V] [st] WITH (NOLOCK)
		ON [si].ShiftId = [st].ShiftId
		AND [si].ShiftFlag = [st].ShiftFlag
),

OVERVIEW AS (
	SELECT ShiftIndex
		,ShiftFlag
		,SiteFlag
		,COALESCE(SUM(TotalMaterialMined), 0) AS TotalMined
	FROM [mor].[CONOPS_MOR_OVERVIEW_V] WITH (NOLOCK)
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
		FROM [mor].[CONOPS_MOR_EFH_V] WITH (NOLOCK)
	) AS efhc
	WHERE rn = 1
),

HAULAGE AS (
	SELECT [si].SiteFlag
		,[si].ShiftFlag
		,[si].ShiftIndex
		,(CASE 
			WHEN [fc].Duration = 0 OR 
				[ov].TotalMined = 0 THEN 0
			ELSE ([ov].TotalMined / [fc].TotalMined) 
		END) AS Total
		,(CASE 
			WHEN [fc].Duration = 0 OR 
				[ef].EFH = 0 THEN 0
			ELSE ([ef].EFH / [fc].EFH) 
		END) AS EFH
	FROM CteShiftInfo [si]
	LEFT JOIN OVERVIEW [ov]
		ON [si].SHIFTINDEX = [ov].shiftindex
		AND [si].ShiftFlag = [ov].ShiftFlag
	LEFT JOIN EFHCTE [ef]
		ON [si].ShiftId = [ef].ShiftId
		AND [si].ShiftFlag = [ef].ShiftFlag
	LEFT JOIN FORECAST AS [fc]
			ON [si].ShiftIndex = [fc].ShiftIndex
)

SELECT SiteFlag
	,ShifTFlag
	,ShiftIndex
	,COALESCE((Total * EFH) * 100, 0) AS HaulageEfficiency
FROM HAULAGE 

