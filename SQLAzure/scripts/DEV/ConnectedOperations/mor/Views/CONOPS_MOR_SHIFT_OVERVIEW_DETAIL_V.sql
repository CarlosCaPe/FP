CREATE VIEW [mor].[CONOPS_MOR_SHIFT_OVERVIEW_DETAIL_V] AS



--SELECT * FROM [MOR].[CONOPS_MOR_SHIFT_OVERVIEW_DETAIL_V]
CREATE VIEW [MOR].[CONOPS_MOR_SHIFT_OVERVIEW_DETAIL_V]
AS

WITH ShiftDump AS (
    SELECT   
        si.shiftid,
        si.shiftindex,
        si.shiftstartdatetime,
        s.FieldId AS [ShovelId],
        sd.FieldLsizetons AS [Tons],
        sl.FieldId AS [Location],
        slloc.FieldId AS [LoadLoc],
        enum.[Description],
        CASE 
            WHEN sd.shiftid <> sd.origshiftid THEN sd.Fieldtimeempty - 43200
            ELSE sd.Fieldtimeempty 
        END AS Fieldtimeempty
    FROM MOR.CONOPS_MOR_SHIFT_INFO_V si
    LEFT JOIN mor.shift_dump_v sd WITH (NOLOCK) ON si.shiftid = sd.shiftid
    LEFT JOIN mor.shift_load sload WITH (NOLOCK) ON sd.id = sload.FieldDumprec
    LEFT JOIN mor.shift_eqmt s WITH (NOLOCK) ON s.Id = sd.FieldExcav
    LEFT JOIN mor.shift_loc sl WITH (NOLOCK) ON sl.Id = sd.FieldLoc
    LEFT JOIN mor.shift_loc slloc WITH (NOLOCK) ON slloc.Id = sload.FieldLoc
    LEFT JOIN mor.enum enum WITH (NOLOCK) ON sd.FieldLoad = enum.Id
    WHERE s.FieldId LIKE 'S%'
       OR s.FieldId IN ('L58', 'L59')
),

ShiftDumpPerShovel AS (
    SELECT   
        sd.shiftid,
        sd.ShovelId,
		shiftstartdatetime,
        DATEADD(SECOND, Fieldtimeempty, shiftstartdatetime) AS DumpingEndTime,
        COUNT(sd.Tons) AS [NrDumps],
        CASE 
            WHEN sd.[Location] LIKE '%MFL' AND sd.LoadLoc NOT LIKE '%-MFL' THEN SUM(sd.Tons)
            ELSE 0
        END AS [TotalCrushedLeachMined],
        CASE 
            WHEN (sd.LoadLoc LIKE '%-MFL' OR sd.LoadLoc LIKE '%-MILL') THEN SUM(sd.Tons)
            ELSE 0
        END AS [TotalTransferOre],
        CASE 
            WHEN (sd.[Location] LIKE '%L4' OR sd.[Location] LIKE '%W') AND sd.LoadLoc NOT LIKE '%-MFL' AND sd.LoadLoc NOT LIKE '%-MILL' THEN SUM(sd.Tons)
            ELSE 0
        END AS [TotalWasteMined],
        CASE 
            WHEN sd.[Location] LIKE '%MIL%' AND sd.LoadLoc NOT LIKE '%-MILL' THEN SUM(sd.Tons)
            ELSE 0
        END AS [TotalMillOreMined],
        CASE 
            WHEN sd.[Location] NOT LIKE '%MFL' AND sd.[Location] NOT LIKE '%MIL%' AND sd.[Location] NOT LIKE '%L4' AND sd.[Location] NOT LIKE '%W' AND sd.LoadLoc NOT LIKE '%-MFL' AND sd.LoadLoc NOT LIKE '%-MILL' THEN SUM(sd.Tons)
            ELSE 0
        END AS [TotalROMLeachMined],
        CASE 
            WHEN sd.[Location] LIKE 'C%MFL' OR sd.[Location] LIKE 'C%MIL' THEN SUM(sd.Tons)
            ELSE 0
        END AS [TotalDeliveredToCrushers]
    FROM ShiftDump sd
    GROUP BY 
        sd.shiftid,
        sd.ShovelId,
        sd.[Description],
        sd.[Location],
        sd.LoadLoc,
        shiftstartdatetime,
        Fieldtimeempty
),

ShovelByRegion AS (
    SELECT pe.FieldId AS [ShovelId]
    FROM mor.pit_excav pe WITH (NOLOCK)
    INNER JOIN mor.pit_loc ppl WITH (NOLOCK) ON ppl.Id = pe.FieldLoc
    INNER JOIN mor.pit_loc pplr WITH (NOLOCK) ON pplr.Id = ppl.FieldRegion
    UNION
    SELECT DISTINCT sd.ShovelId
    FROM ShiftDump sd
)

SELECT  
    sdps.shiftid,
    sbr.ShovelId,
    dumpingendtime AS dump_time,
	DATEDIFF(MINUTE,shiftstartdatetime,DumpingEndTime) / 60 AS dump_hos,
    ISNULL(SUM(sdps.NrDumps), 0) AS [NrOfDumps],
    (ISNULL(SUM(sdps.TotalMillOreMined), 0) + ISNULL(SUM(sdps.TotalROMLeachMined), 0) + ISNULL(SUM(sdps.TotalCrushedLeachMined), 0) + ISNULL(SUM(sdps.TotalWasteMined), 0) + ISNULL(SUM(sdps.TotalTransferOre), 0)) AS [TotalMaterialMoved],
    (ISNULL(SUM(sdps.TotalMillOreMined), 0) + ISNULL(SUM(sdps.TotalROMLeachMined), 0) + ISNULL(SUM(sdps.TotalCrushedLeachMined), 0) + ISNULL(SUM(sdps.TotalWasteMined), 0)) AS [TotalMaterialMined],
    ISNULL(SUM(sdps.TotalTransferOre), 0) AS [RehandledOre],
    ISNULL(SUM(sdps.TotalMillOreMined), 0) AS [MillOreMined],
    ISNULL(SUM(sdps.TotalROMLeachMined), 0) AS [ROMLeachMined],
    ISNULL(SUM(sdps.TotalCrushedLeachMined), 0) AS [CrushedLeachMined],
    ISNULL(