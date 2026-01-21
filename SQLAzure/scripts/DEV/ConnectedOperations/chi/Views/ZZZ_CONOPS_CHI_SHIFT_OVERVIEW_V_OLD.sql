CREATE VIEW [chi].[ZZZ_CONOPS_CHI_SHIFT_OVERVIEW_V_OLD] AS


--select * from [chi].[CONOPS_CHI_SHIFT_OVERVIEW_V] order by shiftid
-- SELECT shiftid, sum(TotalMaterialMined) FROM [chi].[CONOPS_CHI_SHIFT_OVERVIEW_V] where shiftid = '230614001' group by shiftid
CREATE VIEW [chi].[CONOPS_CHI_SHIFT_OVERVIEW_V_OLD]
AS

SELECT Shiftid, 
       [ShovelId],
       ISNULL(SUM(NrDumps), 0) AS NRDumps ,
       0 AS [TotalMineralsMined],
       --ISNULL(SUM(TotalMaterial), 0) AS TotalMaterialMined ,
	   ISNULL(SUM(TotalInpit), 0) + ISNULL(SUM(OreRehandletoCrusher), 0) AS TotalMaterialMined ,
       0 AS [RehandledOre],
       ISNULL(SUM(TotalExpitOre), 0) AS MillOreMined ,
	   0 AS [ROMLeachMined],
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
            [ShovelId],
            SUM(LfTons) AS TotalMaterial ,
            COUNT(LfTons) AS NrDumps ,
            CASE
                WHEN [Load] IN (1, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
                     AND loc NOT LIKE ('ROADFILL%') THEN SUM(Lftons)
                ELSE 0
            END AS [TotalExpit] ,
            CASE
                WHEN [Load] IN (1, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17)
                     AND loc LIKE ('ROADFILL%') OR loc LIKE ('OVERLOAD%') THEN SUM(Lftons)
                ELSE 0
            END AS [TotalInpit] ,
            CASE
                WHEN [Load] IN (1, 8, 16) THEN SUM(LfTons)
                ELSE 0
            END AS [TotalWaste] ,
            CASE
                WHEN [Load] IN (5, 6, 9, 13, 17) THEN SUM(LfTons)
                ELSE 0
            END AS [TotalLeach] ,
            CASE
                WHEN [Load] IN (4)
                     AND loc LIKE 'CRUSHER' THEN SUM(LfTons)
                ELSE 0
            END AS [OreRehandletoCrusher] ,
            CASE
                WHEN [Load] IN (7, 10, 11, 12) THEN SUM(LfTons)
                ELSE 0
            END AS [TotalExpitOre] ,
            CASE
                WHEN [Load] IN (4, 7, 10, 11, 12)
                     AND loc like 'CRUSHER' THEN SUM(LfTons)
                ELSE 0
            END AS [TotalCrushedMillOre] ,
            CASE
                WHEN [Load] IN (7, 10, 11, 12)
                     AND loc like 'CRUSHER' THEN SUM(LfTons)
                ELSE 0
            END AS [ExpitOreToCrusher]
     FROM (
          SELECT enums.[DESCRIPTION] AS [Load],
                 dumps.shiftid,
                 s.FieldId AS [ShovelId],
                 l.FieldId AS loc,
                 --dumps.FieldLsizetons AS [LfTons]
				 dumps.FIELDLSIZEDB AS [LfTons]
          FROM chi.shift_dump dumps WITH (NOLOCK)
		  LEFT JOIN chi.shift_loc l WITH (NOLOCK) ON l.Id = dumps.FieldLoc
          LEFT JOIN chi.shift_eqmt s WITH (NOLOCK)  ON s.Id = dumps.FieldExcav AND s.SHIFTID = dumps.shiftid
          LEFT JOIN chi.shift_load loads WITH (NOLOCK) ON dumps.[FieldLoadRec] = loads.[Id]
          LEFT JOIN chi.enum enums WITH (NOLOCK) ON enums.Id=dumps.FieldLoad
          WHERE enums.Idx NOT IN (2)
     ) AS Consolidated
	 WHERE ShovelId IS NOT NULL
	 --AND shiftid = '230614001'
     GROUP BY Shiftid, ShovelId, [Load],  [loc]
) AS FINAL
GROUP BY Shiftid, ShovelId

