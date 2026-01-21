CREATE VIEW [sie].[ZZZ_CONOPS_SIE_SHIFT_SNAPSHOT_V_OLD] AS





CREATE VIEW [sie].[CONOPS_SIE_SHIFT_SNAPSHOT_V_OLD]
AS


SELECT  
shiftinfo.shiftid,
sdps.ShovelId AS ShovelId, 
sdps.shiftdumptime,
NULLIF(SUM(sdps.TotalMaterialMoved), 0) AS TotalMaterialMoved
FROM (
SELECT Excav AS ShovelId, Calculated_ShiftIndex AS ShiftIndex,
	   TIMEDUMP_TS as shiftdumptime,
       SUM(dumptons) AS TotalMaterialMoved, 
       Loc AS Location, 
       CASE WHEN Loc LIKE '%W' THEN SUM(dumptons) ELSE 0 END AS TotalWasteMoved,  
       CASE WHEN Grade LIKE '%PB%' AND Loc LIKE '%W' THEN SUM(dumptons) ELSE 0 END AS WasteMined,
       CASE WHEN Loc IN ('CR13909O', 'A-SIDE', 'B-SIDE') THEN SUM(dumptons) ELSE 0 END AS TotalCrushedMillOre, 
       CASE WHEN Loc LIKE 'STO%' AND Grade LIKE '%PB%' THEN SUM(dumptons) ELSE 0 END AS StockpiledMillOre,
       CASE WHEN Loc IN ('CR13909O', 'A-SIDE', 'B-SIDE') AND Grade NOT LIKE '%PB%' THEN SUM(dumptons) ELSE 0 END AS StockpileToCrusherOre,  --Total Mineral Mined
       CASE WHEN Loc IN ('CR13909O', 'A-SIDE', 'B-SIDE') AND Grade LIKE '%PB%' THEN SUM(dumptons) ELSE 0 END AS PitToCrusherOre             

FROM dbo.lh_dump 
WHERE site_code = 'SIE' 
GROUP BY Excav, Loc, Grade, Calculated_ShiftIndex,TIMEDUMP_TS  ) AS sdps
LEFT JOIN dbo.SHIFT_INFO_V shiftinfo ON sdps.ShiftIndex = shiftinfo.ShiftIndex AND shiftinfo.siteflag = 'SIE'
GROUP BY sdps.ShovelId, sdps.ShiftIndex,shiftinfo.shiftid,sdps.shiftdumptime

