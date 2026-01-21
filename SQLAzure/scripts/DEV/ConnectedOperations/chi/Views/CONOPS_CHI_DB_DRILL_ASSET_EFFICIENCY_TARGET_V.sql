CREATE VIEW [chi].[CONOPS_CHI_DB_DRILL_ASSET_EFFICIENCY_TARGET_V] AS




  
--select * from [chi].[CONOPS_CHI_DB_DRILL_ASSET_EFFICIENCY_TARGET_V] where shiftflag = 'curr'  
CREATE VIEW [chi].[CONOPS_CHI_DB_DRILL_ASSET_EFFICIENCY_TARGET_V]  
AS  
  
SELECT DISTINCT
	FORMAT(GetDate(),'yyMM') AS [ShiftId],
    'CHI' AS [siteflag],  
    [DRILLAVAILABILITY],  
    [DRILLASSETEFFICIENCY],  
    [DRILLUTILIZATION]  
FROM (  
 SELECT TOP 1 REVERSE(PARSENAME(REPLACE(REVERSE([DateEffective]), '-', '.'), 1)) AS [Year],  
     REVERSE(PARSENAME(REPLACE(REVERSE([DateEffective]), '-', '.'), 2)) AS [Month],  
     ISNULL([DrillAvailability], 0) AS [DRILLAVAILABILITY],  
     ISNULL([DrillAssetEfficiency],0) AS [DRILLASSETEFFICIENCY],  
     ISNULL([DrillUtilization], 0) AS [DRILLUTILIZATION]  
    FROM [chi].[PLAN_VALUES] (NOLOCK) pv
	ORDER BY DateEffective DESC
) [target]  
CROSS JOIN CHI.CONOPS_CHI_SHIFT_INFO_V s




