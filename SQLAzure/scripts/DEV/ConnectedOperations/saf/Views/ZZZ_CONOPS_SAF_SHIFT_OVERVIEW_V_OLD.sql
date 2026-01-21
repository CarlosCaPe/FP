CREATE VIEW [saf].[ZZZ_CONOPS_SAF_SHIFT_OVERVIEW_V_OLD] AS


-- Based on MOR Logic

-- SELECT * FROM [saf].[CONOPS_SAF_SHIFT_OVERVIEW_V] WITH (NOLOCK)
CREATE VIEW [saf].[CONOPS_SAF_SHIFT_OVERVIEW_V_OLD]
AS

WITH ShiftDump AS (
	SELECT  sd.shiftid,
			s.FieldId AS [ShovelId] ,
            sd.FieldLsizetons AS [Tons] ,
            sl.FieldId AS [Location] ,
            slloc.FieldId AS [LoadLoc],
            enum.[Description]
	FROM    saf.shift_dump_v sd WITH (NOLOCK)
            LEFT JOIN saf.shift_load sload WITH (NOLOCK) ON sd.id = sload.FieldDumprec
            LEFT JOIN saf.shift_eqmt s WITH (NOLOCK) ON s.Id = sd.FieldExcav
            LEFT JOIN saf.shift_loc sl WITH (NOLOCK) ON sl.Id = sd.FieldLoc
            LEFT JOIN saf.shift_loc slloc WITH (NOLOCK) ON slloc.Id = sload.FieldLoc
            LEFT JOIN saf.enum enum WITH (NOLOCK) ON sd.FieldLoad = enum.Id
),
 
ShiftDumpPerShovel AS (
	SELECT  sd.shiftid,
			sd.ShovelId ,
            COUNT(sd.Tons) AS [NrDumps] ,
            CASE WHEN sd.[Location] LIKE '%MFL' AND sd.LoadLoc NOT LIKE '%-MFL'
                 THEN SUM(sd.Tons)
                 ELSE 0
            END AS [TotalCrushedLeachMined] ,
            CASE WHEN (sd.LoadLoc LIKE '%-MFL' OR sd.LoadLoc LIKE '%-MILL')
                 THEN SUM(sd.Tons)
                 ELSE 0
            END AS [TotalTransferOre] ,
            CASE WHEN (sd.[Location] LIKE '%L4' OR sd.[Location] LIKE '%W') AND
            	       sd.LoadLoc NOT LIKE '%-MFL' AND sd.LoadLoc NOT LIKE '%-MILL'
                 THEN SUM(sd.Tons)
                 ELSE 0
            END AS [TotalWasteMined] ,
            CASE WHEN sd.[Location] LIKE '%MIL%' AND sd.LoadLoc NOT LIKE '%-MILL'
                 THEN SUM(sd.Tons)
                 ELSE 0
            END AS [TotalMillOreMined] ,
            CASE WHEN sd.[Location] NOT LIKE '%MFL' AND sd.[Location] NOT LIKE '%MIL%' AND
            	      sd.[Location] NOT LIKE '%L4' AND sd.[Location] NOT LIKE '%W'  AND
            	      sd.LoadLoc NOT LIKE '%-MFL' AND sd.LoadLoc NOT LIKE '%-MILL'
                 THEN SUM(sd.Tons)
                 ELSE 0
            END AS [TotalROMLeachMined] ,
            CASE WHEN sd.[Location] LIKE 'C%MFL' OR  sd.[Location] LIKE 'C%MIL'
                 THEN SUM(sd.Tons)
                 ELSE 0
            END AS [TotalDeliveredToCrushers]
   FROM     ShiftDump sd
   GROUP BY sd.shiftid,
			sd.ShovelId ,
            sd.[Description] ,
            sd.[Location],
            sd.LoadLoc
),
 
ShovelByRegion AS (
	SELECT pe.FieldId AS [ShovelId]
    FROM saf.pit_excav pe WITH (NOLOCK)
    INNER JOIN saf.pit_loc ppl WITH (NOLOCK) ON ppl.Id = pe.FieldLoc
    INNER JOIN saf.pit_loc pplr WITH (NOLOCK) ON pplr.Id = ppl.FieldRegion
	UNION
	SELECT DISTINCT sd.ShovelId
	FROM ShiftDump sd
)
 
SELECT  sdps.shiftid,
	    sbr.ShovelId,
		ISNULL(SUM(sdps.NrDumps), 0) AS [NrOfDumps] ,
		( ISNULL(SUM(sdps.TotalMillOreMined), 0) + ISNULL(SUM(sdps.TotalROMLeachMined), 0)
		  + ISNULL(SUM(sdps.TotalCrushedLeachMined), 0) + ISNULL(SUM(sdps.TotalWasteMined), 0)
		  + ISNULL(SUM(sdps.TotalTransferOre), 0) ) AS [TotalMineralsMined] , --TotalMaterialMoved
		( ISNULL(SUM(sdps.TotalMillOreMined), 0) + ISNULL(SUM(sdps.TotalROMLeachMined), 0)
		  + ISNULL(SUM(sdps.TotalCrushedLeachMined), 0) + ISNULL(SUM(sdps.TotalWasteMined), 0) ) AS [TotalMaterialMined] , --TotalMaterialMined
		ISNULL(SUM(sdps.TotalTransferOre), 0) AS [RehandledOre] ,
		ISNULL(SUM(sdps.TotalMillOreMined), 0) AS [MillOreMined] ,
		ISNULL(SUM(sdps.TotalROMLeachMined), 0) AS [ROMLeachMined] ,
		ISNULL(SUM(sdps.TotalCrushedLeachMined), 0) AS [CrushedLeachMined] ,
		ISNULL(SUM(sdps.TotalWasteMined), 0) AS [WasteMined] ,
		ISNULL(SUM(sdps.TotalDeliveredToCrushers), 0) AS [TotalMaterialDeliveredToCrusher]
FROM    ShovelByRegion sbr
LEFT JOIN ShiftDumpPerShovel sdps ON sdps.ShovelId = sbr.ShovelId
GROUP BY sbr.ShovelId,sdps.shiftid

