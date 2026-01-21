CREATE VIEW [SAF].[CONOPS_SAF_SHIFT_OVERVIEW_V] AS







-- SELECT * FROM [saf].[CONOPS_SAF_SHIFT_OVERVIEW_V] WITH (NOLOCK)
CREATE VIEW [saf].[CONOPS_SAF_SHIFT_OVERVIEW_V]
AS

WITH ShiftDump AS (
   SELECT sd.shiftid,
          sr.FieldId AS [Region],
          s.FieldId AS [ShovelId],
          t.FieldSize AS [Tons],
          sl.FieldId AS [Location],
          ssloc.FieldId AS [Dump],
          enum.[Description] AS [Description],
          enum.Id AS [enumId]
   FROM saf.shift_dump_v sd WITH (NOLOCK)
   LEFT JOIN saf.shift_eqmt t WITH (NOLOCK)
   ON t.Id = sd.FieldTruck AND t.SHIFTID = sd.shiftid
   LEFT JOIN saf.shift_eqmt s WITH (NOLOCK)
   ON s.Id = sd.FieldExcav AND s.SHIFTID = sd.shiftid
   LEFT JOIN saf.shift_loc sl WITH (NOLOCK)
   ON sl.Id = sd.FieldBlast AND sl.SHIFTID = sd.shiftid
   LEFT JOIN saf.shift_loc sr WITH (NOLOCK)
   ON sr.Id = sl.FieldRegion AND sr.SHIFTID = sd.shiftid
   LEFT JOIN saf.shift_loc ssloc WITH (NOLOCK)
   ON ssloc.Id = sd.FieldLoc AND ssloc.SHIFTID = sd.shiftid
   LEFT JOIN saf.enum enum WITH (NOLOCK) ON enum.Id = ssloc.FieldUnit
   WHERE sr.FieldId IN ('SAN JUAN',
                        'LONE STAR')
   --AND sd.UTC_LOGICAL_DELETED_DATE is null
),

ShiftDumpPerShovel AS (
   SELECT sd.shiftid,
	      sd.Region,
          sd.ShovelId,
          COUNT(sd.Tons) AS [NrDumps],
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
),

ShovelByRegion AS (
   SELECT pe.SHIFTID,
		  pplr.FieldId AS [Region],
          pe.FieldId AS [ShovelId],
          CASE WHEN (pplr.FieldId = 'SAN JUAN' AND pe.FieldId = 'S003')
                    OR (pplr.FieldId = 'SAN JUAN' AND pe.FieldId = 'S005') THEN 0
               ELSE 1
          END AS [IsValidShovelRegion]
   FROM saf.pit_excav_c pe WITH (NOLOCK)
   INNER JOIN saf.pit_loc ppl WITH (NOLOCK) ON ppl.Id = pe.FieldLoc
   INNER JOIN saf.pit_loc pplr WITH (NOLOCK) ON pplr.Id = ppl.FieldRegion
   UNION
   SELECT DISTINCT sd.shiftid,
				   sd.Region,
				   sd.ShovelId,
				   CASE WHEN (sd.Region = 'SAN JUAN' AND sd.ShovelId = 'S003')
							  OR (sd.Region = 'SAN JUAN' AND sd.ShovelId = 'S005') THEN 0
				   ELSE 1
				   END AS [IsValidShovelRegion]
   FROM ShiftDump sd
)

SELECT sbr.SHIFTID,
       sbr.ShovelId,
       ISNULL(SUM(sdps.NrDumps), 0) AS [NrOfDumps],
       ISNULL(SUM(sdps.TotalCrushedLeach), 0) + ISNULL(SUM(sdps.TotalStockpiledOre), 0) + ISNULL(SUM(sdps.TotalWaste), 0) AS [TotalMineralsMined],
	   0 AS [TotalMaterialMined],
	   0 AS [RehandledOre],
	   0 AS [MillOreMined],
	   ISNULL(SUM(sdps.[TotalROMLeach]), 0) AS [ROMLeachMined],
       ISNULL(SUM(sdps.TotalCrushedLeach), 0) AS [CrushedLeachMined],
       ISNULL(SUM(sdps.TotalWaste), 0) AS [WasteMined],
       --ISNULL(SUM(sdps.TotalStockpiledOre), 0) AS [StockpiledOre],
       ISNULL(SUM(sdps.TotalCrushedLeach), 0) AS [TotalMaterialDeliveredToCrusher]
FROM ShovelByRegion sbr
LEFT JOIN ShiftDumpPerShovel sdps
ON sdps.Region = sbr.Region AND sdps.ShovelId = sbr.ShovelId
   AND sdps.shiftid = sbr.shiftid
WHERE sbr.IsValidShovelRegion = 1 AND sbr.SHIFTID IS NOT NULL
GROUP BY sbr.SHIFTID, sbr.ShovelId, sbr.IsValidShovelRegion;



