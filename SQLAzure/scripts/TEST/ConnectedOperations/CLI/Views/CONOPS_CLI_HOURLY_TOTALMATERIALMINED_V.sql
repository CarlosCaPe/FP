CREATE VIEW [CLI].[CONOPS_CLI_HOURLY_TOTALMATERIALMINED_V] AS

 
--select * from [CLI].[CONOPS_CLI_HOURLY_TOTALMATERIALMINED_V] order by shiftseq      
CREATE VIEW [CLI].[CONOPS_CLI_HOURLY_TOTALMATERIALMINED_V]      
AS

WITH ShiftDump AS (
	SELECT  
        sd.shiftid,
        s.FieldId AS [ShovelId],
        sd.FIELDLSIZEDB AS [Tons],
        sl.FieldId AS [Location],
        enum.[Description],
        enum.Idx AS [Load],
        sg.FieldId AS [Blast],
		sd.dumptime_ts,
		sd.dumptime_hos
    FROM 
        cli.shift_dump_v sd WITH (NOLOCK)
    LEFT JOIN 
        cli.shift_eqmt s WITH (NOLOCK) ON s.Id = sd.FieldExcav
    LEFT JOIN 
        cli.shift_loc sl WITH (NOLOCK) ON sl.Id = sd.FieldLoc
    LEFT JOIN 
        cli.SHIFT_GRADE sg WITH (NOLOCK) ON sd.FIELDGRADE = sg.Id AND sd.origshiftid = sg.SHIFTID
    LEFT JOIN 
        cli.Enum enum WITH (NOLOCK) ON sd.FieldLoad = enum.Id
),


CTE AS(
    SELECT   
        sd.shiftid,
        sd.ShovelId,
        sd.Tons AS [TotalTons],
		dumptime_hos,
		dumptime_ts,
        CASE WHEN sd.[Blast] NOT LIKE 'N40_LOWOXIDE%' THEN sd.Tons END AS TotalMaterial,
        CASE 
            WHEN sd.[Location] LIKE '%CRUSHER%' 
			AND sd.[Description] IN ('H01', 'H02', 'H03', 'H04', 'H05', 'L01', 'L02', 'L03', 'L04', 'L05')
            THEN sd.Tons
            ELSE 0
        END AS [TotalExpitOre],
        CASE 
            WHEN (sd.[Location] LIKE '%MCN%' OR sd.[Location] LIKE '%INPIT%' 
				OR sd.[Location] LIKE '%IN%PIT%' OR sd.[Location] LIKE '%ROAD%' OR sd.[Description] LIKE '%SNOW%')
            AND sd.[Description] IN ('W01', 'W02', 'W03', 'W04', 'W05')
            THEN sd.Tons
            ELSE 0
        END AS [TotalWaste],
        CASE 
            WHEN (sd.[Location] LIKE '%SLS_%' OR sd.[Location] LIKE '%CSP_%' 
				OR sd.[Location] LIKE '%N40%' OR sd.[Location] LIKE '%DOSS%')
            AND sd.[Description] IN ('H01', 'H02', 'H03', 'H04', 'H05', 'L01', 'L02', 'L03', 'L04', 'L05')
            THEN sd.Tons
            ELSE 0
        END AS [TotalStockpiled],
        CASE 
            WHEN sd.[Load] IN (0) AND sd.[Location] NOT LIKE 'ROADFILL%'
            THEN sd.Tons
            ELSE 0
        END AS [TotalExpit],
        CASE 
            WHEN sd.[Load] IN (0) AND sd.[Location] LIKE 'ROADFILL%'
            THEN sd.Tons
            ELSE 0
        END AS [TotalInpit],
        CASE 
            WHEN sd.[Load] IN (0) THEN sd.Tons
            ELSE 0
        END AS [TotalLeach],
        CASE 
            WHEN sd.[Location] LIKE 'CRUSHER%'
			THEN sd.Tons
            ELSE 0
        END AS [OreRehandletoCrusher],
        CASE 
            WHEN sd.[Location] LIKE 'CRUSHER%' THEN sd.Tons
            ELSE 0
        END AS [TotalCrushedMillOre],
        CASE 
            WHEN sd.[Load] IN (0) AND sd.[Location] LIKE 'CRUSHER%'
            THEN sd.Tons
            ELSE 0
        END AS [ExpitOreToCrusher]
    FROM ShiftDump sd
),

ShovelByRegion AS (
    SELECT   
        pplr.FieldId AS [Region],
        pe.FieldId AS [ShovelId]
    FROM 
        cli.pit_excav pe WITH (NOLOCK)
    INNER JOIN 
        cli.pit_loc ppl WITH (NOLOCK) ON ppl.Id = pe.FieldLoc
    INNER JOIN 
        cli.pit_loc pplr WITH (NOLOCK) ON pplr.Id = ppl.FieldRegion
),

Summary AS(
SELECT  
    sdps.shiftid,
	dumptime_hos,
	CAST(FORMAT(dumptime_ts, 'yyyy-MM-dd HH:mm:00') AS DATETIME) AS dumping_time,
    COUNT(*) AS [NrOfDumps],
    ISNULL(SUM(sdps.TotalTons), 0) AS [TotalMaterialMoved],
    ISNULL(SUM(sdps.TotalMaterial), 0) AS [TotalMaterialMined],
    ISNULL(SUM(sdps.TotalExpitOre), 0) AS [MillOreMined],
    ISNULL(SUM(sdps.TotalWaste), 0) AS [WasteMined],
    ISNULL(SUM(sdps.TotalStockpiled), 0) AS [Stockpiled],
    ISNULL(SUM(sdps.TotalCrushedMillOre), 0) AS [TotalMaterialDeliveredtoCrusher],
    ISNULL(SUM(sdps.OreRehandletoCrusher), 0) AS [OreRehandletoCrusher],
    ISNULL(SUM(sdps.ExpitOreToCrusher), 0) AS [ExpitOreToCrusher],
    ISNULL(SUM(sdps.TotalInpit), 0) AS [To