CREATE VIEW [bag].[CONOPS_BAG_DAILY_MATERIAL_DELIVERED_TO_CHRUSHER_V] AS





  
  
  
--select * from [bag].[CONOPS_BAG_DAILY_MATERIAL_DELIVERED_TO_CHRUSHER_V] WITH (NOLOCK)  
CREATE VIEW [bag].[CONOPS_BAG_DAILY_MATERIAL_DELIVERED_TO_CHRUSHER_V]   
AS  
  
WITH CTE AS(
    SELECT  siteflag,
            shiftid,
            CASE WHEN [loc] IN ('Crusher2','Crusher 2') THEN 'Crusher 2' 
                 WHEN [loc] IN ('SMALL CR_T') THEN 'Small Crusher'
            ELSE NULL END
            AS CrusherLoc,
            [LfTons] AS TotalTons
    FROM 
        (
            SELECT 
				SITE_CODE AS SITEFLAG,
				SHIFT_ID AS SHIFTID,
				DUMP_LOC_NAME AS LOC,
				REPORT_PAYLOAD_SHORT_TONS AS LfTons
			FROM BAG.FLEET_TRUCK_CYCLE_V WITH (NOLOCK)
			WHERE (DUMP_LOC_NAME IN('Crusher2', 'Crusher 2') OR DUMP_LOC_NAME LIKE 'SMALL CR%')
			--AND MATERIAL_NAME NOT IN ('ORE', 'MW', 'WST', 'TPW', 'GIL')
        ) AS Consolidated 
),

CrLoc AS (
    SELECT 'Crusher 2' CrusherLoc
    UNION ALL
    SELECT 'Small Crusher' CrusherLoc
),

CrLocShift AS (
    SELECT a.siteflag,
           a.SHIFTFLAG,
           a.shiftid,
           a.SHIFTDURATION,
           CrusherLoc
    FROM CrLoc, [bag].[CONOPS_BAG_EOS_SHIFT_INFO_V] a WITH (NOLOCK)
)

SELECT cl.siteflag
      ,SHIFTFLAG
	  ,cl.shiftid
      ,cl.CrusherLoc AS Name
      ,0 AS LeachActual
      ,0 AS LeachTarget
      ,0 AS LeachShiftTarget
      ,SUM(COALESCE(TotalTons, 0)) / 1000.00 AS MillOreActual
      ,ROUND((COALESCE([ct].[Target], 0) * (FLOOR(cl.ShiftDuration / 3600) / 12.00 )) / 1000.00, 1) AS MillOreTarget
      ,ROUND(COALESCE([ct].[Target], 0) / 1000.00, 1) AS MillOreShiftTarget
	  ,COUNT(TotalTons) AS TotalNrDumps
FROM CrLocShift cl
LEFT JOIN CTE
ON cl.SHIFTID = cte.SHIFTID
   AND cl.CrusherLoc = cte.CrusherLoc
LEFT JOIN [bag].[CONOPS_BAG_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] [ct] WITH (NOLOCK)
ON [ct].shiftid = cl.shiftid AND
   cl.CrusherLoc = [ct].[Location]
GROUP BY cl.siteflag, SHIFTFLAG, cl.CrusherLoc, [ct].[Target], cl.ShiftDuration,cl.shiftid
  
  
  
  





