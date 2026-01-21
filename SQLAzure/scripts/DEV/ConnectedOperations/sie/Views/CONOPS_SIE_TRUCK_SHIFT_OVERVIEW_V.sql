CREATE VIEW [sie].[CONOPS_SIE_TRUCK_SHIFT_OVERVIEW_V] AS




CREATE VIEW [sie].[CONOPS_SIE_TRUCK_SHIFT_OVERVIEW_V]
AS

WITH CTE AS (
SELECT 
sd.shiftid,
t.FieldId AS [TruckId],
--sum(t.FieldSize) AS TotalMaterialMoved,
sum(sd.FIELDLSIZETONS) AS TotalMaterialMoved,
count(sd.FIELDLSIZETONS) AS NrofDumps,
ssloc.FieldId AS [Location],
CASE WHEN ssloc.FieldId LIKE '%W' THEN SUM(sd.FIELDLSIZETONS) ELSE 0 END AS TotalWasteMoved,  
CASE WHEN sl.FieldId LIKE '%PB%' AND ssloc.FieldId LIKE '%W' THEN SUM(sd.FIELDLSIZETONS) ELSE 0 END AS WasteMined,
CASE WHEN sl.FieldId LIKE '%PB%' AND ssloc.FieldId LIKE '%F' THEN SUM(sd.FIELDLSIZETONS) ELSE 0 END AS FinesMined,
CASE WHEN ssloc.FieldId IN ('CR13909O', 'A-SIDE', 'B-SIDE') THEN SUM(sd.FIELDLSIZETONS) ELSE 0 END AS TotalCrushedMillOre, 
CASE WHEN ssloc.FieldId LIKE 'STO%' AND sl.FieldId LIKE '%PB%' THEN SUM(sd.FIELDLSIZETONS) ELSE 0 END AS StockpiledMillOre,
CASE WHEN ssloc.FieldId IN ('CR13909O', 'A-SIDE', 'B-SIDE') AND sl.FieldId NOT LIKE '%PB%' THEN SUM(sd.FIELDLSIZETONS) ELSE 0 END AS StockpileToCrusherOre,  --Total Mineral Mined
CASE WHEN ssloc.FieldId IN ('CR13909O', 'A-SIDE', 'B-SIDE') AND sl.FieldId LIKE '%PB%' THEN SUM(sd.FIELDLSIZETONS) ELSE 0 END AS PitToCrusherOre             
FROM sie.shift_dump_v sd WITH (NOLOCK)
LEFT JOIN sie.shift_eqmt t WITH (NOLOCK)
ON t.Id = sd.FieldTruck AND t.SHIFTID = sd.shiftid
LEFT JOIN sie.shift_loc sl WITH (NOLOCK)
ON sl.Id = sd.FieldBlast AND sl.SHIFTID = sd.shiftid
LEFT JOIN sie.shift_loc ssloc WITH (NOLOCK)
ON ssloc.Id = sd.FieldLoc AND ssloc.SHIFTID = sd.shiftid
LEFT JOIN sie.enum enum ON sd.FieldLoad = enum.enumtypeid and enum.ABBREVIATION = 'load'
--WHERE sd.UTC_LOGICAL_DELETED_DATE is null
GROUP BY sd.shiftid,t.FieldId,ssloc.FieldId,sl.FieldId)


SELECT  
sdps.shiftid,
sdps.shiftid AS ShiftIndex,
sdps.TruckId,
SUM(sdps.NrofDumps) AS NrofDumps,
ISNULL(SUM(sdps.TotalMaterialMoved), 0) AS TotalMaterialMoved,
(ISNULL(SUM(sdps.TotalMaterialMoved),0) - (ISNULL(SUM(sdps.PitToCrusherOre),0) + ISNULL(SUM(sdps.StockpiledMillOre),0) + ISNULL(SUM(sdps.WasteMined),0) + ISNULL(SUM(sdps.FinesMined),0))) AS Rehandle,
(ISNULL(SUM(sdps.PitToCrusherOre),0) + ISNULL(SUM(sdps.StockpiledMillOre),0) + ISNULL(SUM(sdps.WasteMined),0) + ISNULL(SUM(sdps.FinesMined),0)) AS TotalMineralsMined,
(ISNULL(SUM(StockpileToCrusherOre), 0) + ISNULL(SUM(PitToCrusherOre), 0) + ISNULL(SUM(StockpiledMillOre), 0)) AS TotalOreMoved,
ISNULL(SUM(sdps.TotalWasteMoved),0) AS TotalWasteMoved,
(ISNULL(SUM(PitToCrusherOre),0) + ISNULL(SUM(StockpiledMillOre),0)) AS MillOreMined,
(ISNULL(SUM(StockpileToCrusherOre),0) + ISNULL(SUM(PitToCrusherOre),0) + ISNULL(SUM(StockpiledMillOre),0)) AS MillOreMoved,
ISNULL(SUM(sdps.WasteMined),0) AS WasteMined,
ISNULL(SUM(sdps.TotalCrushedMillOre),0) AS TotalMaterialDeliveredToCrusher
FROM CTE AS sdps


GROUP BY sdps.TruckId, sdps.shiftid








