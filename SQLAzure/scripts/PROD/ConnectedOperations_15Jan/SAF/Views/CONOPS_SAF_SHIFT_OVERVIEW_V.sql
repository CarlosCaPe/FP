CREATE VIEW [SAF].[CONOPS_SAF_SHIFT_OVERVIEW_V] AS

--SELECT * FROM [saf].[CONOPS_SAF_SHIFT_OVERVIEW_V] WITH (NOLOCK)
CREATE VIEW [saf].[CONOPS_SAF_SHIFT_OVERVIEW_V]
AS

WITH ShiftDump AS (
SELECT
    sd.shiftid,
    sr.FieldId AS [Region],
    s.FieldId AS [ShovelId],
    t.FieldSize AS [Tons],
    sl.FieldId AS [Location],
    ssloc.FieldId AS [Dump],
    enum.[Description] AS [Description],
    enum.Id AS [enumId]
FROM saf.shift_dump_v sd WITH (NOLOCK)
LEFT JOIN saf.shift_eqmt t WITH (NOLOCK)
    ON t.Id = sd.FieldTruck
    --AND t.SHIFTID = sd.shiftid
LEFT JOIN saf.shift_eqmt s WITH (NOLOCK)
   ON s.Id = sd.FieldExcav
    --AND s.SHIFTID = sd.shiftid
LEFT JOIN saf.shift_loc sl WITH (NOLOCK)
    ON sl.Id = sd.FieldBlast
    --AND sl.SHIFTID = sd.shiftid
LEFT JOIN saf.shift_loc sr WITH (NOLOCK)
    ON sr.Id = sl.FieldRegion
    --AND sr.SHIFTID = sd.shiftid
LEFT JOIN saf.shift_loc ssloc WITH (NOLOCK)
    ON ssloc.Id = sd.FieldLoc
    --AND ssloc.SHIFTID = sd.shiftid
LEFT JOIN saf.enum enum WITH (NOLOCK)
    ON enum.Id = ssloc.FieldUnit
WHERE sr.FieldId IN ('SAN JUAN', 'LONE STAR')
),


ShiftDumpPerShovel AS (
SELECT
    sd.shiftid,
    sd.Region,
    sd.ShovelId,
    COUNT(sd.Tons) AS [NrDumps],
    SUM(sd.Tons) AS [Tons],
    CASE WHEN sd.[enumId] = 284 THEN SUM(sd.Tons)
        ELSE 0
        END AS [TotalCrushedLeach],
    CASE WHEN sd.Region = 'SAN JUAN'
            AND (sd.[enumId] = 285) THEN SUM(sd.Tons)
        WHEN sd.Region = 'LONE STAR'
            AND (sd.[enumId] = 285) THEN SUM(sd.Tons)
        ELSE 0
        END AS [TotalStockpiledOre],
    CASE WHEN NOT EXISTS (SELECT 1 WHERE sd.[enumId] IN (284, 285) ) THEN SUM(sd.Tons)
        ELSE 0
        END AS [TotalWaste],
    CASE WHEN sd.Location IN ('LS-SP-3370-W-ROM2', 'LS-SP-3370-W-ROM3', 'LS-SP-3250-W-ROM4') THEN SUM(sd.Tons)
        ELSE 0
    END AS [TotalROMLeach]
FROM ShiftDump sd WITH (NOLOCK)
GROUP BY sd.shiftid, sd.Region, sd.ShovelId, sd.[Location], sd.[enumId], sd.[Dump]
)

SELECT
    sdps.SHIFTID,
    sdps.ShovelId,
    ISNULL(SUM(sdps.NrDumps), 0) AS [NrOfDumps],
    ISNULL(SUM(sdps.TotalCrushedLeach), 0) + ISNULL(SUM(sdps.TotalStockpiledOre), 0) + ISNULL(SUM(sdps.TotalWaste), 0) AS [TotalMineralsMined],
    ISNULL(SUM(Tons),0) AS [TotalMaterialMined],
    0 AS [RehandledOre],
    0 AS [MillOreMined],
    ISNULL(SUM(sdps.[TotalROMLeach]), 0) AS [ROMLeachMined],
    ISNULL(SUM(sdps.TotalCrushedLeach), 0) AS [CrushedLeachMined],
    ISNULL(SUM(sdps.TotalWaste), 0) AS [WasteMined],
    --ISNULL(SUM(sdps.TotalStockpiledOre), 0) AS [StockpiledOre],
    ISNULL(SUM(sdps.TotalCrushedLeach), 0) AS [TotalMaterialDeliveredToCrusher]
FROM ShiftDumpPerShovel sdps
GROUP BY sdps.SHIFTID, sdps.ShovelId

