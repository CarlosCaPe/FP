CREATE VIEW [sie].[ZZZ_CONOPS_SIE_SHIFT_OVERVIEW_V_NEW] AS







CREATE VIEW [sie].[CONOPS_SIE_SHIFT_OVERVIEW_V_NEW]
AS


WITH CTE AS (
SELECT 
sd.shiftid,
s.FieldId AS [ShovelId],
--sum(t.FieldSize) AS TotalMaterialMoved,
sum(sd.FIELDLSIZETONS) AS TotalMaterialMoved,
ssloc.FieldId AS [Location],
CASE WHEN ssloc.FieldId LIKE '%W' THEN SUM(sd.FIELDLSIZETONS) ELSE 0 END AS TotalWasteMoved,  
CASE WHEN ssloc.FieldId LIKE '%PB%' AND ssloc.FieldId LIKE '%W' THEN SUM(sd.FIELDLSIZETONS) ELSE 0 END AS WasteMined,
CASE WHEN ssloc.FieldId IN ('CR13909O', 'A-SIDE', 'B-SIDE') THEN SUM(sd.FIELDLSIZETONS) ELSE 0 END AS TotalCrushedMillOre, 
CASE WHEN ssloc.FieldId LIKE 'STO%' AND ssloc.FieldId LIKE '%PB%' THEN SUM(sd.FIELDLSIZETONS) ELSE 0 END AS StockpiledMillOre,
CASE WHEN ssloc.FieldId IN ('CR13909O', 'A-SIDE', 'B-SIDE') AND ssloc.FieldId NOT LIKE '%PB%' THEN SUM(sd.FIELDLSIZETONS) ELSE 0 END AS StockpileToCrusherOre,  --Total Mineral Mined
CASE WHEN ssloc.FieldId IN ('CR13909O', 'A-SIDE', 'B-SIDE') AND ssloc.FieldId LIKE '%PB%' THEN SUM(sd.FIELDLSIZETONS) ELSE 0 END AS PitToCrusherOre             
FROM sie.shift_dump sd WITH (NOLOCK)
LEFT JOIN sie.shift_eqmt t WITH (NOLOCK)
ON t.Id = sd.FieldTruck AND t.SHIFTID = sd.shiftid
LEFT JOIN sie.shift_eqmt s WITH (NOLOCK)
ON s.Id = sd.FieldExcav AND s.SHIFTID = sd.shiftid
--LEFT JOIN sie.shift_loc sl WITH (NOLOCK)
--ON sl.Id = sd.FieldBlast AND sl.SHIFTID = sd.shiftid
LEFT JOIN sie.shift_loc ssloc WITH (NOLOCK)
ON ssloc.Id = sd.FieldLoc AND ssloc.SHIFTID = sd.shiftid
LEFT JOIN sie.enum enum ON sd.FieldLoad = enum.enumtypeid and enum.ABBREVIATION = 'load'
GROUP BY sd.shiftid,s.FieldId,ssloc.FieldId)


SELECT  
sdps.shiftid,
sdps.ShovelId AS ShovelId, 
sdps.shiftid AS ShiftIndex,
NULLIF(SUM(sdps.TotalMaterialMoved), 0) AS TotalMaterialMoved,
(NULLIF(SUM(sdps.TotalMaterialMoved),0) - (NULLIF(SUM(sdps.PitToCrusherOre),0) + NULLIF(SUM(sdps.StockpiledMillOre),0) + NULLIF(SUM(sdps.WasteMined),0))) AS Rehandle,
(NULLIF(SUM(sdps.PitToCrusherOre),0) + NULLIF(SUM(sdps.StockpiledMillOre),0) + NULLIF(SUM(sdps.WasteMined),0)) AS TotalMineralsMined,
(NULLIF(SUM(StockpileToCrusherOre), 0) + NULLIF(SUM(PitToCrusherOre), 0) + NULLIF(SUM(StockpiledMillOre), 0)) AS TotalOreMoved,
NULLIF(SUM(sdps.TotalWasteMoved),0) AS TotalWasteMoved,
(NULLIF(SUM(PitToCrusherOre),0) + NULLIF(SUM(StockpiledMillOre),0)) AS MillOreMined,
(NULLIF(SUM(StockpileToCrusherOre),0) + NULLIF(SUM(PitToCrusherOre),0) + NULLIF(SUM(StockpiledMillOre),0)) AS MillOreMoved,
NULLIF(SUM(sdps.WasteMined),0) AS WasteMined,
NULLIF(SUM(sdps.TotalCrushedMillOre),0) AS TotalMaterialDeliveredToCrusher
FROM CTE AS sdps


GROUP BY sdps.ShovelId, sdps.shiftid


