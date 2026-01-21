CREATE VIEW [TYR].[CONOPS_TYR_TRUCK_SHIFT_OVERVIEW_V] AS



-- SELECT * FROM [tyr].[CONOPS_TYR_TRUCK_SHIFT_OVERVIEW_V] where shiftid = '230807002' group by shiftid
CREATE VIEW [tyr].[CONOPS_TYR_TRUCK_SHIFT_OVERVIEW_V]
AS

SELECT Shiftid, 
       [TruckId],
       ISNULL(SUM(NrDumps), 0) AS NRDumps ,
       ISNULL(SUM(TotalMaterial), 0) AS TotalMaterialMoved ,
	   ISNULL(SUM([TotalExpit]), 0) AS TotalMaterialMined ,
       ISNULL(SUM(TotalExpitOre), 0) AS MillOreMined ,
	   ISNULL(SUM(TotalLeach), 0) AS [ROMLeachMined],
	   0 AS [CrushedLeachMined],
       ISNULL(SUM(TotalWaste), 0) AS WasteMined ,
       ISNULL(SUM(TotalCrushedMillOre), 0) AS TotalMaterialDeliveredtoCrusher ,
       ISNULL(SUM(TotalLeach), 0) AS LeachMined ,
       ISNULL(SUM(TotalExpit), 0) AS TotalExpitMined ,
       ISNULL(SUM(TotalInpit), 0) AS TotalInpitMined ,
       ISNULL(SUM(OreRehandletoCrusher), 0) AS OreRehandletoCrusher ,
       ISNULL(SUM(ExpitOreToCrusher), 0) AS ExpitOreToCrusher
FROM (
     SELECT [shiftid],
            [TruckId],
            SUM(LfTons) AS TotalMaterial ,
            COUNT(LfTons) AS NrDumps ,
            CASE
                WHEN [Load] NOT LIKE 'ORE REHANDLE'
                     AND loc NOT LIKE 'ROADFILL%' 
					 AND loc NOT LIKE 'OVERLOAD%' THEN SUM(Lftons)
                ELSE 0
            END AS [TotalExpit] ,
            CASE
                WHEN loc LIKE 'ROADFILL%' OR loc LIKE 'OVERLOAD%' THEN SUM(Lftons)
                ELSE 0
            END AS [TotalInpit] ,
            CASE
                WHEN ([Load] LIKE 'WASTE' OR [Load] LIKE 'AC_WASTE'  OR [Load] LIKE 'K_WASTE' OR [Load] LIKE 'LGL') --Requested by user : 159069
				AND loc NOT LIKE 'ROADFILL%' 
				AND loc NOT LIKE 'OVERLOAD%'
				--AND loc NOT LIKE 'LB%' --Requested by user : 159069
				--AND loc NOT LIKE 'SD%' --Requested by user : 159069
				THEN SUM(LfTons)
                ELSE 0
            END AS [TotalWaste] ,
            CASE
                WHEN [Load] LIKE 'ROM' AND loc NOT LIKE 'ROADFILL%' AND Loc NOT LIKE 'OVERLOAD%' 
					AND (loc LIKE 'SD%' OR loc LIKE 'LB%') --Requested by user : 159069
				THEN SUM(LfTons)
                ELSE 0
            END AS [TotalLeach] ,
            CASE
                WHEN [Load] LIKE 'ORE REHANDLE' THEN SUM(LfTons)
                ELSE 0
            END AS [OreRehandletoCrusher] ,
            CASE
                WHEN [Load] LIKE 'ORE0%' AND loc NOT LIKE 'ROADFILL%' AND Loc NOT LIKE 'OVERLOAD%' 
				THEN SUM(LfTons)
                ELSE 0
            END AS [TotalExpitOre] ,
            CASE
                WHEN loc like 'CRUSHER' THEN SUM(LfTons)
                ELSE 0
            END AS [TotalCrushedMillOre] ,
            CASE
                WHEN [Load] LIKE 'ORE0%'
                     AND loc like 'CRUSHER' THEN SUM(LfTons)
                ELSE 0
            END AS [ExpitOreToCrusher]
     FROM (
          SELECT enums.[DESCRIPTION] AS [Load],
                 dumps.shiftid,
                 s.FieldId AS [TruckId],
                 l.FieldId AS loc,
                 --dumps.FieldLsizetons AS [LfTons]
				 dumps.FIELDLSIZEDB AS [LfTons]
          FROM [tyr].shift_dump_v dumps WITH (NOLOCK)
		  LEFT JOIN [tyr].shift_loc l WITH (NOLOCK) ON l.Id = dumps.FieldLoc
          LEFT JOIN [tyr].shift_eqmt s WITH (NOLOCK)  ON s.Id = dumps.FieldTruck AND s.SHIFTID = dumps.shiftid
          LEFT JOIN [tyr].shift_load loads WITH (NOLOCK) ON dumps.[FieldLoadRec] = loads.[Id]
          LEFT JOIN [tyr].enum enums WITH (NOLOCK) ON enums.Id=dumps.FieldLoad
          WHERE enums.Idx NOT IN (2)
     ) AS Consolidated
	 WHERE TruckId IS NOT NULL
	 --AND shiftid = '230614001'
     GROUP BY Shiftid, TruckId, [Load],  [loc]
) AS FINAL
GROUP BY Shiftid, TruckId




